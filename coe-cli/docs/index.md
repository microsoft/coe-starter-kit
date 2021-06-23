# Overview

The Center of Excellence (COE) toolkit command line interface (CLI) provides common functionality to automate the installation and operate solutions within a COE environment.

![Overview](../images/overview.jpg)


## Prerequisites

To run the COE CLI application you will require the following

1. An installation of Node 11+ for versions (12, 14, 16)
   a) https://nodejs.org/en/download/
2. Azure CLI Required for user authentication and Azure Active Directory Integration
   a) https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

### Checking Prerequisites

To check prerequisites installed at the command prompt

1. Verify node version

```bash
node --version
```

2. Verify Azure CLI Version

```bash
az --version
```

## Installation

### Local Install

1. Download zip or clone repository

2. Change to unzipped or cloned repository

3. cd coe-cli

```bash
cd coe-cli
```

4. Install application dependencies

```bash
npm install
```

5. Build the application

```bash
npm run build
```

6. Link to the CLI application

```bash
npm link
```

7. Install Azure CLI. Follow install instructions for you operating system at https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

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

## Read More

Once you have an install of the command line interface you can review the following commands

- [ALM Accelerator for Advanced Makers](./aa4am/index.md) - Use CLI commands to setup and configure an environment for Advanced Makers to enable them to do more.
- [COE CLI Upgrade](./upgrade.md) How to upgrade to t a new version of the COE install.