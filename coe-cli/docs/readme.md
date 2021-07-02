# Overview

Once you have an install of the command line interface and it's [pre-requisites](#prerequisites) you can review the following commands

- [Install](./install.md) - How to install the COE cli.

- [ALM Accelerator for Advanced Makers](./aa4am/readme.md) - Use CLI commands to setup and configure an environment for Advanced Makers to enable them to do more.

## Background

![Why CLI](./why-cli.svg)

The COE CLI has been design to provide a set of commands that different [personas](./aa4am/personas.md) across the organization can use to automate the process of installing COE components covering Azure, Azure DevOps and the Power Platform. 

![CLI Unified](./cli-unified.svg)

The COE CLI wraps existing CLI and APIs so that there is a set of commands that can be used to holistically automate the end to end Microsoft Solution deployment required by COE services. 


## Getting Started

Once installed can use -h argument to see help options

```bash
coe -h
```

Authentication for tasks is managed using the Azure CLI. Using standard az cli commands you can login, logout and select accounts. For example

```bash
az login
coe aa4am install -c add
az logoff
```

## Read More

Further reading

- [COE CLI Upgrade](./upgrade.md) How to upgrade to a new version of the COE install.