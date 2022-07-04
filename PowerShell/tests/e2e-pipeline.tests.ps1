# e2e pipeline test using az cli to run full inner/outer loop on pipelines

# NOTE: Couldn't use az cli to queue the export-to-git pipeline because we were getting
# 'The command line is too long' when sending the json to the Data parameter.
# So I wrote Invoke-ExportToGit function using the REST API

# TODO: 
# Complete inner/outer loop tests
# -PR into main from solution/vnext branch and detect whether prod deployment pipeline succeeded
#   -Test solution ugrade
# -Add test for brand new solution
# Document how to setup inner loop / personal files for local testing in the PowerShell/Ignore folder

# param(
#     $Org, $Project, $BranchToTest, $SourceBranch, $BranchToCreate, $CommitMessage, $Data, 
#     $Email, $Repo, $ServiceConnectionName, $ServiceConnectionUrl, $SolutionName, $UserName
# )

param(
    $Org, $Project, $BranchToTest, $SourceBranch, $BranchToCreate, $CommitMessage, $Data, 
    $Email, $Repo, $ServiceConnection, $SolutionName, $UserName
)

class Helper {
    static [string]$AccessToken
    static [bool]$ExportToGitNewBranchSucceeded = $false
    static [bool]$ExportToGitExistingBranchSucceeded = $false

    static [bool]WaitForPipelineToComplete ($org, $project, $id) {
        $result = @{status = "" }
        while ($result.status -ne 'completed') {
            Start-Sleep -Seconds 15
            $result = az pipelines runs show --id $id --org $org --project $project
            $result = $result | ConvertFrom-Json -Depth 10
        }
    
        return $result.result -eq 'succeeded' -or $result.result -eq 'partiallySucceeded' 
    }

    static [void]WriteTestMessageToHost($testName) {
        $timestamp = Get-Date -Format hh:mm:ss
        Write-Host "$timestamp - Running $testName..."
    }

    static [bool]QueueExportToGit($org, $project, $body) {        
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $token = [Helper]::AccessToken
        $headers.Add("Authorization", "Bearer $token")
        $headers.Add("Content-Type", "application/json")
        $apiVersion = "?api-version=7.0"

        $requestUrl = "$org/$project/_apis/pipelines$apiVersion"
        $response = Invoke-RestMethod $requestUrl -Method 'GET' -Headers $headers
        $response | ConvertTo-Json -Depth 10

        $pipelineId = 0;

        foreach ($pipeline in $response.value) {
            if ($pipeline.name -eq "export-solution-to-git") {
                $pipelineId = $pipeline.id
                break
            }
        }        

        $body.templateParameters.PipelineId = $pipelineId
        $body = ConvertTo-Json -Depth 10 $body -Compress

        $requestUrl = "$org/$project/_apis/pipelines/$pipelineId/runs$apiVersion"
        # Write-Host $requestUrl
        # Write-Host $body
        $response = Invoke-RestMethod $requestUrl -Method 'POST' -Headers $headers -Body $body
        $response | ConvertTo-Json -Depth 10

        $id = $response.id
        return [Helper]::WaitForPipelineToComplete($org, $project, $id)
    }
}

BeforeAll { 
    [Helper]::AccessToken = (az account get-access-token | ConvertFrom-Json -Depth 10).accessToken    
}

