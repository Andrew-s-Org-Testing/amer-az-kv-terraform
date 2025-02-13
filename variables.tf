# PE Variables

variable "private_dns_zone_id_keyvault" {
  description = "The ID of the private DNS zone for the Key Vault"
  type = string 
}

# Key Vault Variables

variable "key_vault_name" {
  description = "The name of the Key Vault"
  type = string
}

variable "sku_name" {
  description = "The SKU name of the Key Vault"
  type = string
  default = "standard"

  validation {
    condition = contains(["standard", "premium"], lower(var.sku_name))
    error_message = "The SKU name must be either 'standard' or 'premium'"
  }
}

variable "enable_geo_replication" {
  type = bool
  description = "Enable geo-replication for the Key Vault backup Storage Account"
    default = false
}

variable "enable_purge_protection" {
  type = bool
  description = "Enable purge protection for the Key Vault"
    default = true
}

variable "soft_delete_retention_days" {
  type = number
  description = "The number of days to retain soft-deleted keys, secrets, and certificates"
    default = 30
}

variable "certificates" {
  type = map(object({
    subject = string
    dns_names = optional(list(string), [])
    validity_months = optional(number, 12)
    exportable = optional(bool, true)
    key_size = optional(number, 2048)
    key_type = optional(string, "RSA")
    reuse_key = optional(bool, false)
    content_type = optional(string, "application/x-pkcs12")
  }))
  description = "Map of certificates to create in the Key Vault"
    default = {}
}

variable "enabled_for_disk_encryption" {
  type = bool
  description = "Enable the Key Vault for disk encryption"
    default = true  
}

variable "enabled_for_deployment" {
  type = bool
  description = "Enable the Key Vault for template deployment"
    default = true  
}

variable "certificate_renewal_days" {
  type = number
  description = "The number of days before a certificate expires to renew it"
    default = 30

    validation {
        condition = var.certificate_renewal_days >= 7 && var.certificate_renewal_days <= 100
        error_message = "The certificate renewal days must be between 7 and 100"
    }
}

variable "backup_storage_account_tier" {
  type = string
  description = "The tier of the backup storage account"
    default = "Standard_LRS"

    validation {
        condition = contains(["Standard_LRS", "Standard_GRS", "Standard_RAGRS", "Standard_ZRS", "Premium_LRS"], var.backup_storage_account_tier)
        error_message = "The backup storage account tier must be 'Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Standard_ZRS', or 'Premium_LRS'"
    }
}

# Shared Variables

variable "location" {
  description = "The Azure region where the resources will be deployed"
  type = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be deployed"
  type = string  
}

variable "network_artifact_path" {
  description = "The path to the network configuration artifact"
  type = string  
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type = map(string)
  default = {
    "ManagedBy" = "Terraform"
  }
  
}

# Monitoring Variables

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  type = string
}

variable "service_now_action_group_id" {
  description = "The ID of the ServiceNow action group"
  type = string  
}

variable "alert_severity" {
  type = map(number)
  description = "Severity levels for alert types"
    default = {
        certificate_expiry = 1
        access_anomaly = 2
        backup_failure = 1
        vault_availability = 0
    }
}

variable "enable_diagnostic_settings" {
  type = bool
  description = "Enable diagnostic settings for the Key Vault"
    default = true  
}

variable "diagnostic_retention_days" {
  type = number
  description = "The number of days to retain diagnostic logs"
    default = 30

    validation {
        condition = var.diagnostic_retention_days >= 1 && var.diagnostic_retention_days <= 365
        error_message = "The diagnostic retention days must be between 1 and 365"
    }
}