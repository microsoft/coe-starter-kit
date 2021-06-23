# Overview

Before you start an install of AA4AM ensure that you have the following in place

## COE Command Line

Install the COE CLI [locally](../index#local-install) or via a [docker image](../index#docker-imstall)

## Power Platform

Environment | Description
----------- | -------------
Maker | Environment with Dataverse enabled. Will be used to deploy managed solution. See **Note (1)* below to create Common Data Service Connection
Validation | Environment used to validate builds before merging into a solution branch              |
Test | Pre production Environment used to test solutions before moving to production          |
Production | Production Environment for managed solutions                                          |

Notes:
1. In the maker environment will require a Common Data Service Connection created by install user
   1) Goto https://make.powerapps.com/
   2) Navigate to Data -> Connections
   3) New Connection
   4) Microsoft Dataverse (legacy)
   5) Select Create
2. As a Microsoft Partner you can request access to demo tenants to test ALM Accelerators for Advanced Makers
   1) Visit https://docs.microsoft.com/en-us/partner-center/mpn-demos for more information
   2) Go to https://demos.microsoft.com to request a new enviroment
   3) Select My Enviroments
   4) Select Create Tenant
   5) Select tennat location
   6) Select "Dynamics 365 Customer Engagement"
3. Sample environment from https://admin.powerplatform.microsoft.com/environments

   ![Environments](../../images/environments.jpg)

## Azure

Ensure the user you run with has the the following permissions

Component | Description
--------- | ----------
Global Administrator or Privileged Role Administrator|Grant tenant-wide admin consent to an application [Read More](https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/grant-admin-consent)

## Azure DevOps

Component | Description
--------- | ----------
Organization | Review [Add Organization Users](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/add-organization-users?view=azure-devops) to create Azure DevOps organization and add users 
Project | An Azure DevOps project to integtrate with. This guide uses the name **alm-sandbox** as the project name
Extensions | Review the [extensions configuration](./config/AzureDevOpsExtensionsDetails.json) that will be installed
Repository | Ensure the git repository has been initialized with an initial commit

Notes:
1. If installing using demo tenant you can request a trial Azure DevOps environment
   a) https://azure.microsoft.com/en-us/services/devops/
   b) Create Organization
   c) Create initial project e.g. alm-sandbox
2. Review the Azure [DevOps Extensions](./config/AzureDevOpsExtensionsDetails.json) that will be installed by the CLI application to ensure your organization gives consent for them to be installed. 
  - [Power Platform Build Tools](https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.PowerPlatform-BuildTools)
  - [Power DevOps Tools](https://marketplace.visualstudio.com/items?itemName=WaelHamze.xrm-ci-framework-build-tasks)
  - [Replace Tokens](https://marketplace.visualstudio.com/items?itemName=qetza.replacetokens)
  - [SARIF SAST Scans Tab](https://marketplace.visualstudio.com/items?itemName=sariftools.scans)

  ## Read Next

  Once you have verified the above

  1. Complete the [Admin Install](./admin-install)