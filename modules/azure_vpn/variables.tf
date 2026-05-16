variable "project_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "gateway_subnet_id" {
  type = string
}

variable "azure_gateway_pip_name" {
  type = string
}

variable "onprem_cidr" {
  type = string
}

variable "onprem_vpn_public_ip" {
  type = string
}

variable "vpn_shared_key" {
  type      = string
  sensitive = true
}

