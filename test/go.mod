// test/go.mod - Initialize this in each module's test directory
module github.com/your-org/terraform-module-name/test

go 1.21

require (
    github.com/gruntwork-io/terratest v0.46.1
    github.com/stretchr/testify v1.8.4
)

// test/unit_test.go - Template for unit tests
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestUnitModuleValidation(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        // Path to the Terraform code that will be tested
        TerraformDir: "../",
        
        // Variables to pass to the Terraform code using -var options
        Vars: map[string]interface{}{
            "location":         "East US",
            "environment":      "test",
            "project":          "terratest",
            "cost_center":      "engineering",
            "owner":           "platform-team",
            // Add module-specific variables here
        },
        
        // Disable backend for unit testing
        BackendConfig: map[string]interface{}{},
        Reconfigure:   true,
        
        // Set the path to save the plan
        PlanFilePath: "./unit_test.tfplan",
    })

    // Run terraform init and plan only (no apply for unit tests)
    planStruct := terraform.InitAndPlan(t, terraformOptions)

    // Example validations - adjust based on your module's resources
    
    // Validate that main resource exists in plan
    resourceAddress := "azurerm_storage_account.main" // Adjust to your module's main resource
    terraform.RequirePlannedValuesMapKeyExists(t, planStruct, resourceAddress)
    
    // Get the planned values for the resource
    resource := terraform.GetPlannedValuesForResource(t, planStruct, resourceAddress)
    
    // Validate specific configuration - adjust based on your module
    assert.Equal(t, true, resource["enable_https_traffic_only"], "HTTPS traffic should be enabled")
    assert.Equal(t, "TLS1_2", resource["min_tls_version"], "TLS version should be 1.2")
    assert.Equal(t, false, resource["public_network_access_enabled"], "Public access should be disabled")
    
    // Validate tags are present
    tags := resource["tags"].(map[string]interface{})
    assert.Equal(t, "test", tags["environment"], "Environment tag should be set")
    assert.Equal(t, "platform-team", tags["owner"], "Owner tag should be set")
    
    // Validate naming convention
    name := resource["name"].(string)
    assert.Regexp(t, "^[a-z0-9]+$", name, "Storage account name should be lowercase alphanumeric")
}

func TestUnitModuleOutputs(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "location":    "East US",
            "environment": "test",
            "project":     "terratest",
            // Add required variables
        },
        BackendConfig: map[string]interface{}{},
        Reconfigure:   true,
        PlanFilePath:  "./outputs_test.tfplan",
    })

    planStruct := terraform.InitAndPlan(t, terraformOptions)

    // Validate that expected outputs exist
    expectedOutputs := []string{
        "resource_id",
        "name", 
        "primary_connection_string",
        // Add your module's outputs here
    }

    for _, output := range expectedOutputs {
        terraform.RequirePlannedValuesMapKeyExists(t, planStruct, output)
    }
}

// test/integration_test.go - Template for integration tests (optional)
package test

