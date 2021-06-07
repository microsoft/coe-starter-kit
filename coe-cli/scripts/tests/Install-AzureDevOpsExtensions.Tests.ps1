BeforeAll {
    # Import Install-AzureDevOpsExtensions function
    Import-Module (Join-Path ( ([System.IO.Path]::GetDirectoryName($PSCommandPath))) ".." "Install-AzureDevOpsExtensions.ps1") -Force
}

# Install-AzureDevOpsExtensions tests without integrations with other modules
Describe "Install-AzureDevOpsExtensions Unit Tests" -Tag "UnitTests" {
    Context "Parameters configuration verification" {
        It "Given the Mandatory attribute of the OrganizationUrl parameter, it should be equal to true" {
            (Get-Command Install-AzureDevOpsExtensions).Parameters['OrganizationUrl'].Attributes.Mandatory | Should -Be $true
        }

         It "Given the Mandatory attribute of the ExtensionsFilePath parameter, it should be equal to true" {
            (Get-Command Install-AzureDevOpsExtensions).Parameters['ExtensionsFilePath'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Verification of the file with the Azure DevOps extensions details" {
        BeforeEach{
            $organizationUrl = $env:TestDevOpsOrganization
            $correctExistingExtensionsFilePath = ".\correctexistingextensionsfile.json"
            $emptyExistingExtensionsFilePath = ".\emptyexistingextensionsfile.json"
            $wrongFormatExistingExtensionsFilePath = ".\wrongformatexistingextensionsfile.json"
            $nonExistingExtensionsFilePath = ".\nonexistingextensionsfile.json"
            $emptyExistingExtensionsFileContent = [PSCustomObject]@{}
            $wrongFormatExistingExtensionsFileContent = "/wrong/"
            $extensionDetails = [PSCustomObject]@{
                publisherName = "microsoft-IsvExpTools"
                extensionName = "PowerPlatform-BuildTools"
            }

            # Simulate the behavior of the execution of the 'Test-Path' command
            Mock Test-Path { $true } -ParameterFilter { $Path -eq $emptyExistingExtensionsFilePath }
            Mock Test-Path { $true } -ParameterFilter { $Path -eq $wrongFormatExistingExtensionsFilePath }
            Mock Test-Path { $true } -ParameterFilter { $Path -eq $correctExistingExtensionsFilePath }
            Mock Test-Path { $false } -ParameterFilter { $Path -eq $nonExistingExtensionsFilePath }

            # Simulate the behavior of the execution of the 'Get-Content' command
            Mock Get-Content { $emptyExistingExtensionsFileContent } -ParameterFilter { $Path -eq $emptyExistingExtensionsFilePath }
            Mock Get-Content { $wrongFormatExistingExtensionsFileContent } -ParameterFilter { $Path -eq $wrongFormatExistingExtensionsFilePath }
            Mock Get-Content { $extensionDetails | ConvertTo-Json } -ParameterFilter { $Path -eq $correctExistingExtensionsFilePath }

            # Simulate the behavior of the execution of the 'az devops extension list' command
            $extensionListResult = [PSCustomObject]@{}

            Mock az { $extensionListResult | ConvertTo-Json } -ParameterFilter { "$args" -match 'devops extension list' }

            # Simulate the behavior of the execution of the 'az devops extension show' command
            $extensionShowResult = [PSCustomObject]@{}

            Mock az { $extensionShowResult | ConvertTo-Json } -ParameterFilter { "$args" -match 'devops extension show' }

            # Definition of the exepcted results of the tests of the this context
            $expectedResultCorrectExistingExtensionsFile = [PSCustomObject]@{
                ExtensionFullName = "microsoft-IsvExpTools.PowerPlatform-BuildTools"
                Type = "Already installed"
            }

            $expectedResultErrorNonExistingExtensionsFile = [PSCustomObject]@{
                Error = "Error in the path provided for the extensions details: $nonExistingExtensionsFilePath"
            }

            $expectedResultErrorEmptyExistingExtensionsFile = [PSCustomObject]@{
                Error = "No Azure DevOps extensions details found in the file in following location : $emptyExistingExtensionsFilePath"
            }

            $expectedResultErrorWrongFormatExistingExtensionsFile = [PSCustomObject]@{
                Error = "Error in the extraction of the extensions details from the considered file ($wrongFormatExistingExtensionsFilePath): "
            }
        }

        It "Given the path to a non existing file with extensions details, it should return an error about the wrong path to the file" {
            (Install-AzureDevOpsExtensions -OrganizationUrl $organizationUrl -ExtensionsFilePath $nonExistingExtensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResultErrorNonExistingExtensionsFile | ConvertTo-Json)
        }

        It "Given the path to an existing but empty file with extensions details, it should return an error about the absence of extensions details" {
            (Install-AzureDevOpsExtensions -OrganizationUrl $organizationUrl -ExtensionsFilePath $emptyExistingExtensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResultErrorEmptyExistingExtensionsFile | ConvertTo-Json)
        }

        It "Given the path to an existing extensions details file but with a wrong format, it should return an error about the extraction of the content from the file" {
            (Install-AzureDevOpsExtensions -OrganizationUrl $organizationUrl -ExtensionsFilePath $wrongFormatExistingExtensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResultErrorWrongFormatExistingExtensionsFile | ConvertTo-Json)
        }

        It "Given the path to a correct existing extensions details file with only one extension already installed and a valid organization URL, it should return the considered extension with a type 'Already installed'" {
            (Install-AzureDevOpsExtensions -OrganizationUrl $organizationUrl -ExtensionsFilePath $correctExistingExtensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResultCorrectExistingExtensionsFile | ConvertTo-Json)
        }
    }

    Context "Behavior verification regarding the Azure DevOps organization URL provided" {
        BeforeEach{
            $validOrganizationUrl = "https://dev.azure.com/Demonstration"
            $wrongOrganizationUrl = "https://dev.azure.com/WrongDemonstration"
            $extensionsFilePath = ".\extensionsfile.json"
            $extensionDetails = [PSCustomObject]@{
                publisherName = "microsoft-IsvExpTools"
                extensionName = "PowerPlatform-BuildTools"
            }

            # Simulate the behavior of the execution of the 'Test-Path' command
            Mock Test-Path { $true } -ParameterFilter { $Path -eq $extensionsFilePath }

            # Simulate the behavior of the execution of the 'Get-Content' command
            Mock Get-Content { $extensionDetails | ConvertTo-Json } -ParameterFilter { $Path -eq $extensionsFilePath }

            # Simulate the behavior of the execution of the 'az devops extension list' command
            $extensionListResult = [PSCustomObject]@{}

            # Simulate the behavior of the execution of the 'az devops extension show' command
            $extensionShowResult = [PSCustomObject]@{}

            Mock az { $extensionShowResult | ConvertTo-Json } -ParameterFilter { "$args" -match 'devops extension show' }

            # Definition of the exepcted results of the tests of the this context
            $expectedResultValidOrganizationUrl = [PSCustomObject]@{
                ExtensionFullName = "microsoft-IsvExpTools.PowerPlatform-BuildTools"
                Type = "Already installed"
            }

            $expectedResulErrortWrongOrganizationUrl = [PSCustomObject]@{
                Error = "Error in the verification of the existence of the following Azure DevOps organization: $wrongOrganizationUrl"
            }
        }

        It "Given a valid organization URL and an extension already installed, it should return the considered extension with a type 'Already installed'" {
            Mock az { $extensionListResult | ConvertTo-Json } -ParameterFilter { "$args" -match 'devops extension list' }

            (Install-AzureDevOpsExtensions -OrganizationUrl $validOrganizationUrl -ExtensionsFilePath $extensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResultValidOrganizationUrl | ConvertTo-Json)
        }

        It "Given a wrong organization URL and an extension already installed, it should return an error regarding the organization URL provided" {
            Mock az { $null } -ParameterFilter { "$args" -match 'devops extension list' }
            
            (Install-AzureDevOpsExtensions -OrganizationUrl $wrongOrganizationUrl -ExtensionsFilePath $extensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResulErrortWrongOrganizationUrl | ConvertTo-Json)
        }
    }

    Context "Behavior verification for the installation of an extension" {
        BeforeEach{
            $organizationUrl = $env:TestDevOpsOrganization
            $extensionsFilePath = ".\extensionsfile.json"
            $extensionDetails = [PSCustomObject]@{
                publisherName = "microsoft-IsvExpTools"
                extensionName = "PowerPlatform-BuildTools"
            }
            $extensionPublisherName = $extensionDetails.publisherName
            $extensionName = $extensionDetails.extensionName
            $extensionFullName = "$extensionPublisherName.$extensionName"

            # Simulate the behavior of the execution of the 'Test-Path' command
            Mock Test-Path { $true } -ParameterFilter { $Path -eq $extensionsFilePath }

            # Simulate the behavior of the execution of the 'Get-Content' command
            Mock Get-Content { $extensionDetails | ConvertTo-Json } -ParameterFilter { $Path -eq $extensionsFilePath }

            # Simulate the behavior of the execution of the 'az devops extension list' command
            $extensionListResult = [PSCustomObject]@{}

            Mock az { $extensionListResult | ConvertTo-Json } -ParameterFilter { "$args" -match 'devops extension list' }

            # Simulate the behavior of the execution of the 'az devops extension show' command
            $extensionShowResult = [PSCustomObject]@{}

            # Simulate the behavior of the execution of the 'az devops extension install' command
            $extensionInstallResult = [PSCustomObject]@{}

            # Definition of the exepcted results of the tests of the this context
            $expectedResultExtensionAlreadyInstalled = [PSCustomObject]@{
                ExtensionFullName = "microsoft-IsvExpTools.PowerPlatform-BuildTools"
                Type = "Already installed"
            }

            $expectedResultExtensionNewlyInstalled = [PSCustomObject]@{
                ExtensionFullName = "microsoft-IsvExpTools.PowerPlatform-BuildTools"
                Type = "Newly installed"
            }

            $expectedResulErrortExtensionInstallation = [PSCustomObject]@{
                Error = "Error in the installation of the '$extensionFullName' extension in the following Azure DevOps organization: $organizationUrl"
            }
        }

        It "Given a valid organization URL and an extension already installed, it should return the considered extension with a type 'Already installed'" {
            Mock az { $extensionShowResult } -ParameterFilter { "$args" -match 'devops extension show' }

            (Install-AzureDevOpsExtensions -OrganizationUrl $organizationUrl -ExtensionsFilePath $extensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResultExtensionAlreadyInstalled | ConvertTo-Json)
        }

        It "Given a valid organization URL and an extension not installed, it should return the considered extension with a type 'Newly installed'" {
            Mock az { $null } -ParameterFilter { "$args" -match 'devops extension show' }
            Mock az { $extensionInstallResult } -ParameterFilter { "$args" -match 'devops extension install' }

            (Install-AzureDevOpsExtensions -OrganizationUrl $organizationUrl -ExtensionsFilePath $extensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResultExtensionNewlyInstalled | ConvertTo-Json)
        }

        It "Given a valid organization URL, an extension not installed and an error during this installation, it should return an error about the installation of the extension" {
            Mock az { $null } -ParameterFilter { "$args" -match 'devops extension show' }
            Mock az { $null } -ParameterFilter { "$args" -match 'devops extension install' }

            (Install-AzureDevOpsExtensions -OrganizationUrl $organizationUrl -ExtensionsFilePath $extensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResulErrortExtensionInstallation | ConvertTo-Json)
        }
    }
}

# Install-AzureDevOpsExtensions tests with integrations with external dependencies
#   Prerequisites: To execute the following tests you need to
#       - be authenticated using the 'az login' command
#       - to have a $OrganizationUrl initialized with a valid Azure DevOps organization URL without any extension installed
Describe "Install-AzureDevOpsExtensions Integration Tests" -Tag "IntegrationTests" {
    Context "Integration tests with the commands of the Azure CLI" {
        BeforeEach{
            $organizationUrl = $env:TestDevOpsOrganization
            $mockExtensionsFilePath = ".\extensionsfile.json"
            $extensionsDetails = @()
            $extension1 = [PSCustomObject]@{
                publisherName = "microsoft-IsvExpTools"
                extensionName = "PowerPlatform-BuildTools"
            }
            $extensionPublisherName1 = $extension1.publisherName
            $extensionName1 = $extension1.extensionName
            $extensionFullName1 = "$extensionPublisherName1.$extensionName1"
            $extension2 = [PSCustomObject]@{
                publisherName = "WaelHamze"
                extensionName = "xrm-ci-framework-build-tasks"
            }
            $extensionPublisherName2 = $extension2.publisherName
            $extensionName2 = $extension2.extensionName
            $extensionFullName2 = "$extensionPublisherName2.$extensionName2"
            $extension3 = [PSCustomObject]@{
                publisherName = "colinsalmcorner"
                extensionName = "colinsalmcorner-buildtasks"
            }
            $extensionPublisherName3 = $extension3.publisherName
            $extensionName3 = $extension3.extensionName
            $extensionFullName3 = "$extensionPublisherName3.$extensionName3"
            $extension4 = [PSCustomObject]@{
                publisherName = "knom"
                extensionName = "regexreplace-task"
            }
            $extensionPublisherName4 = $extension4.publisherName
            $extensionName4 = $extension4.extensionName
            $extensionFullName4 = "$extensionPublisherName4.$extensionName4"
            $extension5 = [PSCustomObject]@{
                publisherName = "nkdagility"
                extensionName = "variablehydration"
            }
            $extensionPublisherName5 = $extension5.publisherName
            $extensionName5 = $extension5.extensionName
            $extensionFullName5 = "$extensionPublisherName5.$extensionName5"
            $extensionsDetails += $extension1
            $extensionsDetails += $extension2
            $extensionsDetails += $extension3
            $extensionsDetails += $extension4
            $extensionsDetails += $extension5

            # Simulate the behavior of the execution of the 'Test-Path' command
            Mock Test-Path { $true } -ParameterFilter { $Path -eq $mockExtensionsFilePath }

            # Simulate the behavior of the execution of the 'Get-Content' command
            Mock Get-Content { $extensionsDetails | ConvertTo-Json } -ParameterFilter { $Path -eq $mockExtensionsFilePath }

            # Definition of the exepcted results of the tests of the this context
            $expectedResultExtensionsInstallation = @()
            $newlyInstalledExtension1 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName1
                Type = "Newly installed"
            }
            $newlyInstalledExtension2 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName2
                Type = "Newly installed"
            }
            $newlyInstalledExtension3 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName3
                Type = "Newly installed"
            }
            $newlyInstalledExtension4 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName4
                Type = "Newly installed"
            }
            $newlyInstalledExtension5 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName5
                Type = "Newly installed"
            }
            $expectedResultExtensionsInstallation += $newlyInstalledExtension1
            $expectedResultExtensionsInstallation += $newlyInstalledExtension2
            $expectedResultExtensionsInstallation += $newlyInstalledExtension3
            $expectedResultExtensionsInstallation += $newlyInstalledExtension4
            $expectedResultExtensionsInstallation += $newlyInstalledExtension5

            $expectedResultExtensionsInstalled = @()
            $alreadyInstalledExtension1 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName1
                Type = "Already installed"
            }
            $alreadyInstalledExtension2 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName2
                Type = "Already installed"
            }
            $alreadyInstalledExtension3 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName3
                Type = "Already installed"
            }
            $alreadyInstalledExtension4 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName4
                Type = "Already installed"
            }
            $alreadyInstalledExtension5 = [PSCustomObject]@{
                ExtensionFullName = $extensionFullName5
                Type = "Already installed"
            }
            $expectedResultExtensionsInstalled += $alreadyInstalledExtension1
            $expectedResultExtensionsInstalled += $alreadyInstalledExtension2
            $expectedResultExtensionsInstalled += $alreadyInstalledExtension3
            $expectedResultExtensionsInstalled += $alreadyInstalledExtension4
            $expectedResultExtensionsInstalled += $alreadyInstalledExtension5
        }

        It "Given a valid organization URL and extensions to install, it should return the considered extensions with a type 'Newly installed'" {
            (Install-AzureDevOpsExtensions -OrganizationUrl $organizationUrl -ExtensionsFilePath $mockExtensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResultExtensionsInstallation | ConvertTo-Json)
        }

        It "Given a valid organization URL and extensions already installed, it should return the considered extensions with a type 'Already installed'" {
            (Install-AzureDevOpsExtensions -OrganizationUrl $organizationUrl -ExtensionsFilePath $mockExtensionsFilePath | ConvertTo-Json) | Should -Be ($expectedResultExtensionsInstalled | ConvertTo-Json)
        }
    }
}