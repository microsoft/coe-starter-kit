function Invoke-ArchiveConfigurationMigrationData($buildSourceDirectory, $artifactStagingDirectory, $repo, $solutionName) {
    $path = "$buildSourceDirectory\$repo\$solutionName\config\ConfigurationMigrationData"
    if(Test-Path $path) {
        $compress = @{
            Path = $path + '\*.*'
            CompressionLevel = 'Fastest'
            DestinationPath = "$artifactStagingDirectory/ConfigurationMigrationData.zip"
        }
        Compress-Archive @compress
    }
    $settingFiles = @("deploymentSettings","customDeploymentSettings")

    foreach ($settingFile in $settingFiles) {
        $path = "$buildSourceDirectory\$repo\$solutionName\config\$settingFile.json"
        if(Test-Path $path) {
            Copy-Item $path "$artifactStagingDirectory/$settingFile.json"
        }
    }

    if(Test-Path "$buildSourceDirectory\$repo\$solutionName\config") {
        Get-ChildItem -Path "$buildSourceDirectory\$repo\$solutionName\config" | 
        ForEach-Object {
            $environment = $_.Name
            $path = "$buildSourceDirectory\$repo\$solutionName\config\$environment\ConfigurationMigrationData"
            if(Test-Path $path) {
                $compress = @{
                    Path = $path + '\*.*'
                    CompressionLevel = 'Fastest'
                    DestinationPath = "$artifactStagingDirectory/ConfigurationMigrationData-" + $environment + ".zip"
                }
                Compress-Archive @compress
            }
            foreach ($settingFile in $settingFiles) {
                $path = "$buildSourceDirectory\$repo\$solutionName\config\$environment\$settingFile.json"
                if(Test-Path $path) {
                    Copy-Item $path "$artifactStagingDirectory/$settingFile-$environment.json"
                }
            }
        }
    }
}