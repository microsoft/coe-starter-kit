<#
.SYNOPSIS
    Updates the Power BI template file with the correct Power App IDs from your environment.

.DESCRIPTION
    This script fixes the connection issue with embedded Power Apps in the CoE Dashboard Power BI report.
    It updates the hardcoded App IDs in the Power BI template with the App IDs from your specific environment.
    
    The script requires:
    - PowerShell 5.1 or higher
    - Power Apps PowerShell module (Install-Module -Name Microsoft.PowerApps.Administration.PowerShell)
    - Access to the CoE environment where the Core Components are installed

.PARAMETER TemplatePath
    Path to the Power BI template file (.pbit) to update. 
    Default: Production_CoEDashboard_July2024.pbit

.PARAMETER OutputPath
    Path where the updated Power BI template will be saved.
    If not provided, the script will automatically generate a filename by appending "_Updated" to the input filename.
    Example: Production_CoEDashboard_July2024.pbit → Production_CoEDashboard_July2024_Updated.pbit

.PARAMETER EnvironmentName
    The name/ID of the Power Platform environment where CoE Core Components are installed.
    If not provided, you'll be prompted to select from available environments.

.PARAMETER FlowAccessAppName
    Display name of the "Admin - Access this Flow" app.
    Default: "Admin - Access this Flow [works embedded in Power BI only]"

.PARAMETER AppAccessAppName
    Display name of the "Admin - Access this App" app.
    Default: "Admin - Access this App [works embedded in Power BI only]"

.EXAMPLE
    .\Update-PowerBIEmbeddedApps.ps1 -EnvironmentName "00000000-0000-0000-0000-000000000000"
    
    Updates the default template file with App IDs from the specified environment.

.EXAMPLE
    .\Update-PowerBIEmbeddedApps.ps1 -TemplatePath ".\Production_CoEDashboard_July2024.pbit" -OutputPath ".\MyUpdated_CoEDashboard.pbit" -EnvironmentName "00000000-0000-0000-0000-000000000000"
    
    Updates a specific template file and saves it to a custom location.

.NOTES
    This script addresses the issue where the Power BI report shows a "disconnect" error on the 
    "Manage Flow Access" and "Manage App Access" pages because the template contains hardcoded 
    App IDs from the development environment.
    
    Author: CoE Starter Kit Team
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TemplatePath = "Production_CoEDashboard_July2024.pbit",
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "",
    
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory = $false)]
    [string]$FlowAccessAppName = "Admin - Access this Flow [works embedded in Power BI only]",
    
    [Parameter(Mandatory = $false)]
    [string]$AppAccessAppName = "Admin - Access this App [works embedded in Power BI only]"
)

# Function to extract and re-package .pbit files
function Extract-PBITemplate {
    param(
        [string]$TemplatePath,
        [string]$ExtractPath
    )
    
    Write-Host "Extracting Power BI template from: $TemplatePath" -ForegroundColor Cyan
    
    # Create temp directory
    if (Test-Path $ExtractPath) {
        Remove-Item -Path $ExtractPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $ExtractPath -Force | Out-Null
    
    # Extract the .pbit file (it's a ZIP archive)
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($TemplatePath, $ExtractPath)
        Write-Host "Template extracted successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to extract template: $_"
        return $false
    }
}

