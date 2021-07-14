# Use the ALM Accelerator for Advanced Maker App (Preview)

>  [!NOTE] ALM Accelerator for Advanced Makers is currently in public preview. Please see Issues currently tagged as [vnext](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aopen+is%3Aissue+label%3Aalm-accelerator+label%3Avnext) for the Roadmap to be completed prior to general availability. While in Public Preview it can be expected that there will be breaking changes and frequent updates to address feedback from preview members. Additionally, the Public Preview is reliant on the experimental [Power Apps Source File Pack and Unpack Utility](https://github.com/microsoft/PowerApps-Language-Tooling) that is being developed separately from AA4AM.

1. Once the app is installed and configured launch it from your Environment under Apps.

   > [!NOTE] When you first launch the app you may need to consent to the app using your connections.

1. Select the **Cog** in the top right to select your **Azure DevOps Environment**, **Project** and **Repo** to which you'll push your changes and submit your pull requests and select **Save**
   ![Configure Settings for AA4AM](.attachments/GETTINGSTARTED/image-20210303085854533.png)

   > [!NOTE] If you don't see your DevOps Organization / Project in the dropdown double check that the Custom connector is working correctly after updating it's Security settings.

1. From the Environment Drop Down **Select the Dataverse Environment** in which you will be doing your development work.
   ![Select Dataverse Environment](.attachments/GETTINGSTARTED/image-20210303085806618.png)

   > [!NOTE] In order for your Environment to show up in this drop down a service connection in the Azure DevOps project you just selected is required (see [Create a Service Connection for DevOps to access Power Platform](SETUPGUIDE.md#create-service-connections-for-devops-to-access-power-platform). Additionally, verify that you've followed the steps to reconnect the flow above if you do not see any environments in the list.

1. By default the **unmanaged solutions** in your Environment should be displayed in the main window with buttons to **Push Changes** and **Create Pull Requests**.

1. To import an unmanaged solution from an existing Azure DevOps project to begin making changes select the **+ Import Solutions** button and select a **Branch Name, Solution Folder and Configuration (Optional)**.

   - **Branch Name** is based on the branches in Azure DevOps for the Project you selected in the configuration. 

   - **Solution Folder** is a list of folders in the selected branch that contain a **SolutionPackage folder** from a previous export.

   - **Configuration** is a directory under the config directory in the Solution Folder that contains deployment settings and configuration data. For more information on this see the [DEPLOYMENTCONFIGGUIDE](DEPLOYMENTCONFIGGUIDE.md)

   > [!NOTE] The idea here is that you are either pulling the latest from the Solution branch or possibly want to pull another makers branch into your own environment. The configuration allows you to ensure that all of the necessary post solution import configuration and data exists in your environment.

   ![Import Solution from Branch in Azure DevOps](.attachments/GETTINGSTARTED/image-20210303085946610.png)

1. Once your solution is imported into Dataverse, or you've created a new unmanaged solution and made your customizations, you can push your changes to Git using the **Push Changes to Git** button for your solution.

   >[!NOTE]: Be sure to publish your changes before initiating the push. If a newly created solution doesn't show in your list immediately. Click the Refresh button to reload all solutions.

   - Select an **existing branch** or **create a new branch** based on an existing branch and enter a **comment**. Use the hashtag notation e.g. `#123` to link the changes to a specific work item in Azure DevOps and Select **Commit**.
     ![Export Solution from Dataverse to New Azure DevOps Branch](.attachments/GETTINGSTARTED/image-20210303085710535.png)

   - When the push begins a waiting indicator will appear. If the push is successful a checkbox will appear otherwise a red x will appear. In order to see the progress of your push select the progress indicator which will take you to the running pipeline in Azure DevOps.
   - Repeat the pushes as you iterate on your solution.
   
1. When you are ready to create a pull request for the changes to your branch select the Create Pull Request button.

   >[!NOTE]: Be sure to publish your changes before initiating the push.

   - Specify the Source and Target branch and enter a Title and Comment for your Pull Request and Select Create.**
     ![image-20210303085543943](.attachments/GETTINGSTARTED/image-20210303085409740.png)

1. Once a Pull Request is created for your changes the remaining steps to Merge and Release to Test occur in Azure DevOps. Depending on the Branch Policies and Triggers configured for your Target Branch, an Azure DevOps user can approve or reject your Pull Request based on their findings in the submitted changes and that status will appear in the App. 

1. In order to initiate a **solution upgrade** in the target environment you can tag a Pull Request with the **solution-upgrade** tag. 

   ![image-20210524113929989](.attachments/SETUPGUIDE/image-20210524113929989.png)

1. Approving the PR will initiate the deployment of your solution to the Test environment. If the Pull Request is approved you will see the progress move to Test and a status based on the pipeline's success or failure in that stage.

   ![image-20210303085132733](.attachments/GETTINGSTARTED/image-20210303085132733.png)

1. For Production a Pull Request will need to be created in Azure DevOps that merges the changes into your Production release branch. The same approval process will be required depending on your branch policies and once the PR is completed your solution will be pushed to Production. Once the pipeline for deploying to Production is finished you will see the status of the deployment in the App.

## Troubleshooting

1. Occasionally, you may see the following when launching the app. "The app stopped working. Try refreshing your browser." This generally happens after launching the app and then getting a prompt to login. To get around this issue use a **private browser session**. This isn't an issue with the app itself but an issue with credential caching in the browser.

   ![image-20210225172822543](.attachments/USERGUIDE/image-20210225172822543.png)