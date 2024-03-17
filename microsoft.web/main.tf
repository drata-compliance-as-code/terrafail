
resource "azurerm_resource_group" "sac_web_resource_group" {
  name     = "sac-test-web-resource-group"
  location = "East US"
}
# ---------------------------------------------------------------------
# Web App
# ---------------------------------------------------------------------
resource "azurerm_linux_web_app" "sac_linux_web_app" {
  name                       = "sac-linux-web-app"
  resource_group_name        = azurerm_resource_group.sac_web_resource_group.name
  location                   = azurerm_resource_group.sac_web_resource_group.location
  service_plan_id            = azurerm_service_plan.sac_web_service_plan.id
  client_certificate_enabled = false      # SaC Testing - Severity: Critical - Set client_certificate_enabled to false
  client_certificate_mode    = "Optional" # SaC Testing - Severity: Critical - Set client_certificate_mode != "Required"
  site_config {
    cors {
      allowed_origins = ["*"] # SaC Testing - Severity: Critical - Set allowed_origins to invalid value
    }
    minimum_tls_version      = "1.0" # SaC Testing - Severity: Critical - Set minimum_tls_version != 1.2
    remote_debugging_enabled = true  # SaC Testing - Severity: Moderate - Set remote_debugging_enabled to true
    ip_restriction {
      action     = "Allow"
      ip_address = "0.0.0.0/0" # SaC Testing - Severity: Critical - Set ip_address to one of ["0.0.0.0/0", "*"]
    }
  }
}

resource "azurerm_windows_web_app" "sac_windows_web_app" {
  name                       = "sac-windows-web-app"
  resource_group_name        = azurerm_resource_group.sac_web_resource_group.name
  location                   = azurerm_resource_group.sac_web_resource_group.location
  service_plan_id            = azurerm_service_plan.sac_web_service_plan.id
  client_certificate_enabled = false      # SaC Testing - Severity: Critical - Set client_certificate_enabled to false
  client_certificate_mode    = "Optional" # SaC Testing - Severity: Critical - Set client_certificate_mode != "Required"
  site_config {
    cors {
      allowed_origins = ["*"] # SaC Testing - Severity: Critical - Set allowed_origins to invalid value
    }
    minimum_tls_version      = "1.0" # SaC Testing - Severity: Critical - Set minimum_tls_version != 1.2
    remote_debugging_enabled = true  # SaC Testing - Severity: Moderate - Set remote_debugging_enabled to true
    ip_restriction {
      action     = "Allow"
      ip_address = "0.0.0.0/0" # SaC Testing - Severity: Critical - Set ip_address to one of ["0.0.0.0/0", "*"]
    }
  }
}
