"use strict";
import { DevOpsBranchArguments, DevOpsInstallArguments, DevOpsCommand, DevOpsExtension, DevOpsProjectSecurityContext } from '../../src/commands/devops'
import * as azdev from "azure-devops-node-api"
import { mock } from 'jest-mock-extended';
import { IHeaders, IHttpClientResponse, IRequestHandler } from 'azure-devops-node-api/interfaces/common/VsoBaseInterfaces';
import corem = require('azure-devops-node-api/CoreApi');
import CoreInterfaces = require('azure-devops-node-api/interfaces/CoreInterfaces');
import GitInterfaces = require('azure-devops-node-api/interfaces/GitInterfaces');
import gitm = require('azure-devops-node-api/GitApi');
import { IBuildApi } from "azure-devops-node-api/BuildApi";
import { BuildDefinitionReference, BuildDefinition, BuildDefinitionVariable, BuildRepository, YamlProcess } from 'azure-devops-node-api/interfaces/BuildInterfaces';
import { GitRepository } from 'azure-devops-node-api/interfaces/TfvcInterfaces';
import * as BuildInterfaces from 'azure-devops-node-api/interfaces/BuildInterfaces';
import { IPolicyApi } from 'azure-devops-node-api/PolicyApi';
import { PolicyType } from 'azure-devops-node-api/interfaces/PolicyInterfaces';
import { GitAsyncOperationStatus } from 'azure-devops-node-api/interfaces/GitInterfaces';
import httpm = require('typed-rest-client/HttpClient');
import { ITaskAgentApi } from 'azure-devops-node-api/TaskAgentApi';
import { AADAppSecret, AADCommand } from '../../src/commands/aad';
import { TeamProjectReference } from 'azure-devops-node-api/interfaces/CoreInterfaces';
import winston from 'winston';
import { ExtensionManagementApi } from 'azure-devops-node-api/ExtensionManagementApi';
import { InstalledExtension } from 'azure-devops-node-api/interfaces/ExtensionManagementInterfaces';
import { ITaskApi } from 'azure-devops-node-api/TaskApi';
import exp = require('constants');
import { RoleAssignment } from 'azure-devops-node-api/interfaces/SecurityRolesInterfaces';
import { IdentityRef } from 'azure-devops-node-api/interfaces/common/VSSInterfaces';
import { GraphGroup } from 'azure-devops-node-api/interfaces/GraphInterfaces';

