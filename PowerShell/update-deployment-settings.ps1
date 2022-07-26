function Set-DeploymentSettingsConfiguration
{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [String]$cdsBaseConnectionString,
        [Parameter(Mandatory)] [String]$xrmDataPowerShellVersion,
        [Parameter(Mandatory)] [String]$microsoftXrmDataPowerShellModule,
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$projectId,
        [Parameter(Mandatory)] [String]$projectName,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$azdoAuthType,
        [Parameter(Mandatory)] [String]$serviceConnection,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter()] [String]$generateEnvironmentVariables,
        [Parameter()] [String]$generateConnectionReferences,
        [Parameter()] [String]$generateFlowConfig,
        [Parameter()] [String]$generateCanvasSharingConfig,
        [Parameter()] [String]$generateAADGroupTeamConfig,
        [Parameter()] [String]$generateCustomConnectorConfig
    )
    $configurationData = $env:DEPLOYMENT_SETTINGS | ConvertFrom-Json
    Write-Host (ConvertTo-Json -Depth 10 $configurationData)
    #Generate Deployment Settings
    Write-Host "Update Deployment Settings"
    $customDeploymentSettingsFilePath = "$buildSourceDirectory\$repo\$solutionName\config\customDeploymentSettings.json"
    $deploymentSettingsFilePath = "$buildSourceDirectory\$repo\$solutionName\config\deploymentSettings.json"
    if(!(Test-Path "$buildSourceDirectory\$repo\$solutionName\config\")) {
        New-Item "$buildSourceDirectory\$repo\$solutionName\" -Name "config" -ItemType "directory"
    }
    Write-Host "Importing PowerShell Module: $microsoftXrmDataPowerShellModule - $xrmDataPowerShellVersion"
    Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $xrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }
    $conn = Get-CrmConnection -ConnectionString "$cdsBaseConnectionString$serviceConnection"
    $solutions = Get-CrmRecords -conn $conn -EntityLogicalName solution -FilterAttribute "uniquename" -FilterOperator "eq" -FilterValue "$solutionName" -Fields solutionid
    if($solutions.Count -gt 0) {
        Write-Host "Found $solutions solution..."
        $solutionId = $solutions.CrmRecords[0].solutionid
        $solutionComponentResults =  Get-CrmRecords -conn $conn -EntityLogicalName solutioncomponent -FilterAttribute "solutionid" -FilterOperator "eq" -FilterValue $solutionId -Fields componenttype, solutioncomponentid, objectid
        $connectionReferences = [System.Collections.ArrayList]@()
        $environmentVariables = [System.Collections.ArrayList]@()
        $canvasApps = [System.Collections.ArrayList]@()
        $customConnectorSharings = [System.Collections.ArrayList]@()
        $flowOwnerships = [System.Collections.ArrayList]@()
        $flowActivationUsers = [System.Collections.ArrayList]@()
        $flowSharings = [System.Collections.ArrayList]@()
        $groupTeams = [System.Collections.ArrayList]@()
        $cofigurationVariables = [System.Collections.ArrayList]@()

        #Convert the updated configuration to json and store in customDeploymentSettings.json
        $json = ConvertTo-Json -Depth 10 $newCustomConfiguration
        Set-Content -Path $customDeploymentSettingsFilePath -Value $json

        $secretEnvironmentVariables = [System.Collections.ArrayList]@()

        $solutionComponentDefinitionsResults =  Get-CrmRecords -conn $conn -EntityLogicalName solutioncomponentdefinition -FilterAttribute "primaryentityname" -FilterOperator "eq" -FilterValue "connectionreference" -Fields objecttypecode
        #There are extra characters being introduced in specific locales. The regex replace on the objecttypecode below is to remove it.
        $connectionReferenceTypeCode = [int] ($solutionComponentDefinitionsResults.CrmRecords[0].objecttypecode -replace '\D','')
    
        Write-Host "Creating deployment configuration for solution components..."
        foreach($solutioncomponent in $solutionComponentResults.CrmRecords)
        {
            #Connection Reference
            #There are extra characters being introduced in specific locales for the componenttype. The regex replace on the componenttype below is to remove it.
            $solutioncomponentType = [int] ($solutioncomponent.componenttype_Property.Value.Value -replace '\D','')
            if(($solutioncomponentType -eq $connectionReferenceTypeCode) -and ("$generateConnectionReferences" -ne "false")) {
                # "ConnectionReferences": [
                # {
                #    "LogicalName": "cat_CDS_Current",
                #    "ConnectionId": "#{stage.cr.cat_CDS_Current}#",
                #    "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
                # }
                #]
                $connRefResult = Get-CrmRecord -conn $conn -EntityLogicalName connectionreference -Id $solutionComponent.objectid -Fields connectionreferencelogicalname, connectorid
                $connRef = $null
                $connRefName = $connRefResult.connectionreferencelogicalname
                $connectorId = $connRefResult.connectorid
                $connnectionConfigVariable = "#{connectionreference." + $connRefName + "}#"
                $connnectionOwnerConfigVariable = "#{connectionreference.user." + $connRefName + "}#"
                $connRef = [PSCustomObject]@{"LogicalName"="$connRefName"; "ConnectionId"="$connnectionConfigVariable"; "ConnectorId"= "$connectorId"; "ConnectionOwner"="$connnectionOwnerConfigVariable" }
                $cofigurationVariables.Add($connnectionConfigVariable)
                $cofigurationVariables.Add($connnectionOwnerConfigVariable)
                $connectionReferences.Add($connRef)
            }
            #Custom Connector Variable Definition
            elseif($solutioncomponent.componenttype_Property.Value.Value -eq 372 -and "$generateCustomConnectorConfig" -ne "false") {
                  #"ConnectorShareWithGroupTeamConfiguration": [
                  #{
                  #  "connectorId": "b464e249-0bf7-48c0-8350-24476349bac1",
                  #  "aadGroupTeamName": "#{connectorshare.b464e249-0bf7-48c0-8350-24476349bac1}#"
                  #}
                #]
                $connectorResult =  Get-CrmRecord -conn $conn -EntityLogicalName connector -Id $solutionComponent.objectid -Fields displayname
                $connectorSharingConfig = $null
                $placeholdername = $connectorResult.displayname.replace(' ','') + '.' + $solutionComponent.objectid
                #Create the flow sharing deployment settings
                $sharingConfigVariable = "#{connector.teamname." + $placeholdername + "}#"
                $connectorSharingConfig = [PSCustomObject]@{"solutionComponentName"=$connectorResult.name; "solutionComponentUniqueName"=$solutionComponent.objectid; "aadGroupTeamName"="$sharingConfigVariable"}
                $cofigurationVariables.Add($sharingConfigVariable)
                $customConnectorSharings.Add($connectorSharingConfig)
            }

            #Environment Variable Definition
            elseif($solutioncomponent.componenttype_Property.Value.Value -eq 380 -and "$generateEnvironmentVariables" -ne "false") {
                  #"EnvironmentVariables": [
                  #{
                  #  "SchemaName": "cat_ConnectorBaseUrl",
                  #  "Value": "#{environmentvariable.cat_ConnectorBaseUrl}#"
                  #},
                  #{
                  #  "SchemaName": "cat_ConnectorHostUrl",
                  #  "Value": "#{environmentvariable.cat_ConnectorHostUrl}#"
                  #}
                #]
                $envVarResult =  Get-CrmRecord -conn $conn -EntityLogicalName environmentvariabledefinition -Id $solutionComponent.objectid -Fields schemaname, type
                $envVar = $null
                $envVarName = $envVarResult.schemaname
                $envVarConfigVariable = "#{environmentvariable." + $envVarName + "}#"
                $envVar = [PSCustomObject]@{"SchemaName"="$envVarName"; "Value"="$envVarConfigVariable"}
                if($envVarResult.type_Property.Value.Value -eq 100000005) {
                    $secretEnvironmentVariables.Add($envVarName)
                }
                $cofigurationVariables.Add($envVarConfigVariable)
                $environmentVariables.Add($envVar)
            }
            #Canvas App
            elseif($solutioncomponent.componenttype_Property.Value.Value -eq 300 -and "$generateCanvasSharingConfig" -ne "false") {
                #"AadGroupCanvasConfiguration": [
                # {
                #    "aadGroupId": "#{canvasshare.aadGroupId}#",
                #    "canvasNameInSolution": "cat_devopskitsamplecanvasapp_c7ec5",
                #    "canvasDisplayName": "cat_devopskitsamplecanvasapp_c7ec5",
                #    "roleName": "#{canvasshare.roleName}#"
                # }
                #]
                $canvasAppResult =  Get-CrmRecord -conn $conn -EntityLogicalName canvasapp -Id $solutionComponent.objectid -Fields solutionid, name, displayname
                $canvasConfig = $null
                $canvasName = $canvasAppResult.name
                $aadGroupConfigVariable = "#{canvasshare.aadGroupId." + $canvasName + "}#"
                $groupRoleConfigVariable = "#{canvasshare.roleName." + $canvasName + "}#"
                $canvasConfig = [PSCustomObject]@{"aadGroupId"="$aadGroupConfigVariable"; "canvasNameInSolution"=$canvasName; "canvasDisplayName"= $canvasAppResult.displayname; "roleName"="$groupRoleConfigVariable"}
                $cofigurationVariables.Add($aadGroupConfigVariable)
                $cofigurationVariables.Add($groupRoleConfigVariable)
                $canvasApps.Add($canvasConfig)
            }
            #Workflow
            elseif($solutioncomponent.componenttype_Property.Value.Value -eq 29 -and "$generateFlowConfig" -ne "false") {
                #"SolutionComponentOwnershipConfiguration": [
                #{
                #  "solutionComponentType": 29,
                #  "solutionComponentUniqueName": "71cc728c-2487-eb11-a812-000d3a8fe6a3",
                #  "solutionComponentName": My Flow,
                #  "ownerEmail": "#{owner.ownerEmail}#"
                #},
                #{
                #  "solutionComponentType": 29,
                #  "solutionComponentUniqueName": "d2f7f0e2-a1a9-eb11-b1ac-000d3a53c3c2",
                #  "solutionComponentName": My Other Flow,
                #  "ownerEmail": "#{owner.ownerEmail}#"
                #}
                #]
                $flowResult =  Get-CrmRecord -conn $conn -EntityLogicalName workflow -Id $solutionComponent.objectid -Fields solutionid, name
                $flowConfig = $null
                $flowActivationUserConfig = $null
                $flowSharingConfig = $null
                $workflowName = $solutionComponent.objectid
                $placeholdername = $flowResult.name.replace(' ','') + '.' + $solutionComponent.objectid
                $ownerConfigVariable = "#{owner.ownerEmail." + $placeholdername + "}#"
                #Create the flow owner deployment settings
                $flowConfig = [PSCustomObject]@{"solutionComponentType"=$solutioncomponent.componenttype_Property.Value.Value; "solutionComponentName"=$flowResult.name; "solutionComponentUniqueName"=$workflowName; "ownerEmail"="$ownerConfigVariable"}
                $cofigurationVariables.Add($ownerConfigVariable)
                $flowOwnerships.Add($flowConfig)

                #Create the flow sharing deployment settings
                $sharingConfigVariable = "#{flow.sharing." + $placeholdername + "}#"
                $flowSharingConfig = [PSCustomObject]@{"solutionComponentName"=$flowResult.name; "solutionComponentUniqueName"=$workflowName; "aadGroupTeamName"="$sharingConfigVariable"}
                $cofigurationVariables.Add($sharingConfigVariable)
                $flowSharings.Add($flowSharingConfig)

                #Create the flow activation user deployment settings
                $sortOrderConfigVariable = "#{activateflow.order." + $placeholdername + "}#"
                $activateConfigVariable = "#{activateflow.activate." + $placeholdername + "}#"
                $activateUserConfigVariable = "#{activateflow.activateas." + $placeholdername + "}#"
                $flowActivationUserConfig = [PSCustomObject]@{"solutionComponentName"=$flowResult.name; "solutionComponentUniqueName"=$workflowName; "activateAsUser"="$activateUserConfigVariable"; "sortOrder"="$sortOrderConfigVariable"; "activate"="$activateConfigVariable"}
                $cofigurationVariables.Add($sortOrderConfigVariable)
                $cofigurationVariables.Add($activateConfigVariable)
                $cofigurationVariables.Add($activateUserConfigVariable)
                $flowActivationUsers.Add($flowActivationUserConfig)
            }
        }

        $newConfiguration = [PSCustomObject]@{}
        $newConfiguration | Add-Member -MemberType NoteProperty -Name 'EnvironmentVariables' -Value $environmentVariables
        $newConfiguration | Add-Member -MemberType NoteProperty -Name 'ConnectionReferences' -Value $connectionReferences

        $json = ConvertTo-Json -Depth 10 $newConfiguration
        Set-Content -Path $deploymentSettingsFilePath -Value $json

        $newCustomConfiguration = [PSCustomObject]@{}
        $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'ActivateFlowConfiguration' -Value $flowActivationUsers
        $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'ConnectorShareWithGroupTeamConfiguration' -Value $customConnectorSharings
        $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'SolutionComponentOwnershipConfiguration' -Value $flowOwnerships
        $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'FlowShareWithGroupTeamConfiguration' -Value $flowSharings
        $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'AadGroupCanvasConfiguration' -Value $canvasApps
        $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'AadGroupTeamConfiguration' -Value $groupTeams
        #Convert the updated configuration to json and store in customDeploymentSettings.json
        $json = ConvertTo-Json -Depth 10 $newCustomConfiguration
        Set-Content -Path $customDeploymentSettingsFilePath -Value $json

        #Update / Create Deployment Pipelines
        New-DeploymentPipelines "$buildRepositoryName" "$orgUrl" "$projectName" "$repo" "$azdoAuthType" "$solutionName" $configurationData

        $buildDefinitionResourceUrl = "$orgUrl$projectId/_apis/build/definitions?name=deploy-*-$solutionName&includeAllProperties=true&api-version=6.0"

        $fullBuildDefinitionResponse = Invoke-RestMethod $buildDefinitionResourceUrl -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
        $buildDefinitionResponseResults = $fullBuildDefinitionResponse.value

        #Loop through the build definitions we found and update the pipeline variables based on the placeholders we put in the deployment settings files.
        foreach($buildDefinitionResult in $buildDefinitionResponseResults)
        {
            #Getting the build definition id and variables to be updated
            $definitionId = $buildDefinitionResult.id
            $newBuildDefinitionVariables = $buildDefinitionResult.variables
            #Loop through each of the tokens stored above and find an associated variable in the configuration data passed in from AA4AM

            foreach($configurationVariable in $cofigurationVariables) {
                $found = $false
                $configurationVariable = $configurationVariable.replace('#{', '')
                $configurationVariable = $configurationVariable.replace('}#', '')

                #See if the variable already exists
                foreach($buildVariable in $newBuildDefinitionVariables.PSObject.Properties) {
                    if($buildVariable.Name -eq $configurationVariable) {
                        $found = $true
                        break
                    }
                }
                #If the variable was not found create it 
                if(!$found) {
                    $newBuildDefinitionVariables | Add-Member -MemberType NoteProperty -Name $configurationVariable -Value @{value = ''}
                }

                if($configurationData.length -gt 0) {
                    if($null -ne $configurationData) {
                        $configurationDataEnvironment = $configurationData | Where-Object { $_.BuildName -eq $buildDefinitionResult.name } | Select-Object -First 1
                        if($null -ne $configurationDataEnvironment -and $null -ne $configurationDataEnvironment.UserSettings) {
                            $variable = $configurationDataEnvironment.UserSettings | Where-Object { $_.Name -eq $configurationVariable } | Select-Object -First 1
                            # Set the value to the value passed in on the configuration data
                            if($null -eq $variable -or $null -eq $variable.Value -or [string]::IsNullOrWhiteSpace($variable.Value)) {
                                $newBuildDefinitionVariables.$configurationVariable.value = ''
                            }
                            else {
                                $newBuildDefinitionVariables.$configurationVariable.value = $variable.Value
                            }
                        }
                    }
                }
            }

            Set-BuildDefinitionVariables $orgUrl $projectId $azdoAuthType $buildDefinitionResult $definitionId $newBuildDefinitionVariables
        }
        Set-EnvironmentDeploymentSettingsConfiguration $buildSourceDirectory $repo $solutionName $newConfiguration $newCustomConfiguration $configurationData $secretEnvironmentVariables
    }
}

