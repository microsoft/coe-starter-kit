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

        $PSDefaultParameterValues['ConvertTo-Json:Depth'] = 10

        foreach($flowJsonFile in $flowJsonFiles)
        {    
            # Validate the existence of file
            if(Test-Path "$($flowJsonFile.FullName)"){
                Write-Host "Validating flow file - $($flowJsonFile.Name)"
                
                # Read the JSON file content
                $jsonContent = Get-Content -Path "$($flowJsonFile.FullName)" -Raw

                # Convert JSON to PowerShell objects
                $jsonObject = $jsonContent | ConvertFrom-Json

                try {
                    $hasErros = Parse-Validate-Flow-Json-File $jsonObject
                }
                catch {
                    #Write-Host "Errors found in $($flowJsonFile.Name)."
                    $hasErros = $true
                }

                if ($hasErros) {
                    $invalidFiles += $delimiter + $($flowJsonFile.Name)
                    $delimiter = ","
                    Write-Host "Flow file - $($flowJsonFile.Name) is invalid***."
                }
                else {
                    Write-Host "Flow file - $($flowJsonFile.Name) is valid"
                }
				
                Write-Host ""
            }else{
                Write-Host "Invalid path $($flowJsonFile.Name)."
            }
        } 
    }else{
        Write-Host "No cloud flows presents in the solution to validate."
    }

    return $invalidFiles
}

# Validates left and right operands for empty values and spaces at begining
# if any one is blank returns true
function validate_Json{
    param (
        [Parameter(Mandatory)] [String]$jsonContent
    )

    try {
        $parsedJson = ConvertFrom-Json -InputObject $jsonContent
        # Checking for 'or' and 'and' keys
        $orAndKeysPresent = $parsedJson.PSObject.Properties.Name -in ('or', 'and')
        if (-not $orAndKeysPresent) {
            # Check for Expression keys
            $valueKey = $parsedJson.PSObject.Properties.Name | Where-Object { $_ -in ('greater', 'greaterOrEquals', 'equals', 'less', 'contains') }

            if ($valueKey) {
                Write-Host "Validating $valueKey value"
                $valueToCheck = $parsedJson.$valueKey[0]
                if (-not [string]::IsNullOrWhiteSpace($valueToCheck)) {
                    Write-Host "$valueToCheck is not null or empty"
                } else {
                    Write-Host "Value is either null or whitespace. Exiting."
                    throw
                    #return $false
                }
            } else {
                Write-Host "$valueKey is a valid condition. Continuing with next expression."
            }
        } else {
            # 'or' or 'and' keys found in the JSON
            $orAndKey = $parsedJson.PSObject.Properties.Name | Where-Object { $_ -in ('or', 'and') } | Select-Object -First 1

            Write-Host "Group condition type (and/or) - $orAndKey"            

            # Checking for spaces in the Left of Right operands        
            if ($orAndKey) {
                foreach ($element in $parsedJson.$orAndKey) {
                    # Iterate over the properties within each element
                    foreach ($property in $element.PSObject.Properties) {
                        $key = $property.Name
                        $valueArray = $property.Value

                        Write-Host "ValueArray - $valueArray"
                        #Write-Host "Length - " $valueArray.Length

                        if ($valueArray -ne $null -and $valueArray.Length -gt 0) {
                            foreach ($operand in $valueArray) {
                                #Write-Host "Operand - $operand"
                                if ([string]::IsNullOrEmpty($operand)){
                                    Write-Host "Found an empty string in the key - $key. Exiting."
                                    throw
                                }
                                if ($operand -is [string] -and $operand.StartsWith(" ")) {
                                    Write-Host "Starts with a space. $key - $operand. Exiting."
                                    throw
                                    #return $false
                                }
                            }
                        }
                        else {
                            Write-Host "ValueArray is empty for key - $key."
                        }
                    }
                }
            }
        }
    } catch {
        Write-Host "Error in validate_Json - $($_.Exception.Message)"
        #Write-Host "Invalid JSON string"
        throw
    }

    return $true
}

# This function parses and recursively traverse through xml nodes and fetch 'expression' content
# Validates any missing operands
function Parse-Validate-Flow-Json-File() {
    param (
        [Parameter(Mandatory)] [Object]$jsonObject
    )

    foreach ($property in $jsonObject.PSObject.Properties) {
        if ($property.Name -eq 'expression') {
            Write-Host "Expression Value - " $property.Value
            #Write-Host "Expression Value Type - " $property.Value.GetType()
            if ($property.Value -is [System.Object[]]) {
                foreach ($item in $property.Value) {
                    #Write-Host "Object[] Type - " $item
                }
            }
            elseif ($property.Value -is [System.String]) {
                #Write-Host "String Type - " $property.Value
            }
            elseif ($property.Value -is [System.Management.Automation.PSCustomObject]) {
                # Convert the PSCustomObject to JSON string
                $jsonString = $property.Value | ConvertTo-Json

                # Output the JSON string
                Write-Host "expression node content - " $jsonString
               $isValid = validate_Json $jsonString

               if($isValid -eq $false){
                    return $true
               }
            }
        }
        elseif ($property.Value -is [System.Management.Automation.PSCustomObject]) {
            Parse-Validate-Flow-Json-File $property.Value
        }
        elseif ($property.Value -is [System.Collections.ArrayList]) {
            foreach ($item in $property.Value) {
                Parse-Validate-Flow-Json-File $item
            }
        }
    }
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