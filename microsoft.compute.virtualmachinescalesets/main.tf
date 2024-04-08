
resource "azurerm_resource_group" "vmss_resource_group" {
  name     = "vmss-resource-group"
  location = "East US"
}
# ---------------------------------------------------------------------
# Virtual Machine Scale Set
# ---------------------------------------------------------------------
resource "azurerm_windows_virtual_machine_scale_set" "sac_windows_vmss" {
  name                       = "sac-windo"
  resource_group_name        = azurerm_resource_group.vmss_resource_group.name
  location                   = azurerm_resource_group.vmss_resource_group.location
  sku                        = "Standard_A1_v2"
  instances                  = 1
  admin_username             = "adminuser"
  admin_password             = "P@55w0rd1234!" # SaC Testing - Severity: High - Set admin_password != ""
  encryption_at_host_enabled = false           # SaC Testing - Severity: Critical - Set encryption_at_host_enabled to false
  #health_probe_id = azurerm_lb_probe.vmss_lb_probe.id  # SaC Testing - Severity: Moderate - Set health_probe_id to undefined
  upgrade_mode = "Automatic"
  #zones = ["2"]  # SaC Testing - Severity: Moderate - Set zones == ""
  automatic_instance_repair {
    enabled = false # SaC Testing - Severity: High - Set enabled to false
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  enable_automatic_updates = false
  automatic_os_upgrade_policy {
    # SaC Testing - Severity: High - Set enable_automatic_os_upgrade to false
    enable_automatic_os_upgrade = true
    disable_automatic_rollback  = false
  }
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    #disk_encryption_set_id = azurerm_disk_encryption_set.sac_vmss_disk_encryption_set.id # SaC Testing - Severity: Moderate - Set disk_encryption_set_id to ""
  }
  data_disk {
    caching              = "None"
    disk_size_gb         = 3
    lun                  = 20
    storage_account_type = "Standard_LRS"
    #disk_encryption_set_id = azurerm_disk_encryption_set.sac_vmss_disk_encryption_set.id # SaC Testing - Severity: Moderate - Set disk_encryption_set_id to ""
  }
  network_interface {
    name    = "example"
    primary = true
    #network_security_group_id = azurerm_network_security_group.vmss_network_security_group.id  # SaC Testing - Severity: High - Set network_security_group_id to ""
    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
    }
  }
  winrm_listener {
    protocol = "Http" # SaC Testing - Severity: Critical - set protocol to https
  }
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   environment = "staging"
  # }
}
