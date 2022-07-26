function Set-EnableDisableSolutionFlows {
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$disableAllFlows,
        [Parameter(Mandatory)] [String]$activateFlowConfigJson
    )
    if ($disableAllFlows -eq 'true') {
        Get-ChildItem -Path "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\Workflows" -Recurse -Filter *.xml | 
        ForEach-Object {
            $xml = [xml](Get-Content $_.FullName)
            $workflowNode = $xml.SelectSingleNode("//Workflow")
            $workflowNode.StateCode = '0'
            $workflowNode.StatusCode = '1'
            $xml.Save($_.FullName)
        }
    }
    else {
		Write-Host $activateFlowConfigJson
        if (!$activateFlowConfigJson.Contains('$(')) {
            #Disable / Enable flows based on configuration
            $activateFlowConfigs = ConvertFrom-Json $activateFlowConfigJson
            Write-Host "Retrieved " $activateFlowConfigs.Length " flow activation configurations"
            foreach ($activateFlowConfig in $activateFlowConfigs) {
                $filter = "*" + $activateFlowConfig.solutionComponentUniqueName + "*.xml"
                Get-ChildItem -Path "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\Workflows" -Recurse -Filter $filter | 
                ForEach-Object {
                    $xml = [xml](Get-Content $_.FullName)
                    $workflowNode = $xml.SelectSingleNode("//Workflow")
                    if ($activateFlowConfig.activate -eq 'false') {
                        Write-Host "Disabling flow " $activateFlowConfig.solutionComponentName 
                        $workflowNode.StateCode = '0'
                        $workflowNode.StatusCode = '1'
                    }
                    else {
                        Write-Host "Enabling flow " $activateFlowConfig.solutionComponentName 
                        $workflowNode.StateCode = '1'
                        $workflowNode.StatusCode = '2'
                    }
                    $xml.Save($_.FullName)
                }
            
            }
        }
    }
}