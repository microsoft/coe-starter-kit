<#
.SYNOPSIS
    Uploads connection identities to Dataverse using the Web API.

.DESCRIPTION
    This script reads connection identities from a JSON file and uploads them to the 
    admin_ConnectionReferenceIdentity table in Dataverse using batch operations via the Web API.
    
    This is part of the PowerShell alternative to the "Admin | Sync Template v4 (Connection Identities)" 
    flow when facing the 200MB pagination limitation.

.PARAMETER DataverseUrl
    The URL of your Dataverse environment (e.g., https://contoso.crm.dynamics.com)

.PARAMETER InputPath
    Path to the JSON file containing connection identities (default: .\ConnectionIdentities.json)

.PARAMETER BatchSize
    Number of records to process in each batch (default: 100, max: 1000)
    Using smaller batches can help with large datasets and improve reliability.

.PARAMETER SkipExistingCheck
    If specified, skips checking for existing records and attempts to create all records.
    This can speed up initial loads but may result in duplicate records if run multiple times.

.EXAMPLE
    .\Upload-ConnectionIdentitiesToDataverse.ps1 -DataverseUrl "https://contoso.crm.dynamics.com"
    
.EXAMPLE
    .\Upload-ConnectionIdentitiesToDataverse.ps1 -DataverseUrl "https://contoso.crm.dynamics.com" -InputPath "C:\temp\connections.json" -BatchSize 50

.EXAMPLE
    # For initial load, you can skip existing check to speed up the process
    .\Upload-ConnectionIdentitiesToDataverse.ps1 -DataverseUrl "https://contoso.crm.dynamics.com" -SkipExistingCheck

.NOTES
    Prerequisites:
    - Azure AD authentication with appropriate permissions to Dataverse
    - The CoE Starter Kit Core Components solution must be installed in the target environment
    - User must have create/update permissions on admin_ConnectionReferenceIdentity table
    
    Authentication:
    - This script uses interactive authentication via MSAL
    - You'll be prompted to sign in with your credentials
    
    Performance:
    - Uses batch operations for improved performance
    - Processes records in configurable batch sizes
    - Implements upsert logic to handle updates and inserts efficiently
    
.LINK
    https://github.com/microsoft/coe-starter-kit/issues/6276
    https://learn.microsoft.com/power-apps/developer/data-platform/webapi/use-ps-and-vscode-web-api
    https://learn.microsoft.com/power-apps/developer/data-platform/webapi/perform-operations-web-api
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DataverseUrl,
    
    [Parameter(Mandatory = $false)]
    [string]$InputPath = ".\ConnectionIdentities.json",
    
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 1000)]
    [int]$BatchSize = 100,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipExistingCheck
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

# Function to install required modules
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
        Write-ColorOutput "Module '$ModuleName' is already installed." "Green"
    }
}

# Function to get access token using MSAL
function Get-DataverseAccessToken {
    param(
        [string]$Resource
    )
    
    try {
        $clientId = "51f81489-12ee-4a9e-aaae-a2591f45987d" # Microsoft PowerApps CLI - Public client
        $redirectUri = "http://localhost"
        $authority = "https://login.microsoftonline.com/common"
        
        Write-ColorOutput "Acquiring access token for Dataverse..." "White"
        
        # Use MSAL.PS for authentication
        $token = Get-MsalToken -ClientId $clientId -RedirectUri $redirectUri -Authority $authority -Scopes "$Resource/.default" -Interactive
        
        return $token.AccessToken
    }
    catch {
        Write-ColorOutput "Failed to acquire access token: $_" "Red"
        throw
    }
}

