function Invoke-EnableDisableSolutionFlows-Test()
{
	. .\enable-disable-solution-flows.ps1
    $testConfig = Get-Content ".\TestData\activate-flow-test.config.json" | ConvertFrom-Json
    Set-EnableDisableSolutionFlows $testConfig.buildSourceDirectory $testConfig.repo $testConfig.solutionName $testConfig.disableAllFlows $testConfig.configurationDataJson
}
Invoke-EnableDisableSolutionFlows-Test
