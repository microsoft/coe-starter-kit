#Run in Windows Powershell
function Invoke-DeploymentSettingsConfiguration-Test($usePlaceholders, $path)
{
    Set-Location -Path $path

    $testConfig = Get-Content ".\TestData\update-deployment-settings-test.config.json" | ConvertFrom-Json
    $testDeploymentConfig = Get-Content ".\TestData\update-deployment-settings-test-deployment.json"

    $pat = $testConfig.accessToken
    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))

    $path = './update-deployment-settings.tests.ps1'
    $data = @{
        DeploymentConfig                    = $testDeploymentConfig
        BuildSourceDirectory                = $testConfig.buildSourceDirectory
        PipelineSourceDirectory             = $testConfig.pipelineSourceDirectory
        BuildProjectName                    = $testConfig.buildProjectName
        BuildRepositoryName                 = $testConfig.buildRepositoryName
        DataverseConnectionString           = $testConfig.dataverseConnectionString
        XrmDataPowerShellVersion            = $testConfig.xrmDataPowerShellVersion
        MicrosoftXrmDataPowerShellModule    = $testConfig.microsoftXrmDataPowerShellModule
        OrgUrl                              = $testConfig.orgUrl
        ProjectName                         = $testConfig.projectName
        Repo                                = $testConfig.repo
        AuthType                            = "Basic"
        ServiceConnection                   = $testConfig.serviceConnection
        SolutionName                        = $testConfig.solutionName
        UsePlaceholders                     = $usePlaceholders
        AccessToken                         = $token
        Pat                                 = $pat
        AgentOS                             = "Windows"
    }    
    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}

Invoke-DeploymentSettingsConfiguration-Test 'true' '../'
Invoke-DeploymentSettingsConfiguration-Test 'false' './tests'