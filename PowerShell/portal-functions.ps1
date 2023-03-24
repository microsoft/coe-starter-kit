function Get-Website-Name
{
    param (
        [Parameter(Mandatory)] [String]$sourcesDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName
    )

    $websiteName = "NA"
    $powerPagesFolderPath = "$sourcesDirectory\$repo\$solutionName\PowerPages"
    Write-Host "solutionUnpackedFolder - $powerPagesFolderPath"
    if(Test-Path "$powerPagesFolderPath")
    {
        $matchedFolders = Get-ChildItem "$powerPagesFolderPath" -Directory | select Name
        Write-Host "matchedFolders - $matchedFolders"

        if($matchedFolders){
          $websiteName = $matchedFolders[0].Name
        }
    }
    else
    {
       Write-Host "Unpacked website folder unavailable. Path - $powerPagesFolderPath"
    }
    return $websiteName
}

function Process-and-Download-Websites
{
    param (
        [Parameter(Mandatory)] [String]$sourcesDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$pacPath,
        [Parameter(Mandatory)] [String]$serviceConnectionUrl,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$tenantID,
        [Parameter(Mandatory)] [String]$websiteName,
        [Parameter()] [String]$token
    )
    $pacexepath = "$pacPath\pac.exe"
    $powerPagesFolderPath = "$sourcesDirectory\$repo\$solutionName\PowerPages"
    Write-Host "Power Pages folder Path - $powerPagesFolderPath"
    if(Test-Path "$pacexepath")
    {
        # Trigger Auth
        Invoke-Expression -Command "$pacexepath auth create --url $serviceConnectionUrl --name ppdev --applicationId $clientId --clientSecret $clientSecret --tenant $tenantID"

        # Split the WebsiteName by Comma
        $collWebsiteNames = $websiteName -split ","
        foreach ($websiteName in $collWebsiteNames) {
            Write-Host "validating the presence of website - $websiteName"
            # Make sure there is a website with the name
            $websiteId =  Get-Website-ID "$websiteName" "$serviceConnectionUrl" "$token"
            Write-Host "websiteId of $websiteName  - $websiteId"
            if($websiteId -ne "NA"){
                Write-Host "Triggering pac download"
                # Logic to download websites
                $portalDownloadCommand = "paportal download --path $powerPagesFolderPath --webSiteId $websiteId --overwrite"
                Write-Host "Executing portalDownloadCommand - $pacexepath $portalDownloadCommand"
                Invoke-Expression -Command "$pacexepath $portalDownloadCommand"
            }else{
                Write-Host "Website - $websiteName not found in maker Portal"
            }
        }
    }
    else{
        Write-Host "pac is unavailable"
    }
}

function Process-and-Upload-Websites
{
    param (
        [Parameter(Mandatory)] [String]$sourcesDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$environmentName,
        [Parameter(Mandatory)] [String]$pacPath,
        [Parameter(Mandatory)] [String]$serviceConnectionUrl,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$tenantID
    )

    $pacexepath = "$pacPath\pac.exe"
    $websiteName = "NA"
    $powerPagesFolderPath = "$sourcesDirectory\$repo\$solutionName\PowerPages"
    Write-Host "Power Pages folder Path - $powerPagesFolderPath"
    if(Test-Path "$pacexepath")
    {
        # Trigger Auth
        Invoke-Expression -Command "$pacexepath auth create --url $serviceConnectionUrl --name ppdev --applicationId $clientId --clientSecret $clientSecret --tenant $tenantID"

        if(Test-Path "$powerPagesFolderPath")
        {
            $websiteFolders = Get-ChildItem -Path $powerPagesFolderPath | Where-Object { $_.PSIsContainer }

            foreach ($websiteFolder in $websiteFolders) {
                $filesCount = 0
                $websiteName = $websiteFolder.Name
                $websiteFolderPath = $websiteFolder.FullName

                Write-Host "websiteName - $websiteName"
                Write-Host "websiteFolderPath - $websiteFolderPath"

                if(Test-Path "$websiteFolderPath"){
                    # Check if Deployment Profiles provided
                    $deploymentProfilePath = "$websiteFolderPath\deployment-profiles"
                    if(Test-Path "$deploymentProfilePath")
                    {
                        $filesCount = (Get-ChildItem -Path "$deploymentProfilePath" | Where-Object { $_.Name -like "$environmentName.*" } | Measure-Object).Count
                        Write-Host "DeploymentProfile folder available at - $deploymentProfilePath. Matching file count $filesCount"
                    }
                    else
                    {
                       Write-Host "Deployment Profile folder unavailable under unpacked website folder. Path - $deploymentProfilePath"
                    }

                    # Logic to upload websites
                    $portalUploadCommand = "paportal upload --path $websiteFolderPath"
                    if($filesCount -gt 0){
                        Write-Host "Uploading command with profile - $environmentName"
                        $portalUploadCommand = $portalUploadCommand + " --deploymentProfile $environmentName"
                    }

                    Write-Host "Executing portalUploadCommand - $pacexepath $portalUploadCommand"
                    Invoke-Expression -Command "$pacexepath $portalUploadCommand"
                }
                else{
                    Write-Host "websiteFolderPath - $websiteFolderPath unavailable in Repo"
                }
            }
        }
        else
        {
           Write-Host "PowerPages folder unavailable. Path - $powerPagesFolderPath"
        }
    }
    else{
        Write-Host "pac is unavailable"
    }
}

function Invoke-Validate-Profile-Name
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

function Invoke-Create-Or-Override-Profile-File
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

function Invoke-Clean-Website-Folder
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

function Get-Website-ID
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
    #echo "##vso[task.setvariable variable=WebsiteId]$websiteId"
    return $websiteId
}

function Invoke-Portal-Upload-With-Profile{
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