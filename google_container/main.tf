# ---------------------------------------------------------------------
# Container
# ---------------------------------------------------------------------
resource "google_container_cluster" "sac_container_cluster" {
  name                    = "test-container"
  initial_node_count      = 3
  enable_kubernetes_alpha = true  # SaC Testing - Severity: Moderate - set enable_kubernetes_alpha to True
  enable_shielded_nodes   = false # SaC Testing - Severity: Moderate - set enable_shielded_nodes to False
  enable_legacy_abac      = true  # SaC Testing - Severity: Moderate - set enable_legacy_abac to True
  binary_authorization {
    evaluation_mode = "DISABLED" # SaC Testing - Severity: Low - set evaluation_mode to 'DISABLED'
  }
  database_encryption {
    state    = "DECRYPTED" # SaC Testing - Severity: High - set state to 'DECRYPTED'
    key_name = "projects/my-project/locations/global/keyRings/my-ring/cryptoKeys/my-key"
  }
  node_config {
    disk_size_gb = 10
    image_type   = "UBUNTU_CONTAINERD" # SaC Testing - Severity: Moderate - set image_type != ['COS_CONTAINERD', 'COS']
    # SaC Testing - Severity: Moderate - set labels to undefined
    # labels = {
    #   env = "test"
    # }
  }
  datapath_provider = "LEGACY_DATAPATH" # condition: SaC Testing - Severity: High - set datapath_provider to 'LEGACY_DATAPATH'
  network_policy {
    provider = "PROVIDER_UNSPECIFIED"
    enabled  = false # SaC Testing - Severity: High - set enabled to False
  }
}

resource "google_container_node_pool" "test_nodepool" {
  name       = "test-nodepool"
  cluster    = google_container_cluster.sac_container_cluster.name
  node_count = 1
  node_config {
    disk_size_gb = 10
    image_type   = "UBUNTU_CONTAINERD" # SaC Testing - Severity: Moderate - set image_type != ['COS_CONTAINERD', 'COS']
    # SaC Testing - Severity: Moderate - set labels to undefined
    # labels = {
    #   env = "test"
    # }
  }
  management {
    auto_repair  = false # SaC Testing - Severity: Low - set auto_repair to False
    auto_upgrade = true
  }
}
