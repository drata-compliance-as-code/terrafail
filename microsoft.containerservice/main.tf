resource "azurerm_resource_group" "sac_aks_resource_group" {
  name     = "sac-testing-aks-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# AKS
# ---------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "sac_aks_cluster" {
  # Drata: Ensure that [azurerm_kubernetes_cluster.api_server_authorized_ip_ranges] is explicitly defined and narrowly scoped to only allow trusted sources to access AKS Control Plane
  name                = "sac-testing-aks-cluster"
  location            = azurerm_resource_group.sac_aks_resource_group.location
  resource_group_name = azurerm_resource_group.sac_aks_resource_group.name
  dns_prefix          = "sac-testing-cluster"
  default_node_pool {
    name                = "sacakspool"
    vm_size             = "Standard_D2_v2"
    node_count          = 1
    enable_auto_scaling = false
    zones               = []
  }
  #disk_encryption_set_id = azurerm_disk_encryption_set.sac_disk_encryption_set.id  # SaC Testing - Severity: Critical - Set disk_encryption_set_id to ""
  local_account_disabled  = false # SaC Testing - Severity: Critical - Set local_account_disabled to False
  private_cluster_enabled = false # SaC Testing - Severity: High - Set private_cluster_enabled to false
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    #network_policy = "azure" # SaC Testing - Severity: Low - Set network_policy to undefined
  }
  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = false # SaC Testing - Severity: Critical - Set azure_rbac_enabled to false
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   Environment = "Production"
  # }
  # automatic_channel_upgrade = "stable" # SaC Testing - Severity: Low - Set automatic_channel_upgrade to one of ['stable', 'rapid', 'patch']
}

resource "azurerm_kubernetes_cluster_node_pool" "sac_aks_node_pool" {
  name                  = "sacakspool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.sac_aks_cluster.id
  vm_size               = "Standard_DS2_v2"
  enable_node_public_ip = true # SaC Testing - Severity: Critical - Set enable_node_public_ip to true
  #zones = [2,1]  # SaC Testing - Severity: High - Set zones to []
  enable_auto_scaling = false # SaC Testing - Severity: High - Set enable_auto_scaling to false
  max_count           = 100
  min_count           = 0
}
