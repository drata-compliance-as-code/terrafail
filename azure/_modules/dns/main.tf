resource "azurerm_resource_group" "dns_zone_rg" {
  name     = "dns-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------
resource "azurerm_dns_zone" "sac_dns_zone" {
  name                = "thisisthedarkside.com"
  resource_group_name = azurerm_resource_group.dns_zone_rg.name
}
