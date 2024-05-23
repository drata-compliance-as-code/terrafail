

resource "azurerm_resource_group" "sac_vm_group" {
  name     = "sac-vm-group-0"
  location = "East US"
}

# ---------------------------------------------------------------------
# Virtual Machine
# ---------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "sac_linux_vm" {
  name                            = "sac-testing-linux-vm"
  resource_group_name             = azurerm_resource_group.sac_vm_group.name
  location                        = azurerm_resource_group.sac_vm_group.location
  size                            = "Standard_A1_v2"
  admin_username                  = "adminuser"
  admin_password                  = "$uper$ecretP@$$w0rd"
  secure_boot_enabled             = false
  disable_password_authentication = false


  network_interface_ids = [
    azurerm_network_interface.sac_vm_network_interface.id,
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

resource "azurerm_windows_virtual_machine" "sac_windows_vm" {
  name                = "sac-windows-vm"
  resource_group_name = azurerm_resource_group.sac_vm_group.name
  location            = azurerm_resource_group.sac_vm_group.location
  size                = "Standard_DS2_v2"
  admin_username      = "adminuser"
  admin_password      = "$uper$ecretP@$$w0rd"
  secure_boot_enabled = false

  network_interface_ids = [
    azurerm_network_interface.sac_windows_network_interface.id,
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
resource "azurerm_virtual_network" "sac_vm_virtual_network" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sac_vm_group.location
  resource_group_name = azurerm_resource_group.sac_vm_group.name
}

resource "azurerm_subnet" "sac_vm_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.sac_vm_group.name
  virtual_network_name = azurerm_virtual_network.sac_vm_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "sac_vm_network_interface" {
  name                = "vm-nic"
  location            = azurerm_resource_group.sac_vm_group.location
  resource_group_name = azurerm_resource_group.sac_vm_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sac_vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "sac_windows_network_interface" {
  name                = "windows-nic"
  location            = azurerm_resource_group.sac_vm_group.location
  resource_group_name = azurerm_resource_group.sac_vm_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sac_vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "sac_vm_availability_set" {
  name                = "sac-testing-aset"
  location            = azurerm_resource_group.sac_vm_group.location
  resource_group_name = azurerm_resource_group.sac_vm_group.name

  tags = {
    environment = "Production"
  }
}

# ---------------------------------------------------------------------
# KeyVault
# ---------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "sac_vm_keyvault" {
  name                        = "sac-vm-vault-insecure"
  location                    = azurerm_resource_group.sac_vm_group.location
  resource_group_name         = azurerm_resource_group.sac_vm_group.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_key" "sac_vm_keyvault_key" {
  name         = "sac-vm-key-1"
  key_vault_id = azurerm_key_vault.sac_vm_keyvault.id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [
    azurerm_key_vault_access_policy.user
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

resource "azurerm_key_vault_access_policy" "disk" {
  key_vault_id = azurerm_key_vault.sac_vm_keyvault.id

  tenant_id = azurerm_disk_encryption_set.sac_vm_disk_encryption_set.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.sac_vm_disk_encryption_set.identity.0.principal_id

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
    "WrapKey",
    "UnwrapKey"
  ]
}

resource "azurerm_key_vault_access_policy" "user" {
  key_vault_id = azurerm_key_vault.sac_vm_keyvault.id

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

resource "azurerm_disk_encryption_set" "sac_vm_disk_encryption_set" {
  name                = "des"
  resource_group_name = azurerm_resource_group.sac_vm_group.name
  location            = azurerm_resource_group.sac_vm_group.location
  key_vault_key_id    = azurerm_key_vault_key.sac_vm_keyvault_key.id

  identity {
    type = "SystemAssigned"
  }
}

# ---------------------------------------------------------------------
# Role
# ---------------------------------------------------------------------
resource "azurerm_role_assignment" "example-disk" {
  scope                = azurerm_key_vault.sac_vm_keyvault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.sac_vm_disk_encryption_set.identity.0.principal_id
}
