

resource "azurerm_resource_group" "container_app_resource_group" {
  name     = "container-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# ContainerApp
# ---------------------------------------------------------------------
resource "azurerm_container_app" "sac_container_app" {
  name                         = "sac-testing-container-app"
  container_app_environment_id = azurerm_container_app_environment.sac_container_app_env.id
  resource_group_name          = azurerm_resource_group.container_app_resource_group.name
  revision_mode                = "Single"
  ingress {                           # SaC Testing - Severity: High - Set ingress to undefined
    allow_insecure_connections = false
    transport                  = "auto"
    target_port                = 6784
    external_enabled = true # SaC Testing - Severity: High - Set external_enabled to false
    traffic_weight {
      percentage = 100
    }
  }
  # identity {  # SaC Testing - Severity: Moderate - Set identity to undefined
  #   type = "SystemAssigned"
  # }
  template {
    container {
      name   = "sactestingcontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   environment = "Test"
  # }
}

resource "azurerm_container_app_environment" "sac_container_app_env" {
  name                       = "sac-testing-container-env"
  location                   = azurerm_resource_group.container_app_resource_group.location
  resource_group_name        = azurerm_resource_group.container_app_resource_group.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sac_container_app_workspace.id
}

resource "azurerm_log_analytics_workspace" "sac_container_app_workspace" {
  name                = "sac-testing-app-workspace"
  location            = azurerm_resource_group.container_app_resource_group.location
  resource_group_name = azurerm_resource_group.container_app_resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
