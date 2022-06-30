
function Invoke-DeploymentSettingsConfiguration-Test()
{
    $testConfig = Get-Content ".\TestData\update-deployment-settings-test.config.json" | ConvertFrom-Json
    Install-Module $testConfig.microsoftXrmDataPowerShellModule -RequiredVersion $testConfig.xrmDataPowerShellVersion -Force -AllowClobber
    $pat = $testConfig.accessToken
    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
    $env:SYSTEM_ACCESSTOKEN = $token
    $env:DEPLOYMENT_SETTINGS = $testConfig.configurationDataJson
	. .\update-deployment-settings.ps1
    Set-DeploymentSettingsConfiguration $testConfig.buildSourceDirectory $testConfig.buildRepositoryName $testConfig.cdsBaseConnectionString $testConfig.xrmDataPowerShellVersion $testConfig.microsoftXrmDataPowerShellModule $testConfig.orgUrl $testConfig.projectId $testConfig.projectName $testConfig.repo "Basic" $testConfig.serviceConnection $testConfig.solutionName $testConfig.generateEnvironmentVariables $testConfig.generateConnectionReferences $testConfig.generateFlowConfig $testConfig.generateCanvasSharingConfig $testConfig.generateAADGroupTeamConfig $testConfig.generateCustomConnectorConfig
}

Invoke-DeploymentSettingsConfiguration-Test