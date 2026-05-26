variable "project_name" {
  description = "Naam voor alle resources."
  type        = string
  default     = "iac-hybrid-lab"
}

variable "environment" {
  description = "Omgevingsnaam."
  type        = string
  default     = "lab"
}

variable "location" {
  description = "Azure regio."
  type        = string
  default     = "westeurope"
}

variable "azure_resource_group_location" {
  description = "Azure locatie voor de resource group metadata. Windesheim policy staat hiervoor andere regio's toe dan voor resources."
  type        = string
  default     = "westeurope"
}

variable "azure_resource_group_name" {
  description = "Naam van de bestaande Azure resource group die voor de opdracht gebruikt moet worden."
  type        = string
  default     = "s1187594"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID. Laat leeg als je Azure CLI context gebruikt."
  type        = string
  default     = null
}

variable "enable_azure_deployment" {
  description = "Zet op false als Azure Policy of subscription access resource deployment blokkeert."
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "Linux admin user voor Azure en ESXi VM's."
  type        = string
  default     = "Student"
}

variable "admin_password" {
  description = "Optioneel tijdelijk wachtwoord voor console/SSH login op de ESXi guest. Zet dit alleen in terraform.tfvars, nooit in Git."
  type        = string
  sensitive   = true
  default     = ""
}

variable "azure_vm_size" {
  description = "Azure VM grootte."
  type        = string
  default     = "Standard_B1s"
}

variable "azure_workload_cidr" {
  description = "CIDR voor workload subnet in Azure."
  type        = string
  default     = "10.10.1.0/24"
}

variable "azure_vnet_cidr" {
  description = "CIDR voor Azure VNet."
  type        = string
  default     = "10.10.0.0/16"
}

variable "vsphere_server" {
  description = "vCenter of ESXi hostname/IP."
  type        = string
}

variable "vsphere_user" {
  description = "vSphere username."
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere password."
  type        = string
  sensitive   = true
}

variable "vsphere_allow_unverified_ssl" {
  description = "Sta self-signed vSphere certificaten toe."
  type        = bool
  default     = true
}

variable "vsphere_datacenter" {
  description = "Naam van het vSphere datacenter."
  type        = string
}

variable "vsphere_datastore" {
  description = "Naam van de datastore."
  type        = string
}

variable "vsphere_resource_pool" {
  description = "Naam van de vSphere/ESXi resource pool."
  type        = string
  default     = "Resources"
}

variable "vsphere_network" {
  description = "Naam van het VM netwerk/portgroup."
  type        = string
}

variable "vsphere_template" {
  description = "Naam van de Linux template met cloud-init ondersteuning."
  type        = string
}

variable "vsphere_vm_cpu" {
  description = "Aantal vCPU's voor ESXi VM."
  type        = number
  default     = 2
}

variable "vsphere_vm_memory" {
  description = "Geheugen in MB voor ESXi VM."
  type        = number
  default     = 2048
}
