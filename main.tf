locals {
  gke_version = "1.18.17-gke.1200"
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}


resource "google_container_cluster" "gke" {
  name               = var.name
  project            = var.project
  description        = "GKE cluster for postgres deployment"
  min_master_version = local.gke_version
  location           = var.gke_location

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "default_pool" {
  name       = "${var.name}-default-pool"
  project    = var.project
  location   = var.gke_location
  cluster    = google_container_cluster.gke.name
  node_count = var.default_node_count
  version    = local.gke_version

  node_config {
    preemptible  = true
    machine_type = var.default_machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      app  = "postgres_demo"
      pool = "default_pool"
    }
  }
}

resource "google_container_node_pool" "pg_pool" {
  name       = "${var.name}-pg-pool"
  project    = var.project
  location   = var.gke_location
  cluster    = google_container_cluster.gke.name
  node_count = var.pg_node_count
  version    = local.gke_version

  node_config {
    preemptible  = true
    machine_type = var.pg_machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      app  = "postgres_demo"
      pool = "pg_pool"
    }
  }
}


resource "null_resource" "fetch_cluster_details" {
  depends_on = [google_container_node_pool.pg_pool]
  provisioner "local-exec" {
    command = "./scrips/container-config.sh ${var.name} ${var.zone} ${var.project}"
  }
}

data "google_client_config" "provider" {}

data "google_container_cluster" "gke" {
  depends_on = [google_container_node_pool.pg_pool]
  name       = var.name
  location   = var.gke_location
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.gke.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.gke.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate,
    )
  }
}

resource "kubernetes_namespace" "create_operator_namespace" {
  metadata {
    annotations = {
      name = var.postgres_operator_namespace
    }

    labels = {
      applabel = var.postgres_operator_namespace
    }

    name = var.postgres_operator_namespace
  }
}

data "kubernetes_namespace" "operator_namespace" {
  depends_on = [kubernetes_namespace.create_operator_namespace]

  metadata {
    name = var.postgres_operator_namespace
  }
}

resource "helm_release" "postgres_operator" {
  depends_on = [kubernetes_namespace.create_operator_namespace]

  name      = "postgres-operator"
  chart     = "./charts/postgres-operator"
  namespace = data.kubernetes_namespace.operator_namespace.metadata[0].name
  values    = [templatefile("./charts/postgres-operator-values.yaml", { name = var.name })]
}

resource "helm_release" "postgres_init" {
  depends_on = [helm_release.postgres_operator]

  name             = "postgres-init"
  chart            = "./charts/postgres-init"
  create_namespace = true
  namespace        = var.project_namespace
  values = [templatefile("./charts/postgres-init-values.yaml", {
    name         = var.name,
    db_name      = var.db_name,
    db_user      = var.db_user
    db_password  = var.db_password,
    db_replicas  = var.db_replicas,
    db_pgbouncer = var.db_pgbouncer
  })]

}

resource "null_resource" "gcp_account_secret" {
  depends_on = [helm_release.postgres_init]

  provisioner "local-exec" {
    command = "./scrips/load-default-secret.sh ${var.project_namespace}"
  }
}

resource "helm_release" "postgres_toolbox" {
  depends_on = [null_resource.gcp_account_secret, helm_release.postgres_init]

  name      = "postgres-toolbox"
  chart     = "./charts/postgres-toolbox"
  namespace = var.project_namespace
  values = [templatefile("./charts/postgres-toolbox-values.yaml", {
    name               = var.name,
    db_name            = var.db_name,
    db_user            = var.db_user
    db_password        = var.db_password,
    gs_backup_bucket   = var.gs_backup_bucket,
    db_backup_schedule = var.db_backup_schedule
  })]

}
