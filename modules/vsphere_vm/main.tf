data "vsphere_datacenter" "this" {
  name = var.datacenter_name
}

data "vsphere_datastore" "this" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_resource_pool" "this" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "this" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.this.id
}
