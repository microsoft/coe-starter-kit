## Set Variables for setting DLP error setting
$newSiteURL = 'https://contoso.sharepoint.com/sites/PowerPlatformHub'
$supportEmail = 'support@contoso.com'
$tenantId = '00000000-0000-0000-0000-000000000000'

if ($psversiontable.PSVersion -eq [Version]'5.0' -or [Version]'5.1' ) { 
  
  $module = Get-Module -ListAvailable -Name Microsoft.PowerApps.Administration.PowerShell
  $dlpPage = $newSiteURL + '/SitePages/Data-Loss-Prevention-(DLP)-Policies.aspx'

  if ($module) {
    Write-Host 'INFO: Microsoft.PowerApps.Administration.PowerShell module is already installed.'
    if ($module.Version -lt [Version]'2.0.0') {
      Write-Host 'INFO: Microsoft.PowerApps.Administration.PowerShell module is not up to date. Updating module...'
      Update-Module -Name Microsoft.PowerApps.Administration.PowerShell
    }
    else {
      Write-Host 'INFO: Microsoft.PowerApps.Administration.PowerShell module is up to date.'
    }
  } 
  else {
    Write-Host 'INFO: Microsoft.PowerApps.Administration.PowerShell module is not installed. Installing now...'
    ## Install Module
    Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
  }
  try {
    Write-Host 'INFO: Connect to Power Platform'
    Add-PowerAppsAccount
  
    try {
      Write-Host 'INFO: Get DLP error settings'
      $errorSettings = Get-PowerAppDlpErrorSettings -TenantId $tenantId
      if (!$errorSettings) {
        ## Add site to DLP Error Settings if it doesn't exist
        Write-Host 'INFO: DLP error settings not found. Adding DLP error settings...'
        New-PowerAppDlpErrorSettings -TenantId $tenantId -ErrorSettings @{
          ErrorMessageDetails = @{
            enabled = $True
            url     = $dlpPage
          }
          ContactDetails      = @{
            enabled = $True
            email   = $supportEmail
          }
        } | Out-Null
      }
      else {
        Write-Host 'INFO: DLP error settings already exist. Updating settings...'
        Set-PowerAppDlpErrorSettings -TenantId $tenantId -ErrorSettings @{
          ErrorMessageDetails = @{
            enabled = $True
            url     = $dlpPage
          }
          ContactDetails      = @{
            enabled = $True
            email   = $supportEmail
          }
        } | Out-Null
      }
    }
    catch {
      Write-Host 'ERROR: An error occurred during adding or updating the site to the DLP Error Settings.' -ForegroundColor Red
      exit
    } 
  }
  catch {
    Write-Host 'ERROR: An error occurred during connecting to the Power Platform.' -ForegroundColor Red
    exit
  }
  Write-Host 'SUCCESS: DLP Error Settings successfully updated or created.' -ForegroundColor Green
  exit
}
else {
  Write-Host 'ERROR: This script requires PowerShell 5.0 or 5.1. You are running '$($psversiontable.PSVersion) -ForegroundColor Red
  exit
}
