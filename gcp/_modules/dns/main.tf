# ---------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------
resource "google_dns_managed_zone" "TerraFailDNS" {
  name        = "TerraFailDNS"
  dns_name    = "thisisthedarkside.com"
  description = "TerraFailDNS managed zone"
  visibility  = "private"
  dnssec_config {
    default_key_specs {
      algorithm = "rsasha1"
    }
    state = "off"
  }
}
