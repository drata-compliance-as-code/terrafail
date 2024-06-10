# ---------------------------------------------------------------------
# Certificate Manager
# ---------------------------------------------------------------------
resource "google_certificate_manager_certificate" "TerraFailCertManager" {
  name        = "TerraFailCertManager"
  description = "TerraFailCertManager description"
  scope       = "EDGE_CACHE"
  managed {
    domains = [
      "terraform.subdomain1.com"
    ]
    issuance_config = google_certificate_manager_certificate_issuance_config.issuanceconfig.id
  }
}

resource "google_certificate_manager_certificate_map" "TerraFailCertManager_map" {
  # Drata: Set [configId] to ensure that organization-wide label conventions are followed.
  name        = "TerraFailCertManager_map"
  description = "TerraFailCertManager certificate map"
}

resource "google_certificate_manager_certificate_map_entry" "TerraFailCertManager_map_entry" {
  # Drata: Set [configId] to ensure that organization-wide label conventions are followed.
  name         = "TerraFailCertManager_map_entry"
  description  = "TerraFailCertManager map entry"
  map          = google_certificate_manager_certificate_map.TerraFailCertManager_map.name
  certificates = [google_certificate_manager_certificate.TerraFailCertManager.id]
  matcher      = "PRIMARY"
}

resource "google_certificate_manager_dns_authorization" "TerraFailCertManager_dns_authorization" {
  # Drata: Set [configId] to ensure that organization-wide label conventions are followed.
  name        = "TerraFailCertManager_dns_authorization"
  description = "TerraFailCertManager dns authorization"
  domain      = "subdomain.hashicorptest.com"
}
