resource "azurerm_resource_group" "TerraFailDNS_rg" {
  name     = "TerraFailDNS_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------
resource "azurerm_dns_zone" "TerraFailDNS" {
  # Drata: Set [azurerm_dns_zone.tags] to ensure that organization-wide tagging conventions are followed.
  name                = "thisisthedarkside.com"
  resource_group_name = azurerm_resource_group.TerraFailDNS_rg.name
}
