Contents

- [Overview](#overview)
- [Guiding Requirements](#guiding-requitements)
- [Prerequisites](#prerequisites)
  - [Optional Prerequisites](#optional-prerequisites)
- [Installation](#installation)
  - [Local Install](#local-install)
  - [Docker Install](#docker-install)
- [Getting Started](#getting-started)
  - [ALM Accelerator for Advanced Makers](#alm-accelerator-for-advanced-makers)
    - [Local Run](#local-run)
    - [Docker Run](#docker-run)
    - [Common Commands](#common-commands)
      - [Install](#install)
        - [Install All Pre-requisites](#install-all-pre-requisites)
        - [Install Active Directory](#install-active-directory)
        - [Install DevOps](#install-devops)
        - [Install Environment](#install-environment)
      - [Add Service Connections](#add-service-connections)
      - [Add Environment Application User](#add-environment-application-user)
- [Technical](#technical)
  - [Contributions](#contributions)
  - [Authentication](#authentication)

# Overview

The Center of Excellence (COE) toolkit command line interface (CLI) provide common functionality to automate the installation and operate solutions within a COE environment.

## Guiding Requirements

1. Create as common command line that can be installed cross platform and allows easy distribution and upgrade process as the COE toolkit evolves
1. Allows cli to be extensible for new verbs and actions
1. Where existing features exist in other cli tools provide consider a convenience wrapper vs native implementation in the cli app
1. Allow the process to be run by single user or split process to different
1. Allow for future expansion where commands could be run as part of build process

## Prerequisites

To run the COE CLI application you will require the following

1. An installation of Node 11+ for versions (12, 14, 16)
1. Azure CLI https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
   Required for user authentication and Azure Active Directory Integration

### Optional Prerequisites

1. PowerShell Core https://aka.ms/powershell 
   used for coe aa4am install command


## Installation

### Local Install

1. Download zip or clone repository

1. Change to unzipped or cloned repository

1. cd coe-cli

```bash
cd coe-cli
```

1. Install application dependencies

```bash
npm install
```

1. Build the application

```bash
npm run build
```

1. Link to the CLI application

```bash
npm link
```

1. Install Azure CLI 

https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

1. Install PowerShell Core

   - https://aka.ms/powershell 

   - Select "Setup and installation"

### Docker Installation

One method of installation is via docker

1. Download zip or clone repository

1. Build docker image

```bash
cd coe-cli
docker build -t coe-cli . 
```

## Getting Started

Once installed can use -h argument to se help options

```bash
coe -h
```

### ALM Accelerator for Advanced Makers

The ALM Accelerator for Advanced Makers (AA4AM) command allows you to manage common tasks for Advanced Makers.

#### Docker Run

One method of installation is via docker

1. Build docker image

```bash
cd coe-cli
docker build -t coe-cli . 
```

2. Run the docker image

 ```bash
docker run -it --rm coe-cli coe --help
```

-o is the Azure Devops organization name
-p is the Azure DevOps Project name
-e is the Dataverse Environment to install the Administration application to

#### Local Run

```bash
coe aa4am --help
```

-o is the devops organization name
-p is the Azure DevOps Project name
-e is the Dataverse Environment to install the Administration application to

#### Common Commands

##### Install

You can install all pre-requites if you are installing to a Dmo tenant or you have rights to Azure Active Directory, Azure Devops and Power Platform System Administrator rights.

###### Install All Pre-requisites

Install aad, devops and environment components

```bash
coe aa4am install -e org12346 -o dev12345 -p alm-sandbox
```

Will install Managed application the AAD application and Azure DevOps components

###### Install Azure Active Directory

```bash
coe aa4am install -c aad
```
Will login using the Azure CLI user and attempt to install the Azure Active Directory application required for Azure DevOps and the Application User that wil be used to interact Power Platform environments.

Steps by performed by the command:
1. Run the [./scripts/New-AzureAdAppRegistration.ps1](./scripts/New-AzureAdAppRegistration.ps1) to create the application. Notes:
  - Requires PowerShell Core to be installed to run step
  - Requires Azure Active Directory permissions to grant organization right to the application
1. Ensure Reply Url is configured

###### Install DevOps

Install the devops components

```bash
coe aa4am install -c devops -o dev12345 -p alm-sandbox
```

Steps by performed by the command:
1. Install Azure DevOps extensions using [./scripts/Install-AzureDevOpsExtensions.ps1](./scripts/Install-AzureDevOpsExtensions.ps1). Notes:
  - Requires Azure DevOps extension for az cli to be installed
  - Extensions that will be installed configured in [./config/AzureDevOpsExtensionsDetails.json](./config/AzureDevOpsExtensionsDetails.json)
1. Import Azure DevOps Pipelines. Notes:
  - The first time the build is run permissions will need to be granted to the service connections.
1. Install Azure DevOps Build Pipeline for 
  - Exporting solution to git
  - Import Unmanaged solution to Development Environment
  - Delete Development Solution
1. Setup Build Variables
1. Setup service connections

###### Install Environment

Install the Managed Solution to administer the application

```bash
coe aa4am install -c environment -e org1235
```

Steps by performed by the command:
1. Import the latest managed solution from GitHub into the environment

##### Add Service Connections

For each environment (validation, test, prod) and the developer environments you create you will need to create a service connection from Azure DevOps to the environment

```bash
coe aa4am connection add -o dev12345 -p alm-sandbox -e org12345-dev
```

Notes:
1. The command will look to add a new secret per connection to the AAD Application
1. Need to assign rights to the service connection in Azure DevOps

#### Add Environment Application User

Each environment that the solution imports and exports from needs the Azure Active Directory application added as an Application user

```bash
coe aa4am user add -e org12345-dev -i 00000-00000-000000000000-00000
```

Notes:
1. Add the Client if of the AAD Application as the -i argument
1. The user will be assigned to the System Administrator role of the environment

#### Create Branch

Creating a branch and associated Azure DevOps Pipelines

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

Notes:
1. If this is your first build pipeline you will need to set Pipeline Variables for your environment. At a minimum you will need to set **ServiceConnection** variable to your environment you have setup for validation, test and production.

## Technical

### Contributions

The [Contribution Guide](./CONTRIBUTING.md) includes technical details on how to contribute additional CLI commands

### Authentication

Authentication for tasks is managed using the Azure CLI. USing standard az cli commands you can login, logout and select accounts

```bash
az login
cor aa4am install -c add
az logoff
```

Notes:
1. If not logged into Azure cli you will be prompted to login
1. Azure CLI has been selected as it allows integration of CLi command to manage Azure resources that integrate with the Power Platform e.g. Azure Active Directory, Azure API Management, Azure Functions