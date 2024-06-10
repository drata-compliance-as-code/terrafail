

resource "azurerm_resource_group" "TerraFailFunction_rg" {
  name     = "TerraFailFunction_rg"
  location = "East US 2"
}


# ---------------------------------------------------------------------
# Function
# ---------------------------------------------------------------------
resource "azurerm_linux_function_app" "TerraFailFunction_linux" {
  name                          = "TerraFailFunction_linux"
  resource_group_name           = azurerm_resource_group.TerraFailFunction_rg.name
  location                      = azurerm_resource_group.TerraFailFunction_rg.location
  storage_account_name          = azurerm_storage_account.TerraFailFunction_storage_linux.name
  storage_uses_managed_identity = true
  service_plan_id               = azurerm_service_plan.TerraFailFunction_service_plan.id
  client_certificate_enabled    = false
  client_certificate_mode       = "Optional"

  site_config {
    cors {
      allowed_origins = ["*"]
    }
    minimum_tls_version      = "1.0"
    remote_debugging_enabled = true

    ip_restriction {
      action     = "Allow"
      ip_address = "0.0.0.0/0"
    }
  }
}

resource "azurerm_windows_function_app" "TerraFailFunction_windows" {
  name                          = "TerraFailFunction_windows"
  resource_group_name           = azurerm_resource_group.TerraFailFunction_rg.name
  location                      = azurerm_resource_group.TerraFailFunction_rg.location
  storage_account_name          = azurerm_storage_account.TerraFailFunction_storage_windows.name
  storage_uses_managed_identity = true
  service_plan_id               = azurerm_service_plan.TerraFailFunction_service_plan.id
  client_certificate_enabled    = false
  client_certificate_mode       = "Optional"

  site_config {
    cors {
      allowed_origins = ["*"]
    }
    minimum_tls_version      = "1.0"
    remote_debugging_enabled = true

    ip_restriction {
      action     = "Allow"
      ip_address = "0.0.0.0/0"
    }
  }
}

# ---------------------------------------------------------------------
# Account
# ---------------------------------------------------------------------
resource "azurerm_service_plan" "TerraFailFunction_service_plan" {
  name                = "TerraFailFunction_service_plan"
  resource_group_name = azurerm_resource_group.TerraFailFunction_rg.name
  location            = azurerm_resource_group.TerraFailFunction_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_storage_account" "TerraFailFunction_storage_linux" {
  name                     = "TerraFailFunction_storage_linux"
  resource_group_name      = azurerm_resource_group.TerraFailFunction_rg.name
  location                 = azurerm_resource_group.TerraFailFunction_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  # Drata: Configure [azurerm_storage_account.account_replication_type] to improve infrastructure availability and resilience. To create highly available Storage Accounts, set azurerm_storage_account.account_replication_type to a geo-redundant storage option by selecting one of the following SKUs: ['standard_grs', 'standard_gzrs', 'standard_ragrs', 'standard_ragzrs', 'grs', 'gzrs', 'ragrs', 'ragzrs']

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.TerraFailFunction_user_identity.id]
  }
}
resource "azurerm_storage_account" "TerraFailFunction_storage_windows" {
  # Drata: Set [azurerm_storage_account.tags] to ensure that organization-wide tagging conventions are followed.
  # Drata: Set [azurerm_storage_account.public_network_access_enabled] to false to prevent unintended public access. Ensure that only trusted users and IP addresses are explicitly allowed access, if a publicly accessible service is required for your business use case this finding can be excluded
  # Drata: Set [azurerm_storage_account.enable_https_traffic_only] to true to ensure secure protocols are being used to encrypt resource traffic
  name                     = "TerraFailFunction_storage_windows"
  resource_group_name      = azurerm_resource_group.TerraFailFunction_rg.name
  location                 = azurerm_resource_group.TerraFailFunction_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  # Drata: Configure [azurerm_storage_account.account_replication_type] to improve infrastructure availability and resilience. To create highly available Storage Accounts, set azurerm_storage_account.account_replication_type to a geo-redundant storage option by selecting one of the following SKUs: ['standard_grs', 'standard_gzrs', 'standard_ragrs', 'standard_ragzrs', 'grs', 'gzrs', 'ragrs', 'ragzrs']

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.TerraFailFunction_user_identity.id]
  }
}

# ---------------------------------------------------------------------
# Managed Identity
# ---------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "TerraFailFunction_user_identity" {
  location            = azurerm_resource_group.TerraFailFunction_rg.location
  name                = "TerraFailFunction_user_identity"
  resource_group_name = azurerm_resource_group.TerraFailFunction_rg.name
}
