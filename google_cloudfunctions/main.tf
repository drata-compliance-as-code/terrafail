# ---------------------------------------------------------------------
# Cloud Functions
# ---------------------------------------------------------------------
resource "google_cloudfunctions_function" "sac_function" {
  name                = "function-test"
  description         = "My function"
  runtime             = "nodejs16" # SaC Testing - Severity: High - set runtime to non-preferred value
  available_memory_mb = 128
  trigger_http        = true
  entry_point         = "helloGET"
  ingress_settings    = "ALLOW_ALL" # SaC Testing - Severity: High - set ingress_settings to ['ALLOW_ALL', '']
  #service_account_email = "test@oak9.io" # SaC Testing - Severity: High - set service_account_email to undefined
  #kms_key_name = "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}" # SaC Testing - Severity: Critical - set kms_key_name to undefined
  vpc_connector_egress_settings = "ALL_TRAFFIC"
  # SaC Testing - Severity: Moderate - set labels to undefined
  # labels = {
  #   env = "test"
  # }
}

resource "google_cloudfunctions_function_iam_binding" "binding" {
  project        = google_cloudfunctions_function.sac_function.project
  region         = google_cloudfunctions_function.sac_function.region
  cloud_function = google_cloudfunctions_function.sac_function.name
  role           = "roles/viewer"
  members = [ # SaC Testing - Severity: Critical - set members = 'allUsers'
    "allUsers",
  ]
}

resource "google_cloudfunctions_function_iam_member" "member" {
  project        = google_cloudfunctions_function.sac_function.project
  region         = google_cloudfunctions_function.sac_function.region
  cloud_function = google_cloudfunctions_function.sac_function.name
  role           = "roles/viewer"
  member         = "allUsers" # SaC Testing - Severity: Critical - set members = 'allUsers'
}
