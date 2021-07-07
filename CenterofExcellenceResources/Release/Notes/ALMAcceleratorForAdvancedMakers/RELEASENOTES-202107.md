## Issues and new features in this release:
https://github.com/microsoft/coe-starter-kit/milestone/10

## First Time Setup Instructions
To get started with the ALM Accelerator For Advanced Makers the setup documentation can be found at https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md

## Upgrade Instructions
If you are upgrading to the latest release you will need to perform the following steps.
- Import the latest AA4AM Solution https://github.com/microsoft/coe-starter-kit/releases/download/ALMAcceleratorForAdvancedMakers-July2021/ALMAcceleratorForAdvancedMakers.zip

- Update your pipeline templates repo with the latest from https://github.com/microsoft/coe-alm-accelerator-templates

- Update Custom Connector Authentication https://github.com/microsoft/coe-starter-kit/blob/ALMAcceleratorForAdvancedMakers/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md#configure-the-azure-devops-custom-connector

- Export solutions with Canvas Apps using latest version of AA4AM. 

  > [!NOTE] AA4AM use a preview version of the Power Apps Source File Pack and Unpack Utility (https://github.com/microsoft/PowerApps-Language-Tooling/blob/master/README.md). As such while AA4AM is still in public preview we are updating our pipelines to stay in sync with the latest releases of the Pack / Unpack utility. The Pack / Unpack utility is not backwards compatible while in preview meaning the version used to unpack must be the same as the version used to pack. If you have previously unpacked Canvas Apps using a previous version of AA4AM you will not be able to repack those apps. Therefore, you must export your solutions to source control again using the latest version so the formats match.