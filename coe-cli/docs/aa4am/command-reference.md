## Command Reference

### Install

You can install all pre-requites if you are installing to a Dmo tenant or you have rights to Azure Active Directory, Azure DevOps and Power Platform System Administrator rights.

#### Preparing for an Install

You can start by generating a configuration file for you install using the following command

```bash
coe aa4am generate install -o test.json
```

This will ask you a series of questions for the values which you can then edit and review before starting install

```json
{
  "components": [
    "environment"
  ],
  "aad": "ALMAcceleratorServicePrincipal",
  "devopsOrg": "CRM12345",
  "project": "alm-sandbox",
  "repository": "pipelines",
  "environments": "https://orga11111.crm.dynamics.com/",
  "settings": {
    "createsecret": "true",
    "region": "NAM"
  },
  "importMethod": "api",
  "endpoint": "prod"
}
```

To start an install with you configured settings you can use thw following.

```bash
coe aa4am install -f test.json
```

#### Install All Pre-requisites

Install aad, DevOps and environment components 

```bash
coe aa4am install -e org12346 -o dev12345 -p alm-sandbox
```

Will install Managed application the AAD application and Azure DevOps components

#### Install Azure Active Directory

To install just the Azure Active Directory components

```bash
coe aa4am install -c aad
```

Will login using the Azure CLI user and attempt to install the Azure Active Directory application required for Azure DevOps and the Application User that wil be used to interact Power Platform environments.

#### Install DevOps

Install the just devops components. This step assumes the Azure Active Directory Service Principal has been created

```bash
coe aa4am install -c devops -o dev12345 -p alm-sandbox
```

Steps by performed by the command:
1. Install Azure DevOps extensions. Extensions that will be installed configured in [config/AzureDevOpsExtensionsDetails.json](../../config/AzureDevOpsExtensionsDetails.json)
1. Import Azure DevOps Pipelines. Notes:
  - The first time the build is run permissions will need to be granted to the service connections.
1. Install Azure DevOps Build Pipeline for 
  - Exporting solution to git
  - Import Unmanaged solution to Development Environment
  - Delete Development Solution
1. Setup Build Variables
1. Setup service connections

#### Install Environment

Install the Managed Solution to administer the application. This step assumes that Azure Active Directory and Azure DevOps components have been created.

```bash
coe aa4am install -c environment -e org1235
```

Steps by performed by the command:
1. Import the latest managed solution from GitHub into the environment

### Add Service Connections

For each environment (validation, test, prod) and the developer environments you create you will need to create a service connection from Azure DevOps to the environment

```bash
coe aa4am connection add -o dev12345 -p alm-sandbox -e org12345-dev
```

Notes:
1. The command will look to add a new secret per connection to the AAD Application
1. Need to assign rights to the service connection in Azure DevOps

### Add Environment Application User

Each environment that the solution imports and exports from needs the Azure Active Directory application added as an Application user

```bash
coe aa4am user add -e org12345-dev -i 00000-00000-000000000000-00000
```

Notes:
1. Add the Client if of the AAD Application as the -i argument
1. The user will be assigned to the System Administrator role of the environment

### Create Branch

One setup you can create a solution branch and the associated Azure DevOps Pipelines

```bash
coe aa4am branch -o yourorg -p alm-sandbox -d MyTestSolution
```

-o is the devops organization name
-p is the Azure DevOps project
-d is the destination branch to create as import the build pipelines

More help is available from

```bash
coe aa4am branch --help
```
