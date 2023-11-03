<#
This function creates a new repo branch with the committed solution name.
Copies the environment deployment pipeline files to the newly created branch.
#>
function Invoke-Create-Branch{
    param (
        [Parameter(Mandatory)] [String]$organizationURL,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [String]$solutionProjectName,
        [Parameter(Mandatory)] [String]$solutionRepositoryName, 
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [String]$pipelineSourceDirectory,
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$environmentNames,
        [Parameter(Mandatory)] [String]$azdoAuthType,
        [Parameter(Mandatory)] [string]$solutionRepoId,
        [Parameter(Mandatory)] [string]$agentPool,
        [Parameter(Mandatory)] [String]$currentBranch,
        [Parameter(Mandatory)] [String]$createSolutionBranch,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$pipelineStageRunId
    )
        Write-Host "Pipeline Project - $buildProjectName Solution Project - $solutionProjectName"
        Write-Host "Pipeline Repository - $buildRepositoryName Solution Repository - $solutionRepositoryName"
        Write-Host "Fetching Pipeline Project - $buildProjectName Repositories"
        $solutionProjectRepo = $null
        # Fetch Repos of build project
        $pipelineRepos = Get-Repositories "$organizationURL" "$buildProjectName"

        $solutionProjectRepos = $null
        if($buildProjectName -eq $solutionProjectName){
            Write-Host "Build and Solution projects are same. No need to make a new API call"
            $solutionProjectRepos = $pipelineRepos
        }else{
            # Fetch Repos of solution project
            $solutionProjectRepos = Get-Repositories "$organizationURL" "$solutionProjectName"
        }

        Write-Host "Checking $buildRepositoryName available among the $($pipelineRepos.value.length) Repos of $buildProjectName"
        $buildRepoExists = $false
        foreach ($pipelineRepo in $pipelineRepos.value) {
            #Write-Host "$($pipelineRepo.name) and $buildRepositoryName"
            if ($pipelineRepo.name -eq $buildRepositoryName) {
                $buildRepoExists = $true
                break
            }
        }

        if($buildRepoExists){
            Write-Host "Found $buildRepositoryName under pipeline project $buildProjectName"
        }else{
            Write-Host "$buildRepositoryName missing under pipeline project $buildProjectName"
        }

        Write-Host "Checking $solutionRepositoryName available among the $($solutionProjectRepos.value.length) Repos of $solutionProjectName"
        $solutionRepoExists = $false
        foreach ($solutionRepo in $solutionProjectRepos.value) {
            if ($solutionRepo.name -eq $solutionRepositoryName) {
                $solutionRepoExists = $true
                $solutionProjectRepo = $solutionRepo
                Write-Host "Solution Project Repo additional details. Id - $($solutionProjectRepo.id) ; Name - $($solutionProjectRepo.name) ; Url - $($solutionProjectRepo.url)"
                break
            }
        }

        if($solutionRepoExists){
            Write-Host "Found $solutionRepositoryName under solution repository $solutionProjectName"
        }else{
            Write-Host "$solutionRepositoryName missing under solution repository $solutionProjectName"
        }

        if($buildRepoExists -and $solutionRepoExists){
            Write-Host "Validating whether the Solution Project -$solutionProjectName is Initialized"
            $repoRefUrl = "$orgUrl$solutionProjectName/_apis/git/repositories/$solutionRepositoryName/refs?filter=heads/&api-version=6.0"
            Write-Host "RepoRefUrl - $repoRefUrl"
            $repoRefUrlResponse = Invoke-RestMethod $repoRefUrl -Method Get -Headers @{
                Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
            }     
            
            if($repoRefUrlResponse.value.length -gt 0)
            {
                Write-Host "Solution Repo - $repo has been Initialized"
                $sourceRefId = $null
                $solutionBranchExists = $false
                # Check if 'Soure Branch' exists
                foreach($refBranch in $repoRefUrlResponse.value){
                    if($refBranch.name -eq "refs/heads/$solutionName"){
                        $solutionBranchExists = $true
                        Write-Host "Solution Branch - $solutionName found."
                    }
                }

                # If Environment Names not provided, fall back to validation|test|prod.
                if([string]::IsNullOrEmpty($environmentNames)){
                    Write-Host "EnvironmentNames not found in Settings. Falling back."
                    $environmentNames = "validation|test|prod"
                }

                Write-Host "Environment Names - $environmentNames"

                # Get 'pipelines' content for all environments
                foreach ($environmentName in $environmentNames.Split('|')) {
                    Write-Host "Check if content yml file available for $environmentName. If not downloads and commit them to solution branch."
                    # Fetch Commit Changes Collection
                    Get-Git-Commit-Changes "$organizationURL" "$buildProjectName" "$solutionProjectName" "$solutionRepositoryName" "$pipelineSourceDirectory" "$buildRepositoryName" "$buildSourceDirectory" "$solutionName" "$environmentName" "$agentPool" "$pipelineStageRunId"
                }

                if($solutionBranchExists -ne $true -and $createSolutionBranch -ne "false" -and $currentBranch -ne "$solutionName"){
                    # Create a new Branch
                    Write-Host "No commit changes. Creating new solution branch - $solutionName"
                    # Construct the request body for creating a new branch
                    $body = @"
                    [
                        {
                            "name": "refs/heads/$solutionName",
                            "newObjectId": "$sourceRefId",
                            "oldObjectId": "0000000000000000000000000000000000000000"
                        }
                    ]
"@
                            
                    # Construct the API endpoint URL for creating a new branch
                    $apiUrl = "$organizationURL$solutionProjectName/_apis/git/repositories/$solutionRepositoryName/refs?api-version=5.0"
                    Write-Host "New branch creation apiUrl - $apiUrl"

                    $response = $null
                    try{
                        # Send a POST request to the API endpoint to create a new branch
                        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers @{
                            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
                            "Content-Type" = "application/json"
                        } -Body $body
                    }
                    catch {
                        Write-Host "Error while posting $body to $apiUrl. Message - $($_.Exception.Message)"
                    }

                    Write-Host "Branch creation response - $response"

                    if($null -ne $response){
                        Write-Host "New branch created with ref name $($response.name) and object ID $($response.objectId)"
                    }
                    else{
                        Write-Host "##vso[task.logissue type=warning]Unable to create solution branch - $solutionName."
                        throw
                    }
                }else{
                    Write-Host "No commits to this repository yet. Initialize this repository before creating new branches"
                }
            }
        }
        
        return $solutionProjectRepo
}

