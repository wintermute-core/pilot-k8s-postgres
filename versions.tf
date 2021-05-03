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

    nullresource = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

  }

  required_version = ">= 0.12"
}