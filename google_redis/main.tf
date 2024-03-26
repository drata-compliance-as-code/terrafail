# ---------------------------------------------------------------------
# Redis
# ---------------------------------------------------------------------
resource "google_redis_instance" "sac_redis_cache" {
  name                    = "memory-cache"
  memory_size_gb          = 1
  tier                    = "BASIC"    # SaC Testing - Severity: Moderate - set tier != STANDARD_HA
  auth_enabled            = false      # SaC Testing - Severity: Critical - set auth_enabled to false
  transit_encryption_mode = "DISABLED" # SaC Testing - Severity: Critical - set transit_encryption_mode != SERVER_AUTHENTICATION
  #customer_managed_key = "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}" # SaC Testing - Severity: Moderate - set customer_managed_key to undefined
  # SaC Testing - Severity: Moderate - set labels to undefined
  # labels = {
  #   env = "test"
  # }
}
