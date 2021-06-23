# Development Environments

Each advanced maker will need a development environment created. Advanced makers can use a community environment to work in. Community environments can be accessed from the sign-up page https://web.powerapps.com/community/signup

In addition they will require the following to setup to endure they can use the management application:
1. A solution created in their Development Environment
1. Basic rights or higher to the Azure DevOps Organization
1. Contributor rights to the Azure DevOps Project
1. User rights to Service Connection to the created Development Environment
1. User rights to Variable Groups

## Admin Maker Setup

As Azure DevOps Administrator you will need to a service connection to each development environment

1. Create the Service Connection

```
coe aa4am connection add -o https://dev.azure.com/dev12345 -p alm-sandbox -e https://org12345-dev.crm.dynamics.com
```

2. For the created service connection assign the requesting user in Security rights
