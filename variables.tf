# PE Variables

variable "subnet_id_keyvault" {
  description = "The Azure ARM ID of the subnet or vnet to deploy the Key Vault private endpoint into"
  type        = string
}

#Network Variables

variable "allowed_ip_addresses_keyvault" {
  description = "A list of IP addresses allowed to access the Key Vault"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids_keyvault" {
  description = "A list of subnet IDs allowed to access the Key Vault"
  type        = list(string)
  default     = []
}

# Key Vault Variables


variable "sku_name" {
  description = "The SKU name of the Key Vault"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], lower(var.sku_name))
    error_message = "The SKU name must be either 'standard' or 'premium'"
  }
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Enable the Key Vault for disk encryption"
  default     = true
}

variable "enabled_for_azure_vm_deployment" {
  type        = bool
  description = "Enable the Key Vault for template deployment"
  default     = true
}

variable "enabled_for_arm_template_deployment" {
  type        = bool
  description = "Enable the Key Vault for template deployment"
  default     = true
}

# Shared Variables

variable "location" {
  description = "The Azure region where the resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be deployed"
  type        = string
}

# Naming Variables
variable "stage" {
  description = "The stage of deployment using Avnet's three letter code names"
  type        = string
  validation {
    condition = contains([
      "dev",
      "poc",
      "tst",
      "qa",
      "prd",
      "stg",
      "dr"
    ], lower(var.stage))
    error_message = "The stage must be one of 'dev', 'poc', 'tst', 'qa', 'prd', 'stg', or 'dr'"
  }
}

variable "geo_region" {
  description = "The environment of deployment (e.g., amer, emeai)"
  type        = string
  validation {
    condition = contains([
      "unassigned",
      "amer",
      "emea",
      "apac",
      "global"
    ], lower(var.geo_region))
    error_message = "The environment must be one of 'unassigned', 'amer', 'emea', 'apac', or 'global'"
  }
}

variable "service_area" {
  description = "The service area or tenant (e.g., data, integration (int))"
  type        = string
  default     = ""
}

variable "additional_suffixes" {
  description = "Additional suffixes for resource naming"
  type        = list(string)
  default     = []
}

variable "application_name" {
  description = "The name of the application using the Key Vault, used for tagging and naming"
  type        = string
}

variable "bill_to_department" {
  description = "The department to bill for the Key Vault"
  type        = string

  validation {
    condition = contains([
      "Avnet-AVT",
      "PremierFarnell-PF",
      "SoftWeb-SW",
      "AVT-EC-Core",
      "AVT-EC-EBV",
      "AVT-EC-Silica",
      "AVT-EC-Abacus",
      "AVT-EC-Asia",
      "AVT-EC-Japan",
      "AVT-IS-Embedded",
      "AVT-IS-MSC",
      "AVT-Emerging-Dragon",
      "AVT-Emerging-Hackster",
      "AVT-Emerging-SoftWeb",
      "AVT-EC-Farnell",
      "AVT-CSG-Admin",
      "AVT-CSG-Finance",
      "AVT-CSG-GIS",
      "AVT-CSG-HR",
      "AVT-CSG-Legal",
      "AVT-CSG-Logistics",
      "AVT-CSG-MarCom",
      "AVT-CSG-Strategy", "AVT-CSG-TO"
    ], var.bill_to_department)
    error_message = "Invalid bill_to_department. Must be one of the predefined department codes."
  }
}

variable "entity" {
  description = "The entity associated with the Key Vault"
  type        = string
  validation {
    condition = contains([
      "Unassigned",
      "Avnet-AVT",
      "PremierFarnell-PF",
      "SoftWeb-SW",
      "AVT-EC-Core",
      "AVT-EC-EBV",
      "AVT-EC-Silica",
      "AVT-EC-Abacus",
      "AVT-EC-Asia",
      "AVT-EC-Japan",
      "AVT-IS-Embedded",
      "AVT-IS-MSC",
      "AVT-Emerging-Dragon",
      "AVT-Emerging-Hackster",
      "AVT-Emerging-SoftWeb",
      "AVT-EC-Farnell",
      "AVT-CSG-Admin",
      "AVT-CSG-Finance",
      "AVT-CSG-GIS",
      "AVT-CSG-HR",
      "AVT-CSG-Legal",
      "AVT-CSG-Logistics",
      "AVT-CSG-MarCom",
      "AVT-CSG-Strategy",
      "AVT-CSG-TO"
    ], var.entity)
    error_message = "Invalid entity. Must be one of the predefined entity codes."
  }
}

variable "project" {
  description = "The name of the project associated with the Key Vault"
  type        = string
}

variable "cost_center" {
  description = "The cost center associated with the Key Vault"
  type        = string
}

variable "deployed_by" {
  description = "The individual or team deploying the Key Vault"
  type        = string
}

