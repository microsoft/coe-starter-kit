# Get-CoEEmbeddedAppIDs.ps1
<#
.SYNOPSIS
    Retrieves the App IDs for CoE Starter Kit embedded Power Apps needed for Power BI dashboard configuration.

.DESCRIPTION
    This script connects to your Power Platform environment and retrieves the App IDs for:
    - Admin - Access this App [works embedded in Power BI only]
    - Admin - Access this Flow [works embedded in Power BI only]
    
    These App IDs are needed to configure the embedded apps in the Power BI dashboard after
    upgrading or installing the CoE Starter Kit.

.PARAMETER EnvironmentUrl
    The URL of your Power Platform environment (e.g., https://contoso.crm.dynamics.com)
    
.EXAMPLE
    .\Get-CoEEmbeddedAppIDs.ps1 -EnvironmentUrl "https://contoso.crm.dynamics.com"
    
.NOTES
    Prerequisites:
    - Microsoft.PowerApps.Administration.PowerShell module
    - Microsoft.PowerApps.PowerShell module
    - Appropriate permissions to view apps in the environment
    
    Install modules if needed:
    Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force
    Install-Module -Name Microsoft.PowerApps.PowerShell -Force
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentUrl
)

# Import required modules
try {
    Import-Module Microsoft.PowerApps.Administration.PowerShell -ErrorAction Stop
    Import-Module Microsoft.PowerApps.PowerShell -ErrorAction Stop
    Write-Host "✓ PowerShell modules loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Error loading PowerShell modules. Please install them first:" -ForegroundColor Red
    Write-Host "  Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force" -ForegroundColor Yellow
    Write-Host "  Install-Module -Name Microsoft.PowerApps.PowerShell -Force" -ForegroundColor Yellow
    exit 1
}

# Extract environment name from URL
$environmentName = ""
if ($EnvironmentUrl -match "https://(.+?)\.crm") {
    # Try to get environment using the org name
    Write-Host "`nConnecting to Power Platform..." -ForegroundColor Cyan
    Add-PowerAppsAccount
    
    $environments = Get-AdminPowerAppEnvironment
    $environment = $environments | Where-Object { $_.Properties.LinkedEnvironmentMetadata.InstanceUrl -eq $EnvironmentUrl }
    
    if ($environment) {
        $environmentName = $environment.EnvironmentName
        Write-Host "✓ Found environment: $($environment.DisplayName)" -ForegroundColor Green
    } else {
        Write-Host "✗ Could not find environment with URL: $EnvironmentUrl" -ForegroundColor Red
        Write-Host "Available environments:" -ForegroundColor Yellow
        $environments | ForEach-Object { Write-Host "  - $($_.DisplayName): $($_.Properties.LinkedEnvironmentMetadata.InstanceUrl)" }
        exit 1
    }
} else {
    Write-Host "✗ Invalid environment URL format. Expected format: https://orgname.crm.dynamics.com" -ForegroundColor Red
    exit 1
}

Write-Host "`nSearching for CoE embedded apps..." -ForegroundColor Cyan

# Get all apps in the environment
$apps = Get-AdminPowerApp -EnvironmentName $environmentName

# Find the embedded apps
$adminAccessAppApp = $apps | Where-Object { $_.DisplayName -like "*Admin - Access this App*" }
$adminAccessFlowApp = $apps | Where-Object { $_.DisplayName -like "*Admin - Access this Flow*" }

# Display results
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CoE Embedded App IDs" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($adminAccessAppApp) {
    Write-Host "Admin - Access this App:" -ForegroundColor Green
    Write-Host "  Display Name: $($adminAccessAppApp.DisplayName)" -ForegroundColor White
    Write-Host "  App ID: $($adminAccessAppApp.AppName)" -ForegroundColor Yellow
    Write-Host "  Description: $($adminAccessAppApp.Properties.Description)" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "✗ Admin - Access this App: NOT FOUND" -ForegroundColor Red
    Write-Host "  This app should be included in the CenterofExcellenceCoreComponents solution." -ForegroundColor Gray
    Write-Host ""
}

if ($adminAccessFlowApp) {
    Write-Host "Admin - Access this Flow:" -ForegroundColor Green
    Write-Host "  Display Name: $($adminAccessFlowApp.DisplayName)" -ForegroundColor White
    Write-Host "  App ID: $($adminAccessFlowApp.AppName)" -ForegroundColor Yellow
    Write-Host "  Description: $($adminAccessFlowApp.Properties.Description)" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "✗ Admin - Access this Flow: NOT FOUND" -ForegroundColor Red
    Write-Host "  This app should be included in the CenterofExcellenceCoreComponents solution." -ForegroundColor Gray
    Write-Host ""
}

Write-Host "========================================`n" -ForegroundColor Cyan

if ($adminAccessAppApp -and $adminAccessFlowApp) {
    Write-Host "✓ All embedded apps found successfully!" -ForegroundColor Green
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "1. Open your Power BI dashboard in Power BI Desktop" -ForegroundColor White
    Write-Host "2. Navigate to the 'App Deep Dive' page and select the 'Manage App' visual" -ForegroundColor White
    Write-Host "3. In the Visualizations pane, update the App ID to:" -ForegroundColor White
    Write-Host "   $($adminAccessAppApp.AppName)" -ForegroundColor Yellow
    Write-Host "4. Navigate to the 'Flow Deep Dive' page and select the 'Manage Flow' visual" -ForegroundColor White
    Write-Host "5. In the Visualizations pane, update the App ID to:" -ForegroundColor White
    Write-Host "   $($adminAccessFlowApp.AppName)" -ForegroundColor Yellow
    Write-Host "6. Save and publish your Power BI report" -ForegroundColor White
    Write-Host "`nFor detailed instructions, see: PowerBI-Embedded-Apps-Troubleshooting.md" -ForegroundColor Gray
} else {
    Write-Host "⚠ Warning: Some embedded apps were not found." -ForegroundColor Yellow
    Write-Host "Please ensure the CenterofExcellenceCoreComponents solution is installed correctly." -ForegroundColor Yellow
}
