<#
This marks the pipeline deployment stage run as succeeded or failed.
#>
function Invoke-Pre-Deployment-Status-Update{
    param (
        [Parameter(Mandatory)] [String]$pipelineStageRunId,
        [Parameter(Mandatory)] [String]$stageStatus,
        [Parameter(Mandatory)] [String]$pipelineServiceConnectionUrl,
        [Parameter(Mandatory)] [String]$aadHost,
        [Parameter(Mandatory)] [String]$tenantId,
        [Parameter(Mandatory)] [String]$applicationId,
        [Parameter(Mandatory)] [String]$clientSecret
    )
    . "$env:POWERSHELLPATH/dataverse-webapi-functions.ps1"
    $dataverseHost = Get-HostFromUrl "$pipelineServiceConnectionUrl"
    $spnToken = Get-SpnToken "$tenantId" "$applicationId" "$clientSecret" "$dataverseHost" "$aadHost"

    # Set up the request body
    $requestBody = @{
        StageRunId = "$pipelineStageRunId"
        PreDeploymentStepStatus = "$stageStatus"
    }
    $jsonBody = $requestBody | ConvertTo-Json

    Invoke-DataverseHttpPost "$spnToken" "$dataverseHost" "UpdatePreDeploymentStepStatus" "$jsonBody"
}
<#
Creates a new Pull Request based on the source and target branches and conditionally auto completes it.
#>
function New-Pull-Request {
    param (
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$org,
        [Parameter(Mandatory)] [String]$project,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$branch,
        [Parameter(Mandatory)] [String]$sourceBranch,
        [Parameter(Mandatory)] [String]$targetBranch,
        [Parameter(Mandatory)][AllowEmptyString()] [String]$encodedCommitMessage,
        [Parameter(Mandatory)] [String]$autocompletePR,
        [Parameter(Mandatory)] [String]$accessToken
    )
    . "$env:POWERSHELLPATH/util.ps1"
    Write-Host "Source Branch: $sourceBranch"
    if("$sourceBranch" -match "Commit to existing branch specified in Branch parameter") {
      $sourceBranch = "refs/heads/$branch"
    }
    Write-Host "Source Branch: $sourceBranch"

    # Check for existing active PR for the branch and repo
    $uri = "$org/$project/_apis/git/pullrequests?searchCriteria.repositoryId=$repo&searchCriteria.sourceRefName=$sourceBranch&searchCriteria.status=active&searchCriteria.targetRefName=$targetBranch&api-version=7.0"
    $response = Invoke-RestMethod $uri -Method Get -Headers @{
        Authorization = "Bearer $accessToken"
    }
    if($response.value.length -eq 0) {
      # Define API endpoint
      $uri = "$org/$project/_apis/git/repositories/$repo/pullrequests?api-version=6.0"

      # Define request body
      $body = @{
          sourceRefName = "$sourceBranch";
          targetRefName = "$targetBranch";
          title = "$solutionName - Deployment Approval Pull Request";
          description = $encodedCommitMessage
      } | ConvertTo-Json

      Write-Host "Body: $body"
      
      # Send API request
      $createPRResponse = Invoke-RestMethod -Uri $uri -Method Post -Headers @{
          Authorization = "Bearer $accessToken"
          "Content-Type" = "application/json; charset=utf-8"
      } -Body $body

      if("$autocompletePR" -eq "true") {
        # Define API endpoint for update
        $uri = "$org/$project/_apis/git/repositories/$repo/pullrequests/" + $createPRResponse.pullRequestId + "?api-version=6.0"

        Write-Host $uri
        # Set the PR to auto-complete
        $body = @{
            autoCompleteSetBy = @{
                id = $createPRResponse.createdBy.id
            }
            completionOptions = @{
                deleteSourceBranch = $true
                bypassPolicy = $false
            }
        } | ConvertTo-Json

        Write-Host $body
        Invoke-RestMethod -Uri $uri -Method Patch -Headers @{
            Authorization = "Bearer $accessToken"
            "Content-Type" = "application/json"
        } -Body $body
      }
    }
}