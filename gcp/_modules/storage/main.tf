# ---------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------
resource "google_storage_bucket" "sac_storage_bucket" {
  name                        = "gcp-storage"
  location                    = "US-EAST1"
  uniform_bucket_level_access = true
  versioning {
    enabled = false
  }
  retention_policy {
    retention_period = 267840
  }
  cors {
    method = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    origin = ["*"]
  }
}

resource "google_storage_bucket_object" "sac_storage_object" {
  name    = "functions_object"
  bucket  = google_storage_bucket.sac_storage_bucket.name
  content = "test_content"
}