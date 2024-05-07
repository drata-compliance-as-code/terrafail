resource "azurerm_resource_group" "iothub_rg" {
  name     = "iothub_rg"
  location = "East US"
}

# ---------------------------------------------------------------------
# Device
# ---------------------------------------------------------------------
resource "azurerm_iothub" "sac_iothub" {
  name                = "sac-testing-iothub"
  resource_group_name = azurerm_resource_group.iothub_rg.name
  location            = azurerm_resource_group.iothub_rg.location
  sku {
    name     = "S1"
    capacity = "1"
  }
  public_network_access_enabled = true # SaC Testing - Severity: Critical - Set public_network_access_enabled to true
  min_tls_version               = 1.2
  network_rule_set {
    default_action = "Allow"
    ip_rule { # SaC Testing - Severity: High - Set ip_rule to undefined
      name    = "wildcard"
      ip_mask = "0.0.0.0/0" # SaC Testing - Severity: Moderate - Set ip_mask to blacklisted IP
    }
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   purpose = "testing"
  # }
}
