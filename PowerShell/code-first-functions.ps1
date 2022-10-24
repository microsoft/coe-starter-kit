function npm-install-pcf-Projects{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory
    )

      $pcfProjectFiles = Get-ChildItem -Path $buildSourceDirectory -Filter *.pcfproj -Recurse
      foreach($pcfProj in $pcfProjectFiles)
      {     
        Write-Host "fullPath - "$pcfProj.FullName
        $fullPath = $pcfProj.FullName
        $pcfProjectRootPath = [System.IO.Path]::GetDirectoryName($fullPath)
              
        Write-Host "Dir Name - "$pcfProjectRootPath
        npm ci $pcfProjectRootPath --prefix $pcfProjectRootPath    
      }   
}

function npm-build-pcf-Projects{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo
    )

      $pcfProjectFiles = Get-ChildItem -Path "$buildSourceDirectory\$repo" -Filter *.pcfproj -Recurse
      foreach($pcfProj in $pcfProjectFiles)
      {     
        Write-Host "fullPath - " $pcfProj.FullName
        $fullPath = $pcfProj.FullName
        $pcfProjectRootPath = [System.IO.Path]::GetDirectoryName($fullPath)
              
        Write-Host "Dir Name - " $pcfProjectRootPath
        Set-Location -Path $pcfProjectRootPath
        # npm run build 
        npm run build -- --mode Release
      } 
}

function pcf-Projects-install-npm{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo
    )

      $pcfProjectFiles = Get-ChildItem -Path "$buildSourceDirectory\$repo" -Filter *.pcfproj -Recurse
      foreach($pcfProj in $pcfProjectFiles)
      {
        $fullPath = $pcfProj.FullName
        # Point cmd to pcfproj directory
        set-cmd-Path "$fullPath"
        
        npm install
      } 
}

function set-cmd-Path{
     param (
            [Parameter(Mandatory)] [String]$filePath
     )

    If(Test-Path "$filePath")
    {
        $folderPath = [System.IO.Path]::GetDirectoryName("$filePath")
              
        Write-Host "Dir Name - " $folderPath
        Set-Location -Path $folderPath
    }
}

function add-codefirst-projects-to-cdsproj{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$pacPath
    )
    if (-not ([string]::IsNullOrEmpty($pacPath)) -and (Test-Path "$pacPath\pac.exe"))
    {
        Write-Host "Executing Pac Auth List command"
        $pacexepath = "$pacPath\pac.exe"
        $authCommand = "auth list"
        Write-Host "Pac command - $pacexepath $authCommand"

        Invoke-Expression -Command "$pacexepath $authCommand"

        # Set location to .cdsproj Path
        $cdsProjPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName.cdsproj"
        Write-Host "cdsProjPath - $cdsProjPath"
        if(Test-Path $cdsProjPath)
        {
            Write-Host "Cds Proj File Found!!!"
            $cdsProjectRootPath = [System.IO.Path]::GetDirectoryName($cdsProjPath)
            Set-Location -Path $cdsProjectRootPath
          
          Write-Host "Adding .pcf project references to cdsproj"
          # Get all pcfproject files under Repo/Commited Solution folder
          $pcfProjectFiles = Get-ChildItem -Path "$buildSourceDirectory\$repo\$solutionName" -Filter *.pcfproj -Recurse
          foreach($pcfProj in $pcfProjectFiles)
          {     
            Write-Host "Adding Reference of Pcf Project - " $pcfProj.FullName
            $pcfProjectPath = $pcfProj.FullName

            $addReferenceCommand = "solution add-reference -p $pcfProjectPath"
            Write-Host "Add Reference Command - $addReferenceCommand"
            Invoke-Expression -Command "$pacexepath $addReferenceCommand"
          } 

          Write-Host "Adding Plugin (i.e.,.csproj) references to cdsproj"
          # Skip adding plugin projects if 'Plugin Assembly' is not part of Dataverse solution
          $unpackedPluginAssemblyPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\src\PluginAssemblies"
          if(Test-Path "$unpackedPluginAssemblyPath"){
              # Get all .csproj files under Repo/Commited Solution folder
              $csProjectFiles = Get-ChildItem -Path "$buildSourceDirectory\$repo\$solutionName" -Filter *.csproj -Recurse
              foreach($csProject in $csProjectFiles)
              {     
                Write-Host "Adding Reference of Plugin Project - " $csProject.FullName
                # Add only Plugin type csproj; Skip others
                $csProjectPath = $csProject.FullName

                # Read csproj xml to determin project type
                [xml]$xmlDoc = Get-Content -Path $csProjectPath
                $tagPowerAppsTargetsPath = $xmlDoc.Project.PropertyGroup.PowerAppsTargetsPath

                # 'PowerAppsTargetsPath' tag is only availble in plugin project generate via 'pac plugin init'
                if(-not [string]::IsNullOrWhiteSpace($tagPowerAppsTargetsPath)){
                    $addReferenceCommand = "solution add-reference -p $csProjectPath"
                    Write-Host "Add Reference Command - $addReferenceCommand"
                    Invoke-Expression -Command "$pacexepath $addReferenceCommand"
                }
                else{
                    Write-Host "Not a plug-in project; Skipping add reference to cdsproj; Path - $csProjectPath"
                }
              }
          }
          else
          {
                Write-Host "PluginAssemblies folder unavailble in unpacked solution"
          }
        }
        else
        {
            Write-Host "Cds Proj File Not Found!!!"
        }
    }
    else
    {
        Write-Host "pac not installed!!!"
    }
}

