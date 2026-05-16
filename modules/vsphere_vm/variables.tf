variable "project_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "datacenter_name" {
  type = string
}

variable "datastore_name" {
  type = string
}

variable "resource_pool" {
  type = string
}

variable "network_name" {
  type = string
}

variable "template_name" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "enable_clone" {
  description = "Zet op true wanneer vsphere_server naar vCenter wijst. Direct clonen via een standalone ESXi-host wordt niet ondersteund door de vSphere provider."
  type        = bool
  default     = false
}
