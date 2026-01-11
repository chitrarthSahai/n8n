# Simple application naming
variable "app_name" {
  type        = string
  description = "Application name for resource naming (e.g., 'n8n')"
}

variable "location" {
  type        = string
  description = "Azure location for resources (e.g., 'eastus', 'westeurope')"
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags for all resources to be deployed."
}

# Virtual Network Configuration
variable "vnet_address_space" {
  type        = string
  description = "The address space for the virtual network in CIDR notation"
  default     = "10.0.0.0/16"
}

variable "app_subnet_address_prefix" {
  type        = string
  description = "The address prefix for the application subnet in CIDR notation"
  default     = "10.0.1.0/24"
}

# n8n Configuration
variable "latest_tag" {
  type        = string
  description = "The Docker image tag for n8n container"
  default     = "latest"
}

