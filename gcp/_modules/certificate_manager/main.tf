# ---------------------------------------------------------------------
# Certificate Manager
# ---------------------------------------------------------------------
resource "google_certificate_manager_certificate" "sac_cert_manager" {
  name        = "issuance-config-cert"
  description = "The default cert"
  scope       = "EDGE_CACHE"
  managed {
    domains = [
      "terraform.subdomain1.com"
    ]
    issuance_config = google_certificate_manager_certificate_issuance_config.issuanceconfig.id
  }
}

resource "google_certificate_manager_certificate_map" "sac_cert_map" {
  name        = "cert-map"
  description = "My acceptance test certificate map"
}

resource "google_certificate_manager_certificate_map_entry" "sac_cert_map_entry" {
  name         = "cert-map-entry"
  description  = "My acceptance test certificate map entry"
  map          = google_certificate_manager_certificate_map.sac_cert_map.name
  certificates = [google_certificate_manager_certificate.sac_cert_manager.id]
  matcher      = "PRIMARY"
}

resource "google_certificate_manager_dns_authorization" "sac_cert_dns_auth" {
  name        = "dns-auth"
  description = "The default dnss"
  domain      = "subdomain.hashicorptest.com"
}
