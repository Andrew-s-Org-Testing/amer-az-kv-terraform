module "keyvault_private_endpoint" {
  source = <PATH_TO_PRIVATE_ENDPOINT_MODULE>

  name = "${var.key_vault_name}-pe"
    resource_group_name = var.resource_group_name
    location = var.location
    subnet_id = local.subnet_id
    private_connection_resource_id = azurerm_key_vault.vault.id
    subresource_names = ["vault"]

    private_dns_zone_group {
        name = "keyvaultPrivateDnsZoneGroup"
        private_dns_zone_ids = [var.private_dns_zone_id_keyvault]
    }

    tags = var.tags
}