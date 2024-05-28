resource "azurerm_resource_group" "TerraFailRoute_rg" {
  name     = "TerraFailRoute_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Route Table
# ---------------------------------------------------------------------
resource "azurerm_route_table" "TerraFailRoute_table" {
  name                          = "TerraFailRoute_table"
  location                      = azurerm_resource_group.TerraFailRoute_rg.location
  resource_group_name           = azurerm_resource_group.TerraFailRoute_rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }
}