describe('Install', () => {
    test('Import Repo', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>()
        let mockGitApi = mock<gitm.IGitApi>();
        let httpClient = mock<httpm.HttpClient>();
        let mockTaskAgentApi = mock<ITaskAgentApi>()

        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        command.runCommand = (command: string, displayOutput: boolean) => {
            return ""
        }
        command.getHttpClient = (connection: azdev.WebApi) => httpClient
        command.createWebApi = () => mockDevOpsWebApi

        httpClient.get.mockImplementation( (url:string, headers: IHeaders) => {
            let httpResponse = mock<IHttpClientResponse>();
            let result = JSON.stringify({value:[]})
           
            httpResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(httpResponse)
        })

        httpClient.put.mockImplementation( (url:string, data:string, headers: IHeaders) => {
            let httpResponse = mock<IHttpClientResponse>();
            let result = JSON.stringify({value:[]})
           
            httpResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(httpResponse)
        })

        httpClient.post.mockImplementation((url:string, data:string, headers: IHeaders) => {

            let httpResponse = mock<IHttpClientResponse>();
            let result = "[]"
            if ( url.indexOf("_apis/IdentityPicker/") > 0 ) {
                result = JSON.stringify({results: []})
            }
            httpResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(httpResponse)
        })

        
        mockDevOpsWebApi.getCoreApi.mockResolvedValue(mockCoreApi)
        mockDevOpsWebApi.getGitApi.mockResolvedValue(mockGitApi)
        mockDevOpsWebApi.getTaskAgentApi.mockResolvedValue(mockTaskAgentApi)

        mockCoreApi.getProjects.mockResolvedValue([<TeamProjectReference>{id:"1"}])
        mockGitApi.getRepositories.mockResolvedValue([])
        mockGitApi.getRefs.mockResolvedValue([])
        mockGitApi.createRepository.mockResolvedValue(<GitRepository>{id:"123"})
        mockGitApi.createImportRequest.mockResolvedValue(<GitInterfaces.GitImportRequest>{importRequestId: 1})
        mockGitApi.queryImportRequests.mockResolvedValue([<GitInterfaces.GitImportRequest>{importRequestId: 1, status: GitAsyncOperationStatus.Completed}])
        httpClient.patch.mockResolvedValue(null)
        let args = new DevOpsInstallArguments();

        mockTaskAgentApi.getVariableGroups.mockResolvedValue([{id:1, name: "alm-accelerator-variable-group"}])
        
        // Act
        await command.install(args)

        // Assert
    })

    test('Repo alredy exists', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        command.runCommand = (command: string, displayOutput: boolean) => {
            return ""
        }
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>();
        let mockGitApi = mock<gitm.IGitApi>();
        let httpClient = mock<httpm.HttpClient>();
        let httpResponse = mock<IHttpClientResponse>();
        let mockTaskAgentApi = mock<ITaskAgentApi>()

        command.getHttpClient = (connection: azdev.WebApi) => httpClient

        httpClient.get.mockImplementation((url: string, headers: IHeaders) => {
            let result = JSON.stringify({value:[]})

            if (url.indexOf("_apis/Graph/Groups") > 0) {
                result = JSON.stringify({value:[
                    {
                        displayName: "ALM Accelerator for Advanced Makers"
                    }
                ]})
            }

            httpResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(httpResponse)
        }) 

        httpClient.post.mockImplementation((url: string, data: string, headers: IHeaders) => {
            let result = JSON.stringify({value:[]})

            if (url.indexOf("_apis/IdentityPicker/Identities") > 0) {
                result = JSON.stringify({results:[
                ]})
            }

            httpResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(httpResponse)
        }) 

        httpClient.put.mockImplementation((url: string, data: string, headers: IHeaders) => {
            let result = JSON.stringify({value:[]})

            httpResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(httpResponse)
        }) 

        let args = new DevOpsInstallArguments();
        args.repositoryName = "pipeline"
        args.projectName = "test1"

        command.createWebApi = () => mockDevOpsWebApi
        mockDevOpsWebApi.getCoreApi.mockResolvedValue(mockCoreApi)
        mockDevOpsWebApi.getGitApi.mockResolvedValue(mockGitApi)
        
        mockDevOpsWebApi.getTaskAgentApi.mockResolvedValue(mockTaskAgentApi)
        mockTaskAgentApi.getVariableGroups.mockResolvedValue([{id:1, name: "alm-accelerator-variable-group"}])

        mockCoreApi.getProjects.mockResolvedValue([{
            name: args.projectName
        }])
        mockGitApi.getRepositories.mockResolvedValue([<GitRepository>{id:"123", name:"pipeline"}])
        mockGitApi.getRefs.mockResolvedValue([<GitInterfaces.GitRef>{}])
        
        // Act
        await command.install(args)

        // Assert
    })
})

describe('Install Build', () => {
    test('Error - Powershell Not Installed', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let args = new DevOpsInstallArguments();
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockBuildApi = mock<IBuildApi>();
        let repo = <GitRepository>{project: <CoreInterfaces.TeamProjectReference>{name:"P1"}}

        mockDevOpsWebApi.getBuildApi.mockResolvedValue(mockBuildApi)
        mockBuildApi.getDefinitions.mockResolvedValue([])
        
        // Act
        await command.createAdvancedMakersBuildPipelines(args, mockDevOpsWebApi, repo)

        // Assert
        expect(mockBuildApi.createDefinition).toHaveBeenCalled()
        expect(mockBuildApi.createDefinition.mock.calls[0][0].name).toBe('export-solution-to-git')
        expect((<YamlProcess>mockBuildApi.createDefinition.mock.calls[0][0].process).yamlFilename).toBe('/Pipelines/export-solution-to-git.yml')
        
        expect(mockBuildApi.createDefinition.mock.calls[1][0].name).toBe('import-unmanaged-to-dev-environment')
        expect((<YamlProcess>mockBuildApi.createDefinition.mock.calls[1][0].process).yamlFilename).toBe('/Pipelines/import-unmanaged-to-dev-environment.yml')

        expect(mockBuildApi.createDefinition.mock.calls[2][0].name).toBe('delete-unmanaged-solution-and-components')
        expect((<YamlProcess>mockBuildApi.createDefinition.mock.calls[2][0].process).yamlFilename).toBe('/Pipelines/delete-unmanaged-solution-and-components.yml')
    })
})

