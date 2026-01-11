# Generate random encryption key for n8n
resource "random_password" "n8n_encryption_key" {
  length  = 32
  special = true
}

# n8n Container App
resource "azurerm_container_app" "n8n_app" {
  name                         = "${var.app_name}-app-${random_string.unique_suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.n8n_env.id
  resource_group_name          = azurerm_resource_group.rg_n8n.name
  revision_mode                = "Single"
  workload_profile_name         = "Consumption"

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "n8n"
      image  = "docker.io/n8nio/n8n:${var.latest_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      # n8n Configuration Environment Variables - Postgres
      env {
        name  = "DB_TYPE"
        value = "postgresdb"
      }

      env {
        name  = "DB_POSTGRESDB_HOST"
        value = azurerm_postgresql_flexible_server.n8n_pg.fqdn
      }

      env {
        name  = "DB_POSTGRESDB_PORT"
        value = "5432"
      }

      env {
        name  = "DB_POSTGRESDB_DATABASE"
        value = var.pg_database_name
      }

      env {
        name  = "DB_POSTGRESDB_USER"
        value = var.pg_admin_user
      }

      env {
        name  = "DB_POSTGRESDB_PASSWORD"
        value = local.pg_admin_password_effective
      }

      env {
        name  = "DB_POSTGRESDB_SCHEMA"
        value = "public"
      }

      env {
        name  = "DB_POSTGRESDB_SSL_ENABLED"
        value = "true"
      }

      env {
        name  = "N8N_HOST"
        value = "https://${var.app_name}-app.${azurerm_container_app_environment.n8n_env.default_domain}"
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
        name  = "WEBHOOK_URL"
        value = "https://${var.app_name}-app.${azurerm_container_app_environment.n8n_env.default_domain}"
      }

      # Security and Performance
      env {
        name  = "N8N_SECURE_COOKIE"
        value = "true"
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
        name  = "N8N_ENCRYPTION_KEY"
        value = coalesce(var.n8n_encryption_key, random_password.n8n_encryption_key.result)
      }

      env {
        name  = "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS"
        value = "false"
      }

      # SQLite-specific tuning removed because Postgres is now used
    }
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
    azurerm_postgresql_flexible_server.n8n_pg,
    azurerm_postgresql_flexible_server_database.n8n_db
  ]
}
