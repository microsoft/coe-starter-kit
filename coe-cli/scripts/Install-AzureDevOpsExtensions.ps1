Function Install-AzureDevOpsExtensions {
    <#
        .SYNOPSIS
            Install extensions in a targeted Azure DevOps organization if it is not already the case.

        .DESCRIPTION
            For each provided extensions and for the targeted Azure DevOps organization:
                - check if is already installed
                - install it if it is not already the case

        .PARAMETER OrganizationUrl
            Specifies the URL of the targeted Azure DevOps organization.

        .PARAMETER ExtensionsFilePath
            Specifies the path to the file containing the information of the Azure DevOps extensions to install in the targeted organization.

        .INPUTS
            None. You cannot pipe objects to Install-AzureDevOpsExtensions.

        .OUTPUTS
            Object. Install-AzureDevOpsExtensions returns information regarding the extensions installed in the targeted Azure DevOps organization.

        .EXAMPLE
            PS> Install-AzureDevOpsExtensions -OrganizationUrl "https://dev.azure.com/Demonstration" -ExtensionsFilePath .\AzureDevOpsExtensions.json
            ExtensionFullName                               Type
            -----------------                               ----
            microsoft-IsvExpTools.PowerPlatform-BuildTools  Already installed
            WaelHamze.xrm-ci-framework-build-tasks          Already installed
            colinsalmcorner.colinsalmcorner-buildtasks      Newly installed
            knom.regexreplace-task                          Newly installed
            nkdagility.variablehydration                    Newly installed

        .LINK
            README.md: https://github.com/microsoft/coe-starter-kit/tree/main/PowerPlatformDevOpsALM/SetupAutomation

        .NOTES
            * You need to be authenticated with an account with the permissions to install extensions in Azure DevOps organizations using the "az login" (Azure CLI) command to be able to use this function
    #>

    [CmdletBinding()]
    [OutputType([psobject])]
    Param (
        # URL of the targeted Azure DevOps organization
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$OrganizationUrl,

        # Path to the file containing the information of the Azure DevOps extensions to install
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$ExtensionsFilePath
    )

    Begin{}

    Process{
        # Init output variable
        $azureDevOpsExtensionsInstallationResult = [PSCustomObject]@{}
        
        # Test the path provided to the file with the extensions details
        Write-Verbose "Test the path provided to the file with the extensions details: $ExtensionsFilePath"
        Write-Debug "Before the call to the 'Test-Path' command..."
        if(Test-Path $ExtensionsFilePath) {
            $exentionsFilePathValidated = $true
        }
        else {
            Write-Verbose "Error in the path provided for the extensions details: $ExtensionsFilePath"
            $exentionsFilePathValidated = $false
            $errorMessage = "Error in the path provided for the extensions details: $ExtensionsFilePath"
            $azureDevOpsExtensionsInstallationResult | Add-Member -MemberType NoteProperty -Name "Error" -Value $errorMessage
        }

        # Continue only if the path provided for the file with the extensions details is correct
        if ($exentionsFilePathValidated) {
            # Extract Azure DevOps extension details
            Write-Verbose "Get content from file with the extensions details in following location: $ExtensionsFilePath"
            try {
                Write-Verbose "Try to call the Get-Content command."
                Write-Debug "Before the call to the Get-Content command..."
                $azureDevOpsExtensions = Get-Content $ExtensionsFilePath -ErrorVariable getExtensionsDetailsError -ErrorAction Stop | ConvertFrom-Json
            }
            catch {
                Write-Verbose "Error in the extraction of the extensions details from the considered file ($ExtensionsFilePath): $getExtensionsDetailsError"
                $errorMessage = "Error in the extraction of the extensions details from the considered file ($ExtensionsFilePath): $getExtensionsDetailsError"
                $azureDevOpsExtensionsInstallationResult | Add-Member -MemberType NoteProperty -Name "Error" -Value $errorMessage
            }
            
            # Get the number of extensions in the file
            $azureDevOpsExtensionsMeasure = $azureDevOpsExtensions | Measure
            $azureDevOpsExtensionsCount = $azureDevOpsExtensionsMeasure.count

            # If no extensions details found in the file return an error
            if ($azureDevOpsExtensionsCount -eq 0 -and $azureDevOpsExtensionsInstallationResult.Error -eq $null) {
                Write-Verbose "No Azure DevOps extensions details found in the file in following location : $ExtensionsFilePath"
                $errorMessage = "No Azure DevOps extensions details found in the file in following location : $ExtensionsFilePath"
                $azureDevOpsExtensionsInstallationResult | Add-Member -MemberType NoteProperty -Name "Error" -Value $errorMessage
            }

            # Continue only if extensions details extracted from file
            if ($azureDevOpsExtensionsCount -gt 0) {
                # Check the provided Azure DevOps organization URL provided (call to the 'az devops extension list' command)
                # List non built in and non disabled extensions for the considered Azure DevOps organization
                Write-Verbose "Try to call the 'az devops extension list' command for the following Azure DevOps organization: $OrganizationUrl"
                Write-Debug "Before the call to the 'az devops extension list' command..."
                $organizationNonBuiltInExtensions = az devops extension list --org $OrganizationUrl --include-built-in false

                # Case Azure DevOps organization does not exist
                if(!$organizationNonBuiltInExtensions) {
                    Write-Verbose "Error in the verification of the existence of the following Azure DevOps organization: $OrganizationUrl"
                    $errorMessage = "Error in the verification of the existence of the following Azure DevOps organization: $OrganizationUrl"
                    $azureDevOpsExtensionsInstallationResult | Add-Member -MemberType NoteProperty -Name "Error" -Value $errorMessage
                }
                # Case Azure DevOps organization exists
                else {
                    # Set output variable as an array
                    $azureDevOpsExtensionsInstallationResult = @()

                    # For each extension we got from the file...
                    foreach ($azureDevOpsExtension in $azureDevOpsExtensions) {
                        $extensionPublisherName = $azureDevOpsExtension.publisherName
                        $extensionName = $azureDevOpsExtension.extensionName
                        $extensionFullName = "$extensionPublisherName.$extensionName"

                        # See if this extension is already installed for the considered Azure DevOps organization (using the 'az devops extension show' command)
                        Write-Verbose "Try to call the 'az devops extension show' command for the following extension: $extensionFullName"
                        Write-Debug "Before the call to the 'az devops extension show' command..."
                        $extensionSearchResult = az devops extension show --org $OrganizationUrl --publisher-id $extensionPublisherName --extension-id $extensionName

                        # Case extension not already installed
                        if(!$extensionSearchResult) {
                            # Install this extension for the considered Azure DevOps organization (using the 'az devops extension install' command)
                            Write-Verbose "Try to call the 'az devops extension install' command for the following extension: $extensionFullName"
                            Write-Debug "Before the call to the 'az devops extension install' command..."
                            $extensionInstallation = az devops extension install --org $OrganizationUrl --publisher-id $extensionPublisherName --extension-id $extensionName

                            # Case error in the installation of the extension
                            if (!$extensionInstallation) {
                                Write-Verbose "Error in the installation of the '$extensionFullName' extension in the following Azure DevOps organization: $OrganizationUrl"
                                $errorMessage = "Error in the installation of the '$extensionFullName' extension in the following Azure DevOps organization: $OrganizationUrl"
                                $installedExtension = [PSCustomObject]@{
                                    Error = $errorMessage
                                }
                                $azureDevOpsExtensionsInstallationResult += $installedExtension
                            }
                            # Case installation of the extension done correctly
                            else {
                                # Add extension information to output variable
                                $installedExtension = [PSCustomObject]@{
                                    ExtensionFullName = $extensionFullName
                                    Type = "Newly installed"
                                }
                                $azureDevOpsExtensionsInstallationResult += $installedExtension
                            }
                        }
                        # Case extension already installed
                        else {
                            # Add extension information to output variable
                            $installedExtensionFound = [PSCustomObject]@{
                                ExtensionFullName = $extensionFullName
                                Type = "Already installed"
                            }
                            $azureDevOpsExtensionsInstallationResult += $installedExtensionFound
                        }
                    } 
                }
            }
        }

        # Return the result of the Azure DevOps extensions installation
        Write-Verbose "Return the result of the Azure DevOps extensions installation."
        Write-Debug "Before sending the output..."
        $azureDevOpsExtensionsInstallationResult
    }

    End{}
}