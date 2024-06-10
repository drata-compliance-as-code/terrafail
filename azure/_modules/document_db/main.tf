

resource "azurerm_resource_group" "TerraFailCosmosDB_rg" {
  name     = "TerraFailCosmosDB_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# CosmosDB
# ---------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "TerraFailCosmosDB_account" {
  name                              = "TerraFailCosmosDB_account"
  resource_group_name               = azurerm_resource_group.TerraFailCosmosDB_rg.name
  location                          = azurerm_resource_group.TerraFailCosmosDB_rg.location
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

resource "azurerm_cosmosdb_sql_database" "TerraFailCosmosDB" {
  name                = "TerraFailCosmosDB"
  resource_group_name = azurerm_resource_group.TerraFailCosmosDB_rg.name
  account_name        = azurerm_cosmosdb_account.TerraFailCosmosDB_account.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "TerraFailCosmosDB_container" {
  name                   = "TerraFailCosmosDB_container"
  resource_group_name    = azurerm_resource_group.TerraFailCosmosDB_rg.name
  account_name           = azurerm_cosmosdb_account.TerraFailCosmosDB_account.name
  database_name          = azurerm_cosmosdb_sql_database.TerraFailCosmosDB.name
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
resource "azurerm_subnet" "TerraFailCosmosDB_subnet" {
  name                 = "TerraFailCosmosDB_subnet"
  resource_group_name  = azurerm_resource_group.TerraFailCosmosDB_rg.name
  virtual_network_name = azurerm_virtual_network.TerraFailCosmosDB_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.AzureCosmosDB"]
}

resource "azurerm_virtual_network" "TerraFailCosmosDB_virtual_network" {
  # Drata: Set [azurerm_virtual_network.tags] to ensure that organization-wide tagging conventions are followed.
  name                = "TerraFailCosmosDB_virtual_network"
  location            = azurerm_resource_group.TerraFailCosmosDB_rg.location
  resource_group_name = azurerm_resource_group.TerraFailCosmosDB_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_storage_account" "TerraFailCosmosDB_storage" {
  # Drata: Set [azurerm_storage_account.enable_https_traffic_only] to true to ensure secure protocols are being used to encrypt resource traffic
  name                     = "TerraFailCosmosDB_storage"
  location                 = azurerm_resource_group.TerraFailCosmosDB_rg.location
  resource_group_name      = azurerm_resource_group.TerraFailCosmosDB_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  # Drata: Configure [azurerm_storage_account.account_replication_type] to improve infrastructure availability and resilience. To create highly available Storage Accounts, set azurerm_storage_account.account_replication_type to a geo-redundant storage option by selecting one of the following SKUs: ['standard_grs', 'standard_gzrs', 'standard_ragrs', 'standard_ragzrs', 'grs', 'gzrs', 'ragrs', 'ragzrs']

  tags = {
    environment = "staging"
  }
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.TerraFailCosmosDB_subnet.id]
  }
}
