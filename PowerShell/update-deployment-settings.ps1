function Set-DeploymentSettingsConfiguration
{
    param (
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$pipelineSourceDirectory,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [String]$dataverseConnectionString,
        [Parameter(Mandatory)] [String]$xrmDataPowerShellVersion,
        [Parameter(Mandatory)] [String]$microsoftXrmDataPowerShellModule,
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$projectName,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$azdoAuthType,
        [Parameter(Mandatory)] [String]$serviceConnection,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter()] [String]$agentOS = "",
        [Parameter()] [String]$usePlaceholders = "true",
        [Parameter()] [String]$pat = "" # Azure DevOps Personal Access Token only required for running local tests
    )
    $configurationData = $env:DEPLOYMENT_SETTINGS | ConvertFrom-Json
    $reservedVariables = @("TriggerSolutionUpgrade")
    Write-Host (ConvertTo-Json -Depth 10 $configurationData)


    #Generate Deployment Settings
    Write-Host "Update Deployment Settings"
    if(!(Test-Path "$buildSourceDirectory\$repo\$solutionName\config\")) {
        New-Item "$buildSourceDirectory\$repo\$solutionName\" -Name "config" -ItemType "directory"
    } else {
        #Remove legacy deployment settings
        Remove-Item "$buildSourceDirectory\$repo\$solutionName\config\*eploymentSettings.json" -Force
    }

    #Update / Create Deployment Pipelines
    New-DeploymentPipelines "$pipelineSourceDirectory" "$buildProjectName" "$buildRepositoryName" "$orgUrl" "$projectName" "$repo" "$azdoAuthType" "$pat" "$solutionName" $configurationData $agentOS

    Write-Host "Importing PowerShell Module: $microsoftXrmDataPowerShellModule - $xrmDataPowerShellVersion"
    Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $xrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }
    $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

    #Loop through the build definitions we found and update the pipeline variables based on the placeholders we put in the deployment settings files.
    foreach($configurationDataEnvironment in $configurationData)
    {
        $connectionReferences = [System.Collections.ArrayList]@()
        $environmentVariables = [System.Collections.ArrayList]@()
        $canvasApps = [System.Collections.ArrayList]@()
        $customConnectorSharings = [System.Collections.ArrayList]@()
        $flowOwnerships = [System.Collections.ArrayList]@()
        $flowActivationUsers = [System.Collections.ArrayList]@()
        $flowSharings = [System.Collections.ArrayList]@()
        $groupTeams = [System.Collections.ArrayList]@()
        #Getting the build definition id and variables to be updated
        $buildName = $configurationDataEnvironment.BuildName
        $buildDefinitionResourceUrl = "$orgUrl$projectName/_apis/build/definitions?name=$buildName&includeAllProperties=true&api-version=6.0"
        Write-Host $buildDefinitionResourceUrl
        $fullBuildDefinitionResponse = Invoke-RestMethod $buildDefinitionResourceUrl -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
        $buildDefinitionResponseResults = $fullBuildDefinitionResponse.value
        Write-Host "Retrieved " $buildDefinitionResponseResults.length " builds"

        $newBuildDefinitionVariables = $null
        if($buildDefinitionResponseResults.length -gt 0) {
            $newBuildDefinitionVariables = $buildDefinitionResponseResults[0].variables
        }
		
        # Updating "ServiceConnection"; Required if the ''Environment URL' in the profile changes post commit.
        if($null -ne $configurationDataEnvironment -and $null -ne $configurationDataEnvironment.DeploymentEnvironmentUrl) {         
            $DeploymentEnvironmentUrl=$configurationDataEnvironment.DeploymentEnvironmentUrl
            $ServiceConnectionName=$configurationDataEnvironment.ServiceConnectionName
            if($null -ne $newBuildDefinitionVariables){
                Create-Update-ServiceConnection-Parameters $DeploymentEnvironmentUrl $ServiceConnectionName $newBuildDefinitionVariables
            }
        }		

        if($null -ne $configurationDataEnvironment -and $null -ne $configurationDataEnvironment.UserSettings) {
            foreach($configurationVariable in $configurationDataEnvironment.UserSettings) {
                $configurationVariableName = $configurationVariable.Name
                $configurationVariableValue = $configurationVariable.Value
                if (-not ([string]::IsNullOrEmpty($configurationVariableName)))
                {				
                    #Set connection reference variables
                    if($configurationVariableName.StartsWith("connectionreference.user.", "CurrentCultureIgnoreCase")) {
                        $schemaName = $configurationVariableName -replace "connectionreference.user.", ""
                        $connRefResults = Get-CrmRecords -conn $conn -EntityLogicalName connectionreference -FilterAttribute "connectionreferencelogicalname" -FilterOperator "eq" -FilterValue $schemaName -Fields connectorid
                        if ($connRefResults.Count -gt 0){
                            $connectorId = $connRefResults.CrmRecords[0].connectorid
                            $connectionVariable = $configurationDataEnvironment.UserSettings | Where-Object { $_.Name -eq "connectionreference.$schemaName" } | Select-Object -First 1
                            $connectionVariableName = $connectionVariable.Name
                            $connectionVariableValue = $connectionVariable.Value
                            if($null -ne $connectionVariable) {
                                $connRef = [PSCustomObject]@{"LogicalName"="$schemaName"; "ConnectionId"="#{$connectionVariableName}#"; "ConnectorId"= "$connectorId"; "ConnectionOwner"="#{$configurationVariableName}#" }
                                if($usePlaceholders.ToLower() -eq 'false') {
                                    $connRef = [PSCustomObject]@{"LogicalName"="$schemaName"; "ConnectionId"="$connectionVariableValue"; "ConnectorId"= "$connectorId"; "ConnectionOwner"="$configurationVariableValue" }
                                }
                                $connectionReferences.Add($connRef)
                            }
                        }
                    }
                    #Set environment variable variables
                    elseif($configurationVariableName.StartsWith("environmentvariable.", "CurrentCultureIgnoreCase")) {
                        $schemaName = $configurationVariableName -replace "environmentvariable.", ""
                        $envVarResults =  Get-CrmRecords -conn $conn -EntityLogicalName environmentvariabledefinition -FilterAttribute "schemaname" -FilterOperator "eq" -FilterValue $schemaName -Fields type
                        if ($envVarResults.Count -gt 0){
                            $type = $envVarResults.CrmRecords[0].type_Property.Value.Value
                            if($type -ne 100000005 -or -not [string]::IsNullOrEmpty($configurationVariableValue)) {
                                $envVar = [PSCustomObject]@{"SchemaName"="$schemaName"; "Value"="#{$configurationVariableName}#"}
                                if($usePlaceholders.ToLower() -eq 'false') {
                                    $envVar = [PSCustomObject]@{"SchemaName"="$schemaName"; "Value"="$configurationVariableValue"}
                                }
                                $environmentVariables.Add($envVar)
                            }
                        }
                    }
                    elseif($configurationVariableName.StartsWith("canvasshare.aadGroupId.", "CurrentCultureIgnoreCase")) {
                        $schemaName = $configurationVariableName -replace "canvasshare.aadGroupId.", ""
                        $roleVariable = $configurationDataEnvironment.UserSettings | Where-Object { $_.Name -eq "canvasshare.roleName.$schemaName" } | Select-Object -First 1
                        $canvasAppResults =  Get-CrmRecords -conn $conn -EntityLogicalName canvasapp -FilterAttribute "name" -FilterOperator "eq" -FilterValue $schemaName -Fields displayname
                        if($canvasAppResults.Count -gt 0 -and $null -ne $roleVariable) {
                            $canvasAppResult = $canvasAppResults.CrmRecords[0]
                            $roleVariableName = $roleVariable.Name
                            $roleVariableValue = $roleVariable.Value
                            $canvasConfig = [PSCustomObject]@{"aadGroupId"="#{$configurationVariableName}#"; "canvasNameInSolution"=$schemaName; "canvasDisplayName"= $canvasAppResult.displayname; "roleName"="#{$roleVariableName}#"}
                            if($usePlaceholders.ToLower() -eq 'false') {
                                $canvasConfig = [PSCustomObject]@{"aadGroupId"="$configurationVariableValue"; "canvasNameInSolution"=$schemaName; "canvasDisplayName"= $canvasAppResult.displayname; "roleName"="$roleVariableValue"}
                            }
                            $canvasApps.Add($canvasConfig)
                        }
                    }
                    elseif($configurationVariableName.StartsWith("owner.ownerEmail.", "CurrentCultureIgnoreCase")) {
                        #Create the flow ownership deployment settings
                        $flowSplit = $configurationVariableName.Split(".")
                        $solutionComponentName = Get-Flow-Component-Name $configurationVariableName

                        $flowOwnerConfig = [PSCustomObject]@{"solutionComponentType"=29; "solutionComponentName"=$solutionComponentName; "solutionComponentUniqueName"=$flowSplit[$flowSplit.Count-1]; "ownerEmail"="#{$configurationVariableName}#"}
                        if($usePlaceholders.ToLower() -eq 'false') {
                            $flowOwnerConfig = [PSCustomObject]@{"solutionComponentType"=29; "solutionComponentName"=$solutionComponentName; "solutionComponentUniqueName"=$flowSplit[$flowSplit.Count-1]; "ownerEmail"="$configurationVariableValue"}
                        }
                        $flowOwnerships.Add($flowOwnerConfig)
                    }
                    elseif($configurationVariableName.StartsWith("flow.sharing.", "CurrentCultureIgnoreCase")) {
                        $flowSplit = $configurationVariableName.Split(".")
                        $solutionComponentName = Get-Flow-Component-Name $configurationVariableName
                        $flowSharing = [PSCustomObject]@{"solutionComponentName"=$solutionComponentName; "solutionComponentUniqueName"=$flowSplit[$flowSplit.Count-1]; "aadGroupTeamName"="#{$configurationVariableName}#"}
                        if($usePlaceholders.ToLower() -eq 'false') {
                            $flowSharing = [PSCustomObject]@{"solutionComponentName"=$solutionComponentName; "solutionComponentUniqueName"=$flowSplit[$flowSplit.Count-1]; "aadGroupTeamName"="$configurationVariableValue"}
                        }
                        $flowSharings.Add($flowSharing)
                    }
                    elseif($configurationVariableName.StartsWith("activateflow.activate.", "CurrentCultureIgnoreCase")) {
                        Write-Host "Flow configurationVariableName - $configurationVariableName"
                        $flowSplit = $configurationVariableName.Split(".")
                        
                        for($indxVariableParts=0;$indxVariableParts -lt $flowSplit.Count;$indxVariableParts++)
                        {
                            Write-Host "$indxVariableParts - " $flowSplit[$indxVariableParts]
                        }

                        $flowActivateAsName = $configurationVariableName.Replace(".activate.", ".activateas.")
                        $flowActivateOrderName = $configurationVariableName.Replace(".activate.", ".order.")

                        $flowActivateAs = $configurationDataEnvironment.UserSettings | Where-Object { $_.Name -eq $flowActivateAsName } | Select-Object -First 1
                        $flowActivateOrder = $configurationDataEnvironment.UserSettings | Where-Object { $_.Name -eq $flowActivateOrderName } | Select-Object -First 1

                        if($null -ne $flowActivateAs -and $null -ne $flowActivateOrder) {
                            $flowActivateOrderValue = $flowActivateOrder.Value
                            $flowActivateAsValue = $flowActivateAs.Value

                            $solutionComponentName = Get-Flow-Component-Name $configurationVariableName
                            $flowActivateConfig = [PSCustomObject]@{"solutionComponentName"=$solutionComponentName; "solutionComponentUniqueName"=$flowSplit[$flowSplit.Count-1]; "activateAsUser"="#{$flowActivateAsName}#"; "sortOrder"="#{$flowActivateOrderName}#"; "activate"="#{$configurationVariableName}#"}
                            if($usePlaceholders.ToLower() -eq 'false') {
                                $flowActivateConfig = [PSCustomObject]@{"solutionComponentName"=$solutionComponentName; "solutionComponentUniqueName"=$flowSplit[$flowSplit.Count-1]; "activateAsUser"="$flowActivateAsValue"; "sortOrder"="$flowActivateOrderValue"; "activate"="$configurationVariableValue"}
                            }
                            $flowActivationUsers.Add($flowActivateConfig)
                        }
                    }
                    elseif($configurationVariableName.StartsWith("connector.teamname.", "CurrentCultureIgnoreCase")) {
                        $connectorSplit = $configurationVariableName.Split(".")
                        if($connectorSplit.length -eq 4){
                            $connectorSharingConfig = [PSCustomObject]@{"solutionComponentName"=$connectorSplit[2]; "solutionComponentUniqueName"=$connectorSplit[3]; "aadGroupTeamName"="#{$configurationVariableName}#"}
                            if($usePlaceholders.ToLower() -eq 'false') {
                                $connectorSharingConfig = [PSCustomObject]@{"solutionComponentName"=$connectorSplit[2]; "solutionComponentUniqueName"=$connectorSplit[3]; "aadGroupTeamName"="$configurationVariableValue"}
                            }
                            $customConnectorSharings.Add($connectorSharingConfig)
                        }
                    }
                    elseif($configurationVariableName.StartsWith("groupTeam.", "CurrentCultureIgnoreCase")) {
                        #$teamName = $configurationVariableName.split('.')[-1]
                        $teamName = Get-Group-Team-Name $configurationVariableName
                        $teamGroupRoles = $configurationVariable.Data.split(',')
                        $businessUnitVariableName = $configurationVariableName.Replace("groupTeam", "businessUnit")
                        $teamBusinessUnit = $configurationDataEnvironment.UserSettings | Where-Object { $_.Name -eq $businessUnitVariableName } | Select-Object -First 1
                        $teamBusinessUnitValue = ""
                        if($null -ne $teamBusinessUnit) {
                            $teamBusinessUnitValue = $teamBusinessUnit.Value
                        }
                        $groupTeamConfig = [PSCustomObject]@{"aadGroupTeamName"=$teamName; "aadGroupTeamBusinessUnitId"="#{$businessUnitVariableName}#"; "aadSecurityGroupId"="#{$configurationVariableName}#"; "dataverseSecurityRoleNames"=@($teamGroupRoles)}
                        if($usePlaceholders.ToLower() -eq 'false') {
                            $groupTeamConfig = [PSCustomObject]@{"aadGroupTeamName"=$teamName; "aadGroupTeamBusinessUnitId"="$teamBusinessUnitValue"; "aadSecurityGroupId"="$configurationVariableValue"; "dataverseSecurityRoleNames"=@($teamGroupRoles)}
                        }
                        $groupTeams.Add($groupTeamConfig)
                    }
				}

                #See if the variable already exists
                if($null -ne $newBuildDefinitionVariables) {
                    $found = Check-Parameter $configurationVariableName $newBuildDefinitionVariables                
                    #Add the configuration variable to the list of pipeline variables if usePlaceholders is not false
                    if($usePlaceholders.ToLower() -ne 'false') {
                        #If the variable was not found create it 
                        if(!$found) { 
                            $newBuildDefinitionVariables | Add-Member -MemberType NoteProperty -Name $configurationVariableName -Value @{value = ''}
                        }

                        # Set the value to the value passed in on the configuration data
                        if($null -eq $configurationVariableValue -or [string]::IsNullOrWhiteSpace($configurationVariableValue)) {
                            $newBuildDefinitionVariables.$configurationVariableName.value = ''
                        } else {
                            $newBuildDefinitionVariables.$configurationVariableName.value = $configurationVariableValue
                        }
                    }
                    elseif($reservedVariables -contains $configurationVariableName) {
                        #If the variable is in the reserved variables list then set the value to the value passed in on the configuration data
                        if(!$found) { 
                            $newBuildDefinitionVariables | Add-Member -MemberType NoteProperty -Name $configurationVariableName -Value @{value = ''}
                        }
                        $newBuildDefinitionVariables.$configurationVariableName.value = $configurationVariableValue
                    }
                }
            }

            $environmentName = $configurationDataEnvironment.DeploymentEnvironmentName
            if(Test-Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName\") {
                Write-Host "Deleting $buildSourceDirectory\$repo\$solutionName\config\$environmentName\*eploymentSettings.json"
                Remove-Item -Path "$buildSourceDirectory\$repo\$solutionName\config\$environmentName\*eploymentSettings.json" -Force
            }
            else {
                Write-Host "Creating $buildSourceDirectory\$repo\$solutionName\config" -Name "$environmentName" -ItemType "directory"
                New-Item "$buildSourceDirectory\$repo\$solutionName\config" -Name "$environmentName" -ItemType "directory"
            }

            #Create the deployment configuration
            $deploymentSettingsFilePath = "$buildSourceDirectory\$repo\$solutionName\config\$environmentName\deploymentSettings.json"
            $newConfiguration = [PSCustomObject]@{}
            $newConfiguration | Add-Member -MemberType NoteProperty -Name 'EnvironmentVariables' -Value $environmentVariables
            $newConfiguration | Add-Member -MemberType NoteProperty -Name 'ConnectionReferences' -Value $connectionReferences

            Write-Host "Creating deployment settings"
            $json = ConvertTo-Json -Depth 10 $newConfiguration
            if ($PSVersionTable.PSVersion.Major -gt 5) {
                Set-Content -Path $deploymentSettingsFilePath -Value $json
            }
            else {
                $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
                $jsonBytes = $utf8NoBomEncoding.GetBytes($json)
                Set-Content -Path $deploymentSettingsFilePath -Value $jsonBytes -Encoding Byte
            }

            #Create the custom deployment configuration
            $customDeploymentSettingsFilePath = "$buildSourceDirectory\$repo\$solutionName\config\$environmentName\customDeploymentSettings.json"
            $newCustomConfiguration = [PSCustomObject]@{}
            $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'ActivateFlowConfiguration' -Value $flowActivationUsers
            $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'ConnectorShareWithGroupTeamConfiguration' -Value $customConnectorSharings
            $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'SolutionComponentOwnershipConfiguration' -Value $flowOwnerships
            $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'FlowShareWithGroupTeamConfiguration' -Value $flowSharings
            $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'AadGroupCanvasConfiguration' -Value $canvasApps
            $newCustomConfiguration | Add-Member -MemberType NoteProperty -Name 'AadGroupTeamConfiguration' -Value $groupTeams
            #Convert the updated configuration to json and store in customDeploymentSettings.json
            Write-Host "Creating custom deployment settings"
            $json = ConvertTo-Json -Depth 10 $newCustomConfiguration
            if ($PSVersionTable.PSVersion.Major -gt 5) {
                Set-Content -Path $customDeploymentSettingsFilePath -Value $json
            }
            else {
                $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
                $jsonBytes = $utf8NoBomEncoding.GetBytes($json)
                Set-Content -Path $customDeploymentSettingsFilePath -Value $jsonBytes -Encoding Byte
            }
            #Set the build variables
            Set-BuildDefinitionVariables $orgUrl $projectName $azdoAuthType $buildDefinitionResponseResults[0] $buildDefinitionResponseResults[0].id $newBuildDefinitionVariables
        }
    }
}

