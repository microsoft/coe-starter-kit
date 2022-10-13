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
            if ($PSVersionTable.PSVersion.Major -gt 5) {
                $settingsJson | Out-File "$deploymentSettingsNode.json" -Encoding utf8NoBOM
            }
            else {
                $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText("$deploymentSettingsNode.json", $settingsJson, $utf8NoBomEncoding)
                # PowerShell < v6 does not support writing UTF8 without BOM using Out-File
                # $settingsJson | Out-File "$deploymentSettingsNode.json"
            }

            return "$deploymentSettingsNode.json"
        }
    }
}