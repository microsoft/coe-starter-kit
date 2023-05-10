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