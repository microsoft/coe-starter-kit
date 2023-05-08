<#
This function adds the managed solutions to deployment packager file (i.e.,PD Package project).
This step is needed to for App Source Packaging.
#>
function Invoke-Add-Solution-References-To-Package-Project{
     param (
        [Parameter(Mandatory)] [String]$pacPath,
        [Parameter(Mandatory)] [String]$appSourcePackageProjectPath,
        [Parameter(Mandatory)] [String]$solutionsFolderPath,
        [Parameter(Mandatory)] [String]$appSourceInputFilePath
     )

     if(Test-Path $solutionsFolderPath){
         if(Test-Path $appSourcePackageProjectPath)
         {
            $pacexepath = "$pacPath\pac.exe"
            if(Test-Path "$pacexepath")
            {
                Get-ChildItem "$solutionsFolderPath" | Where-Object {$_.Name -match '_managed.zip'} |
                #Get-ChildItem "$solutionsFolderPath" -Filter *.managed.zip | 
                Foreach-Object {
                    $solutionName = $_.Name
                    $solutionPath = $_.FullName
                    Write-Host "Fetching import order of Solution - " $solutionName
                    $importOrder = Get-Solution-Import-Order "$appSourceInputFilePath" "$solutionName"
                    $pacCommand = "package add-solution --path $solutionPath --import-order $importOrder --import-mode async"
                    Write-Host "Pac Command - $pacCommand"
                    if($importOrder -ne 0){
                        Write-Host "Pointing to $appSourcePackageProjectPath path" 
                        Set-Location -Path $appSourcePackageProjectPath
                        Invoke-Expression -Command "$pacexepath $pacCommand"
                    }
                    else{
                        Write-Host "Invalid import order for Solution - $solutionName"
                    }

					# Solution Anchor Name in input.xml file can be Solution Name with Import order 1
                    if($importOrder -eq 1){
						Write-Host "Setting Solution Anchor Name to $solutionName"
                        Write-Host "##vso[task.setVariable variable=SolutionAnchorName]$solutionName"
                    }					
                }
            }
            else{
                Write-Host "Invalid pac exe path $pacexepath"
            }
         }
         else{
              Write-Host "Invalid app source folder path - $appSourcePackageProjectPath"
         }
     }
    else{
        Write-Host "Invalid solutions folder path - $solutionsFolderPath"
    }
}

<#
This is a child function of Invoke-Add-Solution-References-To-Package-Project function.
Matches the solution name and returns the 'import order'
#>
function Get-Solution-Import-Order{
    param(
        [Parameter(Mandatory)] [String]$appSourceInputFilePath,
        [Parameter(Mandatory)] [String]$solutionName       
    )

    $importOrder = 0
    if(Test-Path "$appSourceInputFilePath"){
        $appSourceInputData = Get-Content "$appSourceInputFilePath" | ConvertFrom-Json        
        foreach($solution in $appSourceInputData.Configdatastorage.Solutions){
          if("$solutionName" -match $solution.Name){
              $importOrder = $solution.Importorder
              Write-Host "Given Solution - $solutionName MACTHED with appSource Solution - "$solution.Name
              break;
          }
          else{
             #Write-Host "Given Solution - $solutionName not matched with appSource Solution - "$solution.Name
          }
        }
    }
    else{
        Write-Host "appSourceInputPath is unavailble at {$appSourceInputFilePath}"
    }

    Write-Host "importOrder - $importOrder"
    return $importOrder;
}

function Invoke-Trigger-Dotnet-Publish{
    param(
        [Parameter(Mandatory)] [String]$appSourcePackageProjectPath
    )

    Write-Host "Pointing to package project folder path - " $appSourcePackageProjectPath
    if(Test-Path $appSourcePackageProjectPath){
        Set-Location -Path $appSourcePackageProjectPath
        dotnet publish
    }
    else{
        Write-Host "Path unavailble; $appSourcePackageProjectPath"
    }
}

# Copy the .zip folder generated in either bin\debug or bin\release and move it to "AppSourcePackageProject\AppSourceAssets"
function Copy-Published-Assets-To-AppSourceAssets{
    param(
        [Parameter(Mandatory)] [String]$appSourcePackageProjectPath,
        [Parameter(Mandatory)] [String]$appSourceAssetsPath,
        [Parameter(Mandatory)] [String]$packageFileName,
        [Parameter(Mandatory)] [String]$releaseAssetsDirectory
    )

    $pdpkgFileCount = 0
    $appSourcePackageFound = $false

    if(Test-Path "$appSourcePackageProjectPath\bin\Release"){
		$binPath = "bin\Release"
        $pdpkgFileCount = (Get-ChildItem "$appSourcePackageProjectPath\$binPath" -Filter *pdpkg.zip | Measure-Object).Count
        Write-Host "Count of .pdpkg.zip from $appSourcePackageProjectPath\$binPath - "$pdpkgFileCount
        if($pdpkgFileCount -gt 0){
            Copy-Pdpkg-File "$appSourcePackageProjectPath" "$packageFileName" "$appSourceAssetsPath" "$binPath"           
            $appSourcePackageFound = $true
        }
        else{
            Write-Host "pdpkg.zip not found under $appSourcePackageProjectPath\$binPath"
        }
    }

    if(($pdpkgFileCount -eq 0) -and (Test-Path "$appSourcePackageProjectPath\bin\Debug")){
		$binPath = "bin\Debug"
        $pdpkgFileCount = (Get-ChildItem "$appSourcePackageProjectPath\$binPath" -Filter *pdpkg.zip | Measure-Object).Count
        Write-Host "Count of .pdpkg.zip from $appSourcePackageProjectPath\$binPath - "$pdpkgFileCount
        if($pdpkgFileCount -gt 0){
            Copy-Pdpkg-File "$appSourcePackageProjectPath" "$packageFileName" "$appSourceAssetsPath" "$binPath"           
            $appSourcePackageFound = $true
        }
        else{
            Write-Host "pdpkg.zip not found under $appSourcePackageProjectPath\$binPath"
        }
    }

    if($pdpkgFileCount -eq 0){
        Write-Host "pdpkg.zip not found; Exiting"
    }

    Write-Host "##vso[task.setVariable variable=AppSourcePackageFound]$appSourcePackageFound"
}

