# Virtual Network for n8n application
resource "azurerm_virtual_network" "vnet_n8n" {
  name                = "${var.app_name}-vnet"
  location            = azurerm_resource_group.rg_n8n.location
  resource_group_name = azurerm_resource_group.rg_n8n.name
  address_space       = [var.vnet_address_space]

  tags = var.tags
}

# Subnet for n8n application
resource "azurerm_subnet" "subnet_n8n_app" {
  name                 = "${var.app_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg_n8n.name
  virtual_network_name = azurerm_virtual_network.vnet_n8n.name
  address_prefixes     = [var.app_subnet_address_prefix]
}

