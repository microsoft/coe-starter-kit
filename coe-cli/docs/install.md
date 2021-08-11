# Installation

To install the CoE CLI

1. Download zip or clone repository

2. Change to unzipped or cloned repository

```bash
cd coe-starter-kit
```

3. Change to the coe-cli folder

```bash
cd coe-cli
```

Next select either [Local Install](#local-install) or [Docker Install](#docker-install)

## Local Install

### Prerequisites

To run the CoE CLI application you will require the following

1. An installation of Node 11+

   a. https://nodejs.org/en/download/

2. Azure CLI (version 2.24.0 or greater) is required for user authentication and Azure Active Directory Integration

   a. https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

### Checking Prerequisites

To check prerequisites have been installed correctly and have the correct versions at the command prompt

1. Verify node version

```bash
node --version
```

2. Verify Azure CLI Version

```bash
az --version
```

### Install

1. Install application dependencies

```bash
npm install
```

2. Build the application

```bash
npm run build
```

3. Link to the CoE CLI application

```bash
npm link
```

NOTE:
1. On Windows you may need to add %APPDATA%\npm to your PATH environment variable to access the coe command

2. Install Azure CLI. Follow install instructions for your operating system at https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

## Docker Install

One method of installation is via docker.

### Prerequisites

To run the CoE CLI application you will require the following

1. A local install of [Docker](https://docs.docker.com/get-docker/) this can be either Community Edition or Enterprise Edition. If you are installing onto a desktop environment you will normally pick a Community Edition deployment.

### Install

NOTE: On some operating systems you may need to use sudo before each of the docker commands.

1. Build docker image. 

```bash
cd coe-cli
docker build -t coe-cli . 
```

2. Using the docker image

```bash
docker run -it --rm coe-cli
```

This will start a new interactive console (-it) and remove the docker container (--rm) when the console session exits. Using --rm ensures that any cached credentials are removed when you exit.