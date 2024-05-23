# ---------------------------------------------------------------------
# Cloud Functions
# ---------------------------------------------------------------------
resource "google_cloudfunctions_function" "sac_function" {
  name                          = "function-test"
  description                   = "My function"
  runtime                       = "nodejs16"
  available_memory_mb           = 128
  trigger_http                  = true
  entry_point                   = "helloGET"
  ingress_settings              = "ALLOW_ALL"
  vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
}

resource "google_cloudfunctions_function_iam_binding" "binding" {
  project        = google_cloudfunctions_function.sac_function.project
  region         = google_cloudfunctions_function.sac_function.region
  cloud_function = google_cloudfunctions_function.sac_function.name
  role           = "roles/viewer"
  members = [
    "allUsers",
  ]
}

resource "google_cloudfunctions_function_iam_member" "member" {
  project        = google_cloudfunctions_function.sac_function.project
  region         = google_cloudfunctions_function.sac_function.region
  cloud_function = google_cloudfunctions_function.sac_function.name
  role           = "roles/viewer"
  member         = "allUsers"
}
