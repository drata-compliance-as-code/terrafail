# ---------------------------------------------------------------------
# PubSub
# ---------------------------------------------------------------------
resource "google_pubsub_topic" "sac_pubsub_topic" {
  name                       = "example-topic"
  message_retention_duration = "86600s"
  kms_key_name               = "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}"
}

resource "google_pubsub_subscription" "sac_pubsub_subscription" {
  name                       = "example-subscription"
  topic                      = google_pubsub_topic.sac_pubsub_topic.name
  message_retention_duration = "1200s"
  retain_acked_messages      = true
  ack_deadline_seconds       = 20
  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }
  enable_message_ordering = false
}

resource "google_pubsub_topic_iam_binding" "sac_pubsub_topic_binding" {
  project = google_pubsub_topic.sac_pubsub_topic.project
  topic   = google_pubsub_topic.sac_pubsub_topic.name
  role    = "roles/viewer"
  members = [
    "allUsers",
  ]
}

resource "google_pubsub_topic_iam_member" "sac_pubsub_topic_member" {
  project = google_pubsub_topic.sac_pubsub_topic.project
  topic   = google_pubsub_topic.sac_pubsub_topic.name
  role    = "roles/viewer"
  member  = "allUsers"
}

resource "google_pubsub_subscription_iam_binding" "sac_pubsub_sub_bindng" {
  subscription = "your-subscription-name"
  role         = "roles/editor"
  members = [
    "allUsers",
  ]
}

resource "google_pubsub_subscription_iam_member" "sac_pubsub_sub_member" {
  subscription = "your-subscription-name"
  role         = "roles/editor"
  member       = "allUsers"
}
