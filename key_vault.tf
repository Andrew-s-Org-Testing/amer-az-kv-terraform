resource "azurerm_key_vault" "this" {
  #checkov:skip=CKV2_AZURE_32:key vault is configured with a private endpoint through module call in private_endpoint.tf
  name                = module.kv_amer_label.id
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name

  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_azure_vm_deployment
  enabled_for_template_deployment = var.enabled_for_arm_template_deployment

  soft_delete_retention_days    = 30
  purge_protection_enabled      = true
  rbac_authorization_enabled    = true
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"

    ip_rules                   = toset(var.allowed_ip_addresses_keyvault)
    virtual_network_subnet_ids = toset(var.allowed_subnet_ids_keyvault)
  }

  tags = local.common_tags
}