function New-DeploymentPipelines
{
    param (
        [Parameter(Mandatory)] [String]$pipelineSourceDirectory,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$projectName,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$azdoAuthType,
        [Parameter(Mandatory)] [String] [AllowEmptyString()] $pat,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter()] [System.Object[]] [AllowEmptyCollection()]$configurationData,
        [Parameter()] [String]$agentOS
    )
    if($null -ne $configurationData -and $configurationData.length -gt 0) {
        Write-Host "Retrieved " $configurationData.length " deployment environments"
        $branchResourceUrl = "$orgUrl$projectName/_apis/git/repositories/$repo/refs?filter=heads/$solutionName&api-version=6.0"
        Write-Host $branchResourceUrl
        $branchResourceResponse = Invoke-RestMethod $branchResourceUrl -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
        $branchResourceResults = $branchResourceResponse.value
        Write-Host "Retrieved " $branchResourceResults.length " branch"

        #Update / Create Deployment Pipelines
        $buildDefinitionResourceUrl = "$orgUrl$projectName/_apis/build/definitions?name=deploy-*-$solutionName&includeAllProperties=true&api-version=6.0"
        Write-Host $buildDefinitionResourceUrl
        $fullBuildDefinitionResponse = Invoke-RestMethod $buildDefinitionResourceUrl -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
        $buildDefinitionResponseResults = $fullBuildDefinitionResponse.value
        Write-Host "Retrieved " $buildDefinitionResponseResults.length " builds"

        #$deploymentConfigurationData = $configurationData | Where-Object -FilterScript { [string]::IsNullOrWhiteSpace($_.StepType) -or $_.StepType -ne 809060000 }
        [System.Object[]]$deploymentConfigurationData = $configurationData | Where-Object { 
            ([string]::IsNullOrWhiteSpace($_.StepType)) -or ($_.StepType -ne 809060000)
        }
        
        Write-Host "Retrieved " $deploymentConfigurationData.length " deployment configurations"

        if($branchResourceResults.length -eq 0 -or $buildDefinitionResponseResults.length -lt $deploymentConfigurationData.length) {
            $settings= ""
            $environmentNames = ""
            foreach($deploymentEnvironment in $deploymentConfigurationData) {
                if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                    $settings = $settings + ","
                }

                if(-Not [string]::IsNullOrWhiteSpace($environmentNames)) {
                    $environmentNames = $environmentNames + "|"
                }

                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentUrl) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentName)) {
                    $environmentNames = $environmentNames + $deploymentEnvironment.DeploymentEnvironmentName
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "=" + $deploymentEnvironment.DeploymentEnvironmentUrl
                }

                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.ServiceConnectionName) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentName)) {
                    if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                        $settings = $settings + ","
                    }
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "-scname=" + $deploymentEnvironment.ServiceConnectionName
                }

                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.VariableGroup) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.DeploymentEnvironmentName)) {
                    if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                        $settings = $settings + ","
                    }
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "-variablegroup=" + $deploymentEnvironment.VariableGroup
                }

                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.BuildName) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.BuildName)) {
                    if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                        $settings = $settings + ","
                    }
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "-buildname=" + $deploymentEnvironment.BuildName
                }

                if(-Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.BuildTemplate) -and -Not [string]::IsNullOrWhiteSpace($deploymentEnvironment.BuildTemplate)) {
                    if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                        $settings = $settings + ","
                    }
                    $settings = $settings + $deploymentEnvironment.DeploymentEnvironmentName.ToLower() + "-buildtemplate=" + $deploymentEnvironment.BuildTemplate
                }
            }
            if(-Not [string]::IsNullOrWhiteSpace($settings)) {
                $settings = $settings + ",environments=" + $environmentNames
                Write-Host "environments: " $settings

                $currentPath = Get-Location
                Set-Location "$pipelineSourceDirectory"
                if(Test-Path ".\combined.log") {
                    Remove-Item ".\combined.log"
                }
                if ($agentOS -eq "Linux") {
                    #NOTE: The ability to call the coe-cli in a Linux environment is here for reference. Currently, the ALM Accelerator Pipelines require Windows runners due to several
                    #packages we use that are windows only. We are actively working toward support for Linux environments, but as of the time of this addition this is for reference only.
                    if([string]::IsNullOrWhiteSpace($pat)) {
                        .\Coe-Cli\linux\coe-cli alm branch --pipelineProject "$buildProjectName" --pipelineRepository "$buildRepositoryName" -o "$orgUrl" -p "$projectName" -r "$repo" -d "$solutionName" -a $env:SYSTEM_ACCESSTOKEN -s $settings
                    }
                    else {
                        .\Coe-Cli\linux\coe-cli alm branch --pipelineProject "$buildProjectName" --pipelineRepository $buildRepositoryName -o "$orgUrl" -p "$projectName" -r "$repo" -d "$solutionName" -a $pat -s $settings
                    }
                }
                else {
                    if([string]::IsNullOrWhiteSpace($pat)) {
                        .\Coe-Cli\coe-cli.exe alm branch --pipelineProject "$buildProjectName" --pipelineRepository "$buildRepositoryName" -o "$orgUrl" -p "$projectName" -r "$repo" -d "$solutionName" -a $env:SYSTEM_ACCESSTOKEN -s $settings
                    }
                    else {
                        .\Coe-Cli\coe-cli.exe alm branch --pipelineProject "$buildProjectName" --pipelineRepository "$buildRepositoryName" -o "$orgUrl" -p "$projectName" -r "$repo" -d "$solutionName" -a $pat -s $settings
                    }
                }

                if(Test-Path ".\combined.log") {
                    Write-Host ((Get-Content ".\combined.log") -join "`n") 
                }
                Set-Location $currentPath
            }
        }
    }
}

