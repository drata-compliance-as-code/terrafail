# ---------------------------------------------------------------------
# Redis
# ---------------------------------------------------------------------
resource "google_redis_instance" "TerraFailRedis" {
  name                    = "TerraFailRedis"
  memory_size_gb          = 1
  tier                    = "BASIC"
  auth_enabled            = false
  transit_encryption_mode = "SERVER_AUTHENTICATION"
}
