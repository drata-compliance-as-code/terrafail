# ---------------------------------------------------------------------
# Compute Subnetwork
# ---------------------------------------------------------------------
resource "google_compute_subnetwork" "sac_compute_subnetwork" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.custom-test.id
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_subnetwork_iam_binding" "sac_compute_subnetwork_binding" {
  project    = google_compute_subnetwork.sac_compute_subnetwork.project
  region     = google_compute_subnetwork.sac_compute_subnetwork.region
  subnetwork = google_compute_subnetwork.sac_compute_subnetwork.name
  role       = "roles/compute.networkUser"
  members = [
    "allUsers",
  ]
}

resource "google_compute_subnetwork_iam_member" "member" {
  project    = google_compute_subnetwork.sac_compute_subnetwork.project
  region     = google_compute_subnetwork.sac_compute_subnetwork.region
  subnetwork = google_compute_subnetwork.sac_compute_subnetwork.name
  role       = "roles/compute.networkUser"
  member     = "allUsers"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "google_compute_network" "custom-test" {
  name                    = "test-network"
  auto_create_subnetworks = false
}
