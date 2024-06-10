

resource "azurerm_resource_group" "TerraFailNSG_rg" {
  name     = "TerraFailNSG_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_network_security_group" "TerraFailNSG" {
  # Drata: Set [azurerm_network_security_group.tags] to ensure that organization-wide tagging conventions are followed.
  # Drata: Ensure that [azurerm_network_security_group.security_rule.source_address_prefix] is explicitly defined and narrowly scoped to only allow traffic from trusted sources
  # Drata: Ensure that [azurerm_network_security_group.security_rule.destination_address_prefix] is explicitly defined and narrowly scoped to only allow traffic to trusted sources
  name                = "TerraFailNSG"
  location            = azurerm_resource_group.TerraFailNSG_rg.location
  resource_group_name = azurerm_resource_group.TerraFailNSG_rg.name
}

resource "azurerm_network_security_rule" "TerraFailNSG_inbound_rule" {
  name                        = "TerraFailNSG_inbound_rule"
  resource_group_name         = azurerm_resource_group.TerraFailNSG_rg.name
  network_security_group_name = azurerm_network_security_group.TerraFailNSG.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "TerraFailNSG_outbound_rule" {
  name                        = "TerraFailNSG_outbound_rule"
  resource_group_name         = azurerm_resource_group.TerraFailNSG_rg.name
  network_security_group_name = azurerm_network_security_group.TerraFailNSG.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

