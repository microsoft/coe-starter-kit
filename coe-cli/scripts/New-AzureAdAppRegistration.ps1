Import-Module (Join-Path ( ([System.IO.Path]::GetDirectoryName($PSCommandPath))) "Microsoft.PowerApps.Administration.PowerShell.psm1") -Force
Import-Module (Join-Path ( ([System.IO.Path]::GetDirectoryName($PSCommandPath))) "Microsoft.PowerApps.AuthModule.psm1") -Force

Function New-AzureAdAppRegistration {
    <#
        .SYNOPSIS
            Create an Azure AD app registration if it does not exist.

        .DESCRIPTION
            Search an app registration with the name provided.
            If no app registration found, create a new one.

        .PARAMETER DisplayName
            Specifies the display name of the app registration to create.

        .PARAMETER AvailableToOtherTenants
            Parameter that allows you to choose if you want to make your app registration available to other tenants or not.

        .PARAMETER ManifestPath
            Specifies the path to the manifest file to specify the required ressource accesses the app registration will need.

        .INPUTS
            None. You cannot pipe objects to New-AzureAdAppRegistration.

        .OUTPUTS
            Object. New-AzureAdAppRegistration returns the details of the app registration found or created.

        .EXAMPLE
            PS> New-AzureAdAppRegistration -DisplayName "ExistingDemonstration" -ManifestPath .\manifest.json
            DisplayName                                : ExistingDemonstration
            ApplicationId                              : 00000000-0000-0000-0000-000000000000
            TenantId                                   : 00000000-0000-0000-0000-000000000000
            Password                                   :
            Type                                       : Existing

        .EXAMPLE
            PS> New-AzureAdAppRegistration -DisplayName "NewDemonstration" -AvailableToOtherTenants $false -ManifestPath .\manifest.json
            DisplayName                                : NewDemonstration
            ApplicationId                              : 00000000-0000-0000-0000-000000000000
            TenantId                                   : 00000000-0000-0000-0000-000000000000
            Password                                   : 0000000000000000000000000000
            Type                                       : Created

        .LINK
            README.md: https://github.com/microsoft/coe-starter-kit/tree/main/PowerPlatformDevOpsALM/SetupAutomation

        .NOTES
            * You need to be authenticated with an account with the permissions to create app registrations using the "az login" (Azure CLI) command to be able to use this function
            * You need to have Azure DevOps in your Enterprise Applications in Azure AD
    #>

    [CmdletBinding()]
    [OutputType([psobject])]
    Param (
        # Display name of the app registration to create
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$DisplayName,

        # Make your app registration available to other tenants or not
        [Parameter()]
        [Boolean]$AvailableToOtherTenants = $false,

        # Path to the manifest file to specify the required ressource accesses the app registration will need
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$ManifestPath
    )

    Begin{}

    Process{
        [Console]::ResetColor()
        
        # Test the path provided to the manifest file
        Write-Verbose "Test the path provided to the manifest file: $ManifestPath"
        Write-Debug "Before the call to the 'Test-Path' command..."
        if(Test-Path $ManifestPath) {
            $manifestPathValidated = $true
        }
        else {
            $manifestPathValidated = $false
        }

        # Get the ID of the tenant
        Write-Verbose "Get the ID of the tenant where the user is logged in"
        Write-Debug "Before the call to the 'az account list' command..."
        $tenantListJson = az account list
        $tenantList = $tenantListJson | ConvertFrom-Json
        $tenantId = $tenantList[0].tenantId
        
        # Search for an existing app registration with the display name provided
        Write-Verbose "Search app registrations with the following display name: $DisplayName"
        Write-Debug "Before the call to the 'az ad app list' command..."
        $appListJson = az ad app list --filter "displayName eq '$DisplayName'"

        # Number of app registrations found
        $appList = $appListJson | ConvertFrom-Json
        $appListMeasure = $appList | Measure
        $appListCount = $appListMeasure.Count

        # Case only one app registration found for the provided display name
        if($appListCount -eq 1) {
            Write-Verbose "Only one app registration found - Do nothing"
            $appRegistration = [PSCustomObject]@{
                DisplayName = $appList[0].displayName
                ApplicationId = $appList[0].appId
                TenantId = $tenantId
                Password = ""
                Type = "Existing"
            }
        }

        # Case no app registration found for the provided display name and existing manifest file
        if($appListCount -eq 0 -and $manifestPathValidated) {
            Write-Verbose "No app registration found - Create a new one"

            # Call to 'az ad app create' command
            Write-Verbose "Try to call the 'az ad app create' command."
            Write-Debug "Before the call to the 'az ad app create' command..."
            $appRegistrationCreated = az ad app create --display-name $DisplayName --available-to-other-tenants $AvailableToOtherTenants --required-resource-accesses $ManifestPath | ConvertFrom-Json
            
            if (!$appRegistrationCreated) {
                Write-Verbose "Error in the creation of the app registration"
                $appRegistration = [PSCustomObject]@{
                    Error = "Error in the creation of the app registration"
                }
            }
            else {
                $appRegistration = [PSCustomObject]@{
                    DisplayName = $appRegistrationCreated.displayName
                    ApplicationId = $appRegistrationCreated.appId
                    TenantId = $tenantId
                }
            }

            # Call to 'az ad app admin-consent' command if app registration created without error
            if($appRegistration.Error -eq $null){
                # Call to 'az ad app permission admin-consent' command
                Write-Verbose "Try to call the 'az ad app permission admin-consent' command."
                Write-Debug "Before the call to the 'az ad app permission admin-consent' command..."
                az ad app permission admin-consent --id $appRegistration.ApplicationId | ConvertFrom-Json
                
                Write-Verbose "Try to call the 'az ad app permission list-grants' command."
                Write-Debug "Before the call to the 'az ad app permission list-grants' command..."
                $appRegistrationListGrantsOutput = az ad app permission list-grants --id $appRegistration.ApplicationId | ConvertFrom-Json
                $appRegistrationListGrantsOutputMeasure = $appRegistrationListGrantsOutput | Measure
                $appRegistrationListGrantsOutputCount = $appRegistrationListGrantsOutputMeasure.Count

                if (!$appRegistrationListGrantsOutputCount -gt 0) {
                    Write-Verbose "Error in the admin consent for the app registration created"
                    $appRegistration = [PSCustomObject]@{
                        Error = "Error in the admin consent for the app registration created"
                    }
                }
            }

            # Call to 'az ad app credential reset' command if admin consent for the app registration created without error
            if($appRegistration.Error -eq $null){
                # Call to 'az ad app credential reset' command
                Write-Verbose "Try to call the 'az ad app credential reset' command."
                Write-Debug "Before the call to the 'az ad app credential reset' command..."
                $appCredential = az ad app credential reset --id $appRegistration.ApplicationId | ConvertFrom-Json

                if (!$appCredential) {
                    Write-Verbose "Error in the app credential reset for the app registration created"
                    $appRegistration = [PSCustomObject]@{
                        Error = "Error in the app credential reset for the app registration created"
                    }
                }
                else {
                    $appRegistration | Add-Member -MemberType NoteProperty -Name "Password" -Value $appCredential.password
                    $appRegistration | Add-Member -MemberType NoteProperty -Name "Type" -Value "Created"
                }
            }
        }

        # Case no app registration found for the provided display name and non existing manifest file
        if($appListCount -eq 0 -and -not $manifestPathValidated) {
            Write-Verbose "Error - Creation of the app registration impossible because manifest file not found"
            $appRegistration = [PSCustomObject]@{
                Error = "Error - Creation of the app registration impossible because manifest file not found"
            }
        }

        # Case multiple app registration found for the provided display name
        if($appListCount -gt 1) {
            Write-Verbose "Error - Multiple app registration corresponding to the following display name: $DisplayName"
            $appRegistration = [PSCustomObject]@{
                Error = "Error - Multiple app registration corresponding to the following display name: $DisplayName"
            }
        }

        # Return the considered app registration (found or created)
        Write-Verbose "Return the app registration found or created."
        Write-Debug "Before sending the output..."
        $appRegistration
    }

    End{}
}