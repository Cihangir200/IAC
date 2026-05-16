output "vm_name" {
  value = var.enable_clone ? vsphere_virtual_machine.this[0].name : data.vsphere_virtual_machine.template.name
}

output "vm_default_ip_address" {
  value = var.enable_clone ? vsphere_virtual_machine.this[0].default_ip_address : null
}
