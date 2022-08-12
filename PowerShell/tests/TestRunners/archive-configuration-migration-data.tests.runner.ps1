function Invoke-ArchiveConfigurationMigrationData-Test()
{
    Set-Location -Path "..\"
    $testConfig = Get-Content ".\TestData\archive-configuration-migration-data-test.config.json" | ConvertFrom-Json

    $path = './archive-configuration-migration-data.tests.ps1'
    $data = @{
        ArtifactStagingDirectory    = $testConfig.artifactStagingDirectory
        BuildSourceDirectory        = $testConfig.buildSourceDirectory
        Repo                        = $testConfig.repo
        SolutionName                = $testConfig.solutionName
    }

    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}
Invoke-ArchiveConfigurationMigrationData-Test
