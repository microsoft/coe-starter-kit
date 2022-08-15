param(
    $DeploymentConfig, $AccessToken, $BuildSourceDirectory, $BuildRepositoryName, $CdsBaseConnectionString,
    $XrmDataPowerShellVersion, $MicrosoftXrmDataPowerShellModule, $OrgUrl, $ProjectId, $ProjectName, $Repo, $AuthType,
    $ServiceConnection, $SolutionName, $UsePlaceholders
)

Describe 'Update-Deployment-Settings-Test' {
    It 'UpdateDeploymentSettings' -Tag 'UpdateDeploymentSettings' {
        Set-Location -Path "..\"
        Install-Module $MicrosoftXrmDataPowerShellModule -RequiredVersion $XrmDataPowerShellVersion -Force -AllowClobber
        $env:SYSTEM_ACCESSTOKEN = $AccessToken
        $env:DEPLOYMENT_SETTINGS = $DeploymentConfig
        . .\update-deployment-settings.ps1
        Set-DeploymentSettingsConfiguration $BuildSourceDirectory $BuildRepositoryName $CdsBaseConnectionString $XrmDataPowerShellVersion $MicrosoftXrmDataPowerShellModule $OrgUrl $ProjectId $ProjectName $Repo $AuthType $ServiceConnection $SolutionName $UsePlaceholders
    }
}
