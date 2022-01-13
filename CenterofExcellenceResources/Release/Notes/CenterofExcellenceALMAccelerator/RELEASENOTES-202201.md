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