import (
    "context"
    "strings"
    "testing"
    "time"

    "github.com/Azure/azure-sdk-for-go/sdk/azidentity"
    "github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/storage/armstorage"
    "github.com/gruntwork-io/terratest/modules/azure"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

// Only run integration tests when explicitly requested
func TestIntegrationModuleDeployment(t *testing.T) {
    // Skip unless specifically testing integration
    if testing.Short() {
        t.Skip("Skipping integration test in short mode")
    }

    t.Parallel()

    // Generate unique names to avoid conflicts
    uniqueId := random.UniqueId()
    namePrefix := "terratest" + strings.ToLower(uniqueId)

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "location":      "East US",
            "environment":   "test", 
            "project":       "terratest",
            "cost_center":   "engineering",
            "owner":        "platform-team",
            "name_prefix":   namePrefix,
            // Add module-specific variables
        },
        
        // Use regional backend for integration tests
        BackendConfig: map[string]interface{}{
            "resource_group_name":  "tfstate-rg-amer", // Adjust based on test region
            "storage_account_name": "tfstateamer",
            "container_name":       "tfstate",
            "key":                 "test-" + namePrefix + ".tfstate",
        },
    })

    // Clean up resources at the end of the test
    defer terraform.Destroy(t, terraformOptions)

    // Deploy the infrastructure
    terraform.InitAndApply(t, terraformOptions)

    // Validate that resources were created correctly
    subscriptionID := azure.GetSubscriptionID(t)
    
    // Example validation using Azure SDK
    cred, err := azidentity.NewDefaultAzureCredential(nil)
    require.NoError(t, err)
    
    client, err := armstorage.NewAccountsClient(subscriptionID, cred, nil)
    require.NoError(t, err)

    // Get the outputs from Terraform
    resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
    storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")

    // Validate the resource exists and has correct configuration
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()
    
    result, err := client.GetProperties(ctx, resourceGroupName, storageAccountName, nil)
    require.NoError(t, err)

    account := result.Account
    assert.NotNil(t, account.Properties)
    assert.Equal(t, armstorage.HTTPSTrafficOnlyEnabledTrue, *account.Properties.EnableHTTPSTrafficOnly)
    assert.Equal(t, armstorage.MinimumTLSVersionTLS12, *account.Properties.MinimumTLSVersion)
}

---
// tests/module.tftest.hcl - Terraform Native Test Template
// Create this file in the tests/ directory of your module

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Test variables - adjust based on your module
variables {
  location     = "East US"
  environment  = "test"
  project      = "terraform-testing"
  cost_center  = "engineering"
  owner       = "platform-team"
  
  # Add module-specific test variables here
  # storage_account_tier = "Standard"
  # replication_type     = "LRS"
}

# Test 1: Validate planned configuration
run "validate_configuration" {
  command = plan

  # Validate main resource configuration
  assert {
    condition     = azurerm_storage_account.main.enable_https_traffic_only == true
    error_message = "Storage account must enable HTTPS traffic only"
  }

  assert {
    condition     = azurerm_storage_account.main.min_tls_version == "TLS1_2" 
    error_message = "Storage account must use TLS 1.2 or higher"
  }

  assert {
    condition     = azurerm_storage_account.main.public_network_access_enabled == false
    error_message = "Storage account should not allow public network access"
  }

  # Validate required tags are present
  assert {
    condition = contains(keys(azurerm_storage_account.main.tags), "environment")
    error_message = "Storage account must have environment tag"
  }

  assert {
    condition = contains(keys(azurerm_storage_account.main.tags), "owner")
    error_message = "Storage account must have owner tag"
  }

  # Validate naming convention
  assert {
    condition = can(regex("^[a-z0-9]+$", azurerm_storage_account.main.name))
    error_message = "Storage account name must be lowercase alphanumeric"
  }
}

# Test 2: Validate outputs after apply (optional - requires actual deployment)
run "validate_outputs" {
  command = apply

  assert {
    condition     = output.storage_account_id != ""
    error_message = "Storage account ID output should not be empty"
  }

  assert {
    condition = can(regex("^https://", output.primary_blob_endpoint))
    error_message = "Primary blob endpoint must use HTTPS"
  }

  assert {
    condition = output.storage_account_name == azurerm_storage_account.main.name
    error_message = "Output name should match resource name"
  }
}

---
#!/bin/bash
# scripts/setup-module-testing.sh
# Run this script to set up testing framework in a new module repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Setting up Terraform Module Testing Framework"
echo "Module directory: $MODULE_ROOT"

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p test
mkdir -p tests
mkdir -p policies
mkdir -p .github/workflows

# Copy workflow file
echo "⚙️ Setting up GitHub Actions workflow..."
if [ ! -f .github/workflows/terraform-testing.yml ]; then
    cat > .github/workflows/terraform-testing.yml << 'EOF'
# Copy the main workflow content here
# Or download from your centralized template repository
EOF
    echo "Created .github/workflows/terraform-testing.yml"
fi

# Create pre-commit config
echo "🔧 Setting up pre-commit hooks..."
if [ ! -f .pre-commit-config.yaml ]; then
    # Copy pre-commit configuration from templates
    echo "Created .pre-commit-config.yaml"
