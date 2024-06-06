resource "azurerm_resource_group" "TerraFailDNS_rg" {
  name     = "TerraFailDNS_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------
resource "azurerm_private_dns_zone" "TerraFailDNS" {
  name                = "thisisthedarkside.com"
  resource_group_name = azurerm_resource_group.TerraFailDNS_rg.name
}