describe('Branch', () => {
    
    beforeEach(() => jest.clearAllMocks())

    test('Create new branch if project exists and source build exists', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>(); 
        let mockTaskAgentApi = mock<ITaskAgentApi>();
        
        let mockProject = mock<CoreInterfaces.TeamProject>()
        
        let mockGitApi = mock<gitm.IGitApi>();
        let mockBuildApi = mock<IBuildApi>();
        
        let mockRepo = mock<GitInterfaces.GitRepository>()
        let mockSourceRef = mock<GitInterfaces.GitRef>()

        let mockSourceBuildRef = mock<BuildDefinitionReference>();

        command.createWebApi = (org: string, handler: IRequestHandler) => mockDevOpsWebApi;
        command.getUrl = (url: string) => Promise.resolve('123')

        mockDevOpsWebApi.getCoreApi.mockResolvedValue(mockCoreApi)
        mockDevOpsWebApi.getGitApi.mockResolvedValue(mockGitApi)
        mockDevOpsWebApi.getBuildApi.mockResolvedValue(mockBuildApi)
        mockDevOpsWebApi.getTaskAgentApi.mockResolvedValue(mockTaskAgentApi)

        mockCoreApi.getProject.mockResolvedValue(mockProject)

        mockGitApi.getRepositories.mockResolvedValue([mockRepo])
        mockGitApi.getRefs.mockResolvedValue([mockSourceRef])

        mockBuildApi.getDefinitions.mockResolvedValue([])

        mockProject.name = 'alm-sandbox'
        mockRepo.name = 'repo1'
        mockRepo.defaultBranch = 'refs/heads/main'
        mockSourceRef.name = 'refs/heads/main'

        mockTaskAgentApi.getVariableGroups.mockResolvedValue([<BuildInterfaces.VariableGroup>{
            variables: {
                "ValidationServiceConnection": <BuildDefinitionVariable>{
                    value: "123"
                }
            }
        }])

        let args = new DevOpsBranchArguments();
        args.accessToken = "FOO"
        args.organizationName = "org"
        args.projectName = "P1"
        args.repositoryName = "repo1"        
        args.pipelineRepository = "templates"
        args.sourceBranch = "main"  
        args.sourceBuildName = "TestSolution"
        args.destinationBranch = "NewSolution"  

        // Act
        await command.branch(args)

        // Assert
        expect(mockDevOpsWebApi.getCoreApi).toHaveBeenCalled()
        expect(mockCoreApi.getProject).toHaveBeenCalled()
    })

    test('Create new branch if project exists and source build exists - Case Insentive', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>(); 
        let mockTaskAgentApi = mock<ITaskAgentApi>();
        
        let mockProject = mock<CoreInterfaces.TeamProject>()
        
        let mockGitApi = mock<gitm.IGitApi>();
        let mockBuildApi = mock<IBuildApi>();
        
        let mockRepo = mock<GitInterfaces.GitRepository>()
        let mockSourceRef = mock<GitInterfaces.GitRef>()

        let mockSourceBuildRef = mock<BuildDefinitionReference>();

        command.createWebApi = (org: string, handler: IRequestHandler) => mockDevOpsWebApi;
        command.getUrl = (url: string) => Promise.resolve('123')

        mockDevOpsWebApi.getCoreApi.mockResolvedValue(mockCoreApi)
        mockDevOpsWebApi.getGitApi.mockResolvedValue(mockGitApi)
        mockDevOpsWebApi.getBuildApi.mockResolvedValue(mockBuildApi)
        mockDevOpsWebApi.getTaskAgentApi.mockResolvedValue(mockTaskAgentApi)

        mockCoreApi.getProject.mockResolvedValue(mockProject)

        mockGitApi.getRepositories.mockResolvedValue([mockRepo])
        mockGitApi.getRefs.mockResolvedValue([mockSourceRef])

        mockBuildApi.getDefinitions.mockResolvedValue([])

        mockProject.name = 'alm-sandbox'
        mockRepo.name = 'RePo1'
        mockRepo.defaultBranch = 'refs/heads/main'
        mockSourceRef.name = 'refs/heads/main'

        mockTaskAgentApi.getVariableGroups.mockResolvedValue([<BuildInterfaces.VariableGroup>{
            variables: {
                "ValidationServiceConnection": <BuildDefinitionVariable>{
                    value: "123"
                }
            }
        }])

        let args = new DevOpsBranchArguments();
        args.accessToken = "FOO"
        args.organizationName = "org"
        args.projectName = "P1"
        args.repositoryName = "REPO1"
        args.pipelineRepository = "templates"        
        args.sourceBranch = "main"  
        args.sourceBuildName = "TestSolution"
        args.destinationBranch = "NewSolution"  

        // Act
        await command.branch(args)

        // Assert
        expect(mockDevOpsWebApi.getCoreApi).toHaveBeenCalled()
        expect(mockCoreApi.getProject).toHaveBeenCalled()
        expect(mockGitApi.createPush).toHaveBeenCalled()
        
    })

    test('Clone existing source build - validation', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockBuildApi = mock<IBuildApi>();

        let args = new DevOpsBranchArguments();
        args.accessToken = "FOO"
        args.organizationName = "org"
        args.projectName = "P1"
        args.repositoryName = "repo1"
        args.pipelineRepository = "templates"        
        args.sourceBranch = "main"  
        args.sourceBuildName = "TestSolution"
        args.destinationBranch = "NewSolution"  

        let project = <CoreInterfaces.TeamProject>{}
        project.name = 'test'

        let sourceValidationBuildDefinition = <BuildDefinitionReference>{}
        sourceValidationBuildDefinition.name = "deploy-validation-TestSolution"

        let sourceValidationBuild = <BuildDefinition>{}
        sourceValidationBuild.project = <CoreInterfaces.TeamProjectReference>{}
        sourceValidationBuild.project.name = 'Test Project'
        let variable = <BuildDefinitionVariable>{}
        variable.value = '123'
        sourceValidationBuild.variables = {
            Foo: variable
        }
        sourceValidationBuild.repository = <BuildRepository>{}
        sourceValidationBuild.repository.defaultBranch = 'main'
        
        mockBuildApi.getDefinitions.mockResolvedValue([sourceValidationBuildDefinition])
        mockBuildApi.getDefinition.mockResolvedValue(sourceValidationBuild)
        mockDevOpsWebApi.getBuildApi.mockResolvedValue(mockBuildApi)

        let repo = <GitRepository>{}
        
        // Act
        await command.createBuildForBranch(args, project, repo, mockDevOpsWebApi);

        // Assert
        expect(mockBuildApi.createDefinition).toHaveBeenCalled()
    })

    test('Clone existing source build - match validation', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockBuildApi = mock<IBuildApi>();

        let args = new DevOpsBranchArguments();
        args.accessToken = "FOO"
        args.organizationName = "org"
        args.projectName = "P1"
        args.repositoryName = "repo1"
        args.pipelineRepository = "templates"        
        args.sourceBranch = "main"  
        args.destinationBranch = "NewSolution"  

        let project = <CoreInterfaces.TeamProject>{}
        project.name = 'test'

        let sourceValidationBuildDefinition = <BuildDefinitionReference>{}
        sourceValidationBuildDefinition.name = "deploy-validation-TestSolution"

        let sourceValidationBuild = <BuildDefinition>{}
        sourceValidationBuild.project = <CoreInterfaces.TeamProjectReference>{}
        sourceValidationBuild.project.name = 'Test Project'
        let variable = <BuildDefinitionVariable>{}
        variable.value = '123'
        sourceValidationBuild.variables = {
            Foo: variable
        }
        sourceValidationBuild.repository = <BuildRepository>{}
        sourceValidationBuild.repository.defaultBranch = 'main'
        
        mockBuildApi.getDefinitions.mockResolvedValue([sourceValidationBuildDefinition])
        mockBuildApi.getDefinition.mockResolvedValue(sourceValidationBuild)
        mockDevOpsWebApi.getBuildApi.mockResolvedValue(mockBuildApi)

        let repo = <GitRepository>{}
        
        // Act
        await command.createBuildForBranch(args, project, repo, mockDevOpsWebApi);

        // Assert
        expect(mockBuildApi.createDefinition).toHaveBeenCalled()
    })


    test('Clone existing source build - validation using default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockBuildApi = mock<IBuildApi>();
        let mockTaskApi = mock<ITaskAgentApi>();

        let args = new DevOpsBranchArguments();
        args.accessToken = "FOO"
        args.organizationName = "org"
        args.projectName = "P1"
        args.repositoryName = "repo1"
        args.pipelineRepository = "templates"        
        args.sourceBuildName = "TestSolution"
        args.destinationBranch = "NewSolution"  

        let project = <CoreInterfaces.TeamProject>{}
        project.name = 'test'

        let sourceValidationBuildDefinition = <BuildDefinitionReference>{}
        sourceValidationBuildDefinition.name = "deploy-validation-TestSolution"

        let sourceValidationBuild = <BuildDefinition>{}
        sourceValidationBuild.project = <CoreInterfaces.TeamProjectReference>{}
        sourceValidationBuild.project.id = '1'
        let variable = <BuildDefinitionVariable>{}
        variable.value = '123'
        sourceValidationBuild.variables = {
            Foo: variable
        }
        sourceValidationBuild.repository = <BuildRepository>{}
        sourceValidationBuild.repository.defaultBranch = 'main'
        sourceValidationBuild.queue = <BuildInterfaces.AgentPoolQueue>{}
        sourceValidationBuild.queue.name = "Test Pool"
        sourceValidationBuild.triggers = <BuildInterfaces.BuildTrigger[]>[{}]
        sourceValidationBuild.triggers[0].triggerType = BuildInterfaces.DefinitionTriggerType.ContinuousIntegration

        
        mockBuildApi.getDefinitions.mockResolvedValue([sourceValidationBuildDefinition])
        mockBuildApi.getDefinition.mockResolvedValue(sourceValidationBuild)
        mockTaskApi.getAgentPools.mockResolvedValue([])

        mockDevOpsWebApi.getBuildApi.mockResolvedValue(mockBuildApi)
        mockDevOpsWebApi.getTaskAgentApi.mockResolvedValue(mockTaskApi)

        command.getUrl = () => Promise.resolve("[SampleSolutionName]-[SampleSolutionName]")

        let repo = <GitRepository>{}
        
        // Act
        await command.createBuildForBranch(args, project,repo, mockDevOpsWebApi);

        // Assert
        expect(mockBuildApi.createDefinition.mock.calls[0][0].name).toBe("deploy-validation-NewSolution")
        expect((<YamlProcess>mockBuildApi.createDefinition.mock.calls[0][0].process).yamlFilename).toBe("/NewSolution/deploy-validation-NewSolution.yml")
        expect(mockBuildApi.createDefinition.mock.calls[0][0].path).toBe("/NewSolution")
        expect(mockBuildApi.createDefinition.mock.calls[0][0].repository.defaultBranch).toBe("NewSolution")
        expect(mockBuildApi.createDefinition.mock.calls[0][0].variables.Foo.value).toBe("123")
        expect(mockBuildApi.createDefinition.mock.calls[0][0].queue.name).toBe("Test Pool")
        expect(mockBuildApi.createDefinition.mock.calls[0][0].triggers.length).toBe(1)
        expect(mockBuildApi.createDefinition.mock.calls[0][0].triggers[0].triggerType).toBe(BuildInterfaces.DefinitionTriggerType.ContinuousIntegration)
        expect(mockBuildApi.createDefinition).toHaveBeenCalled()
    })

    
    
});

