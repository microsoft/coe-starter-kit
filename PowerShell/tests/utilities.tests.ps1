function Invoke-SetDeploymentVariable
{
    param (
        [Parameter(Mandatory)] [String]$deploymentSettingsPath,
        [Parameter(Mandatory)] [String]$deploymentSettingsNode
    )

    if($deploymentSettingsPath -ne '')
    {
        $deploymentSettings = Get-Content $deploymentSettingsPath | ConvertFrom-Json
        $settingsNode = $deploymentSettings.$deploymentSettingsNode
        $settingsJson = ConvertTo-Json($settingsNode) -Compress
        if ($settingsJson) {
            if(Test-Path -Path "$deploymentSettingsNode.json") {
                Remove-Item -Path "$deploymentSettingsNode.json" -Force
            }
            $settingsJson | Out-File "$deploymentSettingsNode.json"

            return "$deploymentSettingsNode.json"
        }
    }
}