

resource "azurerm_resource_group" "TerraFailNSG_rg" {
  name     = "TerraFailNSG_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_network_security_group" "TerraFailNSG_inbound" {
  # Drata: Set [azurerm_network_security_group.tags] to ensure that organization-wide tagging conventions are followed.
  name                = "TerraFailNSG_inbound"
  location            = azurerm_resource_group.TerraFailNSG_rg.location
  resource_group_name = azurerm_resource_group.TerraFailNSG_rg.name

  security_rule {
    name                       = "TerraFailNSG_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "TerraFailNSG_outbound" {
  # Drata: Set [azurerm_network_security_group.tags] to ensure that organization-wide tagging conventions are followed.
  name                = "TerraFailNSG_outbound"
  location            = azurerm_resource_group.TerraFailNSG_rg.location
  resource_group_name = azurerm_resource_group.TerraFailNSG_rg.name

  security_rule {
    name                       = "TerraFailNSG_outbound_rule"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
