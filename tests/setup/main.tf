resource "random_integer" "example" {
  min = 10000
  max = 99999
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet-${random_integer.example.result}"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet-${random_integer.example.result}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vault.core.windows.net"
  resource_group_name = var.resource_group_name
}


