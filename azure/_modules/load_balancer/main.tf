

resource "azurerm_resource_group" "sac_lb_resource_group" {
  name     = "sac-testing-lb-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# LoadBalancer
# ---------------------------------------------------------------------
resource "azurerm_lb" "sac_load_balancer" {
  name                = "sac-testing-load-balancer"
  location            = azurerm_resource_group.sac_aks_resource_group.location
  resource_group_name = azurerm_resource_group.sac_aks_resource_group.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.sac_lb_public_ip.id
  }
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "azurerm_public_ip" "sac_lb_public_ip" {
  name                = "sac-lb-public-ip"
  resource_group_name = azurerm_resource_group.sac_aks_resource_group.name
  location            = azurerm_resource_group.sac_aks_resource_group.location
  allocation_method   = "Static"

  sku = "Standard"

  tags = {
    environment = "Production"
  }
}