<#
This function creates a new App Source folder.
Compresses package deployer assets and moves them to newly created folder.
#>
function Invoke-Pack-And-Move-Assets-To-AppSourcePackage{
    param(
        [Parameter(Mandatory)] [String]$appSourceAssetsPath,
        [Parameter(Mandatory)] [String]$appSourcePackagePath,
        [Parameter(Mandatory)] [String]$releaseZipName,
        [Parameter(Mandatory)] [String]$appSourcePackageFolderName
    )

    # Create a new folder in Destination
    if(!(Test-Path "$appSourcePackagePath\$appSourcePackageFolderName")){
        Write-Host "Creating a new folder $appSourcePackageFolderName under $appSourcePackagePath"
        New-Item -Path "$appSourcePackagePath" -Name "$appSourcePackageFolderName" -ItemType "directory"
    }

    $destinationPath = "$appSourcePackagePath\$appSourcePackageFolderName\$releaseZipName"
    if(Test-Path "$appSourceAssetsPath")
    {
        if(Test-Path "$appSourcePackagePath\$appSourcePackageFolderName"){
            Write-Host "Packaging assets from $appSourceAssetsPath and creating $destinationPath"
            Compress-Archive -Path "$appSourceAssetsPath\*" -CompressionLevel Optimal -DestinationPath "$destinationPath" -Force
        }
        else{
            Write-Host "Invalid appSourcePackagePath path - $appSourcePackagePath\$appSourcePackageFolderName"
        }
    }
    else{
        Write-Host "Invalid appSourceAssetsPath path - $appSourceAssetsPath" 
    }
}

<#
This function updates the 'Input.xml' file.
Sets StartDate,EndDate and SolutionAnchorName.
#>
function Update-Input-File{
    param (
        [Parameter(Mandatory)] [String]$inputFilePath,
        [Parameter(Mandatory)] [String]$packageFileName,
        [Parameter()] [String]$solutionAnchorName
    )

    if(Test-Path "$inputFilePath"){
        [xml]$xmlDoc = Get-Content -Path $inputFilePath

        $todayDate = (Get-Date).ToString('MM-dd-yyyy')
        $futureDate = (Get-Date).AddMonths(12).ToString('MM-dd-yyyy')
        $xmlDoc.PvsPackageData.StartDate = $todayDate
        $xmlDoc.PvsPackageData.EndDate = $futureDate
        $xmlDoc.PvsPackageData.PackageFile = "$packageFileName"
		$xmlDoc.PvsPackageData.SolutionAnchorName = "$solutionAnchorName"
        Write-Host "Setting StartDate as $todayDate and EndDate as $futureDate and PackageFile as $packageFileName and Solution Anchor Name as $solutionAnchorName"
        $xmlDoc.save("$inputFilePath")
    }
    else{
        Write-Host "Input.xml unavailable at - $inputFilePath"
    }
}

<#
This function installs the PowerApps.CLI nuget package.
#>
function Install-Pac-Cli{
	param(
        [Parameter()] [String]$nugetPackageVersion		
	)
    $nugetPackage = "Microsoft.PowerApps.CLI"
    $outFolder = "pac"
    if($nugetPackageVersion -ne '') {
        nuget install $nugetPackage -Version $nugetPackageVersion -OutputDirectory $outFolder
    }
    else {
        nuget install $nugetPackage -OutputDirectory $outFolder
    }
    $pacNugetFolder = Get-ChildItem $outFolder | Where-Object {$_.Name -match $nugetPackage + "."}
    $pacPath = $pacNugetFolder.FullName + "\tools"
    Write-Host "##vso[task.setvariable variable=pacPath]$pacPath"	
}

<#
This function copies the generated package deployer file (i.e., pdpkg.zip).
Moves the file to ReleaseAssets folder.
#>
function Copy-Pdpkg-File{
    param (
        [Parameter(Mandatory)] [String]$appSourcePackageProjectPath,
        [Parameter(Mandatory)] [String]$packageFileName,
        [Parameter(Mandatory)] [String]$appSourceAssetsPath,
        [Parameter(Mandatory)] [String]$binPath
    )

    Write-Host "pdpkg file found under $appSourcePackageProjectPath\$binPath"
    Write-Host "Copying pdpkg.zip file to $appSourceAssetsPath\$packageFileName"
            
    Get-ChildItem "$appSourcePackageProjectPath\$binPath" -Filter *pdpkg.zip | Copy-Item -Destination "$appSourceAssetsPath\$packageFileName" -Force -PassThru
    # Copy pdpkg.zip file to ReleaseAssets folder
    if(Test-Path "$releaseAssetsDirectory"){
        Write-Host "Copying pdpkg file to Release Assets Directory"
        Get-ChildItem "$appSourcePackageProjectPath\$binPath" -Filter *pdpkg.zip | Copy-Item -Destination "$releaseAssetsDirectory" -Force -PassThru
    }
    else{
        Write-Host "Release Assets Directory is unavailable to copy pdpkg file; Path - $releaseAssetsDirectory"
    }
}