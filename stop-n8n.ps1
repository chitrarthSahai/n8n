Write-Host "Stopping n8n infrastructure..." -ForegroundColor Cyan

# 1. Stop Container App
Write-Host "`n1. Stopping Container App..." -ForegroundColor Yellow
$subscriptionId = "2c27d2a3-d8ff-483e-8d3e-74d599e1e421"
az rest --method post --url "/subscriptions/$subscriptionId/resourceGroups/n8n-rg/providers/Microsoft.App/containerApps/n8n-app-wv62/stop?api-version=2024-03-01"

Write-Host "`nWaiting 10 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 2. Stop PostgreSQL
Write-Host "`n2. Stopping PostgreSQL..." -ForegroundColor Yellow
az postgres flexible-server stop --resource-group n8n-rg --name n8n-pg-wv62

Write-Host "`nn8n infrastructure stopped successfully!" -ForegroundColor Green
Write-Host "Note: PostgreSQL will auto-start after 7 days when stopped." -ForegroundColor Yellow
