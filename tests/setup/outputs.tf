output "subnet_id" {
  description = "The ID of the subnet."
  value       = azurerm_subnet.example.id
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone for Key Vault."
  value       = azurerm_private_dns_zone.key_vault.id
}