function Set-BuildDefinitionVariables {
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$projectName,
        [Parameter(Mandatory)] [String]$azdoAuthType,
        [Parameter()] [PSCustomObject]$buildDefinitionResult,
        [Parameter()] [String]$definitionId,
        [Parameter()] [PSCustomObject]$newBuildDefinitionVariables
    )
    if($null -ne $newBuildDefinitionVariables) {
        #Set the build definition variables to the newly created list
        ([pscustomobject]$buildDefinitionResult.variables) = ([pscustomobject]$newBuildDefinitionVariables)
        $buildDefinitionResourceUrl = "$orgUrl$projectName/_apis/build/definitions/" + $definitionId + "?api-version=6.0"
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN")
        $headers.Add("Content-Type", "application/json")
        $body = ConvertTo-Json -Depth 10 $buildDefinitionResult
        #remove tab charcters from the body
        $body = $body -replace "`t", ""
        Write-Host $buildDefinitionResourceUrl
        Invoke-RestMethod $buildDefinitionResourceUrl -Method 'PUT' -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) | Out-Null   
    }
}

function Create-Update-ServiceConnection-Parameters{
    param (
        [Parameter()] [String]$DeploymentEnvironmentUrl,
        [Parameter()] [String]$ServiceConnectionName,
        [Parameter()] [PSCustomObject]$newBuildDefinitionVariables
    )
    Write-Host "Inside Create-Update-ServiceConnection-Parameters"
    Write-Host "newBuildDefinitionVariables - $newBuildDefinitionVariables"
     if($null -ne $newBuildDefinitionVariables){
        #If the "ServiceConnection" variable was not found create it 
        $found = Check-Parameter "ServiceConnection" $newBuildDefinitionVariables
        if(!$found) { 
            $newBuildDefinitionVariables | Add-Member -MemberType NoteProperty -Name "ServiceConnection" -Value @{value = ''}
        }

        #If the "ServiceConnectionUrl" variable was not found create it 
        $found = Check-Parameter "ServiceConnectionUrl" $newBuildDefinitionVariables
        if(!$found) { 
            $newBuildDefinitionVariables | Add-Member -MemberType NoteProperty -Name "ServiceConnectionUrl" -Value @{value = ''}
        }

		# If the "$ServiceConnectionName" variable was not found, use $DeploymentEnvironmentUrl
		if([string]::IsNullOrEmpty($ServiceConnectionName))
		{
			$ServiceConnectionName = $DeploymentEnvironmentUrl
        }
        $newBuildDefinitionVariables.ServiceConnection.value = $ServiceConnectionName
        $newBuildDefinitionVariables.ServiceConnectionUrl.value = $DeploymentEnvironmentUrl
    }
}

