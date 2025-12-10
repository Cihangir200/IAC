terraform {
  required_version = ">= 1.10.3"

  required_providers {
    esxi = {
      source  = "josenk/esxi"
      version = "1.10.3"
    }
  }
}

provider "esxi" {
  esxi_hostname = "192.168.1.5"
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = "root"
  esxi_password = "Welkom01!"
}

resource "esxi_guest" "week5_vm" {
  guest_name = "week5-ci-vm"
  disk_store = "datastore1"
  memsize    = 1024
  numvcpus   = 1

  ovf_source = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.ova"

  network_interfaces {
    virtual_network = "VM Network"
  }
}

output "vm_name" {
  value = esxi_guest.week5_vm.guest_name
}
# Test trigger for CI pipeline
