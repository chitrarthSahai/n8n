# Virtual Network for n8n application
resource "azurerm_virtual_network" "vnet_n8n" {
  name                = "vnet-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}"
  location            = azurerm_resource_group.rg_n8n.location
  resource_group_name = azurerm_resource_group.rg_n8n.name
  address_space       = [var.vnet_address_space]

  tags = var.tags
}

# Subnet for n8n application
resource "azurerm_subnet" "subnet_n8n_app" {
  name                 = "subnet-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}-app"
  resource_group_name  = azurerm_resource_group.rg_n8n.name
  virtual_network_name = azurerm_virtual_network.vnet_n8n.name
  address_prefixes     = [var.app_subnet_address_prefix]

  # Delegation required for Container App Environment with Workload Profiles
  delegation {
    name = "Microsoft.App.environments"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Subnet for private endpoints
resource "azurerm_subnet" "subnet_n8n_private_endpoints" {
  name                 = "subnet-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}-pe"
  resource_group_name  = azurerm_resource_group.rg_n8n.name
  virtual_network_name = azurerm_virtual_network.vnet_n8n.name
  address_prefixes     = [var.private_endpoint_subnet_address_prefix]

  # Disable private endpoint network policies
  private_endpoint_network_policies = "Disabled"
}



# Network Security Group for application subnet
resource "azurerm_network_security_group" "nsg_n8n_app" {
  name                = "nsg-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}-app"
  location            = azurerm_resource_group.rg_n8n.location
  resource_group_name = azurerm_resource_group.rg_n8n.name

  # Allow HTTPS inbound from specific IPs
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.tags
}

# Associate NSG with application subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association_app" {
  subnet_id                 = azurerm_subnet.subnet_n8n_app.id
  network_security_group_id = azurerm_network_security_group.nsg_n8n_app.id
}

# Network Security Group for private endpoints subnet
resource "azurerm_network_security_group" "nsg_n8n_private_endpoints" {
  name                = "nsg-${var.taxonomy.application_acronym}-${var.taxonomy.deployment_environment_acronym}-${var.taxonomy.location_acronym}-pe"
  location            = azurerm_resource_group.rg_n8n.location
  resource_group_name = azurerm_resource_group.rg_n8n.name

  # Allow inbound from app subnet to private endpoints
  security_rule {
    name                       = "AllowAppSubnetInbound"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.app_subnet_address_prefix
    destination_address_prefix = "*"
  }



  tags = var.tags
}

# Associate NSG with private endpoints subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association_private_endpoints" {
  subnet_id                 = azurerm_subnet.subnet_n8n_private_endpoints.id
  network_security_group_id = azurerm_network_security_group.nsg_n8n_private_endpoints.id
}

