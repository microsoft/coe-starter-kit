function Invoke-ActivateFlows {
    param (
        [Parameter(Mandatory)] [String]$dataverseConnectionString, 
        [Parameter(Mandatory)] [String]$serviceConnection,
        [Parameter(Mandatory)] [String]$microsoftXrmDataPowerShellModule, 
        [Parameter(Mandatory)] [String]$xrmDataPowerShellVersion,
        [Parameter(Mandatory)] [String]$microsoftPowerAppsAdministrationPowerShellModule, 
        [Parameter(Mandatory)] [String]$powerAppsAdminModuleVersion,
        [Parameter(Mandatory)] [String]$tenantId, 
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret, 
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$environmentId, 
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$solutionComponentOwnershipConfiguration,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$connectionReferences, 
        [Parameter(Mandatory)] [String][AllowEmptyString()]$activateFlowConfiguration,
        [Parameter()] [String]$token
    )

    Write-Host "Importing PowerShell Module: $microsoftPowerAppsAdministrationPowerShellModule - $powerAppsAdminModuleVersion"
    Import-Module $microsoftPowerAppsAdministrationPowerShellModule -Force -RequiredVersion $powerAppsAdminModuleVersion -ArgumentList @{ NonInteractive = $true }

    Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $clientId -ClientSecret $clientSecret

    Write-Host "Importing PowerShell Module: $microsoftXrmDataPowerShellModule - $xrmDataPowerShellVersion"
    Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $xrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }

    $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

    . "$env:POWERSHELLPATH/dataverse-webapi-functions.ps1"
    $dataverseHost = Get-HostFromUrl "$serviceConnection"
    Write-Host "dataverseHost - $dataverseHost"

    Write-Host "solutionComponentOwnershipConfiguration - " $solutionComponentOwnershipConfiguration
    Write-Host "connectionReferences - " $connectionReferences
    Write-Host "activateFlowConfiguration - " $activateFlowConfiguration

    $flowsToActivate = [System.Collections.ArrayList]@()

    #Connection Reference based Flow Activations must be first as they shouldn't be overridden by owner based activations
    Get-ConnectionReferenceFlowActivations $solutionName $connectionReferences $activateFlowConfiguration $conn $flowsToActivate
    #Owner based Flow Activations must be second as they can't override the connection reference based activations
    Get-OwnerFlowActivations $solutionComponentOwnershipConfiguration $activateFlowConfiguration $conn $flowsToActivate
    #User Configured Flow Activations must be last as they should override all other configurations based on the user's input
    Get-UserConfiguredFlowActivations $activateFlowConfiguration $conn $flowsToActivate $token $dataverseHost
    
    Write-Flows "Printing total active flows" $flowsToActivate

    Write-Host "Activating flows..."
    #Activate any flows added to the collection based on sort order
    $flowsToActivate = $flowsToActivate | Sort-Object -Property sortOrder
    $flowsActivatedDeactivatedThisPass = $false
    $throwOnComplete = $false
    do {
        $throwOnComplete = $false
        $flowsActivatedDeactivatedThisPass = $false
        foreach ($flowToActivate in $flowsToActivate) {
            $impersonationConn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"
            try {
                if ($flowToActivate.activate -eq 'false' -and $flowToActivate.solutionComponent.statecode -ne 0) {
                    Write-Host "Deactivating Flow: " $flowToActivate.solutionComponent.name
                    Set-CrmRecordState -conn $impersonationConn -EntityLogicalName workflow -Id $flowToActivate.solutionComponent.workflowid -StateCode 0 -StatusCode 1
                    $flowToActivate.solutionComponent.statecode = 0
                    $flowsActivatedDeactivatedThisPass = $true
                }
                elseif ($flowToActivate.activate -ne 'false' -and $flowToActivate.solutionComponent.statecode -ne 1) {
                    Write-Host "Activating Flow: " $flowToActivate.solutionComponent.name " as: " $flowToActivate.impersonationCallerId
                    if($flowToActivate.impersonationCallerId -ne '') {
                        $impersonationConn.OrganizationWebProxyClient.CallerId = $flowToActivate.impersonationCallerId
                    }
                    Write-Host "Impersonation Connection CallerId: " $impersonationConn.OrganizationWebProxyClient.CallerId
                    Set-CrmRecordState -conn $impersonationConn -EntityLogicalName workflow -Id $flowToActivate.solutionComponent.workflowid -StateCode 1 -StatusCode 2
                    $flowToActivate.solutionComponent.statecode = 1
                    $flowsActivatedDeactivatedThisPass = $true
                }
                else{
                    Write-Host "Workflow " $flowToActivate.solutionComponent.name " already activated/deactivated at target"
                }
            }
            catch {
                $throwOnComplete = $true
                Write-Host "##vso[task.logissue type=warning]Flow could not be activated. Continuing with flow activation until no more flows can be activated. If this is a result of a child flow not being activated before it's parent consider ordering your flows to avoid this message."
                Write-Host $_
            }
        }
    } while ($flowsActivatedDeactivatedThisPass)

    if ($throwOnComplete) {
        throw
    }
}

