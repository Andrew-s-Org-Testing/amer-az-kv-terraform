module "keyvault_private_endpoint" {
  source = "git::https://github.com/Andrew-s-Org-Testing/amer-private-endpoint-terraform.git?ref=v1.1.0"
  #checkov:skip=CKV_TF_1:Module source is from a trusted internal repository

  #naming vars
  stage               = module.kv_amer_label.stage
  geo_region          = module.kv_amer_label.environment
  service_area        = module.kv_amer_label.tenant
  additional_suffixes = module.kv_amer_label.attributes

  #tagging vars
  deployed_by        = var.deployed_by
  application_name   = var.application_name
  cost_center        = var.cost_center
  bill_to_department = var.bill_to_department
  project            = var.project
  entity             = var.entity

  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_keyvault
  location            = var.location
  target_resource     = azurerm_key_vault.this.id
  subresource_name    = "vault"

  private_dns_zone_group = {
    name                       = "keyvaultPrivateDnsZoneGroup"
    private_dns_zone_group_ids = ["/subscriptions/4506920e-7581-4f01-a3c3-202caa8c5dd7/resourceGroups/avt-prd-wus2-vnet-rg-014/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
  }
}