<#
This function is a child function of Invoke-Create-Branch.
Checks and returns existence of repos under a project.
#>
function Get-Repositories{
    param (
        [Parameter(Mandatory)] [String]$organizationURL,
        [Parameter(Mandatory)] [String]$project
    )

    Write-Host "Fetching repositories of project - $project"

    $getReposInProjectUrl = "$organizationURL$project/_apis/git/repositories?api-version=6.0"
    Write-Host "GetReposInProjectUrl - $getReposInProjectUrl"
    $getReposInProjectResponse = Invoke-RestMethod $getReposInProjectUrl -Method Get -Headers @{
        Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
    }

    Write-Host "$($getReposInProjectResponse.value.length) repositories available in Project - $project"
    return $getReposInProjectResponse
}

<#
This function is a child function of Invoke-Create-Branch.
Gets the deployment pipelines content from pipeline repo.
Commits the pipeline files to the solution branch.
#>
function Get-Git-Commit-Changes{
    param(
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [String]$solutionProjectName,
        [Parameter(Mandatory)] [String]$solutionRepositoryName, 
        [Parameter(Mandatory)] [String]$pipelineSourceDirectory,
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [String]$buildSourceDirectory,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$environmentName,
        [Parameter(Mandatory)] [String]$agentPool,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$pipelineStageRunId
    )

    $deployPipelineName = "deploy-$environmentName".ToLower()
    $ymlContentFilePath = "/$solutionName/$deployPipelineName-$solutionName.yml"
    Write-Host "RepoTemplatePath - $ymlContentFilePath"
    # Check if build yml file available under source branch
    $deploymentPipelineYamlFile = "$buildSourceDirectory\$repo\$solutionName\$deployPipelineName-$solutionName.yml"
    Write-Host "Build Source Directory - $buildSourceDirectory\$repo\$solutionName"
    $ymlContentFileExists = Test-Path $deploymentPipelineYamlFile

    if(-not $ymlContentFileExists){
        Write-Host "Downloading YML content file for $environmentName"
        # Fetch the Template from pipeline Repo
        $deployPipelineName = "build-deploy-$environmentName".ToLower()
        $templatePath = "/Pipelines/$deployPipelineName-SampleSolution.yml"
        if($null -ne $pipelineStageRunId -and $pipelineStageRunId -ne "") {
            # Fetch the Pipelines for PP template from pipeline Repo
            $templatePath = "/Pipelines/$deployPipelineName-Pipelines.yml"
        }
        Write-Host "Check for buildtemplate in settings. Key - $environmentName-buildtemplate"
        $settingsTemplatePath = Get-Value-From-settings $settings "$environmentName-buildtemplate"
        if($null -ne $settingsTemplatePath){
            Write-Host "Template Path mentioned in Settings for $environmentName. Path - $settingsTemplatePath"
            $templatePath = $settingsTemplatePath
        }else{
            Write-Host "Template Path not mentioned in Settings for $environmentName"
        }
                                    
        Write-Host "Fetching the build pipeline content from - $pipelineSourceDirectory\$templatePath"
        # Get the pipeline content from the local template repo
        if(Test-Path "$pipelineSourceDirectory\$templatePath"){
            Write-Host "Fetched pipeline content file for $environmentName"
            $pipelineContent = Get-Content "$pipelineSourceDirectory\$templatePath"
            # Replace Placeholders in the template. Hardcoding main for now as the default branch containing the build templates
            $pipelineContent = $pipelineContent -replace "BranchContainingTheBuildTemplates", "main"
            $pipelineContent = $pipelineContent -replace "RepositoryContainingTheBuildTemplates", "$buildProjectName/$buildRepositoryName"
            $pipelineContent = $pipelineContent -replace "SampleSolutionName", $solutionName
            if($agentPool -ne "Azure Pipelines"){
                if($pipelineStageRunId -ne '') {
                    Write-Host "Updating to build-deploy-Solution-To-Environment-Hosted-Pipelines.yml for $pipelineStageRunId"
                    $pipelineContent = $pipelineContent -replace "build-deploy-Solution-To-Environment-Pipelines.yml", "build-deploy-Solution-To-Environment-Hosted-Pipelines.yml"
                } else {
                    Write-Host "Updating to build-deploy-Solution-To-Environment-Hosted.yml for $pipelineStageRunId"
                    $pipelineContent = $pipelineContent -replace "build-deploy-Solution-To-Environment.yml", "build-deploy-Solution-To-Environment-Hosted.yml"
                }
            }

            $variableGroup = Get-Value-From-settings $settings "$environmentName-variablegroup"
            if($null -ne $variableGroup){
                $pipelineContent = $pipelineContent -replace "alm-accelerator-variable-group", $variableGroup
            }

            Write-Host "Pipeline content post substitution - $pipelineContent"
            $pipelineContent | Out-File $deploymentPipelineYamlFile
        }else{
            Write-Host "Unable to fetch pipeline content for $environmentName"
        }
    }else{
        Write-Host "YML content file exists at $ymlContentFilePath for $environmentName"
    }

    return $deploymentPipelineYamlFile
}

