# ALM Accelerator for Advanced Makers

The [ALM Accelerator for Advanced Makers](https://github.com/microsoft/coe-starter-kit/tree/main/ALMAcceleratorForAdvancedMakers) (AA4AM) 
command allows you to manage common tasks for Advanced Makers. 

Not sure what AA4AM is and how it can help? The main GitHub project [README](https://github.com/microsoft/coe-starter-kit/blob/main/ALMAcceleratorForAdvancedMakers/README.md) provides further context and examples of usage.

## Getting Started

- [Scenarios](./scenarios.md) - Discusses different install scenarios for AA4AM from Demo Installs to Enterprise Deployments
- [Key Concepts](./key-concepts.md) - Understand the key concepts for the components that are being automated under the hood by the CLI commands
- [Personas](./key-concepts.md) - Understand the key personas that may be related to AA4AM.

## Overview

The diagram below provides an overview of the key components required and permissions required.

![ALM Accelerator for Advanced Makers Overview](../images/aa4am-overview.jpg)

## Sample Install

The following recording shows a sample generating a install configuration file and installing AA4AM using the config file using a [Demo Deployment](./scenarios.md#demonstration-deployment).

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