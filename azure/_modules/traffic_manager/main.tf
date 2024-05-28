

resource "azurerm_resource_group" "TerraFailTrafficManager_rg" {
  name     = "TerraFailTrafficManager_rg"
  location = "East US"
}

# ---------------------------------------------------------------------
# Traffic Manager
# ---------------------------------------------------------------------
resource "azurerm_traffic_manager_profile" "TerraFailTrafficManager_profile" {
  name                   = "TerraFailTrafficManager_profile"
  resource_group_name    = azurerm_resource_group.TerraFailTrafficManager_rg.name
  traffic_routing_method = "Geographic"
  traffic_view_enabled   = true

  dns_config {
    relative_name = "traffic-manager-config"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
    expected_status_code_ranges  = ["100-101"]

    custom_header {
      name  = "custom-header"
      value = "header-value"
    }
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "TerraFailTrafficManager_endpoint" {
  name               = "TerraFailTrafficManager_endpoint"
  profile_id         = azurerm_traffic_manager_profile.TerraFailTrafficManager_profile.id
  target_resource_id = azurerm_public_ip.TerraFailTrafficManager_public_ip.id
  weight             = 100
  priority           = 1
  geo_mappings       = ["US-OH"]
  custom_header {
    name  = "custom-header"
    value = "header-value"
  }

  subnet {
    first = "10.0.0.0"
    last  = "10.0.0.255"
    scope = "24"
  }
}

resource "azurerm_traffic_manager_external_endpoint" "TerraFailTrafficManager_external_endpoint" {
  name              = "TerraFailTrafficManager_external_endpoint"
  profile_id        = azurerm_traffic_manager_profile.TerraFailTrafficManager_profile.id
  target            = "thisisthedarkside.com"
  weight            = 10
  priority          = 2
  geo_mappings      = ["US-ND"]
  endpoint_location = "East US"
  custom_header {
    name  = "custom-header"
    value = "header-value"
  }
  subnet {
    first = "10.0.1.0"
    last  = "10.0.1.255"
    scope = "24"
  }
}

resource "azurerm_traffic_manager_nested_endpoint" "TerraFailTrafficManager_nested_endpoint" {
  name                    = "TerraFailTrafficManager_nested_endpoint"
  target_resource_id      = azurerm_linux_web_app.TerraFailTrafficManager_web_app.id
  profile_id              = azurerm_traffic_manager_profile.TerraFailTrafficManager_profile.id
  minimum_child_endpoints = 9
  weight                  = 5
  priority                = 3
  geo_mappings            = ["US-SD"]
  endpoint_location       = "East US"
  custom_header {
    name  = "custom-header"
    value = "header-value"
  }
  subnet {
    first = "10.0.2.0"
    last  = "10.0.2.255"
    scope = "24"
  }
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_public_ip" "TerraFailTrafficManager_public_ip" {
  name                = "TerraFailTrafficManager_public_ip"
  location            = azurerm_resource_group.TerraFailTrafficManager_rg.location
  resource_group_name = azurerm_resource_group.TerraFailTrafficManager_rg.name
  allocation_method   = "Static"
  domain_name_label   = "TerraFailTrafficManager_public_ip"
}

# ---------------------------------------------------------------------
# Service Plan
# ---------------------------------------------------------------------
resource "azurerm_service_plan" "TerraFailTrafficManager_service_plan" {
  name                = "TerraFailTrafficManager_service_plan"
  resource_group_name = azurerm_resource_group.TerraFailTrafficManager_rg.name
  location            = azurerm_resource_group.TerraFailTrafficManager_rg.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# ---------------------------------------------------------------------
# Web App
# ---------------------------------------------------------------------
resource "azurerm_linux_web_app" "TerraFailTrafficManager_web_app" {
  name                = "TerraFailTrafficManager_web_app"
  resource_group_name = azurerm_resource_group.TerraFailTrafficManager_rg.name
  location            = azurerm_service_plan.TerraFailTrafficManager_service_plan.location
  service_plan_id     = azurerm_service_plan.TerraFailTrafficManager_service_plan.id

  site_config {}
}
