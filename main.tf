
locals {
  gke_version = "1.18"
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
  location           = var.region

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
  location   = var.region
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
  location   = var.region
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

