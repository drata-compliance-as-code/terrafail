
# ---------------------------------------------------------------------
# Cloud Tasks
# ---------------------------------------------------------------------
resource "google_cloud_tasks_queue_iam_binding" "TerraFailCloudTasks_iam_binding" {
  name = "TerraFailCloudTasks_iam_binding"
  role = "roles/viewer"
  members = [
    "allUsers",
  ]
}

resource "google_cloud_tasks_queue_iam_member" "TerraFailCloudTasks_iam_member" {
  project  = google_cloud_tasks_queue.TerraFailCloudTasks_queue.project
  location = google_cloud_tasks_queue.TerraFailCloudTasks_queue.location
  name     = google_cloud_tasks_queue.TerraFailCloudTasks_queue.name
  role     = "roles/viewer"
  member   = "allUsers"
}

resource "google_cloud_tasks_queue" "TerraFailCloudTasks_queue" {
  # Drata: Configure [google_cloud_tasks_queue.stackdriver_logging_config] to ensure that security-relevant events are logged to detect malicious activity
  name     = "TerraFailCloudTasks_queue"
  location = "us-central1"
  app_engine_routing_override {
    service  = "worker"
    version  = "1.0"
    instance = "terrafail"
  }
  rate_limits {
    max_concurrent_dispatches = 3
    max_dispatches_per_second = 2
  }
  retry_config {
    max_attempts       = 5
    max_retry_duration = "4s"
    max_backoff        = "3s"
    min_backoff        = "2s"
    max_doublings      = 1
  }
}
