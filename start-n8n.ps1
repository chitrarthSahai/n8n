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
    $result = az postgres flexible-server start `
        --resource-group $ResourceGroup `
        --name $PostgresServer 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ PostgreSQL server started successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to start PostgreSQL server" -ForegroundColor Red
        Write-Host "Error: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Failed to start PostgreSQL server: $_" -ForegroundColor Red
    exit 1
}

# Wait for database to be fully ready
Write-Host "Waiting 15 seconds for database to be fully ready..." -ForegroundColor Gray
Start-Sleep -Seconds 15

# Step 2: Start Container App using REST API
Write-Host "[2/2] Starting Container App: $ContainerApp..." -ForegroundColor Yellow
try {
    # Get subscription ID
    $subscriptionId = az account show --query id -o tsv
    
    # Start the container app using the REST API
    $result = az rest --method post --url "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.App/containerApps/$ContainerApp/start?api-version=2024-03-01" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Container App started successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to start Container App" -ForegroundColor Red
        Write-Host "Error: $result" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Failed to start Container App: $_" -ForegroundColor Red
    exit 1
}

# Wait for container to be ready
Write-Host "Waiting 20 seconds for container to start..." -ForegroundColor Gray
Start-Sleep -Seconds 20

# Get the app URL
Write-Host ""
Write-Host "==> n8n is now starting up!" -ForegroundColor Cyan
$AppUrl = az containerapp show `
    --resource-group $ResourceGroup `
    --name $ContainerApp `
    --query 'properties.configuration.ingress.fqdn' `
    --output tsv

if ($AppUrl) {
    Write-Host "✓ n8n Editor URL: https://$AppUrl" -ForegroundColor Green
} else {
    Write-Host "⚠ Could not retrieve app URL" -ForegroundColor Yellow
}
