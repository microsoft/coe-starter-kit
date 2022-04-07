function Set-DeploymentSettingsConfiguration($buildSourceDirectory, $buildRepositoryName, $cdsBaseConnectionString, $xrmDataPowerShellVersion, $microsoftXrmDataPowerShellModule, $orgUrl, $projectId, $projectName, $repo, $azdoAuthType, $serviceConnection, $solutionName, $profileEnvironmentUrl, $profileId, $configurationDataJson, $generateEnvironmentVariables, $generateConnectionReferences, $generateFlowConfig, $generateCanvasSharingConfig, $generateAADGroupTeamConfig, $generateCustomConnectorConfig)
{
    Write-Host (ConvertTo-Json -Depth 10 $configurationDataJson)
    #Generate Deployment Settings
    Write-Host "Update Deployment Settings"
    Remove-CurrentDeploymentSettingsConfiguration $buildSourceDirectory $repo $solutionName
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

        Write-Host "Retrieving maker deployment configuration data..."
        $deploymentConfigurationData = [System.Collections.ArrayList]@()
        #If configuration data was passed in use this to set the pipeline variable values
        $newConfigurationData = [System.Collections.ArrayList]@()

        $settingsConn = Get-CrmConnection -ConnectionString "$cdsBaseConnectionString$profileEnvironmentUrl"
        #The configuration data will point to the records in Dataverse that store the JSON to set pipeline variables. Try/Catch for invalid json
        $configurationData = ConvertFrom-Json $configurationDataJson

        if($configurationData.length -gt 0) {
            $userSettings = $configurationData.UserSettingId
            #Add the cat_usersetting records to an array
            foreach($configCriteria in $userSettings) {
                $userSetting = Get-CrmRecord -conn $settingsConn -EntityLogicalName cat_usersetting -Id $configCriteria.cat_usersettingid -Fields cat_data
                $newConfigurationData.Add($userSetting)
            }

            if($null -ne $newConfigurationData) {
                foreach($newEnvironmentConfig in $newConfigurationData) {
                    foreach($variableConfigurationJson in $newEnvironmentConfig.cat_data) {
                        #Convert the JSON in the cat_data field to an object
                        $variableConfiguration = ConvertFrom-Json $variableConfigurationJson
                        $deploymentConfigurationData.AddRange($variableConfiguration)
                    }
                }
            }
        }

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
                $envVarResult =  Get-CrmRecord -conn $conn -EntityLogicalName environmentvariabledefinition -Id $solutionComponent.objectid -Fields schemaname
                $envVar = $null
                $envVarName = $envVarResult.schemaname

                $envVarConfigVariable = "#{environmentvariable." + $envVarName + "}#"
                $envVar = [PSCustomObject]@{"SchemaName"="$envVarName"; "Value"="$envVarConfigVariable" }
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

        if("$generateAADGroupTeamConfig" -ne "false") {
            Set-EnvironmentDeploymentSettingsConfiguration $buildSourceDirectory $repo $solutionName $newCustomConfiguration $newConfigurationData
        }
        #Update / Create Deployment Pipelines
        New-DeploymentPipelines "$buildRepositoryName" "$orgUrl" "$projectName" "$repo" "$azdoAuthType" $settingsConn "$solutionName" "$profileId"

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

                $variable = $deploymentConfigurationData | Where-Object { $_.Build -eq $buildDefinitionResult.name -and $_.Name -eq $configurationVariable } | Select-Object -First 1
                # Set the value to the value passed in on the configuration data
                if($null -eq $variable -or $null -eq $variable.Value -or [string]::IsNullOrWhiteSpace($variable.Value)) {
                    $newBuildDefinitionVariables.$configurationVariable.value = ''
                }
                else {
                    $newBuildDefinitionVariables.$configurationVariable.value = $variable.Value
                }
            }

            Set-BuildDefinitionVariables $orgUrl $projectId $azdoAuthType $buildDefinitionResult $definitionId $newBuildDefinitionVariables
        }
    }
}

