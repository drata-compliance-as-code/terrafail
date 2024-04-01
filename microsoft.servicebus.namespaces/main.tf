resource "azurerm_resource_group" "sac_servicebus" {
  name     = "sac-servicebus"
  location = "East US"
}

# ---------------------------------------------------------------------
# Service Bus
# ---------------------------------------------------------------------
resource "azurerm_servicebus_namespace" "sac_servicebus" {
  name                = "sac-servicebus-namespace"
  location            = azurerm_resource_group.sac_servicebus.location
  resource_group_name = azurerm_resource_group.sac_servicebus.name
  sku                 = "Premium"

  zone_redundant = false    # SaC Testing - Serverity: Moderate - Set zone_redundant != true
  minimum_tls_version = "1.0"   # SaC Testing - Serverity: Critical - Set minimum_tls_version != 1.2

  tags = {
    source = "terraform"
  }
}