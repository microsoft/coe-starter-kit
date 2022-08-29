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