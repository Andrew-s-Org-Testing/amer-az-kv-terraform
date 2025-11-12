output "key_vault" {
  description = "The Key Vault details."
  value = {
    id         = azurerm_key_vault.this.id
    name       = azurerm_key_vault.this.name
    fqdn       = azurerm_key_vault.this.vault_uri
    ip_address = module.keyvault_private_endpoint.private_ip_address
  }
}
