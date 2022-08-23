## ALM Install Help

The ALM Accelerator install command allows components to be installed.

### Examples

```bash
coe alm install -f install.json
```

To generate an install file you can use the [generate install](./generate/install) command

```bash
coe alm generate install -o install.json
```

### Parameters

##### -l, --log

The level of logging to be created when running the install in the log file combined.log

Read more https://github.com/winstonjs/winston#logging-levels

##### -f, --file

The install configuration parameters file. Example command to generate install configuration file

```bash
coe alm generate install -o install.json
```

##### -c, --components

The component(s) to install

- **all** - All components required from Azure Active Directory, Azure DevOps and Power Platform environment
- **aad** - Install and configure Azure active directory components only
- **devops** - Install and configure Azure DevOps components only
- **environment** - Install and configure Power Platform components only

##### --a, --aad

The Azure Active Directory Application name that will be used as Service Principal to connect from Azure DevOps via Service Connectors to Power Platform Environments.

The application will be created if it does not exists if component **aad** or **all** is selected. Requires Azure Active Directory permissions. [Read More](https://docs.microsoft.com/azure/active-directory/develop/howto-create-service-principal-portal)

For **aad** or **devops** install the AAD application will be assigned as the identity to for the service connection.

For **aad** or **environment** install the AAD application will be assigned as the Application User in the Power Platform environment with System Administrator privileges to allow import/export of solutions.

##### -g, --group

The Azure Active Directory Group name that will be used to grant access to makers in Azure DevOps and the Power Platform.

The group will be created if it does not exists if component **aad** or **all** is selected.

For **aad** or **devops** the group will be used to grant access to Variable group used by Azure DevOps pipelines.

For **aad** or **environment** the group will be used to share access to run the Canvas application.

##### -o, --devOpsOrganization

The Azure DevOps organization that will be installed to or referenced.

The value can be in the format https://dev.azure.com/contoso or contoso. If the fully qualified Url is not specified then https://dev.azure.com/ will be inserted before the provided value.

##### -p, --project

The Azure DevOps project name where the solution source code will be stored. The project must already be created in your Azure DevOps organization. This value will be used to:
 - Create Variable Group
 - Import Azure DevOps pipeline templates
 - Create Azure DevOps pipelines to import, export and delete solutions in the Power Platform environments

The default value is **alm-sandbox**

##### -r, --repository

The Azure DevOps repository where Azure DevOps solutions will be stored

The default value is **alm-sandbox**

##### --pipelineProject

The Azure DevOps project name where the pipeline source code will be stored and where the default pipelines will be created. The project must already be created in your Azure DevOps organization. This value will be used to:
 - Create Variable Group
 - Import Azure DevOps pipeline templates
 - Create Azure DevOps pipelines to import, export and delete solutions in the Power Platform environments

##### --pipelineRepository

The Azure DevOps repository where Azure DevOps pipeline templates will be cloned from https://github.com/microsoft/coe-alm-accelerator-templates.git

The default value is **pipelines**

##### -e, --environments

The Power Platform environment where the ALM Accelerator for Maker solution will be installed. You can enter either the

1. Organization name e.g. contoso-dev1234. The **region** parameter will be used to create the full qualified domain name
2. The fully qualified domain name with regional deployment e.g. http://contoso-dev1234.crm.dynamics.com

You can visit https://aka.ms/ppac to list environments that you have access to.

##### -s, --settings

A dictionary of settings used by the install process

###### --validation

The name of the build validation environment that will be used to validate pull requests before committing changes to a solution branch.

The value can be either the
1. Organization name e.g. contoso-validation. The **region** parameter will be used to create the full qualified domain name
2. The fully qualified domain name with regional deployment e.g. http://contoso-validation.crm.dynamics.com

###### --test

The name of the test environment that solutions will be promoted to

The value can be either the
1. Organization name e.g. contoso-test. The **region** parameter will be used to create the full qualified domain name
2. The fully qualified domain name with regional deployment e.g. http://contoso-test.crm.dynamics.com

###### --prod

The name of the production environment that solutions will be promoted to

The value can be either the
1. Organization name e.g. contoso-prod. The **region** parameter will be used to create the full qualified domain name
2. The fully qualified domain name with regional deployment e.g. http://contoso-prod.crm.dynamics.com

###### --createSecret

Determine if secrets should be created and assigned to resources that require Service Principal Name (SPN) authentication for **aad** parameter. To create a secret for an Azure Active Directory application you must be assigned as an owner of the Azure Active Directory application

Default value is **true**.

Read more on [Manage user assignment for an app in Azure Active Directory](https://docs.microsoft.com/azure/active-directory/manage-apps/assign-user-or-group-access-portal)

###### --cloud

The Azure cloud your tenant is using. Currently, there are 4 Azure clouds Public, US Gov, Germany and China. The default value is **Public** Azure Public Cloud

###### --region

The region that environments are deployed to. This setting will be used if a fully qualified domain name is not supplied. The default value is **NAM** North America

Further reading:

- [Regions overview](https://docs.microsoft.com/power-platform/admin/regions-overview)
- [Region List](https://docs.microsoft.com/power-platform/admin/new-datacenter-regions)

##### -m, --importMethod

The method to import the managed ALM Accelerator for Makers into Power Platform environment.

- **api** - The default option that uses the Power Platform APIs to import the solution and fix Dataverse and custom connectors

- **browser** - Indicates that a manual install will be done. The CoE CLI will download the latest release from GitHub for you to manually install.

- **pac** - Install using the Power Platform CLI. See https://docs.microsoft.com/powerapps/developer/data-platform/powerapps-cli#solution for the **pac solution import** and install requirements

##### --endpoint

The Power Platform Administration environment to interact with. The default value is **prod**

- **prod** - The current production deployment for the commercial cloud
- **usgov** - US Government cloud deployments
- **usgovhigh** - US Government cloud deployments
- **dod** - US Government cloud deployments
- **china** - China regional deployments
- **preview** - Preview environment
- **tip1** - Testing environment for Microsoft internal use
- **tip2** - Testing environment for Microsoft internal use

Read More
- [Microsoft Power Apps US Government](https://docs.microsoft.com/power-platform/admin/powerapps-us-government)
- [Power Apps operated by 21Vianet and Power Automate operated by 21Vianet](https://docs.microsoft.com/power-platform/admin/business-applications-availability-china)
- [Power Apps Preview Program](https://docs.microsoft.com/power-platform/admin/preview-environments)
- [What is a CDS endpoint](https://powerusers.microsoft.com/t5/Building-Power-Apps/What-is-a-CDS-Endpoint/m-p/44969#M18758)

##### --installFile

The relative or path to the solution zip file of the ALM Accelerator for Power Platform managed solution export zip file to import during install.

If not specified the install process will attempt to download the latest release version from [https://github.com/microsoft/coe-starter-kit/releases/](https://github.com/microsoft/coe-starter-kit/releases/).

For example for the [January 2022 release](https://github.com/microsoft/coe-starter-kit/releases/tag/CenterofExcellenceALMAccelerator-January2022) this would be in the Assets section and download [CenterofExcellenceALMAccelerator_1.0.20220114.1_managed.zip](https://github.com/microsoft/coe-starter-kit/releases/download/CenterofExcellenceALMAccelerator-January2022/CenterofExcellenceALMAccelerator_1.0.20220114.1_managed.zip)

NOTE: If you are running via [Docker image](https://docs.microsoft.com/power-platform/guidance/coe/cli/install#docker-install) this will need to be location inside the docker image. For example if you downloaded the release to your Downloads folder in Windows

```pwsh
docker run -it --rm -v $env:HOMEDRIVE$env:HOMEPATH/Downloads:/downloads coe-cli
```

Once the docker image starts you could then use the generate command to create an install.json file and reference docker path when prompted for installPath with /downloads/CenterofExcellenceALMAccelerator_1.0.20220114.1_managed.zip

```bash
coe alm generate install -o install.json
```

##### --installSource

The GitHub Release name to download the ALM Accelerator from. The default value is **coe**

Prior to February 2022 release the default value was **alm** because the assets were released separate from the CoE Starter Kit.

##### --installAsset

The optional name of the ALM Accelerator install package asset in GitHub to install.

##### --subscription

The name of the Azure Active Directory that should be selected. This value is optional in the case you only have access to a single Azure Active Tenant.

If your user account has access to multiple subscriptions this parameter allows you to specify which Azure subscription and tenant should be selected.

The Azure CLI [az account set](https://docs.microsoft.com/cli/azure/account?view=azure-cli-latest#az-account-set) can be used to set the active subscription.
