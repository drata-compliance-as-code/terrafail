

resource "azurerm_resource_group" "mssql_database_resource_group" {
  name     = "example-resources"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# SQL Database
# ---------------------------------------------------------------------
resource "azurerm_mssql_database" "sac_mssql_database" {
  name                                = "sac-mssql-database"
  server_id                           = azurerm_mssql_server.mssql_database_server.id
  zone_redundant                      = false
  transparent_data_encryption_enabled = false
  sku_name                            = "DW100c"
  auto_pause_delay_in_minutes         = 1
}


resource "azurerm_mssql_database_extended_auditing_policy" "mssql_database_auditing_policy" {
  database_id       = azurerm_mssql_database.sac_mssql_database.id
  enabled           = false
  retention_in_days = 10
}

resource "azurerm_mssql_server" "mssql_database_server" {
  name                          = "sac-testing-mssql-server"
  resource_group_name           = azurerm_resource_group.mssql_database_resource_group.name
  location                      = azurerm_resource_group.mssql_database_resource_group.location
  version                       = "12.0"
  administrator_login           = "msuch-oak9"
  administrator_login_password  = "$uPer$ecure$ecret!234"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  tags = {
    environment = "production"
  }
}