describe('Build', () => {
    
    beforeEach(() => jest.clearAllMocks())

    test('Empty repo', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let args = new DevOpsBranchArguments();
        let project = <CoreInterfaces.TeamProject>{}
        let gitMock = mock<gitm.GitApi>()
        project.name = 'test'
        command.getUrl = () => Promise.resolve(`[SampleSolutionName]
-[BranchContainingTheBuildTemplates]
-[RepositoryContainingTheBuildTemplates]
-[SampleSolutionName]`)

        args.projectName = 'DevOpsProject'
        args.repositoryName = 'alm-sandbox'
        
        let repo = <GitRepository>{}
        repo.name = 'alm-sandbox'

        args.projectName = 'test'
        args.destinationBranch = "New"

        gitMock.getRepositories.mockResolvedValue([repo])
        gitMock.getRefs.mockResolvedValue([])

        // Act
        await command.createBranch(args, project, gitMock)

        // Assert
        
        expect(gitMock.createPush).toBeCalledTimes(0)
    });

    test('Clone existing source build - validation using default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let args = new DevOpsBranchArguments();
        let project = <CoreInterfaces.TeamProject>{}
        let gitMock = mock<gitm.GitApi>()
        project.name = 'test'
        command.getUrl = () => Promise.resolve(`[SampleSolutionName]
-[BranchContainingTheBuildTemplates]
-[RepositoryContainingTheBuildTemplates]
-[SampleSolutionName]`)

        args.projectName = 'DevOpsProject'
        args.repositoryName = 'alm-sandbox'
        
        let repo = <GitRepository>{}
        repo.defaultBranch = 'refs/heads/main'
        repo.name = 'alm-sandbox'

        let refSource = <GitInterfaces.GitRef>{}
        refSource.name = "refs/heads/main"

        args.projectName = 'test'
        args.destinationBranch = "New"
        args.pipelineRepository = "templates"

        gitMock.getRepositories.mockResolvedValue([repo])
        gitMock.getRefs.mockResolvedValue([refSource])

        // Act
        await command.createBranch(args, project, gitMock)

        // Assert
        
        expect(gitMock.createPush).toHaveBeenCalled()
        expect(gitMock.createPush.mock.calls[0][0].commits[0].changes.length).toBe(3)
        expect(gitMock.createPush.mock.calls[0][0].commits[0].changes[0].item.path).toBe("/New/deploy-validation-New.yml")
        expect(gitMock.createPush.mock.calls[0][0].commits[0].changes[0].newContent.content).toBe(`[New]
-[main]
-[templates]
-[New]`)
    })
});