function check-code-first-components{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName
    )
    $path = "$buildSourceDirectory\$repo\$solutionName"
    $totalCSproj = (Get-ChildItem -Path $path -force -Recurse | Where-Object Extension -eq '.csproj' | Measure-Object).Count
    $totalpcfproj = (Get-ChildItem -Path $path -force -Recurse | Where-Object Extension -eq '.pcfproj' | Measure-Object).Count
    [bool] $isCSProjExists = ($totalCSproj -gt 0)
    [bool] $isPCFProjExists = ($totalpcfproj -gt 0)
    [bool] $isCodeFirstProjectExists = ($isCSProjExists -or $isPCFProjExists)
    Write-Host "##vso[task.setvariable variable=pluginsexists;]$isCSProjExists"
    Write-Host "##vso[task.setvariable variable=pcfsexists;]$isPCFProjExists"
    Write-Host "##vso[task.setvariable variable=codefirstexists;]$isCodeFirstProjectExists"
}

function set-pac-tools-path{
    param (
        [Parameter(Mandatory)] [String]$agentOS
    )

   if ($agentOS -eq "Linux") {
       $pacToolsPath = $env:POWERPLATFORMTOOLS_PACCLIPATH + "/pac_linux/tools"
   }
   else {
       $pacToolsPath = $env:POWERPLATFORMTOOLS_PACCLIPATH + "\pac\tools"
   } 

    echo "##vso[task.setvariable variable=pacPath]$pacToolsPath"
}

function pac-authenticate{
    param (
        [Parameter(Mandatory)] [String]$serviceConnectionUrl,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$tenantID,
        [Parameter(Mandatory)] [String]$pacPath
    )
    if(Test-Path "$pacPath\pac.exe")
    {
        $pacexepath = "$pacPath\pac.exe"
        Invoke-Expression -Command "$pacexepath auth create --url $serviceConnectionUrl --name ppdev --applicationId $clientId --clientSecret $clientSecret --tenant $tenantID"
    }
    else
    {
        Write-Host "pac.exe NOT found"
    }

    return $pacexepath
}

function clone-or-sync-solution{
    param (
        [Parameter(Mandatory)] [String]$serviceConnectionUrl,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$tenantID,
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$pacPath,
        [Parameter(Mandatory)] [String]$buildDirectory
    )
	
	$legacyFolderPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage"
    $pacexepath = "$pacPath\pac.exe"
    if(Test-Path "$pacexepath")
    {
        # Trigger Auth
        Invoke-Expression -Command "$pacexepath auth create --url $serviceConnectionUrl --name ppdev --applicationId $clientId --clientSecret $clientSecret --tenant $tenantID"
        $unpackfolderpath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage"

        # Trigger Clone or Sync
        #$cdsProjPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName\$solutionName.cdsproj"
        #$cdsProjFolderPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName"
        $cdsProjPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName.cdsproj"
        $cdsProjFolderPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage"
        # If .cds project file exists (i.e., Clone performed already) trigger Sync
        if(Test-Path "$cdsProjPath")
        {
            Write-Host "Cloned solution available; Triggering Solution Sync"
            $cdsProjfolderPath = [System.IO.Path]::GetDirectoryName("$cdsProjPath")
            Write-Host "Pointing to cdsproj folder path - " $cdsProjfolderPath
            Set-Location -Path $cdsProjfolderPath
            $syncCommand = "solution sync -pca true -p Both"
            Write-Host "Triggering Sync - $syncCommand"
            Invoke-Expression -Command "$pacexepath $syncCommand"
        }
        else {
            if(Test-Path "$legacyFolderPath"){ # Legacy folder structure
				Write-Host "Deleting legcay folder path - $legacyFolderPath"
                # Delete "SolutionPackage" folder
                Remove-Item "$legacyFolderPath" -recurse -Force
            }

            # Trigger Clone
            $cloneCommand = "solution clone -n $solutionName -pca true -o ""$unpackfolderpath"" -p Both"
            Write-Host "Clone Command - $pacexepath $cloneCommand"
            Invoke-Expression -Command "$pacexepath $cloneCommand"
        }
        
		If(Test-Path "$cdsProjFolderPath\$solutionName")
		{
		    # Move items from SolutionPackage/Solution folder to SolutionPackage
            Write-Host "Moving items from $cdsProjFolderPath\$solutionName to $cdsProjFolderPath"
            Get-ChildItem -Path "$cdsProjFolderPath\$solutionName" | Copy-Item -Destination "$cdsProjFolderPath" -Recurse -Container
            Write-Host "Removing redundant folder $cdsProjFolderPath\$solutionName"
            # Remove the redundant SolutionPackage/Solution folder
            Remove-Item "$cdsProjFolderPath\$solutionName" -Recurse
		}
    }
}

