resource "azurerm_resource_group" "TerraFailIoTHub_rg" {
  name     = "TerraFailIoTHub_rg"
  location = "East US"
}

# ---------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------
resource "azurerm_iothub" "TerraFailIoTHub" {
  # Drata: Set [azurerm_iothub.tags] to ensure that organization-wide tagging conventions are followed.
  name                = "TerraFailIoTHub"
  resource_group_name = azurerm_resource_group.TerraFailIoTHub_rg.name
  location            = azurerm_resource_group.TerraFailIoTHub_rg.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  public_network_access_enabled = true
  min_tls_version               = 1.2

  network_rule_set {
    default_action = "Allow"
    ip_rule {
      name    = "wildcard"
      ip_mask = "0.0.0.0/0"
    }
  }
}
