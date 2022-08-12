param(
    $CdsBaseConnectionString, $ServiceConnection, $MicrosoftXrmDataPowerShellModule, $XrmDataPowerShellVersion, $SolutionComponentOwnershipConfigurationPath
)

Describe 'Enable-Disable-Solution-Flows-Test' {
    It 'EnablesDisablesFlows' -Tag 'EnablesDisablesFlows' {

        . ..\activate-flows.ps1
        . ..\update-solution-component-owner.ps1
        . .\utilities.tests.ps1
   
        $componentOwnerConfig = Invoke-SetDeploymentVariable "$SolutionComponentOwnershipConfigurationPath" "SolutionComponentOwnershipConfiguration"
        Invoke-UpdateSolutionComponentOwner $CdsBaseConnectionString $ServiceConnection $MicrosoftXrmDataPowerShellModule $XrmDataPowerShellVersion $componentOwnerConfig
    }
}