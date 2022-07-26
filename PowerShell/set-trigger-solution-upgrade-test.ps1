function Set-TriggerSolutionUpgrade-Test()
{
	. .\set-trigger-solution-upgrade.ps1
    $testConfig = Get-Content ".\TestData\set-trigger-solution-upgrade.config.json" | ConvertFrom-Json
    Set-TriggerSolutionUpgrade $false $testConfig.orgUrl $testConfig.projectid $testConfig.buildRepositoryName $testConfig.buildRepositoryProvider $testConfig.buildSourceVersion $testConfig.buildReason $testConfig.systemAccessToken $testConfig.gitHubRepo $testConfig.gitHubPat
}

Set-TriggerSolutionUpgrade-Test