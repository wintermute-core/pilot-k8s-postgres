terraform {

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.65.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.0.3"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.1.2"
    }

  }

  required_version = ">= 0.12"
}