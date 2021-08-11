## Admin Install

To complete the initial steps of an AA4AM deployment you will need to complete the administrative tasks. Once this is done Advanced Makers can create and register development environments.

![ALM Accelerator for Advanced Makers Install Overview](../images/aa4am-install-overview.png)

It is assumed that the Admin Install will be run by a single user that has Power Platform Global Administrator, DevOps Administrator rights and Azure Active directory Administrator rights.

### Before You Start

Complete [Before You Start](./before-you-start.md) to ensure that:

A. Power Platform Environments have been created

B. Azure DevOps Organization and Project has been created

C. CoE CLI installed

### Initial Install

1. Create install configuration file and review the generated JSON file and confirm the settings before you start the install process

```bash
coe aa4am generate install -o test.json
```

More information on the [coe aa4am generate install](../help/aa4am/generate/install.md) command

Which will generate a file similar to

```json
{
  "log": [
    "info"
  ],
  "components": [
    "all"
  ],
  "aad": "ALMAcceleratorServicePrincipal",
  "group": "ALMAcceleratorForAdvancedMakers",
  "devOpsOrganization": "https://dev.azure.com/dev1234",
  "project": "alm-sandbox",
  "repository": "pipelines",
  "settings": {
    "installEnvironments": [
      "validation",
      "test",
      "prod"
    ],
    "validation": "https://sample-validation.crm.dyamics.com",
    "test": "https://sample-test.crm.dyamics.com",
    "prod": "https://sample-prod.crm.dyamics.com",
    "createSecret": "true",
    "region": [
      "NAM"
    ]
  },
  "importMethod": "api",
  "endpoint": "prod"
}
```

2. Review the JSON and install using the following command

```bash
coe aa4am install -f test.json
```

More information on the [coe aa4am install](../help/aa4am/install.md) command

3. [Update permissions for the project build service](https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md#update-permissions-for-the-project-build-service) to enable build pipelines to interact with Git Repositories

### Read Next

- Complete the [Install Overview](./readme.md#install-overview)
