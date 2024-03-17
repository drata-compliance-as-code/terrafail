
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
  zone_redundant                      = false # SaC Testing - Severity: High - Set zone_redundant == false
  transparent_data_encryption_enabled = false # SaC Testing - Severity: Critical - Set transparent_data_encryption == false
  sku_name                            = "DW100c"
  auto_pause_delay_in_minutes         = 1
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   environment = "production"
  # }
}

resource "azurerm_mssql_database_extended_auditing_policy" "mssql_database_auditing_policy" { # SaC Testing - Severity: Critical - set auditing policy to undefined
  database_id = azurerm_mssql_database.sac_mssql_database.id
  enabled     = false # SaC Testing - Severity: Moderate - Set enabled to false
  #storage_endpoint = azurerm_storage_account.example.primary_blob_endpoint # SaC Testing - Severity: Moderate - set storage_endpoint to undefined
  #log_monitoring_enabled = true  # SaC Testing - Severity: Critical - Set log_monitoring_enabled  == false
  retention_in_days = 10 # SaC Testing - Severity: Moderate - Set retention_in_days to < 90
}

resource "azurerm_mssql_server" "mssql_database_server" {
  name                          = "sac-testing-mssql-server"
  resource_group_name           = azurerm_resource_group.mssql_database_resource_group.name
  location                      = azurerm_resource_group.mssql_database_resource_group.location
  version                       = "12.0"
  administrator_login           = "msuch-oak9"
  administrator_login_password  = "$uPer$ecure$ecret!234"
  minimum_tls_version           = "1.1" # SaC Testing - Severity: Critical - Set minimum_tls_version != 1.2
  public_network_access_enabled = true  # SaC Testing - Severity: High - Set public_network_access_enabled to true
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   environment = "production"
  # }
}
