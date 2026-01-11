#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Start n8n infrastructure (Postgres database and Container App)
.DESCRIPTION
    This script starts the Azure PostgreSQL Flexible Server first, then starts the Container App.
#>

$ErrorActionPreference = "Stop"

# Configuration - update these if your resource names differ
$ResourceGroup = "n8n-rg"
$PostgresServer = "n8n-pg-wv62"
$ContainerApp = "n8n-app-wv62"

Write-Host "==> Starting n8n infrastructure..." -ForegroundColor Cyan

# Step 1: Start Postgres database
Write-Host "[1/2] Starting PostgreSQL Flexible Server: $PostgresServer..." -ForegroundColor Yellow
try {
    az postgres flexible-server start `
        --resource-group $ResourceGroup `
        --name $PostgresServer `
        --output none
    Write-Host "✓ PostgreSQL server started successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to start PostgreSQL server: $_" -ForegroundColor Red
    exit 1
}

# Wait for database to be fully ready
Write-Host "Waiting 15 seconds for database to be fully ready..." -ForegroundColor Gray
Start-Sleep -Seconds 15

# Step 2: Start Container App (scale to 1 replica)
Write-Host "[2/2] Starting Container App: $ContainerApp..." -ForegroundColor Yellow
try {
    az containerapp update `
        --resource-group $ResourceGroup `
        --name $ContainerApp `
        --min-replicas 0 `
        --max-replicas 1 `
        --output none
    Write-Host "✓ Container App started successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to start Container App: $_" -ForegroundColor Red
    exit 1
}

# Wait for container to be ready
Write-Host "Waiting 20 seconds for container to start..." -ForegroundColor Gray
Start-Sleep -Seconds 20

# Get the app URL
Write-Host "`n==> n8n is now starting up!" -ForegroundColor Cyan
$AppUrl = az containerapp show `
    --resource-group $ResourceGroup `
    --name $ContainerApp `
    --query "properties.configuration.ingress.fqdn" `
    --output tsv

if ($AppUrl) {
    Write-Host "✓ n8n Editor URL: https://$AppUrl" -ForegroundColor Green
} else {
    Write-Host "⚠ Could not retrieve app URL" -ForegroundColor Yellow
}

Write-Host "`n==> Startup complete!" -ForegroundColor Cyan
