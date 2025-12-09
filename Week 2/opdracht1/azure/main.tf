terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "azurerm" {
  features {}
  # Laat deze subscription staan zoals je zelf gebruikt. Pas desnoods aan.
  subscription_id                 = "c064671c-8f74-4fec-b088-b53c568245eb"
  resource_provider_registrations = "none"
}

# ===== Huidige resource group + eerder geüploade SSH key =====
data "azurerm_resource_group" "rg" {
  name = "S1187594"
}

data "azurerm_ssh_public_key" "skylab" {
  name                = "skylab"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# ================== Netwerk ==================
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

# NSG met SSH open
resource "azurerm_network_security_group" "ssh" {
  name                = "nsg-ssh"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 2× Public IP (statisch, Standard)
resource "azurerm_public_ip" "pip" {
  count               = 2
  name                = "pip-ubuntu-${count.index + 1}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 2× NIC + NSG-koppeling
resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "nic-ubuntu-${count.index + 1}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.ssh.id
}

# ============== Cloud-Init ==============
locals {
  admin_user = "iac"
  cloudinit  = <<-EOT
    #cloud-config
    users:
      - name: ${local.admin_user}
        groups: [sudo]
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
    write_files:
      - path: /home/${local.admin_user}/hello.txt
        content: |
          Hello World
        owner: ${local.admin_user}:${local.admin_user}
        permissions: '0644'
  EOT
}

# ============== 2× Ubuntu 24.04 VM ==============
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = 2
  name                  = "ubuntu-vm-${count.index + 1}"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
  size                  = "Standard_DS1_v2"
  admin_username        = local.admin_user
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu 24.04 LTS (noble). Als jouw tenant gen2 eist: vervang sku door "24_04-lts-gen2"
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble"
    sku       = "24_04-lts"
    version   = "latest"
  }

  # Eerder geüploade SSH key resource gebruiken
  admin_ssh_key {
    username   = local.admin_user
    public_key = data.azurerm_ssh_public_key.skylab.public_key
  }

  custom_data = base64encode(local.cloudinit)
}

# ============== IP's naar bestand + outputs ==============
resource "local_file" "azure_ips" {
  filename = "${path.module}/azure_ips.txt"
  content  = join("\n", [for i in azurerm_public_ip.pip : "${i.name}: ${i.ip_address}"])
}

output "public_ips" {
  value = [for i in azurerm_public_ip.pip : i.ip_address]
}
