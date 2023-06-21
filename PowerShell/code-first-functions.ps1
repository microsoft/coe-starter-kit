<#
This function fetches all the pcf projects under the repository.
Runs the npm 'clean install'.
Installs a project's dependencies.
#>
function Invoke-Npm-Install-Pcf-Projects{
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

<#
This function fetches all the pcf projects under the repository.
Runs the npm build against each project.
#>
function Invoke-Npm-Build-Pcf-Projects{
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

<#
This function fetches all the pcf projects under the repository.
Runs the npm install against each project.
#>
function Invoke-Pcf-Projects-Install-Npm{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo
    )

      $pcfProjectFiles = Get-ChildItem -Path "$buildSourceDirectory\$repo" -Filter *.pcfproj -Recurse
      foreach($pcfProj in $pcfProjectFiles)
      {
        $fullPath = $pcfProj.FullName
        # Point cmd to pcfproj directory
        Set-Cmd-Path "$fullPath"
        
        npm install
      } 
}

<#
This function sets the directory path to run npm commands further.
#>
function Set-Cmd-Path{
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

<#
This function fetches all the code first projects (i.e., pcf and cs) projects under the repository.
Adds the code first projects to the cdsproj file.
cdsproj file will be used to build and convert to a solution.
#>
function Add-Codefirst-Projects-To-Cdsproj{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$pacPath,
        [Parameter()] [String]$base64Snk
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
            $pcfProjectPath = '"' + $($pcfProj.FullName) + '"'
            $addReferenceCommand = "solution add-reference --path $pcfProjectPath"
            Write-Host "Add Reference Command - $addReferenceCommand"
            Invoke-Expression -Command "$pacexepath $addReferenceCommand"
          } 

          Write-Host "Adding Plugin (i.e.,.csproj) references to cdsproj"
          # Skip adding plugin projects if 'Plugin Assembly' is not part of Dataverse solution
          $unpackedPluginAssemblyPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\src\PluginAssemblies"
          if(Test-Path "$unpackedPluginAssemblyPath"){
              # Get all .csproj files under Repo/Commited Solution folder
              $csProjectFiles = Get-ChildItem -Path "$buildSourceDirectory\$repo\$solutionName" -Filter *.csproj -Recurse
              Write-Host "$($csProjectFiles.Count) cs project files found"
              # Filter out projects name ending with "Tests.csproj" (i.e.,Unit test projects)
              $filteredProjects = $csProjectFiles | Where-Object { $_.Name -notlike "*Tests.csproj" }
              Write-Host "$($filteredProjects.Count) plugin project files found after filtering out unit test projects"
              foreach($csProject in $filteredProjects)
              {     
                Write-Host "Adding Reference of Plugin Project - " $csProject.FullName
                $csProjectPath = '"' + $($csProject.FullName) + '"'
                
                # Read csproj file's AssemblyOriginatorKeyFile and SignAssembly properties.
                # We need to read these properties to determine whether the C# project is signed.
                [xml]$xmlDoc = Get-Content -Path $($csProject.FullName)
                $snkFileName = $xmlDoc.Project.PropertyGroup.AssemblyOriginatorKeyFile
                $signAssembly = $xmlDoc.Project.PropertyGroup.SignAssembly
                Write-Host "SNKFileName - $snkFileName"
                Write-Host "SignAssembly - $signAssembly"
                # Check for existing snk file or pull from global variables
                if($signAssembly -eq "true") {
                    $projectDirectory = [System.IO.Path]::GetDirectoryName("$csProject.FullName")
                    Write-Host "SNK Path: $projectDirectory\$snkFileName"
                    if(!(Test-Path "$projectDirectory\$snkFileName")) {
                        if(!($base64Snk.Contains('$('))) {
                            Write-Host "Writing plugin snk file to disk"
                            $bytes = [Convert]::FromBase64String($base64Snk)
                            [IO.File]::WriteAllBytes("$projectDirectory\$snkFileName", $bytes)
                        }else{
                            Write-Host "No snk found at repo and no snk content defined in variables"
                        }
                    }else{
                        Write-Host ".snk file - $snkFileName already presents in the repo. No need to read from variable"
                    }
                }

                $addReferenceCommand = "solution add-reference --path $csProjectPath"
                Write-Host "Add Reference Command - $addReferenceCommand"
                Invoke-Expression -Command "$pacexepath $addReferenceCommand"
              }
          }
          else
          {
                Write-Host "PluginAssemblies folder unavailable in unpacked solution"
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

<#
This function checks the existence of code first projects.
Sets the global variable flags.
#>
function Invoke-Check-Code-First-Components{
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

<#
This function sets the pac tools path.
#>
function Set-Pac-Tools-Path{
    param (
        [Parameter(Mandatory)] [String]$agentOS
    )

   if ($agentOS -eq "Linux") {
       $pacToolsPath = $env:POWERPLATFORMTOOLS_PACCLIPATH + "/pac_linux/tools"
   }
   else {
       $pacToolsPath = $env:POWERPLATFORMTOOLS_PACCLIPATH + "\pac\tools"
   } 

    Write-Host "##vso[task.setvariable variable=pacPath]$pacToolsPath"
}

<#
This function creates authentication profile.
This step is required to trigger further pac commands.
#>
function Invoke-Pac-Authenticate{
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

<#
This function triggers either pac solution clone and sync command.
Clone command will be triggered for the first time solution export.
Sync command will be triggered for subsequent solution exports.
#>
function Invoke-Clone-Or-Sync-Solution{
    param (
        [Parameter(Mandatory)] [String]$serviceConnectionUrl,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$tenantID,
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$pacPath,
        [Parameter(Mandatory)] [String]$buildDirectory,
        [Parameter(Mandatory)] [String]$processCanvasApps
    )
	
	$legacyFolderPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage"
    $pacexepath = "$pacPath\pac.exe"
    if(Test-Path "$pacexepath")
    {
        # Trigger Auth
        Invoke-Expression -Command "$pacexepath auth create --url $serviceConnectionUrl --name ppdev --applicationId $clientId --clientSecret $clientSecret --tenant $tenantID"
        $unpackfolderpath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage"

        # Trigger Clone or Sync
        $cdsProjPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName.cdsproj"
        $cdsProjFolderPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage"
        # If .cds project file exists (i.e., Clone performed already) trigger Sync
        if(Test-Path "$cdsProjPath")
        {
            Write-Host "Cloned solution available; Triggering Solution Sync"
            $cdsProjfolderPath = [System.IO.Path]::GetDirectoryName("$cdsProjPath")
            Write-Host "Pointing to cdsproj folder path - " $cdsProjfolderPath
            Set-Location -Path $cdsProjfolderPath
            $syncCommand = "solution sync --processCanvasApps $processCanvasApps --packagetype Both --async"
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
            $cloneCommand = "solution clone -n $solutionName --processCanvasApps $processCanvasApps --outputDirectory ""$unpackfolderpath"" --packagetype Both --async"
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

<#
This function updates the cdsproj file's 'SolutionPackageType' node to 'Both'.
To generate both Managed and Unmanaged solutions 'SolutionPackageType' node must be set to 'Both'.
#>
function Add-Packagetype-Node-To-Cdsproj{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName
    )
    $cdsProjPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\$solutionName.cdsproj"

    if(Test-Path $cdsProjPath){
        [xml]$xmlDoc = Get-Content -Path $cdsProjPath

        # Skip logic if 'Solution Package Type' node already exists'
        $solutionPackageType = $xmlDoc.Project.PropertyGroup.SolutionPackageType

        Write-Host "Existing solutionPackageType - " $solutionPackageType
        if (([string]::IsNullOrWhiteSpace("$solutionPackageType"))){
            Write-Host "Adding SolutionPackageType='Both' node"
            $newPropertyGroup = $xmlDoc.Project.AppendChild($xmlDoc.CreateElement("PropertyGroup",$xmlDoc.Project.NamespaceURI));
            $newSolPkgType = $newPropertyGroup.AppendChild($xmlDoc.CreateElement("SolutionPackageType",$xmlDoc.Project.NamespaceURI));
            $newSolPkgType.AppendChild($xmlDoc.CreateTextNode("Both"));

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

<#
This function restructures the legacy solution folder structure.
#>
function Invoke-Restructure-Legacy-Folders{
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
        $publisherName = Get-Publisher-Name "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\Other\Solution.xml"
        # Get Prefix Name
        $publisherPrefix = Get-Publisher-Prefix "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\Other\Solution.xml"

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

        $solInitCommand = "solution init --publisher-name $publisherName --publisher-prefix $publisherPrefix --outputDirectory $temp_init_path\$solutionName"
        Write-Host "Solution Init Command - $solInitCommand"
        Invoke-Expression -Command "$pacPath\pac.exe $solInitCommand"

        # Copy .cdsprojfile from temp to new folder structure
        $temp_cdsProjPath = "$temp_init_path\$solutionName\$solutionName.cdsproj"
        Write-Host "temp_cdsProjPath - $temp_cdsProjPath"
        if(Test-Path "$temp_cdsProjPath")
        {
            Copy-Item "$temp_cdsProjPath" -Destination "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\"
            Write-Host "Adding Package Type 'Both' to .cds proj file"
            Add-Packagetype-Node-To-Cdsproj "$buildSourceDirectory" "$repo" "$solutionName"
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

<#
This function parses and reads the publisher unique name from the solution xml file.
#>
function Get-Publisher-Name{
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

<#
This function parses and reads the publisher prefix from the solution xml file.
#>
function Get-Publisher-Prefix{
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

<#
This function appends the version number as a suffix to solution zip files.
#>
function Invoke-Append-Version-To-Solutions{
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

function Restore-Nuget-Packages(){
    param (
        [Parameter(Mandatory)] [String]$repoPath
    )
    $csProjectFiles = Get-ChildItem -Path "$repoPath" -Filter '*.csproj' -Recurse
    foreach ($csProjectFile in $csProjectFiles) {
      $csProjectFileFullPath = $csProjectFile.FullName
      $csProjectFileName = $csProjectFile.Name

        # Read the contents of the project file
        $projectFileContent = Get-Content -Path "$csProjectFileFullPath" -Raw

        # Check if the project file contains the <Project Sdk="..."> element
        $isSdkStyleProject = $projectFileContent -match '<Project[^>]*Sdk="'

        Write-Host "IsSdkStyleProject - $isSdkStyleProject"

        if ($isSdkStyleProject) {
            Write-Host "Project - $csProjectFileName does not require a nuget restore."
        } else {
            Write-Host "Project - $csProjectFileName requires nuget restore. Restoring nuget packages - $csProjectFileFullPath"
              $projectDirectory = Split-Path -Path "$csProjectFileFullPath" -Parent
              $restoreDirectory = Join-Path -Path "$projectDirectory" -ChildPath 'packages'
              $configFile = Join-Path -Path "$projectDirectory" -ChildPath 'packages.config'
              Write-Host "Packages config file path - $configFile"

              if(Test-Path "$configFile"){
                & nuget.exe restore "$configFile" -PackagesDirectory "$restoreDirectory"
              }
              else{
                    Write-Host "Packages config file unavailable at - $configFile"
              }
        }
    }    
}

<#
This function removes the nuget package restore check nodes from csproj files.
Creates a copy file which will be used in later step
#>
function Disable-Target-Nodes-in-csproj-Files{
    param (
        [Parameter(Mandatory)] [String]$repoPath
    )

    Write-Host "RepoPath - $repoPath"
    $csProjectFiles = Get-ChildItem -Path "$repoPath" -Filter '*.csproj' -Recurse
    foreach ($csProjectFile in $csProjectFiles) {
        $csProjectFileFullPath = $csProjectFile.FullName
        $csProjectFileName = $csProjectFile.Name

        if(Test-Path "$csProjectFileFullPath"){
            Write-Host "Reading the xml content of $csProjectFileFullPath"

            # Load the XML content using XmlDocument
            $xmlDocument = New-Object System.Xml.XmlDocument
            $xmlDocument.Load("$csProjectFileFullPath")

            # Create a namespace manager
            $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmlDocument.NameTable)
            $namespaceManager.AddNamespace("ns", "http://schemas.microsoft.com/developer/msbuild/2003")

            # Select all <Target> nodes
            $targetNodes = $xmlDocument.SelectNodes("//ns:Target", $namespaceManager)

            # Find the <Target> node with Name="EnsureNuGetPackageBuildImports"
            $targetNode = $targetNodes | Where-Object { $_.Name -eq "EnsureNuGetPackageBuildImports" }

            Write-Host "TargetNode - $targetNode"
            Write-Host "Target Parent Node - " $targetNode.ParentNode

            # Check if the <Target> node exists
            if ($targetNode) {
                Write-Host "Target node found. Removal and copying the content starts"
                # Create a copy of the original XML file
                $copyFileName = [System.IO.Path]::GetFileNameWithoutExtension("$csProjectFileFullPath") + "-copy.xml"
                Write-Host "CopyFileName - $copyFileName"
                $copyFilePath = Join-Path -Path (Split-Path "$csProjectFileFullPath") -ChildPath $copyFileName
                Write-Host "CopyFilePath - $copyFilePath"
                Copy-Item -Path "$csProjectFileFullPath" -Destination "$copyFilePath" -Force
                Write-Host "Copy file has been created at $copyFilePath "
                # Remove the <Target> node from its parent
                $targetNode.ParentNode.RemoveChild($targetNode)
                # Save the modified XML content back to the original file
                $xmlDocument.Save("$csProjectFileFullPath")
                Write-Host "The <Target> node has been removed. A copy of the original file - $copyFileName has been created."
            }
            else {
                Write-Host "The <Target> node with Name='EnsureNuGetPackageBuildImports' does not exist at $csProjectFileName."
            }
        }else{
            Write-Host "Invalid file path - $csProjectFileFullPath"
        }
    }
}

<#
This function restores the csproj file content from copy file.
#>
function Repopulate-csproj-File-Content{
    param (
        [Parameter(Mandatory)] [String]$repoPath
    )

    $csProjectFiles = Get-ChildItem -Path "$repoPath" -Filter '*.csproj' -Recurse
    foreach ($csProjectFile in $csProjectFiles) {
        $csProjectFileFullPath = $csProjectFile.FullName
        $csProjectFileName = $csProjectFile.Name
        Write-Host "Looking for 'copy' file of $csProjectFileName"
        $fileNameWithoutExtension = (Get-Item -Path $csProjectFileFullPath).BaseName
        $csprojFilefolderPath = Split-Path -Path $csProjectFileFullPath -Parent
        $csprojCopyFilePath = "$csprojFilefolderPath\$fileNameWithoutExtension-copy.xml"
        # Check if there is a copy file (i.e., filename-copy.csproj)
        if(Test-Path "$csprojCopyFilePath"){
            Write-Host "Copy file of $csProjectFileName exists at $csprojCopyFilePath. Moving the 'copy' file content to 'main' file"
            # Copy content of 'copy' file to main file
            Copy-Item -Path "$csprojCopyFilePath" -Destination "$csProjectFileFullPath" -Force
            Write-Host "Removing the 'copy' file from $csprojCopyFilePath"
            # Remove the 'copy' file
            Remove-Item -Path "$csprojCopyFilePath" -Force
        }else{
            Write-Host "Copy file path does not exists at $csprojCopyFilePath"
        }
    }
}