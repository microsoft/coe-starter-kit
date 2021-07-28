## AA4AM Advanced Maker Solution Branch

The ALM Accelerator for Advanced Makers (AA4AM) branch command allows Advanced Makers to create a branch in the source code repository to store and build a Power Platform solution. To run the branch command the repository that is being branched mys exist and be initialized with an initial commit

The process will
1. Create a source code git branch

2. Create build pipelines to validate, test and move to production

### Examples

```bash
coe aa4am branch \
    -o https://dev.azure.com/contoso \
    -p alm-sandbox \
    -r Operations \
    -d MyTestSolution \
    -s validation=https://contoso-validation.crm.dynamics.com,test=https://contoso-test.crm.dynamics.com,https://contoso.crm.dynamics.com
```

### Parameters

#### -o, --devOpsOrganization

The Azure DevOps organization that will be installed to or referenced.

The value can be in the format https://dev.azure.com/contoso or contoso. If the fully qualified Url is not specified then https://dev.azure.com/ will be inserted before the provided value.

#### -p, --project

The Azure DevOps project name. The project must already be created in your Azure DevOps organization. This value will be used to:
 - Create Variable Group
 - Import Azure DevOps pipeline templates
 - Create Azure DevOps pipelines to import, export and delete solutions in the Power Platform environments

The default value is **alm-sandbox**

#### -d, --destination

The destination solution branch name to create

#### -r, --repository

The Azure DevOps repository to create the branch in. If the name of the repository is not supplied then it will be assumed to be the name of the project.

##### --pipelineRepository

The Azure DevOps repository where Azure DevOps pipeline templates cloned from https://github.com/microsoft/coe-alm-accelerator-templates.git

#### --source

The source branch to copy from. If not supplied assume that a new branch is being created

#### --source-build

The source build to copy build variable from. If not supplied the process will 

1. Attempt to copy values for validation, test and production from other solution branch build variables

2. Get values from Variable Groups

3. Use placeholder values that must be manually updated by a Build Administrator

#### -s, --settings

The optional settings. Can be used to set the service connections for the build pipelines **validation**, **test** and **prod**



