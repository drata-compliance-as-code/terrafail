

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
    public_ip_address_id = azurerm_public_ip.sac_lb_public_ip.id # SaC Testing - Severity: Moderate - Set public_ip_address_id to defined
    #private_ip_address = "172.16.10.100" # SaC Testing - Severity: Moderate - Set private_ip_address to undefined
    #zones = [1,2]  # SaC Testing - Severity: Moderate  - Set zones to ""
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  # tags = {
  #   "key" = "value"
  # } 
}
# resource "azurerm_lb_probe" "sac_load_balancer_probe" { # SaC Testing - Severity: Moderate - Set probes to undefined
#   loadbalancer_id = azurerm_lb.sac_load_balancer.id
#   name            = "sac-load-balancer-probe"
#   port            = 22
#   protocol = "Tcp"
# }
