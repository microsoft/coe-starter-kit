function Set-Dataverse-AAD-Group-Teams
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
        [Parameter()] [String]$aadGroupTeamConfiguration,
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseConnectionString
    )

	if($aadGroupTeamConfiguration -ne '') {
        #$microsoftPowerAppsAdministrationPowerShellModule = '$(CoETools_Microsoft_PowerApps_Administration_PowerShell)'
        Import-Module $microsoftPowerAppsAdministrationPowerShellModule -Force -RequiredVersion $powerAppsAdminModuleVersion -ArgumentList @{ NonInteractive = $true }
        Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $clientId -ClientSecret $clientSecret
        #$microsoftXrmDataPowerShellModule = '$(CoeTools_Microsoft_Xrm_Data_Powershell)'
        Import-Module $microsoftXrmDataPowerShellModule -Force -RequiredVersion $XrmDataPowerShellVersion -ArgumentList @{ NonInteractive = $true }
        $conn = Get-CrmConnection -ConnectionString "$dataverseConnectionString"

        . "$env:POWERSHELLPATH/dataverse-webapi-functions.ps1"
        $dataverseHost = Get-HostFromUrl "$serviceConnection"
        Write-Host "dataverseHost - $dataverseHost"

        # json config value must follow this format
        # [
        #   {
        #     "aadGroupTeamName":"name-of-aad-group-team-to-create-or-update-1",
        #     "aadSecurityGroupId":"guid-of-security-group-from-aad-1",
        #     "dataverseSecurityRoleNames":["dataverse-security-role-name-1","dataverse-security-role-name-2"]
        #   },
        # [
        #   {
        #     "aadGroupTeamName":"name-of-aad-group-team-to-create-or-update-2",
        #     "aadSecurityGroupId":"guid-of-security-group-from-aad-2",
        #     "dataverseSecurityRoleNames":["dataverse-security-role-name-3","dataverse-security-role-name-4"]
        #   }
        # ]
        Write-Host "aadGroupTeamConfiguration - $aadGroupTeamConfiguration"

        $config = Get-Content "$aadGroupTeamConfiguration" | ConvertFrom-Json

        Write-Host "config - $config"

        foreach ($c in $config){
          $aadGroupTeamName = $c.aadGroupTeamName
          $businessUnitId = $c.aadGroupTeamBusinessUnitId
          $aadId = $c.aadSecurityGroupId
          $securityRoleNames = $c.dataverseSecurityRoleNames

          Write-Host "aadGroupTeamName - $aadGroupTeamName"
          Write-Host "businessUnitId - $businessUnitId"
          Write-Host "aadId - $aadId"
          Write-Host "securityRoleNames - $securityRoleNames"
          if($aadGroupTeamName -ne '' -and $aadId -ne '') {
              $teamTypeValue = New-CrmOptionSetValue -Value 2

              $fields = @{ "name"=$aadGroupTeamName;"teamtype"=$teamTypeValue;"azureactivedirectoryobjectid"=[guid]$aadId }

              #Get business unit
              if($businessUnitId -ne '') {
                  $guidBU = [GUID]"$businessUnitId"
                  #$businessUnitLookup = [PSCustomObject]@{"LogicalName"="businessunit"; "Id"=[guid]"$businessUnitId"}
                  $businessUnitLookup = (New-CrmEntityReference -EntityLogicalName businessunit -Id $guidBU)
                  $fields = @{ "name"=$aadGroupTeamName;"teamtype"=$teamTypeValue;"azureactivedirectoryobjectid"=[guid]$aadId;"businessunitid"=$businessUnitLookup }
              }

              $queryteams = "teams?`$select=teamid&`$filter=(name eq '$aadGroupTeamName')"    

              try{
                Write-Host "Teams Query - $queryteams"
                $aadGroupTeams = Invoke-DataverseHttpGet $token $dataverseHost $queryteams
              }
              catch{
                Write-Host "Error queryteams - $($_.Exception.Message)"
              }

              #$aadGroupTeams = Get-CrmRecords -conn $conn -EntityLogicalName team -FilterAttribute "name" -FilterOperator "eq" -FilterValue $aadGroupTeamName -Fields teamid
              if($null -ne $aadGroupTeams.value -and $aadGroupTeams.value.count -gt 0){
                Write-Host "Updating existing team with $fields"
                $aadGroupTeamId = $aadGroupTeams.value[0].teamid
                Set-CrmRecord -conn $conn -EntityLogicalName team -Id $aadGroupTeamId -Fields $fields
              } 
              else {
                Write-Host "Creating new team with $fields"  
                $aadGroupTeamId = New-CrmRecord -conn $conn -EntityLogicalName team -Fields $fields
              }
      
              Write-Host "aadGroupTeamId - $aadGroupTeamId"
                $queryaadGroupTeamRoles = "teamrolescollection?`$select=roleid&`$filter=(teamid eq '$aadGroupTeamId')"    

                try{
                    Write-Host "aadGroupTeamRoles Query - $queryaadGroupTeamRoles"
                    $aadGroupTeamRoles = Invoke-DataverseHttpGet $token $dataverseHost $queryaadGroupTeamRoles
                }
                catch{
                    Write-Host "Error queryaadGroupTeamRoles - $($_.Exception.Message)"
                }

              foreach ($securityRoleName in $securityRoleNames){
                #$securityRoles = Get-CrmRecords -conn $conn -EntityLogicalName role -FilterAttribute "name" -FilterOperator "eq" -FilterValue $securityRoleName -Fields roleid
                $querysecurityRoles = "roles?`$select=roleid,name&`$filter=(name eq '$securityRoleName' and _businessunitid_value eq '$businessUnitId')"
                try{
                    Write-Host "Security Roles Query - $querysecurityRoles"
                    $securityRoles = Invoke-DataverseHttpGet $token $dataverseHost $querysecurityRoles
                }
                catch{
                    Write-Host "Error querysecurityRoles - $($_.Exception.Message)"
                }

                if($null -ne $securityRoles.value -and $securityRoles.value.count -gt 0){
                    $securityRole = $securityRoles.value[0]
                    Write-Host "Checking whether role is already mapped to Team; Role Name - $securityRoleName; Id - " $securityRole.roleid

                    if($null -ne $aadGroupTeamRoles.value -and $aadGroupTeamRoles.value.count -gt 0){
                        # Add the role if its not already added
                        if ($aadGroupTeamRoles.value.Where({$_.roleid -eq $securityRole.roleid}).Count -eq 0){
                          Write-Host "Assigning additional Role - $securityRoleName to Team - $aadGroupTeamName"
                          Add-CrmSecurityRoleToTeam -conn $conn -TeamId $aadGroupTeamId -SecurityRoleId $securityRole.roleid
                        }
                        else{
                          Write-Host "Role - $securityRoleName already assigned to Team - $aadGroupTeamName"
                        }
                    }
                    else{
                        # Add role for newly created team
                        Write-Host "Assigning Role - $securityRoleName to Team - $aadGroupTeamName"
                        Add-CrmSecurityRoleToTeam -conn $conn -TeamId $aadGroupTeamId -SecurityRoleId $securityRole.roleid
                    }
                }
                else {
                    Write-Host "##vso[task.logissue type=warning]A specified security role ($securityRoleName) was not found in the target environment. Verify your deployment configuration and try again."
                }
              }
            }
        }
    }
}