fi

# Initialize Go module for tests
echo "🧪 Setting up test environment..."
if [ ! -f test/go.mod ]; then
    cd test
    MODULE_PATH="github.com/$(basename $(dirname $(pwd)))/$(basename $(dirname $(pwd)))/test"
    go mod init "$MODULE_PATH"
    go get github.com/gruntwork-io/terratest/modules/terraform@latest
    go get github.com/stretchr/testify/assert@latest
    go get github.com/Azure/azure-sdk-for-go/sdk/azidentity@latest
    go get github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/storage/armstorage@latest
    cd ..
    echo "Initialized Go module for Terratest"
fi

# Create example test files if they don't exist
if [ ! -f test/unit_test.go ]; then
    cat > test/unit_test.go << 'EOF'
// Basic unit test template - customize for your module
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestUnitBasicValidation(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "location":    "East US",
            "environment": "test",
            // Add your module's required variables here
        },
        BackendConfig: map[string]interface{}{},
        Reconfigure:   true,
        PlanFilePath:  "./basic_test.tfplan",
    })

    // This will run terraform init and plan but not apply
    planStruct := terraform.InitAndPlan(t, terraformOptions)

    // Add assertions based on your module's resources
    // Example: terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_resource_group.main")
    
    t.Log("Basic validation test completed successfully")
}
EOF
    echo "Created test/unit_test.go template"
fi

# Create Terraform native test template
if [ ! -f tests/basic.tftest.hcl ]; then
    cat > tests/basic.tftest.hcl << 'EOF'
# Basic Terraform native test - customize for your module
variables {
  location    = "East US"
  environment = "test"
  # Add your module's required variables here
}

run "basic_validation" {
  command = plan

  # Add assertions based on your module's resources
  # Example:
  # assert {
  #   condition     = azurerm_resource_group.main.location == "East US"
  #   error_message = "Resource group should be in East US"
  # }
}
EOF
    echo "Created tests/basic.tftest.hcl template"
fi

# Create example.tfvars for cost estimation
if [ ! -f example.tfvars ]; then
    cat > example.tfvars << 'EOF'
# Example values for cost estimation and testing
location    = "East US"
environment = "sandbox"
project     = "terraform-testing"
cost_center = "engineering"
owner      = "platform-team"

# Add your module's variables with realistic example values here
# This file is used for cost estimation in CI/CD
EOF
    echo "Created example.tfvars template"
fi

# Create basic policies
if [ ! -f policies/main.rego ]; then
    cat > policies/main.rego << 'EOF'
package terraform.module

import rego.v1

# Basic policy to ensure resources have required tags
required_tags := ["environment", "owner", "project"]

deny contains msg if {
    some i
    resource := input.planned_values.root_module.resources[i]
    resource.type != "random_string"  # Skip utility resources
    missing_tags := required_tags - object.keys(resource.values.tags)
    count(missing_tags) > 0
    msg := sprintf("Resource '%s' is missing required tags: %v", [resource.address, missing_tags])
}
EOF
    echo "Created policies/main.rego template"
fi

# Install pre-commit if available
if command -v pre-commit &> /dev/null; then
    echo "🪝 Installing pre-commit hooks..."
    pre-commit install
else
    echo "⚠️  pre-commit not found. Install it with: pip install pre-commit"
fi

echo ""
echo "✅ Module testing framework setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Customize the test files in test/ and tests/ directories for your module"
echo "2. Update example.tfvars with realistic values for your module"
echo "3. Configure repository secrets in GitHub:"
echo "   - AZURE_CLIENT_ID"
echo "   - AZURE_CLIENT_SECRET" 
echo "   - AZURE_TENANT_ID"
echo "   - AZURE_SUBSCRIPTION_ID_AMER"
echo "   - AZURE_SUBSCRIPTION_ID_APAC"
echo "   - AZURE_SUBSCRIPTION_ID_EMEA"
echo "   - INFRACOST_API_KEY"
echo "4. Commit and push to trigger the testing workflow"
echo ""
echo "📚 Documentation:"
echo "- Test files: test/ directory contains Terratest Go tests"
echo "- Native tests: tests/ directory contains Terraform native tests"
echo "- Policies: policies/ directory contains OPA/Rego policies"
echo "- CI/CD: .github/workflows/terraform-testing.yml"