function New-DeploymentPipelines
{
    param (
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$projectName,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$azdoAuthType,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [System.Object[]]$configurationData
    )

    if($null -ne $configurationData -and $configurationData.length -gt 0) {
        Write-Host "Retrieved " $configurationData.length " deployment environments"
        #Update / Create Deployment Pipelines
        $buildDefinitionResourceUrl = "$orgUrl$projectId/_apis/build/definitions?name=deploy-*-$solutionName&includeAllProperties=true&api-version=6.0"
        Write-Host $buildDefinitionResourceUrl
        $fullBuildDefinitionResponse = Invoke-RestMethod $buildDefinitionResourceUrl -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
        $buildDefinitionResponseResults = $fullBuildDefinitionResponse.value
        Write-Host "Retrieved " $buildDefinitionResponseResults.length " builds" $env:SYSTEM_ACCESSTOKEN

        if($buildDefinitionResponseResults.length -lt $configurationData.length) {
            $currentPath = Get-Location
            if(Test-Path -Path "../coe-starter-kit-source") {
                Remove-Item "../coe-starter-kit-source" -Force -Recurse
            }
            New-Item -ItemType "directory" -Name "../coe-starter-kit-source"
            Set-Location ../coe-starter-kit-source
            git clone -b "main" "https://github.com/microsoft/coe-starter-kit.git"
            Set-Location coe-starter-kit\coe-cli
            npm install
            npm run build
            npm link
            $settings= ""
            foreach($deploymentEnvironment in $configurationData) {
                if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                    $settings = $settings + ","
                }

                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentUrl) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentName)) {
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "=" + $deploymentEnvironment.DeploymentEnvironmentUrl
                }


                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.ServiceConnectionName) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentName)) {
                    if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                        $settings = $settings + ","
                    }
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "-scname=" + $deploymentEnvironment.ServiceConnectionName
                }


                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.TenantId) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentName)) {
                    if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                        $settings = $settings + ","
                    }

                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "-tenantid=" + $deploymentEnvironment.TenantId
                }


                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.ClientId) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentName)) {
                    if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                        $settings = $settings + ","
                }
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "-clientid=" + $deploymentEnvironment.ClientId
                }

                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.ClientSecret) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentName)) {
                    if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                        $settings = $settings + ","
                    }
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "-clientsecret=" + $deploymentEnvironment.ClientSecret
                }

                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.VariableGroup) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentName)) {
                    if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                        $settings = $settings + ","
                }
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "-variablegroup=" + $deploymentEnvironment.VariableGroup
                }


            }
            if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                Write-Host "Environments: " $settings
                coe alm branch --pipelineRepository $buildRepositoryName -o $orgUrl -p "$projectName" -r "$repo" -d "$solutionName" -a  $env:SYSTEM_ACCESSTOKEN -s $settings
            }

            Set-Location $currentPath
        }
    }
}

