# Get current client configuration
data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "n8n_keyvault" {
  name                          = "kvl-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
  location                      = azurerm_resource_group.rg_n8n.location
  resource_group_name           = azurerm_resource_group.rg_n8n.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  public_network_access_enabled = true

  # Access policy for current user/service principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore"
    ]
  }

  # Access policy for Container App managed identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.container_app_identity.principal_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }

  tags = var.tags
}

# Key Vault Private Endpoint
resource "azurerm_private_endpoint" "keyvault_private_endpoint" {
  name                = "pe-kvl-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
  location            = azurerm_resource_group.rg_n8n.location
  resource_group_name = azurerm_resource_group.rg_n8n.name
  subnet_id           = azurerm_subnet.subnet_n8n_private_endpoints.id

  private_service_connection {
    name                           = "psc-kvl-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
    private_connection_resource_id = azurerm_key_vault.n8n_keyvault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdz-group-kvl-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]
  }

  tags = var.tags

  depends_on = [azurerm_key_vault.n8n_keyvault]
}

# Key Vault Secret for PostgreSQL Password
resource "azurerm_key_vault_secret" "postgresql_admin_password" {
  name         = "postgresql-admin-password"
  value        = var.postgresql_admin_password
  key_vault_id = azurerm_key_vault.n8n_keyvault.id

  depends_on = [azurerm_key_vault.n8n_keyvault]
}

# Generate random encryption key for n8n
resource "random_password" "n8n_encryption_key" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Key Vault Secret for n8n Encryption Key
resource "azurerm_key_vault_secret" "n8n_encryption_key" {
  name         = "n8n-encryption-key"
  value        = random_password.n8n_encryption_key.result
  key_vault_id = azurerm_key_vault.n8n_keyvault.id

  depends_on = [azurerm_key_vault.n8n_keyvault]
}

# Key Vault Secret for TikTok API Key
resource "azurerm_key_vault_secret" "tiktok_api_key" {
  name         = "tiktok-api-key"
  value        = var.tiktok_api_key != "" ? var.tiktok_api_key : "placeholder-key"
  key_vault_id = azurerm_key_vault.n8n_keyvault.id

  depends_on = [azurerm_key_vault.n8n_keyvault]
}