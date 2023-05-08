<#
This function creates a new repo branch with the committed solution name.
Copies the environment deployment pipeline files to the newly created branch.
#>
function Create-Branch{
    param (
        [Parameter(Mandatory)] [String]$organizationURL,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [String]$solutionProjectName,
        [Parameter(Mandatory)] [String]$solutionRepositoryName, 
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$environmentNames,
        [Parameter(Mandatory)] [String]$azdoAuthType
    )
        Write-Host "Pipeline Project: $buildProjectName"
        Write-Host "Getting Pipeline Project Repositories"
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
                Write-Host "Setting Solution Project Repo. Id - $($solutionProjectRepo.id) ; Name - $($solutionProjectRepo.name) ; Url - $($solutionProjectRepo.url)"
                break
            }
        }

        if($solutionRepoExists){
            Write-Host "Found $solutionRepositoryName under solution repository $solutionProjectName"
        }else{
            Write-Host "$solutionRepositoryName missing under solution repository $solutionProjectName"
        }

        if($buildRepoExists -and $solutionRepoExists){
            Write-Host "Validating whether the Solution Project is Initialized"
            $repoRefUrl = "$orgUrl$solutionProjectName/_apis/git/repositories/$solutionRepositoryName/refs?filter=heads/&api-version=6.0"
            Write-Host "RepoRefUrl - $repoRefUrl"
            $repoRefUrlResponse = Invoke-RestMethod $repoRefUrl -Method Get -Headers @{
                Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
            }     
            
            if($repoRefUrlResponse.value.length -gt 0)
            {
                Write-Host "Solution Repo - $repo has been Initialized"
                $sourceBranch = "main"
                $defaultBranch = "main"
                $sourceBranchExists = $false
                $sourceRefId = $null
                $solutionBranchExists = $false
                # Check if 'Soure Branch' exists
                foreach($refBranch in $repoRefUrlResponse.value){
                    if($refBranch.name -eq "refs/heads/$sourceBranch"){
                        $sourceBranchExists = $true
                        $sourceRefId = $refBranch.objectId
                        Write-Host "Source Branch - $sourceBranch found. objectId -  $sourceRefId"
                    }
                    if($refBranch.name -eq "refs/heads/$solutionName"){
                        $solutionBranchExists = $true
                        Write-Host "Solution Branch - $solutionName found."
                    }
                }

                if($sourceBranchExists -eq $false){
                    Write-Host "Source Branch $sourceBranch not found.Exiting."
                    return $solutionProjectRepo
                }

                if($solutionBranchExists -eq $true){
                    Write-Host "Solution Branch $solutionName already exists. Exiting."
                    return $solutionProjectRepo
                }

                Write-Host "Proceeding with Branch creation"
                # If Environment Names not provided, fall back to validation|test|prod.
                if([string]::IsNullOrEmpty($environmentNames)){
                    Write-Host "EnvironmentNames not found in Settings. Falling back."
                    $environmentNames = "validation|test|prod"
                }

                Write-Host "Environment Names - $environmentNames"

                # Get 'pipelines' content for all environments
                $collEnvironmentNames = $environmentNames.Split('|')
                $commitChanges = New-Object System.Collections.ArrayList
                foreach ($environmentName in $collEnvironmentNames) {
                    Write-Host "Getting commit changes for $environmentName"
                    # Fetch Commit Changes Collection
                    $commitChange = Get-Git-Commit-Changes "$organizationURL" "$buildProjectName" "$solutionProjectName" "$solutionRepositoryName" "$buildRepositoryName" "$solutionName" "$environmentName" "$sourceBranch"
                    if($null -ne $commitChange){
                        $commitChanges.Add($commitChange)
                    }
                }

                Write-Host "Count of commitChanges - "$commitChanges.Count
                If($commitChanges.Count -eq 0){
                    # Create a new Branch
                    Write-Host "Creating new solution branch - $solutionName"
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

                    if($response){
                        Write-Host "New branch created with ref name $($response.name) and object ID $($response.objectId)"
                    }
                }
                else{
                    # Create a new commit object with the changes array
                    $commit = @(
                        @{
                            comment = "Add DevOps Pipeline"
                            changes = $commitChanges
                        }
                    )

                    $newRef = @(
                        @{
                            name = "refs/heads/$solutionName"
                            oldObjectId = "$sourceRefId"
                        }
                    )

                    $gitPush = @{
                        refUpdates = $newRef
                        commits = $commit
                    }

                    # Convert the commit object to JSON format
                    $gitPushBody = $gitPush | ConvertTo-Json -Depth 10

                    #Write-Host "GitPushBody - $gitPushBody"

                    $apiUrlGitPush = "$organizationURL$solutionProjectName/_apis/git/repositories/$solutionRepositoryName/pushes?api-version=6.0"
                    #Write-Host "ApiUrlGitPush - $apiUrlGitPush"

                    $response = $null
                    try{
                        # Send a POST request to the API endpoint to create a new branch
                        $response = Invoke-RestMethod -Uri $apiUrlGitPush -Method Post -Headers @{
                            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
                            "Content-Type" = "application/json"
                        } -Body $gitPushBody
                    }
                    catch {
                        Write-Host "Error while posting Git Push to $apiUrlGitPush. Message - $($_.Exception.Message)"
                    }

                    if($response){
                        Write-Host "New branch created with ref name $($response.name) and object ID $($response.objectId)"
                    }
                }
            }else{
                Write-Host "No commits to this repository yet. Initialize this repository before creating new branches"
            }
        }

        return $solutionProjectRepo
}

