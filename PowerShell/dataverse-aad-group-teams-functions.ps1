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
                  $queryteams = "teams?`$select=teamid&`$filter=(name eq '$encodedFilterValue')"    

                  try{
                    Write-Host "Teams Query - $queryteams"
                    $aadGroupTeams = Invoke-DataverseHttpGet $token $dataverseHost $queryteams
                  }
                  catch{
                    Write-Host "Error queryteams - $($_.Exception.Message)"
                  }

                  if($null -ne $aadGroupTeams.value -and $aadGroupTeams.value.count -gt 0){
                    Write-Host "Team with name $aadGroupTeamName found. Updating the existing team - $aadGroupTeamName"
                    $aadGroupTeamId = $aadGroupTeams.value[0].teamid
                    Set-CrmRecord -conn $conn -EntityLogicalName team -Id $aadGroupTeamId -Fields $fields
                  } 
                  else {
                    Write-Host "Team with name $aadGroupTeamName not found. Creating a new team by name $aadGroupTeamName"  
                    $aadGroupTeamId = New-CrmRecord -conn $conn -EntityLogicalName team -Fields $fields
                  }
      
                  Write-Host "Fetching the existing roles of Team $aadGroupTeamName"
                  $queryaadGroupTeamRoles = "teamrolescollection?`$select=roleid&`$filter=(teamid eq '$aadGroupTeamId')"    

                  try{
                     Write-Host "aadGroupTeamRoles Query - $queryaadGroupTeamRoles"
                     $existingAADGroupTeamRoles = Invoke-DataverseHttpGet $token $dataverseHost $queryaadGroupTeamRoles
                  }
                  catch{
                     Write-Host "Error queryaadGroupTeamRoles - $($_.Exception.Message)"
                  }

                  Write-Host "Comparing the Team $aadGroupTeamName roles with roles passed in configuration settings "
                  foreach ($securityRoleName in $securityRoleNames){
                    $encodedFilterValue = [System.Web.HttpUtility]::UrlEncode("$securityRoleName")
                    $querysecurityRoles = "roles?`$select=roleid,name&`$filter=(name eq '$encodedFilterValue' and _businessunitid_value eq '$businessUnitId')"
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

                        if($null -ne $existingAADGroupTeamRoles.value -and $existingAADGroupTeamRoles.value.count -gt 0){
                            # Add the role only if its not already added
                            if ($existingAADGroupTeamRoles.value.Where({$_.roleid -eq $securityRole.roleid}).Count -eq 0){
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
}