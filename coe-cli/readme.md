# Overview

Using the Center of Excellence (COE) toolkit command line interface (CLI), you can manage your COE deployment on any platform. No matter if you are on Windows, macOS or Linux, using Bash, Cmd or PowerShell. The CLI currently starts with commands for the [ALM Accelerator for Advanced Makers](./docs/aa4am/index.md) and will add more features over time.

![Overview](./images/overview.jpg)

## Guiding Requirements

1. Create as common command line that can be installed cross platform and allows easy distribution and upgrade process as the COE toolkit evolves
1. Allows cli to be extensible for new verbs and actions
1. Where existing features exist in other cli tools provide consider a convenience wrapper vs native implementation in the cli app
1. Allow the process to be run by single user or split process to different
1. Allow for future expansion where commands could be run as part of build process

## Documentation

Read the [Documentation](./docs/index.md) for information on supported commands and setup process

## Requirements

To run the application you will require local install of the following or Docker installed.

1. An installation of Node 11+ for versions (12, 14, 16)
   a) https://nodejs.org/en/download/
1. Azure CLI Required for user authentication and Azure Active Directory Integration
   a) https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

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

### Docker Install

One method of installation is via docker

1. Download zip or clone repository

2. Build docker image

```bash
cd coe-cli
docker build -t coe-cli . 
```

3. Using the docker image

```bash
docker run -it --rm coe-cli
```

This will start a new interactive console (-it) and remove the docker container (--rm) when the console session exits. Using --rm ensures that any cached credentials are removed when you exit.

## Getting Started

Once installed can use -h argument to se help options

```bash
coe -h
```

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
