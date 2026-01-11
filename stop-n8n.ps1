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

# Step 1: Stop Container App (scale to 0 replicas)
Write-Host "[1/2] Stopping Container App: $ContainerApp..." -ForegroundColor Yellow
try {
    az containerapp update `
        --resource-group $ResourceGroup `
        --name $ContainerApp `
        --min-replicas 0 `
        --max-replicas 0 `
        --output none
    Write-Host "✓ Container App stopped successfully" -ForegroundColor Green
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
    az postgres flexible-server stop `
        --resource-group $ResourceGroup `
        --name $PostgresServer `
        --output none
    Write-Host "✓ PostgreSQL server stopped successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to stop PostgreSQL server: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n==> Shutdown complete!" -ForegroundColor Cyan
Write-Host "Note: Storage and backup costs continue while the server is stopped (~`$3-4/month)" -ForegroundColor Gray
