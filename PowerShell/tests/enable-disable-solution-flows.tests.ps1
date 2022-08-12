param(
    $BuildSourceDirectory, $Repo, $SolutionName, $DisableAllFlows, $ActivationConfigPath
)

Describe 'Enable-Disable-Solution-Flows-Test' {
    It 'EnablesDisablesFlows' -Tag 'EnablesDisablesFlows' {

        . ..\enable-disable-solution-flows.ps1
        . .\utilities.tests.ps1
        $activationConfig = Invoke-SetDeploymentVariable "$ActivationConfigPath" "ActivateFlowConfiguration"
        Set-EnableDisableSolutionFlows $BuildSourceDirectory $Repo $SolutionName $DisableAllFlows $ActivationConfig
    }
}