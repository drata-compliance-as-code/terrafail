

resource "azurerm_resource_group" "TerraFailSQL_rg" {
  name     = "TerraFailSQL_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# SQL Database
# ---------------------------------------------------------------------
resource "azurerm_mssql_database" "TerraFailSQL_database" {
  name                                = "TerraFailSQL_database"
  server_id                           = azurerm_mssql_server.TerraFailSQL_server.id
  zone_redundant                      = false
  transparent_data_encryption_enabled = false
  sku_name                            = "DW100c"
  auto_pause_delay_in_minutes         = 1
}


resource "azurerm_mssql_database_extended_auditing_policy" "TerraFailSQL_database_auditing_policy" {
  database_id       = azurerm_mssql_database.TerraFailSQL_database.id
  enabled           = true
  retention_in_days = 365
}

resource "azurerm_mssql_server" "TerraFailSQL_server" {
  name                          = "TerraFailSQL_server"
  resource_group_name           = azurerm_resource_group.TerraFailSQL_rg.name
  location                      = azurerm_resource_group.TerraFailSQL_rg.location
  version                       = "12.0"
  administrator_login           = "TerraFailSQLadmin"
  administrator_login_password  = "$uPer$ecure$ecret!234"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  tags = {
    environment = "production"
  }
}
