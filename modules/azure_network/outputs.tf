output "resource_group_name" {
  value = data.azurerm_resource_group.this.name
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "workload_subnet_id" {
  value = azurerm_subnet.workload.id
}

output "gateway_subnet_id" {
  value = null
}
