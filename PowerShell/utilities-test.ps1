function Invoke-SetDeploymentVariable($deploymentSettingsPath, $deploymentSettingsNode)
{
    if($deploymentSettingsPath -ne '')
    {
        $deploymentSettings = Get-Content $deploymentSettingsPath | ConvertFrom-Json
        $settingsNode = $deploymentSettings.$deploymentSettingsNode
        $settingsJson = ConvertTo-Json($settingsNode) -Compress
        if ($settingsJson) {
            return $settingsJson
        }
    }
}