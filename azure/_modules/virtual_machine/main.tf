

resource "azurerm_resource_group" "TerraFailVM_rg" {
  name     = "TerraFailVM_rg"
  location = "East US"
}

# ---------------------------------------------------------------------
# Virtual Machine
# ---------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "TerraFailVM_linux" {
  name                            = "TerraFailVM_linux"
  resource_group_name             = azurerm_resource_group.TerraFailVM_rg.name
  location                        = azurerm_resource_group.TerraFailVM_rg.location
  size                            = "Standard_A1_v2"
  admin_username                  = "adminuser"
  admin_password                  = "$uper$ecretP@$$w0rd"
  secure_boot_enabled             = false
  disable_password_authentication = false


  network_interface_ids = [
    azurerm_network_interface.TerraFailVM_linux_network_interface.id,
  ]
  encryption_at_host_enabled = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "TerraFailVM_windows" {
  name                = "TerraFailVM_windows"
  resource_group_name = azurerm_resource_group.TerraFailVM_rg.name
  location            = azurerm_resource_group.TerraFailVM_rg.location
  size                = "Standard_DS2_v2"
  admin_username      = "adminuser"
  admin_password      = "$uper$ecretP@$$w0rd"
  secure_boot_enabled = false

  network_interface_ids = [
    azurerm_network_interface.TerraFailVM_windows_network_interface.id,
  ]
  encryption_at_host_enabled = false

  winrm_listener {
    protocol = "Http"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_virtual_network" "TerraFailVM_virtual_network" {
  name                = "TerraFailVM_virtual_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.TerraFailVM_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVM_rg.name
}

resource "azurerm_subnet" "TerraFailVM_subnet" {
  name                 = "TerraFailVM_subnet"
  resource_group_name  = azurerm_resource_group.TerraFailVM_rg.name
  virtual_network_name = azurerm_virtual_network.TerraFailVM_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "TerraFailVM_linux_network_interface" {
  name                = "TerraFailVM_linux_network_interface"
  location            = azurerm_resource_group.TerraFailVM_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVM_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.TerraFailVM_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "TerraFailVM_windows_network_interface" {
  name                = "TerraFailVM_windows_network_interface"
  location            = azurerm_resource_group.TerraFailVM_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVM_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.TerraFailVM_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "TerraFailVM_availability_set" {
  name                = "TerraFailVM_availability_set"
  location            = azurerm_resource_group.TerraFailVM_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVM_rg.name

  tags = {
    environment = "Production"
  }
}

# ---------------------------------------------------------------------
# KeyVault
# ---------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "TerraFailVM_vault" {
  name                        = "TerraFailVM_vault"
  location                    = azurerm_resource_group.TerraFailVM_rg.location
  resource_group_name         = azurerm_resource_group.TerraFailVM_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_key" "TerraFailVM_vault_key" {
  name         = "TerraFailVM_vault_key"
  key_vault_id = azurerm_key_vault.TerraFailVM_vault.id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [
    azurerm_key_vault_access_policy.TerraFailVM_vault_user_access_policy
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_key_vault_access_policy" "TerraFailVM_vault_disk_access_policy" {
  key_vault_id = azurerm_key_vault.TerraFailVM_vault.id

  tenant_id = azurerm_disk_encryption_set.TerraFailVM_disk_encryption_set.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.TerraFailVM_disk_encryption_set.identity.0.principal_id

  key_permissions = [
    # Drata: Explicitly define permissionss for [azurerm_key_vault_access_policy.key_permissions] in adherence with the principal of least privilege. Avoid the use of overly permissive allow-all access patterns such as ([all, delete, purge])
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "WrapKey",
    "UnwrapKey"
  ]
}

resource "azurerm_key_vault_access_policy" "TerraFailVM_vault_user_access_policy" {
  key_vault_id = azurerm_key_vault.TerraFailVM_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "GetRotationPolicy",
  ]
}

resource "azurerm_disk_encryption_set" "TerraFailVM_disk_encryption_set" {
  name                = "TerraFailVM_disk_encryption_set"
  resource_group_name = azurerm_resource_group.TerraFailVM_rg.name
  location            = azurerm_resource_group.TerraFailVM_rg.location
  key_vault_key_id    = azurerm_key_vault_key.TerraFailVM_vault_key.id

  identity {
    type = "SystemAssigned"
  }
}

# ---------------------------------------------------------------------
# Role
# ---------------------------------------------------------------------
resource "azurerm_role_assignment" "TerraFailVM_role" {
  scope                = azurerm_key_vault.TerraFailVM_vault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.TerraFailVM_disk_encryption_set.identity.0.principal_id
}