describe('Policy', () => {
    
    beforeEach(() => jest.clearAllMocks())

    test('Do nothing policy exists', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let args = new DevOpsBranchArguments();
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockPolicyApi = mock<IPolicyApi>();
        let mockBuildApi = mock<IBuildApi>();

        args.projectName = 'DevOpsProject'
        args.repositoryName = 'alm-sandbox'
        args.destinationBranch = 'Test1'

        mockDevOpsWebApi.getPolicyApi.mockResolvedValue(mockPolicyApi)
        mockDevOpsWebApi.getBuildApi.mockResolvedValue(mockBuildApi)

        let existingBuild = <BuildDefinitionReference>{}
        existingBuild.id = 1
        existingBuild.name = 'deploy-validation-Test1'

        let buildPolicy = <PolicyType>{}
        buildPolicy.displayName = 'Build'

        mockPolicyApi.getPolicyConfigurations.mockResolvedValue([])
        mockPolicyApi.getPolicyTypes.mockResolvedValue([buildPolicy])
        mockBuildApi.getDefinitions.mockResolvedValue([existingBuild])

        let repo = <GitRepository>{}
        repo.id = '123'

        // Act
        await command.setBranchPolicy(args, repo, mockDevOpsWebApi)

        // Assert
        expect(mockPolicyApi.createPolicyConfiguration).toHaveBeenCalled()
        expect(mockPolicyApi.createPolicyConfiguration.mock.calls[0][0].type.displayName).toBe("Build")
        expect(mockPolicyApi.createPolicyConfiguration.mock.calls[0][0].settings.displayName).toBe("Build Validation")
        expect(mockPolicyApi.createPolicyConfiguration.mock.calls[0][0].settings.filenamePatterens[0]).toBe("/Test1/*")
        expect(mockPolicyApi.createPolicyConfiguration.mock.calls[0][0].settings.scope[0].refName).toBe("refs/heads/Test1")
        expect(mockPolicyApi.createPolicyConfiguration.mock.calls[0][0].settings.scope[0].repositoryId).toBe("123")
        expect(mockPolicyApi.createPolicyConfiguration.mock.calls[0][0].settings.scope[0].matchKind).toBe("Exact")
    })
});

