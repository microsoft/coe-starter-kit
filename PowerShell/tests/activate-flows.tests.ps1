param(
    $MicrosoftXrmDataPowerShellModule, $XrmDataPowerShellVersion, $MicrosoftPowerAppsAdministrationPowerShellModule, $PowerAppsAdminModuleVersion,
    $ActivationConfigPath, $ComponentOwnerConfigPath, $ConnectionReferenceConfigPath, $DataverseConnectionString, $ServiceConnection, $TenantId,
    $ClientId, $ClientSecret, $SolutionName, $EnvironmentId
)

Describe 'Activate-Flows-Test' {
    It 'ActivateFlows' -Tag 'ActivateFlows' {
        . ..\activate-flows.ps1
 
        Install-Module $MicrosoftXrmDataPowerShellModule -RequiredVersion $XrmDataPowerShellVersion -Force -AllowClobber
        Install-Module $MicrosoftPowerAppsAdministrationPowerShellModule -RequiredVersion $PowerAppsAdminModuleVersion -Force -AllowClobber
    
        . .\utilities.tests.ps1
    
        $activationConfig = Invoke-SetDeploymentVariable "$ActivationConfigPath" "ActivateFlowConfiguration"
        $componentOwnerConfig = Invoke-SetDeploymentVariable "$ComponentOwnerConfigPath" "SolutionComponentOwnershipConfiguration"
        $connectionReferenceConfig = Invoke-SetDeploymentVariable "$ConnectionReferenceConfigPath" "ConnectionReferences"
    
        #Deactivate the flows to test
        $activationConfigs = Get-Content $activationConfig | ConvertFrom-Json
        Write-Host "Importing PowerShell Module: $MicrosoftXrmDataPowerShellModule - $XrmDataPowerShellVersion"
        Import-Module $MicrosoftXrmDataPowerShellModule -Force -RequiredVersion $XrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }
    
        $connectionString = $DataverseConnectionString
    
        $conn = Get-CrmConnection -ConnectionString $connectionString
        foreach ($activateConfig in $activationConfigs){
            if($activateConfig.solutionComponentUniqueName -ne ''){
                $workflow = Get-CrmRecord -conn $conn -EntityLogicalName workflow -Id $activateConfig.solutionComponentUniqueName -Fields clientdata,category,statecode
                Set-CrmRecordState -conn $conn -EntityLogicalName workflow -Id $workflow.workflowid -StateCode 0 -StatusCode 1
            }
        }
        Invoke-ActivateFlows $DataverseConnectionString $ServiceConnection $MicrosoftXrmDataPowerShellModule $XrmDataPowerShellVersion $MicrosoftPowerAppsAdministrationPowerShellModule $PowerAppsAdminModuleVersion $TenantId $ClientId $ClientSecret $SolutionName $EnvironmentId $componentOwnerConfig $connectionReferenceConfig $activationConfig
    }
}