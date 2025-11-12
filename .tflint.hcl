# .tflint.hcl - TFLint Configuration for Terraform Modules
# This file configures TFLint to catch common Terraform issues and enforce Azure best practices
# Place this file in the root of each module repository

# Core Terraform plugin - provides basic Terraform linting rules
plugin "terraform" {
  enabled = true
  preset  = "recommended"  # Enables a curated set of recommended rules
}

# Azure-specific plugin - provides Azure resource validation
plugin "azurerm" {
  enabled = true
  version = "0.25.1"  # Pin to specific version for consistency across modules
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Global configuration
config {
  format = "compact"                    # Output format: compact, default, json, junit, or sarif
  plugin_dir = "~/.tflint.d/plugins"   # Directory to store plugin binaries
  disabled_by_default = false          # Enable all rules by default
  
  # TODO: Customize based on your preferences
  # call_module_type = "local"         # Options: local, all, none - controls module inspection
  # force = false                      # Whether to ignore lock file issues
}

#
# TERRAFORM CORE RULES
# These rules enforce general Terraform best practices
#

# Ensure terraform_required_version is specified
rule "terraform_required_version" {
  enabled = true
  # WHY: Ensures consistent Terraform version across team members
  # CUSTOMIZE: You may want to set specific version constraints in your modules
}

# Ensure required_providers block is present and properly configured
rule "terraform_required_providers" {
  enabled = true
  # WHY: Explicit provider requirements prevent version conflicts
  # EXAMPLE: Should specify azurerm provider version like "~> 3.0"
}

# Enforce consistent naming conventions for resources, variables, and outputs
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"  # Options: snake_case, mixed_snake_case, none
  # WHY: Consistent naming improves code readability and maintainability
  # CUSTOMIZE: Consider "mixed_snake_case" if you have existing mixed conventions
}

# Ensure all variables have explicit types
rule "terraform_typed_variables" {
  enabled = true
  # WHY: Explicit types prevent unexpected behavior and improve documentation
  # EXAMPLE: variable "location" { type = string } instead of just variable "location" {}
}

# Detect unused variables, locals, and outputs
rule "terraform_unused_declarations" {
  enabled = true
  # WHY: Clean code - removes clutter and potential confusion
  # NOTE: May flag variables that are conditionally used
}

# Ensure proper comment syntax
rule "terraform_comment_syntax" {
  enabled = true
  # WHY: Enforces # for comments instead of // which can cause issues
}

# Ensure all outputs have descriptions
rule "terraform_documented_outputs" {
  enabled = true
  # WHY: Output descriptions are crucial for module consumers
  # EXAMPLE: output "storage_account_id" { description = "The ID of the storage account" }
}

# Ensure all variables have descriptions
rule "terraform_documented_variables" {
  enabled = true
  # WHY: Variable descriptions serve as inline documentation
  # EXAMPLE: variable "location" { description = "Azure region for resources" }
}

# Detect deprecated HashiCorp Configuration Language (HCL) syntax
rule "terraform_deprecated_interpolation" {
  enabled = true
  # WHY: Modern HCL syntax is more readable and performant
  # EXAMPLE: Use ${var.name} instead of "${var.name}" for simple references
}

# Require explicit module source versions
rule "terraform_module_pinned_source" {
  enabled = true
  # WHY: Prevents unexpected changes from module updates
  # EXAMPLE: source = "git::https://github.com/org/module.git?ref=v1.0.0"
  # TODO: May need to disable if using local modules during development
}

# Ensure workspace names follow conventions (if using workspaces)
rule "terraform_workspace_remote" {
  enabled = false  # Disabled by default - enable if using Terraform Cloud/Enterprise
  # WHY: Prevents accidental operations on wrong workspace
  # CUSTOMIZE: Enable if you use Terraform workspaces for environment separation
}

#
# AZURE-SPECIFIC RULES
# These rules enforce Azure best practices and catch common Azure configuration errors
#

# Validate Azure resource group naming conventions
rule "azurerm_resource_group_name" {
  enabled = true
  # WHY: Ensures resource groups follow Azure naming conventions
  # NOTE: Azure has specific character restrictions for resource group names
}

# TODO: Add more Azure-specific rules based on your organizational standards
# Examples of additional rules you might want:

# rule "azurerm_storage_account_name" {
#   enabled = true
#   # WHY: Storage account names must be globally unique and follow strict naming rules
# }

# rule "azurerm_virtual_machine_name" {
#   enabled = true
#   # WHY: VM names have specific length and character restrictions
# }

#
# CUSTOM RULES CONFIGURATION
# Disable or customize rules that don't fit your specific needs
#

# Example: Disable if you have a different variable documentation strategy
# rule "terraform_documented_variables" {
#   enabled = false
# }

# Example: Customize naming for specific resource types
# rule "terraform_naming_convention" {
#   enabled = true
#   format  = "snake_case"
#   custom_formats = {
#     # Allow different naming for specific resource types
#     azurerm_storage_account = "lower_case"  # Storage accounts require lowercase
#   }
# }

#
# PERFORMANCE AND BEHAVIOR SETTINGS
#

# TODO: Configure based on your CI/CD performance requirements
# config {
#   # Disable specific checks for large modules if performance is an issue
#   disabled_by_default = false
#   
#   # Adjust module call behavior
#   call_module_type = "local"  # Only check local modules, not remote ones
#   
#   # Enable/disable specific features
#   # varfile = ["terraform.tfvars"]  # Specify variable files to use for validation
# }

#
# ENVIRONMENT-SPECIFIC OVERRIDES
# You can create environment-specific configurations if needed
#

# Example: Different rules for development vs production modules
# rule "terraform_required_version" {
#   enabled = true
#   # For development: allow broader version ranges
#   # For production: require specific versions
# }

#
# INTEGRATION WITH CI/CD
# Configuration optimized for GitHub Actions workflow
#

# The following settings work well with the GitHub Actions workflow:
# - compact format for readable output in logs
# - all rules enabled by default for comprehensive checking
# - specific rule customization for your team's standards

# NEXT STEPS FOR CUSTOMIZATION:
# 1. Review each enabled rule and decide if it fits your team's standards
# 2. Add organization-specific naming conventions
# 3. Configure Azure-specific rules based on your resource types
# 4. Test with your existing modules and adjust as needed
# 5. Consider creating different configurations for different module types

#
# TROUBLESHOOTING COMMON ISSUES
#

# Issue: TFLint fails on valid Terraform code
# Solution: Check if you need to update plugin versions or disable specific rules

# Issue: Too many false positives
# Solution: Gradually enable rules or customize rule configurations

# Issue: Plugin installation failures in CI
# Solution: Ensure proper internet access and consider caching plugin directory

# Issue: Rules conflict with existing code style
# Solution: Prioritize consistency - either update code or adjust rules, but be consistent