describe('Build Variables', () => {
    
    beforeEach(() => jest.clearAllMocks())

    test('Create', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        let args = new DevOpsInstallArguments();
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockTaskApi = mock<ITaskAgentApi>();
        let mockBuildApi = mock<IBuildApi>();
        let mockHttpClient = mock<httpm.HttpClient>()

        let mockAADCommand = mock<AADCommand>()
        command.createAADCommand= () => mockAADCommand
        command.getHttpClient = () => mockHttpClient

        args.projectName = 'DevOpsProject'
        args.repositoryName = 'alm-sandbox'
        args.createSecretIfNoExist = true

        mockDevOpsWebApi.getTaskAgentApi.mockResolvedValue(mockTaskApi)
        mockDevOpsWebApi.getBuildApi.mockResolvedValue(mockBuildApi)

        mockTaskApi.getVariableGroups.mockResolvedValue([])
        mockTaskApi.addVariableGroup.mockResolvedValue({id:1})

        mockBuildApi.getDefinitions.mockResolvedValue([<BuildDefinitionReference>{id:1, name: "export-solution-to-git"}])

        mockAADCommand.addSecret.mockResolvedValue(<AADAppSecret>{clientId:'C1', clientSecret:'S1', tenantId:'T1'})

        let getRequest = mock<IHttpClientResponse>()
        getRequest.readBody.mockResolvedValue(JSON.stringify({value:[]}))
        mockHttpClient.get.mockResolvedValue(getRequest);

        let putRequest = mock<IHttpClientResponse>()
        putRequest.readBody.mockResolvedValue(JSON.stringify({value: [<RoleAssignment>{ identity: <IdentityRef>{}}]}))
        mockHttpClient.put.mockResolvedValue(putRequest);

        let securityContext = <DevOpsProjectSecurityContext>{
            almGroup: <GraphGroup>{}
        }
        
        // Act
        await command.createAdvancedMakersBuildVariables(args, mockDevOpsWebApi, securityContext)

        // Assert
        expect(mockAADCommand.addSecret).toBeCalledTimes(1)
    })
});

