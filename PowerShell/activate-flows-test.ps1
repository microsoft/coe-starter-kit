function Invoke-ActivateFlows-Test()
{
	. .\activate-flows.ps1
    $testConfig = Get-Content ".\TestData\activate-flows-test.config.json" | ConvertFrom-Json

    Install-Module $testConfig.microsoftXrmDataPowerShellModule -RequiredVersion $testConfig.xrmDataPowerShellVersion -Force -AllowClobber
    Install-Module $testConfig.microsoftPowerAppsAdministrationPowerShellModule -RequiredVersion $testConfig.powerAppsAdminModuleVersion -Force -AllowClobber

	. .\utilities-test.ps1

    $activationConfig = Invoke-SetDeploymentVariable ".\TestData\Solutions\coe-starter-kit-azdo\ALMAcceleratorSampleSolution\config\customDeploymentSettings.json" "ActivateFlowConfiguration"
    $componentOwnerConfig = Invoke-SetDeploymentVariable ".\TestData\Solutions\coe-starter-kit-azdo\ALMAcceleratorSampleSolution\config\customDeploymentSettings.json" "SolutionComponentOwnershipConfiguration"
    $connectionReferenceConfig = Invoke-SetDeploymentVariable ".\TestData\Solutions\coe-starter-kit-azdo\ALMAcceleratorSampleSolution\config\deploymentSettings.json" "ConnectionReferences"

    #Deactivate the flows to test
    $activationConfigs = ConvertFrom-Json $activationConfig
    Write-Host "Importing PowerShell Module: $testConfig.microsoftXrmDataPowerShellModule - $testConfig.xrmDataPowerShellVersion"
    Import-Module $testConfig.microsoftXrmDataPowerShellModule -Force -RequiredVersion $testConfig.xrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }

    $connectionString = $testConfig.cdsBaseConnectionString + $testConfig.serviceConnection

    $conn = Get-CrmConnection -ConnectionString $connectionString
    foreach ($activateConfig in $activationConfigs){
        if($activateConfig.solutionComponentUniqueName -ne ''){
            $workflow = Get-CrmRecord -conn $conn -EntityLogicalName workflow -Id $activateConfig.solutionComponentUniqueName -Fields clientdata,category,statecode
            Set-CrmRecordState -conn $conn -EntityLogicalName workflow -Id $workflow.workflowid -StateCode 0 -StatusCode 1
        }
    }
    Invoke-ActivateFlows $testConfig.cdsBaseConnectionString $testConfig.serviceConnection $testConfig.microsoftXrmDataPowerShellModule $testConfig.xrmDataPowerShellVersion $testConfig.microsoftPowerAppsAdministrationPowerShellModule $testConfig.powerAppsAdminModuleVersion $testConfig.tenantId $testConfig.clientId $testConfig.clientSecret $testConfig.solutionName $testConfig.environmentId $componentOwnerConfig $connectionReferenceConfig $activationConfig
}

Invoke-ActivateFlows-Test