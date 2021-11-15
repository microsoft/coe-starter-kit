>  [!IIMPORTANT] This release includes the use of an update in the platform that will not be released to the following geos (SPL, GCC, USG, CHN) until the last week in July. If you are using AA4AM in one of these geos please wait to upgrade until August 1st 2021.

## Issues and new features in this release:

https://github.com/microsoft/coe-starter-kit/milestone/10

## First Time Setup Instructions
To get started with the ALM Accelerator For Advanced Makers you can
1. Use the preview CoE CLI to automate the install at https://github.com/microsoft/coe-starter-kit/blob/main/coe-cli/docs/aa4am/readme.md or in the [Power Platform CoE CLI E-Book](https://aka.ms/coe-cli-ebook)
2. Use the  manual setup documentation can be found at https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md


## Upgrade Instructions
If you are upgrading to the latest release you will need to perform the following steps.
- Import the latest AA4AM Solution https://github.com/microsoft/coe-starter-kit/releases/download/ALMAcceleratorForAdvancedMakers-July2021/ALMAcceleratorForAdvancedMakers.zip

- Update your pipeline templates repo with the latest from https://github.com/microsoft/coe-alm-accelerator-templates

- Update Custom Connector Authentication https://github.com/microsoft/coe-starter-kit/blob/ALMAcceleratorForAdvancedMakers/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md#configure-the-azure-devops-custom-connector

- Export solutions with Canvas Apps using latest version of AA4AM. 

  > [!NOTE] AA4AM use a preview version of the Power Apps Source File Pack and Unpack Utility (https://github.com/microsoft/PowerApps-Language-Tooling/blob/master/README.md). As such while AA4AM is still in public preview we are updating our pipelines to stay in sync with the latest releases of the Pack / Unpack utility. The Pack / Unpack utility is not backwards compatible while in preview meaning the version used to unpack must be the same as the version used to pack. If you have previously unpacked Canvas Apps using a previous version of AA4AM you will not be able to repack those apps. Therefore, you must export your solutions to source control again using the latest version so the formats match.
  
- In this release we have updated the pipelines to allow for using a deployment configuration file stored in source control as an option rather than using Pipeline variables for the json configuration of Connection References, Component Ownership, App Sharing etc. There is a new doc included on how to setup your deployment configuration file and use variable substitution techniques to secure sensitive data from being source controlled. [DEPLOYMENTCONFIGGUIDE.md](https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/DEPLOYMENTCONFIGGUIDE.md).

  > [!NOTE] If you have previously configured your pipelines using pipeline variables you are not required to switch to using the deployment configuration file and the pipelines will continue to fall back to using pipeline variables in the absence of a deployment configuration file for the environment to which a solution is deployed. However, future updates to the Power Platform build tool will be reliant on a deployment configuration file so you may want to consider moving to this standard now.

- The list of Azure DevOps extensions required for the AA4AM pipelines has been updated. Double check this list to ensure you have the correct extensions installed. Any extension that has been removed from the list can be safely removed [Install Azure DevOps Extensions](https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md#install-azure-devops-extensions).