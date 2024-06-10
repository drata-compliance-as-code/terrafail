# ---------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------
resource "google_dns_managed_zone" "TerraFailDNS" {
  # Drata: Set [configId] to ensure that organization-wide label conventions are followed.
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
