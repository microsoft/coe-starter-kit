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

$module = Get-Module -ListAvailable -Name PnP.PowerShell

if ($module) { 
  Write-Host 'INFO: PnP.PowerShell module is already installed.'
  if ($module.Version -lt [Version]'1.11.0') {
    Write-Host 'INFO: PnP.PowerShell module is not up to date. Updating module...'
    Update-Module -Name PnP.PowerShell
  }
  else {
    Write-Host 'INFO: PnP.PowerShell module is up to date.'
  }
}
else {
  ## Install Module
  Write-Host 'INFO: PnP.PowerShell module is not installed. Installing now...'
  Install-Module -Name PnP.PowerShell
}

try {
  ## Connect to SharePoint Online
  Write-Host 'INFO: Connecting to SharePoint Online'
  Write-Host 'INFO: Connecting to' $adminURL
  Connect-PnPOnline -Url $adminUrl -Interactive
  Write-Host 'INFO: Connected to' $adminURL
  
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
      Write-Host 'INFO: Site already exists, skipping creation of site...'

      ## Get current user
      $ctx = Get-PnPContext
      $ctx.Load($ctx.Web.CurrentUser)
      $ctx.ExecuteQuery()
      $currentUser = $ctx.Web.CurrentUser.Email

      ## Add current user as site owner
      Set-PnPTenantSite -Identity $newSiteURL -Owners @($ownerEmail, $currentUser)

      Write-Host 'INFO: Connecting to site...'
      Connect-PnPOnline -Url $newSiteURL -Interactive
      Write-Host 'INFO: Connected to' $newSiteURL'.'

      Write-Host 'INFO: Deploying template...'
    
      ## Get Date
      $date = Get-Date
      $year = $date.Year
      $month = $date.Month + 1
      $traceDate = Get-Date -Format 'yyyy-MM-dd'

      ## Turn trace log on
      Set-PnPTraceLog -On -LogFile $traceDate.txt

      ## Import Template
      Invoke-PnPSiteTemplate -Path template.pnp -Parameters @{'CompanyName' = $companyName; 'Year' = $year; 'Month' = $month } -ErrorAction Stop

      Write-Host 'SUCCESS: Deployment of Power Platform Hub complete!' -ForegroundColor Green
      Write-Host 'Go to the site:' $newSiteUrl -ForegroundColor Green

      exit
    }    
  }
  catch {
    Set-PnPTraceLog -Off
    Write-Host 'ERROR: An error occurred.' -ForegroundColor Red
    Write-Host 'ERROR: Deployment of Power Platform Hub failed!' -ForegroundColor Red
    exit
  }

  try {
    Write-Host 'INFO: Wait 15 seconds to make sure the site is ready...'
    
    ## Wait 15 seconds to make sure the site is ready
    Start-Sleep -Seconds 15

    ## Get current user
    $ctx = Get-PnPContext
    $ctx.Load($ctx.Web.CurrentUser)
    $ctx.ExecuteQuery()
    $currentUser = $ctx.Web.CurrentUser.Email

    ## Add current user as site owner
    Set-PnPTenantSite -Identity $newSiteURL -Owners @($ownerEmail, $currentUser)

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
    Write-Host 'INFO: Deploying template...'
    
    ## Get Date
    $date = Get-Date
    $year = $date.Year
    $month = $date.Month + 1
    $traceDate = Get-Date -Format 'yyyy-MM-dd_HH:mm:ss'

    ## Turn trace log on
    Set-PnPTraceLog -On -LogFile $traceDate.txt

    ## Import Template
    Invoke-PnPSiteTemplate -Path template.pnp -Parameters @{'CompanyName' = $companyName; 'Year' = $year; 'Month' = $month } -ErrorAction Stop
  }
  catch {
    Set-PnPTraceLog -Off
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
