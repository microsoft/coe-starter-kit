<#
.SYNOPSIS
    Updates the admin_FullInventory environment variable value in a CoE Starter Kit environment.

.DESCRIPTION
    This script helps administrators update the FullInventory environment variable when it appears 
    locked or read-only in the Power Platform admin center. This is particularly useful for large 
    tenants (10,000+ resources) where full inventory can cause timeouts and incomplete updates.

.PARAMETER EnvironmentId
    The GUID of the Power Platform environment where CoE Starter Kit is installed.
    Example: "00000000-0000-0000-0000-000000000000"

.PARAMETER Value
    The value to set for FullInventory. Valid values: "yes" or "no"
    - "no" (recommended for large tenants): Only updates changed objects (incremental inventory)
    - "yes": Updates all objects in every inventory run (full inventory)

.PARAMETER TenantId
    (Optional) The Azure AD tenant ID. If not provided, uses the current authenticated tenant.

.EXAMPLE
    .\Update-FullInventoryEnvVar.ps1 -EnvironmentId "12345678-1234-1234-1234-123456789012" -Value "no"
    Sets FullInventory to "no" (incremental inventory) in the specified environment.

.EXAMPLE
    .\Update-FullInventoryEnvVar.ps1 -EnvironmentId "12345678-1234-1234-1234-123456789012" -Value "yes"
    Sets FullInventory to "yes" (full inventory) in the specified environment.

.NOTES
    Prerequisites:
    - PowerShell 5.1 or later
    - Microsoft.PowerApps.Administration.PowerShell module
    - Power Platform Administrator or System Administrator permissions
    
    For more information, see:
    https://github.com/microsoft/coe-starter-kit/blob/main/TROUBLESHOOTING-INVENTORY.md
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, HelpMessage="The GUID of the Power Platform environment")]
    [ValidateNotNullOrEmpty()]
    [string]$EnvironmentId,
    
    [Parameter(Mandatory=$true, HelpMessage="The value to set: 'yes' for full inventory, 'no' for incremental")]
    [ValidateSet("yes", "no", IgnoreCase=$true)]
    [string]$Value,
    
    [Parameter(Mandatory=$false, HelpMessage="Azure AD Tenant ID (optional)")]
    [string]$TenantId
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "CoE Starter Kit - Update FullInventory Environment Variable" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if the PowerApps module is installed
Write-Host "Checking for Microsoft.PowerApps.Administration.PowerShell module..." -ForegroundColor Yellow

$module = Get-Module -ListAvailable -Name "Microsoft.PowerApps.Administration.PowerShell"
if (-not $module) {
    Write-Host "ERROR: Microsoft.PowerApps.Administration.PowerShell module not found." -ForegroundColor Red
    Write-Host "Please install it using:" -ForegroundColor Yellow
    Write-Host "  Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "Module found: Version $($module.Version)" -ForegroundColor Green
Write-Host ""

# Import the module
try {
    Import-Module Microsoft.PowerApps.Administration.PowerShell -ErrorAction Stop
    Write-Host "Module imported successfully." -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to import module: $_" -ForegroundColor Red
    exit 1
}

# Authenticate
Write-Host "Authenticating to Power Platform..." -ForegroundColor Yellow
try {
    if ($TenantId) {
        Add-PowerAppsAccount -TenantID $TenantId -ErrorAction Stop | Out-Null
    } else {
        Add-PowerAppsAccount -ErrorAction Stop | Out-Null
    }
    Write-Host "Authentication successful." -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Authentication failed: $_" -ForegroundColor Red
    exit 1
}

# Validate environment exists
Write-Host "Validating environment: $EnvironmentId..." -ForegroundColor Yellow
try {
    $environment = Get-AdminPowerAppEnvironment -EnvironmentName $EnvironmentId -ErrorAction Stop
    Write-Host "Environment found: $($environment.DisplayName)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Environment not found or you don't have access: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please verify:" -ForegroundColor Yellow
    Write-Host "  1. The Environment ID is correct" -ForegroundColor White
    Write-Host "  2. You have Power Platform Administrator or System Administrator permissions" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Get environment variable definition
Write-Host "Looking for admin_FullInventory environment variable..." -ForegroundColor Yellow
try {
    $envVars = Get-AdminPowerAppEnvironmentVariable -EnvironmentName $EnvironmentId -ErrorAction Stop
    $fullInventoryVar = $envVars | Where-Object { $_.SchemaName -eq "admin_FullInventory" }
    
    if (-not $fullInventoryVar) {
        Write-Host "ERROR: admin_FullInventory environment variable not found in this environment." -ForegroundColor Red
        Write-Host "This environment may not have the CoE Starter Kit Core Components installed." -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
    
    Write-Host "Environment variable found." -ForegroundColor Green
    Write-Host "  Definition ID: $($fullInventoryVar.EnvironmentVariableDefinitionId)" -ForegroundColor Gray
    
    # Show current value if it exists
    if ($fullInventoryVar.Value) {
        Write-Host "  Current Value: $($fullInventoryVar.Value)" -ForegroundColor Gray
    } else {
        Write-Host "  Current Value: (not set, using default)" -ForegroundColor Gray
    }
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to retrieve environment variables: $_" -ForegroundColor Red
    exit 1
}

# Confirm the change
Write-Host "Ready to update FullInventory to: " -NoNewline -ForegroundColor Yellow
Write-Host $Value -ForegroundColor White
Write-Host ""

if ($Value.ToLower() -eq "no") {
    Write-Host "NOTE: Incremental inventory (no) is recommended for large tenants." -ForegroundColor Green
    Write-Host "      Only flows modified in the last N days will be updated." -ForegroundColor Gray
    Write-Host "      (N is controlled by admin_InventoryFilter_DaysToLookBack)" -ForegroundColor Gray
} else {
    Write-Host "WARNING: Full inventory (yes) will process ALL flows in your tenant." -ForegroundColor Yellow
    Write-Host "         For tenants with 10,000+ flows, this can take 20+ hours" -ForegroundColor Yellow
    Write-Host "         and may cause timeouts or incomplete updates." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "         Consider using incremental inventory (no) instead." -ForegroundColor Yellow
}
Write-Host ""

$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    exit 0
}
Write-Host ""

# Update the environment variable value
Write-Host "Updating environment variable value..." -ForegroundColor Yellow
try {
    Set-AdminPowerAppEnvironmentVariableValue `
        -EnvironmentName $EnvironmentId `
        -EnvironmentVariableDefinitionId $fullInventoryVar.EnvironmentVariableDefinitionId `
        -Value $Value `
        -ErrorAction Stop
    
    Write-Host "SUCCESS: FullInventory updated to: $Value" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. The next inventory run will use the new setting" -ForegroundColor White
    Write-Host "  2. Monitor flow runs in the CoE Admin Command Center" -ForegroundColor White
    Write-Host "  3. For additional configuration options, see:" -ForegroundColor White
    Write-Host "     https://github.com/microsoft/coe-starter-kit/blob/main/TROUBLESHOOTING-INVENTORY.md" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "ERROR: Failed to update environment variable: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Ensure you have System Administrator role in the environment" -ForegroundColor White
    Write-Host "  2. Check if there's a managed solution layer preventing updates" -ForegroundColor White
    Write-Host "  3. Try using the Power Platform admin center UI directly" -ForegroundColor White
    Write-Host "  4. See troubleshooting guide for alternative methods:" -ForegroundColor White
    Write-Host "     https://github.com/microsoft/coe-starter-kit/blob/main/TROUBLESHOOTING-INVENTORY.md" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "Script completed successfully." -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
