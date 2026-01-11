resource "azurerm_resource_group" "rg_n8n" {
  name     = "${var.app_name}-rg"
  location = var.location
  tags     = var.tags
}