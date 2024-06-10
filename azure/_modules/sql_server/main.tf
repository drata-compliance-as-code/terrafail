

resource "azurerm_resource_group" "TerraFailSQL_rg" {
  name     = "TerraFailSQL_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# SQL Server
# ---------------------------------------------------------------------
resource "azurerm_mssql_server" "TerraFailSQL_server" {
  name                          = "TerraFailSQL_server"
  resource_group_name           = azurerm_resource_group.TerraFailSQL_rg.name
  location                      = azurerm_resource_group.TerraFailSQL_rg.location
  version                       = "12.0"
  administrator_login           = "TerraFailSQLadmin"
  administrator_login_password  = "$uPer$ecure$ecret!234"
  minimum_tls_version           = "1.1"
  public_network_access_enabled = true
}

resource "azurerm_mssql_elasticpool" "TerraFailSQL_elasticpool" {
  name                = "TerraFailSQL_elasticpool"
  resource_group_name = azurerm_resource_group.TerraFailSQL_rg.name
  location            = azurerm_resource_group.TerraFailSQL_rg.location
  server_name         = azurerm_mssql_server.TerraFailSQL_server.name
  max_size_gb         = 10
  zone_redundant      = true

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

resource "azurerm_mssql_server_extended_auditing_policy" "TerraFailSQL_server_auditing_policy" {
  server_id         = azurerm_mssql_server.TerraFailSQL_server.id
  enabled           = true
  retention_in_days = 365
}

resource "azurerm_mssql_server_transparent_data_encryption" "TerraFailSQL_server_tde" {
  server_id = azurerm_mssql_server.TerraFailSQL_server.id
}

resource "azurerm_mssql_server_vulnerability_assessment" "TerraFailSQL_server_vulnerability_assessment" {
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
