## ALM Accelerate for Advanced Makers User Add

### Description

Add the Azure Active Directory User as a System administrator in a Power Platform environment.

### Example

```bash
coe aa4am user add \
  -e https://contoso-alans-dev.crm.dynamics.com
```

### Parameters

#### -e, --environment

The Power Platform development environment to add the Azure Active Directory as a System Administrator. You can enter either the

1. Organization name e.g. contoso-alans-dev. The **region** parameter will be used to create the full qualified domain name
2. The fully qualified domain name with regional deployment e.g. http://contoso-alans-dev.crm.dynamics.com

You can visit https://aka.ms/ppac to list environments that you have access to.

#### --aad <name>

The Azure Active Directory service principal application created during install. The user will be used to create the service connection to an advanced maker development environment.

Note the user running this command must be the creator or owner of the AAD application. The [Manage user assignment for an app in Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/assign-user-or-group-access-portal) provides more information.

#### -r, --role

The user role to assign. The default value is **System Administrator**

#### --settings

##### --region

The region that environments are deployed to. This setting will be used if a fully qualified domain name is not supplied. The default value is **NAM** North America

Further reading:

- [Regions overview](https://docs.microsoft.com/en-us/power-platform/admin/regions-overview)
- [Region List](https://docs.microsoft.com/en-us/power-platform/admin/new-datacenter-regions)