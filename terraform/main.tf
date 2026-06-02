resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "azure_network" {
  source   = "./modules/azure_network"
  for_each = var.enable_azure_deployment ? { enabled = true } : {}

  location             = var.location
  resource_group_name  = var.azure_resource_group_name
  tags                 = local.tags
  vnet_cidr            = var.azure_vnet_cidr
  workload_subnet_cidr = var.azure_workload_cidr
}

module "azure_vm" {
  source   = "./modules/azure_linux_vm"
  for_each = var.enable_azure_deployment ? { enabled = true } : {}

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

  project_name   = var.project_name
  admin_username = var.admin_username
  ssh_public_key = tls_private_key.ssh.public_key_openssh
  datastore_name = var.vsphere_datastore
  network_name   = var.vsphere_network
  template_name  = var.vsphere_template
  cpu            = var.vsphere_vm_cpu
  memory         = var.vsphere_vm_memory
  admin_password = var.admin_password
}
