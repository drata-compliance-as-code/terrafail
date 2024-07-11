

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
  account_tier             = "Standard_v2"
  account_replication_type = "GRS"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.TerraFailFunction_user_identity.id]
  }
}
resource "azurerm_storage_account" "TerraFailFunction_storage_windows" {
  name                     = "TerraFailFunction_storage_windows"
  resource_group_name      = azurerm_resource_group.TerraFailFunction_rg.name
  location                 = azurerm_resource_group.TerraFailFunction_rg.location
  account_tier             = "Standard_v2"
  account_replication_type = "LRS"

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
