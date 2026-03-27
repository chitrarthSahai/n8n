# Tagging
tags = {
  Resource = "Test"
}

# Environment Instance Info # Fill as as you see fit, but limit to 2 characters, as this defines the resource names
taxonomy = {
  deployment_environment         = "poc"
  deployment_environment_acronym = "poc"
  environment_acronym            = "dv"
  location                       = "eastus"
  location_acronym               = "eus"
  application_acronym            = "n8n"
}

# Virtual Network Configuration
vnet_address_space                     = "10.0.0.0/16"
app_subnet_address_prefix              = "10.0.0.0/22"
private_endpoint_subnet_address_prefix = "10.0.4.0/24"
postgresql_subnet_address_prefix       = "10.0.5.0/24"

# PostgreSQL Configuration
flexibleServers_myn8npgsql_name = "pgsql"
postgresql_admin_username       = "adminuser"
postgresql_admin_password       = "3edc#EDC"
tenant_id                       = "a41367e8-54d3-456e-8732-cd2eeebb2816"
admin_user_object_id            = "c720620c-0f31-4b96-9cc9-14fae1a544ea"                              # Object ID in Tenant for an Administrator
admin_user_principal_name       = "chitrarthsahai_gmail.com#EXT#@chitrarthsahaigmail.onmicrosoft.com" # Principal Name in Tenant for an Administrator

# PostgreSQL Firewall Rules (customize as needed)
postgresql_firewall_rules = {
  "AllowAzureCloudIPs" = {
    start_ip_address = "" # Your Public IP Address
    end_ip_address   = ""
  }
  "AllowYourOffice" = {
    start_ip_address = "" # Your Public IP Address
    end_ip_address   = ""
  }
}

# Trends MCP Configuration
trends_mcp_image_tag = "latest"
trends_mcp_source_path = "../Repos/Trends-MCP"
tiktok_api_key = "235025dacemsh59f57dd3f271750p11f902jsnf8670766eb92"

# News Agent MCP Configuration
news_agent_mcp_image_tag = "latest"
news_agent_mcp_source_path = "../Repos/news-agent"

# n8n Container Image Configuration
# Specify the n8n Docker image tag to deploy
#   - Use specific version (e.g., "1.114.0") for production stability
#   - Latest available: 1.114.0 (as of 2025-09-29)
# Use the scripts/check-n8n-versions.ps1 to figure out the latest stable version
# perform terraform taint for null_resource.import_n8n_image, for reimport the image to the container registry
latest_tag = "1.116.1"