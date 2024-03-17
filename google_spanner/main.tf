# ---------------------------------------------------------------------
# Spanner
# ---------------------------------------------------------------------
resource "google_spanner_instance" "sac_spanner_instance" {
  config        = "regional-us-east1"
  display_name  = "test-instance"
  num_nodes     = 1
  project       = "test-projectID"
  force_destroy = true # SaC Testing - Severity: Low - set force_destroy to true 
  # SaC Testing - Severity: Moderate - set labels to undefined
  # labels = {
  #   env = "test"
  # }
}

resource "google_spanner_instance_iam_binding" "sac_spanner_instance_binding" {
  instance = "sac-spanner"
  role     = "roles/spanner.databaseAdmin"
  members = [ # SaC Testing - Severity: Critical - set members to 'allUsers'
    "allUsers",
  ]
}

resource "google_spanner_instance_iam_member" "sac_spanner_instance_member" {
  instance = "your-instance-name"
  role     = "roles/spanner.databaseAdmin"
  member   = "allUsers" # SaC Testing - Severity: Critical - set members to 'allUsers'
}

resource "google_spanner_database" "sac_spanner_db" {
  instance            = google_spanner_instance.sac_spanner_instance.name
  name                = "test-database"
  project             = "test-projectID"
  deletion_protection = false
  # encryption_config {
  #   #kms_key_name = "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}" # SaC Testing - Severity: Moderate - set kms_key_name to undefined 
  # }
}

resource "google_spanner_database_iam_binding" "sac_spanner_db_binding" {
  instance = "your-instance-name"
  database = "your-database-name"
  role     = "roles/compute.networkUser"
  members = [ # SaC Testing - Severity: Critical - set members to 'allUsers'
    "allUsers",
  ]
}

resource "google_spanner_database_iam_member" "sac_spanner_db_member" {
  instance = "your-instance-name"
  database = "your-database-name"
  role     = "roles/compute.networkUser"
  member   = "allUsers" # SaC Testing - Severity: Critical - set members to 'allUsers'
}
