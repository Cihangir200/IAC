variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "c064671c-8f74-4fec-b088-b53c568245eb"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "s1187594"
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "West Europe"
}

variable "ssh_key_name" {
  description = "Name of the Azure SSH public key"
  type        = string
  default     = "skylab"
}
