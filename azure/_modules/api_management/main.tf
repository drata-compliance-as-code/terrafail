

resource "azurerm_resource_group" "apim_resource_group" {
  name     = "apim-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# ApiManagement
# ---------------------------------------------------------------------
resource "azurerm_api_management" "sac_api_management" {
  name                          = "sac-testing-api-management"
  location                      = azurerm_resource_group.apim_resource_group.location
  resource_group_name           = azurerm_resource_group.apim_resource_group.name
  publisher_name                = "My Company"
  publisher_email               = "company@terraform.io"
  sku_name                      = "Premium_1"
  client_certificate_enabled    = false
  min_api_version               = "2014-02-14"
  public_network_access_enabled = false

  virtual_network_configuration {
    subnet_id = azurerm_subnet.sac_apim_subnet.id
  }
}

resource "azurerm_api_management_api" "sac_api_management_api" {
  name                = "sac-testing-apim-api"
  resource_group_name = azurerm_resource_group.apim_resource_group.name
  api_management_name = azurerm_api_management.sac_api_management.name
  revision            = "1"
  display_name        = "ac-testing-apim-api"
  protocols           = ["http"]
}

resource "azurerm_api_management_backend" "sac_api_management_backend" {
  name                = "sac-testing-apim-backend"
  resource_group_name = azurerm_resource_group.apim_resource_group.name
  api_management_name = azurerm_api_management.sac_api_management.name
  protocol            = "http"
  url                 = "https://conferenceapi.azurewebsites.net?format=json"

  tls {
    validate_certificate_chain = false
    validate_certificate_name  = false
  }
}

resource "azurerm_api_management_named_value" "sac_api_management_named_val" {
  name                = "sac-testing-apim-named-value"
  resource_group_name = azurerm_resource_group.apim_resource_group.name
  api_management_name = azurerm_api_management.sac_api_management.name
  display_name        = "ExampleProperty"
  secret              = true
  value               = "Example Value"
  tags                = ["test-tag"]
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_subnet" "sac_apim_subnet" {
  name                 = "sac-testing-apim-subnet"
  resource_group_name  = azurerm_resource_group.apim_resource_group.name
  virtual_network_name = azurerm_virtual_network.sac_apim_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "sac_apim_virtual_network" {
  name                = "sac-testing-apim-virtual-network"
  location            = azurerm_resource_group.apim_resource_group.location
  resource_group_name = azurerm_resource_group.apim_resource_group.name
  address_space       = ["10.0.0.0/16"]
}
