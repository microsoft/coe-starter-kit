<#
This function sets AAD Group Teams from the custom deployment settings.
#>
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
        Import-Module $microsoftPowerAppsAdministrationPowerShellModule -Force -RequiredVersion $powerAppsAdminModuleVersion -ArgumentList @{ NonInteractive = $true }
        Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $clientId -ClientSecret $clientSecret
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

        foreach ($c in $config){
          $aadGroupTeamName = $c.aadGroupTeamName
          $businessUnitId = $c.aadGroupTeamBusinessUnitId
          $aadId = $c.aadSecurityGroupId
          $securityRoleNamesfromConfig = $c.dataverseSecurityRoleNames
          $skipRolesDeletion = $c.skipRolesDeletion

          Write-Host "aadGroupTeamName - $aadGroupTeamName"
          Write-Host "businessUnitId - $businessUnitId"
          Write-Host "aadId - $aadId"
          Write-Host "securityRoleNames - $securityRoleNamesfromConfig"
          Write-Host "skipRolesDeletion - $skipRolesDeletion"
          if($aadGroupTeamName -ne '' -and $aadId -ne '') {
              $teamTypeValue = New-CrmOptionSetValue -Value 2

              $fields = @{ "name"=$aadGroupTeamName;"teamtype"=$teamTypeValue;"azureactivedirectoryobjectid"=[guid]$aadId }

              #Get business unit
              if($businessUnitId -ne '') {
                  $guidBU = [GUID]"$businessUnitId"
                  $businessUnitLookup = (New-CrmEntityReference -EntityLogicalName businessunit -Id $guidBU)
                  $fields = @{ "name"=$aadGroupTeamName;"teamtype"=$teamTypeValue;"azureactivedirectoryobjectid"=[guid]$aadId;"businessunitid"=$businessUnitLookup }
              }

              $applySecurityRoleRefresh = $true
              # Check if any Dataverse team with AAD security group already exists
              $queryteamswithaadID = "teams?`$select=teamid,name&`$filter=(azureactivedirectoryobjectid eq '$aadId')"

              try{
                Write-Host "Checking if AAD group already mapped to DV teams in the target. 'Teams with AAD' Query - $queryteamswithaadID"
                $aadGroupTeamswithAAD = Invoke-DataverseHttpGet $token $dataverseHost $queryteamswithaadID
              }
              catch{
                Write-Host "Error $queryteamswithaadID - $($_.Exception.Message)"
              }

              if($null -ne $aadGroupTeamswithAAD.value -and $aadGroupTeamswithAAD.value.count -gt 0){
                $existingTeamName = $aadGroupTeamswithAAD.value[0].name
                Write-Host "Given AAD team with id - $aadId is already mapped to the Dataverse team - $existingTeamName"
                # If already mapped team name not matches with Team name from Deployment setting skip the Security Role refresh
                if ($existingTeamName -ne $aadGroupTeamName) {
                    Write-Host "Existing team - $existingTeamName not matching with  aadGroupTeamName - $aadGroupTeamName. Cancelling Security Role refresh"
                    $applySecurityRoleRefresh = $false
                }else{
                    Write-Host "Existing team - $existingTeamName matching with  aadGroupTeamName - $aadGroupTeamName. Proceeding with Security Role refresh"
                }
              }
              else{
                Write-Host "Given AAD team with id - $aadId is not mapped to any Dataverse teams - $existingTeamName. Proceeding with creation or updation of Team."
              }

              # Perform Security Role refresh only if $applySecurityRoleRefresh is $true
              if($applySecurityRoleRefresh){
                  Write-Host "Checking and fetching the Team by name $aadGroupTeamName in the target environment"
                  $encodedFilterValue = [System.Web.HttpUtility]::UrlEncode("$aadGroupTeamName")
                  # Fetch Team by Name
                  $queryteams = "teams?`$select=teamid&`$filter=(name eq '$encodedFilterValue')"    

                  try{
                    Write-Host "Teams Query - $queryteams"
                    $aadGroupTeams = Invoke-DataverseHttpGet $token $dataverseHost $queryteams
                  }
                  catch{
                    Write-Host "Error queryteams - $($_.Exception.Message)"
                  }

                  $newTeamCreated = $false
                  if($null -ne $aadGroupTeams.value -and $aadGroupTeams.value.count -gt 0){
                    Write-Host "Team with name $aadGroupTeamName found. Updating the existing team - $aadGroupTeamName"
                    $aadGroupTeamId = $aadGroupTeams.value[0].teamid
                    Set-CrmRecord -conn $conn -EntityLogicalName team -Id $aadGroupTeamId -Fields $fields
                  } 
                  else {
                    $newTeamCreated = $true
                    Write-Host "Team with name $aadGroupTeamName not found. Creating a new team by name $aadGroupTeamName"  
                    $aadGroupTeamId = New-CrmRecord -conn $conn -EntityLogicalName team -Fields $fields
                  }
      
                  $existingDVTeamRolesNonConfig = $null
                  # Skip role fetch, if Team is newly created
                  if($newTeamCreated -eq $false){
                      Write-Host "Fetching the existing roles of the existing Team $aadGroupTeamName"
                      $queryaadGroupTeamRoles = "teamrolescollection?`$select=roleid&`$filter=(teamid eq '$aadGroupTeamId')"
                      try{
                         Write-Host "aadGroupTeamRoles Query - $queryaadGroupTeamRoles"
                         $existingDVTeamRolesNonConfig = Invoke-DataverseHttpGet $token $dataverseHost $queryaadGroupTeamRoles
                      }
                      catch{
                         Write-Host "Error queryaadGroupTeamRoles - $($_.Exception.Message)"
                      }
                  }

                  $dvRoleofConfigIds = New-Object System.Collections.ArrayList
                  Write-Host "Query Dataverse for the Team $aadGroupTeamName roles passed in configuration settings "
                  foreach ($securityRoleNamefromConfig in $securityRoleNamesfromConfig){
                    $encodedFilterValue = [System.Web.HttpUtility]::UrlEncode("$securityRoleNamefromConfig")
                    $querysecurityRoles = "roles?`$select=roleid,name&`$filter=(name eq '$encodedFilterValue')"
                    if($businessUnitId -ne '') {
                      $querysecurityRoles = "roles?`$select=roleid,name&`$filter=(name eq '$encodedFilterValue' and _businessunitid_value eq '$businessUnitId')"
                    }

                    try{
                        Write-Host "Security Roles Query - $querysecurityRoles"
                        $responseDVSecurityRoleofConfig = Invoke-DataverseHttpGet $token $dataverseHost $querysecurityRoles
                    }
                    catch{
                        Write-Host "Error querysecurityRoles - $($_.Exception.Message)"
                    }

                    if($null -ne $responseDVSecurityRoleofConfig.value -and $responseDVSecurityRoleofConfig.value.count -gt 0){
                        $dvSecurityRoleofConfig = $responseDVSecurityRoleofConfig.value[0]
                        Write-Host "Checking whether role is already mapped to Team; Role Name - $securityRoleNamefromConfig; Id - " $dvSecurityRoleofConfig.roleid
                        $dvRoleofConfigIds.Add($dvSecurityRoleofConfig.roleid)

                        if($null -ne $existingDVTeamRolesNonConfig.value -and $existingDVTeamRolesNonConfig.value.count -gt 0){
                            # Add the role only if its not already added
                            if ($existingDVTeamRolesNonConfig.value.Where({$_.roleid -eq $dvSecurityRoleofConfig.roleid}).Count -eq 0){
                              Write-Host "Assigning additional Role - $securityRoleNamefromConfig to Team - $aadGroupTeamName"
                              Add-CrmSecurityRoleToTeam -conn $conn -TeamId $aadGroupTeamId -SecurityRoleId $dvSecurityRoleofConfig.roleid
                            }
                            else{
                              Write-Host "Role - $securityRoleNamefromConfig already assigned to Team - $aadGroupTeamName"
                            }
                        }
                        else{
                            # Add role for newly created team
                            Write-Host "Assigning Role - $securityRoleNamefromConfig to Team - $aadGroupTeamName"
                            Add-CrmSecurityRoleToTeam -conn $conn -TeamId $aadGroupTeamId -SecurityRoleId $dvSecurityRoleofConfig.roleid
                        }
                    }
                    else {
                        Write-Host "##vso[task.logissue type=warning]A specified security role ($securityRoleNamefromConfig) was not found in the target environment. Verify your deployment configuration and try again."
                    }
                  }

                  # Feature to remove additional DV roles
                  if($skipRolesDeletion -eq "false" -and $null -ne $securityRoleNamesfromConfig -and !$newTeamCreated){
                    Write-Host "Admin chosen to remove additional roles not part of configurations"
                    if($null -ne $existingDVTeamRolesNonConfig.value -and $existingDVTeamRolesNonConfig.value.count -gt 0){
                        #Check if DVRole 
                        foreach ($existingDVTeamRoleNonConfig in $existingDVTeamRolesNonConfig.value){
                            if (-not $dvRoleofConfigIds.Contains($existingDVTeamRoleNonConfig.roleid)) {
                                # Removing the Role from Team
                                Write-Host "Removing the " $existingDVTeamRoleNonConfig.roleid " from Team - $aadGroupTeamName"
                                Remove-CrmSecurityRoleFromTeam -conn $conn -TeamId $aadGroupTeamId -SecurityRoleId $existingDVTeamRoleNonConfig.roleid
                            }                            
                        }
                    }
                  }
                  else{
                    Write-Host "Skipping removal of additional roles from Team - $aadGroupTeamName"
                  }
              }
            }
        }
    }
}