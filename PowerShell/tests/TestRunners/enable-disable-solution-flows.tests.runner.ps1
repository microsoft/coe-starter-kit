#Run in Windows Powershell

function Invoke-EnableDisableSolutionFlows-Test()
{
    Set-Location -Path "..\"
    $testConfig = Get-Content ".\TestData\enable-disable-solution-flows-test.config.json" | ConvertFrom-Json

    $path = './enable-disable-solution-flows.tests.ps1'
    $data = @{
        BuildSourceDirectory    = $testConfig.buildSourceDirectory 
        Repo                    = $testConfig.repo 
        SolutionName            = $testConfig.solutionName 
        DisableAllFlows         = $testConfig.disableAllFlows 
        ActivationConfigPath    = $testConfig.activationConfigPath
    }
    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}
Invoke-EnableDisableSolutionFlows-Test
