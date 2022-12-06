function Fix-Unset-GUIDs-In-New-Business-Rules
{
    param (
        [Parameter(Mandatory)] [String]$workflowsPath
    )
   # Regex to extract GUID from the end of the filename
   $reGuid = '(([0-9a-f]){8}-([0-9a-f]){4}-([0-9a-f]){4}-([0-9a-f]){4}-([0-9a-f]){12})\.xaml$'
   Get-ChildItem -Path "$workflowsPath" -Recurse -File -Filter *.xaml | 
     Select-String 'XrmWorkflow00000000000000000000000000000000' -List | 
     Select-Object Path,Filename |
     ForEach-Object {
       $fileToFix = $_.Path
       if ($fileToFix -match $reGuid) {
         Write-Host "Fixing unset GUIDs in BR" $_.Filename
         # Use the GUID extracted from the filename to replace the empty GUIDs in the XAML content
         $guid = 'XrmWorkflow' + $matches[1].ToLower().Replace('-', '')
         ((Get-Content -path $fileToFix -Raw) -replace 'XrmWorkflow00000000000000000000000000000000', $guid) |
           Set-Content -NoNewLine -Path $fileToFix
       }
     }
}

function verify-default-environment-variables-are-set
{
    param (
        [Parameter()] [String]$outDefaultEnvironmentVariables,
        [Parameter(Mandatory)] [String]$envvardefinitionPath
    )

   if (-not ([string]::IsNullOrEmpty("$outDefaultEnvironmentVariables"))) {
       $config = Get-Content $(outDefaultEnvironmentVariables) | ConvertFrom-Json
       foreach ($c in $config) {
           $envVariableName = $c[0]
           Get-ChildItem -Path "$envvardefinitionPath\$envVariableName\environmentvariabledefinition.xml" | 
           ForEach-Object {
             $xml=[xml](Get-Content $_.FullName)
             $definitionNode = $xml.SelectSingleNode("//environmentvariabledefinition")
             $valueExists = $definitionNode.defaultvalue
             if($valueExists){
                $definitionNode.defaultvalue = $c[1]
             }
             else {
                $defaultValue = $xml.CreateElement("defaultvalue")
                $defaultValue.InnerText = $c[1]
                $definitionNode.AppendChild($defaultValue)
             }
             $xml.Save($_.FullName)
        }
       }
    }
}

function Check-if-Configuration-Migration-Data-Exists
{
    param (
        [Parameter()] [String]$path,
        [Parameter()] [String]$workspace
    )

   if(Test-Path "$path")
   {
        Write-Host "##vso[task.setvariable variable=ConfigurationMigrationFilePath]$path"
   }
   else
   {
        $path = "$workspace/drop/ConfigurationMigrationData.zip"
        if(Test-Path "$path")
        {
            Write-Host "##vso[task.setvariable variable=ConfigurationMigrationFilePath]$path"
        }
        else
        {
            Write-Host "##vso[task.setvariable variable=ConfigurationMigrationFilePath]"
        }
   }
}

function reset-solution-xml-build-number
{
    param (
        [Parameter(Mandatory)] [String]$solutionXMLPath
    )
   if(Test-Path "$solutionXMLPath"){
       Get-ChildItem -Path "$solutionXMLPath" | 
        ForEach-Object {
            (Get-Content $_.FullName) `
                -replace '<Version>[\s\S]*?<\/Version>', '<Version>0.0.0.0</Version>' |
            Out-File $_.FullName
        }
   }
   else{
    Write-Host "Solution.xml unavialble at $solutionXMLPath"
   }
}

function Format-JSON-Files 
{
    param (
        [Parameter(Mandatory)] [String]$solutionComponentsPath
    )
   Get-ChildItem -Path "$solutionComponentsPath" -Recurse -Filter *.json | 
   ForEach-Object {
    #skip canvas app and workflows folder because canvas and flows team already handles this
     if(-not $_.FullName.Contains('CanvasApps') -and -not $_.FullName.Contains('Workflows')) {
       Write-Host $_.FullName
       $formatted = jq . $_.FullName --sort-keys
       $formatted | Out-File $_.FullName -Encoding utf8NoBOM
     }
   }
}

function Remove-Code-From-Custom-Connectors-Where-Disabled
{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName
    )
	
   Write-Host $repo
   Write-Host $solutionName
   $connectorspath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\src\Connectors";
   Write-Host $connectorspath

   if(-not [string]::IsNullOrEmpty($connectorspath)) {
     Get-ChildItem -Path "$connectorspath" -Recurse -Filter *.xml | 
     ForEach-Object {
       $xml = [xml](Get-Content $_.FullName)
       $connectornode = $xml.SelectSingleNode("//Connector")
       Write-Host $connectornode.OuterXml
       $scriptoperationsnode = $connectornode.SelectSingleNode("//scriptoperations")
       $customcodeblobcontentnode = $connectornode.SelectSingleNode("//customcodeblobcontent")
       $connectornode.RemoveChild($scriptoperationsnode)
       $connectornode.RemoveChild($customcodeblobcontentnode)
       $xml.Save($_.FullName)
     }
   }
	
}