describe('Extensions', () => {
    test('No extensions installed', async () => {

        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger);
        let args = new DevOpsInstallArguments();
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockExtensionManagementApi = mock<ExtensionManagementApi>(); 

        args.extensions = []
        args.extensions.push(<DevOpsExtension> {
            name: 'test',
            publisher: "P1"
        })

        mockDevOpsWebApi.getExtensionManagementApi.mockResolvedValue(mockExtensionManagementApi)
        mockExtensionManagementApi.getInstalledExtensions.mockResolvedValue([])

        // Act
        await command.installExtensions(args, mockDevOpsWebApi)

        // Assert
        expect(mockDevOpsWebApi.getExtensionManagementApi).toBeCalledTimes(1)
        expect(mockExtensionManagementApi.getInstalledExtensions).toBeCalledTimes(1)
        expect(mockExtensionManagementApi.installExtensionByName).toBeCalledTimes(1)
    })

    test('Extenion Installed', async () => {

        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger);
        let args = new DevOpsInstallArguments();
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockExtensionManagementApi = mock<ExtensionManagementApi>(); 

        args.extensions = []
        args.extensions.push(<DevOpsExtension> {
            name: 'test',
            publisher: "P1"
        })

        mockDevOpsWebApi.getExtensionManagementApi.mockResolvedValue(mockExtensionManagementApi)
        mockExtensionManagementApi.getInstalledExtensions.mockResolvedValue([<InstalledExtension>{
            extensionId: 'test',
            publisherId: 'P1'
        }])

        // Act
        await command.installExtensions(args, mockDevOpsWebApi)

        // Assert
        expect(mockDevOpsWebApi.getExtensionManagementApi).toBeCalledTimes(1)
        expect(mockExtensionManagementApi.getInstalledExtensions).toBeCalledTimes(1)
        expect(mockExtensionManagementApi.installExtensionByName).toBeCalledTimes(0)
    })
})

describe('Service Connections', () => {
    
    beforeEach(() => jest.clearAllMocks())

    test('Create', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>(); 
        let mockAADCommand = mock<AADCommand>(); 
        let mockHttpClient = mock<httpm.HttpClient>(); 
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        command.createAADCommand = () => mockAADCommand
        command.getHttpClient = (connection: azdev.WebApi) => mockHttpClient
        let args = new DevOpsInstallArguments();
        
        args.environment = "E1"
        args.settings = { 'region': 'NAM' }
        args.projectName = "P1"

        mockDevOpsWebApi.getCoreApi.mockResolvedValue(mockCoreApi)
        mockCoreApi.getProjects.mockResolvedValue([{name: 'p1'}])

        
        mockHttpClient.get.mockImplementation((url: string, header: IHeaders) => {
            let mockGetResponse = mock<IHttpClientResponse>()
            mockGetResponse.readBody.mockResolvedValue(JSON.stringify({value:[{name:'E1'}]}))
            return Promise.resolve(mockGetResponse)
        })

        let mockPostResponse = mock<IHttpClientResponse>()
        mockPostResponse.message.statusCode = 200
        mockPostResponse.readBody.mockResolvedValue(JSON.stringify({id:'S123'}))
        mockHttpClient.post.mockResolvedValue(mockPostResponse)

        mockAADCommand.addSecret.mockResolvedValue(<AADAppSecret> {})

        // Act
        await command.createAdvancedMakersServiceConnections(args, mockDevOpsWebApi, false)

        // Assert
        expect(mockAADCommand.addSecret).toBeCalledTimes(1)
        
    })

    test('Assign users', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockHttpClient = mock<httpm.HttpClient>(); 
        var command = new DevOpsCommand(logger, { readFile: () => Promise.resolve("[]" )});
        command.getHttpClient = (connection: azdev.WebApi) => mockHttpClient
        let args = new DevOpsInstallArguments();
        let project = mock<CoreInterfaces.TeamProjectReference>()
        
        args.organizationName = 'dev12345'
        args.projectName = 'test1'
        args.environment = 'test'
        args.user = "test@microsoft.com"
        args.settings = {
            'region': 'NAM'
        }
       
        mockHttpClient.get.mockImplementation((url: string, header: IHeaders) => {
            if ( url.indexOf('/_apis/serviceendpoint') > 0 ) {
                let mockGetResponse = mock<IHttpClientResponse>()
                mockGetResponse.readBody.mockResolvedValue(JSON.stringify({value:[{url:'https://test.crm.dynamics.com', id:'SC1'}]}))
                return Promise.resolve(mockGetResponse)
            }

            if ( url.indexOf('/_apis/securityroles') > 0 ) {
                let mockGetResponse = mock<IHttpClientResponse>()
                mockGetResponse.readBody.mockResolvedValue(JSON.stringify({value:[]}))
                return Promise.resolve(mockGetResponse)
            }

            if ( url.indexOf('_apis/identities') > 0 ) {
                let mockGetResponse = mock<IHttpClientResponse>()
                mockGetResponse.readBody.mockResolvedValue(JSON.stringify({value:[{properties:{ Account: {
                    '$value':'test@microsoft.com'
                }}, id:'U1234'}]}))
                return Promise.resolve(mockGetResponse)
            }
        })

        let mockPostResponse = mock<IHttpClientResponse>()
        mockPostResponse.message.statusCode = 200
        mockPostResponse.readBody.mockResolvedValue("{'id':'S123'")
        mockHttpClient.put.mockResolvedValue(mockPostResponse)

        project.id = 'P1'

        // Act
        await command.assignUserToServiceConnector(project, "https://test.crm.dynamics.com", args, mockDevOpsWebApi)

        // Assert
        expect(mockHttpClient.put).toBeCalledTimes(1)
    })
});

