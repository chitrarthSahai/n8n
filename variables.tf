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

# Optional static encryption key for n8n. If empty, a random key is generated.
variable "n8n_encryption_key" {
  type        = string
  description = "Optional stable encryption key for n8n. If empty, Terraform generates one."
  default     = ""
}

# Postgres configuration (used when DB_TYPE=postgresdb)
variable "pg_admin_user" {
  type        = string
  description = "Postgres admin username"
  default     = "n8nadmin"
}

variable "pg_admin_password" {
  type        = string
  description = "Postgres admin password. If empty, Terraform generates one."
  default     = ""
  sensitive   = true
}

variable "pg_database_name" {
  type        = string
  description = "Postgres database name"
  default     = "n8ndb"
}

variable "pg_version" {
  type        = string
  description = "Postgres version"
  default     = "16"
}

variable "pg_sku_name" {
  type        = string
  description = "Postgres SKU (e.g., B_Standard_B1ms for low cost)"
  default     = "B_Standard_B1ms"
}

variable "pg_storage_mb" {
  type        = number
  description = "Postgres storage in MB"
  default     = 32768
}

variable "pg_backup_retention_days" {
  type        = number
  description = "Backup retention days for Postgres"
  default     = 7
}