function Check-Parameter{
    param (
        [Parameter()] [String]$configurationVariableName,
        [Parameter()] [PSCustomObject]$newBuildDefinitionVariables
    )
    $found = $false
    if($null -ne $newBuildDefinitionVariables){
        foreach($buildVariable in $newBuildDefinitionVariables.PSObject.Properties) {
            if($buildVariable.Name -eq $configurationVariableName) {
                $found = $true
                break
            }
         }
     }

     return $found
}

function Get-Group-Team-Name{
    param (
        [Parameter()] [String]$configurationVariableName
    )

    $teamName = ""
    $seperator=""
    $arrVariableParts = $configurationVariableName.split('.')

    if($arrVariableParts.Count -gt 2)
    {
        for($indxVariableParts=2;$indxVariableParts -lt $arrVariableParts.Count;$indxVariableParts++)
        {
            $teamName += $seperator + $arrVariableParts[$indxVariableParts]
            $seperator='.'
        }
    }

    Write-Host "teamName - $teamName"
    return $teamName
}

# Flow component name starts from split[2] to split[n-2]; if contains periods
function Get-Flow-Component-Name{
    param (
        [Parameter()] [String]$configurationVariableName
    )

    $flowComponentName = ""
    $seperator=""
    $arrVariableParts = $configurationVariableName.split('.')

    if($arrVariableParts.Count -gt 4)
    {
        for($indxVariableParts=2;$indxVariableParts -lt $arrVariableParts.Count-1;$indxVariableParts++)
        {
            $flowComponentName += $seperator + $arrVariableParts[$indxVariableParts]
            $seperator='.'
        }
    }
    elseif($arrVariableParts.Count -eq 4){
       $flowComponentName = $arrVariableParts[2]
    }

    Write-Host "flowComponentName - $flowComponentName"
    return $flowComponentName
}