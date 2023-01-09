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

    Get-UserConfiguredFlowActivations $activateFlowConfiguration $conn $flowsToActivate $token $dataverseHost
    Get-ConnectionReferenceFlowActivations $solutionName $connectionReferences $activateFlowConfiguration $conn $flowsToActivate
    Get-OwnerFlowActivations $solutionComponentOwnershipConfiguration $activateFlowConfiguration $conn $flowsToActivate
    
    print-flows "Printing total active flows" $flowsToActivate

    Write-Host "Activating flows..."
    #Activate any flows added to the collection based on sort order
    $impersonationConn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"
    $flowsToActivate = $flowsToActivate | Sort-Object -Property sortOrder
    $flowsActivatedThisPass = $false
    $throwOnComplete = $false
    do {
        $throwOnComplete = $false
        $flowsActivatedThisPass = $false
        foreach ($flowToActivate in $flowsToActivate) {
            try {
                if ($flowToActivate.solutionComponent.statecode -ne 1) {
                    Write-Host "Activating Flow: " $flowToActivate.solutionComponent.name
                    $impersonationConn.OrganizationWebProxyClient.CallerId = $flowToActivate.impersonationCallerId
                    Set-CrmRecordState -conn $impersonationConn -EntityLogicalName workflow -Id $flowToActivate.solutionComponent.workflowid -StateCode 1 -StatusCode 2
                    $flowToActivate.solutionComponent.statecode = 1
                    $flowsActivatedThisPass = $true
                }
                else{
                    Write-Host "Workflow " $flowToActivate.solutionComponentName " already activated at target"
                }
            }
            catch {
                $throwOnComplete = $true
                Write-Host "##vso[task.logissue type=warning]Flow could not be activated. Continuing with flow activation until no more flows can be activated. If this is a result of a child flow not being activated before it's parent consider ordering your flows to avoid this message."
                Write-Host $_
            }
        }
    } while ($flowsActivatedThisPass)

    Write-Host "Getting flows to deactivate..."
    $flowsToDeactivate = get-flows-to-deactivate $activateFlowConfiguration $flowsToActivate
    if($flowsToDeactivate.Count -gt 0){
        $flowsToDeactivate = $flowsToDeactivate | Sort-Object -Property sortOrder    
        print-flows "Printing flows to deactivate" $flowsToDeactivate
        $flowsDeactivatedThisPass = $false
        do {
            $throwOnComplete = $false
            $flowsDeactivatedThisPass = $false
            foreach ($flowToDeactivate in $flowsToDeactivate) {
                try {
                    if($flowToDeactivate.solutionComponentUniqueName -ne $null -and $flowToDeactivate.solutionComponentUniqueName -ne ''){
                        $existingStatus = get-workflow-dv-status $flowToDeactivate.solutionComponentUniqueName $token $dataverseHost
                        if ($existingStatus -ne 0) {
                            Write-Host "Dectivating Flow: " $flowToDeactivate.solutionComponentName
                            Set-CrmRecordState -conn $impersonationConn -EntityLogicalName workflow -Id $flowToDeactivate.solutionComponentUniqueName -StateCode 0 -StatusCode 1
                            $flowsDeactivatedThisPass = $true
                        }
                        else{
                            Write-Host "Workflow " $flowToDeactivate.solutionComponentName " already deactivated at target"
                        }
                    }
                }
                catch {
                    $throwOnComplete = $true
                    Write-Host "##vso[task.logissue type=warning]Flow could not be deactivated. Continuing with flow deactivation until no more flows can be deactivated. If this is a result of a child flow not being deactivated before it's parent consider ordering your flows to avoid this message."
                    Write-Host $_
                }
            }
        } while ($flowsActivatedThisPass)

        if ($throwOnComplete) {
            throw
        }
    }
    else{
		Write-Host "No flows to deactivate"
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
        foreach ($activateConfig in $activationConfigs) {
            if ($activateConfig.activateAsUser -ne '' -and $activateConfig.solutionComponentUniqueName -ne '' -and $activateConfig.activate -ne 'false') {
                $existingActivation = $flowsToActivate | Where-Object { $_.solutionComponentUniqueName -eq $activateConfig.solutionComponentUniqueName } | Select-Object -First 1
                if ($null -eq $existingActivation) {
                    $workflow = Get-CrmRecord -conn $conn -EntityLogicalName workflow -Id $activateConfig.solutionComponentUniqueName -Fields clientdata, category, statecode, name
                    $existingStatus = get-workflow-dv-status $activateConfig.solutionComponentUniqueName $token $dataverseHost

                    $systemUserResult = Get-CrmRecords -conn $conn -EntityLogicalName systemuser -FilterAttribute "internalemailaddress" -FilterOperator "eq" -FilterValue $activateConfig.activateAsUser -Fields systemuserid
                    if ($systemUserResult.Count -gt 0) {
                        $impersonationCallerId = $systemUserResult.CrmRecords[0].systemuserid
                        #$existingStatus = $workflow.statecode_Property.Value
                        Write-Host "existingStatus - "$existingStatus
                        #Activate the workflow using the specified user.
                        #if ($existingStatus -ne 1) {
                            Write-Host "1 - Adding flow " $activateConfig.solutionComponentName " to activation collection"
                            $flowActivation = [PSCustomObject]@{}
                            $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponentUniqueName' -Value $activateConfig.solutionComponentUniqueName
                            $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponentName' -Value $activateConfig.solutionComponentName
                            $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponent' -Value $workflow
                            $flowActivation | Add-Member -MemberType NoteProperty -Name 'impersonationCallerId' -Value $impersonationCallerId
                            $flowActivation | Add-Member -MemberType NoteProperty -Name 'sortOrder' -Value $activateConfig.sortOrder
                            $flowsToActivate.Add($flowActivation)
                        #}
                        #else{
                        #    Write-Host "Flow " $activateConfig.solutionComponentName " is already activated at target"
                        #}
                    }
                    else {
                        Write-Host "##vso[task.logissue type=warning]A specified user record was not found in the target environment. Verify your deployment configuration and try again."
                    }
                }
            }
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
                                                    $flowsToActivate.Add($flowActivation)
                                                }
                                                else {
                                                    Write-Host "Excluding flow " $activationConfig.solutionComponentName "from activation collection"
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
        print-flows "Inside Get-OwnerFlowActivations; Prinitng Active Flows" $flowsToActivate

        Write-Host "activationConfigs - " $activationConfigs
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
                        $systemuserResult = Get-CrmRecords -conn $conn -EntityLogicalName systemuser -FilterAttribute "internalemailaddress" -FilterOperator "eq" -FilterValue $ownershipConfig.ownerEmail -Fields systemuserid
                        if ($systemuserResult.Count -gt 0) {
                            $systemUserId = $systemuserResult.CrmRecords[0].systemuserid
                            #Activate the workflow using the owner.
                            $sortOrder = [int]::MaxValue
                            $activateFlow = 'true'
                            if ($null -ne $activationConfigs) {
                                Write-Host "Retrieving activation config"
                                $activationConfig = $activationConfigs | Where-Object { $_.solutionComponentUniqueName -eq $solutionComponent.objectid } | Select-Object -First 1
                                if ($null -ne $activationConfig) {
                                    if($activationConfig.sortOrder -ne '') {
                                        $sortOrder = $activationConfig.sortOrder
                                    }

                                    Write-Host "activationConfig.activate - " $activationConfig.activate
                                    $activateFlow = $activationConfig.activate
                                }
                            }

                            if ($activateFlow -eq 'true') {
                                Write-Host "3 - Adding flow " $ownershipConfig.solutionComponentName " to activation collection"
                                $flowActivation = [PSCustomObject]@{}
    
                                $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponentUniqueName' -Value $ownershipConfig.solutionComponentUniqueName
                                $flowActivation | Add-Member -MemberType NoteProperty -Name 'solutionComponent' -Value $workflow
                                $flowActivation | Add-Member -MemberType NoteProperty -Name 'impersonationCallerId' -Value $systemUserId
                                $flowActivation | Add-Member -MemberType NoteProperty -Name 'sortOrder' -Value $sortOrder
                                $flowsToActivate.Add($flowActivation)
                            }
                            else{
                                Write-Host "Flow " $ownershipConfig.solutionComponentName " tagged for deactivation. Not adding to activation list"
                            }
                        }
                        else {
                            Write-Host "##vso[task.logissue type=warning]A specified user record was not found in the target environment. Verify your deployment configuration and try again."
                        }
                    }
                    else {
                        Write-Host "##vso[task.logissue type=warning]A specified flow was not found in the target environment. Verify your deployment configuration and try again."
                    }
                }
            }
        }
    }    
}

