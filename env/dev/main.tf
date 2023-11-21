terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.43.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.33.0"
    }
  }
}

# Configure the default provider
provider "azurerm" {
    features {}
}

provider "azuread" {}

#data
data "azurerm_client_config" "current" {}

module "monitoring" {
  source = "../../groups/Monitoring"
}

module "security" {
  source = "../../groups/Security"
}

locals {
  ## Monitoring ##
  monitoring_policies = [
    module.monitoring.activity_log_retention_policy,
    module.monitoring.audit_law_app_service
  ]

  ## Security ##
  security_policies = [
    # module.security.enforce_key_vault_deletion_protection
  ]
}

resource "azurerm_policy_set_definition" "set" {
  name         = "testPolicySet"
  policy_type  = "Custom"
  display_name = "Test Policy Set"

  parameters = <<PARAMETERS
    {
        "logAnalytics": {
            "displayName": "logAnalytics",
            "type": "string",
            "defaultValue": "Test"
        }
    }
  PARAMETERS

  policy_definition_group {
    name = "Monitoring"
  }

  dynamic "policy_definition_reference" {
    for_each = {for policy in local.monitoring_policies: policy.id => policy }

    content {
      policy_definition_id = policy_definition_reference.value.id
      parameter_values = policy_definition_reference.value.parameter_values
      policy_group_names = ["Monitoring"]
    }
  }

    policy_definition_group {
    name = "Security"
  }

  dynamic "policy_definition_reference" {
    for_each = {for policy in local.security_policies: policy.id => policy }

    content {
      policy_definition_id = policy_definition_reference.value.id
      parameter_values = policy_definition_reference.value.parameter_values
      policy_group_names = ["Security"]
    }
  }
}
