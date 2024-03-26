# ---------------------------------------------------------------------
# Compute Firewall
# ---------------------------------------------------------------------
resource "google_compute_firewall" "sac_compute_firewall" {
  name      = "test-firewall"
  network   = google_compute_network.compute_network.name
  direction = "ingress"
  # log_config {  # SaC Testing - Severity: Low - set log_config to undefined
  #   metadata = "EXCLUDE_ALL_METADATA"
  # }
  allow { # condition: SaC Testing - Severity: High - set allow to defined
    protocol = "icmp"
  }
  source_ranges = ["*"] # SaC Testing - Severity: High - set source_ranges to ['*', '0.0.0.0/0']
  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }
  source_tags = ["web"]
}

resource "google_compute_firewall_policy_rule" "sac_compute_firewall_rule" {
  firewall_policy = google_compute_firewall_policy.default.name
  description     = "Resource created for Terraform acceptance testing"
  priority        = 9000
  enable_logging  = false   # SaC Testing - Severity: Moderate - set enable_logging to False
  action          = "allow" # condition: SaC Testing - Severity: High - set to 'allow'
  direction       = "EGRESS"
  disabled        = false
  match {
    layer4_configs {
      ip_protocol = "tcp"
      ports       = [8080]
    }
    layer4_configs {
      ip_protocol = "udp"
      ports       = [22]
    }
    src_ip_ranges             = ["*"] # SaC Testing - Severity: High - set src_ip_ranges to ['*', '0.0.0.0/0']
    dest_ip_ranges            = ["11.100.0.1/32"]
    dest_fqdns                = []
    dest_region_codes         = ["US"]
    dest_threat_intelligences = ["iplist-known-malicious-ips"]
    src_address_groups        = []
    dest_address_groups       = [google_network_security_address_group.basic_global_networksecurity_address_group.id]
  }
  target_service_accounts = ["my@service-account.com"]
}