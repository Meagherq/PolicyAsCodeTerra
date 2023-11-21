####################################
####Built-In Monitoring Policies####
####################################
data azurerm_policy_definition activity_log_retention_policy {
  display_name = "Activity log should be retained for at least one year"
}
output "activity_log_retention_policy" {
  value = {
    id = data.azurerm_policy_definition.activity_log_retention_policy.id
    parameter_values = <<VALUE
    {
      "effect": {"value": "AuditIfNotExists"}
    }
    VALUE
  }
}

##################################
####Custom Monitoring Policies####
##################################
resource "azurerm_policy_definition" "audit_law_app_service" {
  name         = "accTestPolicy"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "acceptance test policy definition"

  metadata = <<METADATA
    {
    "category": "General"
    }
    METADATA


  policy_rule = <<POLICY_RULE
  {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "microsoft.Web/serverFarms"
          },
          {
            "anyOf": [
              {
                "value": "[first(parameters('resourceLocationList'))]",
                "equals": "*"
              },
              {
                "field": "location",
                "in": "[parameters('resourceLocationList')]"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Insights/diagnosticSettings",
          "existenceCondition": {
            "allOf": [
              {
                "count": {
                  "field": "Microsoft.Insights/diagnosticSettings/logs[*]",
                  "where": {
                    "allOf": [
                      {
                        "field": "Microsoft.Insights/diagnosticSettings/logs[*].enabled",
                        "equals": "[equals(parameters('categoryGroup'), 'audit')]"
                      },
                      {
                        "field": "microsoft.insights/diagnosticSettings/logs[*].categoryGroup",
                        "equals": "audit"
                      }
                    ]
                  }
                },
                "equals": 1
              },
              {
                "count": {
                  "field": "Microsoft.Insights/diagnosticSettings/logs[*]",
                  "where": {
                    "allOf": [
                      {
                        "field": "Microsoft.Insights/diagnosticSettings/logs[*].enabled",
                        "equals": "[equals(parameters('categoryGroup'), 'allLogs')]"
                      },
                      {
                        "field": "microsoft.insights/diagnosticSettings/logs[*].categoryGroup",
                        "equals": "allLogs"
                      }
                    ]
                  }
                },
                "equals": 1
              },
              {
                "field": "Microsoft.Insights/diagnosticSettings/workspaceId",
                "equals": "[parameters('logAnalytics')]"
              }
            ]
          }
        }
      }
    }
  POLICY_RULE

  parameters = <<PARAMETERS
  {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ],
        "defaultValue": "AuditIfNotExists"
      },
      "categoryGroup": {
        "type": "String",
        "metadata": {
          "displayName": "Category Group",
          "description": "Diagnostic category group - none, audit, or allLogs."
        },
        "allowedValues": [
          "audit",
          "allLogs"
        ],
        "defaultValue": "allLogs"
      },
      "resourceLocationList": {
        "type": "Array",
        "metadata": {
          "displayName": "Resource Location List",
          "description": "Resource Location List to send logs to nearby Log Analytics. A single entry \"*\" selects all locations (default)."
        },
        "defaultValue": [
          "*"
        ]
      },
      "logAnalytics": {
        "type": "String",
        "metadata": {
          "displayName": "Log Analytics Workspace",
          "description": "Log Analytics Workspace",
          "strongType": "omsWorkspace",
          "assignPermissions": true
        },
        "defaultValue": "ebd7199b-33be-4511-b7e0-d6d015e7ae20"
      }
    }
  PARAMETERS
}
output "audit_law_app_service" {
  value = {
    id = azurerm_policy_definition.audit_law_app_service.id
    parameter_values = <<VALUE
    {
      "logAnalytics": {"value": "[parameters('logAnalytics')]"}
    }
    VALUE
  }
}
