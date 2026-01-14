<#
.SYNOPSIS
    Complete end-to-end sync of connection identities to CoE Dataverse.

.DESCRIPTION
    This wrapper script executes both steps of the connection identities sync process:
    1. Retrieves connection identities from Power Platform environments
    2. Uploads the data to the CoE Dataverse environment
    
    This is a convenience script that combines Get-ConnectionIdentities.ps1 and 
    Upload-ConnectionIdentitiesToDataverse.ps1 for easier automation and scheduling.

.PARAMETER DataverseUrl
    The URL of your CoE Dataverse environment (e.g., https://contoso.crm.dynamics.com)

.PARAMETER EnvironmentFilter
    Optional filter to process specific environment(s). Supports wildcards.
    Example: "Default*" or specific environment name (default: "*" for all)

.PARAMETER BatchSize
    Number of records to process in each batch when uploading (default: 100)

.PARAMETER SkipUpload
    If specified, only retrieves connection identities but doesn't upload to Dataverse.
    Useful for testing or when you want to review the data before uploading.

.PARAMETER CleanupJsonAfterUpload
    If specified, deletes the temporary JSON file after successful upload.

.EXAMPLE
    .\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://contoso.crm.dynamics.com"
    
.EXAMPLE
    .\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://contoso.crm.dynamics.com" -EnvironmentFilter "Default-*"
    
.EXAMPLE
    # Dry run - retrieve data but don't upload
    .\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://contoso.crm.dynamics.com" -SkipUpload

.EXAMPLE
    # Full sync with cleanup
    .\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://contoso.crm.dynamics.com" -CleanupJsonAfterUpload

.NOTES
    This is a wrapper script designed for automation scenarios such as:
    - Windows Task Scheduler
    - Azure Automation Runbooks
    - Scheduled scripts via cron (Linux/Mac)
    
    Prerequisites:
    - Microsoft.PowerApps.Administration.PowerShell module
    - MSAL.PS module
    - Power Platform Administrator or System Administrator role
    - CoE Starter Kit Core Components solution installed

.LINK
    https://github.com/microsoft/coe-starter-kit/issues/6276
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DataverseUrl,
    
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentFilter = "*",
    
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 1000)]
    [int]$BatchSize = 100,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipUpload,
    
    [Parameter(Mandatory = $false)]
    [switch]$CleanupJsonAfterUpload
)

$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$tempJsonPath = Join-Path $scriptDir "ConnectionIdentities_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"

try {
    Write-ColorOutput "`n================================================================" "Cyan"
    Write-ColorOutput "   Connection Identities Sync - Complete Process" "Cyan"
    Write-ColorOutput "================================================================`n" "Cyan"
    
    $startTime = Get-Date
    
    # Step 1: Retrieve Connection Identities
    Write-ColorOutput "STEP 1: Retrieving connection identities from Power Platform..." "Green"
    Write-ColorOutput "Environment Filter: $EnvironmentFilter" "Gray"
    Write-ColorOutput "Output Path: $tempJsonPath`n" "Gray"
    
    $getScript = Join-Path $scriptDir "Get-ConnectionIdentities.ps1"
    
    if (-not (Test-Path $getScript)) {
        throw "Get-ConnectionIdentities.ps1 not found in: $scriptDir"
    }
    
    & $getScript -EnvironmentFilter $EnvironmentFilter -OutputPath $tempJsonPath
    
    if (-not (Test-Path $tempJsonPath)) {
        throw "Failed to create connection identities file"
    }
    
    $fileSize = [math]::Round((Get-Item $tempJsonPath).Length / 1MB, 2)
    Write-ColorOutput "`nStep 1 completed successfully! File size: $fileSize MB`n" "Green"
    
    # Step 2: Upload to Dataverse (unless skipped)
    if ($SkipUpload) {
        Write-ColorOutput "STEP 2: Skipped (SkipUpload flag specified)" "Yellow"
        Write-ColorOutput "`nConnection identities saved to: $tempJsonPath" "White"
    }
    else {
        Write-ColorOutput "STEP 2: Uploading connection identities to Dataverse..." "Green"
        Write-ColorOutput "Dataverse URL: $DataverseUrl" "Gray"
        Write-ColorOutput "Batch Size: $BatchSize`n" "Gray"
        
        $uploadScript = Join-Path $scriptDir "Upload-ConnectionIdentitiesToDataverse.ps1"
        
        if (-not (Test-Path $uploadScript)) {
            throw "Upload-ConnectionIdentitiesToDataverse.ps1 not found in: $scriptDir"
        }
        
        & $uploadScript -DataverseUrl $DataverseUrl -InputPath $tempJsonPath -BatchSize $BatchSize
        
        Write-ColorOutput "`nStep 2 completed successfully!`n" "Green"
        
        # Cleanup if requested
        if ($CleanupJsonAfterUpload) {
            Write-ColorOutput "Cleaning up temporary JSON file..." "Gray"
            Remove-Item -Path $tempJsonPath -Force
            Write-ColorOutput "Cleanup completed.`n" "Green"
        }
        else {
            Write-ColorOutput "Temporary file preserved at: $tempJsonPath`n" "White"
        }
    }
    
    # Summary
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-ColorOutput "================================================================" "Cyan"
    Write-ColorOutput "   Sync Process Completed Successfully!" "Cyan"
    Write-ColorOutput "================================================================" "Cyan"
    Write-ColorOutput "Start Time: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))" "White"
    Write-ColorOutput "End Time: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))" "White"
    Write-ColorOutput "Duration: $($duration.ToString('hh\:mm\:ss'))" "White"
    Write-ColorOutput "================================================================`n" "Cyan"
}
catch {
    Write-ColorOutput "`n================================================================" "Red"
    Write-ColorOutput "   ERROR: Sync Process Failed!" "Red"
    Write-ColorOutput "================================================================" "Red"
    Write-ColorOutput "Error details: $_" "Red"
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" "Red"
    Write-ColorOutput "================================================================`n" "Red"
    
    # Cleanup on error if file exists
    if ((Test-Path $tempJsonPath) -and $CleanupJsonAfterUpload) {
        Write-ColorOutput "Cleaning up temporary file due to error..." "Gray"
        Remove-Item -Path $tempJsonPath -Force -ErrorAction SilentlyContinue
    }
    
    exit 1
}
