## Set Variables for setting DLP error setting
$newSiteURL = 'https://contoso.sharepoint.com/sites/powerplatformhub'
$supportEmail = 'support@contoso.com'
$tenantId = '00000000-0000-0000-0000-000000000000'

if ($psversiontable.PSVersion -ne [Version]'5.0') { 
  
  if (Get-Module -ListAvailable -Name PnP.PowerShell) {
    Write-Host 'Microsoft.PowerApps.Administration.PowerShell module is already installed.'
  } 
  else {
    Write-Host 'Microsoft.PowerApps.Administration.PowerShell module is not installed. Installing now...'
    ## Install Module
    Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
  }
  try {
    Write-Host 'Connect to Power Platform'
    Add-PowerAppsAccount
  
    Write-Host 'Adding site to DLP Error Settings'
    New-PowerAppDlpErrorSettings -TenantId $tenantId -ErrorSettings @{
      ErrorMessageDetails = @{
        enabled = $True
        url     = $newSiteURL
      }
      ContactDetails      = @{
        enabled = $True
        email   = $supportEmail
      }
    }
    Write-Host 'Adding site to DLP Error Settings complete!' -ForegroundColor Green   
  }
  catch {
    Write-Host 'An error occurred during adding the site to the DLP Error Settings.' -ForegroundColor Red
  }
  Write-Host 'Script done! :)' -ForegroundColor Green
}
else {
  Write-Host "This script requires PowerShell 5.0 or higher. You are running $($psversiontable.PSVersion)." -ForegroundColor Red
}