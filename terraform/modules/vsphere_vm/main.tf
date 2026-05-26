resource "esxi_guest" "this" {
  guest_name    = "${var.project_name}-esxi"
  disk_store    = var.datastore_name
  clone_from_vm = var.template_name
  memsize       = var.memory
  numvcpus      = var.cpu
  power         = "on"
  boot_firmware = "efi"

  guest_startup_timeout = 300

  network_interfaces {
    virtual_network = var.network_name
    nic_type        = "vmxnet3"
  }

  guestinfo = {
    "metadata" = base64gzip(jsonencode({
      "instance-id"    = "${var.project_name}-esxi"
      "local-hostname" = "${var.project_name}-esxi"
    }))
    "metadata.encoding" = "gzip+base64"
    "userdata" = base64gzip(templatefile("${path.module}/cloud-init.yml.tftpl", {
      admin_username = var.admin_username
      ssh_public_key = var.ssh_public_key
      admin_password = var.admin_password
    }))
    "userdata.encoding" = "gzip+base64"
  }
}
