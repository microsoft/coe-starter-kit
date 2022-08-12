#Run in Windows Powershell
function Invoke-ActivateFlows-Test()
{
    Set-Location -Path "..\"
    $testConfig = Get-Content ".\TestData\activate-flows-test.config.json" | ConvertFrom-Json

    $path = './activate-flows.tests.ps1'
    $data = @{
        MicrosoftXrmDataPowerShellModule                   = $testConfig.microsoftXrmDataPowerShellModule
        XrmDataPowerShellVersion                           = $testConfig.xrmDataPowerShellVersion        
        MicrosoftPowerAppsAdministrationPowerShellModule   = $testConfig.microsoftPowerAppsAdministrationPowerShellModule 
        PowerAppsAdminModuleVersion                        = $testConfig.powerAppsAdminModuleVersion
        ActivationConfigPath                               = $testConfig.activationConfigPath
        ComponentOwnerConfigPath                           = $testConfig.componentOwnerConfigPath
        ConnectionReferenceConfigPath                      = $testConfig.connectionReferenceConfigPath
        CdsBaseConnectionString                            = $testConfig.cdsBaseConnectionString
        ServiceConnection                                  = $testConfig.serviceConnection
        TenantId                                           = $testConfig.tenantId
        ClientId                                           = $testConfig.clientId
        ClientSecret                                       = $testConfig.clientSecret
        SolutionName                                       = $testConfig.solutionName
        EnvironmentId                                      = $testConfig.environmentId
    }

    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}

Invoke-ActivateFlows-Test