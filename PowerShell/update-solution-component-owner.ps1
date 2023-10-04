<#
This function updates solution component owner.
#>
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

        $flowsToSetOwners = [System.Collections.ArrayList]@()
        Get-OwnerFlowActivations $solutionComponentOwnershipConfiguration "" $conn $flowsToSetOwners

        foreach ($ownershipConfig in $flowsToSetOwners) {
            $validatedId = Invoke-Validate-And-Clean-Guid $ownershipConfig.solutionComponentUniqueName
            if (!$validatedId) {
                Write-Host "Invalid  flow GUID $($ownershipConfig.solutionComponentUniqueName). Exiting from Invoke-UpdateSolutionComponentOwner."
                return
            }
            Write-Host "OwnershipConfig.solutionComponentType - $($ownershipConfig.solutionComponentType)"
            # Skip this for Canvas Apps
            if($ownershipConfig.solutionComponentType -eq 300)
            {
                Write-Host "Skipping this for Canvas App $($ownershipConfig.solutionComponentName)."
            }else{
                #Need to deactivate the flow before setting ownership if currently active
                if ($ownershipConfig.solutionComponent.statecode_Property.Value -ne 0) {
                    Write-Host "Deactivating the Flow - $($ownershipConfig.solutionComponentName)"
                    Set-CrmRecordState -conn $conn -EntityLogicalName workflow -Id $validatedId -StateCode 0 -StatusCode 1
                }
                Write-Host "Setting flow - $validatedId owner to $($ownershipConfig.impersonationCallerId)"
                Set-CrmRecordOwner -conn $conn $ownershipConfig.solutionComponent $ownershipConfig.impersonationCallerId
            }
        }
    }
}