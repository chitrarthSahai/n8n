# Disable the container app 'ca-n8n-poc-eus'
az containerapp update --name ca-n8n-poc-eus --resource-group rgp-n8n-poc-eus --set configuration.active=false

# Disable the container app 'ca-news-agent-mcp-n8n-poc-eus'
az containerapp update --name ca-news-agent-mcp-n8n-poc-eus --resource-group rgp-n8n-poc-eus --set configuration.active=false

# Disable the container app 'ca-trends-mcp-n8n-poc-eus'
az containerapp update --name ca-trends-mcp-n8n-poc-eus --resource-group rgp-n8n-poc-eus --set configuration.active=false

# Stop the PostgreSQL flexible server 'db-n8n-poc-eus'
az postgres flexible-server stop --resource-group rgp-n8n-poc-eus --name db-n8n-poc-eus
