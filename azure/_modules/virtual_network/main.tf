resource "azurerm_resource_group" "TerraFailVNet_rg" {
  name     = "TerraFailVNet_rg"
  location = "East US"
}

# ---------------------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------------------
resource "azurerm_virtual_network" "TerraFailVNet" {
  # Drata: Set [azurerm_virtual_network.tags] to ensure that organization-wide tagging conventions are followed.
  name                = "TerraFailVNet"
  location            = azurerm_resource_group.TerraFailVNet_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVNet_rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.TerraFailVNet_ddos_protection_plan.id
    enable = false
  }

  subnet {
    name           = "subnet"
    address_prefix = "10.0.2.0/24"
  }
}

resource "azurerm_network_ddos_protection_plan" "TerraFailVNet_ddos_protection_plan" {
  name                = "TerraFailVNet_ddos_protection_plan"
  location            = azurerm_resource_group.TerraFailVNet_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVNet_rg.name
}