---
# Implementation Checklist for Rolling Out Framework

## Phase 1: Infrastructure Setup (1-2 days)

### Azure Infrastructure
- [ ] Create regional state storage accounts:
  - [ ] AMER: `tfstate-rg-amer` / `tfstateamer` 
  - [ ] APAC: `tfstate-rg-apac` / `tfstateapac`
  - [ ] EMEA: `tfstate-rg-emea` / `tfstateemea`
- [ ] Configure service principal with proper permissions:
  - [ ] Contributor role on subscriptions
  - [ ] Storage Blob Data Contributor on state storage accounts
- [ ] Set up Infracost account and get API key

### GitHub Organization Setup  
- [ ] Create organization-level secrets:
  - [ ] `AZURE_CLIENT_ID`
  - [ ] `AZURE_CLIENT_SECRET`
  - [ ] `AZURE_TENANT_ID`
  - [ ] `AZURE_SUBSCRIPTION_ID_AMER`
  - [ ] `AZURE_SUBSCRIPTION_ID_APAC`
  - [ ] `AZURE_SUBSCRIPTION_ID_EMEA`
  - [ ] `INFRACOST_API_KEY`

## Phase 2: Framework Templates (1 day)

### Create Template Repository
- [ ] Create `terraform-module-testing-framework` repository
- [ ] Add all configuration templates
- [ ] Add setup scripts and documentation
- [ ] Create reusable workflow templates

### Documentation
- [ ] Module testing standards document
- [ ] Cost threshold guidelines by module type
- [ ] Security policy requirements
- [ ] Troubleshooting guide

## Phase 3: Pilot Implementation (1 week)

### Select Pilot Modules (2-3 modules)
- [ ] Choose modules with different complexity levels
- [ ] Implement testing framework in pilot modules
- [ ] Run full testing cycles
- [ ] Document lessons learned
- [ ] Refine templates based on feedback

### Validation
- [ ] Verify static analysis catches issues
- [ ] Validate cost estimation accuracy  
- [ ] Test regional state backend switching
- [ ] Confirm security policies work correctly

## Phase 4: Organization Rollout (2-4 weeks)

### Rollout Strategy
- [ ] Create module migration schedule
- [ ] Team training sessions
- [ ] Update development workflows
- [ ] Implement framework in all module repos

### Support and Monitoring
- [ ] Create team responsible for framework maintenance
- [ ] Set up monitoring for test execution
- [ ] Establish feedback collection process
- [ ] Plan regular framework updates

## Regional Configuration Details

### AMER (Americas)
- Subscription: Primary development subscription
- State Storage: `tfstateamer` in East US
- Cost Threshold: $500/month (higher for primary region)
- Test Environment: Sandbox and Dev in East US

### APAC (Asia Pacific)  
- Subscription: APAC-specific subscription
- State Storage: `tfstateapac` in Southeast Asia
- Cost Threshold: $300/month
- Test Environment: Sandbox in Southeast Asia

### EMEA (Europe, Middle East, Africa)
- Subscription: EMEA-specific subscription  
- State Storage: `tfstateemea` in West Europe
- Cost Threshold: $400/month
- Test Environment: Sandbox in West Europe

## Module Type Guidelines

### Storage Modules
- Expected monthly cost: $50-200
- Key security policies: HTTPS only, TLS 1.2, no public access
- Required tests: Encryption validation, access policy tests

### Compute Modules  
- Expected monthly cost: $200-800
- Key security policies: No password auth, managed disks, endpoint protection
- Required tests: Size validation, security configuration

### Networking Modules
- Expected monthly cost: $100-400  
- Key security policies: No unrestricted access, proper NSG rules
- Required tests: Network segmentation, security rule validation

### Database Modules
- Expected monthly cost: $300-1000
- Key security policies: Encryption at rest, firewall rules, no public access
- Required tests: Backup configuration, access validation