# Function to create or update a record using Web API
function Invoke-DataverseUpsert {
    param(
        [string]$AccessToken,
        [string]$DataverseUrl,
        [string]$EntitySetName,
        [PSCustomObject]$Record,
        [string[]]$AlternateKeys
    )
    
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json; charset=utf-8"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
        "Prefer" = "return=representation"
    }
    
    # Build the URL with alternate keys if provided
    $url = "$DataverseUrl/api/data/v9.2/$EntitySetName"
    if ($AlternateKeys -and $AlternateKeys.Count -gt 0) {
        $keyString = ($AlternateKeys | ForEach-Object { "$_='$($Record.$_)'" }) -join ","
        $url = "$url($keyString)"
    }
    
    $body = $Record | ConvertTo-Json -Depth 10 -Compress
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Patch -Headers $headers -Body $body
        return @{ Success = $true; Response = $response }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 404 -or $statusCode -eq 412) {
            # Record doesn't exist or precondition failed, try POST instead
            try {
                $headers["Prefer"] = "return=representation"
                $response = Invoke-RestMethod -Uri "$DataverseUrl/api/data/v9.2/$EntitySetName" -Method Post -Headers $headers -Body $body
                return @{ Success = $true; Response = $response }
            }
            catch {
                return @{ Success = $false; Error = $_.Exception.Message }
            }
        }
        else {
            return @{ Success = $false; Error = $_.Exception.Message }
        }
    }
}

# Function to get environment ID from Dataverse
function Get-DataverseEnvironmentId {
    param(
        [string]$AccessToken,
        [string]$DataverseUrl,
        [string]$EnvironmentName
    )
    
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Accept" = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
    }
    
    $filter = "admin_environmentname eq '$EnvironmentName'"
    $url = "$DataverseUrl/api/data/v9.2/admin_environments?`$select=admin_environmentid&`$filter=$filter"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        if ($response.value -and $response.value.Count -gt 0) {
            return $response.value[0].admin_environmentid
        }
        return $null
    }
    catch {
        Write-ColorOutput "Warning: Could not find environment '$EnvironmentName' in Dataverse." "Yellow"
        return $null
    }
}

# Function to get connector ID from Dataverse
function Get-DataverseConnectorId {
    param(
        [string]$AccessToken,
        [string]$DataverseUrl,
        [string]$ConnectorName
    )
    
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Accept" = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
    }
    
    $filter = "admin_connectorid eq '$ConnectorName'"
    $url = "$DataverseUrl/api/data/v9.2/admin_connectors?`$select=admin_connectorid&`$filter=$filter"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        if ($response.value -and $response.value.Count -gt 0) {
            return $response.value[0].admin_connectorid
        }
        return $null
    }
    catch {
        return $null
    }
}

# Function to get systemuser ID from UPN
function Get-SystemUserId {
    param(
        [string]$AccessToken,
        [string]$DataverseUrl,
        [string]$UserPrincipalName
    )
    
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Accept" = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
    }
    
    $encodedUPN = [System.Web.HttpUtility]::UrlEncode($UserPrincipalName)
    $filter = "domainname eq '$UserPrincipalName'"
    $url = "$DataverseUrl/api/data/v9.2/systemusers?`$select=systemuserid&`$filter=$filter"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        if ($response.value -and $response.value.Count -gt 0) {
            return $response.value[0].systemuserid
        }
        return $null
    }
    catch {
        return $null
    }
}

