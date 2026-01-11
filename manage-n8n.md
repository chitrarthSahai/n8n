# Managing n8n Infrastructure

## Start n8n

```bash
# 1. Start PostgreSQL
az postgres flexible-server start --resource-group n8n-rg --name n8n-pg-wv62

# 2. Start Container App (requires subscription ID)
az rest --method post --url "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/n8n-rg/providers/Microsoft.App/containerApps/n8n-app-wv62/start?api-version=2024-03-01"

# 3. Get app URL
az containerapp show --resource-group n8n-rg --name n8n-app-wv62 --query 'properties.configuration.ingress.fqdn' --output tsv
```

### PowerShell Version

```powershell
# 1. Start PostgreSQL
az postgres flexible-server start --resource-group n8n-rg --name n8n-pg-wv62

# 2. Start Container App
$subscriptionId = az account show --query id -o tsv
az rest --method post --url "/subscriptions/$subscriptionId/resourceGroups/n8n-rg/providers/Microsoft.App/containerApps/n8n-app-wv62/start?api-version=2024-03-01"

# 3. Get app URL
az containerapp show --resource-group n8n-rg --name n8n-app-wv62 --query 'properties.configuration.ingress.fqdn' --output tsv
```

## Stop n8n

```bash
# 1. Stop Container App (requires subscription ID)
az rest --method post --url "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/n8n-rg/providers/Microsoft.App/containerApps/n8n-app-wv62/stop?api-version=2024-03-01"

# 2. Stop PostgreSQL
az postgres flexible-server stop --resource-group n8n-rg --name n8n-pg-wv62
```

### PowerShell Version

```powershell
# 1. Stop Container App
$subscriptionId = az account show --query id -o tsv
az rest --method post --url "/subscriptions/$subscriptionId/resourceGroups/n8n-rg/providers/Microsoft.App/containerApps/n8n-app-wv62/stop?api-version=2024-03-01"

# 2. Stop PostgreSQL
az postgres flexible-server stop --resource-group n8n-rg --name n8n-pg-wv62
```

## Notes

- Wait 15-20 seconds after starting PostgreSQL before starting the Container App
- Wait 10-20 seconds after starting the Container App for it to be fully ready
- PostgreSQL auto-starts after 7 days when stopped
- When stopped: Container App has no compute charges, PostgreSQL only charges ~$3-4/month for storage
