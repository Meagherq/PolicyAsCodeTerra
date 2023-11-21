####################################
####Built-In Monitoring Policies####
####################################
data azurerm_policy_definition enforce_key_vault_deletion_protection {
  display_name = "Key vaults should have deletion protection enabled"
}

output "enforce_key_vault_deletion_protection" {
  value = {
    id = data.azurerm_policy_definition.enforce_key_vault_deletion_protection.id
    parameters_values = null
  }
}