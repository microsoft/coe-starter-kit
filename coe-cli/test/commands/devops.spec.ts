"use strict";
import { DevOpsBranchArguments, DevOpsInstallArguments, DevOpsCommand } from '../../src/commands/devops'
import * as azdev from "azure-devops-node-api"
import { mock } from 'jest-mock-extended';
import { IHttpClientResponse, IRequestHandler } from 'azure-devops-node-api/interfaces/common/VsoBaseInterfaces';
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

describe('Install', () => {
    test('Error - Powershell Not Installed', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger);
        
        command.runCommand = (command: string, displayOutput: boolean) => {
            if (command.startsWith("pwsh --version")) {
                throw Error("pwsh not found")
            }
            return ""
        }

        let args = new DevOpsInstallArguments();
        
        // Act
        await command.install(args)

        // Assert
    })

    test('Import Repo', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger);
        command.runCommand = (command: string, displayOutput: boolean) => {
            return ""
        }
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>()
        let mockGitApi = mock<gitm.IGitApi>();
        let httpClient = mock<httpm.HttpClient>();
        let httpResponse = mock<IHttpClientResponse>();

        command.getHttpClient = (connection: azdev.WebApi) => httpClient
        httpClient.get.mockResolvedValue(httpResponse)
        httpResponse.readBody.mockResolvedValue("[]")

        command.createWebApi = () => mockDevOpsWebApi
        mockDevOpsWebApi.getCoreApi.mockResolvedValue(mockCoreApi)
        mockDevOpsWebApi.getGitApi.mockResolvedValue(mockGitApi)

        mockCoreApi.getProjects.mockResolvedValue([<TeamProjectReference>{id:"1"}])
        mockGitApi.getRepositories.mockResolvedValue([])
        mockGitApi.getRefs.mockResolvedValue([])
        mockGitApi.createRepository.mockResolvedValue(<GitRepository>{id:"123"})
        mockGitApi.createImportRequest.mockResolvedValue(<GitInterfaces.GitImportRequest>{importRequestId: 1})
        mockGitApi.queryImportRequests.mockResolvedValue([<GitInterfaces.GitImportRequest>{importRequestId: 1, status: GitAsyncOperationStatus.Completed}])
        httpClient.patch.mockResolvedValue(null)
        let args = new DevOpsInstallArguments();
        
        // Act
        await command.install(args)

        // Assert
    })

    test('Repo alredy exists', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger);
        command.runCommand = (command: string, displayOutput: boolean) => {
            return ""
        }
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>();
        let mockGitApi = mock<gitm.IGitApi>();
        let httpClient = mock<httpm.HttpClient>();
        let httpResponse = mock<IHttpClientResponse>();

        command.getHttpClient = (connection: azdev.WebApi) => httpClient

        httpClient.get.mockResolvedValue(httpResponse)
        httpResponse.readBody.mockResolvedValue("[]")

        command.createWebApi = () => mockDevOpsWebApi
        mockDevOpsWebApi.getCoreApi.mockResolvedValue(mockCoreApi)
        mockDevOpsWebApi.getGitApi.mockResolvedValue(mockGitApi)

        mockCoreApi.getProjects.mockResolvedValue([])
        mockGitApi.getRepositories.mockResolvedValue([<GitRepository>{id:"123", name:"pipeline"}])
        mockGitApi.getRefs.mockResolvedValue([<GitInterfaces.GitRef>{}])
        let args = new DevOpsInstallArguments();
        args.repositoryName = "pipeline"
        
        // Act
        await command.install(args)

        // Assert
    })
})

describe('Install Build', () => {
    test('Error - Powershell Not Installed', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger);
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
        var command = new DevOpsCommand(logger);
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockCoreApi = mock<corem.ICoreApi>(); 
        
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

        mockCoreApi.getProject.mockResolvedValue(mockProject)

        mockGitApi.getRepositories.mockResolvedValue([mockRepo])
        mockGitApi.getRefs.mockResolvedValue([mockSourceRef])

        mockBuildApi.getDefinitions.mockResolvedValue([])

        mockProject.name = 'alm-sandbox'
        mockRepo.name = 'repo1'
        mockRepo.defaultBranch = 'refs/heads/main'
        mockSourceRef.name = 'refs/heads/main'

        let args = new DevOpsBranchArguments();
        args.accessToken = "FOO"
        args.organizationName = "org"
        args.projectName = "P1"
        args.repositoryName = "repo1"        
        args.sourceBranch = "main"  
        args.sourceBuildName = "TestSolution"
        args.destinationBranch = "NewSolution"  

        // Act
        await command.branch(args)

        // Assert
        expect(mockDevOpsWebApi.getCoreApi).toHaveBeenCalled()
        expect(mockCoreApi.getProject).toHaveBeenCalled()
    })

    test('Clone existing source build - validation', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger);
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockBuildApi = mock<IBuildApi>();

        let args = new DevOpsBranchArguments();
        args.accessToken = "FOO"
        args.organizationName = "org"
        args.projectName = "P1"
        args.repositoryName = "repo1"        
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
        var command = new DevOpsCommand(logger);
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockBuildApi = mock<IBuildApi>();

        let args = new DevOpsBranchArguments();
        args.accessToken = "FOO"
        args.organizationName = "org"
        args.projectName = "P1"
        args.repositoryName = "repo1"        
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
        var command = new DevOpsCommand(logger);
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockBuildApi = mock<IBuildApi>();
        let mockTaskApi = mock<ITaskAgentApi>();

        let args = new DevOpsBranchArguments();
        args.accessToken = "FOO"
        args.organizationName = "org"
        args.projectName = "P1"
        args.repositoryName = "repo1"        
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

    test('Clone existing source build - validation using default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger);
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
-[pipelines]
-[New]`)
    })
});

describe('Policy', () => {
    
    beforeEach(() => jest.clearAllMocks())

    test('Do nothing policy exists', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new DevOpsCommand(logger);
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
        var command = new DevOpsCommand(logger);
        let mockAADCommand = mock<AADCommand>()
        command.createAADCommand= () => mockAADCommand
        let args = new DevOpsInstallArguments();
        let mockDevOpsWebApi = mock<azdev.WebApi>(); 
        let mockTaskApi = mock<ITaskAgentApi>();
        let mockBuildApi = mock<IBuildApi>();

        args.projectName = 'DevOpsProject'
        args.repositoryName = 'alm-sandbox'
        args.createSecretIfNoExist = true

        mockDevOpsWebApi.getTaskAgentApi.mockResolvedValue(mockTaskApi)
        mockDevOpsWebApi.getBuildApi.mockResolvedValue(mockBuildApi)

        mockTaskApi.getVariableGroups.mockResolvedValue([])
        mockBuildApi.getDefinitions.mockResolvedValue([<BuildDefinitionReference>{id:1, name: "export-solution-to-git"}])

        mockAADCommand.addSecret.mockResolvedValue(<AADAppSecret>{clientId:'C1', clientSecret:'S1', tenantId:'T1'})
        
        // Act
        await command.createAdvancedMakersBuildVariables(args, mockDevOpsWebApi)

        // Assert
        expect(mockAADCommand.addSecret).toBeCalledTimes(1)
    })
});