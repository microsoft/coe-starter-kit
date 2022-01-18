## Issues and new features in this release:

https://github.com/microsoft/coe-starter-kit/milestone/16?closed=1

## First Time Setup Instructions
To get started with the ALM Accelerator For Power Platform you can use the CoE CLI to automate the install at https://docs.microsoft.com/en-us/power-platform/guidance/coe/setup-almacceleratorpowerplatform-cli

## Upgrade Instructions
If you are upgrading to the latest release you will need to perform the following steps.

- **Delete the existing ALM Accelerator for Advanced Makers solution**. 

  NOTE: We've changed the internal name of the ALM Accelerator solution in this release. As a result you will need to delete the existing solution, which will cause your App Settings to reset. The history of previous commits and deployments in the app will be lost, but the history will remain in Azure DevOps.

- Import the latest managed AA4PP Solution https://github.com/microsoft/coe-starter-kit/releases/download/ALMAcceleratorForAdvancedMakers-January2022/

- Update your pipeline templates repo with the latest from https://github.com/microsoft/coe-alm-accelerator-templates/archive/refs/tags/ALMAcceleratorForAdvancedMakers-January2022.zip

## Additional Setup Instructions

- Update the Azure DevOps Build Service Permissions to allow the pipelines to create deployment pipelines. 
  
  NOTE: In the latest release, the pipeline which is executed when a solution is committed to source control, will create the associated deployment pipelines automatically if they don't exist. As a result the pipelines need permissions to access resources in Azure DevOps via the following configuration in Azure DevOps.
  
  - Follow the instructions here to update the appropriate permissions (https://docs.microsoft.com/en-us/power-platform/guidance/coe/setup-almacceleratorpowerplatform#update-permissions-for-the-project-build-service)

- Register service principal as management application

  NOTE: In order for the pipelines to perform certain actions (for example Sharing Apps) against the environments in your Power Platform tenant you will need to grant Power App Management permissions to your App registration. To do so you will need to run the following PowerShell commandlet as an interactive user that has Power Apps administrative privileges. You will need to run this command once, using an interactive user, in PowerShell after your app registration has been created. The command gives permissions to the Service Principal to be able to execute environment related functions including querying for environments and connections via Microsoft.PowerApps.Administration.PowerShell (https://docs.microsoft.com/en-us/powershell/module/microsoft.powerapps.administration.powershell/new-powerappmanagementapp?view=pa-ps-latest). For more information on the **New-PowerAppManagementApp** cmdlet see here https://docs.microsoft.com/en-us/powershell/module/microsoft.powerapps.administration.powershell/new-powerappmanagementapp?view=pa-ps-latest
  > Currently this commandlet gives elevated permissions (e.g. Power Platform Admin) to the app registration. Your organization's security policies may not allow for these types of permissions. Ensure that these permissions are allowed before continuing. In the case that these elevated permissions are not allowed you will not be able to use the AA4AM pipelines.

  ```powershell
  Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
  Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber
  New-PowerAppManagementApp -ApplicationId [the Application (client) ID you copied when creating your app registration]
  ```