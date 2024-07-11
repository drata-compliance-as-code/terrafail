

resource "azurerm_resource_group" "TerraFailKeyVault_rg" {
  name     = "TerraFailKeyVault_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# KeyVault
# ---------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "TerraFailKeyVault" {
  name                          = "TerraFailKeyVault"
  location                      = azurerm_resource_group.TerraFailKeyVault_rg.location
  resource_group_name           = azurerm_resource_group.TerraFailKeyVault_rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = false
  soft_delete_retention_days    = 90
  public_network_access_enabled = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

resource "azurerm_key_vault_key" "TerraFailKeyVault_key" {
  name         = "TerraFailKeyVault_key"
  key_vault_id = azurerm_key_vault.TerraFailKeyVault.id
  key_type     = "EC"
  key_opts     = ["sign", "verify"]
  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
  }
}

resource "azurerm_key_vault_secret" "TerraFailKeyVault_secret" {
  name         = "TerraFailKeyVault_secret"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.TerraFailKeyVault.id
}

resource "azurerm_key_vault_access_policy" "TerraFailKeyVault_policy" {
  key_vault_id            = azurerm_key_vault.TerraFailKeyVault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = ""
  key_permissions         = ["Create", "Get", "Update"]
  secret_permissions      = ["Delete", "Purge", "Get", "Set", "List"]
  certificate_permissions = ["Delete", "DeleteIssuers", "Purge", "Create", "Get", "Update"]
}

# ---------------------------------------------------------------------
# Role
# ---------------------------------------------------------------------
resource "azurerm_role_definition" "TerraFailKeyVault_role" {
  name        = "TerraFailKeyVault_role"
  scope       = "/subscriptions/subscription_id/resourceGroups/TerraFailKeyVault_rg" # KeyVault Resource Group
  description = "This is a custom role created via Terraform"

  permissions {
    actions      = ["*"]
    data_actions = ["*"]
  }
}

resource "azurerm_role_assignment" "TerraFailKeyVault_role_assignment" {
  name                 = "TerraFailKeyVault_role_assignment"
  scope                = "/subscriptions/subscription_id/resourceGroups/TerraFailKeyVault_rg"
  principal_id         = ""
  role_definition_name = "Owner"
}