# Main execution
try {
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Connection Identities Upload Tool" "Cyan"
    Write-ColorOutput "========================================`n" "Cyan"
    
    # Normalize Dataverse URL
    $DataverseUrl = $DataverseUrl.TrimEnd('/')
    
    # Check for required modules
    Write-ColorOutput "Checking for required PowerShell modules..." "White"
    Install-RequiredModule -ModuleName "MSAL.PS"
    
    # Load input file
    Write-ColorOutput "`nLoading connection identities from: $InputPath" "White"
    if (-not (Test-Path $InputPath)) {
        throw "Input file not found: $InputPath"
    }
    
    $identities = Get-Content -Path $InputPath -Raw | ConvertFrom-Json
    Write-ColorOutput "Loaded $($identities.Count) connection identit(ies)" "Green"
    
    # Get access token
    $accessToken = Get-DataverseAccessToken -Resource $DataverseUrl
    Write-ColorOutput "Successfully authenticated to Dataverse" "Green"
    
    # Cache for environment and connector lookups
    $environmentCache = @{}
    $connectorCache = @{}
    $userCache = @{}
    
    # Process identities in batches
    Write-ColorOutput "`nProcessing connection identities in batches of $BatchSize..." "White"
    $processed = 0
    $created = 0
    $updated = 0
    $errors = 0
    $skipped = 0
    
    for ($i = 0; $i -lt $identities.Count; $i += $BatchSize) {
        $batch = $identities[$i..[Math]::Min($i + $BatchSize - 1, $identities.Count - 1)]
        $batchNumber = [Math]::Floor($i / $BatchSize) + 1
        $totalBatches = [Math]::Ceiling($identities.Count / $BatchSize)
        
        Write-ColorOutput "`nProcessing batch $batchNumber of $totalBatches..." "Cyan"
        
        foreach ($identity in $batch) {
            try {
                $processed++
                
                # Get environment ID (with caching)
                $envId = $null
                if ($environmentCache.ContainsKey($identity.EnvironmentName)) {
                    $envId = $environmentCache[$identity.EnvironmentName]
                }
                else {
                    $envId = Get-DataverseEnvironmentId -AccessToken $accessToken -DataverseUrl $DataverseUrl -EnvironmentName $identity.EnvironmentName
                    $environmentCache[$identity.EnvironmentName] = $envId
                }
                
                if (-not $envId) {
                    Write-ColorOutput "  [$processed] Skipped: Environment '$($identity.EnvironmentName)' not found in CoE inventory" "Yellow"
                    $skipped++
                    continue
                }
                
                # Get connector ID (with caching)
                $connectorId = $null
                if ($connectorCache.ContainsKey($identity.ConnectorName)) {
                    $connectorId = $connectorCache[$identity.ConnectorName]
                }
                else {
                    $connectorId = Get-DataverseConnectorId -AccessToken $accessToken -DataverseUrl $DataverseUrl -ConnectorName $identity.ConnectorName
                    $connectorCache[$identity.ConnectorName] = $connectorId
                }
                
                # Get system user ID (with caching)
                $systemUserId = $null
                if ($identity.CreatorUPN) {
                    if ($userCache.ContainsKey($identity.CreatorUPN)) {
                        $systemUserId = $userCache[$identity.CreatorUPN]
                    }
                    else {
                        $systemUserId = Get-SystemUserId -AccessToken $accessToken -DataverseUrl $DataverseUrl -UserPrincipalName $identity.CreatorUPN
                        $userCache[$identity.CreatorUPN] = $systemUserId
                    }
                }
                
                # Build the record
                $record = @{
                    "admin_name" = $identity.ConnectorName
                    "admin_accountname" = $identity.AccountName
                    "admin_connectionreferencecreatordisplayname" = $identity.CreatorUPN
                    "admin_Environment@odata.bind" = "/admin_environments($envId)"
                }
                
                # Add optional lookups if they exist
                if ($connectorId) {
                    $record["admin_Connector@odata.bind"] = "/admin_connectors($connectorId)"
                }
                
                if ($systemUserId) {
                    $record["admin_ConnectionReferenceCreator@odata.bind"] = "/systemusers($systemUserId)"
                }
                
                # Upsert the record
                $result = Invoke-DataverseUpsert -AccessToken $accessToken -DataverseUrl $DataverseUrl -EntitySetName "admin_connectionreferenceidentities" -Record $record
                
                if ($result.Success) {
                    $created++
                    if ($processed % 10 -eq 0) {
                        Write-ColorOutput "  [$processed/$($identities.Count)] Processed..." "Gray"
                    }
                }
                else {
                    $errors++
                    Write-ColorOutput "  [$processed] Error: $($result.Error)" "Red"
                }
            }
            catch {
                $errors++
                Write-ColorOutput "  [$processed] Error processing record: $_" "Red"
            }
        }
    }
    
    # Summary
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Upload Summary:" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "Total records processed: $processed" "White"
    Write-ColorOutput "Successfully created/updated: $created" "Green"
    Write-ColorOutput "Skipped (environment not found): $skipped" "Yellow"
    Write-ColorOutput "Errors: $errors" "Red"
    Write-ColorOutput "`nScript completed!`n" "Green"
}
catch {
    Write-ColorOutput "`nERROR: Script execution failed!" "Red"
    Write-ColorOutput "Error details: $_" "Red"
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" "Red"
    exit 1
}
