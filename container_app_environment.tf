# Container App Environment
resource "azurerm_container_app_environment" "n8n_env" {
  name                = "${var.app_name}-env"
  location            = azurerm_resource_group.rg_n8n.location
  resource_group_name = azurerm_resource_group.rg_n8n.name

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  tags = var.tags
}

# Azure File Storage for Container App
resource "azurerm_container_app_environment_storage" "n8n_storage" {
  name                         = "n8n-storage"
  container_app_environment_id = azurerm_container_app_environment.n8n_env.id
  account_name                 = azurerm_storage_account.n8n_storage.name
  share_name                   = azurerm_storage_share.n8n_share.name
  access_key                   = azurerm_storage_account.n8n_storage.primary_access_key
  access_mode                  = "ReadWrite"

  depends_on = [
    azurerm_storage_share.n8n_share,
    azurerm_storage_account.n8n_storage
  ]
}