function add-packagetype-node-to-cdsproj{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName
    )
    #$cdsProjPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName\$solutionName.cdsproj"
    $cdsProjPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName.cdsproj"

    if(Test-Path $cdsProjPath){
        [xml]$xmlDoc = Get-Content -Path $cdsProjPath

        # Skip logic if 'Solution Package Type' node already exists'
        $solutionPackageType = $xmlDoc.Project.PropertyGroup.SolutionPackageType

        if($solutionPackageType -eq $null){
            Write-Host "Adding SolutionPackageType='Both' node"
            $newPropertyGroup = $xmlDoc.Project.AppendChild($xmlDoc.CreateElement("PropertyGroup",$xmlDoc.Project.NamespaceURI));
            $newSolPkgType = $newPropertyGroup.AppendChild($xmlDoc.CreateElement("SolutionPackageType",$xmlDoc.Project.NamespaceURI));
            $newSolPkgTypeTextNode = $newSolPkgType.AppendChild($xmlDoc.CreateTextNode("Both"));

            $xmlDoc.save("$cdsProjPath")
        }
        else
        {
            Write-Host "Solution Package Type' node already exists. Value - $solutionPackageType"
        }
    }
    else{
        Write-Host "cdsproj file unavailble at - $cdsProjPath"
    }
}

function restructure-legacy-folders{
    param (
        [Parameter(Mandatory)] [String]$artifactStagingDirectory,
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$pacPath,
        [Parameter(Mandatory)] [String]$serviceConnection,
        [Parameter(Mandatory)] [String]$buildDirectory
    )
    #$cdsProjPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName\$solutionName.cdsproj"
    $cdsProjPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName.cdsproj"

    # Legacy folder structure "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\{unpackedcomponents}"
    # New folder structure "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName\src\{unpackedcomponents}"
    if(-not (Test-Path $cdsProjPath)){
        # Get Publisher Name
        $publisherName = get-publisher-name "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\Other\Solution.xml"
        # Get Prefix Name
        $publisherPrefix = get-publisher-prefix "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\Other\Solution.xml"

        Write-Host "publisherName - $publisherName"
        Write-Host "publisherPrefix - $publisherPrefix"

        # Move unpacked files from legacy to new folder
        # While moving Destination path cannot be a subdirectory of the source
        # Hence copy files to temp location first and then to new folder location
        $sourceDirectory  = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\"
        $tempSolPackageDirectory  = "$buildDirectory\temp_SolutionPackage"
        Write-Host "Moving files to temp directory"
        Get-ChildItem -Path "$sourceDirectory" -Recurse | Move-Item -Destination "$tempSolPackageDirectory" -Force

        # Create new folder structure
        #New-Item -ItemType "directory" -Path "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName\src"
        New-Item -ItemType "directory" -Path "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\src"

        # Move files from temp to new folder
        #$destinationDirectory = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName\src\"
        $destinationDirectory = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\src\"
        Write-Host "Moving files to $destinationDirectory directory"
        Get-ChildItem -Path "$tempSolPackageDirectory" -Recurse | Move-Item -Destination "$destinationDirectory" -Force

        # Generate .cdsproj file by triggering Clone
        $temp_init_path = "$buildDirectory\temp_init"

        $solInitCommand = "solution init -pn $publisherName -pp $publisherPrefix -o $temp_init_path\$solutionName"
        Write-Host "Solution Init Command - $pacPath\pac.exe $solInitCommand"
        Invoke-Expression -Command "$pacPath\pac.exe $solInitCommand"

        # Copy .cdsprojfile from temp to new folder structure
        $temp_cdsProjPath = "$temp_init_path\$solutionName\$solutionName.cdsproj"
        Write-Host "temp_cdsProjPath - $temp_cdsProjPath"
        if(Test-Path "$temp_cdsProjPath")
        {
            Copy-Item "$temp_cdsProjPath" -Destination "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\"
            Write-Host "Adding Package Type 'Both' to .cds proj file"
            add-packagetype-node-to-cdsproj "$buildSourceDirectory" "$repo" "$solutionName"
        }
        else{
            Write-Host "cdsproj file unavailble at temp path - $temp_cdsProjPath"
        }

        # Delete Temp folders
        Write-Host "Deleting Temp folders"
        if(Test-Path "$tempSolPackageDirectory")
        {
            Remove-Item -path "$tempSolPackageDirectory" -recurse -force
        }
        if(Test-Path "$temp_init_path")
        {
            Remove-Item -path "$temp_init_path" -recurse -force
        }
    }
    else{
        Write-Host "Valid folder structure. No need of restructure"
    }
}

