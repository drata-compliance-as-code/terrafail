

resource "azurerm_resource_group" "front_door_rg" {
  name     = "sac-cdn-front-door-resource-group"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# FrontDoor
# ---------------------------------------------------------------------
resource "azurerm_cdn_frontdoor_profile" "sac_testing_frontdoor_profile" {
  name                = "sac-frontdoor-cdn-profile"
  resource_group_name = azurerm_resource_group.front_door_rg.name
  sku_name            = "Premium_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_security_policy" "sac_frontdoor_security_policy" {
  name                     = "sac-testing-fd-security-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.sac_testing_frontdoor_profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.sac_frontdoor_firewall_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.sac_frontdoor_endpoint.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "sac_frontdoor_firewall_policy" {
  name                = "examplecdnfdwafpolicy"
  resource_group_name = azurerm_resource_group.front_door_rg.name
  sku_name            = azurerm_cdn_frontdoor_profile.sac_testing_frontdoor_profile.sku_name
  enabled             = true
  mode                = "Detection"

  depends_on = [
    azurerm_cdn_frontdoor_profile.sac_testing_frontdoor_profile
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

resource "azurerm_cdn_frontdoor_endpoint" "sac_frontdoor_endpoint" {
  name                     = "sac-cdn-frontdoor-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.sac_testing_frontdoor_profile.id

  tags = {
    ENV = "testing"
  }
}

