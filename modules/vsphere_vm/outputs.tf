output "vm_name" {
  value = esxi_guest.this.guest_name
}

output "vm_default_ip_address" {
  value = esxi_guest.this.ip_address
}
