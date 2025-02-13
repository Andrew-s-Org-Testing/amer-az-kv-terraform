resource "azurerm_monitor_diagnostic_setting" "vault_diagnostics" {
  name = "${var.key_vault_name}-diagnostics"
  target_resource_id = azurerm_key_vault.vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "log" {
    for_each = ["AuditEvent", "AzurePolicyEvaluationDetails"]
    
    content {
        category = log.value
        enabled = true
    }

    retention_policy {
        enabled = true
        days = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled = true

    retention_policy {
        enabled = true
        days = 30
    }
  }
}

resource "azurerm_monitor_metric_alert" "certificates_expiry" {
    for_each = toset(local.monitoring_threshold.certificate_expiry_days)
    name = "${var.key_vault_name}-cert-expiry-${each.value}-days"
    resource_group_name = var.resource_group_name
    scopes = [azurerm_key_vault.vault.id]
    description = "Alert triggered when a certificate is about to expire in ${each.value} days"

    criteria {
        metric_namespace = "Microsoft.KeyVault/vaults"
        metric_name = "CertificateNearExpiry"
        aggregation = "Count"
        operator = "GreaterThan"
        threshold = each.value
    }

    action {
        action_group_id = var.service_now_action_group_id
    }
}