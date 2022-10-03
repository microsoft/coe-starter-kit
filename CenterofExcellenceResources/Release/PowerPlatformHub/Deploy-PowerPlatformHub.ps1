## Set variables for deploying template
$adminTenantName = 'contoso'
$adminURL = 'https://' + $adminTenantName + '-admin.sharepoint.com'
$companyName = 'Contoso'
$lcid = 1033
$newSiteURL = 'https://' + $adminTenantName + '.sharepoint.com/sites/powerplatformhub'
$ownerEmail = 'owner@contoso.com'
$siteTemplate = 'SITEPAGEPUBLISHING#0'
$siteTitle = 'Power Platform Hub'
$timeZone = 2

if (Get-Module -ListAvailable -Name PnP.PowerShell) { 
  Write-Host 'INFO: PnP.PowerShell module is already installed.' 
}
else {
  ## Install Module
  Write-Host 'INFO: PnP.PowerShell module is not installed. Installing now...'
  Install-Module -Name PnP.PowerShell
}
try {
  ## Connect to SharePoint Online
  Write-Host 'INFO: Connecting to SharePoint Online'
  Connect-PnPOnline -Url $adminUrl -Interactive
  
  try {
    # Check if site exists
    $site = Get-PnPTenantSite -Filter "Url -like '$newSiteURL'" -ErrorAction SilentlyContinue
    
    if (!$site) {
      # Check if site exists in recycle bin
      $recycledSite = Get-PnPTenantDeletedSite -Identity $newSiteURL -ErrorAction SilentlyContinue
      $recycledSiteStatus = $recycledSite.Status
      if (!$recycledSiteStatus) {
        Write-Host 'INFO: Creating new site...'

        ## Create new site
        New-PnPTenantSite -Template $siteTemplate -Title $siteTitle -Url $newSiteUrl  -Lcid $lcid -Owner $ownerEmail -TimeZone $timeZone -Wait        
      }
      else {
        Write-Host 'ERROR: Site is lingering in the recycle bin (Status = ' $recycledSiteStatus '). Remove the site from the recycle bin before running this script.' -ForegroundColor Red
        Write-Host 'ERROR: Deployment of Power Platform Hub failed!' -ForegroundColor Red
        exit
      }
    }
    else {
      Write-Host 'ERROR: Site exist. Please remove the site or choose a different URL for the site.' -ForegroundColor Red
      Write-Host 'ERROR: Deployment of Power Platform Hub failed!' -ForegroundColor Red
      exit
    }    
  }
  catch {
    Write-Host 'ERROR: An error occurred during checks if site exists.' -ForegroundColor Red
    Write-Host 'ERROR: Deployment of Power Platform Hub failed!' -ForegroundColor Red
    exit
  }

  try {
    ## Connect to the newly created site
    Write-Host 'INFO: Connecting to newly created site'
    Connect-PnPOnline -Url $newSiteUrl -Interactive    
  }
  catch {
    Write-Host 'ERROR: An error occurred during connecting to the newly created site.' -ForegroundColor Red
    Write-Host 'ERROR: Deployment of Power Platform Hub failed!' -ForegroundColor Red
    exit
  }

  try {
    Write-Host 'INFO: Wait 15 seconds to make sure the site is ready...'
    
    ## Wait 15 seconds to make sure the site is ready
    Start-Sleep -Seconds 15

    Write-Host 'INFO: Deploying template...'
    
    ## Get Date
    $date = Get-Date
    $year = $date.Year
    $month = $date.Month + 1

    ## Import Template
    Invoke-PnPSiteTemplate -Path template.pnp -Parameters @{'CompanyName' = $companyName; 'Year' = $year; 'Month' = $month } -ErrorAction Stop
  }
  catch {
    Write-Host 'ERROR: Template deployment failed with error.' $Error -ForegroundColor Red
    Write-Host 'ERROR:' $Error -ForegroundColor Red
    Write-Host 'ERROR: Removing site collection...' -ForegroundColor Red
    Remove-PnPTenantSite -Url $newSiteUrl -Force
    Remove-PnPTenantDeletedSite -Identity $newSiteUrl -Force
    Write-Host 'ERROR: Site collection removed. Restart deployment to roll out the Power Platform Hub.' -ForegroundColor Red
    Write-Host 'ERROR: Deployment of Power Platform Hub failed!' -ForegroundColor Red
    exit
  } 
  Write-Host 'SUCCESS: Deployment of Power Platform Hub complete!' -ForegroundColor Green
  Write-Host 'Go to the site:' $newSiteUrl -ForegroundColor Green
}
catch {
  Write-Host 'ERROR: Deployment of Power Platform Hub failed!' -ForegroundColor Red
  exit
}
