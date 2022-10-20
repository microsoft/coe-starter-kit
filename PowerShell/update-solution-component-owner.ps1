function Invoke-UpdateSolutionComponentOwner {
    param (
        [Parameter()] [String]$dataverseConnectionString,
        [Parameter()] [String]$serviceConnection,
        [Parameter()] [String]$microsoftXrmDataPowerShellModule,
        [Parameter()] [String]$xrmDataPowerShellVersion,
        [Parameter()] [String]$solutionComponentOwnershipConfiguration
    )
	if($solutionComponentOwnershipConfiguration -ne ''){
        Write-Host "Importing PowerShell Module: $microsoftXrmDataPowerShellModule - $xrmDataPowerShellVersion"
        Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $xrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }

        $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"
        $impersonationConn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

        $flowsToSetOwners = [System.Collections.ArrayList]@()
        Get-OwnerFlowActivations $solutionComponentOwnershipConfiguration "" $conn $flowsToSetOwners

        foreach ($ownershipConfig in $flowsToSetOwners) {
            #Need to deactivate the flow before setting ownership if currently active
            if ($ownershipConfig.solutionComponent.statecode_Property.Value -ne 0) {
                Write-Host "Deactivating the Flow"
                Set-CrmRecordState -conn $impersonationConn -EntityLogicalName workflow -Id $ownershipConfig.solutionComponentUniqueName -StateCode 0 -StatusCode 1
            }
            Write-Host "Setting flow owner: "$ownershipConfig.solutionComponent.name
            $impersonationConn.OrganizationWebProxyClient.CallerId = $ownershipConfig.impersonationCallerId
            Set-CrmRecordOwner -conn $conn $ownershipConfig.solutionComponent $ownershipConfig.impersonationCallerId
        }
    }
}