resource "azurerm_resource_group" "TerraFailVMSS_rg" {
  name     = "TerraFailVMSS_rg"
  location = "East US"
}

# ---------------------------------------------------------------------
# Virtual Machine Scale Set
# ---------------------------------------------------------------------
resource "azurerm_linux_virtual_machine_scale_set" "TerraFailVMSS_linux" {
  name                            = "TerraFailVMSS_linux"
  resource_group_name             = azurerm_resource_group.TerraFailVMSS_rg.name
  location                        = azurerm_resource_group.TerraFailVMSS_rg.location
  sku                             = "Standard_A1_v2"
  instances                       = 1
  admin_username                  = "adminuser"
  disable_password_authentication = false
  admin_password                  = "P@55w0rd1234!"
  encryption_at_host_enabled      = true
  upgrade_mode                    = "Automatic"
  zones = ["1", "2"]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  automatic_instance_repair {
    enabled = true
  }

  automatic_os_upgrade_policy {
    enable_automatic_os_upgrade = true
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
    name                      = "example"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.TerraFailVMSS_nsg.id
    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.TerraFailVMSS_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.TerraFailVMSS_lb_backend_pool.id]
    }
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "TerraFailVMSS_windows" {
  name                       = "TerraFailVMSS_windows"
  resource_group_name        = azurerm_resource_group.TerraFailVMSS_rg.name
  location                   = azurerm_resource_group.TerraFailVMSS_rg.location
  sku                        = "Standard_A1_v2"
  instances                  = 1
  admin_username             = "adminuser"
  admin_password             = "P@55w0rd1234!"
  encryption_at_host_enabled = true
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
      subnet_id                              = azurerm_subnet.TerraFailVMSS_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.TerraFailVMSS_lb_backend_pool.id]
    }
  }

  winrm_listener {
    protocol = "Http"
  }
}

# ---------------------------------------------------------------------
# LoadBalancer
# ---------------------------------------------------------------------
resource "azurerm_lb" "TerraFailVMSS_lb" {
  name                = "TerraFailVMSS_lb"
  location            = azurerm_resource_group.TerraFailVMSS_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVMSS_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name      = "PublicIPAddress"
    zones     = ["2"]
    subnet_id = azurerm_subnet.TerraFailVMSS_subnet.id
  }
}

resource "azurerm_lb_probe" "TerraFailVMSS_lb_probe" {
  loadbalancer_id = azurerm_lb.TerraFailVMSS_lb.id
  name            = "TerraFailVMSS_lb_probe"
  port            = 80
}

resource "azurerm_public_ip" "TerraFailVMSS_public_ip" {
  name                = "TerraFailVMSS_public_ip"
  location            = azurerm_resource_group.TerraFailVMSS_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVMSS_rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb_backend_address_pool" "TerraFailVMSS_lb_backend_pool" {
  loadbalancer_id = azurerm_lb.TerraFailVMSS_lb.id
  name            = "TerraFailVMSS_lb_backend_pool"
}

resource "azurerm_lb_rule" "TerraFailVMSS_lb_rule" {
  name                           = "TerraFailVMSS_lb_rule"
  loadbalancer_id                = azurerm_lb.TerraFailVMSS_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.TerraFailVMSS_lb_backend_pool.id]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.TerraFailVMSS_lb_probe.id
}

# ---------------------------------------------------------------------
# KeyVault
# ---------------------------------------------------------------------
resource "azurerm_disk_encryption_set" "TerraFailVMSS_disk_encryption_set" {
  name                = "TerraFailVMSS_disk_encryption_set"
  resource_group_name = azurerm_resource_group.TerraFailVMSS_rg.name
  location            = azurerm_resource_group.TerraFailVMSS_rg.location
  key_vault_key_id    = azurerm_key_vault_key.TerraFailVMSS_vault_key.id

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "TerraFailVMSS_vault" {
  name                        = "TerraFailVMSS_vault"
  location                    = azurerm_resource_group.TerraFailVMSS_rg.location
  resource_group_name         = azurerm_resource_group.TerraFailVMSS_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  public_network_access_enabled = false
}

resource "azurerm_key_vault_key" "TerraFailVMSS_vault_key" {
  name         = "TerraFailVMSS_vault_key"
  key_vault_id = azurerm_key_vault.TerraFailVMSS_vault.id
  key_type     = "RSA"
  key_size     = 2048

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
  }

  depends_on = [
    azurerm_key_vault_access_policy.TerraFailVMSS_vault_user_access_policy
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

resource "azurerm_key_vault_access_policy" "TerraFailVMSS_vault_disk_access_policy" {
  key_vault_id = azurerm_key_vault.TerraFailVMSS_vault.id

  tenant_id = azurerm_disk_encryption_set.TerraFailVMSS_disk_encryption_set.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.TerraFailVMSS_disk_encryption_set.identity.0.principal_id

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

resource "azurerm_key_vault_access_policy" "TerraFailVMSS_vault_user_access_policy" {
  key_vault_id = azurerm_key_vault.TerraFailVMSS_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
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
resource "azurerm_role_assignment" "TerraFailVMSS_role" {
  scope                = azurerm_key_vault.TerraFailVMSS_vault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.TerraFailVMSS_disk_encryption_set.identity.0.principal_id
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_network_security_group" "TerraFailVMSS_nsg" {
  name                = "TerraFailVMSS_nsg"
  location            = azurerm_resource_group.TerraFailVMSS_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVMSS_rg.name

  security_rule {
    name                       = "TerraFailVMSS_nsg_rule"
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

resource "azurerm_virtual_network" "TerraFailVMSS_vnet" {
  name                = "TerraFailVMSS_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.TerraFailVMSS_rg.location
  resource_group_name = azurerm_resource_group.TerraFailVMSS_rg.name
}

resource "azurerm_subnet" "TerraFailVMSS_subnet" {
  name                 = "TerraFailVMSS_subnet"
  resource_group_name  = azurerm_resource_group.TerraFailVMSS_rg.name
  virtual_network_name = azurerm_virtual_network.TerraFailVMSS_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
