# ALM Accelerator for Power Platform Extensions for Pipelines

The ALM Accelerator for Power Platform is a set of tools and processes that help organizations manage the application lifecycle of their Power Platform solutions. It includes features such as version control, automated testing, and continuous integration and deployment. The pipeline extensions solution allows you to add the ALM Accelerator features to your in-product Pipelines for Power Platform experience.

## Set up Pipelines for Power Platform

You can follow the steps [here](https://learn.microsoft.com/en-us/power-platform/alm/set-up-pipelines) to create your pipeline. The out of the box deployment pipelines available in the ALM Accelerator are Validation, Test and Production. You can create your pipeline with all three stages or if you decide you can just use Test and Production. You can also add additional stages to the ALM Accelerator for Power Platform Extensions by following the steps [here](https://learn.microsoft.com/en-us/power-platform/guidance/alm-accelerator/customize-deployment-pipelines).
**NOTE: Be sure to select 'Pre-Deployment Step Required' on each stage of your pipeline. This will ensure that the ALM Accelerator for Power Platform Extensions for Pipelines run the flow to unpack your solution and commit it to your repository.**

## Set up the ALM Accelerator for Power Platform Extensions for Pipelines

To set up the ALM Accelerator Pipeline Extensions, download the latest version of the follow the steps outlined in the Microsoft Learn content [here](https://learn.microsoft.com/en-us/power-platform/guidance/alm-accelerator/setup-admin-tasks). In the case of the Pipeline Extensions, you will need to download the latest version of the solution Center of Excellence - Pipelines Accelerator instead of the Center of Excellence - ALM Accelerator solution noted in the documentation. The Pipeline Accelerator Sample Solution can be found in the Samples.zip artifact in the coe-starter-kit repository's latest release.

## Set up a Default Deployment Profile

The ALM Accelerator relies on Deployment Profiles to define the environments that are used in the deployment process and the Azure DevOps Organization, Project and Repository where the pipelines exist and into which the solution source code will be saved. You can define a default deployment profile by using the following steps:
 - In the ALM Accelerator Admin App, Navigate to Deployment Profiles
 - Select New
    - Enter a Name for the Deployment Profile
    - Set the Default Deployment Profile flag to Yes
    - Enter the Azure DevOps Organization, Project and Repository name where the pipelines exist and into which the solution source code will be saved (Note: This is the project you just created in the previous step)
- Select Save

## Create the deployment steps

The ALM Accelerator Profile contains deployment steps that map to deployment stages in the pipeline. You can create the deployment steps by using the following steps:
 - In the ALM Accelerator Admin App on your Default Deployment Profile, Navigate to the Deployment Steps subgrid on the Deployment Profile form.
 - Select New Deployment Step
    - Enter a Name for the Deployment Step (Note: This should be the same name as the deployment stage you've created in your pipeline e.g. Test, UAT, Production, etc.)
    - Create a new Environment to set the Environment lookup field (Note: If prompted to Save and Close the step select Yes)
        - Enter a Name for the Environment (e.g. My Test Environment)
        - Enter the URL for the environment (e.g. https://mytestorg.crm.dynamics.com/). **Be sure to include a trailing slash**
    - Navigate back to the Deployment Step and ensure the Environment lookup field on the Deployment Step is set to the Environment you just created.
- Repeat the steps above for any other deployment stages you have in your pipeline.

## Use the ALM Accelerator for Power Platform Extensions for Pipelines

To use the extensions simply navigate to your maker/developer environment you specified in your pipeline and open the unmanaged solution you want to unpack / commit and deploy. Select the Pipelines icon (the one that looks like a rocket) and select the pipeline you created previously. Follow the steps [here](https://learn.microsoft.com/en-us/power-platform/alm/run-pipeline) to deploy your solution and run the extensions prior to deployment 