function Get-ActivationConfigurations {
    param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$activateFlowConfiguration
    )
    $activationConfigs = $null
    if ($activateFlowConfiguration -ne "") {
        $activationConfigs = Get-Content $activateFlowConfiguration | ConvertFrom-Json
        $activationConfigs | ForEach-Object { if ($_.sortOrder -match '^\d+$') { $_.sortOrder = [int]$_.sortOrder } else { $_.sortOrder = [int]::MaxValue } }
    }
    return $activationConfigs
}

function Get-UserConfiguredFlowActivations {
    param (
        [Parameter(Mandatory)] [System.Collections.ArrayList] [AllowEmptyCollection()]$activateFlowConfiguration,
        [Parameter(Mandatory)] [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]$conn,
        [Parameter()] [System.Collections.ArrayList] [AllowEmptyCollection()]$flowsToActivate,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$token,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$dataverseHost
    )

    Write-Host "Inside Get-UserConfiguredFlowActivations"
    $activationConfigs = Get-ActivationConfigurations $activateFlowConfiguration
    # Turn on specified list of flows using a specified user.
    # This should be an ordered list of flows that must be turned on before any other dependent (parent) flows can be turned on.
    if ($null -ne $activationConfigs) {
        $throwOnComplete = $false
        foreach ($activateConfig in $activationConfigs) {
            if ($activateConfig.solutionComponentUniqueName -ne '') {
                $flowActivation = $flowsToActivate | Where-Object { $_.solutionComponentUniqueName -eq $activateConfig.solutionComponentUniqueName } | Select-Object -First 1
                $workflow = Get-CrmRecord -conn $conn -EntityLogicalName workflow -Id $activateConfig.solutionComponentUniqueName -Fields clientdata, category, statecode, name
                $impersonationCallerId = ''
                if($activateConfig.activateAsUser -ne '') {
                    $systemUserResult = Get-CrmRecords -conn $conn -EntityLogicalName systemuser -FilterAttribute "internalemailaddress" -FilterOperator "eq" -FilterValue $activateConfig.activateAsUser -Fields systemuserid
                    if ($systemUserResult.Count -gt 0) {
                        $impersonationCallerId = $systemUserResult.CrmRecords[0].systemuserid
                    }
                    else {
                        Write-Host "##vso[task.logissue type=warning]A specified user record was not found in the target environment. Verify your deployment configuration and try again."
                        $throwOnComplete = $true
                    }
                }

                if ($null -eq $flowActivation) {
                    Write-Host "1 - Adding flow " $activateConfig.solutionComponentName " to activation collection"
                    $flowActivation = [PSCustomObject]@{}
                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponentUniqueName' -Value $activateConfig.solutionComponentUniqueName
                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponent' -Value $workflow
                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'impersonationCallerId' -Value $impersonationCallerId
                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'sortOrder' -Value $activateConfig.sortOrder
                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'activate' -Value $activateConfig.activate
                    $flowsToActivate.Add($flowActivation)
                }
                elseif($impersonationCallerId -ne '') {
                    Write-Host "1 - Updating existing flow activation " $activateConfig.solutionComponentName
                    $flowActivation.solutionComponentUniqueName = $activateConfig.solutionComponentUniqueName
                    $flowActivation.solutionComponent = $workflow
                    $flowActivation.impersonationCallerId = $impersonationCallerId
                    $flowActivation.activate = $activateConfig.activate
                    $flowActivation.sortOrder = $activateConfig.sortOrder
                }
            }
        }

        if($throwOnComplete) {
            throw
        }
    }
}

