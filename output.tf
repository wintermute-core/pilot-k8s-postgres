output "gke_endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "backups_bucket" {
  value = google_storage_bucket.backups_bucket.name
}