function Update-LayoutFile {
    param(
        [string]$LayoutPath,
        [string]$FlowAccessAppId,
        [string]$AppAccessAppId
    )
    
    Write-Host "Updating Layout file with new App IDs..." -ForegroundColor Cyan
    
    try {
        # Read the Layout file as UTF-16 LE
        $content = [System.IO.File]::ReadAllText($LayoutPath, [System.Text.Encoding]::Unicode)
        
        # Original hardcoded App IDs
        $oldFlowAccessAppId = "207e575c-6cf0-4d79-96f9-ffed8310be43"
        $oldAppAccessAppId = "2fd6105d-fd1e-4367-8d35-23fce69f33f4"
        
        # Replace the App IDs
        $updated = $false
        if ($content -match $oldFlowAccessAppId) {
            $content = $content -replace $oldFlowAccessAppId, $FlowAccessAppId
            Write-Host "  - Updated Flow Access App ID: $oldFlowAccessAppId -> $FlowAccessAppId" -ForegroundColor Yellow
            $updated = $true
        }
        else {
            Write-Warning "Original Flow Access App ID not found in template. It may have been already updated."
        }
        
        if ($content -match $oldAppAccessAppId) {
            $content = $content -replace $oldAppAccessAppId, $AppAccessAppId
            Write-Host "  - Updated App Access App ID: $oldAppAccessAppId -> $AppAccessAppId" -ForegroundColor Yellow
            $updated = $true
        }
        else {
            Write-Warning "Original App Access App ID not found in template. It may have been already updated."
        }
        
        if ($updated) {
            # Write back as UTF-16 LE
            [System.IO.File]::WriteAllText($LayoutPath, $content, [System.Text.Encoding]::Unicode)
            Write-Host "Layout file updated successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Warning "No updates were made to the Layout file"
            return $false
        }
    }
    catch {
        Write-Error "Failed to update Layout file: $_"
        return $false
    }
}

function Compress-PBITemplate {
    param(
        [string]$ExtractPath,
        [string]$OutputPath
    )
    
    Write-Host "Creating updated Power BI template: $OutputPath" -ForegroundColor Cyan
    
    try {
        # Remove existing output file if it exists
        if (Test-Path $OutputPath) {
            Remove-Item -Path $OutputPath -Force
        }
        
        # Create ZIP archive
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($ExtractPath, $OutputPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)
        
        Write-Host "Updated template created successfully: $OutputPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to create template: $_"
        return $false
    }
}

# Main script execution
Write-Host @"

========================================
 Power BI Embedded Apps Update Tool
========================================

This tool fixes the connection issue with embedded Power Apps in the 
CoE Dashboard Power BI report by updating the App IDs.

"@ -ForegroundColor Cyan

# Check if Power Apps module is installed
Write-Host "Checking for Power Apps PowerShell module..." -ForegroundColor Cyan
$module = Get-Module -ListAvailable -Name Microsoft.PowerApps.Administration.PowerShell
if (-not $module) {
    Write-Error @"
Power Apps Administration PowerShell module is not installed.
Please install it using: Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
"@
    exit 1
}

# Import the module
Import-Module Microsoft.PowerApps.Administration.PowerShell -ErrorAction Stop
Write-Host "Power Apps module loaded" -ForegroundColor Green

# Connect to Power Apps
Write-Host "`nConnecting to Power Apps..." -ForegroundColor Cyan
try {
    Add-PowerAppsAccount
    Write-Host "Connected successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect to Power Apps: $_"
    exit 1
}

# Get environment if not provided
if (-not $EnvironmentName) {
    Write-Host "`nRetrieving available environments..." -ForegroundColor Cyan
    $environments = Get-AdminPowerAppEnvironment | Where-Object { $_.Internal.isDefault -eq $false }
    
    if ($environments.Count -eq 0) {
        Write-Error "No environments found. Please check your permissions."
        exit 1
    }
    
    Write-Host "`nAvailable Environments:" -ForegroundColor Yellow
    $i = 1
    foreach ($env in $environments) {
        Write-Host "  $i. $($env.DisplayName) ($($env.EnvironmentName))"
        $i++
    }
    
    $selection = Read-Host "`nSelect environment number (1-$($environments.Count))"
    
    # Validate input
    $selectionNumber = 0
    if (-not [int]::TryParse($selection, [ref]$selectionNumber)) {
        Write-Error "Invalid input. Please enter a number."
        exit 1
    }
    
    if ($selectionNumber -lt 1 -or $selectionNumber -gt $environments.Count) {
        Write-Error "Invalid selection. Please enter a number between 1 and $($environments.Count)."
        exit 1
    }
    
    $selectedEnv = $environments[$selectionNumber - 1]
    $EnvironmentName = $selectedEnv.EnvironmentName
    Write-Host "Selected: $($selectedEnv.DisplayName)" -ForegroundColor Green
}

