data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = "azure-mngmt"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "workload" {
  name                 = "subnet-ubuntu"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.workload_subnet_cidr]
}
