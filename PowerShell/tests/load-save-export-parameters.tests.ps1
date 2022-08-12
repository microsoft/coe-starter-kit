param(
    $ConfigFileOutPath, $GitAccessUrl, $Project, $Repo, $Branch, $BranchToCreate, $CommitMessage, $Email, $ServiceConnectionName, $ServiceConnectionUrl,
    $SolutionName, $UserName, $DeploymentSettingsData
)

Describe 'Load-Save-Deploy-Parameters' {
    It 'LoadsAndSavedDeployParameters' -Tag 'LoadsAndSavedDeployParameters' {
        . ..\load-save-pipeline-parameters.ps1
        $ENV:DEPLOYMENT_SETTINGS = $DeploymentSettingsData
        Write-Export-Pipeline-Parameters "$ConfigFileOutPath" $GitAccessUrl $Project $Repo $Branch $BranchToCreate $CommitMessage $Email $ServiceConnectionName $ServiceConnectionUrl $SolutionName $UserName
        Read-Pipeline-Parameters "$ConfigFileOutPath"
    }
}