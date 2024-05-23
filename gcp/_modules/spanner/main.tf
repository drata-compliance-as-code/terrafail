# ---------------------------------------------------------------------
# Spanner
# ---------------------------------------------------------------------
resource "google_spanner_instance" "sac_spanner_instance" {
  config        = "regional-us-east1"
  display_name  = "test-instance"
  num_nodes     = 1
  project       = "project-id"
  force_destroy = true
}

resource "google_spanner_instance_iam_binding" "sac_spanner_instance_binding" {
  instance = "sac-spanner"
  role     = "roles/spanner.databaseAdmin"
  members = [
    "allUsers",
  ]
}

resource "google_spanner_instance_iam_member" "sac_spanner_instance_member" {
  instance = "your-instance-name"
  role     = "roles/spanner.databaseAdmin"
  member   = "allUsers"
}

resource "google_spanner_database" "sac_spanner_db" {
  instance            = google_spanner_instance.sac_spanner_instance.name
  name                = "test-database"
  project             = "project-id"
  deletion_protection = false
}

resource "google_spanner_database_iam_binding" "sac_spanner_db_binding" {
  instance = "your-instance-name"
  database = "your-database-name"
  role     = "roles/compute.networkUser"
  members = [
    "allUsers",
  ]
}

resource "google_spanner_database_iam_member" "sac_spanner_db_member" {
  instance = "your-instance-name"
  database = "your-database-name"
  role     = "roles/compute.networkUser"
  member   = "allUsers"
}
