# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg_n8n.name

  tags = var.tags
}

# Private DNS Zone for PostgreSQL Flexible Server
resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg_n8n.name

  tags = var.tags
}

# Private DNS Zone for Container App Environment
resource "azurerm_private_dns_zone" "container_app_env" {
  name                = "privatelink.azurecontainerapps.io"
  resource_group_name = azurerm_resource_group.rg_n8n.name

  tags = var.tags
}

# Private DNS Zone for Container Registry - REMOVED
# Developer SKU does not support private endpoints

# Virtual Network Links for Key Vault Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_link" {
  name                  = "keyvault-dns-link"
  resource_group_name   = azurerm_resource_group.rg_n8n.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.vnet_n8n.id
  registration_enabled  = false

  tags = var.tags
}

# Virtual Network Links for PostgreSQL Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_link" {
  name                  = "postgresql-dns-link"
  resource_group_name   = azurerm_resource_group.rg_n8n.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.vnet_n8n.id
  registration_enabled  = false

  tags = var.tags
}

# Virtual Network Links for Container App Environment Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "container_app_env_link" {
  name                  = "container-app-env-dns-link"
  resource_group_name   = azurerm_resource_group.rg_n8n.name
  private_dns_zone_name = azurerm_private_dns_zone.container_app_env.name
  virtual_network_id    = azurerm_virtual_network.vnet_n8n.id
  registration_enabled  = false

  tags = var.tags
}

# Virtual Network Links for Container Registry Private DNS Zone - REMOVED
# Developer SKU does not support private endpoints