<#
This function is a child function of Create-Branch.
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
This function is a child function of Create-Branch.
Gets the deployment pipelines content from pipeline repo.
Commits the pipeline files to the solution branch.
#>
function Get-Git-Commit-Changes{
    param(
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [String]$solutionProjectName,
        [Parameter(Mandatory)] [String]$solutionRepositoryName, 
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$environmentName,
        [Parameter(Mandatory)] [String]$sourceBranch
    )

    $commitChange = $null
    $deployPipelineName = "deploy-$environmentName".ToLower()
    $repoTemplatePath = "/$solutionName/$deployPipelineName-$solutionName.yml"
    Write-Host "RepoTemplatePath - $repoTemplatePath"
    $existingPipelineUrl = "$orgUrl$solutionProjectName/_apis/git/repositories/$solutionRepositoryName/items?path=$repoTemplatePath&api-version=6.0&versionDescriptor.versionType=branch&versionDescriptor.version=$sourceBranch"
    Write-Host "ExistingPipelineUrl - $existingPipelineUrl"

    $existingPipelineResponse = $null
    try{
        $existingPipelineResponse = Invoke-RestMethod $existingPipelineUrl -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
    }
    catch {
        Write-Host "Build definition does not exist at $repoTemplatePath. Message - $($_.Exception.Message)"
    }

    if($null -eq $existingPipelineResponse){
        Write-Host "Creating a build definition for $environmentName"
        # Fetch the Template from pipeline Repo
        $deployPipelineName = "build-deploy-$environmentName".ToLower()
        $templatePath = "/Pipelines/$deployPipelineName-SampleSolution.yml"
        $settingsTemplatePath = Get-Value-From-settings $settings "$environmentName-buildtemplate"
        if($null -ne $settingsTemplatePath){
            Write-Host "Template Path mentioned in Settings for $environmentName"
            $templatePath = $settingsTemplatePath
        }
                                    
        Write-Host "Fetching the build pipeline content from - $templatePath"
        # Get the pipeline content from pipeline repo
        $almBuildpipelineUrl = "$orgUrl$buildProjectName/_apis/git/repositories/$buildRepositoryName/items?path=$templatePath&includeContent=true&versionDescriptor.version=$sourceBranch&versionDescriptor.versionType=branch&api-version=5.0"
        Write-Host "ALMBuildpipelineUrl - $almBuildpipelineUrl"
        $almBuildpipelineResponse = $null
        try{
            $almBuildpipelineResponse = Invoke-RestMethod $almBuildpipelineUrl -Method Get -Headers @{
                Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
            }
        }
        catch {
            Write-Host "Pipeline template does not exist at $templatePath. Message - $($_.Exception.Message)"
        }

        if($null -ne $almBuildpipelineResponse){
            Write-Host "Fetched pipeline content for $environmentName"
            # Replace with 'Main' Branch name of Pipeline Build Repository
            $pipelineContent = $almBuildpipelineResponse -replace "BranchContainingTheBuildTemplates", $sourceBranch
            # Replace with 'Build-Templates-Project/Repo'
            $pipelineContent = $pipelineContent -replace "RepositoryContainingTheBuildTemplates", "$buildProjectName/$buildRepositoryName"
            $pipelineContent = $pipelineContent -replace "SampleSolutionName", $solutionName

            $variableGroup = Get-Value-From-settings $settings "$environmentName-variablegroup"
            if($null -ne $variableGroup){
                $pipelineContent = $pipelineContent -replace "alm-accelerator-variable-group", $variableGroup
            }

            #Write-Host "Pipeline content post substitution - $pipelineContent"

            $deployPipelineName = "deploy-$environmentName".ToLower()
            # Create a new commit change
            $commitChange = @{
                changeType = "add"
                item = @{
                    path = "/$solutionName/$deployPipelineName-$solutionName.yml"
                }
                newContent = @{
                    content = "$pipelineContent"
                    contentType = "rawtext"
                }
            }
        }else{
            Write-Host "Unable to fetch pipeline content for $environmentName"
        }
    }

    return $commitChange
}

