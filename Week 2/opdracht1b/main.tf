terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.4.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id = var.subscription_id
}

# SSH key (reeds lokaal aanwezig in ~/.ssh/azure_rsa.pub)
resource "azurerm_ssh_public_key" "skylab" {
  name                = var.ssh_key_name
  location            = var.location
  resource_group_name = var.resource_group_name
  public_key          = file("~/.ssh/id_ed25519.pub")
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ubuntu"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-ubuntu"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "pip" {
  name                = "pip-ubuntu"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "nic-ubuntu"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "ubuntu-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_DS1_v2"   # of "Standard_F2"
  admin_username      = "iac"

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "iac"
    public_key = azurerm_ssh_public_key.skylab.public_key
  }

  custom_data = base64encode(templatefile("${path.module}/userdata.yml", {
    ssh_key = azurerm_ssh_public_key.skylab.public_key
  }))
}

# Output Public IP
output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}