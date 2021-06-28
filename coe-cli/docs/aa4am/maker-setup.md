# Maker Setup

Once a user has been setup with a development environment [Read More](./development-environments.md) they wil nee to us eth following sections to provide access to the service principal and create a solution branch.

## Setup Service Principal

The Azure DevOps Pipeline uses a Azure Active Directory service principal to connect to the development environment and import and export the solution. To enable access to the environment the following command will add the service principal as a System Administrator to the developer Power Platform environment.

1. Log out of any existing sessions if not the maker or a Power Platform tenant Administrator

```bash
az logout
```

2. Ensure the Application User has access access to the development environment. This step only needs to be completed once

```bash
coe aa4am user add -e https://org12345-dev.crm.dynamics.com
```

## Create Solution Branch

Each solution will require a solution branch created with Azure DevOps Pipeline with Build Policies for Validation and Continuous deployment to test and production environments.

To create a solution branch os the following command

```bash
coe aa4am branch -o https://dev.azure.com/dev12345 -p alm-sandbox -d MyTestSolution
```

NOTES:
1. -o is the name of your DevOps Organization

2. -p is the name of the Azure DevOps Project

3. -d os the name of the solution branch to create

4. If the repository you want to create a branch for is empty you will need to commit an initial commit before a branch can be created.

## Post Setup Checks

After setting up an advanced maker you may need to verify the following

1. If this is your first branch created you will need to check variables applied for the the created pipeline

2. The first time that each pipeline is run frm the administration application you will need to open the pipeline in Azure DevOps and approve the resources used by the pipeline.

3. Select the blue icon for the Azure DevOps Build in the application

   ![Latest Push Status](../../images/latest-push-status.jpg)

4. Check if is message similar to the following that requires approval of the pipeline to run

   ![Azure DevOps Permissions](../../images/devops-pipeline-permissions.jpg)

5. If required select "View" and permit the build pipeline to

   ![Azure DevOps Permit](../../images/devops-pipeline-permit.jpg)

NOTES:
1. If you are using a free Azure Subscription you may receive error "No hosted parallelism has been purchased or granted.". To resolve this issue visit to request Azure Pipeline build compute https://aka.ms/azpipelines-parallelism-request

## Read Next

- Complete the [Install Overview](./index.md#install-overview)