

resource "azurerm_resource_group" "sac_nsg_resource_group" {
  name     = "sac-testing-nsg-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_network_security_group" "sac_network_security_group_inbound" {
  name                = "sac-testing-network-security-group-inbound"
  location            = azurerm_resource_group.sac_nsg_resource_group.location
  resource_group_name = azurerm_resource_group.sac_nsg_resource_group.name

  security_rule {
    name                       = "sac-testing-network-security-rule-inbound"
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

resource "azurerm_network_security_group" "sac_network_security_group_outbound" {
  name                = "sac-testing-network-security-group-outbound"
  location            = azurerm_resource_group.sac_nsg_resource_group.location
  resource_group_name = azurerm_resource_group.sac_nsg_resource_group.name

  security_rule {
    name                       = "sac-testing-network-security-rule-outbound"
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
