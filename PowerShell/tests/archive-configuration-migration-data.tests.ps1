param(
    $ArtifactStagingDirectory, $BuildSourceDirectory, $Repo, $SolutionName
)

Describe 'Activate-Flows-Test' {
    It 'ActivateFlows' -Tag 'ActivateFlows' {
        . ..\archive-configuration-migration-data.ps1
        Remove-Item $ArtifactStagingDirectory -Recurse -Force
        New-Item $ArtifactStagingDirectory -ItemType Directory
        Invoke-ArchiveConfigurationMigrationData $BuildSourceDirectory $ArtifactStagingDirectory $Repo $SolutionName
    }
}