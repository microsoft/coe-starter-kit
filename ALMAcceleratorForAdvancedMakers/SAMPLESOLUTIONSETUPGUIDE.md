## ALM Accelerator Sample Solution Setup

When you create a solution in Dataverse you'll need to create pipelines specifically for that solution. Follow these steps for creating pipelines for the ALM Accelerator Sample Solution in Azure DevOps. There are sample pipelines included in the Pipeline directory in the CoE ALM Templates repo.

- https://github.com/microsoft/coe-alm-accelerator-templates/blob/main/Pipelines/build-deploy-validation-SampleSolution.yml
- https://github.com/microsoft/coe-alm-accelerator-templates/blob/main/Pipelines/build-deploy-test-SampleSolution.yml
- https://github.com/microsoft/coe-alm-accelerator-templates/blob/main/Pipelines/deploy-prod-pipelineartifact-SampleSolution.yml 

### Table of Contents
- [ALM Accelerator Sample Solution Setup](#alm-accelerator-sample-solution-setup)
  * [Create the Solution Build and Deployment Pipeline(s)](#create-the-solution-build-and-deployment-pipelines)
    + [Create the Validation and Test Pipelines](#create-the-validation-and-test-pipelines)
    + [Create the Production Solution Deployment Pipeline](#create-the-production-solution-deployment-pipeline)
  * [Setting Branch Policies for Pull Request Validation](#setting-branch-policies-for-pull-request-validation)
  * [Setting Deployment Pipeline Variables](#setting-deployment-pipeline-variables)
    + [Create Environment and Service Connection](#create-environment-and-service-connection)
    + [Create the Connection Reference Pipeline Variable](#create-the-connection-reference-pipeline-variable)
    + [Create Environment Variable Pipeline Variable](#create-environment-variable-pipeline-variable)
    + [Create AAD Group Canvas Configuration Pipeline Variable](#create-aad-group-canvas-configuration-pipeline-variable)
    + [Create AAD Group / Team Configuration Pipeline Variable (Optional)](#create-aad-group--team-configuration-pipeline-variable-optional)
- [Importing the Solution and Configuring the ALM Accelerator App](#importing-the-solution-and-configuring-the-alm-accelerator-app)
- [Test the ALM Accelerator App](#test-the-alm-accelerator-app)


### Create the Solution Build and Deployment Pipeline(s)

Solution Pipelines are used to build and deploy your source controlled solutions to environments in your tenant. The sample pipelines provided assume 3 environments (Validation, Test and Production). Repeat the steps in the next section for the Validation and Test environments and then move to the following section to configure the Production pipeline.

#### Create the Validation and Test Pipelines

In this step you'll be creating the Validation and Test Pipelines for reference your pipelines will follow this configuration

| Pipeline YAML File Name                    | Pipeline Name                    | Branch Policy Enabled |
| ------------------------------------------ | -------------------------------- | --------------------- |
| build-deploy-validation-SampleSolution.yml | deploy-validation-SampleSolution | Yes                   |
| build-deploy-test-SampleSolution.yml       | deploy-test-SampleSolution       | No                    |



1. In Azure DevOps go to the **Repo** that contains the [Pipelines folder you committed](SETUPGUIDE.md#copy-the-YAML-pipelines-from-github-to-your-azure-devops-instance) and select the Pipelines folder

1. Open the sample deployment pipeline (i.e. **build-deploy-validation-SampleSolution.yml or build-deploy-test-SampleSolution.yml**) and copy the YAML to use in your new Pipeline. **Note the name of this repo** for use in your pipeline.

   ![image-20210408172106137](.attachments/GETTINGSTARTED/image-20210408172106137.png)

1. Navigate to the **Repo where you want to source control the ALM Accelerator Sample Solution**.
   
1. Create a new Branch based on **your default branch** in the Repo called **ALMAcceleratorSampleSolution**
   
   >  [NOTE!] This branch will be your v-next branch in the repo. All development work should be branched from this branch to a developers personal working branch and then merged into the v-next branch in order to push to Validation and Testing. Later when a release is ready the v-next branch can be merged into the main or default branch.
   
   ![image-20210505162502432](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505162502432.png)
   
1. Select **New** from the top menu and then **Folder**
   
   ![image-20210505162848092](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505162848092.png)
   
1. Give the new Folder the name **ALMAcceleratorSampleSolution** and the new Pipeline YAML file a name (e.g. **build-deploy-validation-ALMAcceleratorSampleSolution.yml** or **build-deploy-test-ALMAcceleratorSampleSolution.yml**). Select **Create**.

   ![image-20210505163013011](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505163013011.png)

1. Paste the YAML from **build-deploy-validation-SampleSolution.yml** or **build-deploy-test-SampleSolution.yml** into your new Pipeline YAML file.

   ![image-20210505163334414](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505163334414.png)

1. Update the following values in your new Pipeline YAML.

   - Change the **resources -> repositories -> name**  to the repo name that contains your pipeline templates. If your template repository is in another AzDO project you can use the format **projectname/reponame** here. In this case the repo is called **coe-alm-accelerator-templates** (remember we told you to remember the pipeline repo name?) and it exists in the same project as our **ALMAcceleratorSampleSolution repo**. Additionally, you can specify a branch for where your templates live using the **ref** parameter if required.

      ![image-20210505163452491](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505163452491.png)

    - Change any value that references **SampleSolutionName** to the unique name of the ALM Accelerator Sample Solution (i.e. **ALMAcceleratorSampleSolution**).

      ![image-20210505163733070](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505163733070.png)

    - Select **Commit** to save your changes.

1. In Azure DevOps go to **Pipelines** and **Create a New Pipeline**

1. Select **Azure Repos Git** for your code Repository.
   ![image-20210505164249272](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505164249272.png)

1. Select the **Azure DevOps repo** which contains the deployment **Pipeline YAML created above**.

    ![image-20210505164327459](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505164327459.png)

1. On the **Configure your pipeline** page select **Existing Azure Pipelines YAML file**, point to the **YAML File in your repo that you created in step 5** and Select **Continue**.
   ![image-20210505164425446](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505164425446.png)

1. On the next screen Select **Save** and then Select the 3 dots next to Run Pipeline and Select **Rename/Move**.
   ![image-20210301103145498](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505164641102.png)

   ![image-20210301103145498](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210301103145498.png)
   
1. Update the pipeline name to **deploy-validation-ALMAcceleratorSampleSolution** or **deploy-test-ALMAcceleratorSampleSolution** (where 'ALMAcceleratorSampleSolution' is the name of the ALM Accelerator Sample Solution) and select **Save**.

    ![image-20210505164834987](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505164834987.png)

1. Update the **Default branch for manual and scheduled builds**

   - Select Edit on your new Pipeline

   - **Select the 3 dots** on the top right and **Select Triggers**

   ![image-20210510163520532](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210510163520532.png)

   - **Select the YAML tab** and **Select Get Sources**. 

   - Update the **Default branch for manual and scheduled builds** to point to your **Solution branch**

   ![image-20210510163722833](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210510163722833.png)

1. Repeat the steps above to create a deployment pipeline for each of your environments referencing the sample deployment pipeline YAML from the **coe-alm-accelerator-templates repo** (i.e. deploy-test-SampleSolution.yml).

#### Create the Production Solution Deployment Pipeline

As mentioned in the note above, the previous section allows you to create pipelines that build and deploy for each environment (Validation, Test and Production). However, if you want to only build and deploy for Validation and Test and then deploy the artifacts from the Test build to Production you can follow these instructions to create your production deployment pipeline after you've created your build and deploy pipeline for Validation and Test above. For reference your pipeline will be configured as follows.

| Pipeline YAML File Name                      | Pipeline Name                            | Branch Policy Enabled |
| -------------------------------------------- | ---------------------------------------- | --------------------- |
| deploy-prod-ALMAcceleratorSampleSolution.yml | deploy-prod-ALMAcceleratorSampleSolution | No                    |

1. In Azure DevOps go to the **Repo** that contains the [Pipelines folder you committed](#copy-the-YAML-pipelines-from-github-to-your-azure-devops-instance) and select the Pipelines folder

1. Open the sample deployment pipeline (i.e. **deploy-prod-pipelineartifact-SampleSolution.yml**) and copy the YAML to use in your new Pipeline. **Note the name of this repo** for use in your pipeline.

   ![image-20210429113205147](.attachments/SETUPGUIDE/image-20210429113205147.png)

1. Navigate to the **Repo where you want to source control the ALM Accelerator Sample Solution**.

1. Select **New** from the top menu and then **File**

   ![image-20210505171116437](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505171116437.png)

5. Give the new Pipeline YAML file a name (e.g. **deploy-prod-ALMAcceleratorSampleSolution.yml**). Select **Create**

   ![image-20210505171311552](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505171311552.png)

6. Paste the YAML from **deploy-prod-pipelineartifact-SampleSolution.yml** into your new Pipeline YAML file.

   ![image-20210505171429254](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505171429254.png)

7. Update the following values in your new Pipeline YAML.

   - Update the **trigger -> branches -> include** to the branch(es) for which changes would trigger a deployment to production. 

   - Change the **resources -> repositories -> name** to the repo name that contains your pipeline templates. If your template repository is in another AzDO project you can use the format **projectname/reponame** here. In this case the repo is called **coe-alm-accelerator-templates** and it exists in the same project as our ALMAcceleratorSampleSolution repo. Additionally, you can specify a branch for where your templates live using the **ref** parameter if required.

     ![image-20210505171609319](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505171609319.png)

   - Update **resources -> pipelines -> source** to specify **the build pipeline that contains the artifacts to be deployed** by this pipeline. In this case we are going to deploy the artifacts from our Test pipeline, created above, that built and deployed our ALMAcceleratorSampleSolution to the Test environment.

     ![image-20210505172559804](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505172559804.png)

   - Change any value that references **SampleSolutionName** to the unique name of the ALM Accelerator Sample Solution (i.e. **ALMAcceleratorSampleSolution**).

     ![image-20210505172803107](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210505172803107.png)

8. Repeat the same steps 9-15, performed above, for **deploy-validation-ALMAcceleratorSampleSolution** and **deploy-test-ALMAcceleratorSampleSolution** to create a pipeline from the new production pipeline YAML called **deploy-prod-ALMAcceleratorSampleSolution**.

### Setting Branch Policies for Pull Request Validation

In order to leverage executing the build pipeline for the ALM Accelerator Sample Solution when a **Pull Request is created** you'll need to create a **Branch Policy** to execute the **Validation Pipeline** you created in the previous step. Use the following steps to set your Branch Policy. For more information on Branch Policies see here https://docs.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops

1. In Azure DevOps go to **Repos** and select the **Branches** folder

1. Locate the **target branch** on which you want to run the **Pull Request policy** and select the ellipsis to the right of the target branch and Select **Branch Policies**.

   ![image-20210506105054480](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506105054480.png)

1. On the **Branch Policies** screen go to **Build Validation**

1. Click the **+ Button** to add a **new Branch Policy**

   ![image-20210506120940195](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506120940195.png)

1. Select the Pipeline you just created from the **Build pipeline** dropdown

1. Specify a **Path filter** (if applicable). The path filter will ensure that only changes to the path specified will trigger the pipeline for your Pull Request.

1. Set the **Trigger** to **Automatic**

1. Set the **Policy requirement** to **Required**

1. Set the **Build expiration** to **Immediately**

1. Set a **Display name** for your Branch Policy (e.g. PR Build Validation)

1. Click **Save**

   ![image-20210506121134045](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506121134045.png)

### Setting Deployment Pipeline Variables

The ALM Accelerator uses JSON formatted Pipeline variables for updating **connection references, environment variables, setting permissions for AAD Groups and Dataverse teams** as well as **sharing Canvas Apps and updating ownership of solution components** such as Power Automate flows. **EnvironmentName** and **ServiceConnection** variables are **required** for each pipeline. All other pipeline variables are **optional** and depend on what type of components the ALM Accelerator Sample Solution pipelines deploy. For instance, if the ALM Accelerator Sample Solutions only contain Dataverse Tables, Columns and Model Driven Apps **some of these steps may not be necessary** and can be skipped. The following variables allow you to fully automate the deployment of the ALM Accelerator Sample Solutions and specify how to configure items that are specific to the environment to which the solution is being deployed.

> [!IMPORTANT] These pipeline variables will be set for each **deployment pipeline** you've configured above based on the environment to which your pipeline deploys.

#### Create Environment and Service Connection

These variables are required by every deployment pipeline. The Environment variable is **EnvironmentName** and the Service Connection variable is **ServiceConnection**.

The **EnvironmentName** variable is used to specify the Azure DevOps environment being deployed to in order to enable tracking deployment history and set permissions and approvals for deployment to specific environments. Depending on the environment to which you're deploying set this value to **Validate, Test or Production** For more information on Environments in AzureDevOps see https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments.

1. Open the pipeline you created previously (**deploy-validation-ALMAcceleratorSampleSolution**, **deploy-test-ALMAcceleratorSampleSolution** or **deploy-production-ALMAcceleratorSampleSolution**) and **Select Edit**

   ![image-20210506101338620](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506101338620.png)

2. **Select Variables**

   ![image-20210506101437500](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506101437500.png)

3. Select New Variable

   ![image-20210506101519756](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506101519756.png)

4. In the New Variable Screen Enter "**EnvironmentName**" for the Name and either (**Validate, Test or Production**) for the Value depending on which pipeline you are editing and **Select OK**

   ![image-20210506101906429](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506101906429.png)

5. Repeat the steps above to create the **ServiceConnection** variable. This is used to specify how the deployment pipeline connects to the Power Platform. The values used for the Service Connection variable are the names of the Service Connections created during setup [Create a Service Connection for DevOps to access Power Platform](SETUPGUIDE.md#create-service-connections-for-devops-to-access-power-platform)

   > [NOTE!] The Value for the ServiceConnection variable must be identical to the Name of the Service Connection. Including any trailing slashes.

   ![image-20210506102307068](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506102307068.png)

6. Repeat adding the **EnvironmentName** and **ServiceConnection** for each of the pipelines created above (i.e. **deploy-test-ALMAcceleratorSampleSolution** and **deploy-production-ALMAcceleratorSampleSolution**)

#### Create the Connection Reference Pipeline Variable

The connection reference variable is **ConnectionReferences**. This pipeline variable is used for setting connection references in the ALM Accelerator Sample Solution to specific connections configured in a target environment after the solution is imported into an environment. Additionally, the **ConnectionReferences** variable is used to enable flows after the solution is imported based on owner of the connection specified in the variable.

1. You will need to create the connection manually in your target environments and copy the IDs for the connection to use in the JSON value below

1. The format of the JSON for these variables take the form of an array of name/value pairs.

   ```json
   [
      [ 
        "cat_CDS_Current",
        "my environment connection ID1"
      ]
   ]
   ```
   
   - The **schema name** for the connection reference can be obtained from the **connection reference component** in the ALM Accelerator Sample Solution.
     ![image.png](.attachments/GETTINGSTARTED/connrefschema.png)
   
   - The **connection id** can be obtained via the url of the connection after you create it. For example the id of the connection below is **c3ea43ec255c4b6f9d2ec6ccc388f0c2** where the url is https://.../connections/shared_commondataservice/**c3ea43ec255c4b6f9d2ec6ccc388f0c2**/details#
   ![image-20210506104742948](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506104742948.png)
   
1. Once you've gathered the connection reference schema names and connection ids go to the pipeline for the ALM Accelerator Sample Solution that you created above Select **Edit -> Variables**

1. On the **Pipeline Variables** screen create the **ConnectionReferences** pipeline variables.

1. Set the value to the json formatted array of connection reference schema and connection ids.

   ![image-20210506121532075](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506121532075.png)

1. Repeat the steps above for each pipeline (i.e. **deploy-test-ALMAcceleratorSampleSolution** and **deploy-production-ALMAcceleratorSampleSolution**).

#### Create Environment Variable Pipeline Variable

The environment variable pipeline variable is **EnvironmentVariables**. This pipeline variable is used for setting Dataverse **Environment variables** in the ALM Accelerator Sample Solution after the solution is imported into an environment.

1. The format of the JSON for these variables take the form of an array of name/value pairs.

   ```json
   [
      [
         "cat_TextEnvironmentVariable",
         "Some Text"
      ],
      [
         "cat_DecimalEnvironmentVariable",
         "1"
      ],
      [
         "cat_JsonEnvironmentVariable",
         "{\"some\":\"json formatted value\"}"
      ]
   ]
   ```

   - The **schema name** for the environment variable can be obtained from the **environment variable component** in the ALM Accelerator Sample Solution.
     ![image.png](.attachments/GETTINGSTARTED/envvariableschema.png)

1. The 3 Environment Variables in the ALM Accelerator Sample Solution can be seen in the sample above.

1. Click Edit -> Variables

1. On the Pipeline Variables screen create the **EnvironmentVariables** pipeline variables.

1. Set the value to the json formatted array of environment variable schema and values.

1. For the example above the values look like the following
   ![image-20210506122407787](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506122407787.png)

1. Repeat the steps above for each pipeline (i.e. **deploy-test-ALMAcceleratorSampleSolution** and **deploy-production-ALMAcceleratorSampleSolution**). Giving the different environments different Environment Variable values to validate the pipeline sets these appropriately when deployed. 

#### Create AAD Group Canvas Configuration Pipeline Variable

The aad group canvas configuration pipeline variable is **AadGroupCanvasConfiguration**. This pipeline variable is used for **sharing canvas apps** in the ALM Accelerator Sample Solution with specific **Azure Active Directory Groups** after the solution is imported into an environment.

1. The format of the JSON for these variables take the form of an array of objects. The **roleName** can be one of **CanView**, **CanViewWithShare** and **CanEdit**

   ```json
   [
    {
        "aadGroupId": "azure active directory group id",
        "canvasNameInSolution": "cat_devopskitsamplecanvasapp_c7ec5",
        "roleName": "CanView"
    }
   ]
   ```
   
   - The **schema name** for the Canvas App can be obtained from the **Canvas App component** in the ALM Accelerator Sample Solution.
     ![image.png](.attachments/GETTINGSTARTED/canvasschemaname.png)
   
   - The **azure active directory group id** can be obtained from the **Group blade in Azure Active Directory** from the Azure Portal. You can create a new AAD Group for testing the ALM Accelerator Sample Solution and add your user and / or others to it.
     ![image-20210506122826444](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506122826444.png)
   
1. Once you've gathered the **Canvas App schema names** and **aad group ids** go to the pipeline for the ALM Accelerator Sample Solution that you created above

1. Click Edit -> Variables

1. On the Pipeline Variables screen create the **AadGroupCanvasConfiguration** pipeline variables.

1. Set the value to the json formatted array of objects per the sample above.

1. For the example above the values look like the following.
   ![image-20210506123112710](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506123112710.png)
   
1. Repeat the steps above for each pipeline (i.e. **deploy-test-ALMAcceleratorSampleSolution** and **deploy-production-ALMAcceleratorSampleSolution**). Giving the different environments different Environment Variable values to validate the pipeline sets these appropriately when deployed. 

#### Create AAD Group / Team Configuration Pipeline Variable (Optional)

The pipeline variable is **AadGroupTeamConfiguration**. This pipeline variable is used for mapping **Dataverse Teams and Roles** to specific **Azure Active Directory Groups** after the solution is imported into an environment. The security roles will need to added to the ALM Accelerator Sample Solution if they are not manually created in the target environment.

1. The format of the JSON for these variables take the form of an array of objects. One or many roles can be applied to any given team and these roles provide permissions to solution components required by the users in the group.

   ```json
   [
    {
        "aadGroupTeamName": "alm-accelerator-sample-solution",
        "aadSecurityGroupId": "azure active directory group id1",
        "dataverseSecurityRoleNames": [
            "ALM Accelerator Sample Role"
        ]
    }
   ]
   ```
   
   - The **Dataverse team name** can be any **existing team or a new team** to be created in Dataverse and mapped to an AAD Group after the solution is imported via the pipeline.
   
   - The **azure active directory group id** can be obtained from the **Group blade in Azure Active Directory** from the Azure Portal.
   
   ![image-20210506124339972](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506124339972.png)
   
   - The **Dataverse role** can be any **Security Role in Dataverse** that would be applied to the **existing or newly created Team** after the solution is imported via the pipeline. The role should have permissions to the resources required by the solution (e.g. Tables and Processes)
   
1. Once you've gathered the team names, aad group ids and roles go to the pipeline for the ALM Accelerator Sample Solution that you created above. Click Edit -> Variables
1. On the Pipeline Variables screen create the **AadGroupTeamConfiguration** pipeline variables.
1. Set the value to the json formatted array of environment variable schema and values.
1. For the example above the values look like the following
   ![image.png](.attachments/GETTINGSTARTED/aadteamgroupvariables.png)
1. Where applicable repeat the steps above for each solution / pipeline you create.

## Importing the Solution and Configuring the ALM Accelerator App

To get started using the ALM Accelerator For Advanced Makers App follow the instructions in the [SETUPGUIDE](SETUPGUIDE.md#importing-the-solution-and-configuring-the-app).

## Test the ALM Accelerator App

1. Download the **latest managed solution** of the **ALM Accelerator Sample Solution** from the latest release of the ALM Accelerator For Advanced Makers on GitHub (https://github.com/microsoft/coe-starter-kit/releases).

    > [NOTE!] The screenshot below is for reference as to where the managed solution exists under a release. The actual version should be the most recent release.
    
    ![image-20210506140023521](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506140023521.png)
    
1. Once the solution is installed run the ALM Accelerator For Advanced Makers App.

    > [!NOTE] When you first launch the app you may need to consent to the app using your connections.
    
1. Select the **Cog** in the top right to select your **Azure DevOps Environment**, **Project** and **Repo** to which you'll push your changes and submit your pull requests and select **Save**
   ![image-20210303085854533](.attachments/GETTINGSTARTED/image-20210303085854533.png)

   > [!NOTE] If you don't see your DevOps Organization / Project in the dropdown double check that the Custom connector is working correctly after updating it's Security settings.
   
1. From the Environment Drop Down **Select the Dataverse Environment** in which you will be doing your development work.
   ![image-20210506141321294](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506141321294.png)

   > [!NOTE] In order for your Environment to show up in this drop down a service connection in the Azure DevOps project you just selected is required (see [Create a Service Connection for DevOps to access Power Platform](SETUPGUIDE.md#create-service-connections-for-devops-to-access-power-platform). Additionally, verify that you've followed the steps to reconnect the flow above if you do not see any environments in the list.
   
1. By default the **unmanaged solutions**, including the **ALM Accelerator Sample Solution**, in your Environment should be displayed in the main window with buttons to **Push Changes** and **Create Pull Requests**.

1. Now that the ALM Accelerator Sample Solution is imported into Dataverse you can push your changes to Git using the **Push Changes to Git** button for the ALM Accelerator Sample Solution.
   
   - Select an **existing branch** or **create a new branch** based on an existing branch and enter a **comment**. Use the hashtag notation e.g. `#123` to link the changes to a specific work item in Azure DevOps and Select **Commit**.
   ![image-20210506145231393](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506145231393.png)
   >[!NOTE]: There is an option to specify if the latest changes contain Delete Components. This allows the user to specify whether to perform an **update** or an **upgrade** of the solution when it is deployed. The former will increase the performance of the pipelines and reduce the overall time to deploy.
   - When the push begins a waiting indicator will appear. If the push is successful a checkbox will appear otherwise a red x will appear. In order to see the progress of your push select the progress indicator which will take you to the running pipeline in Azure DevOps.
   
1. Once the initial push completes successfully you validate that the changes were exported to your branch.
   
   ![image-20210506143212409](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506143212409.png)
   
1. Next make a small change to the Solution by selecting Open Solution from the ALM Accelerator App.
   
   ![image-20210506143308679](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506143308679.png)
   
1. Find the **DevOpsKitSampleCanvasApp** and **Select the Ellipses** then **Select Edit**
   
   ![image-20210506143558225](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506143558225.png)
   
1. In the Canvas Editor Menu **Select Insert then Label**.
   
1. Position the new label on the App and **set the Text value**
   
   ![image-20210506143921943](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506143921943.png)
   
1. Select **File** from the Canvas Editor Menu and **Select Save** then **Publish**
   
   ![image-20210506144027724](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506144027724.png)
   
1. Return to the ALM Accelerator App and **Select Push Changes to Git** again and repeat the steps above except this time commit to the branch you already created.
   
   ![image-20210506145049512](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506145049512.png)
   
   >[!NOTE]: Be sure to publish your changes before initiating the push.
   14. Once the **latest changes are Committed** create a new Pull Request by **Selecting Create Pull Request**
   
   - Specify the **Source and Target branch** and enter a **Title and Comment** for your Pull Request and **Select Create**.
   ![image-20210506144141234](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506144141234.png)
   
1. Once a Pull Request is created for your changes the remaining steps to Merge and Release to Test occur in Azure DevOps. 

1. Select the Icon under the **Latest PR** Column to Launch Azure DevOps and **View the Pull Request**

    ![image-20210506144309761](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506144309761.png)

1. Verify that your **Validation Build Branch Policy** was created successfully in the Pull Request by confirming that the Validation Build is running.

     ![image-20210506144651140](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506144651140.png)

1. Very that your changes are reflected in the PR by Selecting Files and Finding your Canvas App MainScreen.fx.yaml.

     ![image-20210506150545363](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506150545363.png)

1. Once the **PR Validation Build** completes **Select Approve** then **Select Complete** and **Select Complete merge**.

     ![image-20210506151631470](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506151631470.png)

1. After the Merge completes navigate back to the **ALM Accelerator App** and verify that the **Test Deployment** is in Progress.

     ![image-20210506152042025](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506152042025.png)

1. After the ALM Accelerator Sample Solution has been deployed to Validation and Test you can validate that the changes appear in both environments and that your environment variables, connection references and sharing has been successfully configured in each of the environments.

     ![image-20210506152743903](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506152743903.png)

1. The final step is to deploy your Solution to the **production environment**.

     - Create a new Pull Request in Azure DevOps that will pull the changes in ALMAcceleratorSampleSolution branch into the main branch and enter any required information.

       ![image-20210506151302121](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506151302121.png)

     - This time you will notice that there is **no Build Validation Policy enforcement** since we are only running the build validation for the ALMAcceleratorSampleSolution branch and **not the main branch**.

       ![image-20210506151536128](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506151536128.png)

     - **Approve and Complete** the Pull Request as before and verify that the **deploy-prod-ALMAcceleratorSampleSolution** pipeline runs to push your changes to Production.

       ![image-20210506152930801](.attachments/SAMPLESOLUTIONSETUPGUIDE/image-20210506152930801.png)

     - Once the pipeline for deploying to Production is finished you will see the status of the deployment in the App similar to the other stages.

       

     