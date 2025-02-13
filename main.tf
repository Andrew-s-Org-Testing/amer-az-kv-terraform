locals {
  # Parse network configuration from artifact
  network_config = jsondecode(file(var.network_artifact_path))

  # Extract subnet information for private endpoint
  subnet_id = local.network_config.subnets[0].id

  # Default monitoring threshold
  monitoring_threshold = {
    certificate_expiry_days = [90, 60, 30]
    failed_requests_threshold = 5
    latency_threshold_ms = 1000
  }
}

resource "azurerm_key_vault" "vault" {
    name = var.key_vault_name
    location = var.location
    resource_group_name = var.resource_group_name
    tenant_id = data.azurerm_client_config.current.tenant_id
    sku_name = var.sku_name

    enabled_for_disk_encryption = true
    enabled_for_deployment = true
    enabled_for_template_deployment = true

    soft_delete_retention_days = 30
    purge_protection_enabled = true
    enable_rbac_authorization = true

    network_acls {
        default_action = "Deny"
        bypass = "AzureServices"
    }

    tags = var.tags
}

resource "azurerm_key_vault_certificate" "managed_cert" {
  for_each = var.certificates
  name = each.key
    key_vault_id = azurerm_key_vault.vault.id

    certificate_policy {
      issuer_parameters {
        name = "Self"
      }

        key_properties {
            key_type = each.value.key_type
            reuse_key = each.value.reuse_key
            exportable = each.value.exportable
            key_size = each.value.key_size
        }

        lifetime_action {
          action {
            action_type = "AutoRenew"
          }
          
            trigger {
                days_before_expiry = var.certificate_renewal_days
            }
        }

        secret_properties {
            content_type = each.value.content_type
        }

        x509_certificate_properties {
            extended_key_usage = ["1.2.3.6.1.5.5.7.3.1"]
            key_usage = [ "digitalSignature", "keyEncipherment" ]
            subject = each.value.subject
            validity_in_months = each.value.validity_months

            subject_alternative_names {
                dns_names = each.value.dns_names
            }
        }
    }
}