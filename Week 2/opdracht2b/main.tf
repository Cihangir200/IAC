terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  resource_provider_registrations = "none"
}

# Gebruik bestaande Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Virtual Network + Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ubuntu"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-ubuntu"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NSG met SSH toegang
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-ubuntu"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IPs
resource "azurerm_public_ip" "pip" {
  count               = var.vm_count
  name                = "pip-ubuntu-${count.index + 1}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NICs
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "nic-ubuntu-${count.index + 1}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconf"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count = var.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Ubuntu VM(s)
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "ubuntu-vm-${count.index + 1}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = "iac"
  network_interface_ids = [ azurerm_network_interface.nic[count.index].id ]

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
    # ⚡ Lees direct de key van je lokale bestand
    public_key = file(var.public_key_path)
  }

  custom_data = base64encode(
    templatefile("${path.module}/userdata.yml", {
      username = "iac"
      ssh_key  = file(var.public_key_path)
    })
  )
}

# Public IP’s opslaan in bestand
resource "local_file" "vm_ips" {
  filename = "${path.module}/azure-ips.txt"
  content  = join("\n", [for ip in azurerm_public_ip.pip : ip.ip_address])
}

output "public_ips" {
  value = [for ip in azurerm_public_ip.pip : ip.ip_address]
}
