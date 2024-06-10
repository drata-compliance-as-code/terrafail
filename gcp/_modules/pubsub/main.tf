# ---------------------------------------------------------------------
# PubSub
# ---------------------------------------------------------------------
resource "google_pubsub_topic" "TerraFailPubsub" {
  name                       = "TerraFailPubsub"
  message_retention_duration = "86600s"
  kms_key_name               = "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}"
}

resource "google_pubsub_subscription" "TerraFailPubsub_subscription" {
  name                       = "TerraFailPubsub_subscription"
  topic                      = google_pubsub_topic.TerraFailPubsub.name
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

resource "google_pubsub_topic_iam_binding" "TerraFailPubsub_iam_binding" {
  project = google_pubsub_topic.TerraFailPubsub.project
  topic   = google_pubsub_topic.TerraFailPubsub.name
  role    = "roles/viewer"
  members = [
    "allUsers",
  ]
}

resource "google_pubsub_topic_iam_member" "TerraFailPubsub_iam_member" {
  project = google_pubsub_topic.TerraFailPubsub.project
  topic   = google_pubsub_topic.TerraFailPubsub.name
  role    = "roles/viewer"
  member  = "allUsers"
}

resource "google_pubsub_subscription_iam_binding" "TerraFailPubsub_sub_iam_binding" {
  subscription = "TerraFailPubsub_subscription"
  role         = "roles/editor"
  members = [
    "allUsers",
  ]
}

resource "google_pubsub_subscription_iam_member" "TerraFailPubsub_sub_iam_member" {
  subscription = "TerraFailPubsub_subscription"
  role         = "roles/editor"
  # Drata: Explicitly scope [google_pubsub_subscription_iam_member.role] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as (['roles/pubsub.editor', 'roles/editor', 'roles/pubsub.admin'])
  member       = "allUsers"
}
