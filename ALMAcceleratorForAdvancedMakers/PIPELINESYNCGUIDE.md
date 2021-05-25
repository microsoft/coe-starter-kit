# ALM Accelerator for Advanced Makers Pipeline Sync

## Pipeline Sync Setup

The Pipeline Sync script was created to make synchronizing the ALM Accelerator for Advanced Makers' (AA4AM) pipeline templates simpler. As the pipeline templates grow and change users are required to update the pipelines with each release of AA4AM. To simplify this process we created another pipeline template that will automatically sync your Azure DevOps repo with the pipeline template repo in GitHub. Follow the steps below to get started using the Pipeline Sync pipeline.

1. Initially, you will need to manually copy the pipeline templates from https://github.com/microsoft/coe-alm-accelerator-templates/blob/main/Pipelines/. Follow the steps in the [SETUPGUIDE.md](SETUPGUIDE.md#copy-the-YAML-pipelines-from-github-to-your-azure-devops-instance) to clone the pipeline template repo to your Azure DevOps repo.

1. In Azure DevOps go to **Pipelines** and **Create a New Pipeline**

1. Select **Azure Repos Git** for your code Repository and point to Azure DevOps repo you created and seeded with the pipeline templates in step 1.
   ![image.png](.attachments/GETTINGSTARTED/image-b27c7dc5-7fe7-449f-99bc-73b9b351cc94.png)

1. On the **Configure your pipeline** page select **Existing Azure Pipelines YAML file** and point to **/Pipelines/sync-pipeline-repo.yml** and Select **Continue**.
   ![image-20210524091622017](.attachments/PIPELINESYNCGUIDE/image-20210524091622017.png)

1. On the next screen Select **Save** and then Select the **3 dots next to Run Pipeline** and Select **Rename/Move**.
   ![image.png](.attachments/GETTINGSTARTED/image-c4e3cc16-3abd-453b-a420-9366ef587e8c.png)

1. Update the pipeline name to **sync-pipeline-repo** and select **Save**.

1. Set the **TEMPLATE-REPO pipeline variable** to https://github.com/microsoft/coe-alm-accelerator-templates

   > [!NOTE] The Sync Pipeline can be used to sync any GitHub repo to Azure DevOps. Setting the TEMPLATE-REPO to the source GitHub repo allows you to specify the source of the sync.

   ![image-20210524095158923](.attachments/PIPELINESYNCGUIDE/image-20210524095158923.png)

1. Run the new Pipeline

   ![image-20210524091948116](.attachments/PIPELINESYNCGUIDE/image-20210524091948116.png)

8. Enter the name of the **SourceBranch**, **BranchToCreate** in Azure DevOps and the **TargetBranch** (e.g. main) and **Select Run**

   ![image-20210524101705475](.attachments/PIPELINESYNCGUIDE/image-20210524101705475.png)

9. After the Pipeline runs a Pull Request will be created for the **BranchToCreate** into the **TargetBranch**. To commit the changes **Approve and Complete the Pull Request**.

   ![image-20210524102603951](.attachments/PIPELINESYNCGUIDE/image-20210524102603951.png)