<#
This function creates the pipeline definitions based on the committed the pipeline files.
A default queue will be set to each Pipeline definitions.
#>
function Update-Build-for-Branch{
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$solutionProjectName,
        [Parameter(Mandatory)] [string]$azdoAuthType,
        [Parameter(Mandatory)] [string]$environmentNames,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [object]$repo,
        [Parameter(Mandatory)] [object]$settings,
        [Parameter(Mandatory)] [string]$solutionRepoId,
        [Parameter(Mandatory)] [String]$buildRepoName,
        [Parameter(Mandatory)] [String]$buildDirectory,
        [Parameter(Mandatory)] [String]$currentBranch,
        [Parameter(Mandatory)] [String]$agentPool,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$pipelineStageRunId
    )

    Write-Host "Retrieving default Queue"
    $defaultAgentQueue = Get-AgentQueueByName "$orgUrl" "$solutionProjectName" "$azdoAuthType" "$agentPool"
    if($null -ne $defaultAgentQueue){
        Write-Host "Default queue ($agentPool) is available"
        # If Environment Names not provided, fall back to validation|test|prod.
        if([string]::IsNullOrEmpty($environmentNames)){
            Write-Host "EnvironmentNames not found in Settings. Falling back."
            $environmentNames = "validation|test|prod"
        }

        # Get 'pipelines' content for all environments
        $collEnvironmentNames = $environmentNames.Split('|')
        foreach ($environmentName in $collEnvironmentNames) {
            Invoke-Clone-Build-Settings "$orgUrl" "$solutionProjectName" "$settings" "$environmentName" "$solutionName" $repo "$azdoAuthType" $defaultAgentQueue "$solutionProjectName" "$buildRepoName" "$buildDirectory" "$currentBranch" "$pipelineStageRunId"
        }
    }else{
        Write-Host "'$agentPool' queue Not Found. You will need to set the default queue manually. Please verify the permissions for the user executing this command include access to queues."
    }
}

