# Azure Container Registry
resource "azurerm_container_registry" "acr_n8n" {
  name                = "creg${var.taxonomy.application_acronym}${var.taxonomy.deployment_environment_acronym}${var.taxonomy.location_acronym}"
  resource_group_name = azurerm_resource_group.rg_n8n.name
  location            = azurerm_resource_group.rg_n8n.location
  sku                 = "Basic" # Changed from Premium to Basic for cost optimization
  admin_enabled       = false

  # Basic SKU - Public access enabled (no network rules supported)
  public_network_access_enabled = true

  tags = var.tags
}

# Private Endpoint for Container Registry - REMOVED
# Developer SKU does not support private endpoints

# Role assignment for Container Registry (if needed for container apps)
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr_n8n.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_app_identity.principal_id

  depends_on = [azurerm_user_assigned_identity.container_app_identity]
}

# User Assigned Identity for Container Apps (to pull from ACR)
resource "azurerm_user_assigned_identity" "container_app_identity" {
  name                = "id-ca-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}-containerapp"
  location            = azurerm_resource_group.rg_n8n.location
  resource_group_name = azurerm_resource_group.rg_n8n.name

  tags = var.tags
}

# Null resource to import n8n image from Docker Hub to ACR
resource "null_resource" "import_n8n_image" {
  depends_on = [azurerm_container_registry.acr_n8n]

  provisioner "local-exec" {
    command = <<-EOT
      az acr import --name ${azurerm_container_registry.acr_n8n.name} --source docker.io/n8nio/n8n:${var.latest_tag} --image n8n:${var.latest_tag} --resource-group ${azurerm_resource_group.rg_n8n.name}
    EOT
  }

  # Trigger re-import when ACR changes
  triggers = {
    acr_id = azurerm_container_registry.acr_n8n.id
  }
}

# Null resource to build and push Trends-MCP image to ACR using ACR Tasks (cloud build)
resource "null_resource" "build_and_push_trends_mcp_image" {
  depends_on = [azurerm_container_registry.acr_n8n]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
      $sourcePath = Resolve-Path "${var.trends_mcp_source_path}";
      az acr build --registry ${azurerm_container_registry.acr_n8n.name} --image trends-mcp:${var.trends_mcp_image_tag} --file "$sourcePath\Dockerfile" "$sourcePath" --no-logs;
      if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    EOT
  }

  # Trigger rebuild when ACR changes or source path changes
  triggers = {
    acr_id      = azurerm_container_registry.acr_n8n.id
    source_path = var.trends_mcp_source_path
    image_tag   = var.trends_mcp_image_tag
    # File hashes - using try() to handle cases where files might not exist
    dockerfile_hash   = try(filemd5("${var.trends_mcp_source_path}/Dockerfile"), "unknown")
    requirements_hash = try(filemd5("${var.trends_mcp_source_path}/requirements.txt"), "unknown")
    server_hash       = try(filemd5("${var.trends_mcp_source_path}/src/server.py"), "unknown")
  }
}

# Null resource to build and push Trends-MCP image to ACR using ACR Tasks (cloud build)
resource "null_resource" "build_and_push_news_agent_mcp_image" {
  depends_on = [azurerm_container_registry.acr_n8n]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
      $sourcePath = Resolve-Path "${var.news_agent_mcp_source_path}";
      az acr build --registry ${azurerm_container_registry.acr_n8n.name} --image news-agent-mcp:${var.news_agent_mcp_image_tag} --file "$sourcePath\Dockerfile" "$sourcePath" --no-logs;
      if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    EOT
  }

  # Trigger rebuild when ACR changes or source path changes
  triggers = {
    acr_id      = azurerm_container_registry.acr_n8n.id
    source_path = var.news_agent_mcp_source_path
    image_tag   = var.news_agent_mcp_image_tag
    # File hashes - using try() to handle cases where files might not exist
    dockerfile_hash   = try(filemd5("${var.news_agent_mcp_source_path}/Dockerfile"), "unknown")
    requirements_hash = try(filemd5("${var.news_agent_mcp_source_path}/requirements.txt"), "unknown")
    server_hash       = try(filemd5("${var.news_agent_mcp_source_path}/mcp_servers/server.py"), "unknown")
  }
}