function Set-BuildDefinitionVariables {
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$projectId,
        [Parameter(Mandatory)] [String]$azdoAuthType,
        [Parameter(Mandatory)] [PSCustomObject]$buildDefinitionResult,
        [Parameter(Mandatory)] [String]$definitionId,
        [Parameter(Mandatory)] [PSCustomObject]$newBuildDefinitionVariables
    )
    #Set the build definition variables to the newly created list
    ([pscustomobject]$buildDefinitionResult.variables) = ([pscustomobject]$newBuildDefinitionVariables)
    $buildDefinitionResourceUrl = "$orgUrl$projectId/_apis/build/definitions/" + $definitionId + "?api-version=6.0"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN")
    $headers.Add("Content-Type", "application/json")
    $body = ConvertTo-Json -Depth 10 $buildDefinitionResult
    #remove tab charcters from the body
    $body = $body -replace "`t", ""
    Invoke-RestMethod $buildDefinitionResourceUrl -Method 'PUT' -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) | Out-Null   
}

function Set-EnvironmentDeploymentSettingsConfiguration {
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter()] [PSCustomObject]$newConfiguration,
        [Parameter()] [PSCustomObject]$newCustomConfiguration,
        [Parameter()] [PSCustomObject]$configurationData,
        [Parameter()] [PSCustomObject]$secretEnvironmentVariables
    )
    foreach($newEnvironmentConfig in $configurationData) {
        $groupTeams = [System.Collections.ArrayList]@()
        $secretsRemoved = [System.Collections.ArrayList]@()
        $environmentName = $newEnvironmentConfig.DeploymentEnvironmentName
        if(-Not [string]::IsNullOrWhiteSpace($environmentName)) {
            if(Test-Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName\") {
                Remove-Item -Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName\*eploymentSettings.json" -Force
            }
        }
        foreach($variableConfiguration in $newEnvironmentConfig.UserSettings) {
            $variableName = $variableConfiguration.Name
            if($variableName.Contains("groupTeam.")) {
                $teamGroupConfigVariable = "#{$variableName}#"

                $teamName = $variableConfiguration.Name.split('.')[-1]
                $teamGroupRoles = $variableConfiguration.Data.split(',')

                $groupTeamConfig = [PSCustomObject]@{"aadGroupTeamName"=$teamName; "aadSecurityGroupId"="$teamGroupConfigVariable"; "dataverseSecurityRoleNames"=@($teamGroupRoles)}
                $cofigurationVariables.Add($teamGroupConfigVariable)
                $groupTeams.Add($groupTeamConfig)
            }
        }

        $secretsRemoved = $false
        foreach($secretVariable in $secretEnvironmentVariables) {
            $variable = $newEnvironmentConfig.UserSettings | Where-Object { $_.Name.Contains($secretVariable) } | Select-Object -First 1
            if($null -eq $variable -or $null -eq $variable.Value -or $variable.Value -eq "") {

                $configVariable = $newConfiguration.EnvironmentVariables | Where-Object { $_.SchemaName -eq $secretVariable } | Select-Object -First 1
                $newConfiguration.EnvironmentVariables.Remove($configVariable)
                $secretsRemoved = $true
            }
        }


        if(-Not [string]::IsNullOrWhiteSpace($environmentName)) {
            ([pscustomobject]$newCustomConfiguration.AadGroupTeamConfiguration) = $groupTeams
            if($groupTeams.Count -gt 0) {
                if(!(Test-Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName")) {
                    New-Item "$buildSourceDirectory\$repo\$solutionName\config" -Name "$environmentName" -ItemType "directory"
                }

                #Convert the updated configuration to json and store in customDeploymentSettings.json
                $json = ConvertTo-Json -Depth 10 ([pscustomobject]$newCustomConfiguration)
                Set-Content -Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName\customDeploymentSettings.json" -Value $json
            }
            Write-Host "Checking for secrets removed"
            if($secretsRemoved) {
                Write-Host "Secrets removed creating deploymentConfiguration for $environmentName"
                if(!(Test-Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName")) {
                    New-Item "$buildSourceDirectory\$repo\$solutionName\config" -Name "$environmentName" -ItemType "directory"
                }

                #Convert the updated configuration to json and store in customDeploymentSettings.json
                $json = ConvertTo-Json -Depth 10 $newConfiguration
                Set-Content -Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName\deploymentSettings.json" -Value $json

            }
        }
    }
}