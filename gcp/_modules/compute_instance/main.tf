# ---------------------------------------------------------------------
# Compute Instance
# ---------------------------------------------------------------------

resource "google_compute_instance" "sac_compute_instance" {
  name         = "test-instance"
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
    value                  = "tests"
    block-project-ssh-keys = "false"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  attached_disk {
    source = "test"
  }
  confidential_instance_config {
    enable_confidential_compute = false
  }
}
