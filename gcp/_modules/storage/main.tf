# ---------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------
resource "google_storage_bucket" "TerraFailStorage" {
  # Drata: Set [configId] to ensure that organization-wide label conventions are followed.
  name                        = "TerraFailStorage"
  location                    = "US-EAST1"
  uniform_bucket_level_access = true
  versioning {
    enabled = false
  }
  retention_policy {
    retention_period = 2678400
  }
  cors {
    method = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    origin = ["*"]
  }
}

resource "google_storage_bucket_object" "TerraFailStorage_object" {
  name    = "TerraFailStorage_object"
  bucket  = google_storage_bucket.TerraFailStorage.name
  content = "TerraFailStorage_object content"
}
