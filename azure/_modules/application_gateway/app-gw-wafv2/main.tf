

resource "azurerm_resource_group" "app_gateway_resource_group" {
  name     = "sac-app-gateway-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Application Gateway
# ---------------------------------------------------------------------
resource "azurerm_application_gateway" "sac_application_gateway_wafv2" {
  name                = "sac-application-gateway"
  resource_group_name = azurerm_resource_group.app_gateway_resource_group.name
  location            = azurerm_resource_group.app_gateway_resource_group.location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_gateway_identity.id]
  }

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 25
  }

  waf_configuration {
    enabled                  = false
    file_upload_limit_mb     = 200
    request_body_check       = false
    max_request_body_size_kb = 10
    firewall_mode            = "Detection"
    rule_set_version         = "3.0"
  }

  frontend_ip_configuration {
    name = "frontend-ip-config"
  }

  gateway_ip_configuration {
    name      = "sac-testing-gateway-config"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 63
    protocol              = "Http"
    request_timeout       = 20000

    connection_draining {
      enabled           = false
      drain_timeout_sec = 2000
    }
  }

  http_listener {
    name                           = "http-listener-1"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "redirect-port"
    protocol                       = "Http"
  }

  ssl_policy {
    min_protocol_version = "TLSv1_1"
  }

  frontend_port {
    name = "redirect-port"
    port = 447
  }

  request_routing_rule {
    name                       = "demo-test-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-1"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }

  backend_address_pool {
    name = "backend-address-pool"
  }
}

# ---------------------------------------------------------------------
# Managed Identity
# ---------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "app_gateway_identity" {
  location            = azurerm_resource_group.app_gateway_resource_group.location
  name                = "sac-app-gw-identity"
  resource_group_name = azurerm_resource_group.app_gateway_resource_group.name
}

data "azurerm_client_config" "current" {
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "sac-app-gateway-subnet"
  resource_group_name  = azurerm_resource_group.app_gateway_resource_group.name
  virtual_network_name = azurerm_virtual_network.app_gateway_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "app_gateway_virtual_network" {
  name                = "sac-app-gw-virtual-network"
  location            = azurerm_resource_group.app_gateway_resource_group.location
  resource_group_name = azurerm_resource_group.app_gateway_resource_group.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "app_gateway_ip_config" {
  name                = "demo-app-gateway-ipconfig"
  resource_group_name = azurerm_resource_group.app_gateway_resource_group.name
  location            = azurerm_resource_group.app_gateway_resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"]
}
