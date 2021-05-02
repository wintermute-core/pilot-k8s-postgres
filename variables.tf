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

variable "db_name" {
  default = "potato666"
}

variable "db_replicas" {
  default = "3"
}

variable "db_pgbouncer" {
  default = "2"
}

variable "db_user" {
  default = "potatouser"
}

variable "db_password" {
  default = "potato123"
}

variable "db_backup_schedule" {
  default = "*/30 * * * *"
}
