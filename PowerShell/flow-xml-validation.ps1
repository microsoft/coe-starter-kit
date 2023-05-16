# This function fetches all json files under workflow folder
# Searches for invalid expression nodes.
# Responds invalid files
function Validate-And-Fetch-Invalid-Flows{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName
    )

    $invalidFiles = $null
    $delimiter = ""
    $workflowsFolderPath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\src\Workflows"

    # Validate whether Workflows folder presents
    if(Test-Path "$workflowsFolderPath"){
        # Get all flow json files under SolutionPackage\src\Workflows folder
        $flowJsonFiles = Get-ChildItem -Path "$workflowsFolderPath" -Filter *.json -Recurse
        foreach($flowJsonFile in $flowJsonFiles)
        {    
            # Validate the existence of file
            if(Test-Path "$($flowJsonFile.FullName)"){
                Write-Host "Validating flow file - $($flowJsonFile.Name)"
                [PSCustomObject]$jsonObject = [PSCustomObject](Get-Content "$($flowJsonFile.FullName)" | Out-String | ConvertFrom-Json)
                $hasErros = Parse-Validate-Flow-Json-File $jsonObject

                if ($hasErros) {
                    $invalidFiles += $delimiter + $($flowJsonFile.Name)
                    $delimiter = ","
                    Write-Host "Flow file - $($flowJsonFile.Name) is invalid."
                }
                else {
                    Write-Host "Flow file - $($flowJsonFile.Name) is valid"
                }
            }else{
                Write-Host "Invalid path $($flowJsonFile.Name)."
            }
        } 
    }else{
        Write-Host "No cloud flows presents in the solution to validate."
    }

    return $invalidFiles
}

# This function parses and recursively traverse through xml nodes.
# Finds 'Expression' nodes
# Validates left and right operands
# if any one is blank returns true
function Parse-Validate-Flow-Json-File($jsonObject) {
    if ($jsonObject -is [array]) {
        foreach ($item in $jsonObject) {
            if (Parse-Validate-Flow-Json-File $item) {
                return $true
            }
        }
    }
    elseif ($jsonObject -is [System.Management.Automation.PSCustomObject]) {
        foreach ($property in $jsonObject.psobject.Properties) {
            if ($property.Name -eq 'Expression') {
                    $expression = $property.Value                          
                    if($null -ne $expression){
                        $jsonString = $expression | ConvertTo-Json
                        $keyName = ($expression | Get-Member -MemberType NoteProperty).Name
                        $objCondition = $expression.$keyName
                        # Get the values inside the array
                        $leftOperand = $objCondition[0]
                        $rightOperand = $objCondition[1]
                        Write-Host "leftOperand - $leftOperand and rightOperand - $rightOperand"
                        if([string]::IsNullOrEmpty($leftOperand) -or [string]::IsNullOrEmpty($rightOperand)){
                            return $true
                        }
                    }                
            }
            else {
                if (Parse-Validate-Flow-Json-File $property.Value) {
                    return $true
                }
            }
        }
    }

    return $false
}

# CS Project might be referring NuGet packages. If a NuGet package referred in a CS Project a 'HintPath' node will be added.
# Example <HintPath>..\packages\Castle.Core.4.3.1\lib\net45\Castle.Core.dll</HintPath>
# 'HintPath' pattern will be different for each project template (i.e., Class Library vs Unit test project)
# This function removes '..\' references so that NuGet packages will always be restored at project root folder level
function Remove-Relative-References-from-HintPath{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName
    )

    $repoPath = "$buildSourceDirectory\$repo\$solutionName"
    $projects = Get-ChildItem -Path "$repoPath" -Filter '*.csproj' -Recurse    
    foreach ($project in $projects) {
        $csProjectPath = $project.FullName
        Write-Host "Processing $($project.Name)"
        # Load the XML file content
        $xmlContent = Get-Content -Path $csProjectPath -Raw
        #Write-Host "Content before - "$xmlContent

        # Load the XML content
        $xml = [xml]$xmlContent

        # Call the function with the root node
        RemoveRelativeReferences $xml.DocumentElement

        # Save the modified XML content back to the file
        $xml.Save($csProjectPath)
        #$xmlContent = Get-Content -Path $csProjectPath -Raw
        #Write-Host "Content after - "$xmlContent
    }
}

# This is a subfunction of Remove-Relative-References-from-HintPath
# Fetches all the occurances of HintPath node
function RemoveRelativeReferences($node) {
    if ($node -is [System.Xml.XmlElement]) {
        if ($node.Name -eq "HintPath") {
            $node.InnerText = $node.InnerText -replace "\.\.\\", ""
        }
        foreach ($childNode in $node.ChildNodes) {
            RemoveRelativeReferences $childNode
        }
    }
}