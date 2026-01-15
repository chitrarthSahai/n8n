Write-Host "Starting n8n infrastructure..." -ForegroundColor Cyan

# 1. Start PostgreSQL
Write-Host "`n1. Starting PostgreSQL..." -ForegroundColor Yellow
az postgres flexible-server start --resource-group n8n-rg --name n8n-pg-wv62

Write-Host "`nWaiting 15 seconds for PostgreSQL to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# 2. Start Container App
Write-Host "`n2. Starting Container App..." -ForegroundColor Yellow
$subscriptionId = "2c27d2a3-d8ff-483e-8d3e-74d599e1e421"
az rest --method post --url "/subscriptions/$subscriptionId/resourceGroups/n8n-rg/providers/Microsoft.App/containerApps/n8n-app-wv62/start?api-version=2024-03-01"

Write-Host "`nWaiting 15 seconds for Container App to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# 3. Get app URL
Write-Host "`n3. Getting app URL..." -ForegroundColor Yellow
$url = az containerapp show --resource-group n8n-rg --name n8n-app-wv62 --query 'properties.configuration.ingress.fqdn' --output tsv

if ($url) {
    Write-Host "`nn8n is ready at: https://$url" -ForegroundColor Green
} else {
    Write-Host "`nFailed to get URL. Check Azure Portal." -ForegroundColor Red
}
