
# ---------------------------------------------------------------------
# Cloud Tasks
# ---------------------------------------------------------------------
resource "google_cloud_tasks_queue_iam_binding" "sac_task_iam_binding" {
  name = "Google cloiud Task"
  role = "roles/viewer"
  members = [
    "allUsers",
  ]
}

resource "google_cloud_tasks_queue_iam_member" "sac_task_iam_member" {
  project  = google_cloud_tasks_queue.sac_task_queue.project
  location = google_cloud_tasks_queue.sac_task_queue.location
  name     = google_cloud_tasks_queue.sac_task_queue.name
  role     = "roles/viewer"
  member   = "allUsers"
}

resource "google_cloud_tasks_queue" "sac_task_queue" {
  name     = "instance-name"
  location = "us-central1"
  app_engine_routing_override {
    service  = "worker"
    version  = "1.0"
    instance = "test"
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
