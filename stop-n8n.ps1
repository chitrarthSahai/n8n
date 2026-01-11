#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Stop n8n infrastructure (Container App and Postgres database)
.DESCRIPTION
    This script stops the Azure Container App first, then stops the PostgreSQL Flexible Server to save costs.
#>

$ErrorActionPreference = "Stop"

# Configuration - update these if your resource names differ
$ResourceGroup = "n8n-rg"
$PostgresServer = "n8n-pg-wv62"
$ContainerApp = "n8n-app-wv62"

Write-Host "==> Stopping n8n infrastructure..." -ForegroundColor Cyan

# Step 1: Stop Container App using REST API
Write-Host "[1/2] Stopping Container App: $ContainerApp..." -ForegroundColor Yellow
try {
    # Get subscription ID
    $subscriptionId = az account show --query id -o tsv
    
    # Stop the container app using the REST API
    $result = az rest --method post --url "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.App/containerApps/$ContainerApp/stop?api-version=2024-03-01" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Container App stopped successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to stop Container App" -ForegroundColor Red
        Write-Host "Error: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Failed to stop Container App: $_" -ForegroundColor Red
    exit 1
}

# Wait for container to fully stop
Write-Host "Waiting 10 seconds for container to stop..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# Step 2: Stop Postgres database
Write-Host "[2/2] Stopping PostgreSQL Flexible Server: $PostgresServer..." -ForegroundColor Yellow
try {
    $result = az postgres flexible-server stop `
        --resource-group $ResourceGroup `
        --name $PostgresServer 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ PostgreSQL server stopped successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to stop PostgreSQL server" -ForegroundColor Red
        Write-Host "Error: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Failed to stop PostgreSQL server: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n==> Shutdown complete!" -ForegroundColor Cyan
Write-Host "Container App: Stopped (no compute or environment charges)" -ForegroundColor Green
Write-Host "PostgreSQL:    Stopped (no compute charges, ~`$3-4/month for storage)" -ForegroundColor Green
Write-Host "`nNote: PostgreSQL will auto-start after 7 days. Use start-n8n.ps1 to restart manually." -ForegroundColor Gray
