# ---------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------
resource "google_dns_managed_zone" "sac_dns_zone" {
  name        = "test-zone"
  dns_name    = "thisisthedarkside.com."
  description = "Example DNS zone"
  visibility  = "private"
  dnssec_config {
    default_key_specs {
      algorithm = "rsasha1"
    }
    state = "off"
  }
}