<#
This function is a child function of Update-Build-for-Branch.
Validates if the pipleine definition is already exists.
#>
function Invoke-Clone-Build-Settings {
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [string]$settings,
        [Parameter(Mandatory)] [string]$environmentName,
        [Parameter(Mandatory)] [string]$solutionName,
        [Parameter(Mandatory)] [object]$repo,
        [Parameter(Mandatory)] [string]$azdoAuthType,
        [Parameter(Mandatory)] [object]$defaultAgentQueue,
        [Parameter(Mandatory)] [String]$solutionProjectName,
        [Parameter(Mandatory)] [String]$buildRepoName,
        [Parameter(Mandatory)] [String]$buildDirectory,
        [Parameter(Mandatory)] [String]$currentBranch,
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$pipelineStageRunId
    )

    $destinationBuildName = "deploy-$environmentName".ToLower()
    $destinationBuildName = "$destinationBuildName-$solutionName"
    Write-Host "Looking for DestinationBuildName - $destinationBuildName from the build definitions"
    $pipelines = Get-Repository-Build-Definitions "$orgUrl" "$solutionProjectName" "$destinationBuildName" "$azdoAuthType" "$solutionRepoId"
    $destinationBuild = $pipelines.value | Where-Object {$_.name -eq "$destinationBuildName"}
    # Backward compatibility logic. Check if there other pipleines available with matching pattern. If yes, fetch the Path
    $matchedSolutionBuilds = $pipelines.value | Where-Object {$_.name -like "deploy-*-$solutionName"}
    Write-Host "Number of matched solution builds - " $matchedSolutionBuilds.Count
    # If no matched builds available create a new folder with convention \\Repo - SolutionName
    # If matched builds available, take the $pathofMatchedBuild
    $pathofMatchedBuild = $null
    if($matchedSolutionBuilds.Count -gt 0){
        $pathofMatchedBuild = $matchedSolutionBuilds[0].path
    }else{
        $pathofMatchedBuild = "/$($repo.name) - $solutionName"
    }
    Write-Host "Path of matched build - $pathofMatchedBuild"

    if($destinationBuild){
        Write-Host "Pipeline already configured for $destinationBuildName. No action needed. Returning"
        return;
    }else{
        # Create new Pipeline
        Update-Build-Definition "$orgUrl" "$buildProjectName" "$settings" "$environmentName" "$solutionName" $repo "$destinationBuildName" "$azdoAuthType" $defaultAgentQueue $pathofMatchedBuild "$solutionProjectName" "$buildRepoName" "$buildDirectory" "$currentBranch" "$pipelineStageRunId"
    }
}

