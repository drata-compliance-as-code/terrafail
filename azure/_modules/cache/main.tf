

resource "azurerm_resource_group" "TerraFailCache_rg" {
  name     = "TerraFailCache_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_virtual_network" "TerraFailCache_virtual_network" {
  name                = "TerraFailCache_virtual_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.TerraFailCache_rg.location
  resource_group_name = azurerm_resource_group.TerraFailCache_rg.name
}

resource "azurerm_subnet" "TerraFailCache_subnet" {
  name                 = "TerraFailCache_subnet"
  resource_group_name  = azurerm_resource_group.TerraFailCache_rg.name
  virtual_network_name = azurerm_virtual_network.TerraFailCache_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ---------------------------------------------------------------------
# Cache
# ---------------------------------------------------------------------
resource "azurerm_redis_cache" "TerraFailCache" {
  # Drata: Configure [azurerm_redis_cache.zones] to improve infrastructure availability and resilience
  # Drata: Set [azurerm_redis_cache.tags] to ensure that organization-wide tagging conventions are followed.
  name                          = "TerraFailCachee"
  location                      = azurerm_resource_group.TerraFailCache_rg.location
  resource_group_name           = azurerm_resource_group.TerraFailCache_rg.name
  capacity                      = 1
  family                        = "P"
  sku_name                      = "Premium"
  enable_non_ssl_port           = false
  minimum_tls_version           = "1.0"
  public_network_access_enabled = true

  redis_configuration {
    rdb_backup_enabled = false
  }
}

# ---------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------
resource "azurerm_storage_account" "TerraFailCache_storage" {
  # Drata: Set [azurerm_storage_account.tags] to ensure that organization-wide tagging conventions are followed.
  # Drata: Set [azurerm_storage_account.enable_https_traffic_only] to true to ensure secure protocols are being used to encrypt resource traffic
  name                          = "TerraFailCache_storage"
  resource_group_name           = azurerm_resource_group.TerraFailCache_rg.name
  location                      = azurerm_resource_group.TerraFailCache_rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  # Drata: Configure [azurerm_storage_account.account_replication_type] to improve infrastructure availability and resilience. To create highly available Storage Accounts, set azurerm_storage_account.account_replication_type to a geo-redundant storage option by selecting one of the following SKUs: ['standard_grs', 'standard_gzrs', 'standard_ragrs', 'standard_ragzrs', 'grs', 'gzrs', 'ragrs', 'ragzrs']
  public_network_access_enabled = false
}

resource "azurerm_redis_firewall_rule" "TerraFailCache_firewall_rule" {
  name                = "TerraFailCache_firewall_rule"
  redis_cache_name    = azurerm_redis_cache.TerraFailCache.name
  resource_group_name = azurerm_resource_group.TerraFailCache_rg.name
  start_ip            = "10.0.0.0"
  end_ip              = "192.168.0.0"
}
