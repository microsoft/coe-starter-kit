<#
This function loads the PowerAppsLanguageTooling dll.
Either packs or unpacks the canvas app based on the packOrUnpack parameter.
#>
function Invoke-CanvasUnpackPack {
    param (
        [Parameter(Mandatory)] [String]$packOrUnpack,
        [Parameter(Mandatory)] [String]$source,
        [Parameter(Mandatory)] [String]$destination
    )
    Write-Host "Loading Assemblies"
    Get-ChildItem -Path "..\PowerAppsLanguageTooling\" -Recurse -Filter *.dll | 
    ForEach-Object {
        [System.Reflection.Assembly]::LoadFrom($_.FullName)
    }
    
    if ($packOrUnpack -eq 'pack') {
        Write-Host "Packing $source to $destination"
        $results = [Microsoft.PowerPlatform.Formulas.Tools.CanvasDocument]::LoadFromSources($source)
        if($results.HasErrors) {
            throw $results.Item2.ToString();
            return
        } else {
            Write-Host $results.Item2.ToString()
        }
        $saveResults = $results.Item1.SaveToMsApp($destination)
        if($saveResults.HasErrors) {
            throw $saveResults.ToString();
            return
        } 
        else {
            Write-Host $saveResults.ToString()
        }
    }
    else {
        if ($packOrUnpack -eq 'unpack') {
            Write-Host "Unpacking $source to $destination"
            $results = [Microsoft.PowerPlatform.Formulas.Tools.CanvasDocument]::LoadFromMsapp($source)
            if($results.HasErrors) {
                throw $results.Item2.ToString();
                return
            } else {
                Write-Host $results.Item2.ToString()
            }
    
            $saveResults = $results.Item1.SaveToSources($destination)
            if($saveResults.HasErrors) {
                throw $saveResults.ToString();
                return
            } 
            else {
                Write-Host $saveResults.ToString()
            }
        }
        else {
            throw "Invalid packOrUnpack parameter. Must be 'pack' or 'unpack'.";
        }
    }
}

<#
This function reads aadGroupCanvasConfiguration from custom deployment Settings.
Shares the canvas app with AAD group.
#>
function Invoke-Share-Canvas-App-with-AAD-Group
{
    param (
        [Parameter(Mandatory)] [String]$microsoftPowerAppsAdministrationPowerShellModule,
        [Parameter(Mandatory)] [String]$powerAppsAdminModuleVersion,
        [Parameter(Mandatory)] [String]$tenantId,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$microsoftXrmDataPowerShellModule,
        [Parameter(Mandatory)] [String]$XrmDataPowerShellVersion,
        [Parameter(Mandatory)] [String]$serviceConnection,
        [Parameter()] [String]$aadGroupCanvasConfiguration,
        [Parameter(Mandatory)] [String]$environmentId,
        [Parameter(Mandatory)] [String]$dataverseConnectionString
    )
	if($aadGroupCanvasConfiguration -ne '') {
        #$microsoftPowerAppsAdministrationPowerShellModule = '$(CoETools_Microsoft_PowerApps_Administration_PowerShell)'
        Import-Module $microsoftPowerAppsAdministrationPowerShellModule -Force -RequiredVersion $powerAppsAdminModuleVersion -ArgumentList @{ NonInteractive = $true }
        Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $clientId -ClientSecret $clientSecret
        #$microsoftXrmDataPowerShellModule = '$(CoETools_Microsoft_Xrm_Data_PowerShell)'
        Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $XrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }
        $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

        # json config value must follow this format
        #[
        #    {
        #        "aadGroupId": "aad-security-group-guid-1",
        #        "canvasNameInSolution": "pfx_app-name-in-solution-name-1",
        #        "roleName":"CanView or CanViewWithShare or CanEdit" 
        #    },
        #    {
        #        "aadGroupId": "aad-security-group-guid-2",
        #        "canvasNameInSolution": "pfx_app-name-in-solution-name-2",
        #        "roleName":"CanView or CanViewWithShare or CanEdit" 
        #    }
        #]
        $config = Get-Content "$aadGroupCanvasConfiguration" | ConvertFrom-Json

        foreach ($c in $config){
            $aadGroupId = $c.aadGroupId
            $roleName = $c.roleName
            $canvasNameInSolution = $c.canvasNameInSolution     
            if($aadGroupId -ne '' -and $roleName -ne '' -and $canvasNameInSolution -ne '') {
                $canvasApps = Get-CrmRecords -conn $conn -EntityLogicalName canvasapp -FilterAttribute "name" -FilterOperator "eq" -FilterValue $canvasNameInSolution -Fields canvasappid,uniquecanvasappid
                if($canvasApps.Count -gt 0) {
                    $appId = $canvasApps.CrmRecords[0].canvasappid
                    $uniqueCanvasAppId = $canvasApps.CrmRecords[0].uniquecanvasappid
                    Write-Host "AppId - $appId and UniqueCanvasAppId - $uniqueCanvasAppId"

					# 'CanViewWithShare' is no longer works. Replacing with 'CanView'.
                    if($roleName -eq "CanViewWithShare"){
                        $roleName = "CanView"
                    }
                    if($null -ne $uniqueCanvasAppId) {
                        Write-Host "Command Unique Id- Set-AdminPowerAppRoleAssignment -PrincipalType Group -PrincipalObjectId $aadGroupId -RoleName $roleName -AppName $uniqueCanvasAppId -EnvironmentName $environmentId"
                        Set-AdminPowerAppRoleAssignment -PrincipalType Group -PrincipalObjectId $aadGroupId -RoleName $roleName -AppName $uniqueCanvasAppId -EnvironmentName $environmentId
                    }
                    else {
                        Write-Host "Command App Id- Set-AdminPowerAppRoleAssignment -PrincipalType Group -PrincipalObjectId $aadGroupId -RoleName $roleName -AppName $appId -EnvironmentName $environmentId"
                        Set-AdminPowerAppRoleAssignment -PrincipalType Group -PrincipalObjectId $aadGroupId -RoleName $roleName -AppName $appId -EnvironmentName $environmentId
                    }
                }
                else {
                    Write-Host "##vso[task.logissue type=warning]A specified canvas app was not found in the target environment. Verify your deployment configuration and try again."
                }
            }
        }
	}
}

