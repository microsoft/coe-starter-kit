# AA4AM Install Help

The ALM Accelerator for Advanced Makers (AA4AM) install command allows components to be installed 

Common command to install using generated install configuration file

```bash
coe aa4am install -f install.json
```

## Options

#### -l, --log

The level of logging to created when running the install in the log file combined.log

### -f, --file

The install configuration parameters file. Example command to generate install configuration file

```bash
coe aa4am generate install -o istall.json
```

### -c, --components

The component(s) to install

- **all** - All components in Azure Active Directory, Azure DevOps and Power Platform environment
- **aad** - Install and configure Azure active directory components only
- **devops** - Install and configure Azure DevOps components only
- **environment** - Install and configure Power Platform components only

### --a, --aad

The Azure Active Directory Application name that will be used as Service Principal connect from Azure DevOps Service Connectors and Power Platform Environments.

The application will be created if it does not exists is component **aad** or **all** is selected. Requires Azure Active Directory Directory permissions. [Read More](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)

For **aad** or **devops** install the AAD application will be used to assign as the identity to for the service connection.

For **aad** or **environment** install the AAD application will be used to assign as the Application User in the environment with System Administrator access to allow import/export of solutions.

### -g, --group

The Azure Active Directory Group name that will be used to grant access to Advanced makers in Azure DevOps and the Power Platform.

The group will be created if it does not exists is component **aad** or **all** is selected.

For **aad** or **devops** the group will be used to grant access to Variable group used by Azure DevOps pipelines.

For **aad** or **environment** the group will be used to share access to run the Canvas application.

### -o, --devOpsOrganization

The Azure DevOps organization that will will be installed to or referenced.

The value can be in the format https://dev.azure.com/contoso or contoso. If the fully qualified Url is not specified then https://dev.azure.com/ will be inserted before the provided value.

