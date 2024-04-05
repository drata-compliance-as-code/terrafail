

resource "azurerm_resource_group" "sac_key_vault_group" {
  name     = "sac-key-vault-group"
  location = "East US 2"
}
# ---------------------------------------------------------------------
# KeyVault
# ---------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "sac_key_vault" {
  name                          = "sac-key-vault"
  location                      = azurerm_resource_group.sac_key_vault_group.location
  resource_group_name           = azurerm_resource_group.sac_key_vault_group.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard" # SaC Testing - Severity: Low - set sku_name != premium
  enable_rbac_authorization     = false      # SaC Testing - Severity: Critical - set enable_rbac_authorization to false
  soft_delete_retention_days    = 90         # SaC Testing - Severity: Low - set soft_delete_retention_days >= 30
  public_network_access_enabled = true       # SaC Testing - Severity: High - set public_network_access_enabled to true
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   key = "value"
  # }
}

resource "azurerm_key_vault_key" "sac_key_vault_key" {
  name         = "sac-key-vault-key"
  key_vault_id = azurerm_key_vault.sac_key_vault.id
  key_type     = "EC"
  #curve = "P-256"  # SaC Testing - Severity: High - Set curve to ""
  #expiration_date = "2006-01-02T15:04:05Z" # SaC Testing - Severity: Critical - Set exp to ""
  #not_before_date = "2006-01-02T15:04:05Z" # SaC Testing - Severity: High - Set nbf to ""
  key_opts = ["sign", "verify"]
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   "key" = "value"
  # }
}

resource "azurerm_key_vault_secret" "sac_key_vault_secret" {
  name         = "sac-key-vault-secret-szechuan"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.sac_key_vault.id
  #not_before_date = "2006-01-02T15:04:05Z" # SaC Testing - Severity: High - set not_before_date to ""
  #expiration_date = "2006-01-02T15:04:05Z" # SaC Testing - Severity: High - set expiration_date to ""
  #content_type = "test"  # SaC Testing - Severity: Low - set content_type to ""
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   "key" = "value"
  # }
}

resource "azurerm_key_vault_access_policy" "sac_key_vault_policy" { # SaC Testing - Severity: Critical - set access_policy to undefined
  key_vault_id            = azurerm_key_vault.sac_key_vault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = ""
  key_permissions         = ["Delete", "Purge", "Create", "Get", "Update"]                  # SaC Testing - Severity: Critical - Set key_permissions to bad_key_permissions
  secret_permissions      = ["Delete", "Purge", "Get", "Set", "List"]                       # SaC Testing - Severity: Critical - Set secret_permissions to bad_secrets_permissions
  certificate_permissions = ["Delete", "DeleteIssuers", "Purge", "Create", "Get", "Update"] # SaC Testing - Severity: Critical - Set certificate_permissions to bad_certificates_permissions
}
# ---------------------------------------------------------------------
# Role
# ---------------------------------------------------------------------
resource "azurerm_role_definition" "sac_keyvault_role" {
  name        = "sac-keyvault-create-key-secret-role"
  scope       = "/subscriptions/26e3ffed-afcb-4f7a-a34c-d7905542e0c4/resourceGroups/sac-key-vault-group"
  description = "This is a custom role created via Terraform"
  permissions {
    actions      = ["*"]
    data_actions = ["*"]
  }
}

resource "azurerm_role_assignment" "sac_keyvault_role_assignment" {
  name                 = "00482a5a-887f-4fb3-b363-3b7fe8e74483" # Azure UUID
  scope                = "/subscriptions/26e3ffed-afcb-4f7a-a34c-d7905542e0c4/resourceGroups/sac-key-vault-group"
  principal_id         = ""
  role_definition_name = "Owner"
}
