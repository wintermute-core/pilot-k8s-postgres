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

data "google_client_config" "provider" {}

data "google_container_cluster" "gke" {
  name     = var.name
  location = var.gke_location
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

resource "kubernetes_namespace" "create_deploy_namespace" {
  metadata {
    annotations = {
      name = var.gke_namespace
    }

    labels = {
      applabel = var.gke_namespace
    }

    name = var.gke_namespace
  }
}

data "kubernetes_namespace" "deploy_namespace" {
  depends_on = [kubernetes_namespace.create_deploy_namespace]

  metadata {
    name = var.gke_namespace
  }
}

resource "helm_release" "nginx" {
  depends_on = [kubernetes_namespace.create_deploy_namespace]

  name      = "test-nginx"
  chart     = "./charts/nginx"
  namespace = data.kubernetes_namespace.deploy_namespace.metadata[0].name

}

