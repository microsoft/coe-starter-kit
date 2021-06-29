# Overview

As you deploy and use the AA4AM CLI it is important to understand the following key concepts that the CLI is automating.

## Azure Active Directory 

### Azure Active Directory Application

The CLI application can create a Azure Active Directory application that automate the following key steps.

1. User authenticated via Azure CLI
   - [Azure Login](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az_login)
   - [Source Reference - login Method](../../src/commands/login.ts)

2. Create Azure Active Directory Application using Azure CLI
   - [Create AD Application](https://docs.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest#az_ad_app_create)
   - [Create Service Principal](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az_ad_sp_create)
   - [Source Reference - installAADApplication](../../src/commands/aad.ts)

3. Grant Tenant Consent for Applications using Azure CLI
   - [Permissions Admin Consent](https://docs.microsoft.com/en-us/cli/azure/ad/app/permission?view=azure-cli-latest#az_ad_app_permission_admin_consent)

4. Azure Application Granted rights via [manifest config](../../config/manifest.json) to call
   - Azure DevOps
   - Dataverse
   - PowerApps Checker Module - [Read More](https://docs.microsoft.com/en-us/powershell/powerapps/get-started-powerapps-checker?view=pa-ps-latest)

5. Client secrets will be created for Azure DevOps Service Connections

   - Client secrets should have an established key rotation process to generate new keys for connections

   - After new keys are generated old keys should be removed

### Azure Active Directory Group

The CLI application can create a Azure Active Directory group that is used for Azure DevOps and Power Platform authentication and role based access security.

1. Group Created via Azure CLI
   - [Create Group](https://docs.microsoft.com/en-us/cli/azure/ad/group?view=azure-cli-latest#az_ad_group_create)

   - [Source Reference - installAADGroup](../../src/commands/aad.ts)

## Azure DevOps

### Install Automation

The CLI application assumes that an Azure DevOps organization and project have already been created. it performs the following key steps

1. Source reference [devops.ts - DevOpsCommand](../../src/commands/devops.ts)

1. Install Azure DevOps Extensions defined in [AzureDevOpsExtensionsDetails.json](../../config/AzureDevOpsExtensionsDetails.json) (Source reference - installExtensions)

2. Clone Azure Templates https://github.com/microsoft/coe-alm-accelerator-templates.git into a Azure DevOps git repository named **pipelines** by default  (Source reference - importPipelineRepository).

3. Create Azure DevOps build pipelines (Source reference - createAdvancedMakersBuildPipelines)
  
- [export-solution-to-git.yml](https://github.com/microsoft/coe-alm-accelerator-templates/blob/main/Pipelines/export-solution-to-git.yml) - Export a solution from a Dataverse environment and commit it to a git branch.

- [import-unmanaged-to-dev-environment.yml](https://github.com/microsoft/coe-alm-accelerator-templates/blob/main/Pipelines/import-unmanaged-to-dev-environment.yml) - Import solution into Dataverse environment

- [delete-unmanaged-solution-and-components.yml](https://github.com/microsoft/coe-alm-accelerator-templates/blob/main/Pipelines/delete-unmanaged-solution-and-components.yml) - Delete or "clean up" an unmanaged solution from a Dataverse environment

4. Setup Azure Active Group access the Azure DevOps project (Source reference - setupSecurity)

5. Create Variable Groups for shared variables used by build pipelines (Source reference - createAdvancedMakersBuildVariables)

   - [Read More](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml)

6. Create Service connections to Power Platform Environments Source reference - createAdvancedMakersServiceConnections) using the Azure Active Directory Service Principal

   - NOTE: Each service connection will receive a separate Azure Active Directory secret.

   - [Read More - Service Connections](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml)

### Branch Automation

The [coe aa4am branch](./maker-setup.md#create-solution-branch) command performs the following steps

1. Create a new branch to store the Solution (Source code reference branch function)

1. Create build pipelines for the Solution Branch (Validation, Test, Production)

1. Create [Branch Policies](https://docs.microsoft.com/en-us/azure/devops/repos/git/branch-policies-overview?view=azure-devops) to ensure validation build completes successfully

### Other Concepts

In addition to install automation the following concepts are also assumed for Advanced Makers

1. A git branching strategy https://docs.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance?view=azure-devops

  - The AA4AM assumes a branch per solution

  - Changes merged back into main branch can be promoetd to production evironment

1. Manage Pull Requests to merge changes into Solution Branches https://docs.microsoft.com/en-us/azure/devops/repos/git/pull-requests?view=azure-devops

## Power Platform

The CLI provides the following key steps. (Source code file [powerplatform.ts](../../src/commands/powerplatform.ts))

1. Import Managed solution into environment to allow Advanced Makers to Manage git import, create branches, pull requests and updates to test and production.

2. Fix Custom Connectors used to connect to Azure DevOps

3. Connect Flow to Common data service

4. Add the user to the Azure Active Directory Service Principal to the power platform environments

5. Share the Canvas application with the Maker Azure Active Directory Group