

resource "azurerm_resource_group" "TerraFailAppGateway_rg" {
  name     = "TerraFailAppGateway_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Application Gateway
# ---------------------------------------------------------------------
resource "azurerm_application_gateway" "TerraFailAppGateway" {
  name                = "TerraFailAppGateway"
  resource_group_name = azurerm_resource_group.TerraFailAppGateway_rg.name
  location            = azurerm_resource_group.TerraFailAppGateway_rg.location

  frontend_port {
    name = "redirect-port"
    port = 447
  }

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "TerraFailAppGateway_ip_configuration"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  backend_address_pool {
    name = "TerraFailAppGateway_backend_pool"
  }

  request_routing_rule {
    name                       = "TerraFailAppGateway_request_routing_rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-1"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }

  frontend_ip_configuration {
    name = "TerraFailAppGateway_frontend_ip_config"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 63
    protocol              = "Https"
    request_timeout       = 0

    connection_draining {
      enabled           = false
      drain_timeout_sec = 4000
    }
  }

  http_listener {
    name                           = "http-listener-1"
    frontend_ip_configuration_name = "ip_config_1"
    frontend_port_name             = "front_end_port_1"
    protocol                       = "Http"
  }

  ssl_policy {
    policy_type          = "Predefined"
    min_protocol_version = "TLSv1_1"
    policy_name          = "AppGwSslPolicy20150501"
  }

  ssl_certificate {
    name = "TerraFailAppGateway_ssl_cert"
  }
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_public_ip" "TerraFailAppGateway_ip_config" {
  name                = "TerraFailAppGateway_ip_config"
  resource_group_name = azurerm_resource_group.TerraFailAppGateway_rg.name
  location            = azurerm_resource_group.TerraFailAppGateway_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["us-east-1", "us-west-1", "us-west-2"]
}

# ---------------------------------------------------------------------
# KeyVault
# ---------------------------------------------------------------------
resource "azurerm_key_vault" "TerraFailAppGateway_vault" {
  name                        = "TerraFailAppGateway_vault"
  location                    = azurerm_resource_group.TerraFailAppGateway_rg.location
  resource_group_name         = azurerm_resource_group.TerraFailAppGateway_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
  public_network_access_enabled = true

  sku_name = "standard"
}
