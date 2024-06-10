# ---------------------------------------------------------------------
# Compute Instance
# ---------------------------------------------------------------------

resource "google_compute_instance" "TerraFailComputeInstance" {
  # Drata: Set [configId] to ensure that organization-wide label conventions are followed.
  name         = "TerraFailComputeInstance"
  machine_type = "e2-medium"
  zone         = "us-east1-b"
  project      = "project-id"

  scheduling {
    on_host_maintenance = "TERMINATE"
  }

  network_interface {
    network = "default"
  }

  shielded_instance_config {
    enable_integrity_monitoring = false
    enable_secure_boot          = false
    enable_vtpm                 = false
  }
  metadata = {
    value                  = "terrafail"
    block-project-ssh-keys = "false"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  attached_disk {
    source = "terrafail"
  }
  confidential_instance_config {
    enable_confidential_compute = false
  }
}
