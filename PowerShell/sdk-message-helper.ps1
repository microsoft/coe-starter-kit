<#
This function reads the pipeline message steps configuration available in deployment settings.
Creates or updates the unsecured or secured records in Dataverse.
#>
function Update-Sdk-Message-Configurations {
    param (
        [Parameter()] [String]$dataverseConnectionString,
        [Parameter()] [String]$serviceConnection,
        [Parameter()] [String]$microsoftXrmDataPowerShellModule,
        [Parameter()] [String]$xrmDataPowerShellVersion,
        [Parameter()] [String]$sdkMessageConfiguration,
        [Parameter()] [String]$token
    )
    try{
	    if($sdkMessageConfiguration -ne ''){
            Write-Host "Importing PowerShell Module: $microsoftXrmDataPowerShellModule - $xrmDataPowerShellVersion"
            Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $xrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }

            $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

            . "$env:POWERSHELLPATH/dataverse-webapi-functions.ps1"
            $dataverseHost = Get-HostFromUrl "$serviceConnection"
            Write-Host "dataverseHost - $dataverseHost"

            Write-Host "sdkMessageConfiguration - $sdkMessageConfiguration"
            $sdkMessageConfigCollection = Get-SdkMessageConfiguration $sdkMessageConfiguration

            foreach ($configuration in $sdkMessageConfigCollection) {
                # Retrieve SDK Message Config
                if ($null -ne $configuration.Config) {
                    Write-Host "SDK Message Config - " $configuration.Config

                    # Split the string into two parts using the "." delimiter
                    $parts = $($configuration.Config).Split(".")
                    if ($parts.Count -eq 2){
                        # Config type will be either 'sec' or 'unsec'
                        $configType = $parts[0]

                        # The second part will be the sdkmessageprocessingstepid
                        $sdkMessageStepId = $parts[1]

                        #Fetch the sdkMessageStep record from Dataverse
                        $sdkMessageStep = Get-SDK-Message-Processing-Step-By-Id $sdkMessageStepId $token $dataverseHost

                        if($sdkMessageStepId -ne $null){
                            # If its unsecured configuration update the sdkmessageprocessingstep record.
                            if($configType -eq "unsec"){
                                Write-Host "Updating unsecured configuration to - "$configuration.Value
                                Set-CrmRecord -conn $conn -EntityLogicalName "sdkmessageprocessingstep" -Id $sdkMessageStepId -Fields @{ "configuration" = $configuration.Value }
                            }
                            elseif($configType -eq "sec"){
                                # For secured configuration, first check if 'sdkmessageprocessingstepsecureconfig' already presents
                                if($sdkMessageStep.sdkmessageprocessingstepsecureconfigid){
                                    Write-Host "SDK Message Step already having secureconfig id - "$sdkMessageStep.sdkmessageprocessingstepsecureconfigid
                                    Write-Host "Updating the 'secureconfig' field of sdkmessageprocessingstepsecureconfig."
                                    Set-CrmRecord -conn $conn -EntityLogicalName sdkmessageprocessingstepsecureconfig -Id $sdkMessageStep.sdkmessageprocessingstepsecureconfigid -Fields @{"secureconfig"="$($configuration.Value)";}
                                }else{
                                   # Create a new sdkmessageprocessingstepsecureconfig record
                                   Write-Host "SDK Message Step does not have secureconfig."
                                   Write-Host "Creating a new sdkmessageprocessingstepsecureconfig record."
                                   $securedConfigReferenceId = New-CrmRecord -conn $conn -EntityLogicalName sdkmessageprocessingstepsecureconfig -Fields @{"secureconfig"="$($configuration.Value)";}
                                   $securedConfigReference = New-CrmEntityReference -EntityLogicalName sdkmessageprocessingstepsecureconfig -Id $securedConfigReferenceId
                                   Write-Host "Updating the sdkmessageprocessingstepsecureconfigid field of sdkmessageprocessingstep with the newly created sdkmessageprocessingstepsecureconfig record"
                                   # Set sdkmessageprocessingstepsecureconfigid look up to newly created  $securedConfigReference
                                   Set-CrmRecord -conn $conn -EntityLogicalName "sdkmessageprocessingstep" -Id $sdkMessageStepId -Fields @{ "sdkmessageprocessingstepsecureconfigid" = $securedConfigReference }
                                }
                            }
                        }else{
                            Write-Host "No sdk message step record found with Id - $sdkMessageStepId"
                        }
                    }else{
                        Write-Host "Invalid configuration. $($configuration.Config)"
                    }
                }
            }
        }
    }
    catch{
        Write-Host "Error in Update-Sdk-Message-Configurations - $($_.Exception.Message)"
    }
}

<#
This function fetches the unsecured or secured records in Dataverse.
#>
function Get-SDK-Message-Processing-Step-By-Id{
 param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$sdkMessageStepId,        
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$token,        
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$dataverseHost        
    )
        $sdkMessageStep = $null
        # Fetch SDK Message Processing Step Record
        $querySDKMessageStep = "sdkmessageprocessingsteps?`$select=configuration,sdkmessageprocessingstepsecureconfigid&`$filter=(sdkmessageprocessingstepid eq '$sdkMessageStepId')"    

        try{
            Write-Host "SDK Message Step Query - $querySDKMessageStep"
            $sdkMessageStepResponse = Invoke-DataverseHttpGet $token $dataverseHost $querySDKMessageStep
        }
        catch{
            Write-Host "Error $querySDKMessageStep - $($_.Exception.Message)"
        }

        if($null -ne $sdkMessageStepResponse.value -and $sdkMessageStepResponse.value.count -gt 0){
            $sdkMessageStep = $sdkMessageStepResponse.value[0]
        }

        return $sdkMessageStep
}

<#
This function converts the SDK Message Configurations to json object.
#>
function Get-SdkMessageConfiguration {
    param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$sdkMessageConfiguration
    )
    $sdkMessageConfigs = $null
    if ($sdkMessageConfiguration -ne "") {
        $sdkMessageConfigs = Get-Content $sdkMessageConfiguration | ConvertFrom-Json
    }

    return $sdkMessageConfigs
}