function New-DeploymentPipelines($buildRepositoryName, $orgUrl, $projectName, $repo, $azdoAuthType, $settingsConn, $solutionName, $profileId)
{
    if($null -ne $profileId) {
        $deploymentSteps = Get-CrmRecords -conn $settingsConn -EntityLogicalName cat_deploymentstep -FilterAttribute "cat_deploymentprofileid" -FilterOperator "eq" -FilterValue $profileId -Fields cat_deploymentenvironmentid,cat_name
        Write-Host "Retrieved " $deploymentSteps.Count " deployment steps for " $profileId
        #Update / Create Deployment Pipelines
        $buildDefinitionResourceUrl = "$orgUrl$projectId/_apis/build/definitions?name=deploy-*-$solutionName&includeAllProperties=true&api-version=6.0"
        Write-Host $buildDefinitionResourceUrl
        $fullBuildDefinitionResponse = Invoke-RestMethod $buildDefinitionResourceUrl -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
        $buildDefinitionResponseResults = $fullBuildDefinitionResponse.value
        Write-Host "Retrieved " $buildDefinitionResponseResults.length " builds" $env:SYSTEM_ACCESSTOKEN

        if($buildDefinitionResponseResults.length -lt $deploymentSteps.Count) {
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
            $environments = ""
            foreach($deploymentStep in $deploymentSteps.CrmRecords) {
                if(-Not [string]::IsNullOrWhiteSpace($environments)) {
                    $environments = $environments + ","
                }
                $environment = Get-CrmRecord -conn $settingsConn -EntityLogicalName cat_deploymentenvironment -Id $deploymentStep.cat_deploymentenvironmentid_Property.Value.Id -Fields cat_url

                if(-Not [string]::IsNullOrWhiteSpace($environment.cat_url) -and -Not [string]::IsNullOrWhiteSpace($deploymentStep.cat_name)) {
                    $environments = $environments + $deploymentStep.cat_name.ToLower() + "=" + $environment.cat_url
                }
            }
            if(-Not [string]::IsNullOrWhiteSpace($environments)) {
                coe alm branch --pipelineRepository $buildRepositoryName -o $orgUrl -p "$projectName" -r "$repo" -d "$solutionName" -a  $env:SYSTEM_ACCESSTOKEN -s $environments
            }

            Set-Location $currentPath
        }
    }
}

function Remove-CurrentDeploymentSettingsConfiguration($buildSourceDirectory, $repo, $solutionName)
{
    if(Test-Path "$buildSourceDirectory\$repo\$solutionName\config\") {
        Remove-Item -Path "$buildSourceDirectory\$repo\$solutionName\config\**\customDeploymentSettings.json" -Recurse -Force
        Remove-Item -Path "$buildSourceDirectory\$repo\$solutionName\config\**\deploymentSettings.json" -Recurse -Force
    }
}

function Set-BuildDefinitionVariables($orgUrl, $projectId, $azdoAuthType, $buildDefinitionResult, $definitionId, $newBuildDefinitionVariables) {
    #Set the build definition variables to the newly created list
    $buildDefinitionResult.variables = $newBuildDefinitionVariables
    $buildDefinitionResourceUrl = "$orgUrl$projectId/_apis/build/definitions/" + $definitionId + "?api-version=6.0"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN")
    $headers.Add("Content-Type", "application/json")
    $body = ConvertTo-Json -Depth 10 $buildDefinitionResult
    #remove tab charcters from the body
    $body = $body -replace "`t", ""
    Invoke-RestMethod $buildDefinitionResourceUrl -Method 'PUT' -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) | Out-Null   
}
function Set-EnvironmentDeploymentSettingsConfiguration($buildSourceDirectory, $repo, $solutionName, $newCustomConfiguration, $newConfigurationData) {
    Write-Host "Creating deployment configuration for group teams..."
    #"AadGroupTeamConfiguration": [
    #{
    #    "aadGroupTeamName": "alm-accelerator-sample-solution",
    #    "aadSecurityGroupId": "#{team.aadSecurityGroupId}#",
    #    "dataverseSecurityRoleNames": [
    #    "ALM Accelerator Sample Role"
    #    ]
    #}
    #]
    foreach($newEnvironmentConfig in $newConfigurationData) {
        $groupTeams = [System.Collections.ArrayList]@()
        $environmentName = ""
        foreach($variableConfigurationJson in $newEnvironmentConfig.cat_data) {
            #Convert the JSON in the cat_data field to an object
            $variableConfiguration = ConvertFrom-Json $variableConfigurationJson
            foreach($variable in $variableConfiguration) {
                $variableName = $variable.Name
                if($variableName.Contains("groupTeam.")) {
                    $environmentName = $variable.Environment
                    $teamGroupConfigVariable = "#{$variableName}#"
    
                    $teamName = $variable.Name.split('.')[-1]
                    $teamGroupRoles = $variable.Data.split(',')
    
                    $groupTeamConfig = [PSCustomObject]@{"aadGroupTeamName"=$teamName; "aadSecurityGroupId"="$teamGroupConfigVariable"; "dataverseSecurityRoleNames"=@($teamGroupRoles)}
                    $cofigurationVariables.Add($teamGroupConfigVariable)
                    $groupTeams.Add($groupTeamConfig)
                }
            }
        }
        $newCustomConfiguration.AadGroupTeamConfiguration = $groupTeams
        if($groupTeams.Count -gt 0 -and -Not [string]::IsNullOrWhiteSpace($environmentName)) {
            if(!(Test-Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName")) {
                New-Item "$buildSourceDirectory\$repo\$solutionName\config" -Name "$environmentName" -ItemType "directory"
            }
        

            #Convert the updated configuration to json and store in customDeploymentSettings.json
            $json = ConvertTo-Json -Depth 10 $newCustomConfiguration
            Set-Content -Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName\customDeploymentSettings.json" -Value $json
        }
    }
}