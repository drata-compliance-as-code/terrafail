

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
  public_network_access_enabled     = true
  ip_range_filter                   = "0.0.0.0,203.0.113.0/16"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = "East US 2"
    failover_priority = 0
  }

  cors_rule {
    allowed_methods    = ["GET", "DELETE"]
    allowed_origins    = ["*"]
    allowed_headers    = ["*"]
    exposed_headers    = ["*"]
    max_age_in_seconds = 100
  }
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

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_subnet" "sac_dynamodb_subnet" {
  name                 = "sac-testing-cosmos-subnet"
  resource_group_name  = azurerm_resource_group.cosmos_db_resource_group.name
  virtual_network_name = azurerm_virtual_network.sac_cosmos_db_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.AzureCosmosDB"]
}

resource "azurerm_virtual_network" "sac_cosmos_db_virtual_network" {
  name                = "sac-testing-cosmos-virtual-network"
  location            = azurerm_resource_group.cosmos_db_resource_group.location
  resource_group_name = azurerm_resource_group.cosmos_db_resource_group.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_storage_account" "sac_cosmos_storage" {
  name                     = "tfendpint"
  location                 = azurerm_resource_group.cosmos_db_resource_group.location
  resource_group_name      = azurerm_resource_group.cosmos_db_resource_group.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.sac_dynamodb_subnet.id]
  }
}
