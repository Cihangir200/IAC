provider "azurerm" {
  subscription_id            = var.azure_subscription_id
  skip_provider_registration = true
  features {}
}

provider "esxi" {
  esxi_hostname = var.vsphere_server
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = var.vsphere_user
  esxi_password = var.vsphere_password
}
