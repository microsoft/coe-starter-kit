function Set-TriggerSolutionUpgrade
{
    param (
        [Parameter(Mandatory)] [String]$triggerSolutionUpgrade,
        [Parameter(Mandatory)] [String]$orgUrl,
        [Parameter(Mandatory)] [String]$projectid,
        [Parameter(Mandatory)] [String]$buildRepositoryName,
        [Parameter(Mandatory)] [String]$buildRepositoryProvider,
        [Parameter(Mandatory)] [String]$buildSourceVersion,
        [Parameter(Mandatory)] [String]$buildReason,
        [Parameter(Mandatory)] [String]$gitHubRepo,
        [Parameter(Mandatory)] [String]$gitHubPat
    )

  Write-Output "##vso[task.setvariable variable=TriggerSolutionUpgrade;isOutput=true]false"
  $solutionUpgradeLabel = "solution-upgrade"

  $triggerSolutionUpgradeVariableSupplied = !$triggerSolutionUpgrade.Contains("TriggerSolutionUpgrade")

  # If the TriggerSolutionUpgrade variable is set at queue time, then override the logic to determine solution upgrade based on PR label of solution-upgrade
  if ($triggerSolutionUpgradeVariableSupplied) {
    Write-Output "##vso[task.setvariable variable=TriggerSolutionUpgrade;isOutput=true]$triggerSolutionUpgrade"
  }
  else {
    # In order to determine if we need to perform a Solution Upgrade, we see if the Pull Request has a label of solution-upgrade on it.
    # The only way we know how to determine if the PR that created the commit for the branch had a label is to use the REST API
    if ($buildReason -ne "PullRequest") { 
      Write-Host "Build.Repository.Provider is $buildRepositoryProvider"

      if ("$buildRepositoryProvider" -eq "TfsGit") {      
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $env:SYSTEM_ACCESSTOKEN")
        $headers.Add("Content-Type", "application/json")

        $pullrequestqueryBody = @"
        {
            "queries": [{
                "items": [
                    "$buildSourceVersion"
                ],
                "type": "lastMergeCommit"
            }]
        }
"@ 

        Write-Host "pullrequestqueryBody - " $pullrequestqueryBody
        $pullrequestqueryBodyResourceUrl = "$orgUrl$projectid/_apis/git/repositories/$buildRepositoryName/pullrequestquery?api-version=6.0"
        $pullrequestqueryResponse = Invoke-RestMethod $pullrequestqueryBodyResourceUrl -Method 'POST' -Headers $headers -Body $pullrequestqueryBody
        $pullrequestqueryResponseResults = $pullrequestqueryResponse.results
        $pullRequestId = $pullrequestqueryResponseResults.$buildSourceVersion.pullRequestId

        Write-Host "pullRequestId - " $pullRequestId
        if (-not [string]::IsNullOrEmpty($pullRequestId)) {
          $pullRequestLabelQuery = "$orgUrl$projectid/_apis/git/repositories/$buildRepositoryName/pullRequests/$pullRequestId/labels?api-version=6.0"
        
        $pullRequestLabelQueryResponse = Invoke-RestMethod -Uri $pullRequestLabelQuery -Method 'GET' -Headers $headers
          $pullRequestLabelQueryResponseValue = $pullRequestLabelQueryResponse.value

          if ($pullRequestLabelQueryResponseValue.Count -gt 0) {
            $triggerSolutionUpgrade = $pullRequestLabelQueryResponseValue.name.Contains($solutionUpgradeLabel).ToString().ToLower()
            Write-Host "Post Label Fetch; triggerSolutionUpgrade - " $triggerSolutionUpgrade
            Write-Output "##vso[task.setvariable variable=TriggerSolutionUpgrade;isOutput=true]$triggerSolutionUpgrade"
          }
        }
      }
        
      if ("$buildRepositoryProvider" -eq "GitHub") {
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Accept", "application/vnd.github.groot-preview+json")
        $headers.Add("Authorization", "Bearer $gitHubPat")
          
        Write-Host "Build.SourceVersion is $buildSourceVersion"

        $pullsRequest = "https://api.github.com/repos/$gitHubRepo/commits/$buildSourceVersion/pulls"
          
        $pullsResponse = Invoke-RestMethod $pullsRequest -Method 'GET' -Headers $headers
          
        if ($pullsResponse.Count -gt 0) {
          $pullNumber = $pullsResponse[0].number
          $issuesRequest = "https://api.github.com/repos/$gitHubRepo/issues/$pullNumber"
          $issuesResponse = Invoke-RestMethod $issuesRequest -Method 'GET' -Headers $headers 
            
          if ($issuesResponse.labels.Count -gt 0) {
            $triggerSolutionUpgrade = $issuesResponse.labels.name.Contains($solutionUpgradeLabel).ToString().ToLower()
            Write-Output "##vso[task.setvariable variable=TriggerSolutionUpgrade;isOutput=true]$triggerSolutionUpgrade"
          }
        }
      }
    }
  }
}