function Get-ConnectionReferenceFlowActivations {
    param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$solutionName,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$connectionReferences,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$activateFlowConfiguration,
        [Parameter(Mandatory)] [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]$conn,
        [Parameter()] [System.Collections.ArrayList] [AllowEmptyCollection()]$flowsToActivate
    )
    Write-Host "Inside Get-ConnectionReferenceFlowActivations"
    if($connectionReferences -ne "") {
        Write-Host "connectionReferences - " $connectionReferences
        $solutions = Get-CrmRecords -conn ([Microsoft.Xrm.Tooling.Connector.CrmServiceClient]$conn) -EntityLogicalName solution -FilterAttribute "uniquename" -FilterOperator "eq" -FilterValue "$solutionName" -Fields solutionid
        if ($solutions.Count -gt 0) {

            $solutionId = $solutions.CrmRecords[0].solutionid

            $result = Get-CrmRecords -conn $conn -EntityLogicalName solutioncomponent -FilterAttribute "solutionid" -FilterOperator "eq" -FilterValue $solutionId -Fields objectid, componenttype
            $solutionComponents = $result.CrmRecords

            $activationConfigs = Get-ActivationConfigurations $activateFlowConfiguration
            $config = Get-Content $connectionReferences | ConvertFrom-Json

            foreach ($connectionRefConfig in $config) {
                if ($connectionRefConfig.LogicalName -ne '' -and $connectionRefConfig.ConnectionId -ne '') {
                    # Get the connection reference to update
                    $connRefs = Get-CrmRecords -conn $conn -EntityLogicalName connectionreference -FilterAttribute "connectionreferencelogicalname" -FilterOperator "eq" -FilterValue $connectionRefConfig.LogicalName
                    if ($connRefs.Count -gt 0) {
                        $systemUserId = ""
                        if (-Not [string]::IsNullOrWhiteSpace($connectionRefConfig.ConnectionOwner)) {
                            $systemUserId = $connectionRefConfig.ConnectionOwner
                        }
                        else {
                            # Get connection as a fallback if owner is not specified in the config. 
                            $connections = Get-AdminPowerAppConnection -EnvironmentName $environmentId -Filter $connectionRefConfig.ConnectionId
                            if ($null -ne $connections) {
                                $systemUserId = $connections[0].CreatedBy.id
                            }
                        }
                        # Connection References can only be updated by an identity that has permissions to the connection it references
                        # As of authoring this script, Service Principals (SPN) cannot update connection references
                        # The temporary workaround is to impersonate the user that created the connection
    
                        if (-Not [string]::IsNullOrWhiteSpace($systemUserId)) {
                            # The ConnectionOwner variable may contain an email address - if so change the attribute we filter on
                            $filterAttribute = "azureactivedirectoryobjectid"
                            if ($systemUserId -Match "@") {
                                $filterAttribute = "internalemailaddress"
                            }

                            # Get Dataverse systemuserid for the system user that maps to the aad user guid that created the connection 
                            $systemusers = Get-CrmRecords -conn $conn -EntityLogicalName systemuser -FilterAttribute $filterAttribute -FilterOperator "eq" -FilterValue $systemUserId
                            if ($systemusers.Count -gt 0) {
                                # Impersonate the Dataverse systemuser that created the connection when updating the connection reference
                                $impersonationCallerId = $systemusers.CrmRecords[0].systemuserid

                                foreach ($solutionComponent in $solutionComponents) {
                                    if ($solutionComponent.componenttype -eq "Workflow") {
                                        $workflow = Get-CrmRecord -conn $conn -EntityLogicalName workflow -Id $solutionComponent.objectid -Fields clientdata, category, statecode, name

                                        $existingActivation = $flowsToActivate | Where-Object { $_.solutionComponentUniqueName -eq $solutionComponent.objectid } | Select-Object -First 1
                                        if ($null -eq $existingActivation) {
                                            if ($null -ne $workflow -and $null -ne $workflow.clientdata -and $workflow.clientdata.Contains($connectionRefConfig.LogicalName) -and $workflow.statecode_Property.Value -ne 1) {
                                                Write-Host "Retrieving activation config"
                                                $sortOrder = [int]::MaxValue
                                                $activateFlow = 'true'
                                                if ($null -ne $activationConfigs) {
                                                    $activationConfig = $activationConfigs | Where-Object { $_.solutionComponentUniqueName -eq $solutionComponent.objectid } | Select-Object -First 1
                                                    if ($null -ne $activationConfig) {
                                                        if($activationConfig.sortOrder -ne '') {
                                                            $sortOrder = $activationConfig.sortOrder
                                                        }
                                                        $activateFlow = $activationConfig.activate
                                                    }
                                                }

                                                if ($activateFlow -ne 'false') {
                                                    Write-Host "2 - Adding flow " $workflow.name " to activation collection"
                                                    $flowActivation = [PSCustomObject]@{}
                                                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponentUniqueName' -Value $solutionComponent.objectid
                                                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponent' -Value $workflow
                                                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'impersonationCallerId' -Value $impersonationCallerId
                                                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'sortOrder' -Value $sortOrder
                                                    $flowActivation | Add-Member -MemberType NoteProperty -Name 'activate' -Value $activateFlow
                                                    $flowsToActivate.Add($flowActivation)
                                                }
                                                else {
                                                    Write-Host "Excluding flow " $activationConfig.workflow.name "from activation collection"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            Write-Host "##vso[task.logissue type=warning]A specified connection was not found in the target environment. Verify your deployment configuration and try again."
                        }
                    }
                    else {
                        Write-Host "##vso[task.logissue type=warning]A specified connection reference was not found in the target environment. Verify your deployment configuration and try again."
                    }
                }
            }
        }
    }
}

function Get-OwnerFlowActivations {
    param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$solutionComponentOwnershipConfiguration,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$activateFlowConfiguration,
        [Parameter(Mandatory)] [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]$conn,
        [Parameter()] [System.Collections.ArrayList] [AllowEmptyCollection()]$flowsToActivate
    )
    Write-Host "Inside Get-OwnerFlowActivations"
    if($solutionComponentOwnershipConfiguration -ne "") {
        $rawContent = Get-Content $solutionComponentOwnershipConfiguration
        Write-Host "Ownership Configuration Content - " $rawContent

        $config = Get-Content $solutionComponentOwnershipConfiguration | ConvertFrom-Json
        $activationConfigs = Get-ActivationConfigurations $activateFlowConfiguration
        Write-Flows "Inside Get-OwnerFlowActivations; Printing Active Flows" $flowsToActivate

        Write-Host "activationConfigs - " $activationConfigs
        $throwOnComplete = $false
        foreach ($ownershipConfig in $config) {
            $existingActivation = $flowsToActivate | Where-Object { $_.solutionComponentUniqueName -eq $ownershipConfig.solutionComponentUniqueName } | Select-Object -First 1
            if ($null -eq $existingActivation) {
                if ($ownershipConfig.ownerEmail -ne '' -and $ownershipConfig.solutionComponentType -ne '' -and $ownershipConfig.solutionComponentUniqueName -ne '') {
                    switch ($ownershipConfig.solutionComponentType) {
                        # Workflow 
                        29 {  
                            $workflow = Get-CrmRecord -conn $conn -EntityLogicalName workflow -Id $ownershipConfig.solutionComponentUniqueName -Fields name, clientdata, category, statecode
                        } 
                        default {
                            Write-Host "##vso[task.logissue type=warning]NOT IMPLEMENTED - You supplied a solutionComponentType of $ownershipConfig.solutionComponentType for solutionComponentUniqueName $solutionComponentUniqueName"
                            exit 1;
                        }      
                    }

                    if ($null -ne $workflow) {
                        $matchedUser = Get-User-By-Email-or-DomainName $ownershipConfig.ownerEmail $conn
                        if ($matchedUser -ne $null) {
                            $systemUserId = $matchedUser.systemuserid
                            Write-Host "systemuserid - $systemUserId"
                            #Activate the workflow using the owner.
                            $sortOrder = [int]::MaxValue
                            $activateFlow = 'true'
                            if ($null -ne $activationConfigs) {
                                Write-Host "Retrieving activation config"
                                $activationConfig = $activationConfigs | Where-Object { $_.solutionComponentUniqueName -eq $ownershipConfig.solutionComponentUniqueName } | Select-Object -First 1
                                if ($null -ne $activationConfig) {
                                    if($activationConfig.sortOrder -ne '') {
                                        $sortOrder = $activationConfig.sortOrder
                                    }

                                    Write-Host "activationConfig.activate - " $activationConfig.activate
                                    $activateFlow = $activationConfig.activate
                                }
                            }

                            if ($activateFlow -ne 'false') {
                                Write-Host "3 - Adding flow " $ownershipConfig.solutionComponentName " to activation collection"
                                $flowActivation = [PSCustomObject]@{}
    
                                $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponentUniqueName' -Value $ownershipConfig.solutionComponentUniqueName
                                $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponent' -Value $workflow
                                $flowActivation | Add-Member -MemberType NoteProperty -Name 'impersonationCallerId' -Value $systemUserId
                                $flowActivation | Add-Member -MemberType NoteProperty -Name 'sortOrder' -Value $sortOrder
                                $flowActivation | Add-Member -MemberType NoteProperty -Name 'activate' -Value $activateFlow
                                $flowsToActivate.Add($flowActivation)
                            }
                            else{
                                Write-Host "Flow " $ownershipConfig.solutionComponentName " tagged for deactivation. Not adding to activation list"
                            }
                        }
                        else {
                            Write-Host "##vso[task.logissue type=warning]A specified user record was not found in the target environment. Verify your deployment configuration and try again."
                            $throwOnComplete = $true
                        }
                    }
                    else {
                        Write-Host "##vso[task.logissue type=warning]A specified flow was not found in the target environment. Verify your deployment configuration and try again."
                        $throwOnComplete = $true
                    }
                }
            }
        }

        if($throwOnComplete) {
            throw
        }
    }    
}

function Write-Flows{
 param (
        [Parameter()] [String] [AllowEmptyString()]$message,        
        [Parameter()] [System.Collections.ArrayList] [AllowEmptyCollection()]$flowsToActivate
    )

    Write-Host "$message"
	if($flowsToActivate -ne $null)
	{
		if($flowsToActivate.Count -eq 0)
		{
		    Write-Host "No flows to print"
        }
		
        foreach ($flowToActivate in $flowsToActivate) {
            Write-Host "Flow Name: " $flowToActivate.solutionComponent.name
        }		
    }
}

function Get-User-By-Email-or-DomainName{
 param(
    [Parameter()] [String] [AllowEmptyString()]$filterValue,
    [Parameter(Mandatory)] [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]$conn
    )

    $matchedUser = $null
    $fetch = @"
    <fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='false'>
      <entity name='systemuser'>
        <attribute name='systemuserid' />
        <filter type='and'>
          <filter type='or'>
            <condition attribute='internalemailaddress' operator='eq' value='$filterValue' />
            <condition attribute='domainname' operator='eq' value='$filterValue' />
          </filter>
        </filter>
      </entity>
    </fetch>
"@

    Write-Host "Request XML - "$fetch
    $records = Get-CrmRecordsByFetch -Fetch $fetch -conn $conn
    try{
        $json = ConvertTo-Json $records
        Write-Host "Response - $json"        
        
        if($records -and $records.CrmRecords){  
            $matchedUser = $records.CrmRecords[0]
        }
    }
    catch {
        Write-Host "An error occurred in Get-User-By-Email-or-DomainName: $($_.Exception.Message)"
    }

    return $matchedUser
}