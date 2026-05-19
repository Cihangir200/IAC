resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "azure_network" {
  source   = "./modules/azure_network"
  for_each = var.enable_azure_deployment ? { enabled = true } : {}

  project_name            = var.project_name
  location                = var.location
  resource_group_name     = var.azure_resource_group_name
  resource_group_location = var.azure_resource_group_location
  tags                    = local.tags
  vnet_cidr               = var.azure_vnet_cidr
  workload_subnet_cidr    = var.azure_workload_cidr
}

module "azure_vpn" {
  source   = "./modules/azure_vpn"
  for_each = var.enable_azure_deployment && var.enable_azure_vpn ? { enabled = true } : {}

  project_name           = var.project_name
  location               = var.location
  tags                   = local.tags
  resource_group_name    = module.azure_network["enabled"].resource_group_name
  vnet_name              = module.azure_network["enabled"].vnet_name
  gateway_subnet_id      = module.azure_network["enabled"].gateway_subnet_id
  azure_gateway_pip_name = "${var.project_name}-vpn-pip"
  onprem_cidr            = var.onprem_cidr
  onprem_vpn_public_ip   = var.onprem_vpn_public_ip
  vpn_shared_key         = var.vpn_shared_key
}

module "azure_vm" {
  source   = "./modules/azure_linux_vm"
  for_each = var.enable_azure_deployment ? { enabled = true } : {}

  project_name        = var.project_name
  location            = var.location
  tags                = local.tags
  resource_group_name = module.azure_network["enabled"].resource_group_name
  subnet_id           = module.azure_network["enabled"].workload_subnet_id
  admin_username      = var.admin_username
  ssh_public_key      = tls_private_key.ssh.public_key_openssh
  vm_size             = var.azure_vm_size
}

module "vsphere_vm" {
  source = "./modules/vsphere_vm"

  project_name    = var.project_name
  admin_username  = var.admin_username
  ssh_public_key  = tls_private_key.ssh.public_key_openssh
  datacenter_name = var.vsphere_datacenter
  datastore_name  = var.vsphere_datastore
  resource_pool   = var.vsphere_resource_pool
  network_name    = var.vsphere_network
  template_name   = var.vsphere_template
  cpu             = var.vsphere_vm_cpu
  memory          = var.vsphere_vm_memory
  admin_password  = var.admin_password
}
