# Tagging
variable "tags" {
  type        = map(string)
  description = "Tags for all resources to be deployed."
}

# Taxonomy
variable "taxonomy" {
  type = object({
    deployment_environment         = string
    deployment_environment_acronym = string
    environment_acronym            = string
    location                       = string
    location_acronym               = string
    application_acronym            = string
  })
  description = <<DESCRIPTION
    Defines the Taxonomy of the Regional Deployment Environment (Hub).
    object({
        deployment_environment              = required - string         The regional deployment environment 'go-amer', 'go-emea', 'go-apac' etc.
        deployment_environment_acronym      = required - string         The regional deployment acronym 'amer', 'emea', 'apac' etc.
        environment_acronym                 = required - string         The environment acronym 'dv', 'qa', 'ua', 'pd' etc.
        location                            = required - string         The Azure location 'eastus', 'westeurope', 'australiaeast' etc.
        location_acronym                    = required - string         The Azure location acronym 'use', 'weu', 'aue' etc.
        application_acronym                 = required - string         The application platform acronym 'wb' - Workbench, 'dm' - Digital Matrix.
      })
   DESCRIPTION
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

variable "private_endpoint_subnet_address_prefix" {
  type        = string
  description = "The address prefix for the private endpoints subnet in CIDR notation"
  default     = "10.0.2.0/24"
}

variable "postgresql_subnet_address_prefix" {
  type        = string
  description = "The address prefix for the PostgreSQL delegated subnet in CIDR notation"
  default     = "10.0.5.0/24"
}

# PostgreSQL Configuration
variable "flexibleServers_myn8npgsql_name" {
  type        = string
  description = "The name of the PostgreSQL Flexible Server"
}

variable "postgresql_admin_username" {
  type        = string
  description = "The administrator username for the PostgreSQL server"
  default     = "n8nadmin"
}

variable "postgresql_admin_password" {
  type        = string
  description = "The administrator password for the PostgreSQL server"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "The Azure tenant ID"
}

variable "admin_user_object_id" {
  type        = string
  description = "The object ID of the admin user for PostgreSQL AAD authentication"
}

variable "admin_user_principal_name" {
  type        = string
  description = "The principal name of the admin user for PostgreSQL AAD authentication"
}

variable "postgresql_firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  description = "Map of firewall rules for PostgreSQL server"
  default     = {}
}

variable "latest_tag" {
  type        = string
  description = "The Docker image tag for n8n container"
  default     = "latest"
}

variable "trends_mcp_image_tag" {
  type        = string
  description = "The Docker image tag for Trends-MCP container"
  default     = "latest"
}

variable "trends_mcp_source_path" {
  type        = string
  description = "Path to the Trends-MCP source directory for building Docker image"
  default     = "../Repos/Trends-MCP"
}

variable "tiktok_api_key" {
  type        = string
  description = "TikTok RapidAPI key for Trends-MCP service"
  default     = ""
  sensitive   = true
}

variable "news_agent_mcp_image_tag" {
  type        = string
  description = "The Docker image tag for News Agent MCP container"
  default     = "latest"
}

variable "news_agent_mcp_source_path" {
  type        = string
  description = "Path to the News Agent MCP source directory for building Docker image"
  default     = "../Repos/news-agent"
}
