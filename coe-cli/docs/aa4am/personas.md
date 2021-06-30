# Overview

The following personas are typically involved with ALM Accelerator for Advanced Makers process.

- **Business Users** - Licensed internal users of the created solutions. Will not directly use the AA4AM tools they will be able to see the shared applications. May report version number of application to the support team.

- **Maker** - Wants to use components or services produced by an advanced maker or professional developer. Off the shelf components and documentation. Not directly exposed to the Application Lifecycle as this process is abstracted away. Create and Share the Application with Business Users.

- **Advanced Maker** - Collaborates with Professional Development and IT teams to integrate and build applications. Assumed to be familiar with concepts like ALM, DevOps, Branching and Merging. Work in Development environment and push changes into validation and testing and production environments. Works with managed Canvas management application and Azure DevOps website. Common commands

```bash
coe aa4am branch -o dev12345 -p alm-sandbox -d MyTestSolution
```

- **Professional Developer** - Advanced maker knowledge plus the ability to use lower level development programing languages and SDKs to create components and services. For example JavaScript and PCF controls, Dataverse Plugins in C#, Azure Services and APIs e.g. Azure functions, API Management. LIkely to work in tools like Visual Studio Code. Common commands

```bash
coe aa4am branch -o dev12345 -p alm-sandbox -d MyTestSolution
```

- **Data Analyst** - Develop data model, Create and manage data services and post data collection analysis / reporting. For example Power BI reporting, Datalake. For data elements that are covered in the SOlution system e.g.Dataverse Modeling, AI Models. Items not covered today in solution system today like Power BI will have separate ALM process. Common commands

```bash
coe aa4am branch -o dev12345 -p alm-sandbox -d MyTestSolution
```

- **Operations Teams** - Deploy solution to environments across Power Platform and Microsoft Cloud Services (e.g. Azure). Distribute solutions into Power Platform and run ARM templates in Azure. Will not use the CLI commands directly. May use managed canvas application to view and Azure DevOps pipelines to view the status or and promote applications from test to production.

- **Support Teams** - Post application deployment look at version of applications deployed, triage issues. May use managed canvas application to view deployed solution versions.

- **Information Security Team** - Will compare against organization standards for Data Loss Prevention (DLP), Authentication and Authorization, Service Principals, Teams and Security. Review the ALM process against Threat models, risks and mitigations.

- **Architecture Team**I - Review the entire ALM process and components and verify matches solution methodology and architecture

- **Administrators**
  - **Power Platform Tenant Administrator** - Global right to Power Platform Administration - Manage Environments (Create, Update, Delete). Common commands

  ```bash
  coe aa4am generate install -o data.json
  coe aa4am install -f data.json
  ```

  - **Power Platform Environment Administrator** - Manage One ore more Power Platform Environments - Import solution, add users assign roles

  ```bash
  coe aa4am generate install -o data.json
  coe aa4am install -c environment -e https://contoso-maker.crm.dynamics.com
  ```

  Add makers to an environment (Assuming they also have Azure DevOps Administrator rights)

    ```bash
    coe aa4am maker add -e https://user-Dev.crm.dynamics.com -o https://dev.azure.com/dev12345 -p alm-sandbox -u user@contoso.com
    ```

  **Azure Tenant Administrator** Manage the AAD Tenant - Create User, Groups,  Applications and Service Principals (O365 or Azure Administrators). Common commands

  ```bash
  coe aa4am install -c aad
  ```

  **Azure DevOps Organization Administrators**
  **Azure DevOps Project Administrators**

  ```bash
  coe aa4am install -c devops -o https://dev.azure.com/dev12345 -p alm-sandbox
  ``` 
  