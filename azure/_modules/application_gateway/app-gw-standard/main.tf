

resource "azurerm_resource_group" "app_gateway_resource_group" {
  name     = "sac-app-gateway-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Application Gateway
# ---------------------------------------------------------------------
resource "azurerm_application_gateway" "sac_application_gateway" {
  name                = "sac-application-gateway"
  resource_group_name = azurerm_resource_group.app_gateway_resource_group.name
  location            = azurerm_resource_group.app_gateway_resource_group.location

  frontend_port {
    name = "redirect-port"
    port = 447
  }

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "sac-testing-gateway-config"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  backend_address_pool {
    name = "backend-address-pool"
  }

  request_routing_rule {
    name                       = "demo-test-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-1"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }

  frontend_ip_configuration {
    name = "frontend-ip-config"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 63
    protocol              = "http"
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
    protocol                       = "HTTP"
  }

  ssl_policy {
    policy_type = "Predefined"
    min_protocol_version = "TLSv1_1"
    policy_name = "AppGwSslPolicy20150501"
  }

  ssl_certificate {
    name = "demo-ssl-certificate"
  }
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_public_ip" "app_gateway_ip_config" {
  name                = "demo-app-gateway-ipconfig"
  resource_group_name = azurerm_resource_group.app_gateway_resource_group.name
  location            = azurerm_resource_group.app_gateway_resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["us-east-1", "us-west-1", "us-west-2"]
}

# ---------------------------------------------------------------------
# KeyVault
# ---------------------------------------------------------------------
resource "azurerm_key_vault" "app_gateway_vault" {
  name                        = "sac-app-gateway-vault"
  location                    = azurerm_resource_group.app_gateway_resource_group.location
  resource_group_name         = azurerm_resource_group.app_gateway_resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}
