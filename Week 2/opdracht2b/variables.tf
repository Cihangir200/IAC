variable "subscription_id" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"   # ⚡ gebruik toegestane regio (bv. westeurope)
}

variable "public_key_path" {
  type        = string
}

variable "ssh_key_name" {
  type    = string
  default = "skylab"
}

variable "vm_count" {
  type    = number
  default = 2
}

variable "vm_size" {
  type    = string
  default = "Standard_DS1_v2"
}