<#
Read all the Canvas Apps part of the solution.
Apply PowerShell command to bypass the Canvas app consents.
#>
function ByPass-Canvas-App-Consents
{
    param (
        [Parameter(Mandatory)] [String]$microsoftPowerAppsAdministrationPowerShellModule,
        [Parameter(Mandatory)] [String]$powerAppsAdminModuleVersion,
        [Parameter(Mandatory)] [String]$tenantId,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$microsoftXrmDataPowerShellModule,
        [Parameter(Mandatory)] [String]$XrmDataPowerShellVersion,
        [Parameter(Mandatory)] [String]$serviceConnection,
        [Parameter(Mandatory)] [String]$environmentId,
        [Parameter(Mandatory)] [String]$dataverseConnectionString,
        [Parameter(Mandatory)] [String]$solutionName
    )

    Import-Module $microsoftPowerAppsAdministrationPowerShellModule -Force -RequiredVersion $powerAppsAdminModuleVersion -ArgumentList @{ NonInteractive = $true }
    Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $clientId -ClientSecret $clientSecret
    #$microsoftXrmDataPowerShellModule = '$(CoETools_Microsoft_Xrm_Data_PowerShell)'
    Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $XrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }
    $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

    $environmentName = "$environmentId"

    # Fetch all solution components
    $solutions = Get-CrmRecords -conn $conn -EntityLogicalName solution -FilterAttribute "uniquename" -FilterOperator "eq" -FilterValue "$solutionName" -Fields solutionid
    if($solutions.Count -gt 0) {
        $solutionId = $solutions.CrmRecords[0].solutionid

        $result = Get-CrmRecords -conn $conn -EntityLogicalName solutioncomponent -FilterAttribute "solutionid" -FilterOperator "eq" -FilterValue $solutionId -Fields objectid,componenttype
        $solutionComponents = $result.CrmRecords

        $optionSetMetadata = $null
        foreach ($c in $solutionComponents){
            $componentType = $c.componenttype
            Write-Host "Componenttype - $componentType"
            if ($c.componenttype -eq "Canvas App" -and $c.objectid -ne ""){
                Write-Host "Bypassing the canvas app $($c.objectid) consent. Environment - $environmentName"
                # Set-AdminPowerAppApisToBypassConsent -EnvironmentName [Guid] -AppName [Guid]
                Write-Host "Command - Set-AdminPowerAppApisToBypassConsent –EnvironmentName $environmentName –AppName $($c.objectid)"
                Set-AdminPowerAppApisToBypassConsent –EnvironmentName $environmentName –AppName $($c.objectid)
            }
        }
    }
}

