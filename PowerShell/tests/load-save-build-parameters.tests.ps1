param(
    $ConfigFileOutPath, $BuildType, $ServiceConnectionName, $ServiceConnectionUrl, $SolutionName
)

Describe 'Load-Save-Build-Parameters' {
    It 'LoadsAndSavedBuildParameters' -Tag 'LoadsAndSavedBuildParameters' {

        . ..\load-save-pipeline-parameters.ps1
        Write-Build-Pipeline-Parameters "$ConfigFileOutPath" $BuildType $ServiceConnectionName $ServiceConnectionUrl $SolutionName
        Read-Pipeline-Parameters "$ConfigFileOutPath"
    }
}