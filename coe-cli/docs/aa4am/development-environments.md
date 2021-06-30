# Development Environments

Each advanced maker will need a development environment created. Advanced makers can use a community environment to work in. Community environments can be accessed from the sign-up page https://web.powerapps.com/community/signup

In addition they will require the following to setup to endure they can use the management application:
1. A solution created in their Development Environment
2. Basic rights or higher to the Azure DevOps Organization
3. Contributor rights to the Azure DevOps Project
4. User rights to Service Connection to the created Development Environment
5. User rights to Variable Groups

## Admin Maker Setup

As Azure DevOps Administrator you will need to register each advanced maker environment. The following command will add the required service connection to development environment and setup security for the user

```bash
coe aa4am maker add -o https://dev.azure.com/dev12345 -p alm-sandbox -e https://org12345-dev.crm.dynamics.com -u username@contoso.com
```

## Read Next

- Complete the [Install Overview](./readme.md#install-overview)