<#
Reads the Canvas App ownership configuration.
Triggers 'Set-AdminPowerAppOwner' to set the ownership.
#>
function Set-OwnerCanvasApps {
    param (
        [Parameter(Mandatory)] [String] [AllowEmptyString()]$solutionComponentOwnershipConfiguration,
        [Parameter(Mandatory)] [String]$microsoftPowerAppsAdministrationPowerShellModule,
        [Parameter(Mandatory)] [String]$powerAppsAdminModuleVersion,
        [Parameter(Mandatory)] [String]$tenantId,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$microsoftXrmDataPowerShellModule,
        [Parameter(Mandatory)] [String]$XrmDataPowerShellVersion,
        [Parameter(Mandatory)] [String]$dataverseConnectionString,
        [Parameter(Mandatory)] [String]$environmentId
    )
     
    Import-Module $microsoftPowerAppsAdministrationPowerShellModule -Force -RequiredVersion $powerAppsAdminModuleVersion -ArgumentList @{ NonInteractive = $true }
    Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $clientId -ClientSecret $clientSecret
    
    Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $XrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }
    $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

    $environmentName = "$environmentId"

    Write-Host "Inside Set-OwnerCanvasApps. SolutionComponentOwnershipConfiguration"
    if($solutionComponentOwnershipConfiguration -ne "") {
        $rawContent = Get-Content $solutionComponentOwnershipConfiguration
        Write-Host "SolutionComponentOwnershipConfiguration - $solutionComponentOwnershipConfiguration"
        $config = Get-Content $solutionComponentOwnershipConfiguration | ConvertFrom-Json
        foreach ($ownershipConfig in $config) {
            if ($ownershipConfig.ownerEmail -ne '' -and $ownershipConfig.solutionComponentType -ne '' -and $ownershipConfig.solutionComponentUniqueName -ne '') {
                switch ($ownershipConfig.solutionComponentType) {
                    # Canvas App 
                    300 {
                        $matchedUser = Get-User-By-Email-or-DomainName $ownershipConfig.ownerEmail $conn
                        if ($null -ne $matchedUser) {
                            Write-Host "Matched user found for $($ownershipConfig.ownerEmail)"
                            $systemUserId = $matchedUser.systemuserid
                            $azureactivedirectoryobjectid = $matchedUser.azureactivedirectoryobjectid
                            # Fetch the Canvas App Id from current environment using App Name (i.e., solutionComponentName)
                            $canvasApps = Get-CrmRecords -conn $conn -EntityLogicalName canvasapp -FilterAttribute "name" -FilterOperator "eq" -FilterValue "$($ownershipConfig.solutionComponentName)" -Fields canvasappid,uniquecanvasappid
                            if($canvasApps.Count -gt 0) {
                                $appId = $canvasApps.CrmRecords[0].canvasappid
                                Write-Host "Setting canvas app's $($ownershipConfig.solutionComponentName) owner with $systemUserId. Environment - $environmentName"
                                Write-Host "Command - Set-AdminPowerAppOwner –AppName $appId -AppOwner $azureactivedirectoryobjectid –EnvironmentName $environmentName"
                                Set-AdminPowerAppOwner –AppName $appId -AppOwner $azureactivedirectoryobjectid –EnvironmentName $environmentName
                            }
                            else{
                                Write-Host "No canvas app found with the name - $($ownershipConfig.solutionComponentName)"
                            }
                        }
                        else{
                            Write-Host "No matched user found for $($ownershipConfig.ownerEmail)"
                        }
                        break;
                    }
                    29 {
                        Write-Host "Skipping this for workflow $($ownershipConfig.solutionComponentName)."
                        break;
                    }
                    default {
                        Write-Host "##vso[task.logissue type=warning]NOT IMPLEMENTED - You supplied a solutionComponentType of $ownershipConfig.solutionComponentType for solutionComponentUniqueName $solutionComponentUniqueName"
                        exit 1;
                    }      
                }
            }
        }
    }    
}

