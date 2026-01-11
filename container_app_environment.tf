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

# Container App Environment Storage removed - using Postgres instead