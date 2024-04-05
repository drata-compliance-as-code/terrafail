
resource "azurerm_resource_group" "sac_storage_account_resource_group" {
  name     = "sac-storage-account-resource-group"
  location = "East US"
}
# ---------------------------------------------------------------------
# Storage Account
# ---------------------------------------------------------------------
resource "azurerm_storage_account" "sac_storage_account" {
  name                              = "sactestingstorageaccount"
  resource_group_name               = azurerm_resource_group.sac_storage_account_resource_group.name
  location                          = azurerm_resource_group.sac_storage_account_resource_group.location
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  public_network_access_enabled     = true     # SaC Testing - Severity: High - Set public_network_access_enabled to true
  account_replication_type          = "ZRS"    # SaC Testing - Severity: Moderate - Set account_replication_type
  infrastructure_encryption_enabled = false    # SaC Testing - Severity: Low - Set infrastructure_encryption_enabled to false
  enable_https_traffic_only         = false    # SaC Testing - Severity: Critical - Set enable_https_traffic_only to false
  min_tls_version                   = "TLS1_2"
  # customer_managed_key {  # SaC Testing - Severity: Moderate - Set customer_managed_key to undefined
  #   key_vault_key_id = azurerm_key_vault_key.sac_storage_key_vault_key.id
  #   user_assigned_identity_id = azurerm_user_assigned_identity.sac_storage_account_identity.id
  # }
  network_rules {
    default_action = "Allow" # SaC Testing - Severity: High - Set default_action != "Deny"
    ip_rules       = ["100.0.0.1"]
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.sac_storage_account_identity.id]
  }
  share_properties {
    cors_rule {
      allowed_methods    = ["DELETE", "MERGE", "POST"] # SaC Testing - Severity: High - Set allowed_methods != ['GET','PUT','POST']
      allowed_origins    = ["*"]                       # SaC Testing - Severity: Critical - Set allowed_origins != ['*']
      exposed_headers    = ["*"]
      allowed_headers    = ["*"]
      max_age_in_seconds = 100
    }
  }
  queue_properties {
    cors_rule {
      allowed_methods    = ["DELETE", "MERGE", "POST"] # SaC Testing - Severity: High - Set allowed_methods != ['GET','PUT','POST']
      allowed_origins    = ["*"]                       # SaC Testing - Severity: Critical - Set allowed_origins != ['*']
      exposed_headers    = ["*"]
      allowed_headers    = ["*"]
      max_age_in_seconds = 100
    }
  }
  blob_properties {
    cors_rule {
      allowed_methods    = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"] # SaC Testing - Severity: High - Set allowed_methods != ['GET','PUT','POST']
      allowed_origins    = ["*"]                                                                 # SaC Testing - Severity: Critical - Set allowed_origins != ['*']
      exposed_headers    = ["*"]
      allowed_headers    = ["*"]
      max_age_in_seconds = 100
    }
  }
  # SaC Testing - Moderate: High - Set tags to undefined
  # tags = {
  #   name = "storage-accounts"
  # }
}

data "azurerm_client_config" "current" {}
