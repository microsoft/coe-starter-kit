<#
.SYNOPSIS
    Exports DLP Impact Analysis data from Dataverse to CSV file.

.DESCRIPTION
    This script retrieves all records from the admin_dlpimpactanalysis table
    in your CoE Starter Kit environment and exports them to a CSV file.
    
    The script handles pagination automatically and can export large datasets
    that would timeout in the Canvas or model-driven apps.

.PARAMETER EnvironmentUrl
    The URL of your Dataverse environment (e.g., https://contoso.crm.dynamics.com)

.PARAMETER OutputPath
    The path where the CSV file will be saved. Defaults to current directory.

.PARAMETER DLPPolicyName
    Optional. Filter results by DLP Policy Name. If not specified, exports all records.

.PARAMETER DaysBack
    Optional. Only export records created in the last X days. If not specified, exports all records.

.PARAMETER PageSize
    Optional. Number of records to retrieve per page. Default is 5000.

.EXAMPLE
    .\Export-DLPImpactAnalysis.ps1 -EnvironmentUrl "https://contoso.crm.dynamics.com" -OutputPath "C:\Exports\DLPImpact.csv"
    
    Exports all DLP Impact Analysis records to the specified file.

.EXAMPLE
    .\Export-DLPImpactAnalysis.ps1 -EnvironmentUrl "https://contoso.crm.dynamics.com" -DLPPolicyName "Strict Policy" -OutputPath "StrictPolicy.csv"
    
    Exports only records for the "Strict Policy" DLP policy.

.EXAMPLE
    .\Export-DLPImpactAnalysis.ps1 -EnvironmentUrl "https://contoso.crm.dynamics.com" -DaysBack 30
    
    Exports only records created in the last 30 days.

.NOTES
    Prerequisites:
    - Install Microsoft.Xrm.Data.PowerShell module: Install-Module Microsoft.Xrm.Data.PowerShell
    - You must have read access to the admin_dlpimpactanalysis table in Dataverse
    - You must have System Administrator or similar role in the CoE environment

    Version: 1.0
    Author: CoE Starter Kit Team
    Date: 2024
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$EnvironmentUrl,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "DLPImpactAnalysis_Export_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv",
    
    [Parameter(Mandatory = $false)]
    [string]$DLPPolicyName,
    
    [Parameter(Mandatory = $false)]
    [int]$DaysBack,
    
    [Parameter(Mandatory = $false)]
    [int]$PageSize = 5000
)

# Check if Microsoft.Xrm.Data.PowerShell module is installed
$module = Get-Module -ListAvailable -Name Microsoft.Xrm.Data.PowerShell
if (-not $module) {
    Write-Error "Microsoft.Xrm.Data.PowerShell module is not installed. Please install it using: Install-Module Microsoft.Xrm.Data.PowerShell"
    exit 1
}

Import-Module Microsoft.Xrm.Data.PowerShell

Write-Host "Connecting to Dataverse environment: $EnvironmentUrl" -ForegroundColor Cyan

