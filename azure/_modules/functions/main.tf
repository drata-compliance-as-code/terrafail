

resource "azurerm_resource_group" "sac_function_resource_group" {
  name     = "sac-testing-function-resource-group"
  location = "East US 2"
}


# ---------------------------------------------------------------------
# Function
# ---------------------------------------------------------------------
resource "azurerm_linux_function_app" "sac_linux_function_app" {
  name                          = "sac-linux-function-app"
  resource_group_name           = azurerm_resource_group.sac_function_resource_group.name
  location                      = azurerm_resource_group.sac_function_resource_group.location
  storage_account_name          = azurerm_storage_account.sac_linux_storage_account.name
  storage_uses_managed_identity = true
  service_plan_id               = azurerm_service_plan.sac_function_service_plan.id
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

resource "azurerm_windows_function_app" "sac_windows_function_app" {
  name                          = "sac-windows-function-app"
  resource_group_name           = azurerm_resource_group.sac_function_resource_group.name
  location                      = azurerm_resource_group.sac_function_resource_group.location
  storage_account_name          = azurerm_storage_account.sac_windows_storage_account.name
  storage_uses_managed_identity = true
  service_plan_id               = azurerm_service_plan.sac_function_service_plan.id
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
resource "azurerm_service_plan" "sac_function_service_plan" {
  name                = "sac-function-service-plan"
  resource_group_name = azurerm_resource_group.sac_function_resource_group.name
  location            = azurerm_resource_group.sac_function_resource_group.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_storage_account" "sac_linux_storage_account" {
  name                     = "sacfunctionstorage"
  resource_group_name      = azurerm_resource_group.sac_function_resource_group.name
  location                 = azurerm_resource_group.sac_function_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.sac_storage_account_identity.id]
  }
}
resource "azurerm_storage_account" "sac_windows_storage_account" {
  name                     = "sacfunctions2torage"
  resource_group_name      = azurerm_resource_group.sac_function_resource_group.name
  location                 = azurerm_resource_group.sac_function_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.sac_storage_account_identity.id]
  }
}

# ---------------------------------------------------------------------
# Managed Identity
# ---------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "sac_storage_account_identity" {
  location            = azurerm_resource_group.sac_function_resource_group.location
  name                = "sac-storage-account-id"
  resource_group_name = azurerm_resource_group.sac_function_resource_group.name
}
