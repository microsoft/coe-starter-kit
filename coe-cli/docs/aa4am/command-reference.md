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

Install aad, DevOps and environment components using the default parameters

```bash
coe aa4am install -e https://contoso-maker.crm.microsoft.com -o https://dev.azure.com/dev12345 -p alm-sandbox
```

Will install Managed application the AAD application and Azure DevOps components

#### Install Azure Active Directory

To install just the Azure Active Directory components using the default parameters

```bash
coe aa4am install -c aad
```

Will login using the Azure CLI user and attempt to install the Azure Active Directory application required for Azure DevOps and the Application User that wil be used to interact Power Platform environments.

#### Install DevOps

To install just the DevOps components you can run the following command. This step assumes the Azure Active Directory Service Principal has been created

```bash
coe aa4am install -c devops -o https://dev.azure.com/dev12345 -p alm-sandbox
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
coe aa4am install -c environment -e https://org12345-dev.crm.microsoft.com
```

Steps by performed by the command:
1. Import the latest managed solution from GitHub into the environment

### Add Maker

For each developer environments you create you will need to create a service connection from Azure DevOps to the environment

```bash
coe aa4am maker add -o https://dev.azure.com/dev12345 -p alm-sandbox -e https://org12345-dev.crm.microsoft.com -u name@contoso.com
```

Notes:
1. The command will look to add a new secret per connection to the AAD Application
1. The user will be added to the AAD

### Add Environment Application User

Each environment that the solution imports and exports from needs the Azure Active Directory application added as an Application user

```bash
coe aa4am user add -e https://org12345-dev.crm.microsoft.com -a ALMAcceleratorServicePrincipal
```

Notes:
1. Add the name of the AAD Application as the -a argument
1. The user will be assigned to the System Administrator role of the environment

### Create Branch

One setup you can create a solution branch and the associated Azure DevOps Pipelines

```bash
coe aa4am branch -o https://dev.azure.com/dev12345 -p alm-sandbox -d MyTestSolution
```

-o is the devops organization name
-p is the Azure DevOps project
-d is the destination branch to create as import the build pipelines

More help is available from

```bash
coe aa4am branch --help
```
