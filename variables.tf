variable "name" {
  default = "gke-postgres"
}

variable "project" {
  default = "universal-development-dev"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "gke_location" {
  default = "us-central1-a"
}

variable "default_node_count" {
  default = 1
}

variable "pg_node_count" {
  default = 2
}

variable "default_machine_type" {
  default = "n1-standard-1"
}

variable "pg_machine_type" {
  default = "n1-standard-1"
}

variable "project_namespace" {
  default = "pgo"
}


variable "postgres_operator_namespace" {
  default = "postgres-operator"
}

