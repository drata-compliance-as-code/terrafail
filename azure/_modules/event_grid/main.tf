resource "azurerm_resource_group" "event_grid_rg" {
  name     = "event-grid-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Event Grid
# ---------------------------------------------------------------------
resource "azurerm_eventgrid_domain" "sac_eventgrid_domain" {
  name                = "sac-eventgrid-domain"
  location            = azurerm_resource_group.event_grid_rg.location
  resource_group_name = azurerm_resource_group.event_grid_rg.name
}

resource "azurerm_eventgrid_topic" "sac_eventgrid_topic" {
  name                = "sac-eventgrid-topic"
  location            = azurerm_resource_group.event_grid_rg.location
  resource_group_name = azurerm_resource_group.event_grid_rg.name
}