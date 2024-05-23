

resource "azurerm_resource_group" "cdn_resource_group" {
  name     = "cdn-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# CDN
# ---------------------------------------------------------------------
resource "azurerm_cdn_profile" "sac_cdn_profile" {
  name                = "sac-testing-cdn-profile"
  location            = azurerm_resource_group.cdn_resource_group.location
  resource_group_name = azurerm_resource_group.cdn_resource_group.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "sac_cdn_endpoint" {
  name                = "sac-testing-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.sac_cdn_profile.name
  location            = azurerm_resource_group.cdn_resource_group.location
  resource_group_name = azurerm_resource_group.cdn_resource_group.name
  is_http_allowed = true
  is_https_allowed = false

  origin {
    name      = "sac-test-origin"
    host_name = "thisisthedarkside.com"
  }
}