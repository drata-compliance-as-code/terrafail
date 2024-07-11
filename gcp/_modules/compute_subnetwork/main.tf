# ---------------------------------------------------------------------
# Compute Subnetwork
# ---------------------------------------------------------------------
resource "google_compute_subnetwork" "TerraFailComputeSubnetwork" {
  name          = "TerraFailComputeSubnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.TerraFailComputeSubnetwork_network.id
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  secondary_ip_range {
    range_name    = "TerraFailComputeSubnetwork_ip_range"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_subnetwork_iam_binding" "TerraFailComputeSubnetwork_iam_binding" {
  project    = google_compute_subnetwork.TerraFailComputeSubnetwork.project
  region     = google_compute_subnetwork.TerraFailComputeSubnetwork.region
  subnetwork = google_compute_subnetwork.TerraFailComputeSubnetwork.name
  role       = "roles/compute.networkUser"
  members = [
    "user@terrafail.com",
  ]
}

resource "google_compute_subnetwork_iam_member" "TerraFailComputeSubnetwork_iam_member" {
  project    = google_compute_subnetwork.TerraFailComputeSubnetwork.project
  region     = google_compute_subnetwork.TerraFailComputeSubnetwork.region
  subnetwork = google_compute_subnetwork.TerraFailComputeSubnetwork.name
  role       = "roles/compute.networkUser"
  member     = "allUsers"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "google_compute_network" "TerraFailComputeSubnetwork_network" {
  name                    = "TerraFailComputeSubnetwork_network"
  auto_create_subnetworks = false
}
