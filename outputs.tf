# Private DNS Zone Outputs
output "private_dns_zones" {
  description = "Private DNS zones for various Azure services"
  value = {
    keyvault = {
      id   = azurerm_private_dns_zone.keyvault.id
      name = azurerm_private_dns_zone.keyvault.name
    }
    postgresql = {
      id   = azurerm_private_dns_zone.postgresql.id
      name = azurerm_private_dns_zone.postgresql.name
    }
    container_app_env = {
      id   = azurerm_private_dns_zone.container_app_env.id
      name = azurerm_private_dns_zone.container_app_env.name
    }
    # container_registry = {
    #   id   = azurerm_private_dns_zone.container_registry.id
    #   name = azurerm_private_dns_zone.container_registry.name
    # }
  }
}

# Virtual Network Output (if not already defined elsewhere)
output "virtual_network" {
  description = "Virtual network information"
  value = {
    id   = azurerm_virtual_network.vnet_n8n.id
    name = azurerm_virtual_network.vnet_n8n.name
  }
}

# Subnet Outputs
output "subnets" {
  description = "Subnet information"
  value = {
    app_subnet = {
      id   = azurerm_subnet.subnet_n8n_app.id
      name = azurerm_subnet.subnet_n8n_app.name
    }
    private_endpoint_subnet = {
      id   = azurerm_subnet.subnet_n8n_private_endpoints.id
      name = azurerm_subnet.subnet_n8n_private_endpoints.name
    }
  }
}

# Container Registry Outputs
output "container_registry" {
  description = "Container registry information"
  value = {
    id           = azurerm_container_registry.acr_n8n.id
    name         = azurerm_container_registry.acr_n8n.name
    login_server = azurerm_container_registry.acr_n8n.login_server
    # private_endpoint_ip removed - Basic SKU uses public access
  }
  sensitive = false
}

# User Assigned Identity Output
output "container_app_identity" {
  description = "User assigned identity for container apps"
  value = {
    id           = azurerm_user_assigned_identity.container_app_identity.id
    principal_id = azurerm_user_assigned_identity.container_app_identity.principal_id
    client_id    = azurerm_user_assigned_identity.container_app_identity.client_id
  }
}

# Container App Environment Outputs
output "container_app_environment" {
  description = "Container App Environment information"
  value = {
    id                       = azurerm_container_app_environment.n8n_env.id
    name                     = azurerm_container_app_environment.n8n_env.name
    default_domain           = azurerm_container_app_environment.n8n_env.default_domain
    static_ip_address        = azurerm_container_app_environment.n8n_env.static_ip_address
    docker_bridge_cidr       = azurerm_container_app_environment.n8n_env.docker_bridge_cidr
    platform_reserved_cidr   = azurerm_container_app_environment.n8n_env.platform_reserved_cidr
    platform_reserved_dns_ip = azurerm_container_app_environment.n8n_env.platform_reserved_dns_ip_address
  }
}

# Log Analytics Workspace Output
output "log_analytics_workspace" {
  description = "Log Analytics Workspace information"
  value = {
    id           = azurerm_log_analytics_workspace.container_apps_workspace.id
    name         = azurerm_log_analytics_workspace.container_apps_workspace.name
    workspace_id = azurerm_log_analytics_workspace.container_apps_workspace.workspace_id
  }
  sensitive = false
}

# PostgreSQL Server Outputs
output "postgresql_server" {
  description = "PostgreSQL Flexible Server information"
  value = {
    id                    = azurerm_postgresql_flexible_server.postgresql_server.id
    name                  = azurerm_postgresql_flexible_server.postgresql_server.name
    fqdn                  = azurerm_postgresql_flexible_server.postgresql_server.fqdn
    public_access_enabled = azurerm_postgresql_flexible_server.postgresql_server.public_network_access_enabled
    private_endpoint_ip   = azurerm_private_endpoint.postgresql_private_endpoint.private_service_connection[0].private_ip_address
    database_names = [
      azurerm_postgresql_flexible_server_database.n8n_database.name
    ]
  }
  sensitive = false
}

# Key Vault Output
output "key_vault" {
  description = "Key Vault information"
  value = {
    id                  = azurerm_key_vault.n8n_keyvault.id
    name                = azurerm_key_vault.n8n_keyvault.name
    vault_uri           = azurerm_key_vault.n8n_keyvault.vault_uri
    private_endpoint_ip = azurerm_private_endpoint.keyvault_private_endpoint.private_service_connection[0].private_ip_address
    secret_names = [
      azurerm_key_vault_secret.postgresql_admin_password.name,
      azurerm_key_vault_secret.n8n_encryption_key.name,
      azurerm_key_vault_secret.tiktok_api_key.name
    ]
  }
  sensitive = false
}

# Container App Output
output "container_app" {
  description = "Container App information"
  value = {
    id                           = azurerm_container_app.n8n_app.id
    name                         = azurerm_container_app.n8n_app.name
    latest_revision_name         = azurerm_container_app.n8n_app.latest_revision_name
    latest_revision_fqdn         = azurerm_container_app.n8n_app.latest_revision_fqdn
    outbound_ip_addresses        = azurerm_container_app.n8n_app.outbound_ip_addresses
    container_app_environment_id = azurerm_container_app.n8n_app.container_app_environment_id
    # Access URLs
    internal_fqdn = "${azurerm_container_app.n8n_app.name}.${azurerm_container_app_environment.n8n_env.default_domain}"
  }
  sensitive = false
}

# Trends-MCP Container App Output
output "trends_mcp_container_app" {
  description = "Trends-MCP Container App information"
  value = {
    id                           = azurerm_container_app.trends_mcp_app.id
    name                         = azurerm_container_app.trends_mcp_app.name
    latest_revision_name         = azurerm_container_app.trends_mcp_app.latest_revision_name
    latest_revision_fqdn         = azurerm_container_app.trends_mcp_app.latest_revision_fqdn
    outbound_ip_addresses        = azurerm_container_app.trends_mcp_app.outbound_ip_addresses
    container_app_environment_id = azurerm_container_app.trends_mcp_app.container_app_environment_id
    # Access URLs
    internal_fqdn = "${azurerm_container_app.trends_mcp_app.name}.${azurerm_container_app_environment.n8n_env.default_domain}"
    external_url  = "https://${azurerm_container_app.trends_mcp_app.latest_revision_fqdn}"
  }
  sensitive = false
}