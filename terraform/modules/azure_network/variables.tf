variable "project_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vnet_cidr" {
  type = string
}

variable "workload_subnet_cidr" {
  type = string
}
