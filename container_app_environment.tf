# Log Analytics Workspace for Container App Environment
resource "azurerm_log_analytics_workspace" "container_apps_workspace" {
  name                = "law-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
  location            = azurerm_resource_group.rg_n8n.location
  resource_group_name = azurerm_resource_group.rg_n8n.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

# Container App Environment with Workload Profiles for Private Endpoint Support
resource "azurerm_container_app_environment" "n8n_env" {
  name                               = "caenv-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
  location                           = azurerm_resource_group.rg_n8n.location
  resource_group_name                = azurerm_resource_group.rg_n8n.name
  log_analytics_workspace_id         = azurerm_log_analytics_workspace.container_apps_workspace.id
  infrastructure_resource_group_name = "ME_caenv-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}_${azurerm_resource_group.rg_n8n.name}_${azurerm_resource_group.rg_n8n.location}"

  # VNet Integration
  infrastructure_subnet_id       = azurerm_subnet.subnet_n8n_app.id
  internal_load_balancer_enabled = false
  zone_redundancy_enabled        = false

  # Workload Profile - Required for Private Endpoint support
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 0
    minimum_count         = 0
  }

  tags = var.tags
}

# Note: Workload Profiles enabled to support private endpoints
# The Container App Environment now supports private endpoints with VNet integration