describe('Security', () => {
    test('Project Found, Create Group, AAD Group Found', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>()
        let mockHttpClient = mock<httpm.HttpClient>(); 

        var command = new DevOpsCommand(logger, null)
        command.getHttpClient = () => mockHttpClient

        mockDevOpsWebApi.getCoreApi.mockResolvedValue(mockCoreApi)
        mockCoreApi.getProjects.mockResolvedValue([{name:"test1"}])

        let args = new DevOpsInstallArguments()
        args.projectName = "test1"
        args.azureActiveDirectoryMakersGroup = 'AADMaker'

        mockHttpClient.get.mockImplementation((url: string, header: IHeaders) => {
            let mockResponse = mock<IHttpClientResponse>()
            let result = JSON.stringify({value:[]})
            mockResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(mockResponse)
        })

        mockHttpClient.post.mockImplementation((url: string, data: string, header: IHeaders) => {
            let mockResponse = mock<IHttpClientResponse>()
            let result = JSON.stringify({value:[]})
            if (url.indexOf("_apis/graph/groups")> 0) {
                result = JSON.stringify({displayName:'New Group'})
            }
            if (url.indexOf("_apis/IdentityPicker")> 0) {
                result = JSON.stringify({results:[
                    {
                        displayName: args.azureActiveDirectoryMakersGroup,
                        entityType: "Group",
                        originDirectory: "aad",
                        subjectDescriptor: "ABC"
                    }
                ]})
            }
            mockResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(mockResponse)
        })

        // Act
        let result = await command.setupSecurity(args, mockDevOpsWebApi)

        // Assert
        expect(result.almGroup.displayName).toBe("New Group")
    });

    test('Project Found, Create Group, New AAD Group', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>()
        let mockHttpClient = mock<httpm.HttpClient>(); 

        var command = new DevOpsCommand(logger, null)
        command.getHttpClient = () => mockHttpClient

        mockDevOpsWebApi.getCoreApi.mockResolvedValue(mockCoreApi)
        mockCoreApi.getProjects.mockResolvedValue([{name:"test1"}])

        let args = new DevOpsInstallArguments()
        args.projectName = "test1"
        args.azureActiveDirectoryMakersGroup = 'AADMaker'

        mockHttpClient.get.mockImplementation((url: string, header: IHeaders) => {
            let mockResponse = mock<IHttpClientResponse>()
            let result = JSON.stringify({value:[]})
            mockResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(mockResponse)
        })

        mockHttpClient.post.mockImplementation((url: string, data: string, header: IHeaders) => {
            let mockResponse = mock<IHttpClientResponse>()
            let result = JSON.stringify({value:[]})
            if (url.indexOf("_apis/graph/groups")> 0) {
                result = JSON.stringify({displayName:'New Group', descriptor: "NEW"})
            }
            if (url.indexOf("_apis/IdentityPicker")> 0) {
                result = JSON.stringify({results:[
                    {
                        displayName: args.azureActiveDirectoryMakersGroup,
                        entityType: "Group",
                        originDirectory: "aad",
                        subjectDescriptor: null
                    }
                ]})
            }
            mockResponse.readBody.mockResolvedValue(result)
            return Promise.resolve(mockResponse)
        })

        // Act
        let result = await command.setupSecurity(args, mockDevOpsWebApi)

        // Assert
        expect(result.almGroup.displayName).toBe("New Group")
        expect(result.almGroup.descriptor).toBe("NEW")
    });
})