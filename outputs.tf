output "azure_vm_public_ip" {
  description = "Publiek IP-adres van de Azure VM."
  value       = try(module.azure_vm["enabled"].public_ip_address, null)
}

output "azure_vm_private_ip" {
  description = "Privaat IP-adres van de Azure VM."
  value       = try(module.azure_vm["enabled"].private_ip_address, null)
}

output "azure_vpn_public_ip" {
  description = "Publiek IP-adres van de Azure VPN Gateway."
  value       = try(module.azure_vpn["enabled"].public_ip_address, null)
}

output "azure_vpn_enabled" {
  description = "Geeft aan of Azure VPN Gateway resources in deze run worden aangemaakt."
  value       = var.enable_azure_vpn
}

output "azure_deployment_enabled" {
  description = "Geeft aan of Azure resources in deze run worden aangemaakt."
  value       = var.enable_azure_deployment
}

output "vsphere_vm_name" {
  description = "Naam van de ESXi/vSphere VM."
  value       = module.vsphere_vm.vm_name
}

output "vsphere_vm_private_ip" {
  description = "Privaat IP-adres van de ESXi VM."
  value       = module.vsphere_vm.vm_default_ip_address
}

output "ssh_public_key" {
  description = "Publieke SSH key die in CloudInit wordt geplaatst."
  value       = tls_private_key.ssh.public_key_openssh
}

output "ssh_private_key_pem" {
  description = "Private SSH key voor de demo. Behandel deze als geheim."
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}
