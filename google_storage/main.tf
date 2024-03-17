# ---------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------
resource "google_storage_bucket" "sac_storage_bucket" {
  name                        = "gcp-storage"
  location                    = "US-EAST1"
  uniform_bucket_level_access = true
  versioning {
    enabled = false # condition: SaC Testing - Severity: Moderate - set enabled to False
  }
  retention_policy {
    retention_period = 267840 # SaC Testing - Severity: Moderate - set retention_period to < 2678400
  }
  # encryption {  # condition: SaC Testing - Severity: Moderate - set encryption to undefined
  #   kms_key_name = "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}"
  # }
  cors {
    method = ["GET", "HEAD", "PUT", "POST", "DELETE"] # SaC Testing - Severity: High - set method to non-preferred value
    origin = ["*"]                                    # SaC Testing - Severity: High - set origin to "*"
  }
  # SaC Testing - Severity: Moderate - set labels to undefined
  # labels = {
  #   env = "test"
  # }
}

resource "google_storage_bucket_object" "sac_storage_object" {
  name    = "functions_object"
  bucket  = google_storage_bucket.sac_storage_bucket.name
  content = "test_content"
  #kms_key_name = "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}" # condition: SaC Testing - Severity: Moderate - set kms_key_name to undefined
}

# SaC Testing - Severity: High - set ACLs to undefined
# resource "google_storage_bucket_access_control" "sac_storage_access_control" {
#   bucket = google_storage_bucket.sac_storage_bucket.name
#   role   = "READER"
#   entity = "allUsers"
# }

# resource "google_storage_bucket_acl" "sac_storage_access_control" {
#   bucket = google_storage_bucket.sac_storage_bucket.name

#   role_entity = [
#     "OWNER:user-my.email@gmail.com",
#     "READER:group-mygroup",
#   ]
# }

# resource "google_storage_default_object_access_control" "sac_storage_default_control" {
#   bucket = google_storage_bucket.sac_storage_bucket.name
#   role   = "READER"
#   entity = "allUsers"
# }

# resource "google_storage_default_object_acl" "sac_storage_default_acl" {
#   bucket = google_storage_bucket.sac_storage_bucket.name
#   role_entity = [
#     "OWNER:user-my.email@gmail.com",
#     "READER:group-mygroup",
#   ]
# }

# resource "google_storage_object_access_control" "sac_storage_object_access" {
#   object = google_storage_bucket_object.sac_storage_object.output_name
#   bucket = google_storage_bucket.sac_storage_bucket.name
#   role   = "READER"
#   entity = "allUsers"
# }

# resource "google_storage_object_acl" "sac_storage_object_acl" {
#   object = google_storage_bucket_object.sac_storage_object.output_name
#   bucket = google_storage_bucket.sac_storage_bucket.name

#   role_entity = [
#     "OWNER:user-my.email@gmail.com",
#     "READER:group-mygroup",
#   ]
# }
