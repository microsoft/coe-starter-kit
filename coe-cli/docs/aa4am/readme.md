# ALM Accelerator for Advanced Makers

The [ALM Accelerator for Advanced Makers](https://github.com/microsoft/coe-starter-kit/tree/main/ALMAcceleratorForAdvancedMakers) (AA4AM) 
command allows you to manage common tasks for Advanced Makers. 

Not sure what AA4AM is and how it can help? The main GitHub project [README](https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/README.md) provides further context and examples of usage.

## Quick Start

1. Create your [Power Platform Environments](./key-concepts.md#environments) and Azure DevOps Organization for example create a [Azure DevOps Organization](https://azure.microsoft.com/en-us/services/devops/).

1. Create an install configuration. Review the [install help](../help/aa4am/install.md) for install parameters

```bash
coe aa4am generate install -o quickstart.json
```

2. If you are a [demo tenant install](./scenarios/tenant-deployments.md#demonstration-deployment) us the following command

```bash
coe aa4am install -f quickstart.json
```

If you are deploying to your enterprise refer to [Enterprise Deployment](./scenarios/tenant-deployments.md#enterprise-deployment) for further information.

3. Add Advanced Makers to Azure DevOps and share the Canvas Application

```bash
coe aa4am maker add \
   -o https://dev.azure.com/contso \
   -p alm-sandbox \
   -e https://contoso-userdev.crm.dynamics.com -a aa4am-ado-service-principal \
   -g aa4am-makers -u user@contoso.com
```

You can also generate a user configuration file. Using this approach will allow to you explore each parameter and review the settings before adding the maker.

```bash
coe aa4am generate maker add -o user.config
coe aa4am maker add \
   -f user.config
```

## Getting Started

- [Scenarios](./scenarios/readme.md) - Discusses different install scenarios for AA4AM from Demo Installs to Enterprise Deployments
- [Personas](./personas.md) - Understand the key personas and how they may to AA4AM CLI commands and the wider AA4AM process.
- [Key Concepts](./key-concepts.md) - Understand the key concepts for the components that are being automated under the hood by the CLI commands

## Overview

The diagram below provides an overview of the key components required and permissions required.

![ALM Accelerator for Advanced Makers Overview](../images/aa4am-overview.jpg)

## Sample Install

The following recording shows a sample generating a install configuration file and installing AA4AM using the configuration file using a [Demo Deployment](./scenarios/tenant-deployments.md#demonstration-deployment).

![Example](./install.svg)

## Install Overview

1. Review the [Before You Start](./before-you-start.md) to ensure you have the required Power Platform environments and Azure DevOps organizations created

2. As an administrator complete the [Admin Install](./admin-install.md)

3. Have Advanced Makers create [Development Environments](./development-environments.md)

4. Use [Maker Setup](./maker-setup.md) to create and setup environment and solution branches in the Azure DevOps repository.

Notes:
1. If this is your first build pipeline you will need to set Pipeline Variables for your environment. At a minimum you will need to set **ServiceConnection** variable to your environment you have setup for validation, test and production.

## Read Next

- [Command Reference](./command-reference.md)
- [ALM Accelerator for Advanced Makers](https://github.com/microsoft/coe-starter-kit/tree/main/ALMAcceleratorForAdvancedMakers) - Overview for AA4AM
- Manual Setup - Understand the key steps that the CLI is automating
  - [Foundational Setup](https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md#foundational-setup) - Foundational Setup for Manual steps automated by the CLI install command
  - [Development Project Setup](https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md#development-project-setup) - Documents the Manual steps that are automated by the CLI install command
  - [Solution Setup](https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md#solution-setup) - Documents the manual steps to setup Azure DevOps that are by the CLI install command
  - [Importing Solution](https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/SETUPGUIDE.md#importing-the-solution-and-configuring-the-app) - Documents the manual steps to import the managed solution that are by the CLI install command