function Get-User-By-Email-or-DomainName{
 param(
    [Parameter()] [String] [AllowEmptyString()]$filterValue,
    [Parameter(Mandatory)] [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]$conn
    )

    $matchedUser = $null
    $fetch = @"
    <fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='false'>
      <entity name='systemuser'>
        <attribute name='systemuserid' />
        <attribute name='azureactivedirectoryobjectid' />
        <filter type='and'>
          <filter type='or'>
            <condition attribute='internalemailaddress' operator='eq' value='$filterValue' />
            <condition attribute='domainname' operator='eq' value='$filterValue' />
          </filter>
        </filter>
      </entity>
    </fetch>
"@

    #Write-Host "Request XML - "$fetch
    $records = Get-CrmRecordsByFetch -Fetch $fetch -conn $conn
    try{
        $json = ConvertTo-Json $records
        #Write-Host "Response - $json"        
        
        if($records -and $records.CrmRecords){  
            $matchedUser = $records.CrmRecords[0]
        }
    }
    catch {
        Write-Host "An error occurred in Get-User-By-Email-or-DomainName: $($_.Exception.Message)"
    }

    return $matchedUser
}

<#
This function reads custom deployment Settings and updates canvas app ownership.
#>
function Update-Canvas-App-Ownership
{
    param (
        [Parameter(Mandatory)] [String]$microsoftPowerAppsAdministrationPowerShellModule,
        [Parameter(Mandatory)] [String]$powerAppsAdminModuleVersion,
        [Parameter(Mandatory)] [String]$tenantId,
        [Parameter(Mandatory)] [String]$clientId,
        [Parameter(Mandatory)] [String]$clientSecret,
        [Parameter(Mandatory)] [String]$microsoftXrmDataPowerShellModule,
        [Parameter(Mandatory)] [String]$XrmDataPowerShellVersion,
        [Parameter(Mandatory)] [String]$dataverseConnectionString,
        [Parameter(Mandatory)] [String]$environmentId,
        [Parameter(Mandatory)] [String]$requestedForEmail,
        [Parameter(Mandatory)] [String]$solutionName
    )
    #$microsoftPowerAppsAdministrationPowerShellModule = '$(CoETools_Microsoft_PowerApps_Administration_PowerShell)'
    Import-Module $microsoftPowerAppsAdministrationPowerShellModule -Force -RequiredVersion $powerAppsAdminModuleVersion -ArgumentList @{ NonInteractive = $true }
    Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $clientId -ClientSecret $clientSecret
    #$microsoftXrmDataPowerShellModule = '$(CoETools_Microsoft_Xrm_Data_PowerShell)'
    Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $XrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }
    $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

    $environmentName = "$environmentId"

    $systemusers = Get-CrmRecords -conn $conn -EntityLogicalName systemuser -FilterAttribute "internalemailaddress" -FilterOperator eq -FilterValue "$requestedForEmail" -Fields azureactivedirectoryobjectid
    if($systemusers.Count -gt 0) {

        $azureactivedirectoryobjectid = $systemusers.CrmRecords[0].azureactivedirectoryobjectid

        $solutions = Get-CrmRecords -conn $conn -EntityLogicalName solution -FilterAttribute "uniquename" -FilterOperator "eq" -FilterValue "$solutionName" -Fields solutionid
        if($solutions.Count -gt 0) {
            $solutionId = $solutions.CrmRecords[0].solutionid

            $result = Get-CrmRecords -conn $conn -EntityLogicalName solutioncomponent -FilterAttribute "solutionid" -FilterOperator "eq" -FilterValue $solutionId -Fields objectid,componenttype
            $solutionComponents = $result.CrmRecords
            foreach ($c in $solutionComponents){
                if ($c.componenttype -eq "Canvas App" -and $c.objectid -ne ""){
                    Write-Host "Setting canvas app owner $($c.objectid) with $azureactivedirectoryobjectid. Environment - $environmentName"
                    Write-Host "Command - Set-AdminPowerAppOwner –AppName $c.objectid -AppOwner $azureactivedirectoryobjectid –EnvironmentName $environmentName"
                    Set-AdminPowerAppOwner –AppName $c.objectid -AppOwner $azureactivedirectoryobjectid –EnvironmentName $environmentName
                }
            }
        }
    }
}