# Get the Power Apps
Write-Host "`nRetrieving Power Apps from environment..." -ForegroundColor Cyan
$apps = Get-AdminPowerApp -EnvironmentName $EnvironmentName

# Find the specific apps
$flowAccessApp = $apps | Where-Object { $_.DisplayName -eq $FlowAccessAppName }
$appAccessApp = $apps | Where-Object { $_.DisplayName -eq $AppAccessAppName }

if (-not $flowAccessApp) {
    Write-Error "Could not find app: '$FlowAccessAppName' in environment: $EnvironmentName"
    Write-Host "`nAvailable apps:" -ForegroundColor Yellow
    $apps | ForEach-Object { Write-Host "  - $($_.DisplayName)" }
    exit 1
}

if (-not $appAccessApp) {
    Write-Error "Could not find app: '$AppAccessAppName' in environment: $EnvironmentName"
    Write-Host "`nAvailable apps:" -ForegroundColor Yellow
    $apps | ForEach-Object { Write-Host "  - $($_.DisplayName)" }
    exit 1
}

# Extract App IDs
$flowAccessAppId = $flowAccessApp.AppName
$appAccessAppId = $appAccessApp.AppName

Write-Host "`nFound Apps:" -ForegroundColor Green
Write-Host "  - Flow Access App: $flowAccessAppId"
Write-Host "  - App Access App: $appAccessAppId"

# Verify template file exists
if (-not (Test-Path $TemplatePath)) {
    Write-Error "Template file not found: $TemplatePath"
    exit 1
}

# Generate output filename if not provided
if ([string]::IsNullOrEmpty($OutputPath)) {
    $templateFileName = [System.IO.Path]::GetFileNameWithoutExtension($TemplatePath)
    $templateExtension = [System.IO.Path]::GetExtension($TemplatePath)
    $templateDirectory = [System.IO.Path]::GetDirectoryName($TemplatePath)
    
    if ([string]::IsNullOrEmpty($templateDirectory)) {
        $templateDirectory = "."
    }
    
    $OutputPath = Join-Path $templateDirectory "$templateFileName`_Updated$templateExtension"
    Write-Host "Output path not specified. Using: $OutputPath" -ForegroundColor Yellow
}

# Extract template
$tempPath = Join-Path $env:TEMP "PBITemplate_$(Get-Date -Format 'yyyyMMddHHmmss')"
if (-not (Extract-PBITemplate -TemplatePath $TemplatePath -ExtractPath $tempPath)) {
    exit 1
}

# Update Layout file
$layoutPath = Join-Path $tempPath "Report\Layout"
if (-not (Test-Path $layoutPath)) {
    Write-Error "Layout file not found in template"
    Remove-Item -Path $tempPath -Recurse -Force
    exit 1
}

if (-not (Update-LayoutFile -LayoutPath $layoutPath -FlowAccessAppId $flowAccessAppId -AppAccessAppId $appAccessAppId)) {
    Write-Warning "Failed to update Layout file, but continuing..."
}

# Re-package template
if (-not (Compress-PBITemplate -ExtractPath $tempPath -OutputPath $OutputPath)) {
    Remove-Item -Path $tempPath -Recurse -Force
    exit 1
}

# Cleanup
Remove-Item -Path $tempPath -Recurse -Force

Write-Host @"

========================================
 Update Complete!
========================================

Your updated Power BI template is ready: $OutputPath

Next Steps:
1. Open the updated template file in Power BI Desktop
2. Enter your Dataverse environment URL when prompted
3. Navigate to the "Manage Flow Access" and "Manage App Access" pages
4. The embedded Power Apps should now load correctly

If you still experience issues, ensure:
- The Power Apps are shared with the users accessing the report
- The Power Apps are in the same environment as your data source
- You have the Power Apps visual enabled in Power BI

"@ -ForegroundColor Green
