variable "name" {
  type        = string
  description = "Deployment name, used in GKE name and GS bucket name"
  default     = "gke-postgres"
}

variable "project" {
  type        = string
  description = "GCP project name"
  default     = "gentle-cable-224311"
}

variable "region" {
  type        = string
  description = "GCP region for deployment"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP zone for deployment"
  default     = "us-central1-a"
}

variable "gke_location" {
  type        = string
  description = "Specific location of GKE cluster"
  default     = "us-central1-a"
}

variable "gke_preemptible" {
  type        = bool
  description = "Use preemptible K8S nodes to save costs(and add more risks (: )"
  default     = true
}

variable "gke_default_node_count" {
  type        = number
  description = "Number of GKE ndoes in default node pool"
  default     = 2
}

variable "gke_pg_node_count" {
  type        = number
  description = "Number of GKE ndoes node pool for postgresql"
  default     = 3
}

variable "gke_default_machine_type" {
  type        = string
  description = "Machine type for nodes in default pool"
  default     = "n1-standard-1"
}

variable "gke_pg_machine_type" {
  type        = string
  description = "Machine type for nodes in GKE pool"
  default     = "n1-standard-2"
}

variable "project_namespace" {
  type        = string
  description = "Namespace where to deploy postgres db"
  default     = "pgo"
}


variable "postgres_operator_namespace" {
  type        = string
  description = "Namespace where to deploy postgresql operator chart"
  default     = "postgres-operator"
}

variable "db_replicas" {
  type        = number
  description = "Number of database replicas"
  default     = 2
}

variable "db_pgbouncer" {
  type        = number
  description = "Number of pgbouncer replicas"
  default     = 2
}

variable "db_name" {
  type        = string
  description = "Postgresql database name"
  default     = "potato666"
}

variable "db_user" {
  type        = string
  description = "DB user name"
  default     = "potatouser"
}

variable "db_password" {
  type        = string
  description = "DB user password"
  default     = "potato123"
}

variable "db_backup_schedule" {
  type        = string
  description = "DB backup schedule"
  default     = "*/30 * * * *"
}

variable "image_toolbox_repository" {
  type        = string
  description = "Toolbox container repository"
  default     = "denis256/toolbox"
}

variable "image_toolbox_tag" {
  type        = string
  description = "Toolbox container image"
  default     = "0.0.2"
}
