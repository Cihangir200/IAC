variable "project_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "datastore_name" {
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

variable "admin_password" {
  description = "Optioneel tijdelijk wachtwoord voor console/SSH login op de ESXi guest. Zet dit alleen in terraform.tfvars, nooit in Git."
  type        = string
  sensitive   = true
  default     = ""
}
