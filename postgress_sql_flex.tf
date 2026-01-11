locals {
	pg_admin_password_effective = coalesce(var.pg_admin_password, random_password.n8n_pg_admin_password.result)
}

resource "random_password" "n8n_pg_admin_password" {
	length  = 24
	special = true
}

resource "azurerm_postgresql_flexible_server" "n8n_pg" {
	name                = "${var.app_name}-pg-${random_string.unique_suffix.result}"
	location            = azurerm_resource_group.rg_n8n.location
	resource_group_name = azurerm_resource_group.rg_n8n.name
	administrator_login = var.pg_admin_user
	administrator_password = local.pg_admin_password_effective
	sku_name               = var.pg_sku_name
	storage_mb             = var.pg_storage_mb
	version                = var.pg_version

	public_network_access_enabled = true

	authentication {
		password_auth_enabled       = true
		active_directory_auth_enabled = false
	}

	backup_retention_days        = var.pg_backup_retention_days
	geo_redundant_backup_enabled = false

	# HA disabled by omitting high_availability block

	maintenance_window {
		day_of_week  = 0
		start_hour   = 0
		start_minute = 0
	}

	lifecycle {
		ignore_changes = [maintenance_window, zone]
	}

	tags = var.tags
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
	name             = "allow-all"
	server_id        = azurerm_postgresql_flexible_server.n8n_pg.id
	start_ip_address = "0.0.0.0"
	end_ip_address   = "255.255.255.255"
}

resource "azurerm_postgresql_flexible_server_database" "n8n_db" {
	name      = var.pg_database_name
	server_id = azurerm_postgresql_flexible_server.n8n_pg.id
	collation = "en_US.utf8"
	charset   = "UTF8"
}

