<#
.SYNOPSIS
    Retrieves connection identities from Power Platform environments using PowerShell.

.DESCRIPTION
    This script uses the Get-AdminPowerAppConnection cmdlet to retrieve all connections
    across Power Platform environments and extract identity information.
    
    This is a PowerShell alternative to the "Admin | Sync Template v4 (Connection Identities)" 
    flow when facing the 200MB pagination limitation documented in issue #6276.

.PARAMETER TenantId
    The Azure AD Tenant ID (optional - will prompt for interactive login if not specified)

.PARAMETER OutputPath
    Path to save the output JSON file (default: .\ConnectionIdentities.json)

.PARAMETER EnvironmentFilter
    Optional filter to process specific environment(s). Supports wildcards.
    Example: "Default*" or specific environment name

.EXAMPLE
    .\Get-ConnectionIdentities.ps1
    
.EXAMPLE
    .\Get-ConnectionIdentities.ps1 -EnvironmentFilter "Default-*"
    
.EXAMPLE
    .\Get-ConnectionIdentities.ps1 -OutputPath "C:\temp\connections.json"

.NOTES
    Prerequisites:
    - Install Microsoft.PowerApps.Administration.PowerShell module
      Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
    
    - Account running the script must have Power Platform Admin or System Admin privileges
    
    - This script addresses the limitation where the Power Automate connector 
      "Get Connections as Admin" fails with large connection datasets (>200MB)
    
.LINK
    https://github.com/microsoft/coe-starter-kit/issues/6276
    https://learn.microsoft.com/powershell/module/microsoft.powerapps.administration.powershell/get-adminpowerappconnection
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\ConnectionIdentities.json",
    
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentFilter = "*"
)

#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check and install required module
function Install-RequiredModule {
    param(
        [string]$ModuleName
    )
    
    $module = Get-Module -ListAvailable -Name $ModuleName
    
    if ($null -eq $module) {
        Write-ColorOutput "Module '$ModuleName' is not installed. Installing now..." "Yellow"
        try {
            Install-Module -Name $ModuleName -Scope CurrentUser -Force -AllowClobber
            Write-ColorOutput "Module '$ModuleName' installed successfully." "Green"
        }
        catch {
            Write-ColorOutput "Failed to install module '$ModuleName'. Error: $_" "Red"
            throw
        }
    }
    else {
        Write-ColorOutput "Module '$ModuleName' is already installed (Version: $($module.Version))." "Green"
    }
}

# Main execution
try {
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Connection Identities Export Tool" "Cyan"
    Write-ColorOutput "========================================`n" "Cyan"
    
    # Check for required module
    Write-ColorOutput "Checking for required PowerShell modules..." "White"
    Install-RequiredModule -ModuleName "Microsoft.PowerApps.Administration.PowerShell"
    
    # Connect to Power Platform
    Write-ColorOutput "`nConnecting to Power Platform..." "White"
    if ($TenantId) {
        Add-PowerAppsAccount -TenantID $TenantId
    }
    else {
        Add-PowerAppsAccount
    }
    Write-ColorOutput "Successfully connected to Power Platform." "Green"
    
    # Get all environments
    Write-ColorOutput "`nRetrieving environments..." "White"
    $environments = Get-AdminPowerAppEnvironment | Where-Object { $_.EnvironmentName -like $EnvironmentFilter }
    Write-ColorOutput "Found $($environments.Count) environment(s) matching filter '$EnvironmentFilter'." "Green"
    
    # Collection to store all connection identities
    $allConnectionIdentities = @()
    $totalConnections = 0
    $environmentCount = 0
    
    # Process each environment
    foreach ($env in $environments) {
        $environmentCount++
        Write-ColorOutput "`n[$environmentCount/$($environments.Count)] Processing environment: $($env.DisplayName) ($($env.EnvironmentName))" "Cyan"
        
        try {
            # Get all connections in the environment
            $connections = Get-AdminPowerAppConnection -EnvironmentName $env.EnvironmentName -ErrorAction SilentlyContinue
            
            if ($null -eq $connections) {
                Write-ColorOutput "  No connections found in this environment." "Gray"
                continue
            }
            
            $connectionCount = ($connections | Measure-Object).Count
            $totalConnections += $connectionCount
            Write-ColorOutput "  Found $connectionCount connection(s)" "White"
            
            # Extract identity information from each connection
            foreach ($connection in $connections) {
                # Only process connections that have account name and creator information
                if ($connection.properties.accountName -and 
                    $connection.properties.createdBy -and 
                    $connection.properties.createdBy.userPrincipalName) {
                    
                    # Extract connector name from API ID
                    $apiId = $connection.properties.apiId
                    $connectorName = if ($apiId) { 
                        $apiId.Split('/')[-1] 
                    } else { 
                        "Unknown" 
                    }
                    
                    # Create identity object
                    $identity = [PSCustomObject]@{
                        EnvironmentName = $env.EnvironmentName
                        EnvironmentDisplayName = $env.DisplayName
                        ConnectionName = $connection.ConnectionName
                        ConnectorName = $connectorName
                        AccountName = $connection.properties.accountName
                        CreatorId = $connection.properties.createdBy.id
                        CreatorUPN = $connection.properties.createdBy.userPrincipalName
                        CreatorDisplayName = $connection.properties.createdBy.displayName
                        CreatedTime = $connection.properties.createdTime
                        ApiId = $connection.properties.apiId
                        DisplayName = $connection.properties.displayName
                        ConnectionStatus = $connection.properties.statuses[0].status
                    }
                    
                    $allConnectionIdentities += $identity
                }
            }
            
            Write-ColorOutput "  Processed $($allConnectionIdentities.Count - ($totalConnections - $connectionCount)) unique identit(ies)" "Green"
        }
        catch {
            Write-ColorOutput "  Error processing environment: $_" "Red"
        }
    }
    
    # Export results
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Export Summary:" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "Total environments processed: $environmentCount" "White"
    Write-ColorOutput "Total connections found: $totalConnections" "White"
    Write-ColorOutput "Total connection identities: $($allConnectionIdentities.Count)" "White"
    
    if ($allConnectionIdentities.Count -gt 0) {
        # Ensure output directory exists
        $outputDir = Split-Path -Path $OutputPath -Parent
        if ($outputDir -and -not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        # Export to JSON
        $allConnectionIdentities | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-ColorOutput "`nResults exported to: $OutputPath" "Green"
        Write-ColorOutput "File size: $([math]::Round((Get-Item $OutputPath).Length / 1MB, 2)) MB" "White"
    }
    else {
        Write-ColorOutput "`nNo connection identities found to export." "Yellow"
    }
    
    Write-ColorOutput "`nScript completed successfully!`n" "Green"
}
catch {
    Write-ColorOutput "`nERROR: Script execution failed!" "Red"
    Write-ColorOutput "Error details: $_" "Red"
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" "Red"
    exit 1
}
