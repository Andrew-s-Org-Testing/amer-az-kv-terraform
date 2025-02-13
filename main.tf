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