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

function Clean-Website-Folder
{
    param (
        [Parameter(Mandatory)] [String]$sourcesDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,        
        [Parameter(Mandatory)] [String]$websiteName
    )
    $portalWebsitePath = "$sourcesDirectory\$repo\$solutionName\PowerPages\$websiteName\"
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