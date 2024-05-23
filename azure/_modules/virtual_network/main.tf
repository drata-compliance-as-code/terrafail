resource "azurerm_resource_group" "sac_virtual_network" {
  name     = "sac_virtual_network"
  location = "East US"
}

# ---------------------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------------------
resource "azurerm_virtual_network" "sac_virutal_network" {
  name                = "sac-testing-virtual-network"
  location            = azurerm_resource_group.sac_virtual_network.location
  resource_group_name = azurerm_resource_group.sac_virtual_network.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.sac_vn_ddos_plan.id
    enable = false
  }

  subnet {
    name           = "subnet"
    address_prefix = "10.0.2.0/24"
  }
}

resource "azurerm_network_ddos_protection_plan" "sac_vn_ddos_plan" {
  name                = "sac-protection-plan"
  location            = azurerm_resource_group.sac_virtual_network.location
  resource_group_name = azurerm_resource_group.sac_virtual_network.name
}
