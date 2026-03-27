# n8n Container App
resource "azurerm_container_app" "n8n_app" {
  name                         = "ca-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
  container_app_environment_id = azurerm_container_app_environment.n8n_env.id
  resource_group_name          = azurerm_resource_group.rg_n8n.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_app_identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr_n8n.login_server
    identity = azurerm_user_assigned_identity.container_app_identity.id
  }

  template {
    min_replicas = 1
    max_replicas = 3

    container {
      name   = "n8n"
      image  = "${azurerm_container_registry.acr_n8n.login_server}/n8n:${var.latest_tag}"
      cpu    = 1.0
      memory = "2Gi"

      # n8n Configuration Environment Variables
      env {
        name  = "DB_TYPE"
        value = "postgresdb"
      }

      env {
        name  = "DB_POSTGRESDB_HOST"
        value = azurerm_postgresql_flexible_server.postgresql_server.fqdn
      }

      env {
        name  = "DB_POSTGRESDB_PORT"
        value = "5432"
      }

      env {
        name  = "DB_POSTGRESDB_DATABASE"
        value = azurerm_postgresql_flexible_server_database.n8n_database.name
      }

      env {
        name  = "DB_POSTGRESDB_USER"
        value = var.postgresql_admin_username
      }

      env {
        name        = "DB_POSTGRESDB_PASSWORD"
        secret_name = "postgres-password"
      }

      env {
        name  = "N8N_HOST"
        value = "ca-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}.${azurerm_container_app_environment.n8n_env.default_domain}"
      }

      env {
        name  = "N8N_PORT"
        value = "5678"
      }

      env {
        name  = "N8N_PROTOCOL"
        value = "https"
      }

      env {
        name = "WEBHOOK_URL"
        #value = "https://${module.resource_name.n8n.container_app}.${azurerm_container_app_environment.n8n_env.default_domain}"
        value = "https://ca-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}.${azurerm_container_app_environment.n8n_env.default_domain}"
      }

      # Security and Performance
      env {
        name  = "N8N_SECURE_COOKIE"
        value = "true"
      }

      env {
        name  = "N8N_PROXY_HOPS"
        value = "1"
      }

      env {
        name  = "N8N_EDITOR_BASE_URL"
        value = "https://ca-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}.${azurerm_container_app_environment.n8n_env.default_domain}"
      }

      env {
        name  = "N8N_METRICS"
        value = "true"
      }

      env {
        name  = "N8N_BLOCK_ENV_ACCESS_IN_NODE"
        value = "false"
      }

      env {
        name  = "N8N_RUNNERS_ENABLED"
        value = "true"
      }

      env {
        name  = "EXECUTIONS_MODE"
        value = "regular"
      }

      # Logging
      env {
        name  = "N8N_LOG_LEVEL"
        value = "info"
      }

      env {
        name  = "N8N_LOG_OUTPUT"
        value = "console"
      }

      env {
        name        = "N8N_ENCRYPTION_KEY"
        secret_name = "n8n-encryption-key"
      }

      env {
        name  = "DB_POSTGRESDB_CONNECTION_TIMEOUT"
        value = "600000"
      }

      env {
        name  = "DB_POSTGRESDB_SSL"
        value = "true"
      }

      env {
        name  = "DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED"
        value = "false"
      }

      env {
        name  = "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS"
        value = "true"
      }
    }
  }

  secret {
    name                = "postgres-password"
    key_vault_secret_id = azurerm_key_vault_secret.postgresql_admin_password.versionless_id
    identity            = azurerm_user_assigned_identity.container_app_identity.id
  }

  secret {
    name                = "n8n-encryption-key"
    key_vault_secret_id = azurerm_key_vault_secret.n8n_encryption_key.versionless_id
    identity            = azurerm_user_assigned_identity.container_app_identity.id
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 5678
    transport                  = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_postgresql_flexible_server.postgresql_server,
    azurerm_postgresql_flexible_server_database.n8n_database,
    azurerm_key_vault_secret.postgresql_admin_password,
    azurerm_key_vault_secret.n8n_encryption_key,
    azurerm_key_vault_secret.tiktok_api_key,
    null_resource.import_n8n_image,
    null_resource.build_and_push_trends_mcp_image,
    azurerm_private_endpoint.keyvault_private_endpoint
  ]
}

# Trends-MCP Container App (separate app for external access on port 8999)
# Note: Added as separate app since Azure Container Apps only support one ingress per app
# The n8n app uses port 5678, so Trends-MCP needs its own app for port 8999
resource "azurerm_container_app" "trends_mcp_app" {
  name                         = "ca-trends-mcp-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
  container_app_environment_id = azurerm_container_app_environment.n8n_env.id
  resource_group_name          = azurerm_resource_group.rg_n8n.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_app_identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr_n8n.login_server
    identity = azurerm_user_assigned_identity.container_app_identity.id
  }

  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "trends-mcp"
      image  = "${azurerm_container_registry.acr_n8n.login_server}/trends-mcp:${var.trends_mcp_image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name        = "tiktok"
        secret_name = "tiktok-api-key"
      }
    }
  }

  secret {
    name                = "tiktok-api-key"
    key_vault_secret_id = azurerm_key_vault_secret.tiktok_api_key.versionless_id
    identity            = azurerm_user_assigned_identity.container_app_identity.id
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8999
    transport                  = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_key_vault_secret.tiktok_api_key,
    null_resource.build_and_push_trends_mcp_image,
    azurerm_private_endpoint.keyvault_private_endpoint
  ]
}

# News Agent MCP Container App (separate app for external access on port 7999)
# Note: Added as separate app since Azure Container Apps only support one ingress per app
# The n8n app uses port 5678, so Trends-MCP needs its own app for port 8999
resource "azurerm_container_app" "news_agent_mcp_app" {
  name                         = "ca-news-agent-mcp-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
  container_app_environment_id = azurerm_container_app_environment.n8n_env.id
  resource_group_name          = azurerm_resource_group.rg_n8n.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_app_identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr_n8n.login_server
    identity = azurerm_user_assigned_identity.container_app_identity.id
  }

  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "news-agent-mcp"
      image  = "${azurerm_container_registry.acr_n8n.login_server}/news-agent-mcp:${var.news_agent_mcp_image_tag}"
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 7999
    transport                  = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.tags

  depends_on = [
    null_resource.build_and_push_news_agent_mcp_image,
    azurerm_private_endpoint.keyvault_private_endpoint
  ]
}