<#
This function is a child function of Invoke-Clone-Build-Settings.
Creates the new pipleine build definition if not exists already.
#>
function Update-Build-Definition{
Param(
    [Parameter(Mandatory)] [String]$orgUrl,
    [Parameter(Mandatory)] [String]$buildProjectName,
    [Parameter(Mandatory)] [string]$settings,
    [Parameter(Mandatory)] [string]$environmentName,
    [Parameter(Mandatory)] [string]$solutionName,
    [Parameter(Mandatory)] [object]$repo,
    [Parameter(Mandatory)] [string]$destinationBuildName,
    [Parameter(Mandatory)] [string]$azdoAuthType,
    [Parameter(Mandatory)] [object]$defaultAgentQueue,
    [Parameter()] [string]$pathofMatchedBuild,
    [Parameter(Mandatory)] [String]$solutionProjectName,
    [Parameter(Mandatory)] [String]$buildRepoName,
    [Parameter(Mandatory)] [String]$buildSourceDirectory,
    [Parameter(Mandatory)] [String]$currentBranch,
    [Parameter(Mandatory)] [String] [AllowEmptyString()]$pipelineStageRunId
)
    #Yaml file name
    $deployPipelineName = "deploy-$environmentName".ToLower()
    $yamlFileName = "/$solutionName/$deployPipelineName-$solutionName.yml"

    Write-Host "Creating build definition for $yamlFileName"
    # Prepare Variables
    $serviceConnectionName = $null
    # Read the Service Connection URL from Settings by Environment Name.
    $serviceConnectionUrl = Get-ValueFromKey-Settings "$environmentName" "$settings"
    Write-Host "Service Connection Url - $serviceConnectionUrl"
    #Fall back to using the service connection url supplied as the service connection name if no name was supplied
    if ($null -eq $serviceConnectionName) {
        $serviceConnectionName = $serviceConnectionUrl
    }

    Write-Host "Build definition path - $pathofMatchedBuild"
    Write-Host "Current Branch: $currentBranch"
    Write-Host "Creating a new pipeline $destinationBuildName"
    $pipelinDefinitionBody = @{
        name = "$destinationBuildName"
        repository = @{
            id = $($repo.id)
            name = $($repo.name)
            url = $($repo.url)
            type = "TfsGit"
            defaultBranch = "refs/heads/$currentBranch"
            clean = $null
            checkoutSubmodules = $false
        }
        quality = "definition"
        #path = "/$solutionName"        
        path = $pathofMatchedBuild
        process = @{
            yamlFilename = $yamlFileName
            type = 2
        }
        variables = @{
            EnvironmentName = @{
                value = "$environmentName"
            }
            ServiceConnection = @{
                value = "$serviceConnectionName"
            }
            ServiceConnectionUrl = @{
                value = "$serviceConnectionUrl"
            }
        }        
        jobAuthorizationScope = "projectCollection"
        triggers = @(
            @{
                triggerType = 2
                branchFilters = @()
                pathFilters = @()
                maxConcurrentBuildsPerBranch = 1
                batchChanges = $false
                settingsSourceType = 2
            }
        )
        queue = @{
            id = $defaultAgentQueue.id
            name = $defaultAgentQueue.name
            url = "$orgUrl/_apis/build/Queues/$($defaultAgentQueue.id)"
            pool = @{
                id = $($defaultAgentQueue.pool.id)
                name = $($defaultAgentQueue.pool.name)
                isHosted = $true
            }
        }        
    }

    $jsonBody = $pipelinDefinitionBody | ConvertTo-Json
    # For some reason nested array not parsing properly
    # Logic to convert String to array
    $jsonBodyCleansed = $jsonBody -replace """branchFilters"":  ""main""","""branchFilters"":  [""main""]" 
    Write-Host "Cleansed Body $jsonBodyCleansed"

    $uriBuildDefinition = "$orgUrl$buildProjectName/_apis/build/definitions?api-version=6.0"
    Write-Host "Create Definition URI - $uriBuildDefinition"
        
    try{
        # Send a POST request to the API endpoint to create a new branch
        $headers = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $env:SYSTEM_ACCESSTOKEN"
        }

        Invoke-RestMethod -Uri $uriBuildDefinition -Method Post -Headers $headers -Body $jsonBodyCleansed
        Write-Host "Pipeline definition created successfully."
    }
    catch {
        $errorMessage = $_.Exception.Message
        $innerException = $_.Exception.InnerException

        while ($innerException) {
            $errorMessage += "`nInner Exception:`n" + $innerException.Message
            $innerException = $innerException.InnerException
        }

        Write-Host "An exception occurred: $errorMessage"
    }
}


<#
This function is a child function of Invoke-Clone-Build-Settings and Set-Branch-Policy.
Fetches the build definitions under the Repository
#>
function Get-Repository-Build-Definitions {
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [String]$buildName,
        [Parameter(Mandatory)] [string]$azdoAuthType,
        [Parameter(Mandatory)] [string]$solutionRepoId
    )

    #Retrieve the build by name
    $buildDefinitionResponse = $null
    $uriBuildDefinition = "$orgUrl$buildProjectName/_apis/build/definitions?name=$buildName&api-version=6.0"
    Write-Host "UriBuildDefinition - $uriBuildDefinition"
    try {
        $buildDefinitionResponse = Invoke-RestMethod $uriBuildDefinition -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
    }
    catch {
        Write-Error $_.Exception.Message
        return
    }

    #If only one result is returned then return the result
    if($buildDefinitionResponse.value.length -eq 1){
        Write-Host "Build Definition Response - $buildDefinitionResponse"
        return $buildDefinitionResponse
    }

    #If more than one result is returned then filter by repository
    $uriBuildDefinition = "$orgUrl$buildProjectName/_apis/build/definitions?name=$buildName&repositoryId=$solutionRepoId&repositoryType=TfsGit&api-version=6.0"

    Write-Host "UriBuildDefinition - $uriBuildDefinition"
    try {
        $buildDefinitionResponse = Invoke-RestMethod $uriBuildDefinition -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
    }
    catch {
        Write-Error $_.Exception.Message
        return
    }

    Write-Host "Build Definition Response - $buildDefinitionResponse"
    return $buildDefinitionResponse
}

<#
This function is a child function of Update-Build-for-Branch.
Fetches the Agent queue by name.
#>
function Get-AgentQueueByName {
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [string]$azdoAuthType,
        [Parameter(Mandatory)] [string]$queueNameToSearch
    )

    $defaultQueue = $null
    $uriQueues = "$orgUrl$buildProjectName/_apis/distributedtask/queues?api-version=6.0"
    
    try {
        $queuesResponse = Invoke-RestMethod $uriQueues -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }

        Write-Host "Found: $($queuesResponse.value.Length) queues"
        # Get queue by name
        $defaultQueue = $queuesResponse.value | Where-Object { $_.name -eq $queueNameToSearch }
        Write-Host "DefaultQueue - $defaultQueue"
        # Print queue ID if found, or error if not found
        if ($defaultQueue) {
            Write-Host "Queue ID: $($defaultQueue.id)"
        } else {
            Write-Error "Queue not found: $queueNameToSearch"
        }
    }
    catch {
        Write-Host "Error while retrieving queues. " $_.Exception.Message
    }

    return $defaultQueue
}

<#
This function is a child function of Update-Build-Definition.
Fetches value from settings.
#>
function Get-ValueFromKey-Settings {
    param (
        [Parameter(Mandatory = $true)] [string]$Key,
        [Parameter(Mandatory = $true)] [string]$settings
    )
    
    $hash = ConvertFrom-StringData -StringData $settings.Replace(',',"`n")

    if ($hash.ContainsKey($Key)) {
        return $hash[$Key]
    }
    else {
        Write-Error "Key '$Key' not found in Settings."
    }

    return $null
}

<#
This function sets the branch policy for the solution branch.
Branch policy triggers validation pipeline.
#>
function Set-Branch-Policy{
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$solutionProjectName,
        [Parameter(Mandatory)] [string]$azdoAuthType,
        [Parameter(Mandatory)] [string]$environmentNames,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [object]$repo,
        [Parameter(Mandatory)] [object]$settings,
        [Parameter(Mandatory)] [string]$solutionRepoId,
        [Parameter(Mandatory)] [string]$agentPool
    )

    Write-Host "Fetching Project Build Definitions to set the policy"
    $policyTypes = Get-Policy-Types "$orgUrl" "$solutionProjectName" "$azdoAuthType"
    # Check if a Policy Type by name 'Build' exists.
    $buildTypes = $policyTypes.value | Where-Object { $_.displayName -eq "Build" }
    if($buildTypes){
        Write-Host "Policy Type by name 'Build' exists. Getting Policy configurations."
        # Get existing Policy configurations
        $uriPolicyConfigs = "$orgUrl$solutionProjectName/_apis/policy/configurations?api-version=6.0"
        Write-Host "UriPolicyConfigs - $uriPolicyConfigs"
        try {
            $policyConfigResponse = Invoke-RestMethod $uriPolicyConfigs -Method Get -Headers @{
                Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
            }
        }
        catch {
            Write-Error $_.Exception.Message
            return
        }

        $existingPolices = $null
        Write-Host "Policy Configuration Response - $policyConfigResponse"
        # Loop through the policy configurations and output the results
        foreach ($policyConfig in $policyConfigResponse.value) {
            $refName = $($policyConfig.settings.Scope.refName)
            $repositoryId = $($policyConfig.settings.Scope.repositoryId)
            $displayName = $($policyConfig.settings.displayName)
            $typeId = $($policyConfig.type.id)
            if(($refName -eq "refs/heads/$solutionName") -and ($repositoryId -eq "$($repo.id)") -and ($displayName -eq "Build Validation") -and ($typeId -eq $buildTypes[0].id)){
                $existingPolices = $policyConfig
                break
            }
        }

        # Check if there are existing policies. If yes, delete the policy configuration.
        if($null -ne $existingPolices){
            Write-Host "Policy of branch $solutionName already exists. Deleting existing policy"
            $uriDeleteConfig = "$orgUrl$solutionProjectName/_apis/policy/configurations/$($existingPolices.id)?api-version=6.0"
            Write-Host "UriDeleteConfig - $uriDeleteConfig"
            $deletePolicyResponse = Invoke-RestMethod $uriDeleteConfig -Method Delete -Headers @{
                Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
            }

            Write-Host "Existing Policy has been deleted. Response - $deletePolicyResponse"
        }

        Write-Host "Creating a new Policy."
        $builds = Get-Repository-Build-Definitions "$orgUrl" "$solutionProjectName" "deploy-validation-$solutionName" "$azdoAuthType" "$solutionRepoId"

        $destinationBuild = $builds.value | Where-Object {$_.name -eq "deploy-validation-$solutionName"}

        if($destinationBuild){
            Write-Host "Found policy build $($destinationBuild.name)"

            # Define the policy configuration object with the scope property as an array
            $newPolicyBody = @{
                type =@{
                    id = "$($buildTypes[0].id)"
                    url = "$($buildTypes[0].url)"
                }
                isBlocking = $true
                isEnabled = $true
                isEnterpriseManaged = $false
                settings = @{
                    buildDefinitionId = "$($destinationBuild.id)"
                    displayName = "Build Validation"
                    filenamePatterns = @("/$solutionName/*")
                    manualQueueOnly = $false
                    queueOnSourceUpdateOnly = $false
                    validDuration = 0
                    scope = @{
                        repositoryId = "$($repo.id)"
                        refName = "refs/heads/$solutionName"
                        matchKind = "Exact"
                    }
                }
            }

            $jsonNewPolicyBody = ConvertTo-Json $newPolicyBody
            
            # For some reason, nested arrays are not getting parsed properly.
            # Workaround for 'Scope' tag
            # Convert JSON string to PowerShell object
            $jsonObject = $jsonNewPolicyBody | ConvertFrom-Json

            # Convert existing "Scope" property to array
            $scopeArray = @($jsonObject.settings.scope)

            # Modify "Scope" property to the array
            $jsonObject.settings.scope = $scopeArray

            # Convert modified PowerShell object back to JSON string
            $newPolicyBodyUpdated = $jsonObject | ConvertTo-Json -Depth 10

            # Print the updated JSON string
            Write-Host "NewPolicyBody Updated - $newPolicyBodyUpdated"

            # API endpoint URL
            $urlNewPolicy = "$orgUrl$solutionProjectName/_apis/policy/configurations?api-version=6.0"
            Write-Host "UrlNewPolicy - $urlNewPolicy"
               
            try{
                # Send a POST request to the API endpoint to create a new Policy
                $newPolicyResponse = Invoke-RestMethod -Uri $urlNewPolicy -Method Post -Headers @{
                    Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
                    "Content-Type" = "application/json"
                } -Body $newPolicyBodyUpdated
            }
            catch {
                Write-Host "Error while creating new policy. Message - $($_.Exception.Message)"
            }

            # Print the ID of the new policy
            Write-Host "New Policy Id - " $newPolicyResponse.id
        }else{
            Write-Host "policy build $($destinationBuild.name) not found"
        }
    }else{
        Write-Host "Policy Type by name 'Build' is unavailable"
    }
}

<#
This function is a child function of Set-Branch-Policy.
Fetches the policy types of project.
#>
function Get-Policy-Types {
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$solutionProjectName,
        [Parameter(Mandatory)] [string]$azdoAuthType
    )

    Write-Host "Fetching policy types"
    $policyTypesResponse = $null    
    $uriPolicyTypes = "$orgUrl$solutionProjectName/_apis/policy/types?api-version=6.0-preview.1"
    Write-Host "UriPolicyTypes - $uriPolicyTypes"
    try {
        $policyTypesResponse = Invoke-RestMethod $uriPolicyTypes -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
    }
    catch {
        Write-Error $_.Exception.Message
        return
    }

    Write-Host "Policy Types Response - $policyTypesResponse"
    return $policyTypesResponse
}

<#
This function fetches the repositories of project.
#>
function Get-Repo-in-Project{
    param (
        [Parameter(Mandatory)] [String]$organizationURL,
        [Parameter(Mandatory)] [String]$project,
        [Parameter(Mandatory)] [String]$repositoryName 
    )

    $getRepoInProjectUrl = "$organizationURL$project/_apis/git/repositories/$repositoryName"
    $getRepoInProjectResponse = Invoke-RestMethod $getRepoInProjectUrl -Method Get -Headers @{
        Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
    }

    return $getRepoInProjectResponse
}


<#
This function is a child function of Get-Git-Commit-Changes.
Fetches the value from key value dictionary.
#>
function Get-Value-From-settings {
    param (
        [Parameter(Mandatory)] [string]$InputString,
        [Parameter(Mandatory)] [string]$ParameterName
    )

    $keyValuePairs = $InputString.Split(',')
    
    foreach ($pair in $keyValuePairs) {
        $keyValue = $pair.Split('=')
        if ($keyValue[0].Trim() -eq $ParameterName) {
            return $keyValue[1].Trim()
        }
    }
    
    return $null
}

<#
This function downloads the file content and created a new yml file.
#>
function Download-File-to-Location{
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [string]$azdoAuthType,
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [string]$sourceBranch,
        [Parameter(Mandatory)] [string]$ymlContentFilePath,
        [Parameter(Mandatory)] [string]$tempYamlFilePath,
        [Parameter(Mandatory)] [string]$currentBranch
    )
    Write-Host "Fetching the build pipeline content from - $ymlContentFilePath"
    $downloadFileUrl = "$orgUrl$buildProjectName/_apis/git/repositories/$buildRepositoryName/items?path=$ymlContentFilePath&includeContent=true&versionDescriptor.version=$sourceBranch&versionDescriptor.versionType=branch&api-version=5.0"
    Write-Host "DownloadFileUrl - $downloadFileUrl"
    $downloadFileResponse = $null
    try{
        $downloadFileResponse = Invoke-RestMethod $downloadFileUrl -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
    }
    catch {
        Write-Host "Pipeline template does not exist at $ymlContentFilePath. Message - $($_.Exception.Message)"
        return $false
    }

    #Write-Host "DownloadFileResponse - $downloadFileResponse"
    if($null -ne $downloadFileResponse){
        # Check if the folder path exists
        $folderPath = Split-Path -Path $tempYamlFilePath
        if (-not (Test-Path -Path $folderPath -PathType Container)) {
            Write-Host "Creating folder path - $folderPath"
            New-Item -Path $folderPath -ItemType Directory -Force
        }

        # Check if the file exists
        if (-not (Test-Path -Path $tempYamlFilePath -PathType Leaf)) {
            Write-Host "Creating yml file - $tempYamlFilePath"
            Set-Content -Path $tempYamlFilePath -Value $downloadFileResponse
        }
        Write-Host "Created file under $tempYamlFilePath"
        return $true
    }

    return $false
}