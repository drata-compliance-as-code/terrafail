

resource "azurerm_resource_group" "cache_resource_group" {
  name     = "cache-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Cache
# ---------------------------------------------------------------------
resource "azurerm_redis_cache" "sac_redis_cache" {
  name                = "sac-cache"
  location            = azurerm_resource_group.cache_resource_group.location
  resource_group_name = azurerm_resource_group.cache_resource_group.name
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = true  # SaC Testing - Severity: Critical/High - set enable_non_ssl_port to true
  minimum_tls_version = "1.0" # SaC Testing - Severity: Critical - set minimum_tls_version to 1.0 or 1.1 
  # replicas_per_master       = 2 # SaC Testing - Severity: Moderate - set replicas_per_master to undefined
  # zones = ["2"] # SaC Testing - Severity: Moderate - set zones to undefined
  public_network_access_enabled = true
  # subnet_id = azurerm_subnet.sac_cache_subnet.id  # SaC Testing - Severity: Moderate - set subnet_id to undefined
  # patch_schedule  { # SaC Testing - Severity: Low - set patch_schedule to undefined
  #   maintenance_window = "PT5H"
  #   start_hour_utc = 4
  #   day_of_week = "SUNDAY"
  # }
  redis_configuration {
    rdb_backup_enabled            = false # SaC Testing - Severity: Low - Backup set to false
    rdb_backup_frequency          = 60
    rdb_backup_max_snapshot_count = 1
    rdb_storage_connection_string = "DefaultEndpointsProtocol=https;BlobEndpoint=${azurerm_storage_account.sac_cache_storage.primary_blob_endpoint};AccountName=${azurerm_storage_account.sac_cache_storage.name};AccountKey=${azurerm_storage_account.sac_cache_storage.primary_access_key}"
  }
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   Environment = "test"
  # }

}
