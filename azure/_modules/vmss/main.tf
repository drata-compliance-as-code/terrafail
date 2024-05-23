resource "azurerm_resource_group" "vmss_resource_group" {
  name     = "vmss-resource-group"
  location = "East US"
}

# ---------------------------------------------------------------------
# Virtual Machine Scale Set
# ---------------------------------------------------------------------
resource "azurerm_linux_virtual_machine_scale_set" "sac_linux_vmss" {
  name                            = "sac-linux"
  resource_group_name             = azurerm_resource_group.vmss_resource_group.name
  location                        = azurerm_resource_group.vmss_resource_group.location
  sku                             = "Standard_A1_v2"
  instances                       = 1
  admin_username                  = "adminuser"
  disable_password_authentication = false
  admin_password                  = "P@55w0rd1234!"
  encryption_at_host_enabled      = false
  upgrade_mode                    = "Automatic"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  automatic_instance_repair {
    enabled = false
  }

  automatic_os_upgrade_policy {
    enable_automatic_os_upgrade = false
    disable_automatic_rollback  = true
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  data_disk {
    caching              = "None"
    disk_size_gb         = 3
    lun                  = 20
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "example"
    primary = true
    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
    }
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "sac_windows_vmss" {
  name                       = "sac-windo"
  resource_group_name        = azurerm_resource_group.vmss_resource_group.name
  location                   = azurerm_resource_group.vmss_resource_group.location
  sku                        = "Standard_A1_v2"
  instances                  = 1
  admin_username             = "adminuser"
  admin_password             = "P@55w0rd1234!"
  encryption_at_host_enabled = false
  upgrade_mode               = "Automatic"

  automatic_instance_repair {
    enabled = false
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  enable_automatic_updates = false

  automatic_os_upgrade_policy {
    enable_automatic_os_upgrade = false
    disable_automatic_rollback  = false
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  data_disk {
    caching              = "None"
    disk_size_gb         = 3
    lun                  = 20
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
    }
  }

  winrm_listener {
    protocol = "Http"
  }
}

# ---------------------------------------------------------------------
# LoadBalancer
# ---------------------------------------------------------------------
resource "azurerm_lb" "vmss_lb" {
  name                = "vmss-lb"
  location            = azurerm_resource_group.vmss_resource_group.location
  resource_group_name = azurerm_resource_group.vmss_resource_group.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name      = "PublicIPAddress"
    zones     = ["2"]
    subnet_id = azurerm_subnet.vmss_subnet.id
  }
}

resource "azurerm_lb_probe" "vmss_lb_probe" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "health-check-probe"
  port            = 80
}

resource "azurerm_public_ip" "vmss_public_ip" {
  name                = "vmss-public-ip"
  location            = azurerm_resource_group.vmss_resource_group.location
  resource_group_name = azurerm_resource_group.vmss_resource_group.name
  allocation_method   = "Static"
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "lbnatrule" {
  name                           = "vmss-lb-rule"
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.vmss_lb_probe.id
}

# ---------------------------------------------------------------------
# KeyVault
# ---------------------------------------------------------------------
resource "azurerm_disk_encryption_set" "sac_vmss_disk_encryption_set" {
  name                = "des"
  resource_group_name = azurerm_resource_group.vmss_resource_group.name
  location            = azurerm_resource_group.vmss_resource_group.location
  key_vault_key_id    = azurerm_key_vault_key.sac_vmss_keyvault_key.id

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "sac_vmss_keyvault" {
  name                        = "sac-vmss-vault"
  location                    = azurerm_resource_group.vmss_resource_group.location
  resource_group_name         = azurerm_resource_group.vmss_resource_group.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_key" "sac_vmss_keyvault_key" {
  name         = "sac-vmss-key"
  key_vault_id = azurerm_key_vault.sac_vmss_keyvault.id
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
  key_vault_id = azurerm_key_vault.sac_vmss_keyvault.id

  tenant_id = azurerm_disk_encryption_set.sac_vmss_disk_encryption_set.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.sac_vmss_disk_encryption_set.identity.0.principal_id

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
  key_vault_id = azurerm_key_vault.sac_vmss_keyvault.id

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

# ---------------------------------------------------------------------
# Role
# ---------------------------------------------------------------------
resource "azurerm_role_assignment" "example-disk" {
  scope                = azurerm_key_vault.sac_vmss_keyvault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.sac_vmss_disk_encryption_set.identity.0.principal_id
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_network_security_group" "vmss_network_security_group" {
  name                = "vmss-sec-group"
  location            = azurerm_resource_group.vmss_resource_group.location
  resource_group_name = azurerm_resource_group.vmss_resource_group.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "vmss_virtual_network" {
  name                = "vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vmss_resource_group.location
  resource_group_name = azurerm_resource_group.vmss_resource_group.name
}

resource "azurerm_subnet" "vmss_subnet" {
  name                 = "vmss-subnet"
  resource_group_name  = azurerm_resource_group.vmss_resource_group.name
  virtual_network_name = azurerm_virtual_network.vmss_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}
