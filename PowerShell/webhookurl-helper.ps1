function Update-WebHookUrls {
    param (
        [Parameter()] [String]$dataverseConnectionString,
        [Parameter()] [String]$serviceConnection,
        [Parameter()] [String]$microsoftXrmDataPowerShellModule,
        [Parameter()] [String]$xrmDataPowerShellVersion,
        [Parameter()] [String]$webHookConfiguration,
        [Parameter()] [String]$token
    )
	if($webHookConfiguration -ne ''){
        Write-Host "Importing PowerShell Module: $microsoftXrmDataPowerShellModule - $xrmDataPowerShellVersion"
        Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $xrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }

        $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

        . "$env:POWERSHELLPATH/dataverse-webapi-functions.ps1"
        $dataverseHost = Get-HostFromUrl "$serviceConnection"
        Write-Host "dataverseHost - $dataverseHost"

        Write-Host "webHookConfiguration - $webHookConfiguration"
        $webHookConfigCollection = Get-WebHookConfigurations $webHookConfiguration

        foreach ($configuration in $webHookConfigCollection) {
            # Retrieve Service End Point
            if ($null -ne $configuration.SchemaName) {
                Write-Host "Fetching Service endpoint by Name - " $configuration.SchemaName
                $serviceEndPointId = Get-Service-Endpoint-By-Name $configuration.SchemaName $token $dataverseHost

                if($serviceEndPointId -ne -1){
                    Write-Host "Updating serviceendpoint URL to - "$configuration.Value
                    Set-CrmRecord -conn $conn -EntityLogicalName serviceendpoint -Id $serviceEndPointId -Fields @{ "url" = $configuration.Value }
                }
            }
        }
    }
}

function Get-Service-Endpoint-By-Name{
 param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$endPointName,        
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$token,        
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$dataverseHost        
    )
        $serviceEndPointId = -1
        # Check current status of workflow
        $queryServiceEndPoint = "serviceendpoints?`$select=url&`$filter=(name eq '$endPointName')"    

        try{
            Write-Host "Service End Point Query - $queryServiceEndPoint"
            $serviceEndPointResponse = Invoke-DataverseHttpGet $token $dataverseHost $queryServiceEndPoint
        }
        catch{
            Write-Host "Error $queryServiceEndPoint - $($_.Exception.Message)"
        }

        if($null -ne $serviceEndPointResponse.value -and $serviceEndPointResponse.value.count -gt 0){
            $serviceEndPointId = $serviceEndPointResponse.value[0].serviceendpointid
            Write-Host "Service End Point Id is $serviceEndPointId"
        }

        return $serviceEndPointId
}

function Get-WebHookConfigurations {
    param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$activateFlowConfiguration
    )
    $activationConfigs = $null
    if ($activateFlowConfiguration -ne "") {
        $activationConfigs = Get-Content $activateFlowConfiguration | ConvertFrom-Json
    }

    return $activationConfigs
}