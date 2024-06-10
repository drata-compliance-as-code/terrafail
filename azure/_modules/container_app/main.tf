

resource "azurerm_resource_group" "TerraFailContainerApp_rg" {
  name     = "TerraFailContainerApp_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# ContainerApp
# ---------------------------------------------------------------------
resource "azurerm_container_app" "TerraFailContainerApp" {
  name                         = "TerraFailContainerApp"
  container_app_environment_id = azurerm_container_app_environment.TerraFailContainerApp_environment.id
  resource_group_name          = azurerm_resource_group.TerraFailContainerApp_rg.name
  revision_mode                = "Single"

  ingress {
    allow_insecure_connections = false
    transport                  = "auto"
    target_port                = 6784

    traffic_weight {
      percentage = 100
    }
  }

  template {
    container {
      name   = "TerraFailContainerApp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}

resource "azurerm_container_app_environment" "TerraFailContainerApp_environment" {
  name                       = "TerraFailContainerApp_environment"
  location                   = azurerm_resource_group.TerraFailContainerApp_rg.location
  resource_group_name        = azurerm_resource_group.TerraFailContainerApp_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.TerraFailContainerApp_workspace.id
}

resource "azurerm_log_analytics_workspace" "TerraFailContainerApp_workspace" {
  name                = "TerraFailContainerApp_workspace"
  location            = azurerm_resource_group.TerraFailContainerApp_rg.location
  resource_group_name = azurerm_resource_group.TerraFailContainerApp_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