Describe 'E2E-Pipeline-Test' {
    # Hard coding test name intentionally.  Pester doesn't like it when it's a variable.
    # TODO: Investigate why pester doesn't like it when it's a variable and come up with a better way to do this.
    It 'ImportUnamanagedToDevEnvironment' -Tag 'ImportUnamanagedToDevEnvironment' {
        [Helper]::WriteTestMessageToHost('ImportUnamanagedToDevEnvironment')
        
        # hacky/brittle
        # and depends on the fact that the service connection name is the environment url
        # and that the environment name is the same as the first part of the environment url
        $environmentName = $ServiceConnection.Replace('https://', '').Replace('.crm.dynamics.com/', '')

        $result = az pipelines run --org $Org --project $Project --branch $BranchToTest `
            --name 'import-unmanaged-to-dev-environment' `
            --parameters `
            Branch=$SolutionName `
            CommitMessage='NA' `
            Email=$Email `
            Project=$Project `
            Repo=$Repo `
            ServiceConnectionName=$ServiceConnection `
            ServiceConnectionUrl=$ServiceConnection `
            SolutionName=$SolutionName `
            UserName=$UserName `
            EnvironmentName=$environmentName
        $result = $result | ConvertFrom-Json -Depth 10
        $id = $result.id
        [Helper]::WaitForPipelineToComplete($Org, $Project, $id) | Should -BeTrue
    }

    # Hard coding test name intentionally.  Pester doesn't like it when it's a variable.
    # TODO: Investigate why pester doesn't like it when it's a variable and come up with a better way to do this.
    It 'ExportToGitNewBranch' -Tag 'ExportToGitNewBranch' {
        [Helper]::WriteTestMessageToHost('ExportToGitNewBranch')        

        $body = @{
            resources          = @{
                repositories = @{
                    self = @{
                        refName = $BranchToTest
                    }
                }
            }
            templateParameters = @{
                Branch            = $SourceBranch
                BranchToCreate    = $BranchToCreate
                CommitMessage     = $CommitMessage
                Data              = $Data
                Email             = $Email
                Project           = $Project
                Repo              = $Repo
                ServiceConnectionName = $ServiceConnection
                ServiceConnectionUrl = $ServiceConnection
                SolutionName      = $SolutionName
                UserName          = $UserName
                PipelineId        = 0
            } 
        }
        [Helper]::ExportToGitNewBranchSucceeded = [Helper]::QueueExportToGit($Org, $Project, $body)
        [Helper]::ExportToGitNewBranchSucceeded | Should -BeTrue
    }    

    # Hard coding test name intentionally.  Pester doesn't like it when it's a variable.
    # TODO: Investigate why pester doesn't like it when it's a variable and come up with a better way to do this.
    It 'ExportToGitExistingBranch' -Tag 'ExportToGitExistingBranch' {
        if ([Helper]::ExportToGitNewBranchSucceeded -ne $true) {
            Set-ItResult -Skipped -Because "ExportToGitNewBranchSucceeded did not succeed"
        }
        
        [Helper]::WriteTestMessageToHost('ExportToGitExistingBranch')  
        
        # set branch to use for second commit to existing branch previously created
        $branchToUse = $BranchToCreate
    
        $body = @{
            resources          = @{
                repositories = @{
                    self = @{
                        refName = $BranchToTest
                    }
                }
            }
            templateParameters = @{
                Branch            = $branchToUse
                CommitMessage     = $CommitMessage + " existing branch"
                Data              = $Data
                Email             = $Email
                Project           = $Project
                Repo              = $Repo
                ServiceConnectionName = $ServiceConnection
                ServiceConnectionUrl = $ServiceConnection
                SolutionName      = $SolutionName
                UserName          = $UserName
                PipelineId        = 0
            } 
        }
    
        [Helper]::ExportToGitExistingBranchSucceeded = [Helper]::QueueExportToGit($Org, $Project, $body)
        [Helper]::ExportToGitExistingBranchSucceeded | Should -BeTrue
    }
    
    # Hard coding test name intentionally.  Pester doesn't like it when it's a variable.
    # TODO: Investigate why pester doesn't like it when it's a variable and come up with a better way to do this.
    It 'CreatePullRequestForUATWaitForPRValidationToSucceedApproveAndMerge' -Tag 'CreatePullRequestForUATWaitForPRValidationToSucceedApproveAndMerge' {
        if ([Helper]::ExportToGitExistingBranchSucceeded -ne $true) {
            Set-ItResult -Skipped -Because "ExportToGitExistingBranchSucceeded did not succeed"
        }

        [Helper]::WriteTestMessageToHost('CreatePullRequestForUATWaitForPRValidationToSucceedApproveAndMerge')

        # Before we create the PR, we need to update the pipeline yml to use the branch containing the yml we want to test
        $result = az pipelines run --org $Org --project $Project --name update-ref-for-pr-loop --variables BranchToUpdate=$BranchToCreate TemplateBranch=$BranchToTest
        Start-Sleep -Seconds 15

        # Create PR for the branch we committed/pushed to
        $result = az repos pr create --org $Org --project $Project --repository $Repo --source-branch $BranchToCreate --target-branch $SolutionName --title "E2E-Pipeline-Test"
        $result = $result | ConvertFrom-Json -Depth 10
        $result.status | Should -Be 'active'
        
        # Get the id of the PR validation pipeline using the PR id and wait for it to successfully complete
        $pullRequestId = $result.pullRequestId
        # sleep for 15 seconds to ensure the pipeline to validate the PR is kicked off (may need to tweak)
        Start-Sleep -Seconds 15
        $result = az pipelines runs list --org $Org --project $Project --branch "refs/pull/$pullRequestId/merge"
        $result = $result | ConvertFrom-Json -Depth 10
        $id = $result[0].id
        [Helper]::WaitForPipelineToComplete($Org, $Project, $id) | Should -BeTrue

        # Approve the PR, complete, squash merge, and delete source branch
        az repos pr set-vote --id $pullRequestId --org $Org --vote approve
        az repos pr update --id $pullRequestId --org $Org --status completed --squash true  --merge-commit-message $CommitMessage --delete-source-branch true
        # sleep for 15 seconds to ensure the pipeline to deploy to UAT environment is kicked off (may need to tweak)
        Start-Sleep -Seconds 15
        # Get the id of the pipeline to deploy to UAT and wait for it to successfully complete
        # TODO: See if we can improve the query below to be more precise.  Works when there isn't another pipeline running triggered from the same solution branch
        $result = az pipelines runs list --org $Org --project $Project --branch $SolutionName --top 1 --reason individualCI --query-order QueueTimeDesc
        $result = $result | ConvertFrom-Json -Depth 10
        $id = $result[0].id
        [Helper]::WaitForPipelineToComplete($Org, $Project, $id) | Should -BeTrue
    }
    
    # Hard coding test name intentionally.  Pester doesn't like it when it's a variable.
    # TODO: Investigate why pester doesn't like it when it's a variable and come up with a better way to do this.
    It 'DeleteUnamangedSolutionAndComponents' -Tag 'DeleteUnamangedSolutionAndComponents' {
        [Helper]::WriteTestMessageToHost('DeleteUnamangedSolutionAndComponents')
        
        $result = az pipelines run --org $Org --project $Project --branch $BranchToTest `
            --name 'delete-unmanaged-solution-and-components' `
            --parameters `
            Branch=$SolutionName `
            CommitMessage='NA' `
            Email=$Email `
            Project=$Project `
            Repo=$Repo `
            ServiceConnectionName=$ServiceConnection `
            ServiceConnectionUrl=$ServiceConnection `
            SolutionName=$SolutionName `
            UserName=$UserName
        $result = $result | ConvertFrom-Json -Depth 10
        $id = $result.id
        [Helper]::WaitForPipelineToComplete($Org, $Project, $id) | Should -BeTrue
    }    
}