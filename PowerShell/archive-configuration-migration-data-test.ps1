function Invoke-ArchiveConfigurationMigrationData-Test()
{
	. .\archive-configuration-migration-data.ps1
    $testConfig = Get-Content ".\TestData\archive-configuration-migration-data-test.config.json" | ConvertFrom-Json
    Remove-Item $testConfig.artifactStagingDirectory -Recurse -Force
    New-Item $testConfig.artifactStagingDirectory -ItemType Directory
    Invoke-ArchiveConfigurationMigrationData $testConfig.buildSourceDirectory $testConfig.artifactStagingDirectory $testConfig.repo $testConfig.solutionName
}
Invoke-ArchiveConfigurationMigrationData-Test
