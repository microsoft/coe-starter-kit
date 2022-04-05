
function Invoke-DeploymentSettingsConfiguration-Test()
{
	. "update-deployment-settings.ps1"
    $testConfig = Get-Content ".\TestData\test.config.json" | ConvertFrom-Json
    $json = ConvertTo-Json $testConfig

    Write-Output $json
    Install-Module $testConfig.microsoftXrmDataPowerShellModule -RequiredVersion $testConfig.xrmDataPowerShellVersion
    $pat = $testConfig.accessToken
    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
    $env:SYSTEM_ACCESSTOKEN = $token
    Set-DeploymentSettingsConfiguration $testConfig.buildSourceDirectory $testConfig.buildRepositoryName $testConfig.cdsBaseConnectionString $testConfig.xrmDataPowerShellVersion $testConfig.microsoftXrmDataPowerShellModule $testConfig.orgUrl $testConfig.projectId $testConfig.projectName $testConfig.repo "Basic" $testConfig.serviceConnection $testConfig.solutionName $testConfig.profileEnvironmentUrl $testConfig.profileId $testConfig.configurationDataJson $testConfig.generateEnvironmentVariables $testConfig.generateConnectionReferences $testConfig.generateFlowConfig $testConfig.generateCanvasSharingConfig $testConfig.generateAADGroupTeamConfig $testConfig.generateCustomConnectorConfig
}

Invoke-DeploymentSettingsConfiguration-Test