

resource "azurerm_resource_group" "TerraFailFrontDoor_rg" {
  name     = "TerraFailFrontDoor_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# FrontDoor
# ---------------------------------------------------------------------
resource "azurerm_cdn_frontdoor_profile" "TerraFailFrontDoor_profile" {
  name                = "TerraFailFrontDoor_profile"
  resource_group_name = azurerm_resource_group.TerraFailFrontDoor_rg.name
  sku_name            = "Premium_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_security_policy" "TerraFailFrontDoor_policy" {
  name                     = "TerraFailFrontDoor_policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.TerraFailFrontDoor_profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.TerraFailFrontDoor_firewall_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.TerraFailFrontDoor_endpoint.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "TerraFailFrontDoor_firewall_policy" {
  name                = "TerraFailFrontDoor_firewall_policy"
  resource_group_name = azurerm_resource_group.TerraFailFrontDoor_rg.name
  sku_name            = azurerm_cdn_frontdoor_profile.TerraFailFrontDoor_profile.sku_name
  enabled             = true
  mode                = "Detection"

  depends_on = [
    azurerm_cdn_frontdoor_profile.TerraFailFrontDoor_profile
  ]

  custom_rule {
    name                           = "RateLimitingRule"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    type                           = "MatchRule"
    action                         = "Allow"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "Equal"
      negation_condition = false
      match_values       = ["US"]
    }

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "Contains"
      negation_condition = false
      match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
    }
  }

  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
    action  = "Allow"

    override {
      rule_group_name = "PHP"

      rule {
        rule_id = "933100"
        enabled = false
        action  = "Block"
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_endpoint" "TerraFailFrontDoor_endpoint" {
  name                     = "TerraFailFrontDoor_endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.TerraFailFrontDoor_profile.id

  tags = {
    ENV = "sandbox"
  }
}

