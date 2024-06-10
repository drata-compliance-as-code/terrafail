

resource "azurerm_resource_group" "TerraFailCDN_rg" {
  name     = "TerraFailCDN_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# CDN
# ---------------------------------------------------------------------
resource "azurerm_cdn_profile" "TerraFailCDN_profile" {
  name                = "TerraFailCDN_profile"
  location            = azurerm_resource_group.TerraFailCDN_rg.location
  resource_group_name = azurerm_resource_group.TerraFailCDN_rg.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "TerraFailCDN_endpoint" {
  name                = "TerraFailCDN_endpoint"
  profile_name        = azurerm_cdn_profile.TerraFailCDN_profile.name
  location            = azurerm_resource_group.TerraFailCDN_rg.location
  resource_group_name = azurerm_resource_group.TerraFailCDN_rg.name
  is_http_allowed = true
  is_https_allowed = true

  origin {
    name      = "TerraFailCDN_endpoint_origin"
    host_name = "thisisthedarkside.com"
  }
}