

resource "azurerm_resource_group" "cache_resource_group" {
  name     = "cache-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_virtual_network" "sac_cache_vnet" {
  name                = "sac-cache-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cache_resource_group.location
  resource_group_name = azurerm_resource_group.cache_resource_group.name
}

resource "azurerm_subnet" "sac_cache_subnet" {
  name                 = "sac-cache-subnet"
  resource_group_name  = azurerm_resource_group.cache_resource_group.name
  virtual_network_name = azurerm_virtual_network.sac_cache_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ---------------------------------------------------------------------
# Cache
# ---------------------------------------------------------------------
resource "azurerm_redis_cache" "sac_redis_cache" {
  name                          = "sac-cache"
  location                      = azurerm_resource_group.cache_resource_group.location
  resource_group_name           = azurerm_resource_group.cache_resource_group.name
  capacity                      = 1
  family                        = "P"
  sku_name                      = "Premium"
  enable_non_ssl_port           = true
  minimum_tls_version           = "1.0"
  public_network_access_enabled = true

  redis_configuration {
    rdb_backup_enabled = false
  }
}

# ---------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------
resource "azurerm_storage_account" "sac_cache_storage" {
  name                          = "saccachestorage"
  resource_group_name           = azurerm_resource_group.cache_resource_group.name
  location                      = azurerm_resource_group.cache_resource_group.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
}

resource "azurerm_redis_firewall_rule" "sac_cache_firewall" {
  name                = "saccachefirewall"
  redis_cache_name    = azurerm_redis_cache.sac_redis_cache.name
  resource_group_name = azurerm_resource_group.cache_resource_group.name
  start_ip            = "10.0.0.0"
  end_ip              = "192.168.0.0"
}
