param(
    $DeploymentConfig, $BuildSourceDirectory, $PipelineSourceDirectory, $BuildProjectName, $BuildRepositoryName, $DataverseConnectionString,
    $XrmDataPowerShellVersion, $MicrosoftXrmDataPowerShellModule, $OrgUrl, $ProjectName, $Repo, $AuthType,
    $ServiceConnection, $SolutionName, $UsePlaceholders, $AgentOS, $AccessToken, $Pat
)

Describe 'Update-Deployment-Settings-Test' {
    It 'UpdateDeploymentSettings' -Tag 'UpdateDeploymentSettings' {
        Set-Location -Path "..\"
        Install-Module $MicrosoftXrmDataPowerShellModule -RequiredVersion $XrmDataPowerShellVersion -Force -AllowClobber
        $env:SYSTEM_ACCESSTOKEN = $AccessToken
        $env:DEPLOYMENT_SETTINGS = $DeploymentConfig

        #Delete the current pipelines to validate they are recreated by update settings
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Basic $AccessToken")
        $headers.Add("Content-Type", "application/json")
        $requestUrl = "$OrgUrl$ProjectName/_apis/build/folders?api-version=6.0-preview.2&path=$SolutionName"
        $response = Invoke-RestMethod $requestUrl -Method 'DELETE' -Headers $headers
        $response | ConvertTo-Json -Depth 10

        #Run Update Deployment Settings
        . .\update-deployment-settings.ps1
        Set-DeploymentSettingsConfiguration $BuildSourceDirectory $PipelineSourceDirectory $BuildProjectName $BuildRepositoryName $DataverseConnectionString $XrmDataPowerShellVersion $MicrosoftXrmDataPowerShellModule $OrgUrl $ProjectName $Repo $AuthType $ServiceConnection $SolutionName '' $AgentOS $UsePlaceholders $Pat
    }
}
