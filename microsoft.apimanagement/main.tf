

resource "azurerm_resource_group" "apim_resource_group" {
  name     = "apim-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# ApiManagement
# ---------------------------------------------------------------------
resource "azurerm_api_management" "sac_api_management" {
  name                       = "sac-testing-api-management"
  location                   = azurerm_resource_group.apim_resource_group.location
  resource_group_name        = azurerm_resource_group.apim_resource_group.name
  publisher_name             = "My Company"
  publisher_email            = "company@terraform.io"
  sku_name                   = "Premium_1"
  client_certificate_enabled = false # SaC Testing - Severity: High - Set client_certificate_enabled to false
  #min_api_version = "2014-02-14" # SaC Testing - Severity: Moderate - Set min_api_version to undefined
  #zones = ["East US 2"] # SaC Testing - Severity: Low - Set zones to undefined
  public_network_access_enabled = false # SaC Testing - Severity: Moderate - Set public_network_access_enabled to undefined
  #virtual_network_type = "Internal"  # SaC Testing - Severity: Moderate - Set virtual_network_type to undefined
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   key = "value"
  # }
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
  protocols           = ["http"] # SaC Testing - Severity: Critical - Set protocols to "http"
}

resource "azurerm_api_management_backend" "sac_api_management_backend" {
  name                = "sac-testing-apim-backend"
  resource_group_name = azurerm_resource_group.apim_resource_group.name
  api_management_name = azurerm_api_management.sac_api_management.name
  protocol            = "http"
  url                 = "https://conferenceapi.azurewebsites.net?format=json"
  # credentials { # SaC Testing - Severity: High - Set credentials to undefined
  #   header = {
  #     key = "value"
  #   }
  # }
  tls {
    validate_certificate_chain = false # SaC Testing - Severity: High - Set validate_certificate_chain to false
    validate_certificate_name  = false # SaC Testing - Severity: High - Set validate_certificate_name to false
  }
}

resource "azurerm_api_management_named_value" "sac_api_management_named_val" {
  name                = "sac-testing-apim-named-value"
  resource_group_name = azurerm_resource_group.apim_resource_group.name
  api_management_name = azurerm_api_management.sac_api_management.name
  display_name        = "ExampleProperty"
  secret              = true
  value               = "Example Value" # SaC Testing - Severity: Low - set value instead of value_from_key_vault
  tags                = ["test-tag"]
  # value_from_key_vault {  # SaC Testing - Severity: Low - Set value_from_key_vault to undefined
  #   secret_id = ""  
  #   identity_client_id = ""   
  # }
}
