

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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.TerraFailAppGateway_user_identity.id]
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
    name      = "TerraFailAppGateway_ip_config"
    subnet_id = azurerm_subnet.TerraFailAppGateway_subnet.id
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
    name                       = "TerraFailAppGateway_routing_rule"
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
resource "azurerm_user_assigned_identity" "TerraFailAppGateway_user_identity" {
  location            = azurerm_resource_group.TerraFailAppGateway_rg.location
  name                = "TerraFailAppGateway_user_identity"
  resource_group_name = azurerm_resource_group.TerraFailAppGateway_rg.name
}

data "azurerm_client_config" "current" {
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_subnet" "TerraFailAppGateway_subnet" {
  name                 = "TerraFailAppGateway_subnet"
  resource_group_name  = azurerm_resource_group.TerraFailAppGateway_rg.name
  virtual_network_name = azurerm_virtual_network.TerraFailAppGateway_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "TerraFailAppGateway_virtual_network" {
  name                = "TerraFailAppGateway_virtual_network"
  location            = azurerm_resource_group.TerraFailAppGateway_rg.location
  resource_group_name = azurerm_resource_group.TerraFailAppGateway_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "TerraFailAppGateway_ip_config" {
  name                = "TerraFailAppGateway_ip_config"
  resource_group_name = azurerm_resource_group.TerraFailAppGateway_rg.name
  location            = azurerm_resource_group.TerraFailAppGateway_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"]
}
