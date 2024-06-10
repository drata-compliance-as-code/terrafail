# ---------------------------------------------------------------------
# Cloud Functions
# ---------------------------------------------------------------------
resource "google_cloudfunctions_function" "TerraFailCloudFunctions" {
  name                          = "TerraFailCloudFunctions"
  description                   = "TerraFailCloudFunctions description"
  runtime                       = "nodejs16"
  available_memory_mb           = 128
  trigger_http                  = true
  entry_point                   = "helloGET"
  ingress_settings              = "ALLOW_ALL"
  vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
}

resource "google_cloudfunctions_function_iam_binding" "TerraFailCloudFunctions_iam_binding" {
  project        = google_cloudfunctions_function.TerraFailCloudFunctions.project
  region         = google_cloudfunctions_function.TerraFailCloudFunctions.region
  cloud_function = google_cloudfunctions_function.TerraFailCloudFunctions.name
  role           = "roles/viewer"
  members = [
    "allUsers",
  ]
}

resource "google_cloudfunctions_function_iam_member" "TerraFailCloudFunctions_iam_member" {
  project        = google_cloudfunctions_function.TerraFailCloudFunctions.project
  region         = google_cloudfunctions_function.TerraFailCloudFunctions.region
  cloud_function = google_cloudfunctions_function.TerraFailCloudFunctions.name
  role           = "roles/viewer"
  member         = "allUsers"
  # Drata: Explicitly scope [google_cloudfunctions_function_iam_member.member] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as ([allusers, allauthenticatedusers])
}
