function Get-Website-Name
{
    param (
        [Parameter(Mandatory)] [String]$sourcesDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName
    )

    $websiteName = "NA"
    $solutionUnpackedFolder = "$sourcesDirectory\$repo\$solutionName\PowerPages"
    Write-Host "solutionUnpackedFolder - $solutionUnpackedFolder"
    if(Test-Path "$solutionUnpackedFolder")
    {
        $matchedFolders = Get-ChildItem "$solutionUnpackedFolder" -Directory | select Name
        Write-Host "matchedFolders - $matchedFolders"

        if($matchedFolders){
          $websiteName = $matchedFolders[0].Name
        }
    }
    else
    {
       Write-Host "Unpacked website folder unavailable. Path - $solutionUnpackedFolder"
    }
    return $websiteName
}

function Validate-Profile-Name
{
    param (
        [Parameter(Mandatory)] [String]$websiteRepoPath,
        [Parameter(Mandatory)] [String]$passedProfileName
    )

    $filesCount = 0
    $profileName = "NA"
    Write-Host "websiteRepoPath - $websiteRepoPath"
    $deploymentProfilePath = "$websiteRepoPath\deployment-profiles"
    if(Test-Path "$deploymentProfilePath")
    {
        $filesCount = (Get-ChildItem -Path "$deploymentProfilePath" | Where-Object { $_.Name -like "$passedProfileName.*" } | Measure-Object).Count
    }
    else
    {
       Write-Host "Deployment Profile folder unavailable under unpacked website folder. Path - $deploymentProfilePath"
    }

    Write-Host "Deployment Profile File Count - $filesCount"
    return $filesCount
}

function Create-or-Override-Profile-File
{
    param (
        [Parameter(Mandatory)] [String]$websiteRepoPath,
        [Parameter(Mandatory)] [String]$passedProfileName,
        [Parameter(Mandatory)] [String]$profileContent
    )

    $deploymentProfilePath = "$websiteRepoPath\deployment-profiles"

    # Create deployment Profile Path
    New-Item -ItemType Directory -Force -Path $deploymentProfilePath

    if (!(Test-Path "$deploymentProfilePath\$passedProfileName.deployment.yml"))
    {
       New-Item -path "$deploymentProfilePath" -name "$passedProfileName.deployment.yml" -type "file" -value "$profileContent"
       Write-Host "Created new yml file for $passedProfileName"
    } else {
      Set-Content -path "$deploymentProfilePath\$passedProfileName.deployment.yml" -value "$profileContent"
      Write-Host "Overriden the Content of yml file for $passedProfileName"
    }
}

function Clean-Website-Folder
{
    param (
        [Parameter(Mandatory)] [String]$sourcesDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName     
    )
    $portalWebsitePath = "$sourcesDirectory\$repo\$solutionName\PowerPages\"
    if(Test-Path "$portalWebsitePath"){
      Remove-Item "$portalWebsitePath\*" -Recurse -Force
    }
    else{
       Write-Host "Unpacked website folder unavailable. Path - $portalWebsitePath"
    }
}

function Fetch-Website-ID
{
    param (
        [Parameter()] [String]$websiteName,
        [Parameter()] [String]$serviceConnectionUrl,
        [Parameter()] [String]$token
    )
    Write-Host "websiteName - $websiteName"
    $websiteId = "NA"
    if("$websiteName" -ne "NA" -and "$websiteName" -ne "")
    {
        Write-Host "Portal 'Website ID' not provided as variable. Making API call."
        . "$env:POWERSHELLPATH/dataverse-webapi-functions.ps1"
        $dataverseHost = Get-HostFromUrl "$serviceConnectionUrl"
        # Fetch the Website by the 'Website name' passed from App (Exact Match)
        $odataQuery = "adx_websites?`$filter=adx_name eq '$websiteName'"    
        Write-Host "Portal odataQuery - $odataQuery"

        try{
            $response = Invoke-DataverseHttpGet $token $dataverseHost $odataQuery
        }
        catch{
            Write-Host "Error - $($_.Exception.Message)"
            # if Power Pages solutions are not installed in Dataverse. adx_websites table will not be created. Suppres the error.
        }

        if($null -ne $response.value -and $response.value.count -gt 0){
            $websiteId = $response.value[0].adx_websiteid
        }
        else{
            Write-Host "No sites found with the provided website name - $websiteName. Retry by correcting the solution name."
        }
    }
    Write-Host "websiteId - $websiteId"
    echo "##vso[task.setvariable variable=WebsiteId]$websiteId"
}

function Portal-Upload-With-Profile{
    param (
        [Parameter(Mandatory)] [String]$pacPath,
        [Parameter(Mandatory)] [String]$serviceConnectionUrl,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$tenantID,
        [Parameter(Mandatory)] [String]$websitePath,
        [Parameter(Mandatory)] [String]$profileName
    )
	
    $pacexepath = "$pacPath\pac.exe"
    if(Test-Path "$pacexepath")
    {
        # Trigger Auth
        Invoke-Expression -Command "$pacexepath auth create --url $serviceConnectionUrl --name ppdev --applicationId $clientId --clientSecret $clientSecret --tenant $tenantID"

        $pacCommand = "paportal upload --path $websitePath --deploymentProfile $profileName"
        Write-Host "Triggering Sync - $pacCommand"
        Invoke-Expression -Command "$pacexepath $pacCommand"
    }
}