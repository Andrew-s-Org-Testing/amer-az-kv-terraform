module "azure_monitoring_setup" {
  source = "git::https://github.com/AvnetGIS/amer-az-alerts-terraform?ref=v1.0.0"
  #checkov:skip=CKV_TF_1:Module source is from a trusted internal repository
  target_resource_id = azurerm_key_vault.this.id
}

resource "azurerm_monitor_diagnostic_setting" "vault" {
  name                       = "${module.kv_amer_label.id}-diagnostics"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = "/subscriptions/2f2bebb8-4079-4940-9629-b7fd560d6154/resourceGroups/avt-amer-svc-wus3-ent-monitoring-rg/providers/Microsoft.OperationalInsights/workspaces/avt-amer-svc-wus3-snow-la"

  dynamic "enabled_log" {
    for_each = [
      "AuditEvent",
      "Performance",
      "Request",
      "Security",
    ]
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = [
      "AllMetrics",
    ]
    content {
      category = enabled_metric.value
    }
  }

  lifecycle {
    ignore_changes = [enabled_log, metric]
  }
}