try {
    # Connect to Dataverse
    $conn = Get-CrmConnection -InteractiveMode
    
    if (-not $conn.IsReady) {
        Write-Error "Failed to connect to Dataverse. Please check your credentials and environment URL."
        exit 1
    }
    
    Write-Host "✓ Connected successfully" -ForegroundColor Green
    
    # Build FetchXML query
    $filterConditions = ""
    
    if ($DLPPolicyName) {
        $filterConditions += "      <condition attribute='admin_dlppolicyname' operator='eq' value='$DLPPolicyName' />`n"
    }
    
    if ($DaysBack) {
        $dateThreshold = (Get-Date).AddDays(-$DaysBack).ToString("yyyy-MM-dd")
        $filterConditions += "      <condition attribute='createdon' operator='on-or-after' value='$dateThreshold' />`n"
    }
    
    $fetchXml = @"
<fetch version="1.0" mapping="logical" distinct="false" count="$PageSize">
  <entity name="admin_dlpimpactanalysis">
    <attribute name="admin_dlpimpactanalysisid" />
    <attribute name="admin_name" />
    <attribute name="admin_dlppolicyname" />
    <attribute name="admin_decision" />
    <attribute name="admin_decisionstatus" />
    <attribute name="admin_conflictingconnectorblocked" />
    <attribute name="admin_conflictingconnectorbusiness" />
    <attribute name="admin_conflictingconnectornonbusiness" />
    <attribute name="admin_impactedapp" />
    <attribute name="admin_impactedflow" />
    <attribute name="admin_businessimpact" />
    <attribute name="admin_actionrequiredon" />
    <attribute name="createdon" />
    <attribute name="modifiedon" />
    <attribute name="statecode" />
    <filter type="and">
      <condition attribute="statecode" operator="eq" value="0" />
$filterConditions
    </filter>
    <order attribute="admin_name" descending="false" />
  </entity>
</fetch>
"@
    
    Write-Host "`nFetch Query:" -ForegroundColor Cyan
    Write-Host $fetchXml -ForegroundColor Gray
    
    Write-Host "`nRetrieving records..." -ForegroundColor Cyan
    
    $allResults = @()
    $pageNumber = 1
    $moreRecords = $true
    $totalRecords = 0
    
    while ($moreRecords) {
        Write-Host "  Fetching page $pageNumber (up to $PageSize records)..." -ForegroundColor Yellow
        
        # Add page number to fetch XML
        $pagedFetch = $fetchXml -replace 'count="' + $PageSize + '"', "count='$PageSize' page='$pageNumber'"
        
        try {
            $response = Get-CrmRecordsByFetch -conn $conn -Fetch $pagedFetch
            
            if ($response.CrmRecords.Count -gt 0) {
                $allResults += $response.CrmRecords
                $totalRecords += $response.CrmRecords.Count
                Write-Host "    Retrieved $($response.CrmRecords.Count) records (Total: $totalRecords)" -ForegroundColor Green
            }
            
            # Check if there are more records
            if ($response.CrmRecords.Count -lt $PageSize) {
                $moreRecords = $false
                Write-Host "  ✓ All records retrieved" -ForegroundColor Green
            }
            else {
                $pageNumber++
            }
        }
        catch {
            Write-Error "Error retrieving records: $_"
            exit 1
        }
    }
    
    if ($totalRecords -eq 0) {
        Write-Host "`n⚠ No records found matching the specified criteria." -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "`n✓ Retrieved $totalRecords total records" -ForegroundColor Green
    Write-Host "`nExporting to CSV: $OutputPath" -ForegroundColor Cyan
    
    # Convert to custom objects for better CSV export
    $exportData = $allResults | ForEach-Object {
        [PSCustomObject]@{
            'ID'                                = $_.admin_dlpimpactanalysisid
            'Name'                              = $_.admin_name
            'DLP Policy Name'                   = $_.admin_dlppolicyname
            'Decision'                          = $_.admin_decision
            'Decision Status'                   = $_.admin_decisionstatus
            'Conflicting Connector (Blocked)'   = $_.admin_conflictingconnectorblocked
            'Conflicting Connector (Business)'  = $_.admin_conflictingconnectorbusiness
            'Conflicting Connector (Non-Business)' = $_.admin_conflictingconnectornonbusiness
            'Impacted App'                      = $_.admin_impactedapp
            'Impacted Flow'                     = $_.admin_impactedflow
            'Business Impact'                   = $_.admin_businessimpact
            'Action Required On'                = $_.admin_actionrequiredon
            'Created On'                        = $_.createdon
            'Modified On'                       = $_.modifiedon
            'State'                             = $_.statecode
        }
    }
    
    # Export to CSV
    $exportData | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    
    Write-Host "✓ Export completed successfully!" -ForegroundColor Green
    Write-Host "`nExport Summary:" -ForegroundColor Cyan
    Write-Host "  Total Records: $totalRecords"
    Write-Host "  Output File: $OutputPath"
    Write-Host "  File Size: $([math]::Round((Get-Item $OutputPath).Length / 1MB, 2)) MB"
    
    # Provide summary statistics
    Write-Host "`nRecord Statistics:" -ForegroundColor Cyan
    $uniquePolicies = ($exportData | Select-Object -ExpandProperty 'DLP Policy Name' -Unique).Count
    Write-Host "  Unique DLP Policies: $uniquePolicies"
    
    $impactedApps = ($exportData | Where-Object { $_.'Impacted App' } | Measure-Object).Count
    $impactedFlows = ($exportData | Where-Object { $_.'Impacted Flow' } | Measure-Object).Count
    Write-Host "  Impacted Apps: $impactedApps"
    Write-Host "  Impacted Flows: $impactedFlows"
    
    if ($DLPPolicyName) {
        Write-Host "  Filtered by Policy: $DLPPolicyName"
    }
    if ($DaysBack) {
        Write-Host "  Filtered by Date: Last $DaysBack days"
    }
    
    Write-Host "`n✓ Done!" -ForegroundColor Green
}
catch {
    Write-Error "An error occurred: $_"
    Write-Error $_.Exception.Message
    Write-Error $_.ScriptStackTrace
    exit 1
}
finally {
    # Clean up connection
    if ($conn) {
        $conn.Dispose()
    }
}
