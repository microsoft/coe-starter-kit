function Invoke-UpdateSolutionComponentOwner-Test()
{
    Set-Location -Path "..\"
    $testConfig = Get-Content ".\TestData\update-solution-component-owner-test.config.json" | ConvertFrom-Json

    $path = './update-solution-component-owner.tests.ps1'
    $data = @{
        CdsBaseConnectionString                         = $testConfig.cdsBaseConnectionString 
        ServiceConnection                               = $testConfig.serviceConnection 
        MicrosoftXrmDataPowerShellModule                = $testConfig.microsoftXrmDataPowerShellModule 
        XrmDataPowerShellVersion                        = $testConfig.xrmDataPowerShellVersion 
        SolutionComponentOwnershipConfigurationPath     = $testConfig.componentOwnerConfigPath
    }
    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}

Invoke-UpdateSolutionComponentOwner-Test