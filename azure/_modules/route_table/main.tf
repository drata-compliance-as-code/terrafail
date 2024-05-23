resource "azurerm_resource_group" "route_table_rg" {
  name     = "route-table-rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Route Table
# ---------------------------------------------------------------------
resource "azurerm_route_table" "sac_route_table" {
  name                          = "sac-route-table"
  location                      = azurerm_resource_group.route_table_rg.location
  resource_group_name           = azurerm_resource_group.route_table_rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }
}
