<#
This function either enables or disables flows based on deployment settings.
#>
function Set-EnableDisableSolutionFlows {
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$disableAllFlows,
        [Parameter()] [String]$activateFlowConfigJson
    )
	
    $workflowspath = "$buildSourceDirectory\$repo\$solutionName\SolutionPackage\src\Workflows";

    if(-not [string]::IsNullOrEmpty($workflowspath))
    {
        if ($disableAllFlows -eq 'true') {
            Get-ChildItem -Path "$workflowspath" -Recurse -Filter *.xml | 
            ForEach-Object {
                If(Test-Path $_.FullName){
                    $xml = [xml](Get-Content $_.FullName)
                    $workflowNode = $xml.SelectSingleNode("//Workflow")
                    $workflowNode.StateCode = '0'
                    $workflowNode.StatusCode = '1'
                    $xml.Save($_.FullName)
                }
                else{
                    Write-Host "Path unavailable - " $_.FullName
                }
            }
        }
        else {
		    Write-Host $activateFlowConfigJson
            if ($activateFlowConfigJson -ne '') {
                #Disable / Enable flows based on configuration
                If(Test-Path $activateFlowConfigJson){
                    $activateFlowConfigs = Get-Content $activateFlowConfigJson | ConvertFrom-Json
                    Write-Host "Retrieved " $activateFlowConfigs.Length " flow activation configurations"
                    foreach ($activateFlowConfig in $activateFlowConfigs) {
                        $filter = "*" + $activateFlowConfig.solutionComponentUniqueName + "*.xml"
                        Get-ChildItem -Path "$workflowspath" -Recurse -Filter $filter | 
                        ForEach-Object {
                            if(Test-Path $_.FullName){
                                $xml = [xml](Get-Content $_.FullName)
                                $workflowNode = $xml.SelectSingleNode("//Workflow")
                                if ($activateFlowConfig.activate -eq 'false') {
                                    Write-Host "Disabling flow " $activateFlowConfig.solutionComponentName 
                                    $workflowNode.StateCode = '0'
                                    $workflowNode.StatusCode = '1'
                                }
                                elseif ($activateFlowConfig.activate -eq 'true') {
                                    Write-Host "Enabling flow " $activateFlowConfig.solutionComponentName 
                                    $workflowNode.StateCode = '1'
                                    $workflowNode.StatusCode = '2'
                                }
                                $xml.Save($_.FullName)
                            }
                            else{
                                Write-Host "Path unavailable - " $_.FullName
                            }
                        }
                    }
                }
                else{
                    Write-Host "ActivateFlowConfigJson Path unavailable - " $activateFlowConfigJson
                }
            }
        }
	}
}