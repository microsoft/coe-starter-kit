<#
This function returns the Access Token.
Testable outside of agent
#>
function Get-SpnToken {
    param (
        [Parameter(Mandatory)] [String]$tenantId,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$aadHost
    )
    $body = @{client_id = $clientId; client_secret = $clientSecret; grant_type = "client_credentials"; scope = "https://$dataverseHost/.default"; }
    $OAuthReq = Invoke-RestMethod -Method Post -Uri "https://$aadHost/$tenantId/oauth2/v2.0/token" -Body $body

    return $OAuthReq.access_token
}

<#
This function splits the environment url and returns the Host.
#>
function Get-HostFromUrl {
    param (
        [Parameter(Mandatory)] [String]$url
    )
    $options = [System.StringSplitOptions]::RemoveEmptyEntries
    return $url.Split("://", $options)[1].Split("/")[0]
}

<#
This function reads the Spn Token and sets SpnToken variable.
#>
function Set-SpnTokenVariableWithinAgent {    
    param (
        [Parameter(Mandatory)] [String]$tenantId,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$serviceConnection,
        [Parameter(Mandatory)] [String]$aadHost
    )
    $dataverseHost = Get-HostFromUrl $serviceConnection
      
    $spnToken = Get-SpnToken $tenantId $clientId $clientSecret $dataverseHost $aadHost

    Write-Host "##vso[task.setvariable variable=SpnToken;issecret=true]$spnToken"
}

<#
This function sets the header parameters.
#>
function Set-DefaultHeaders {
    param (
        [Parameter(Mandatory)] [String]$token
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")
    $headers.Add("Content-Type", "application/json")
    return $headers
}

<#
This function sets the url by joining the host url and requestUrlRemainder.
#>
function Set-RequestUrl {
    param (
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$requestUrlRemainder
    )
    $requestUrl = "https://$dataverseHost/api/data/v9.2/$requestUrlRemainder"
    return $requestUrl    
}

<#
This function invokes Dataverse web api GET.
#>
function Invoke-DataverseHttpGet {
    param (
        [Parameter(Mandatory)] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$requestUrlRemainder
    )
    $headers = Set-DefaultHeaders $token
    $requestUrl = Set-RequestUrl $dataverseHost $requestUrlRemainder
    $response = Invoke-RestMethod $requestUrl -Method 'GET' -Headers $headers
    return $response
}

<#
This function invokes Dataverse web api POST.
#>
function Invoke-DataverseHttpPost {
    param (
        [Parameter(Mandatory)] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$requestUrlRemainder,
        [Parameter(Mandatory)] [String]$body
    )
    $headers = Set-DefaultHeaders $token
    $requestUrl = Set-RequestUrl $dataverseHost $requestUrlRemainder
    $response = Invoke-RestMethod $requestUrl -Method 'POST' -Headers $headers -Body $body
    return $response
}

<#
This function triggers to download the unmanaged and managed solution pipeline artifacts.
#>
function Invoke-Download-Solution-Artifact{
    param (
        [Parameter(Mandatory)] [String]$pipelineConnectionUrl,
        [Parameter(Mandatory)] [String]$aadHost,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$tenantID,
        [Parameter(Mandatory)] [String]$solutionZipDirectory,
        [Parameter(Mandatory)] [String]$repo,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$artifactUrl
    )
	
    #Download the unmanaged and managed solution zips
    $dataverseHost = Get-HostFromUrl "$pipelineConnectionUrl"
    $spnToken = Get-SpnToken "$tenantID" "$clientId" "$clientSecret" "$dataverseHost" "$aadHost"

    $headers = Set-DefaultHeaders $spnToken
    $response = Invoke-RestMethod $artifactUrl -Method 'GET' -Headers $headers   

    $bytes = [Convert]::FromBase64String($response.value)
    [IO.File]::WriteAllBytes("$solutionZipDirectory\$solutionName" + "_managed.zip", $bytes)

    $unmanagedArtifactUrl = "$artifactUrl".Replace("artifactfile", "artifactfileunmanaged")
    $response = Invoke-RestMethod "$unmanagedArtifactUrl" -Method 'GET' -Headers $headers
    $bytes = [Convert]::FromBase64String($response.value)
    [IO.File]::WriteAllBytes("$solutionZipDirectory\$solutionName.zip", $bytes)
}
