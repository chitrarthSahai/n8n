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

  template {
    min_replicas = 0
    max_replicas = 1

    volume {
      name         = "n8n-data"
      storage_name = "n8n-storage"
      storage_type = "AzureFile"
    }

    container {
      name   = "n8n"
      image  = "docker.io/n8nio/n8n:${var.latest_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      # n8n Configuration Environment Variables - SQLite (default)
      # DB_TYPE defaults to sqlite if not specified
      env {
        name  = "DB_TYPE"
        value = "sqlite"
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
        value = random_password.n8n_encryption_key.result
      }

      env {
        name  = "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS"
        value = "true"
      }

      # Volume mounts for Azure file share
      volume_mounts {
        name = "n8n-data"
        path = "/home/node/.n8n"
      }
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
    azurerm_container_app_environment_storage.n8n_storage
  ]
}
