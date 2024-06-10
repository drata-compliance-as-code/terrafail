resource "azurerm_resource_group" "TerraFailEventGrid_rg" {
  name     = "TerraFailEventGrid_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Event Grid
# ---------------------------------------------------------------------
resource "azurerm_eventgrid_domain" "TerraFailEventGrid_domain" {
  # Drata: Set [azurerm_eventgrid_domain.tags] to ensure that organization-wide tagging conventions are followed.
  name                = "TerraFailEventGrid_domain"
  location            = azurerm_resource_group.TerraFailEventGrid_rg.location
  resource_group_name = azurerm_resource_group.TerraFailEventGrid_rg.name
}

resource "azurerm_eventgrid_topic" "TerraFailEventGrid_topic" {
  name                = "TerraFailEventGrid_topic"
  location            = azurerm_resource_group.TerraFailEventGrid_rg.location
  resource_group_name = azurerm_resource_group.TerraFailEventGrid_rg.name
}
