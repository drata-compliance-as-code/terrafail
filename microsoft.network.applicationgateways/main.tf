

# ---------------------------------------------------------------------
# Application Gateway
# ---------------------------------------------------------------------
resource "azurerm_application_gateway" "sac_application_gateway_standardv2_predefined" {
  name                = "sac-application-gateway"
  resource_group_name = azurerm_resource_group.app_gateway_resource_group.name
  location            = azurerm_resource_group.app_gateway_resource_group.location
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_gateway_identity.id]
  }
  #zones = ["2"]  # SaC Testing - Severity: Moderate - Set zones to undefined
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
  autoscale_configuration { # SaC Testing - Severity: Moderate - Set autoscale_configuration to undefined
    min_capacity = 1        # SaC Testing - Severity: Moderate - Set min_capacity < 2
    max_capacity = 25
  }
  frontend_ip_configuration {
    name = "frontend-ip-config"
    #public_ip_address_id = azurerm_public_ip.app_gateway_ip_config.id  # SaC Testing - Severity: - Set public_ip_address_id to undefined
  }
  gateway_ip_configuration {
    name      = "sac-testing-gateway-config"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }
  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 63
    protocol              = "Http" # SaC Testing - Severity: Critical - Set protocol != Https
    request_timeout       = 20000
    connection_draining {
      enabled           = false # SaC Testing - Severity: Moderate - Set enabled to false
      drain_timeout_sec = 2000
    }
  }
  http_listener {
    name                           = "http-listener-1"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "redirect-port"
    protocol                       = "Http" # SaC Testing - Severity: Critical - Set protocol != https
  }
  ssl_policy {
    min_protocol_version = "TLSv1_1" # SaC Testing - Severity: Critical - Set min_protocol_version != tlsv1.2
    #disabled_protocols = ["TLSv1_0", "TLSv1_1"]  # SaC Testing - Severity: Critical - Set disabled_protocols != [TLSv1_0, TLSv1_1]
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
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags ={
  #   key = "value"
  # }
}
