

resource "azurerm_resource_group" "sac_vm_group" {
  name     = "sac-vm-group-0"
  location = "East US"
}

# ---------------------------------------------------------------------
# Virtual Machine
# ---------------------------------------------------------------------
resource "azurerm_windows_virtual_machine" "sac_windows_vm" {
  name                = "sac-windows-vm"
  resource_group_name = azurerm_resource_group.sac_vm_group.name
  location            = azurerm_resource_group.sac_vm_group.location
  size                = "Standard_DS2_v2"
  admin_username      = "adminuser"
  admin_password      = "$uper$ecretP@$$w0rd" # SaC Testing - Serverity: Low - define admin_password
  secure_boot_enabled = false
  network_interface_ids = [
    azurerm_network_interface.sac_windows_network_interface.id,
  ]
  #availability_set_id = azurerm_availability_set.sac_vm_availability_set.id  # SaC Testing - Serverity: High - Set availability_set_id to undefined
  encryption_at_host_enabled = false # SaC Testing - Serverity: Moderate - Set encryption_at_host_enabled to undefined
  winrm_listener {
    protocol = "Https"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    #disk_encryption_set_id = azurerm_disk_encryption_set.sac_vm_disk_encryption_set.id  # SaC Testing - Serverity: Moderate - Set disk_encryption_set_id to undefined
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  # SaC Testing - Serverity: Moderate - Set tags to undefined
  # tags = {
  #   environment = "Production"
  # }
}