<#
This function creates the pipeline definitions based on the committed the pipeline files.
A default queue will be set to each Pipeline definitions.
#>
function Update-Build-for-Branch{
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [string]$azdoAuthType,
        [Parameter(Mandatory)] [string]$environmentNames,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [object]$repo,
        [Parameter(Mandatory)] [object]$settings
    )

    Write-Host "Fetching Project Build Definitions"
    $definitions = Get-Project-Build-Definitions "$orgUrl" "$buildProjectName" "$azdoAuthType"
    Write-Host "Retrieving default Queue"
    $defaultAgentQueue = Get-AgentQueueByName "$orgUrl" "$buildProjectName" "$azdoAuthType" "Azure Pipelines"
    if($null -ne $defaultAgentQueue){
        Write-Host "Default queue (Azure Pipelines) is available"
        # If Environment Names not provided, fall back to validation|test|prod.
        if([string]::IsNullOrEmpty($environmentNames)){
            Write-Host "EnvironmentNames not found in Settings. Falling back."
            $environmentNames = "validation|test|prod"
        }

        # Get 'pipelines' content for all environments
        $collEnvironmentNames = $environmentNames.Split('|')
        foreach ($environmentName in $collEnvironmentNames) {
            Invoke-Clone-Build-Settings "$orgUrl" "$buildProjectName" "$settings" $definitions "$environmentName" "$solutionName" $repo "$azdoAuthType" $defaultAgentQueue
        }
    }else{
        Write-Host "'Azure Pipelines' queue Not Found. You will need to set the default queue manually. Please verify the permissions for the user executing this command include access to queues."
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
        [Parameter(Mandatory)] [object]$pipelines,
        [Parameter(Mandatory)] [string]$environmentName,
        [Parameter(Mandatory)] [string]$solutionName,
        [Parameter(Mandatory)] [object]$repo,
        [Parameter(Mandatory)] [string]$azdoAuthType,
        [Parameter(Mandatory)] [object]$defaultAgentQueue
    )

    $destinationBuildName = "deploy-$environmentName".ToLower()
    $destinationBuildName = "$destinationBuildName-$solutionName"
    Write-Host "Looking for DestinationBuildName - $destinationBuildName from the build definitions"

    $destinationBuild = $pipelines.value | Where-Object {$_.name -eq "$destinationBuildName"}

    if($destinationBuild){
        Write-Host "Pipeline already configured for $destinationBuildName. No action needed. Returning"
        return;
    }else{
        # Create new Pipeline
        Update-Build-Definition "$orgUrl" "$buildProjectName" "$settings" "$environmentName" "$solutionName" $repo "$destinationBuildName" "$azdoAuthType" $defaultAgentQueue
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
    [Parameter(Mandatory)] [object]$defaultAgentQueue
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

    Write-Host "Creating a new pipleine $destinationBuildName"
    $pipelinDefinitionBody = @{
        name = "$destinationBuildName"
        repository = @{
            id = $($repo.id)
            name = $($repo.name)
            url = $($repo.url)
            type = "TfsGit"
            defaultBranch = "refs/heads/$solutionName"
            clean = $null
            checkoutSubmodules = $false
        }
        quality = "definition"
        path = "/$solutionName"
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

    #$jsonBody = $body | ConvertTo-Json
    $jsonBody = $pipelinDefinitionBody | ConvertTo-Json
    # For some reason nested array not parsing properly
    # Logic to convert String to array
    $jsonBodyCleansed = $jsonBody -replace """branchFilters"":  ""main""","""branchFilters"":  [""main""]" 
    Write-Host "Cleansed Body $jsonBodyCleansed"

    $uriBuildDefinition = "$orgUrl$buildProjectName/_apis/build/definitions?api-version=6.0"
    Write-Host "Create Definition URI - $uriBuildDefinition"
    #Write-Host "The pipeline is running under the user: " $env:BUILD_REQUESTEDFOR
    
    try{
        # Send a POST request to the API endpoint to create a new branch
        $headers = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $env:SYSTEM_ACCESSTOKEN"
        }

        $buildDefinitionResponse = Invoke-RestMethod -Uri $uriBuildDefinition -Method Post -Headers $headers -Body $jsonBodyCleansed
        Write-Host "Pipeline definition created successfully."
        $buildDefinitionResponseJson = $buildDefinitionResponse | ConvertTo-Json 
        Write-Host "BuildDefinitionResponseJson - $buildDefinitionResponseJson"
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
Fetches the build definitions under the projects
#>
function Get-Project-Build-Definitions {
    param (
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$buildProjectName,
        [Parameter(Mandatory)] [string]$azdoAuthType
    )

    $buildDefinitionResponse = $null
    $uriBuildDefinition = "$orgUrl$buildProjectName/_apis/build/definitions?api-version=6.0"
    #Write-Host "UriBuildDefinition - $uriBuildDefinition"
    try {
        $buildDefinitionResponse = Invoke-RestMethod $uriBuildDefinition -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
    }
    catch {
        Write-Error $_.Exception.Message
        return
    }

    #Write-Host "Build Definition Response - $buildDefinitionResponse"
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
        [Parameter(Mandatory)] [object]$settings
    )

    Write-Host "Fetching Project Build Definitions to set the policy"
    $policyTypes = Get-Policy-Types "$orgUrl" "$solutionProjectName" "$azdoAuthType"
    # Check if a Policy Type by name 'Build' exists.
    $buildTypes = $policyTypes.value | Where-Object { $_.displayName -eq "Build" }
    if($buildTypes){
        # Get existing Policy configurations
        $uriPolicyConfigs = "$orgUrl$solutionProjectName/_apis/policy/configurations?api-version=6.0"
        #Write-Host "UriPolicyConfigs - $uriPolicyConfigs"
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
        #Write-Host "Policy Configuration Response - $policyConfigResponse"
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
        $builds = Get-Project-Build-Definitions "$orgUrl" "$solutionProjectName" "$azdoAuthType"

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

    $policyTypesResponse = $null    
    $uriPolicyTypes = "$orgUrl$buildProjectName/_apis/policy/types?api-version=6.0-preview.1"
    #Write-Host "UriPolicyTypes - $uriPolicyTypes"
    try {
        $policyTypesResponse = Invoke-RestMethod $uriPolicyTypes -Method Get -Headers @{
            Authorization = "$azdoAuthType  $env:SYSTEM_ACCESSTOKEN"
        }
    }
    catch {
        Write-Error $_.Exception.Message
        return
    }

    #Write-Host "Policy Types Response - $policyTypesResponse"
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