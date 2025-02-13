# Needs to be refactored for Storage Account module
resource "azurerm_storage_account" "backup" {
  name = "${var.key_vault_name}-backup"
    location = var.location
    resource_group_name = var.resource_group_name
    account_tier = var.backup_storage_account_tier
    account_replication_type = var.enable_geo_replication ? "GRS" : "LRS"

    network_rules {
      default_action = "Deny"
      bypass = ["AzureServices"]
    }

    tags = var.tags
}