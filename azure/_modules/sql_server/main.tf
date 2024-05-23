

resource "azurerm_resource_group" "server_resource_group" {
  name     = "sql-server-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# SQL Server
# ---------------------------------------------------------------------
resource "azurerm_mssql_server" "sac_mssql_server" {
  name                          = "sac-testing-mssql-server"
  resource_group_name           = azurerm_resource_group.server_resource_group.name
  location                      = azurerm_resource_group.server_resource_group.location
  version                       = "12.0"
  administrator_login           = "msuch-oak9"
  administrator_login_password  = "$uPer$ecure$ecret!234"
  minimum_tls_version           = "1.1"
  public_network_access_enabled = true
}

resource "azurerm_mssql_elasticpool" "elasticpool" {
  name                = "test-epool"
  resource_group_name = azurerm_resource_group.server_resource_group.name
  location            = azurerm_resource_group.server_resource_group.location
  server_name         = azurerm_mssql_server.sac_mssql_server.name
  max_size_gb         = 10
  zone_redundant      = false

  tags = {
    key = "value"
  }

  sku {
    name     = "BC_Gen5"
    tier     = "BusinessCritical"
    family   = "Gen5"
    capacity = 4
  }

  per_database_settings {
    min_capacity = 0
    max_capacity = 4
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "sac_mssql_server_auditing_policy" {
  server_id         = azurerm_mssql_server.sac_mssql_server.id
  enabled           = false
  retention_in_days = 20
}

resource "azurerm_mssql_server_transparent_data_encryption" "data-encryption" {
  server_id = azurerm_mssql_server.sac_mssql_server.id
}

resource "azurerm_mssql_server_vulnerability_assessment" "vulnerability-assess" {
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.example.id
  storage_container_path          = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.example.name}/"
  storage_account_access_key      = azurerm_storage_account.example.primary_access_key
  storage_container_sas_key       = ""

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails = [
      "email@example1.com",
      "email@example2.com"
    ]
  }
}
