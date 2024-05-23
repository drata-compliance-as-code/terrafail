

resource "azurerm_resource_group" "sac_traffic_manager_group" {
  name     = "sac-traffic-resource-group"
  location = "East US"
}

# ---------------------------------------------------------------------
# Traffic Manager
# ---------------------------------------------------------------------
resource "azurerm_traffic_manager_profile" "sac_traffic_manager_profiles" {
  name                   = "sac-testing-traffic-manager"
  resource_group_name    = azurerm_resource_group.sac_traffic_manager_group.name
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

resource "azurerm_traffic_manager_azure_endpoint" "azure_endpoint" {
  name               = "sac-azure-endpoint"
  profile_id         = azurerm_traffic_manager_profile.sac_traffic_manager_profiles.id
  target_resource_id = azurerm_public_ip.traffic_manager_ip.id
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

resource "azurerm_traffic_manager_external_endpoint" "external_endpoint" {
  name              = "sac-external-endpoint"
  profile_id        = azurerm_traffic_manager_profile.sac_traffic_manager_profiles.id
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

resource "azurerm_traffic_manager_nested_endpoint" "nested_endpoint" {
  name                    = "sac-nested-endpoint"
  target_resource_id      = azurerm_linux_web_app.app_service.id
  profile_id              = azurerm_traffic_manager_profile.sac_traffic_manager_profiles.id
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
resource "azurerm_public_ip" "traffic_manager_ip" {
  name                = "sac-traffic-manager-public-ip"
  location            = azurerm_resource_group.sac_traffic_manager_group.location
  resource_group_name = azurerm_resource_group.sac_traffic_manager_group.name
  allocation_method   = "Static"
  domain_name_label   = "sac-traffic-manager-public-ip"
}

# ---------------------------------------------------------------------
# Service Plan
# ---------------------------------------------------------------------
resource "azurerm_service_plan" "nested_plan" {
  name                = "sac-app-service-plan"
  resource_group_name = azurerm_resource_group.sac_traffic_manager_group.name
  location            = azurerm_resource_group.sac_traffic_manager_group.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# ---------------------------------------------------------------------
# Web App
# ---------------------------------------------------------------------
resource "azurerm_linux_web_app" "app_service" {
  name                = "sac-nested-app-service"
  resource_group_name = azurerm_resource_group.sac_traffic_manager_group.name
  location            = azurerm_service_plan.nested_plan.location
  service_plan_id     = azurerm_service_plan.nested_plan.id

  site_config {}
}
