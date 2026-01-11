# Generate random suffix for globally unique resource names
resource "random_string" "unique_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Azure Storage Account for n8n data persistence
resource "azurerm_storage_account" "n8n_storage" {
  name                     = "${replace(var.app_name, "-", "")}storage${random_string.unique_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg_n8n.name
  location                 = azurerm_resource_group.rg_n8n.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

# Azure File Share for n8n persistent data
resource "azurerm_storage_share" "n8n_share" {
  name                 = "n8n-data"
  storage_account_name = azurerm_storage_account.n8n_storage.name
  quota                = 5 # 5 GB quota for SQLite database and n8n configuration

  depends_on = [azurerm_storage_account.n8n_storage]
}

# Output storage credentials for container app mounting
output "storage_account_name" {
  value       = azurerm_storage_account.n8n_storage.name
  description = "The name of the storage account"
}

output "storage_account_key" {
  value       = azurerm_storage_account.n8n_storage.primary_access_key
  sensitive   = true
  description = "The primary access key for the storage account"
}

output "file_share_name" {
  value       = azurerm_storage_share.n8n_share.name
  description = "The name of the file share"
}
