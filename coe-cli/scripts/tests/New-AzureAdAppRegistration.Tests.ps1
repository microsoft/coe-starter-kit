BeforeAll {
    # Import New-AzureAdAppRegistration function
    Import-Module (Join-Path ( ([System.IO.Path]::GetDirectoryName($PSCommandPath))) ".." "New-AzureAdAppRegistration.ps1") -Force
}

# New-AzureAdAppRegistration tests without integrations with other modules
Describe "New-AzureAdAppRegistration Unit Tests" -Tag "UnitTests" {
    Context "Parameters configuration verification" {
        It "Given the Mandatory attribute of the DisplayName parameter, it should be equal to true" {
            (Get-Command New-AzureAdAppRegistration).Parameters['DisplayName'].Attributes.Mandatory | Should -Be $true
        }

        It "Given the Mandatory attribute of the AvailableToOtherTenants parameter, it should be equal to false" {
            (Get-Command New-AzureAdAppRegistration).Parameters['AvailableToOtherTenants'].Attributes.Mandatory | Should -Be $false
        }

        It "Given the ParameterType.Name attribute of the AvailableToOtherTenants parameter, it should be equal to Boolean" {
            (Get-Command New-AzureAdAppRegistration).Parameters['AvailableToOtherTenants'].ParameterType.Name | Should -Be "Boolean"
        }

        It "Given the Mandatory attribute of the ManifestPath parameter, it should be equal to true" {
            (Get-Command New-AzureAdAppRegistration).Parameters['ManifestPath'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Manifest file verification" {
        BeforeEach{
            # Simulate the behavior of the execution of the 'Test-Path' command
            Mock Test-Path { $true } -ParameterFilter { $Path -eq ".\existingmanifestfile.json" }
            Mock Test-Path { $false } -ParameterFilter { $Path -eq ".\nonexistingmanifestfile.json" }

            # Simulate the behavior of the execution of the 'az account list' command
            $tenantIdFoundMock = [PSCustomObject]@{
                tenantId = "10000000-0000-0000-0000-000000000000"
            }

            Mock az { $tenantIdFoundMock | ConvertTo-Json } -ParameterFilter { "$args" -match 'account list' }

            # Simulate the behavior of the execution of the 'az ad app list' command
            $appListFoundMock = [PSCustomObject]@{
                displayName = "Existing Mock App"
                appId = "00000000-0000-0000-0000-000000000000"
            }

            # Simulate the behavior of the execution of the 'az ad app create' command
            $appCreated = [PSCustomObject]@{
                displayName = "New Mock App"
                appId = "00000000-0000-0000-0000-000000000000"
            }

            Mock az { $appCreated | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app create' }

            # Simulate the behavior of the execution of the 'az ad app permission admin-consent' command
            Mock az { } -ParameterFilter { "$args" -match 'ad app permission admin-consent' }

            # Simulate the behavior of the execution of the 'az ad app permission list-grants' command
            $appCreatedGrants = [PSCustomObject]@{
                displayName = "New Mock App"
            }

            Mock az { $appCreatedGrants | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app permission list-grants' }

            # Simulate the behavior of the execution of the 'az ad app credential reset' command
            $appCreatedReset = [PSCustomObject]@{
                password = "0000000000000000000000000000"
            }

            Mock az { $appCreatedReset | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app credential reset' }

            # Definition of the exepcted results of the tests of the this context
            $expectedResultExistingAppFound = [PSCustomObject]@{
                DisplayName = "Existing Mock App"
                ApplicationId = "00000000-0000-0000-0000-000000000000"
                TenantId = "10000000-0000-0000-0000-000000000000"
                Password = ""
                Type = "Existing"
            }

            $expectedResultNewAppCreated = [PSCustomObject]@{
                DisplayName = "New Mock App"
                ApplicationId = "00000000-0000-0000-0000-000000000000"
                TenantId = "10000000-0000-0000-0000-000000000000"
                Password = "0000000000000000000000000000"
                Type = "Created"
            }

            $expectedResultErrorNonExistingManifestFile = [PSCustomObject]@{
                Error = "Error - Creation of the app registration impossible because manifest file not found"
            }
        }

        It "Given a correct path to a manifest file and the display name of an existing app registration, it should return the information of the app found" {
            Mock az { $appListFoundMock | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app list' }

            (New-AzureAdAppRegistration -DisplayName "Existing Mock App" -ManifestPath ".\existingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultExistingAppFound | ConvertTo-Json)
        }

        It "Given a wrong path to a manifest file and the display name of an existing app registration, it should return the information of the app found" {
            Mock az { $appListFoundMock | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app list' }

            (New-AzureAdAppRegistration -DisplayName "Existing Mock App" -ManifestPath ".\nonexistingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultExistingAppFound | ConvertTo-Json)
        }

        It "Given a correct path to a manifest file and the display name of a non existing app registration, it should return the information of the app found" {
            Mock az { } -ParameterFilter { "$args" -match 'ad app list' }

            (New-AzureAdAppRegistration -DisplayName "New Mock App" -ManifestPath ".\existingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultNewAppCreated | ConvertTo-Json)
        }

        It "Given a wrong path to a manifest file and the display name of a non existing app registration, it should return an error regarding the fact the creation of the app is impossible because the manifest file was not found" {
            Mock az { } -ParameterFilter { "$args" -match 'ad app list' }

            (New-AzureAdAppRegistration -DisplayName "New Mock App" -ManifestPath ".\nonexistingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultErrorNonExistingManifestFile | ConvertTo-Json)
        }

        It "Given a wrong path to a manifest file and the display name of a non existing app registration, it should not call the 'az ad app create' command" {
            Mock az { } -ParameterFilter { "$args" -match 'ad app list' }

            New-AzureAdAppRegistration -DisplayName "New Mock App" -ManifestPath ".\nonexistingmanifestfile.json"
            
            Should -Invoke -CommandName "az" -Exactly -Times 0 -ParameterFilter { "$args" -match 'ad app create' }
        }
    }

    Context "Behavior verification regarding an existing app registration registration" {
        BeforeEach{
            # Simulate the behavior of the execution of the 'Test-Path' command
            Mock Test-Path { $true } -ParameterFilter { $Path -eq ".\existingmanifestfile.json" }

            # Simulate the behavior of the execution of the 'az account list' command
            $tenantIdFoundMock = [PSCustomObject]@{
                tenantId = "10000000-0000-0000-0000-000000000000"
            }

            Mock az { $tenantIdFoundMock | ConvertTo-Json } -ParameterFilter { "$args" -match 'account list' }

            # Simulate the behavior of the execution of the 'az ad app list' command
            $oneAppFoundMock = [PSCustomObject]@{
                displayName = "Existing Mock App"
                appId = "00000000-0000-0000-0000-000000000000"
            }

            $multipleAppFoundMock = @($oneAppFoundMock, $oneAppFoundMock)

            # Simulate the behavior of the execution of the 'az ad app create' command
            $appCreated = [PSCustomObject]@{
                displayName = "New Mock App"
                appId = "00000000-0000-0000-0000-000000000000"
            }

            Mock az { $appCreated | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app create' }

            # Simulate the behavior of the execution of the 'az ad app permission admin-consent' command
            Mock az { } -ParameterFilter { "$args" -match 'ad app permission admin-consent' }

            # Simulate the behavior of the execution of the 'az ad app permission list-grants' command
            $appCreatedGrants = [PSCustomObject]@{
                displayName = "New Mock App"
            }

            Mock az { $appCreatedGrants | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app permission list-grants' }

            # Simulate the behavior of the execution of the 'az ad app credential reset' command
            $appCreatedReset = [PSCustomObject]@{
                password = "0000000000000000000000000000"
            }

            Mock az { $appCreatedReset | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app credential reset' }

            # Definition of the exepcted results of the tests of the this context
            $expectedResultExistingAppFound = [PSCustomObject]@{
                DisplayName = "Existing Mock App"
                ApplicationId = "00000000-0000-0000-0000-000000000000"
                TenantId = "10000000-0000-0000-0000-000000000000"
                Password = ""
                Type = "Existing"
            }

            $expectedResultNewAppCreated = [PSCustomObject]@{
                DisplayName = "New Mock App"
                ApplicationId = "00000000-0000-0000-0000-000000000000"
                TenantId = "10000000-0000-0000-0000-000000000000"
                Password = "0000000000000000000000000000"
                Type = "Created"
            }

            $expectedResultErrorMultipleAppFound = [PSCustomObject]@{
                Error = "Error - Multiple app registration corresponding to the following display name: Existing Mock App"
            }
        }

        It "Given the display name of an existing app registration, it should return the information of the app found" {
            Mock az { $oneAppFoundMock | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app list' }

            (New-AzureAdAppRegistration -DisplayName "Existing Mock App" -ManifestPath ".\existingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultExistingAppFound | ConvertTo-Json)
        }

        It "Given the display name of an existing app registration, it should not call the 'az ad app create' command" {
            Mock az { $oneAppFoundMock | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app list' }

            New-AzureAdAppRegistration -DisplayName "Existing Mock App" -ManifestPath ".\existingmanifestfile.json"
            
            Should -Invoke -CommandName "az" -Exactly -Times 0 -ParameterFilter { "$args" -match 'ad app create' }
        }

        It "Given the display name of a non existing app registration, it should return the information of the new app registration created" {
            Mock az { } -ParameterFilter { "$args" -match 'ad app list' }

            (New-AzureAdAppRegistration -DisplayName "New Mock App" -ManifestPath ".\existingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultNewAppCreated | ConvertTo-Json)
        }

        It "Given the display name of a non existing app registration, it should call the 'az ad app create' command once" {
            Mock az { } -ParameterFilter { "$args" -match 'ad app list' }

            New-AzureAdAppRegistration -DisplayName "New Mock App" -ManifestPath ".\existingmanifestfile.json"
            
            Should -Invoke -CommandName "az" -Exactly -Times 1 -ParameterFilter { "$args" -match 'ad app create' }
        }

        It "Given the display name corresponding to multiple app registrations, it should return the information an error" {
            Mock az { $multipleAppFoundMock | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app list' }

            (New-AzureAdAppRegistration -DisplayName "Existing Mock App" -ManifestPath ".\existingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultErrorMultipleAppFound | ConvertTo-Json)
        }

        It "Given the display name corresponding to multiple app registrations, it should not call the 'az ad app create' command" {
            Mock az { $multipleAppFoundMock | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app list' }

            New-AzureAdAppRegistration -DisplayName "Existing Mock App" -ManifestPath ".\existingmanifestfile.json"
            
            Should -Invoke -CommandName "az" -Exactly -Times 0 -ParameterFilter { "$args" -match 'ad app create' }
        }
    }

    Context "Behavior verification regarding the steps after the creation of an app registration" {
        BeforeEach{
            # Simulate the behavior of the execution of the 'Test-Path' command
            Mock Test-Path { $true } -ParameterFilter { $Path -eq ".\existingmanifestfile.json" }

            # Simulate the behavior of the execution of the 'az account list' command
            $tenantIdFoundMock = [PSCustomObject]@{
                tenantId = "10000000-0000-0000-0000-000000000000"
            }

            Mock az { $tenantIdFoundMock | ConvertTo-Json } -ParameterFilter { "$args" -match 'account list' }

            # Simulate the behavior of the execution of the 'az ad app list' command
            Mock az { } -ParameterFilter { "$args" -match 'ad app list' }

            # Simulate the behavior of the execution of the 'az ad app list' command
            $oneAppFoundMock = [PSCustomObject]@{
                displayName = "Existing Mock App"
                appId = "00000000-0000-0000-0000-000000000000"
            }

            $multipleAppFoundMock = @($oneAppFoundMock, $oneAppFoundMock)

            # Simulate the behavior of the execution of the 'az ad app create' command
            $appCreated = [PSCustomObject]@{
                displayName = "New Mock App"
                appId = "00000000-0000-0000-0000-000000000000"
            }

            # Simulate the behavior of the execution of the 'az ad app permission admin-consent' command
            Mock az { } -ParameterFilter { "$args" -match 'ad app permission admin-consent' }

            # Simulate the behavior of the execution of the 'az ad app permission list-grants' command
            $appCreatedGrants = [PSCustomObject]@{
                displayName = "New Mock App"
            }

            # Simulate the behavior of the execution of the 'az ad app credential reset' command
            $appCreatedReset = [PSCustomObject]@{
                password = "0000000000000000000000000000"
            }

            # Definition of the exepcted results of the tests of the this context
            $expectedResultNewAppCreated = [PSCustomObject]@{
                DisplayName = "New Mock App"
                ApplicationId = "00000000-0000-0000-0000-000000000000"
                TenantId = "10000000-0000-0000-0000-000000000000"
                Password = "0000000000000000000000000000"
                Type = "Created"
            }

            $expectedResultErrorAppRegistrationCreation = [PSCustomObject]@{
                Error = "Error in the creation of the app registration"
            }

            $expectedResultErrorAdminGrant = [PSCustomObject]@{
                Error = "Error in the admin consent for the app registration created"
            }
    
            $expectedResultErrorCredentialReset = [PSCustomObject]@{
                Error = "Error in the app credential reset for the app registration created"
            }
        }

        It "Given the creation of a new app registration without error, it should return the information of the new app registration created" {
            Mock az { $appCreated | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app create' }
            Mock az { $appCreatedGrants | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app permission list-grants' }
            Mock az { $appCreatedReset | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app credential reset' }

            (New-AzureAdAppRegistration -DisplayName "New Mock App" -ManifestPath ".\existingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultNewAppCreated | ConvertTo-Json)
        }

        It "Given an error during the creation of a new app registration, it should return an error mentioning something went wrong in the creation of the app registration" {
            Mock az { } -ParameterFilter { "$args" -match 'ad app create' }

            (New-AzureAdAppRegistration -DisplayName "New Mock App" -ManifestPath ".\existingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultErrorAppRegistrationCreation | ConvertTo-Json)
        }

        It "Given an error during the admin consent step after the creation of a new app registration, it should return an error mentioning something went wrong in the admin consent" {
            Mock az { $appCreated | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app create' }
            Mock az { } -ParameterFilter { "$args" -match 'ad app permission list-grants' }

            (New-AzureAdAppRegistration -DisplayName "New Mock App" -ManifestPath ".\existingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultErrorAdminGrant | ConvertTo-Json)
        }

        It "Given an error during the credential reset step after the creation of a new app registration, it should return an error mentioning something went wrong in the credential reset" {
            Mock az { $appCreated | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app create' }
            Mock az { $appCreatedGrants | ConvertTo-Json } -ParameterFilter { "$args" -match 'ad app permission list-grants' }
            Mock az { } -ParameterFilter { "$args" -match 'ad app credential reset' }

            (New-AzureAdAppRegistration -DisplayName "New Mock App" -ManifestPath ".\existingmanifestfile.json" | ConvertTo-Json) | Should -Be ($expectedResultErrorCredentialReset | ConvertTo-Json)
        }
    }
}

# New-AzureAdAppRegistration tests with integrations with external dependencies
#   Prerequisites: To execute the following tests you need to be authenticated using the 'az login' command
Describe "New-AzureAdAppRegistration Integration Tests" -Tag "IntegrationTests" {
    Context "Integration tests with the commands of the Azure CLI" {
        BeforeEach{
            # Initialise a variable for the display name of the app registration considered in the tests of this context
            $appRegistrationDisplayName = "Test auto $(Get-Date -format 'yyyyMMdd')"

            # Get the ID of the tenant
            $tenantList = az account list | ConvertFrom-Json
            $tenantId = $tenantList[0].tenantId

            # Definition of the exepcted results of the tests of the this context
            $expectedResultErrorAppRegistrationCreation = [PSCustomObject]@{
                Error = "Error in the creation of the app registration"
            }
        }

        It "Given a correct path to a manifest file with incorrect content and the display name of a non-existing app registration, it should return an error mentioning something went wrong in the creation of the app registration" {
            $manifestFileContentWithIncorrectContent = "WrongContent"

            $manifestFileContentWithIncorrectContent | ConvertTo-Json | Out-File ".\wrongmanifest.json"

            (New-AzureAdAppRegistration -DisplayName $appRegistrationDisplayName -ManifestPath ".\wrongmanifest.json" | ConvertTo-Json) | Should -Be ($expectedResultErrorAppRegistrationCreation | ConvertTo-Json)

            Remove-Item .\wrongmanifest.json
        }

        It "Given a correct path a correct manifest file and the display name of a non-existing app registration, it should return the information of the new app registration created" {
            $newAppRegistration = New-AzureAdAppRegistration -DisplayName $appRegistrationDisplayName -ManifestPath ".\config\manifest.json"

            $newAppRegistration.DisplayName | Should -Be $appRegistrationDisplayName
            $newAppRegistration.ApplicationId | Should -Not -BeNullOrEmpty
            $newAppRegistration.TenantId | Should -Be $tenantId
            $newAppRegistration.Password | Should -Not -BeNullOrEmpty
            $newAppRegistration.Type | Should -Be "Created"
        }

        It "Given a correct path a correct manifest file and the display name of an existing app registration, it should return the information of the app registration found" {
            $existingAppRegistration = New-AzureAdAppRegistration -DisplayName $appRegistrationDisplayName -ManifestPath ".\config\manifest.json"

            $existingAppRegistration.DisplayName | Should -Be $appRegistrationDisplayName
            $existingAppRegistration.ApplicationId | Should -Not -BeNullOrEmpty
            $existingAppRegistration.TenantId | Should -Be $tenantId
            $existingAppRegistration.Password | Should -BeNullOrEmpty
            $existingAppRegistration.Type | Should -Be "Existing"

            # Delete the app registration created in the previous test
            az ad app delete --id $existingAppRegistration.ApplicationId
        }
    }
}