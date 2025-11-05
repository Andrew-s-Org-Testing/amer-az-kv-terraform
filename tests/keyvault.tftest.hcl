variables {
  resource_group_name = "avt-wus3-tst-terraform-rg"
  location            = "westus3"
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

test {
  parallel = true
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "create_keyvault" {
  command = apply

  variables {
    private_dns_zone_id_keyvault = run.setup.private_dns_zone_id
    subnet_id_keyvault           = run.setup.subnet_id

    geo_region         = "amer"
    stage              = "tst"
    application_name   = "CCoE"
    bill_to_department = "AVT-CSG-GIS"
    entity             = "AVT-CSG-GIS"
    project            = "CCOE"
    cost_center        = "12345678"
    deployed_by        = "Terraform Automated Tests"
  }

  assert {
    condition     = azurerm_key_vault.this.name == "avt-amer-tst-ccoe-kv"
    error_message = "Keyvault name does not match expected value."
  }

  assert {
    condition     = azurerm_key_vault.this.id != null
    error_message = "Keyvault ID should not be null. Check that it deployed properly."
  }
}
