

resource "azurerm_resource_group" "sac_nsg_resource_group" {
  name     = "sac-testing-nsg-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_network_security_group" "sac_network_security_group" {
  # Drata: Ensure that [azurerm_network_security_group.security_rule.destination_address_prefix] is explicitly defined and narrowly scoped to only allow traffic to trusted sources
  name                = "sac-testing-network-security-group"
  location            = azurerm_resource_group.sac_nsg_resource_group.location
  resource_group_name = azurerm_resource_group.sac_nsg_resource_group.name
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   environment = "Production"
  # }
}

resource "azurerm_network_security_rule" "sac_network_security_rule_inbound" {
  name                        = "sac-testing-network-security-rule-inbound"
  resource_group_name         = azurerm_resource_group.sac_nsg_resource_group.name
  network_security_group_name = azurerm_network_security_group.sac_network_security_group.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*" # SaC Testing - Severity: Moderate - Set source_address_prefix to non-preferred value
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "sac_network_security_rule_outbound" {
  name                        = "sac-testing-network-security-rule-outbound"
  resource_group_name         = azurerm_resource_group.sac_nsg_resource_group.name
  network_security_group_name = azurerm_network_security_group.sac_network_security_group.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*" # SaC Testing - Severity: Moderate - Set destination_address_prefix to non-preferred value
}
