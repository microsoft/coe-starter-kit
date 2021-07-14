## ALM Accelerate for Advanced Connection Add

### Description

Add an Service Connection to a Power Platform environment into Azure DevOps

The user that executes this command will need the following permissions
 - Azure Active Directory application owner
 - Azure DevOps Project Administrator

### Example

```bash
coe aa4am connection add \
   -o https://dev.azure.com/contoso
   -p alm-sandbox
   -e https://contoso-test.crm.dynamics.com
```

### Parameters

#### -o, --devOpsOrganization

The Azure DevOps organization that will be installed to or referenced.

The value can be in the format https://dev.azure.com/contoso or contoso. If the fully qualified Url is not specified then https://dev.azure.com/ will be inserted before the provided value.

#### -p, --project

The Azure DevOps project name. The project must already be created in your Azure DevOps organization. This value will be used to:
 - Create Variable Group
 - Import Azure DevOps pipeline templates
 - Create Azure DevOps pipelines to import, export and delete solutions in the Power Platform environments

#### -e, --environment

The Power Platform development environment for the Advanced Makers. You can enter either the

1. Organization name e.g. contoso-test. The **region** parameter will be used to create the full qualified domain name
2. The fully qualified domain name with regional deployment e.g. http://contoso-test.crm.dynamics.com

You can visit https://aka.ms/ppac to list environments that you have access to.

#### --aad <name>

The Azure Active Directory service principal application created during install. The user will be used to create the service connection to an advanced maker development environment.

Note the user running this command must be the creator or owner of the AAD application. The [Manage user assignment for an app in Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/assign-user-or-group-access-portal) provides more information.

####  -u, --user

The optional User Principal Name (UPN) to allow access to the created connection e.g. alan-s\@contoso.com

#### --endpoint

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
- [Microsoft Power Apps US Government](https://docs.microsoft.com/en-us/power-platform/admin/powerapps-us-government)
- [Power Apps operated by 21Vianet and Power Automate operated by 21Vianet](https://docs.microsoft.com/en-us/power-platform/admin/business-applications-availability-china)
- [Power Apps Preview Program](https://docs.microsoft.com/en-us/power-platform/admin/preview-environments)
- [What is a CDS endpoint](https://powerusers.microsoft.com/t5/Building-Power-Apps/What-is-a-CDS-Endpoint/m-p/44969#M18758)

#### --settings

##### --createSecret

Determine if secrets should be created and assigned to resources that require Service Principal Name (SPN) when adding service connection. To create a secret for an Azure Active Directory application you must be assigned as an owner of the Azure Active Directory application

Default value is **true**.

Read more on [Manage user assignment for an app in Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/assign-user-or-group-access-portal)

##### --region

The region that environments are deployed to. This setting will be used if a fully qualified domain name is not supplied. The default value is **NAM** North America

Further reading:

- [Regions overview](https://docs.microsoft.com/en-us/power-platform/admin/regions-overview)
- [Region List](https://docs.microsoft.com/en-us/power-platform/admin/new-datacenter-regions)