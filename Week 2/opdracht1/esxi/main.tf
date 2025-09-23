terraform {
  required_providers {
    esxi = {
      source  = "josenk/esxi"
      version = "~> 1.6"
    }
  }
}

provider "esxi" {
  esxi_hostname = "192.168.1.5"
  esxi_hostport = 22
  esxi_hostssl  = 443
  esxi_username = "root"
  esxi_password = "Welkom01!!"
}

resource "esxi_guest" "ubuntu_test" {
  guest_name = "ubuntu-test-vm"
  disk_store = "datastore1"
  ovf_source = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.ova"

  network_interfaces {
    virtual_network = "VM Network"
  }

  memsize = 1024
  numvcpus = 1
}
