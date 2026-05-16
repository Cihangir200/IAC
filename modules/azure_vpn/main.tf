resource "azurerm_public_ip" "vpn" {
  name                = var.azure_gateway_pip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "this" {
  name                = "vpngw-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "Basic"

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  tags = var.tags
}

resource "azurerm_local_network_gateway" "onprem" {
  name                = "lng-${var.project_name}-esxi"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = var.onprem_vpn_public_ip
  address_space       = [var.onprem_cidr]
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "s2s" {
  name                       = "conn-${var.project_name}-azure-to-esxi"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem.id
  shared_key                 = var.vpn_shared_key
  tags                       = var.tags
}
