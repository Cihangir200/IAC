provider "azurerm" {
  subscription_id            = var.azure_subscription_id
  skip_provider_registration = true
  features {}
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.vsphere_allow_unverified_ssl
}