function print-flows{
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
            Write-Host "Flow Name: " $flowToActivate.solutionComponentName
        }		
    }
}

function get-flows-to-deactivate{
 param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$activateFlowConfiguration,        
        [Parameter()] [System.Collections.ArrayList] [AllowEmptyCollection()]$flowsToActivate
    )

    Write-Host "Inside get-flows-to-deactivate"
    $flowsToDeactivate = [System.Collections.ArrayList]@()
    $activationConfigs = Get-ActivationConfigurations $activateFlowConfiguration

    if ($null -ne $activationConfigs) {
        foreach ($activateConfig in $activationConfigs) {
            $existingActivation = $null
            if($flowsToActivate -ne $null -and $flowsToActivate.Count -gt 0){
                $existingActivation = $flowsToActivate | Where-Object { $_.solutionComponentUniqueName -eq $activateConfig.solutionComponentUniqueName } | Select-Object -First 1
            }

            # Add the flow configiration if its not in Flows to Activate list
            if ($null -eq $existingActivation -and $activateConfig.activate -eq 'false') {
                $flowDeactivation = [PSCustomObject]@{}
                $flowDeactivation | Add-Member -MemberType NoteProperty -Name 'solutionComponentUniqueName' -Value $activateConfig.solutionComponentUniqueName
                $flowDeactivation | Add-Member -MemberType NoteProperty -Name 'solutionComponentName' -Value $activateConfig.solutionComponentName
                $flowDeactivation | Add-Member -MemberType NoteProperty -Name 'sortOrder' -Value $activateConfig.sortOrder
                Write-Host "Adding " $activateConfig.solutionComponentName " to deactivation list"
                $flowsToDeactivate.Add($flowDeactivation)
            }
        }
    }

    return $flowsToDeactivate
}

function get-workflow-dv-status{
 param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$workflowId,        
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$token,        
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$dataverseHost        
    )
        $existingStatus = -1
        # Check current status of workflow
        $queryWorkflow = "workflows?`$select=clientdata,category,statecode,name&`$filter=(workflowid eq '$workflowId')"    

        try{
        Write-Host "Workflow Query - $queryWorkflow"
        $workflowResponse = Invoke-DataverseHttpGet $token $dataverseHost $queryWorkflow
        }
        catch{
        Write-Host "Error $queryWorkflow - $($_.Exception.Message)"
        }

        if($null -ne $workflowResponse.value -and $workflowResponse.value.count -gt 0){
            $existingStatus = $workflowResponse.value[0].statecode
            Write-Host "Workflow status is $existingStatus"
        }

        return $existingStatus
}