# ---------------------------------------------------------------------
# Compute Firewall
# ---------------------------------------------------------------------
resource "google_compute_firewall" "TerraFailComputeFirewall" {
  # Drata: Configure [google_compute_firewall.log_config] to ensure that security-relevant events are logged to detect malicious activity
  name          = "TerraFailComputeFirewall"
  network       = google_compute_network.TerraFailComputeFirewall_network.name
  direction     = "ingress"
  source_ranges = ["*"]
  # Drata: Ensure that [google_compute_firewall.source_ranges] is explicitly defined and narrowly scoped to only allow traffic from trusted sources
  source_tags   = ["web"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }
}

resource "google_compute_firewall_policy_rule" "TerraFailComputeFirewall_rule" {
  firewall_policy = google_compute_firewall_policy.default.name
  description     = "Resource created for Terraform acceptance testing"
  priority        = 9000
  enable_logging  = true
  action          = "allow"
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

    src_ip_ranges             = ["*"]
    dest_ip_ranges            = ["11.100.0.1/32"]
    dest_fqdns                = []
    dest_region_codes         = ["US"]
    dest_threat_intelligences = ["iplist-known-malicious-ips"]
    src_address_groups        = []
    dest_address_groups       = [google_network_security_address_group.basic_global_networksecurity_address_group.id]
  }
  target_service_accounts = ["my@service-account.com"]
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "google_compute_network" "TerraFailComputeFirewall_network" {
  name = "TerraFailComputeFirewall_network"
}
