

resource "azurerm_resource_group" "TerraFailAPI_rg" {
  name     = "TerraFailAPI_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# ApiManagement
# ---------------------------------------------------------------------
resource "azurerm_api_management" "TerraFailAPI" {
  name                          = "TerraFailAPI"
  location                      = azurerm_resource_group.TerraFailAPI_rg.location
  resource_group_name           = azurerm_resource_group.TerraFailAPI_rg.name
  publisher_name                = "TerraFailAPI"
  publisher_email               = "TerraFailAPI@fail.io"
  sku_name                      = "Premium_1"
  client_certificate_enabled    = false
  min_api_version               = "2014-02-14"
  public_network_access_enabled = false

  virtual_network_configuration {
    subnet_id = azurerm_subnet.TerraFailAPI_subnet.id
  }
}

resource "azurerm_api_management_api" "TerraFailAPI_api" {
  name                = "TerraFailAPI_api"
  resource_group_name = azurerm_resource_group.TerraFailAPI_rg.name
  api_management_name = azurerm_api_management.TerraFailAPI.name
  revision            = "1"
  display_name        = "TerraFailAPI_api"
  protocols           = ["http"]
}

resource "azurerm_api_management_backend" "TerraFailAPI_backend" {
  name                = "TerraFailAPI_backend"
  resource_group_name = azurerm_resource_group.TerraFailAPI_rg.name
  api_management_name = azurerm_api_management.TerraFailAPI.name
  protocol            = "http"
  url                 = "https://conferenceapi.azurewebsites.net?format=json"

  tls {
    validate_certificate_chain = false
    validate_certificate_name  = false
  }
}

resource "azurerm_api_management_named_value" "TerraFailAPI_named_value" {
  name                = "TerraFailAPI_named_value"
  resource_group_name = azurerm_resource_group.TerraFailAPI_rg.name
  api_management_name = azurerm_api_management.TerraFailAPI.name
  display_name        = "TerraFailAPI_named_value"
  secret              = true
  value               = "sensitivestring"
  tags                = ["sandbox"]
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_subnet" "TerraFailAPI_subnet" {
  name                 = "TerraFailAPI_subnet"
  resource_group_name  = azurerm_resource_group.TerraFailAPI_rg.name
  virtual_network_name = azurerm_virtual_network.TerraFailAPI_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "TerraFailAPI_virtual_network" {
  name                = "TerraFailAPI_virtual_network"
  location            = azurerm_resource_group.TerraFailAPI_rg.location
  resource_group_name = azurerm_resource_group.TerraFailAPI_rg.name
  address_space       = ["10.0.0.0/16"]
}
