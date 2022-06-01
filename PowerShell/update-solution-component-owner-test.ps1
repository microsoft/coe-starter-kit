function Invoke-UpdateSolutionComponentOwner-Test()
{
    . .\activate-flows.ps1
	. .\update-solution-component-owner.ps1
	. .\utilities-test.ps1
    $testConfig = Get-Content ".\TestData\activate-flows-test.config.json" | ConvertFrom-Json

    $componentOwnerConfig = Invoke-SetDeploymentVariable ".\TestData\Solutions\coe-starter-kit-azdo\ALMAcceleratorSampleSolution\config\customDeploymentSettings.json" "SolutionComponentOwnershipConfiguration"
    Invoke-UpdateSolutionComponentOwner $testConfig.cdsBaseConnectionString $testConfig.serviceConnection $testConfig.microsoftXrmDataPowerShellModule $testConfig.xrmDataPowerShellVersion $componentOwnerConfig
}

Invoke-UpdateSolutionComponentOwner-Test