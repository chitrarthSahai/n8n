# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgresql_server" {
  name                          = "db-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
  resource_group_name           = azurerm_resource_group.rg_n8n.name
  location                      = "eastus2"
  version                       = "16"
  delegated_subnet_id           = null
  private_dns_zone_id           = null
  public_network_access_enabled = false

  administrator_login    = var.postgresql_admin_username
  administrator_password = var.postgresql_admin_password
  zone                   = "3"

  storage_mb   = 131072 # 128 GB
  storage_tier = "P10"

  sku_name = "B_Standard_B1ms"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = var.tenant_id
  }

  tags = var.tags
}

# PostgreSQL Flexible Server Administrator
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "postgresql_admin" {
  server_name         = azurerm_postgresql_flexible_server.postgresql_server.name
  resource_group_name = azurerm_resource_group.rg_n8n.name
  tenant_id           = var.tenant_id
  object_id           = var.admin_user_object_id
  principal_name      = var.admin_user_principal_name
  principal_type      = "User"

  lifecycle {
    ignore_changes = [principal_name]
  }
}

# PostgreSQL Databases
resource "azurerm_postgresql_flexible_server_database" "n8n_database" {
  name      = "n8n"
  server_id = azurerm_postgresql_flexible_server.postgresql_server.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

# PostgreSQL Firewall Rules
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AllowAllAzureServicesAndResourcesWithinAzureIps"
  server_id        = azurerm_postgresql_flexible_server.postgresql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# PostgreSQL Private Endpoint
resource "azurerm_private_endpoint" "postgresql_private_endpoint" {
  name                = "pe-${var.flexibleServers_myn8npgsql_name}"
  location            = azurerm_resource_group.rg_n8n.location
  resource_group_name = azurerm_resource_group.rg_n8n.name
  subnet_id           = azurerm_subnet.subnet_n8n_private_endpoints.id

  private_service_connection {
    name                           = "psc-${var.flexibleServers_myn8npgsql_name}"
    private_connection_resource_id = azurerm_postgresql_flexible_server.postgresql_server.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdz-group-${var.flexibleServers_myn8npgsql_name}"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgresql.id]
  }

  tags = var.tags

  depends_on = [azurerm_postgresql_flexible_server.postgresql_server]
}