function get-publisher-name{
    param (
        [Parameter(Mandatory)] [String]$solutionFilePath
    )
    $publisherName = $null

    if(Test-Path "$solutionFilePath"){
        [xml]$xmlElm = Get-Content -Path "$solutionFilePath"
        $publisherName = $xmlElm.ImportExportXml.SolutionManifest.Publisher.UniqueName
    }
    else{
       Write-Host "Solution xml file unavailble at path - $solutionFilePath"
    }

    return $publisherName
}

function get-publisher-prefix{
    param (
        [Parameter(Mandatory)] [String]$solutionFilePath
    )
    $publisherPrefix = $null

    if(Test-Path "$solutionFilePath"){
        [xml]$xmlElm = Get-Content -Path "$solutionFilePath"
        $publisherPrefix = $xmlElm.ImportExportXml.SolutionManifest.Publisher.CustomizationPrefix
    }
    else{
       Write-Host "Solution xml file unavailble at path - $solutionFilePath"
    }

    return $publisherPrefix
}

function append-version-to-solutions{
    param (
        [Parameter(Mandatory)] [String]$artifactStagingDirectory,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$buildNumber
    )
    $folderType = ".zip"
    $managedSolutionPath = "$artifactStagingDirectory\$solutionName" + "_managed.zip"
    $newManagedSolutionFileName = "$solutionName" + "_" + "$buildNumber" + "_" + "managed" + "$folderType"
    $unmanagedSolutionPath = "$artifactStagingDirectory\$solutionName" + ".zip"
    $newUnmanagedSolutionFileName = "$solutionName" + "_" + "$buildNumber" + "$folderType"
    Write-Host "managedSolutionPath - $managedSolutionPath"
    Write-Host "unmanagedSolutionPath - $unmanagedSolutionPath"
    Write-Host "newManagedSolutionFileName - $newManagedSolutionFileName"
    Write-Host "newUnManagedSolutionFileName - $newUnmanagedSolutionFileName"
    if(Test-Path "$managedSolutionPath")
    {
        #Rename-Item -Path "$managedSolutionPath" -NewName "$newManagedSolutionFileName"

        # Create a new Solution zip file with new name (Appending version number)
        Copy-Item "$managedSolutionPath" -Destination "$artifactStagingDirectory\$newManagedSolutionFileName"
		# Delete old managed solution file
		Remove-Item -Path "$managedSolutionPath" -Force
    }
    else
    {
        Write-Host "Managed solution is unavailble at $managedSolutionPath"
    }
	
    if(Test-Path "$unmanagedSolutionPath")
    {
        #Rename-Item -Path "$managedSolutionPath" -NewName "$newManagedSolutionFileName"

        # Create a new Solution zip file with new name (Appending version number)
        Copy-Item "$unmanagedSolutionPath" -Destination "$artifactStagingDirectory\$newUnmanagedSolutionFileName"
		# Delete old unmanaged solution file
		Remove-Item -Path "$unmanagedSolutionPath" -Force
    }
    else
    {
        Write-Host "Unmanaged solution is unavailble at unmanagedSolutionPath"
    }
}

function check-test-projects{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName
    )

    $testProjectsPath = "$buildSourceDirectory\$repo\$solutionName\Test"
    If(Test-Path "$testProjectsPath")
    {
        $testProjectFiles = Get-ChildItem -Path "$testProjectsPath" -Filter *.csproj -Recurse
        foreach($csProject in $csProjectFiles)
        {     
            # Add only Plugin type csproj; Skip others
            $csProjectPath = $csProject.FullName

            # Read csproj xml to determin project type
            [xml]$xmlDoc = Get-Content -Path $csProjectPath
            $testProjectType = $xmlDoc.Project.PropertyGroup.TestProjectType

            # 'TestProjectType' tag is available only to Test projects
            if(-not [string]::IsNullOrWhiteSpace($testProjectType)){
                Write-Host "Test projects exist in the Repo - $csProjectPath"
                Write-Host "##vso[task.setvariable variable=pluginstestexists;]$true"
                break
            }       
        }
    }
    else
    {
        Write-Host "Test projects not exist under $testProjectsPath"
    }
}