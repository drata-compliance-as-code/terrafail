

resource "azurerm_resource_group" "cosmos_db_resource_group" {
  name     = "cosmos-db-rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# CosmosDB
# ---------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "sac_cosmosdb_account" {
  name                              = "sac-testing-cosmosdb"
  resource_group_name               = azurerm_resource_group.cosmos_db_resource_group.name
  location                          = azurerm_resource_group.cosmos_db_resource_group.location
  kind                              = "GlobalDocumentDB"
  offer_type                        = "Standard"
  is_virtual_network_filter_enabled = true
  enable_automatic_failover         = false
  analytical_storage_enabled        = true
  public_network_access_enabled     = false
  #ip_range_filter = "0.0.0.0,203.0.113.0/16"  # SaC Testing - Severity: High - Set ip_range_filter to undefined
  #   virtual_network_rule {  # SaC Testing - Severity: High - Set virtual_network_rule to undefined
  #     id = azurerm_subnet.sac_dynamodb_subnet.id
  #   }
  consistency_policy {
    consistency_level = "Strong"
  }
  geo_location {
    location          = "East US 2"
    failover_priority = 0
  }
  #key_vault_key_id = azurerm_key_vault_key.sac_cosmosdb_key_vault_key.versionless_id # SaC Testing - Severity: Moderate - Set key_vault_key_id to undefined
  cors_rule {
    allowed_methods    = ["GET", "DELETE"] # SaC Testing - Severity: High - Set allowed_methods != ['get','put','post']
    allowed_origins    = ["*"]             # SaC Testing - Severity: Critical - Set allowed_origins to *
    allowed_headers    = ["*"]
    exposed_headers    = ["*"]
    max_age_in_seconds = 100
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  #   tags = {
  #     key = "value"
  #   }
}

resource "azurerm_cosmosdb_sql_database" "cosmos_db_sql_db" {
  name                = "cosmos-db-sql"
  resource_group_name = azurerm_resource_group.cosmos_db_resource_group.name
  account_name        = azurerm_cosmosdb_account.sac_cosmosdb_account.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "cosmos_db_sql_container" {
  name                   = "cosmos-db-sqlcont"
  resource_group_name    = azurerm_resource_group.cosmos_db_resource_group.name
  account_name           = azurerm_cosmosdb_account.sac_cosmosdb_account.name
  database_name          = azurerm_cosmosdb_sql_database.cosmos_db_sql_db.name
  partition_key_path     = "/definition/id"
  partition_key_version  = 1
  throughput             = 400
  analytical_storage_ttl = -1

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }
  unique_key {
    paths = ["/definition/idlong", "/definition/idshort"]
  }
}
