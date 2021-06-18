Contents

- [Overview](#overview)
- [Guiding Requirements](#guiding-requirements)
- [Prerequisites](#prerequisites)
  - [Optional Prerequisites](#optional-prerequisites)
- [Before You Start](#before-you-start)
- [Assumed Workflow](#assumed-worflow)
   - [Initial Setup](#initial-setup)
   - [Maker Setup](#maker-setup)
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
        - [Install Azure Active Directory](#install-azure-active-directory)
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
   NOTE: Used for coe aa4am install command

## Before You Start

Before you start you will need the following
1. The following Power Platform environment provisioned:
   1) An environment to deploy the Managed Application with Common Data Service database enabled. It will required Data Loss Prevention Policies enables for
      - Common Data Service
      - Custom Connectors
   2) A validation environment
   3) A test environment
   4) A production environment
   5) Development environment for each developer
1. Azure Active Directory Administrator with rights to create Azure Active Directory Applications and grant tenant permissions
1. An Azure DevOps subscription
1. A Common Data Service Connection created in target environment that will host Advanced Maker solution created by install user
   1) Goto https://make.powerapps.com/
   2) Navigate to Data -> Connections
   3) New Connection
   4) Microsoft Dataverse (legacy)
   5) Select Create

## Assumed Workflow

This guide assumes that you have the the following end to end workflow or a similar variation run.

### Initial Setup

Assuming a single user that has Power Platform Global Administrator, DevOps Administrator rights and Azure Active directory Administrator rights.

1. An Power Platform Environment has been selected to host the following
   1) The environment for host the Managed Advanced Makers solution. Likely to be a new environment and not the Default environment as it may not match your Data Loss Prevention Policies for Default
   2) The validation, test and production environments
1. A Common Data Service Connection created in target environment created by install user
1. A user with access to the Azure Active directory tenant to create teh and grant the required permissions
1. An Azure DevOps Organization with a created Azure DevOps Project

For example

```bash
coe aa4am generate install -o test.json
coe aa4am install -f test.json
```

1. In Azure DevOps initialize an empty Azure DevOps git repository (e.g. in project alm-sandbox, alm-sandbox repository)

### Security Setup

1. Create AAD Security to Share Canvas Application
1. Create Azure DevOps Group to add Advanced Makers to
   a. Grant Variable Groups rights 
   b. Grant Build Administrator Rights
1. Ensure Maker assigned as Azure DevOps user with **Basic** permissions and access to DevOps project e.g. **alm-sandbox**

### Maker Setup

1. A Development Environment for the Maker. 
   a. Can use https://web.powerapps.com/community/signup to signup for community developer environment
1. Add the Azure Active Directory Service service principal in the Developers Maker environment
1. Add a service connection to the developers environment
1. Run the ALM Accelerator for Advanced Makers application and sign into services
1. Set initial settings
   a. CRM Organization
   b. Azure DevOps project e.g. **alm-sandox**
   c. Pick Azure DevOps project where wil store solutions e.g. **alm-sandbox**
1. Create a branch for the solution

For example logged in as the **maker**

```
coe aa4am user add -e https://org12345-dev.crm.dynamics.com
coe aa4am branch -o dev12345 -p alm-sandbox -d MyTestSolution
```

## Admin Maker Setup

As Azure DevOps Administrator

1. Create the Service Connection

```
coe aa4am connection add -o dev12345 -p alm-sandbox -e https://org12345-dev.crm.dynamics.com
```

1. For the created service connection assign the user in Security rights

### Maker First Solution

1. Switch to Developer Environment
1. Create new solution e.g. NewSolution1
1. Add items to the solution. For example
   a. Select Solution
   b. Add Canvas Application
   c. Add Button
   d. Save Application and Close
1. Create Solution branch

```bash
coe aa4am branch -o dev12345 -p alm-sandbox -d MySolution1
```

1. Open ALM Accelerate for Advanced Maker Application
1. Select Push change to Git
   a. Create New Branch e.g. MySolution1-WIP
   b. From existing Solution Branch created above e.g. MySolution1
   c. Add a comment e.g. Initial version
1. Click on Latest Push Status 
   a. Permit permissions for pipeline to run (Variable Group, Service Connection, Pipeline)

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

### Docker Install

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

Run the docker image which will start a PowerShell session

 ```bash
docker run -it --rm coe-cli
```

**-it** run docker command interactive with terminal input
**--rm** remove the docker image when exit. Ensure any temp files or credentials are removed when sesion ends
coe-cli is the docker image name

**Optional Arguments**

**-v "c:\temp":/tmp** map local c:\temp to the /temp folder inside the docker container 
**coe --help** os the command to run (Optional will start PowerShell by default)

Notes:
1. Once the docker container starts youc an use coe command inside the powershell e.g. coe --help
1. You can run a single command from the command line e.g. 

```bash
docker run -it --rm coe-cli coe --help
```

#### Local Run

```bash
coe aa4am --help
```

-o is the devops organization name
-p is the Azure DevOps Project name
-e is the Dataverse Environment to install the Administration application to

#### Common Commands

##### Install

You can install all pre-requites if you are installing to a Dmo tenant or you have rights to Azure Active Directory, Azure DevOps and Power Platform System Administrator rights.

###### Preparing for an Install

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

###### Install All Pre-requisites

Install aad, DevOps and environment components 

```bash
coe aa4am install -e org12346 -o dev12345 -p alm-sandbox
```

Will install Managed application the AAD application and Azure DevOps components

###### Install Azure Active Directory

To install just the Azure Active Directory components

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

Install the just devops components. This step assumes the Azure Active Directory Service Principal has been created

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

Install the Managed Solution to administer the application. This step assumes that Azure Active Directory and Azure DevOps components have been created.

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

Notes:
1. If this is your first build pipeline you will need to set Pipeline Variables for your environment. At a minimum you will need to set **ServiceConnection** variable to your environment you have setup for validation, test and production.

## Technical

### Contributions

The [Contribution Guide](./CONTRIBUTING.md) includes technical details on how to contribute additional CLI commands

### Authentication

Authentication for tasks is managed using the Azure CLI. Using standard az cli commands you can login, logout and select accounts.

```bash
az login
cor aa4am install -c add
az logoff
```

Notes:
1. If not logged into Azure cli you will be prompted to login
1. Azure CLI has been selected as it allows integration of CLi command to manage Azure resources that integrate with the Power Platform e.g. Azure Active Directory, Azure API Management, Azure Functions