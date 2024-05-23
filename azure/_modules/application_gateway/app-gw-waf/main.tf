

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

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 1
  }

  waf_configuration {
    enabled                  = true
    file_upload_limit_mb     = 0
    request_body_check       = false
    max_request_body_size_kb = 0
    firewall_mode            = "DETECTION"
    rule_set_version         = "0.1"

  }

  frontend_port {
    name = "redirect-port"
    port = 447
  }

  frontend_port {
    name = "http-port"
    port = 447
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.app_gateway_ip_config.id
  }

  backend_address_pool {
    name         = "backend-address-pool"
    ip_addresses = [azurerm_public_ip.app_gateway_ip_config.id]
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

  http_listener {
    name                           = "http-listener-2"
    frontend_ip_configuration_name = "ip_config_2"
    frontend_port_name             = "front_end_port_2"
    protocol                       = "HTTP"
  }
  gateway_ip_configuration {
    name      = "sac-testing-gateway-config"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  request_routing_rule {
    name                       = "demo-test-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-1"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 0
  }

  probe {
    name                                      = "demo-test-probe"
    interval                                  = 0
    protocol                                  = "http"
    pick_host_name_from_backend_http_settings = false
    unhealthy_threshold                       = 2
    timeout                                   = 100
    path                                      = "/*"
  }

  ssl_policy {
    policy_type          = "Custom"
    cipher_suites        = ["TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA"]
    min_protocol_version = "TLSv1_1"
  }

  ssl_certificate {
    name                = "demo-ssl-certificate"
    key_vault_secret_id = ""
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
