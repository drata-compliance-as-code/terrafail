# ---------------------------------------------------------------------
# Spanner
# ---------------------------------------------------------------------
resource "google_spanner_instance" "TerraFailSpanner_instance" {
  config        = "regional-us-east1"
  display_name  = "TerraFailSpanner_instance"
  num_nodes     = 1
  project       = "terrafail"
  force_destroy = true
}

resource "google_spanner_instance_iam_binding" "TerraFailSpanner_instance_iam_binding" {
  instance = "TerraFailSpanner_instance"
  role     = "roles/spanner.databaseAdmin"
  members = [
    "allUsers",
  ]
}

resource "google_spanner_instance_iam_member" "TerraFailSpanner_instance_iam_member" {
  instance = "your-instance-name"
  role     = "roles/spanner.databaseAdmin"
  member   = "allUsers"
}

resource "google_spanner_database" "TerraFailSpanner_database" {
  instance            = google_spanner_instance.TerraFailSpanner_instance.name
  name                = "TerraFailSpanner_database"
  project             = "terrafail"
  deletion_protection = false
}

resource "google_spanner_database_iam_binding" "TerraFailSpanner_database_iam_binding" {
  instance = "TerraFailSpanner_instance"
  database = "TerraFailSpanner_database"
  role     = "roles/compute.networkUser"
  members = [
    "allUsers",
  ]
}

resource "google_spanner_database_iam_member" "TerraFailSpanner_database_iam_member" {
  instance = "TerraFailSpanner_instance"
  database = "TerraFailSpanner_database"
  role     = "roles/compute.networkUser"
  member   = "allUsers"
  # Drata: Explicitly scope [google_spanner_database_iam_member.member] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as ([allusers, allauthenticatedusers])
}
