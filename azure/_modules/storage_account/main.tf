

resource "azurerm_resource_group" "TerraFailStorage_rg" {
  name     = "TerraFailStorage_rg"
  location = "East US"
}

# ---------------------------------------------------------------------
# Storage Account
# ---------------------------------------------------------------------
resource "azurerm_storage_account" "TerraFailStorage" {
  name                              = "TerraFailStorage"
  resource_group_name               = azurerm_resource_group.TerraFailStorage_resource_group.name
  location                          = azurerm_resource_group.TerraFailStorage_resource_group.location
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  public_network_access_enabled     = true
  account_replication_type          = "ZRS"
  infrastructure_encryption_enabled = false
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_0"

  network_rules {
    default_action = "Allow"
    ip_rules       = ["100.0.0.1"]
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.TerraFailStorage_user_identity.id]
  }

  share_properties {
    cors_rule {
      allowed_methods    = ["DELETE", "MERGE", "POST"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      allowed_headers    = ["*"]
      max_age_in_seconds = 100
    }
  }

  queue_properties {
    cors_rule {
      allowed_methods    = ["DELETE", "MERGE", "POST"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      allowed_headers    = ["*"]
      max_age_in_seconds = 100
    }
  }

  blob_properties {
    cors_rule {
      allowed_methods    = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      allowed_headers    = ["*"]
      max_age_in_seconds = 100
    }
  }
}

data "azurerm_client_config" "current" {
}

# ---------------------------------------------------------------------
# Managed Identity
# ---------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "TerraFailStorage_user_identity" {
  location            = azurerm_resource_group.TerraFailStorage_resource_group.location
  name                = "TerraFailStorage_user_identity"
  resource_group_name = azurerm_resource_group.TerraFailStorage_resource_group.name
}
