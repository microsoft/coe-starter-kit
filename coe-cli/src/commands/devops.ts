"use strict";
import * as azdev from "azure-devops-node-api"
import { IHeaders, IRequestHandler } from "azure-devops-node-api/interfaces/common/VsoBaseInterfaces";
import util from "util"
import * as CoreInterfaces from 'azure-devops-node-api/interfaces/CoreInterfaces';
import { GitVersionDescriptor, GitVersionType, GitRefUpdate, GitCommitRef, GitPush, GitChange, VersionControlChangeType, GitItem, ItemContentType, GitRef, GitImportRequest, GitRepositoryCreateOptions, GitImportRequestParameters, GitImportGitSource, GitAsyncOperationStatus, VersionControlRecursionType } from 'azure-devops-node-api/interfaces/GitInterfaces';
import * as gitm from "azure-devops-node-api/GitApi"
import * as BuildInterfaces from 'azure-devops-node-api/interfaces/BuildInterfaces';
import { GitHubCommand } from './github';

import axios from 'axios';
import open = require('open');
import { GitRepository, ItemContent } from "azure-devops-node-api/interfaces/TfvcInterfaces";
import { IBuildApi } from "azure-devops-node-api/BuildApi";
import { PolicyConfiguration } from "azure-devops-node-api/interfaces/PolicyInterfaces";

import { execSync, ExecSyncOptionsWithStringEncoding } from 'child_process';
import path = require('path');
import * as fs from 'fs';
import { FileHandle } from 'fs/promises';
import httpm = require('typed-rest-client/HttpClient');

import { AADAppInstallArguments, AADCommand } from "./aad";
import { EndpointAuthorization, ServiceEndpoint, TaskAgentQueue, VariableGroupParameters } from "azure-devops-node-api/interfaces/TaskAgentInterfaces";
import { ProjectReference, VariableGroupProjectReference, VariableValue } from "azure-devops-node-api/interfaces/ReleaseInterfaces";

import * as winston from 'winston';
import { Environment } from "../common/environment";
import { Prompt } from "../common/prompt";
import { InstalledExtension } from "azure-devops-node-api/interfaces/ExtensionManagementInterfaces";

import url from 'url';
import { RoleAssignment } from "azure-devops-node-api/interfaces/SecurityRolesInterfaces";

const { spawnSync } = require("child_process");
/**
* Azure DevOps Commands
*/
class DevOpsCommand {
    createWebApi: (orgUrl: string, authHandler: IRequestHandler) => azdev.WebApi
    createAADCommand: () => AADCommand
    runCommand: (command: string, displayOutput: boolean) => string
    deleteIfExists: (name: string, type: string) => Promise<void>
    writeFile: (name: string, data: Buffer) => Promise<void>
    prompt: Prompt
    getHttpClient: (connection: azdev.WebApi) => httpm.HttpClient
    logger: winston.Logger
    readFile: (path: fs.PathLike | FileHandle, options: { encoding: BufferEncoding, flag?: fs.OpenMode } | BufferEncoding) => Promise<string>
    createGitHubCommand: () => GitHubCommand
    getUrl: (url: string, config: any) => Promise<string>

    constructor(logger: winston.Logger, defaultFs: any = null) {
        this.logger = logger
        this.createWebApi = (orgUrl: string, authHandler: IRequestHandler) => new azdev.WebApi(orgUrl, authHandler)
        this.createAADCommand = () => new AADCommand(this.logger)
        this.createGitHubCommand = () => new GitHubCommand(this.logger)
        this.deleteIfExists = async (name: string, type: string) => {
            if (fs.existsSync(name)) {
                if (type == "file")
                    await fs.promises.unlink(name)
                else if (type == "directory") {
                    await fs.promises.rm(name, { recursive: true })
                }
            }
        }
        this.writeFile = async (name: string, data: Buffer) => fs.promises.writeFile(name, data, 'binary')
        this.getUrl = async (url: string, config: any = null) => {
            if (config == null) {
                return (await (axios.get<string>(url))).data
            }
            else {
                return (await (axios.get<string>(url, config))).data
            }
        }
        this.runCommand = (command: string, displayOutput: boolean) => {
            if (displayOutput) {
                return execSync(command, <ExecSyncOptionsWithStringEncoding>{ stdio: 'inherit', encoding: 'utf8' })
            } else {
                return execSync(command, <ExecSyncOptionsWithStringEncoding>{ encoding: 'utf8' })
            }
        }
        this.prompt = new Prompt()
        this.getHttpClient = (connection: azdev.WebApi) => connection.rest.client
        if (defaultFs == null) {
            this.readFile = fs.promises.readFile
        } else {
            this.readFile = defaultFs.readFile
        }
    }

    /**
     * 
     * @param args Install components required to run ALM using Azure CLI commands
     * @returns 
     */
    async install(args: DevOpsInstallArguments): Promise<void> {
        let extensions = path.join(__dirname, '..', '..', '..', 'config', 'AzureDevOpsExtensionsDetails.json')

        let orgUrl = Environment.getDevOpsOrgUrl(args)

        if (args.extensions.length == 0) {
            this.logger?.info('Loading DevOps Extensions Configuration')
            let extensionConfig = JSON.parse(await this.readFile(extensions, 'utf-8'))
            for (let i = 0; i < extensionConfig.length; i++) {
                args.extensions.push(<DevOpsExtension>{
                    name: extensionConfig[i].extensionId,
                    publisher: extensionConfig[i].publisherId
                })
            }
        }

        let authHandler: IRequestHandler = azdev.getHandlerFromToken(typeof args.accessTokens["499b84ac-1321-427f-aa17-267ca6975798"] !== "undefined" ? args.accessTokens["499b84ac-1321-427f-aa17-267ca6975798"] : args.accessToken);
        let connection = this.createWebApi(orgUrl, authHandler);

        await this.installExtensions(args, connection)

        let repo = await this.importPipelineRepository(args, connection)

        if (repo !== null) {
            await this.createMakersBuildPipelines(args, connection, repo)

            let securityContext = await this.setupSecurity(args, connection)

            await this.createMakersBuildVariables(args, connection, securityContext)

            await this.createMakersServiceConnections(args, connection)
        }
    }

    async setupSecurity(args: DevOpsInstallArguments, connection: azdev.WebApi): Promise<DevOpsProjectSecurityContext> {
        let context: DevOpsProjectSecurityContext = <DevOpsProjectSecurityContext>{}
        let coreApi = await connection.getCoreApi();

        //let projects = await coreApi.getProjects()
        let projects = await coreApi.getProjects(undefined, 300, undefined, undefined, undefined)
        
        let project = projects.filter(p => p.name?.toLowerCase() == args.projectName?.toLowerCase())

        if (project.length != 1) {
            return Promise.resolve(context)
        }
        let client = this.getHttpClient(connection)
        let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args)

        context.projectId = project[0].id
        context.securityUrl = devOpsOrgUrl.replace("https://dev", "https://vssps.dev")

        this.logger?.debug(`Getting descriptor for project ${project[0].id}`)

        // https://docs.microsoft.com/rest/api/azure/devops/graph/Descriptors/Get?view=azure-devops-rest-6.0
        context.projectDescriptor = await this.getSecurityDescriptor(client, context.securityUrl, project[0].id)

        let headers = <IHeaders>{};
        headers["Content-Type"] = "application/json"

        this.logger?.debug(`Getting groups for project ${args.projectName} (${context.projectDescriptor})`)

        // Get groups for the project
        // https://docs.microsoft.com/rest/api/azure/devops/graph/groups/list?view=azure-devops-rest-6.0
        let query = await client.get(`${context.securityUrl}_apis/Graph/Groups?scopeDescriptor=${context.projectDescriptor}&api-version=6.0-preview.1`)
        let groupJson = await query.readBody()
        let groups = JSON.parse(groupJson)

        let groupMatch = groups.value.filter((g: GraphGroup) => g.displayName == "ALM Accelerator for Makers")
        let almGroup: GraphGroup;
        if (groupMatch.length == 0) {
            let newGroup = {
                "displayName": "ALM Accelerator for Makers",
                "description": "Members of this group will be able to access resources required for operation of the ALM Accelerator for Makers",
                "storageKey": "",
                "crossProject": false,
                "descriptor": "",
                "restrictedVisibility": false,
                "specialGroupType": "Generic"
            }
            this.logger?.info(`Creating new Group ${newGroup.displayName}`)
            let create = await client.post(`${context.securityUrl}_apis/graph/groups?scopeDescriptor=${context.projectDescriptor}&api-version=6.0-preview.1`, JSON.stringify(newGroup), headers)
            let createdJson = await create.readBody()
            almGroup = JSON.parse(createdJson)
        } else {
            almGroup = groupMatch[0]
        }

        context.almGroup = almGroup

        let makerAADGroup = await this.getSecurityAADUserGroup(client, context.securityUrl, args.azureActiveDirectoryMakersGroup, almGroup.descriptor)

        if (makerAADGroup != null) {
            this.logger?.debug(`Getting members for ALM Accelerator for Makers (${almGroup.originId})`)

            let members = await this.getGroupMembers(client, context.securityUrl, almGroup.descriptor)

            let match = members?.value?.filter((m: GraphMembership) => m.memberDescriptor == makerAADGroup)

            if (match?.length == 1) {
                this.logger?.info("Group already a member of group")
            } else {
                this.logger?.info("Adding member to group")
                let update = await client.put(`${context.securityUrl}_apis/Graph/Memberships/${makerAADGroup}/${almGroup.descriptor}?api-version=5.2-preview.1`, "", headers)
                let updateData = await update.readBody()
                this.logger?.debug(updateData)
            }
        }

        return context;
    }

    async getSecurityAADUserGroup(client: httpm.HttpClient, url: string, name: string, groupDescriptor: string): Promise<string> {
        let headers = <IHeaders>{};
        headers["Content-Type"] = "application/json"
        let request = {
            "query": name,
            "identityTypes": ["user", "group"],
            "operationScopes": ["ims", "source"],
            "options": { "MinResults": 5, "MaxResults": 20 },
            "properties": ["DisplayName", "SubjectDescriptor"]
        }
        let descriptor = await client.post(`${url}_apis/IdentityPicker/Identities?api-version=6.0-preview.1`, JSON.stringify(request), headers)
        let descriptorJson = await descriptor.readBody()
        let descriptorInfo = JSON.parse(descriptorJson)

        let aadGroupFilter = (i: any) => i.displayName == name && i.entityType == "Group" && i.originDirectory == 'aad'
        let devOpsAADGroupFilter = (i: any) => i.displayName == `[TEAM FOUNDATION]\\${name}` && i.entityType == "Group" && i.originDirectory == 'aad'

        let match = descriptorInfo.results?.filter((r: any) => r.identities?.filter((i: any) => aadGroupFilter(i) || devOpsAADGroupFilter(i)).length == 1)

        if (match.length == 1) {
            let identityMatch = match[0].identities?.filter((i: any) => aadGroupFilter(i) || devOpsAADGroupFilter(i))[0]
            if (identityMatch.subjectDescriptor == null) {
                this.logger?.info(`Adding Azure Active Directory Group (${identityMatch.originId}) to DevOps`)
                let addToDevOps = await client.post(`${url}_apis/Graph/Groups?groupDescriptors=${groupDescriptor}&api-version=5.2-preview.1`, JSON.stringify({ "originId": identityMatch.originId, "storageKey": "" }), headers)
                let resultJson = await addToDevOps.readBody()
                let addToDevOpsResult = JSON.parse(resultJson)
                return addToDevOpsResult.descriptor
            } else {
                return identityMatch.subjectDescriptor
            }
        }

        if (match.length == 0) {
            this.logger.info(`No match found for Azure Active Directory Group ${name}`)
            return null
        }

        this.logger.info(`Multiple matches Azure Active Directory Group ${name}`)

        for (let i = 0; i < descriptorInfo?.results?.identities?.length; i++) {
            this.logger.info(descriptorInfo?.results?.identities[i].displayName)
        }

        return null
    }

    async getSecurityAADUserGroupReference(client: httpm.HttpClient, url: string, name: string, groupDescriptor: string): Promise<string> {
        let headers = <IHeaders>{};
        headers["Content-Type"] = "application/json"
        let request = {
            "query": name,
            "identityTypes": ["user", "group"],
            "operationScopes": ["ims", "source"],
            "options": { "MinResults": 5, "MaxResults": 20 },
            "properties": ["DisplayName", "SubjectDescriptor"]
        }
        let descriptor = await client.post(`${url}_apis/IdentityPicker/Identities?api-version=6.0-preview.1`, JSON.stringify(request), headers)
        let descriptorJson = await descriptor.readBody()
        let descriptorInfo = JSON.parse(descriptorJson)

        let aadGroupFilter = (i: any) => i.displayName == name && i.entityType == "Group" && i.originDirectory == 'aad'
        let devOpsAADGroupFilter = (i: any) => i.displayName == `[TEAM FOUNDATION]\\${name}` && i.entityType == "Group" && i.originDirectory == 'aad'

        let match = descriptorInfo.results?.filter((r: any) => r.identities?.filter((i: any) => aadGroupFilter(i) || devOpsAADGroupFilter(i)).length == 1)
        if (match.length == 1) {
            let identityMatch = match[0].identities?.filter((i: any) => aadGroupFilter(i) || devOpsAADGroupFilter(i))[0]
            if (identityMatch.subjectDescriptor == null) {
                this.logger?.info(`Adding Azure Active Directory Group (${identityMatch.originId}) to DevOps`)
                let addToDevOps = await client.post(`${url}_apis/Graph/Groups?groupDescriptors=${groupDescriptor}&api-version=5.2-preview.1`, JSON.stringify({ "originId": identityMatch.originId, "storageKey": "" }), headers)
                let resultJson = await addToDevOps.readBody()
                let addToDevOpsResult = JSON.parse(resultJson)
                return addToDevOpsResult.descriptor
            } else {
                return identityMatch.subjectDescriptor
            }
        }

        if (match.length == 0) {
            this.logger.info(`No match found for Azure Active Directory Group ${name}`)
            return null
        }

        this.logger.info(`Multiple matches Azure Active Directory Group ${name}`)

        for (let i = 0; i < descriptorInfo?.results?.identities?.length; i++) {
            this.logger.info(descriptorInfo?.results?.identities[i].displayName)
        }

        return null
    }

    async getSecurityDescriptor(client: httpm.HttpClient, url: string, id: string): Promise<string> {
        let descriptor = await client.get(`${url}_apis/graph/descriptors/${id}?api-version=6.0-preview.1`)
        let descriptorJson = await descriptor.readBody()
        let descriptorInfo = JSON.parse(descriptorJson)
        return descriptorInfo.value
    }

    async getGroupMembers(client: httpm.HttpClient, url: string, id: string): Promise<MembershipResponse> {
        // https://docs.microsoft.com/rest/api/azure/devops/graph/memberships/list?view=azure-devops-rest-6.0
        let results = await client.get(`${url}_apis/graph/Memberships/${id}?direction=Down&api-version=6.0-preview.1`)
        let resultsJson = await results.readBody()
        return JSON.parse(resultsJson)
    }

    async installExtensions(args: DevOpsInstallArguments, connection: azdev.WebApi): Promise<void> {
        if (args.extensions.length == 0) {
            return Promise.resolve()
        }

        this.logger.info(`Checking DevOps Extensions`)

        let extensionsApi = await connection.getExtensionManagementApi()

        this.logger.info(`Retrieving Extensions`)
        try {
            let extensions = await extensionsApi.getInstalledExtensions()
            for (let i = 0; i < args.extensions.length; i++) {
                let extension = args.extensions[i]

                let match = extensions.filter((e: InstalledExtension) => e.extensionId == extension.name && e.publisherId == extension.publisher)
                if (match.length == 0) {
                    this.logger.info(`Installing ${extension.name} by ${extension.publisher}`)
                    await extensionsApi.installExtensionByName(extension.publisher, extension.name)
                } else {
                    this.logger.info(`Extension ${extension.name} by ${extension.publisher} installed`)
                }
            }
        } catch (err) {
            this.logger?.error(err)
            throw err
        }

    }

    async importPipelineRepository(args: DevOpsInstallArguments, connection: azdev.WebApi) {

        let gitApi = await connection.getGitApi()
        let pipelineProjectName = (typeof args.pipelineProjectName !== "undefined" && args.pipelineProjectName?.length > 0) ? args.pipelineProjectName : args.projectName
        this.logger.info(`Checking pipeline repository ${pipelineProjectName} ${args.pipelineRepositoryName}`)
        let repo = await this.getRepository(args, gitApi, pipelineProjectName, args.pipelineRepositoryName)

        if (repo == null) {
            return Promise.resolve(null)
        }

        let command = `./src/powershell/importpipelinerepo.ps1 "${args.organizationName}" "${pipelineProjectName}" "${args.pipelineRepositoryName}" "${args.accessTokens["499b84ac-1321-427f-aa17-267ca6975798"]}"`

        const child = spawnSync('pwsh', ["-File", command], {
            shell: true,
            stdio: ['pipe', 'pipe', 'pipe'],
            ...{},
        });

        this.logger.info(`Output: ${child.stdout.toString()}`);
        if (child.statusCode != 0) {
            this.logger.info(`Error message: ${child.stderr.toString()}`);
        }

        this.logger?.debug('Setting default branch')
        let headers = <IHeaders>{};
        headers["Content-Type"] = "application/json"

        let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args)
        await this.getHttpClient(connection).patch(`${devOpsOrgUrl}${args.projectName}/_apis/git/repositories/${repo.id}?api-version=6.0`, '{"defaultBranch":"refs/heads/main"}', headers)
        this.logger.info(`Pipeline repository ${pipelineProjectName} ${args.pipelineRepositoryName} imported`)

        return repo;
    }

    private async getRepository(args: DevOpsInstallArguments, gitApi: gitm.IGitApi, projectName: string, repositoryName: string): Promise<GitRepository> {
        let repos = await gitApi.getRepositories(projectName);

        if (repos == null) {
            this.logger?.error(`${projectName} not found`)
            return Promise.resolve(null)
        }

        if (repos?.filter(r => r.name == repositoryName).length == 0) {
            this.logger?.info(`Creating repository ${repositoryName}`)
            return await gitApi.createRepository(<GitRepositoryCreateOptions>{ name: repositoryName }, projectName)
        } else {
            this.logger?.info(`Found repository ${repositoryName}`)
            return repos.filter(r => r.name == repositoryName)[0]
        }
    }

    sleep(ms: number) {
        return new Promise(resolve => setTimeout(resolve, ms))
    }

    /**
     * Create Build pipelines required by the ALM Accelerator
     * @param args The installation parameters
     * @param connection The authenticated connection
     * @param repo The pipeline repo to a create builds for
     */
    async createMakersBuildPipelines(args: DevOpsInstallArguments, connection: azdev.WebApi, repo: GitRepository): Promise<GitRepository> {
        let pipelineProjectName = (typeof args.pipelineProjectName !== "undefined" && args.pipelineProjectName?.length > 0) ? args.pipelineProjectName : args.projectName
        connection = await this.createConnectionIfExists(args, connection)

        if (repo == null) {
            let gitApi = await connection.getGitApi()
            repo = await this.getRepository(args, gitApi, pipelineProjectName, args.repositoryName)
        }

        let buildApi = await connection.getBuildApi();

        if (typeof buildApi == "undefined") {
            this.logger?.info("Build API missing")
            return
        }

        let taskApi = await connection.getTaskAgentApi()
        let core = await connection.getCoreApi()
        let project: CoreInterfaces.TeamProject = await core.getProject(pipelineProjectName)

        if (typeof project !== "undefined") {
            this.logger?.info(util.format("Found project %s", project.name))

            this.logger?.info(`Retrieving default Queue`)
            let defaultQueue = (await taskApi?.getAgentQueues(pipelineProjectName))?.filter(p => p.name == "Azure Pipelines")

            let defaultAgentQueue = defaultQueue?.length > 0 ? defaultQueue[0] : undefined
            this.logger?.info(`Default Queue: ${defaultQueue?.length > 0 ? defaultQueue[0].name : "undefined"}`)

            let builds = await buildApi.getDefinitions(pipelineProjectName)

            let buildNames = ['export-solution-to-git', 'import-unmanaged-to-dev-environment', 'delete-unmanaged-solution-and-components']

            for (var i = 0; i < buildNames.length; i++) {
                let filteredBuilds = builds.filter(b => b.name == buildNames[i])

                if (filteredBuilds.length == 0) {
                    this.logger?.debug(`Creating build ${buildNames[i]}`)
                    await this.createBuild(buildApi, repo, buildNames[i], `/Pipelines/${buildNames[i]}.yml`, defaultAgentQueue)
                } else {
                    let build = await buildApi.getDefinition(pipelineProjectName, filteredBuilds[0].id)
                    let changes = false

                    if (typeof build.queue === "undefined") {
                        this.logger?.debug(`Missing build queue for ${build.name}`)
                        build.queue = defaultAgentQueue
                        changes = true
                    }

                    if (changes) {
                        this.logger?.debug(`Updating ${build.name}`)
                        await buildApi.updateDefinition(build, pipelineProjectName, filteredBuilds[0].id)
                    } else {
                        this.logger?.debug(`No changes to ${buildNames[i]}`)
                    }
                }
            }
        }
    }

    async createMakersBuildVariables(args: DevOpsInstallArguments, connection: azdev.WebApi, securityContext: DevOpsProjectSecurityContext) {
        let projects = [args.projectName]
        if (typeof args.pipelineProjectName !== "undefined" && args.pipelineProjectName?.length > 0) {
            projects.push(args.pipelineProjectName)
        }

        for (let i = 0; i < projects.length; i++) {
            connection = await this.createConnectionIfExists(args, connection)

            let taskApi = await connection.getTaskAgentApi()

            let groups = await taskApi?.getVariableGroups(projects[i]);

            let variableGroupName = "alm-accelerator-variable-group"
            let global = groups?.filter(g => g.name == variableGroupName)
            let variableGroup = global?.length == 1 ? global[0] : null
            if (global?.length == 0) {
                let aadCommand = this.createAADCommand()

                let aadArgs = new AADAppInstallArguments()
                aadArgs.subscription = args.subscription
                aadArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
                aadArgs.createSecret = args.createSecretIfNoExist
                aadArgs.accessTokens = args.accessTokens
                aadArgs.endpoint = args.endpoint
                aadArgs.settings = args.settings

                let secretInfo = await aadCommand.addSecret(aadArgs, "CoE-ALM")

                let aadHost = Environment.getAzureADAuthEndpoint(aadArgs.settings).replace("https://", "")
                if (!aadArgs.createSecret) {
                    this.logger?.warn('Client secret not added for variable group alm-accelerator-variable-group it wil need to be added manually')
                }

                let buildApi = await connection.getBuildApi();
                let builds = await buildApi.getDefinitions(projects[i])
                let exportBuild = builds.filter(b => b.name == "export-solution-to-git")
                let buildId = exportBuild.length == 1 ? exportBuild[0].id.toString() : ""

                let parameters = <VariableGroupParameters>{}
                parameters.variableGroupProjectReferences = [
                    <VariableGroupProjectReference>{
                        name: variableGroupName,
                        projectReference: <ProjectReference>{
                            name: projects[i],
                        }
                    }]
                parameters.name = variableGroupName
                parameters.description = 'ALM Accelerator for Power Platform'

                parameters.variables = {
                    "AADHost": <VariableValue>{
                        value: aadHost
                    },
                    "CdsBaseConnectionString": <VariableValue>{
                        value: "AuthType=ClientSecret;ClientId=$(ClientId);ClientSecret=$(ClientSecret);Url="
                    },
                    "ClientId": <VariableValue>{
                        value: secretInfo.clientId
                    },
                    "ClientSecret": <VariableValue>{
                        isSecret: true,
                        value: secretInfo.clientSecret
                    },
                    "TenantID": <VariableValue>{
                        value: secretInfo.tenantId
                    }
                }

                this.logger?.info(`Creating variable group ${variableGroupName}`)
                variableGroup = await taskApi.addVariableGroup(parameters)
            }

            this.logger?.debug("Searching for existing role assignements")

            let variableGroupId = `${securityContext.projectId}%24${variableGroup.id}`

            let client = this.getHttpClient(connection)
            let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args)

            let variableGroupUrl = `${devOpsOrgUrl}_apis/securityroles/scopes/distributedtask.variablegroup/roleassignments/resources/${variableGroupId}?api-version=6.1-preview.1`
            let roleRequest = await client.get(variableGroupUrl)
            let roleJson = await roleRequest.readBody()
            let roleAssignmentsResponse = JSON.parse(roleJson)

            let roleAssignments = <RoleAssignment[]>roleAssignmentsResponse.value

            if (roleAssignments.filter((r: RoleAssignment) => r.identity.id == securityContext.almGroup.originId).length == 0) {
                this.logger?.debug(`Adding User role for Group ${securityContext.almGroup.displayName}`)

                let headers = <IHeaders>{};
                headers["Content-Type"] = "application/json"

                let updateRequest = await client.put(variableGroupUrl, JSON.stringify([{ "roleName": "User", "userId": securityContext.almGroup.originId }]), headers)
                let newRoleAssignmentJson = await updateRequest.readBody();
                let newRoleAssignmentResult = JSON.parse(newRoleAssignmentJson)

                if (newRoleAssignmentResult.value?.length == 1) {
                    let newRoleAssignment = <RoleAssignment>newRoleAssignmentResult.value[0]
                    this.logger?.info(`Added new role assignnment ${newRoleAssignment.identity.displayName} for variable group ${variableGroupName}`)
                } else {
                    this.logger?.error(`Role for ${securityContext.almGroup.displayName} not assigned to ${variableGroupName}`)
                }
            }
        }
    }

    async createMakersServiceConnections(args: DevOpsInstallArguments, connection: azdev.WebApi, setupEnvironmentConnections: boolean = true) {
        let projectNames = [args.projectName]
        if (typeof args.pipelineProjectName !== "undefined" && args.pipelineProjectName != args.projectName) {
            projectNames.push(args.pipelineProjectName)
        }
        for (let projectIndex = 0; projectIndex < projectNames.length; projectIndex++) {
            connection = await this.createConnectionIfExists(args, connection)

            let endpoints = await this.getServiceConnections(args, connection)
            let coreApi = await connection.getCoreApi();

            //let projects = await coreApi.getProjects()
            let projects = await coreApi.getProjects(undefined, 300, undefined, undefined, undefined)
            let project = projects.filter(p => p.name?.toLowerCase() == projectNames[projectIndex].toLowerCase())

            if (project.length == 0) {
                this.logger?.error(`Azure DevOps project ${projectNames[projectIndex]} not found`)
                return Promise.resolve();
            }

            let aadCommand = this.createAADCommand()
            let aadArgs = new AADAppInstallArguments()
            aadArgs.subscription = args.subscription
            aadArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
            aadArgs.createSecret = args.createSecretIfNoExist
            aadArgs.accessTokens = args.accessTokens
            aadArgs.endpoint = args.endpoint

            let keys = Object.keys(args.environments)

            let environments: string[] = []

            if (args.environment?.length > 0) {
                environments.push(args.environment)
            }

            let mapping: { [id: string]: string } = {}

            if (setupEnvironmentConnections) {
                for (var i = 0; i < keys.length; i++) {
                    let environmentName = args.environments[keys[i]]
                    mapping[environmentName] = keys[i]
                    if (environments.filter((e: string) => e == environmentName).length == 0) {
                        environments.push(environmentName)
                    }
                }

                if (Array.isArray(args.settings["installEnvironments"])) {
                    for (var i = 0; i < args.settings["installEnvironments"].length; i++) {
                        let environmentName = args.settings["installEnvironments"][i]
                        if (typeof args.settings[environmentName] === "string" && environments.filter((e: string) => e == args.settings[environmentName]).length == 0) {
                            environments.push(args.settings[environmentName])
                        }
                    }
                }
            }

            for (var i = 0; i < environments.length; i++) {
                let environmentName = environments[i]
                let endpointUrl = Environment.getEnvironmentUrl(environmentName, args.settings)

                let secretName = environmentName
                try {
                    let environmentUrl = new url.URL(secretName)
                    secretName = environmentUrl.hostname.split(".")[0]
                } catch {

                }

                let secretInfo = await aadCommand.addSecret(aadArgs, secretName)

                if (endpoints.filter(e => e.name == endpointUrl).length == 0) {
                    let ep = <ServiceEndpoint>{
                        authorization: <EndpointAuthorization>{
                            parameters: {
                                tenantId: secretInfo.tenantId,
                                clientSecret: secretInfo.clientSecret,
                                applicationId: secretInfo.clientId
                            },
                            scheme: "None"
                        },
                        name: endpointUrl,
                        type: "powerplatform-spn",
                        url: endpointUrl,
                        description: typeof mapping[environmentName] !== "undefined" ? `Environment ${mapping[environmentName]}` : '',
                        serviceEndpointProjectReferences: [
                            {
                                projectReference: <ProjectReference>{
                                    id: project[0].id,
                                    name: projectNames[projectIndex]
                                },
                                name: endpointUrl
                            }
                        ]
                    }

                    let headers = <IHeaders>{};
                    headers["Content-Type"] = "application/json"
                    let webClient = this.getHttpClient(connection);

                    let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args)

                    // https://docs.microsoft.com/rest/api/azure/devops/serviceendpoint/endpoints/create?view=azure-devops-rest-6.0
                    let create = await webClient.post(`${devOpsOrgUrl}${projectNames[projectIndex]}/_apis/serviceendpoint/endpoints?api-version=6.0-preview.4`, JSON.stringify(ep), headers)

                    let serviceConnection: any
                    serviceConnection = JSON.parse(await create.readBody())
                    if (create.message.statusCode != 200) {
                        return Promise.resolve()
                    } else {
                        this.logger?.info(`Created service connection ${endpointUrl}`)
                    }

                    await this.assignUserToServiceConnector(project[0], serviceConnection, args, connection)
                } else {
                    await this.assignUserToServiceConnector(project[0], endpointUrl, args, connection)
                }
            }
        }
    }

    async assignUserToServiceConnector(project: CoreInterfaces.TeamProjectReference, endpoint: ServiceConnectorReference, args: DevOpsInstallArguments, connection: azdev.WebApi) {
        if (args.user?.length > 0) {

            let webClient = this.getHttpClient(connection);
            let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args)

            if (typeof endpoint === "string") {
                let results = await webClient.get(`${devOpsOrgUrl}${project.name}/_apis/serviceendpoint/endpoints?api-version=6.0-preview.4`);
                let endpointJson = await results.readBody()
                this.logger?.debug(endpointJson)
                let endpoints = <any[]>(JSON.parse(endpointJson).value)
                this.logger?.debug(endpoints)

                let endPointMatch = endpoints.filter((ep: any) => ep.url == endpoint)

                if (endPointMatch.length == 1) {
                    endpoint = endPointMatch[0]
                } else {
                    this.logger.error(`Unable to find service connection ${endpoint}`)
                    return Promise.resolve()
                }
            }

            let userId = await this.getUserId(devOpsOrgUrl, args.user, connection)
            if (userId == null) {
                this.logger?.info("No user found -- Exiting")
                return Promise.resolve()
            } else {
                this.logger?.info(`Found user ${userId}`)
            }

            let connectorRoles = await webClient.get(`${devOpsOrgUrl}_apis/securityroles/scopes/distributedtask.serviceendpointrole/roleassignments/resources/${project.id}_${endpoint.id}`)
            let connectorData = JSON.parse(await connectorRoles.readBody())

            let connectorMatch = connectorData.value?.filter((c: any) => c.identity.id == userId)

            if (connectorMatch?.length == 0) {
                let headers = <IHeaders>{};
                headers["Content-Type"] = "application/json"

                let newRole = [{
                    "roleName": "User",
                    "userId": userId
                }]

                //https://docs.microsoft.com/rest/api/azure/devops/securityroles/roleassignments/set%20role%20assignments?view=azure-devops-rest-6.1
                this.logger?.info(`Assigning user ${args.user} to service connection ${endpoint.url}`)
                let update = await webClient.put(`${devOpsOrgUrl}_apis/securityroles/scopes/distributedtask.serviceendpointrole/roleassignments/resources/${project.id}_${endpoint.id}?api-version=6.1-preview.1`, JSON.stringify(newRole), headers)

                if (update.message.statusCode != 200) {
                    this.logger?.info("Update failed")
                    this.logger?.error(await update.readBody())
                } else {
                    this.logger?.info('User role assigned')
                    let results = await update.readBody()
                    this.logger?.debug(results)
                }
            } else {
                this.logger?.info("User role already assigned")
            }
        }
    }

    async getUserId(devOpsOrgUrl: string, user: string, connection: azdev.WebApi) {
        let client = this.getHttpClient(connection)

        // https://docs.microsoft.com/rest/api/azure/devops/ims/identities/read%20identities?view=azure-devops-rest-6.0#by-email
        let query = await client.get(`${devOpsOrgUrl.replace("https://dev", "https://vssps.dev")}_apis/identities?searchFilter=General&filterValue=${user}&queryMembership=None&api-version=6.0`)
        let identityJson = await query.readBody()
        let users = JSON.parse(identityJson)
        this.logger?.debug(`Found ${users.value?.length} user(s)`)
        this.logger?.verbose(users)

        this.logger?.debug(`Searching for ${user}`)
        let userMatch = users.value?.filter((u: any) => u.properties?.Account['$value']?.toLowerCase() == user?.toLowerCase())

        if (userMatch?.length == 1) {
            this.logger?.debug(`Found user ${userMatch[0].id}`)
            return userMatch[0].id
        }

        if (userMatch?.length == 0) {
            this.logger?.error(`Unable to find ${user} in ${devOpsOrgUrl}, has the used been added?`)
            return null
        }

        if (userMatch?.length > 1) {
            this.logger?.error(`More than one match for ${user} in ${devOpsOrgUrl}`)
            return null
        }

    }

    /**
     * Retrieve array of current service connections
     * @param connection The authenticated connection
     * @returns 
     */
    async getServiceConnections(args: DevOpsInstallArguments, connection: azdev.WebApi): Promise<ServiceEndpoint[]> {
        let pipelineProjectName = (typeof args.pipelineProjectName !== "undefined" && args.pipelineProjectName?.length > 0) ? args.pipelineProjectName : args.projectName
        let webClient = this.getHttpClient(connection);
        let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args, args.settings)
        let request = await webClient.get(`${devOpsOrgUrl}${pipelineProjectName}/_apis/serviceendpoint/endpoints?api-version=6.0-preview.4`)
        let data = await request.readBody()
        this.logger?.debug(data)
        return <ServiceEndpoint[]>(JSON.parse(data).value)
    }

    private async createConnectionIfExists(args: DevOpsInstallArguments, connection: azdev.WebApi): Promise<azdev.WebApi> {
        if (connection == null) {
            let authHandler = azdev.getHandlerFromToken(args.accessToken?.length > 0 ? args.accessToken : args.accessTokens["499b84ac-1321-427f-aa17-267ca6975798"], true);
            let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args, args.settings)
            return this.createWebApi(devOpsOrgUrl, authHandler);
        }
        return connection
    }

    async createBuild(buildApi: IBuildApi, repo: GitRepository, name: string, yamlFilename: string, defaultQueue: TaskAgentQueue): Promise<BuildInterfaces.BuildDefinition> {
        let newBuild = <BuildInterfaces.BuildDefinition>{};
        newBuild.name = name
        newBuild.repository = <BuildInterfaces.BuildRepository>{}
        newBuild.repository.defaultBranch = "refs/heads/main"
        newBuild.repository.id = repo.id
        newBuild.repository.name = repo.name
        newBuild.repository.url = repo.url
        newBuild.repository.type = 'TfsGit'
        let process = <BuildInterfaces.YamlProcess>{};
        process.yamlFilename = yamlFilename
        newBuild.process = process
        newBuild.queue = defaultQueue

        let trigger = <BuildInterfaces.ContinuousIntegrationTrigger>{}
        trigger.triggerType = BuildInterfaces.DefinitionTriggerType.ContinuousIntegration
        trigger.branchFilters = []
        trigger.pathFilters = []
        trigger.maxConcurrentBuildsPerBranch = 1
        trigger.batchChanges = false
        trigger.settingsSourceType = BuildInterfaces.DefinitionTriggerType.ContinuousIntegration
        newBuild.triggers = <BuildInterfaces.ContinuousIntegrationTrigger[]>[trigger]

        return buildApi.createDefinition(newBuild, repo.project.name)
    }


    /**
     * Create new branch in Azure DevOps repository
     *
     * @param args {DevOpsBranchArguments} - The branch request
     * @return {Promise} aync outcome
     *
     */
    async branch(args: DevOpsBranchArguments): Promise<void> {
        try {
            this.logger?.info(`Pipeline Project: ${args.pipelineProject}`)
            let pipelineProjectName = args.pipelineProject?.length > 0 ? args.pipelineProject : args.projectName
            let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args, args.settings)
            let authHandler = azdev.getHandlerFromToken(args.accessToken);
            let connection = this.createWebApi(devOpsOrgUrl, authHandler);

            let core = await connection.getCoreApi()
            this.logger?.info(`Getting Project`)
            let project: CoreInterfaces.TeamProject = await core.getProject(args.projectName)
            this.logger?.info(`Getting Pipeline Project`)
            let pipelineProject: CoreInterfaces.TeamProject = await core.getProject(pipelineProjectName)

            this.logger?.info(util.format("Found project %s %s", project?.name, args.projectName))
            this.logger?.info(util.format("Found pipeline project %s %s", pipelineProject?.name, pipelineProjectName))
            if (typeof project !== "undefined" && typeof pipelineProject !== "undefined") {

                let gitApi = await connection.getGitApi()

                let repo = await this.createBranch(args, pipelineProject, project, gitApi);

                if (repo != null) {
                    await this.createBuildForBranch(args, project, repo, connection);
                    await this.setBranchPolicy(args, repo, connection);
                }
            }
        }
        catch (error) {
            this.logger?.info(`An error occurred while creating the branch: ${error}`)
            throw error
        }
    }

    /**
     * Create branch in Azure Devops Repo
     * @param args - The branch arguments
     * @param project Th project to create the project in
     * @param gitApi The open git API connection to create the 
     * @returns 
     */
    async createBranch(args: DevOpsBranchArguments, pipelineProject: CoreInterfaces.TeamProject, project: CoreInterfaces.TeamProject, gitApi: gitm.IGitApi): Promise<GitRepository> {
        var pipelineRepos = await gitApi.getRepositories(pipelineProject.id);
        var projectRepos = await gitApi.getRepositories(project.id);
        let repositoryName = args.repositoryName
        if (typeof repositoryName === "undefined" || repositoryName?.length == 0) {
            // No repository defined assume it is the project name
            repositoryName = args.projectName
        }
        this.logger?.info(`Found ${pipelineRepos.length} pipeline repositories`)
        this.logger?.info(`Searching for repository ${pipelineProject.name} ${args.pipelineRepository.toLowerCase()}`)
        let pipelineRepo = pipelineRepos.find((repo) => {
            return repo.name.toLowerCase() == args.pipelineRepository.toLowerCase();
        });
        this.logger?.info(`Found pipeline repository ${pipelineRepo?.name}`)
        this.logger?.info(`Searching for repository ${project.name} ${repositoryName.toLowerCase()}`)
        let projectRepo = projectRepos.find((repo) => {
            return repo.name.toLowerCase() == repositoryName.toLowerCase();
        });
        this.logger?.info(`Found project repository ${projectRepo?.name}`)

        if (pipelineRepo && projectRepo) {
            this.logger?.info(`Found matching repo ${repositoryName}`)

            let refs = await gitApi.getRefs(projectRepo.id, undefined, "heads/");

            if (refs.length == 0) {
                this.logger.error("No commits to this repository yet. Initialize this repository before creating new branches")
                return Promise.resolve(null)
            }

            let sourceBranch = args.sourceBranch;
            if (typeof sourceBranch === "undefined" || args.sourceBranch?.length == 0) {
                sourceBranch = this.withoutRefsPrefix(projectRepo.defaultBranch)
            }

            let sourceRef = refs.filter(f => f.name == util.format("refs/heads/%s", sourceBranch))
            if (sourceRef.length == 0) {
                this.logger?.error(util.format("Source branch [%s] not found", sourceBranch))
                this.logger?.debug('Existing branches')
                for (var refIndex = 0; refIndex < refs.length; refIndex++) {
                    this.logger?.debug(refs[refIndex].name)
                }
                return projectRepo;
            }

            let destinationRef = refs.filter(f => f.name == util.format("refs/heads/%s", args.destinationBranch))
            if (destinationRef.length > 0) {
                return projectRepo;
            }

            let newRef = <GitRefUpdate>{};
            newRef.repositoryId = projectRepo.id
            newRef.oldObjectId = sourceRef[0].objectId
            newRef.name = util.format("refs/heads/%s", args.destinationBranch)

            let newGitCommit = <GitCommitRef>{}
            newGitCommit.comment = "Add DevOps Pipeline"
            if (typeof args.settings["environments"] === "string") {
                newGitCommit.changes = await this.getGitCommitChanges(args, gitApi, projectRepo, pipelineRepo, sourceRef[0].name, args.destinationBranch, this.withoutRefsPrefix(projectRepo.defaultBranch), args.settings["environments"].split('|').map(element => {
                    return element.toLowerCase();
                }))
            }
            else {
                newGitCommit.changes = await this.getGitCommitChanges(args, gitApi, projectRepo, pipelineRepo, sourceRef[0].name, args.destinationBranch, this.withoutRefsPrefix(projectRepo.defaultBranch), ['validation', 'test', 'prod'])
            }
            if(newGitCommit.changes.length == 0) {
                //Create new branch without any changes
                let newRef = <GitRefUpdate>{};
                newRef.newObjectId = sourceRef[0].objectId
                newRef.oldObjectId = "0000000000000000000000000000000000000000"
                newRef.name = util.format("refs/heads/%s", args.destinationBranch)
                gitApi.updateRefs([newRef], projectRepo.id, project.name)
                this.logger?.info(`Created branch ${args.destinationBranch}`)
            }
            else {
                //Create new branch with updates to pipeline templates
                let gitPush = <GitPush>{}
                gitPush.refUpdates = [newRef]
                gitPush.commits = [newGitCommit]
    
                this.logger?.info(util.format('Pushing new branch %s: %s', args.destinationBranch, JSON.stringify(gitPush)))
                await gitApi.createPush(gitPush, projectRepo.id, project.name)
    
                if (repositoryName?.length > 0) {
                    this.logger?.info(util.format("Repo %s not found", repositoryName))
                    this.logger?.info('Did you mean?')
                    projectRepos.forEach(repo => {
                        if (repo.name.startsWith(repositoryName[0])) {
                            this.logger?.info(repo.name)
                        }
                    });
                }
            }
        }
        return projectRepo;
    }

    /**
     * 
     * @param args Set the default validation branch policy to a branch
     * @param repo The repository that the branch belongs to
     * @param connection The authentcated connection to the Azure DevOps WebApi
     */
    async setBranchPolicy(args: DevOpsBranchArguments, repo: GitRepository, connection: azdev.WebApi): Promise<void> {
        let policyApi = await connection.getPolicyApi();
        if (policyApi == null) {
            return
        }

        let policyTypes = await policyApi.getPolicyTypes(args.projectName)
        let buildTypes = policyTypes.filter(p => { if (p.displayName == 'Build') { return true } })

        if (buildTypes.length > 0) {
            let existingConfigurations = await policyApi.getPolicyConfigurations(args.projectName);

            let existingPolices = existingConfigurations.filter((policy: PolicyConfiguration) => {
                if (policy.settings.scope?.length == 1
                    && policy.settings.scope[0].refName == `refs/heads/${args.destinationBranch}`
                    && policy.settings.scope[0].repositoryId == repo.id
                    && policy.settings.displayName == 'Build Validation'
                    && policy.type.id == buildTypes[0].id) {
                    return true
                }
            })

            if(existingPolices.length > 0) {
                this.logger?.info(util.format("Policy for branch %s already exists. Deleting existing policy", args.destinationBranch))
                for(let i = 0; i < existingPolices.length; i++) {
                    await policyApi.deletePolicyConfiguration(args.projectName, existingPolices[i].id)
                }
            }

            let buildApi = await connection.getBuildApi();
            let builds = await buildApi.getDefinitions(args.projectName)
            let buildMatch = builds.filter(b => { if (b.name == `deploy-validation-${args.destinationBranch}`) { return true } })

            if (buildMatch.length > 0) {
                this.logger?.info(util.format("Found policy build %s", buildMatch[0].name))
                let newPolicy = <PolicyConfiguration>{}
                newPolicy.settings = {}
                newPolicy.settings.buildDefinitionId = buildMatch[0].id
                newPolicy.settings.displayName = 'Build Validation'
                newPolicy.settings.filenamePatterns = [`/${args.destinationBranch}/*`]
                newPolicy.settings.manualQueueOnly = false
                newPolicy.settings.queueOnSourceUpdateOnly = false
                newPolicy.settings.validDuration = 0
                let repoRef = { refName: `refs/heads/${args.destinationBranch}`, matchKind: 'Exact', repositoryId: repo.id }
                newPolicy.settings.scope = [repoRef]
                newPolicy.type = buildTypes[0]
                newPolicy.isBlocking = true
                newPolicy.isEnabled = true
                newPolicy.isEnterpriseManaged = false

                this.logger?.info('Creating branch policy')
                await policyApi.createPolicyConfiguration(newPolicy, args.projectName)
            }
        }
    }

    withoutRefsPrefix(refName: string): string {
        if (!refName.startsWith("refs/heads/")) {
            throw Error("The ref name should have started with 'refs/heads/' but it didn't.");
        }
        return refName.substr("refs/heads/".length, refName.length - "refs/heads/".length);
    }

    /**
     * Create Azure DevOps builds for branch
     * @param args - The branch to optionally copy from and and destination branch to apply the builds to
     * @param project - The project to add the build to
     * @param connection - The authenticated connection to Azure DevOp WebApi
     */
    async createBuildForBranch(args: DevOpsBranchArguments, project: CoreInterfaces.TeamProject, repo: GitRepository, connection: azdev.WebApi): Promise<void> {
        let buildClient = await connection.getBuildApi()

        let definitions = await buildClient.getDefinitions(project.name)

        let taskApi = await connection.getTaskAgentApi()

        let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args, args.settings)
        let baseUrl = `$(devOpsOrgUrl}${args.projectName}`

        this.logger?.info(`Retrieving default Queue`)
        let agentQueues = await taskApi?.getAgentQueues(project.id)
        this.logger?.info(`Found: ${agentQueues?.length} queues`)

        let defaultQueue = agentQueues?.filter(p => p.name == "Azure Pipelines")

        let defaultAgentQueue = defaultQueue?.length > 0 ? defaultQueue[0] : undefined
        this.logger?.info(`Default Queue: ${defaultQueue?.length > 0 ? defaultQueue[0].name : "Not Found. You will need to set the default queue manually. Please verify the permissions for the user executing this command include access to queues."}`)

        if (typeof args.settings["environments"] === "string") {
            for (const environment of args.settings["environments"].split('|')) {
                this.logger?.info(`Creating build for environment ${environment}`)
                await this.cloneBuildSettings(definitions, buildClient, project, repo, baseUrl, args, environment, environment.toLowerCase(), args.destinationBranch, defaultAgentQueue);
            }
        } else {
            await this.cloneBuildSettings(definitions, buildClient, project, repo, baseUrl, args, "Validation", "validation", args.destinationBranch, defaultAgentQueue);
            await this.cloneBuildSettings(definitions, buildClient, project, repo, baseUrl, args, "Test", "test", args.destinationBranch, defaultAgentQueue);
            await this.cloneBuildSettings(definitions, buildClient, project, repo, baseUrl, args, "Production", "prod", args.destinationBranch, defaultAgentQueue);
        }
    }

    async cloneBuildSettings(pipelines: BuildInterfaces.BuildDefinitionReference[], client: IBuildApi, project: CoreInterfaces.TeamProject, repo: GitRepository, baseUrl: string, args: DevOpsBranchArguments, environmentName: string, buildName: string, createInBranch: string, defaultQueue: TaskAgentQueue): Promise<void> {

        let source = args.sourceBuildName
        let destination = args.destinationBranch

        var destinationBuildName = util.format("deploy-%s-%s", buildName, destination);
        var destinationBuilds = pipelines.filter(p => p.name == destinationBuildName);
        let destinationBuild = destinationBuilds.length > 0 ? await client.getDefinition(destinationBuilds[0].project.name, destinationBuilds[0].id) : null
        let sourceBuild = null
        if (typeof (source) != "undefined" && (source.length != 0)) {
            var sourceBuildName = util.format("deploy-%s-%s", buildName, source);
            var sourceBuilds = pipelines.filter(p => p.name == sourceBuildName);

            sourceBuild = sourceBuilds.length > 0 ? await client.getDefinition(sourceBuilds[0].project?.name, sourceBuilds[0].id) : null
            if (sourceBuild != null) {
                sourceBuild.repository = repo
                if (destinationBuild != null && destinationBuild.variables != null) {
                    let destinationKeys = Object.keys(destinationBuild.variables)
                    if (sourceBuild.variables != null) {
                        let sourceKeys = Object.keys(sourceBuild.variables)
                        if (destinationKeys.length == 0 && sourceKeys.length > 0) {
                            destinationBuild.variables = sourceBuild.variables

                            this.logger?.debug(util.format("Updating %s environment variables", destinationBuildName))
                            await client.updateDefinition(destinationBuild, destinationBuild.project.name, destinationBuild.id)
                            return;
                        }
                    }
                }
            }
        }

        if (destinationBuild != null) {
            return;
        }

        let defaultSettings = false

        if (sourceBuild == null) {
            defaultSettings = true
            this.logger?.debug(`Matching ${buildName} build not found, will apply default settings`)
            this.logger?.debug(`Applying default service connection. You will need to update settings with you environment teams`)
            sourceBuild = <BuildInterfaces.BuildDefinition>{};
            sourceBuild.repository = <BuildInterfaces.BuildRepository>{}
            sourceBuild.repository.id = repo.id
            sourceBuild.repository.name = repo.name
            sourceBuild.repository.url = repo.url
            sourceBuild.repository.type = 'TfsGit'
            let serviceConnectionName = ''
            let serviceConnectionUrl = ''
            let environmentTenantId = ''
            let environmentClientId = ''
            let environmentSecret = ''

            let environmentUrl = typeof (args.settings[buildName] === "string") ? args.settings[buildName] : ""
            this.logger?.info(`Environment URL: ${environmentUrl}`)
            serviceConnectionName = args.settings[`${buildName}-scname`]
            serviceConnectionUrl = Environment.getEnvironmentUrl(environmentUrl, args.settings)
            this.logger?.info(`Service Connection URL: ${serviceConnectionUrl}`)
            //Fall back to using the service connection url supplied as the service connection name if no name was supplied
            if (typeof serviceConnectionName === "undefined" || serviceConnectionName == '') {
                serviceConnectionName = serviceConnectionUrl
            }
            this.logger?.debug(util.format("Environment Name %s", environmentName));
            this.logger?.debug(util.format("Name %s", serviceConnectionName));
            this.logger?.debug(util.format("URL %s", serviceConnectionUrl));

            sourceBuild.variables = {
                EnvironmentName: <BuildInterfaces.BuildDefinitionVariable>{},
                ServiceConnection: <BuildInterfaces.BuildDefinitionVariable>{},
                ServiceConnectionUrl: <BuildInterfaces.BuildDefinitionVariable>{}
            }

            sourceBuild.variables.EnvironmentName.value = environmentName
            sourceBuild.variables.ServiceConnection.value = serviceConnectionName
            sourceBuild.variables.ServiceConnectionUrl.value = serviceConnectionUrl
        }

        this.logger?.info(util.format("Creating new pipeline %s", destinationBuildName));
        var newBuild = <BuildInterfaces.BuildDefinition>{};
        newBuild.name = destinationBuildName;
        let process = <BuildInterfaces.YamlProcess>{};
        process.yamlFilename = util.format("/%s/%s.yml", destination, destinationBuildName)
        newBuild.process = process
        newBuild.path = "/" + destination;
        newBuild.repository = sourceBuild.repository;
        newBuild.repository.defaultBranch = createInBranch;
        newBuild.variables = sourceBuild.variables
        if (sourceBuild.triggers != null) {
            newBuild.triggers = sourceBuild.triggers
        }
        else {
            let trigger = <BuildInterfaces.ContinuousIntegrationTrigger>{}
            trigger.triggerType = BuildInterfaces.DefinitionTriggerType.ContinuousIntegration
            trigger.branchFilters = []
            trigger.pathFilters = []
            trigger.maxConcurrentBuildsPerBranch = 1
            trigger.batchChanges = false
            trigger.settingsSourceType = BuildInterfaces.DefinitionTriggerType.ContinuousIntegration
            newBuild.triggers = <BuildInterfaces.ContinuousIntegrationTrigger[]>[trigger]
        }
        if (sourceBuild.queue != null) {
            newBuild.queue = sourceBuild.queue
        } else {
            newBuild.queue = defaultQueue
        }

        let result
        try {
            result = await client.createDefinition(newBuild, project.name);
        } catch (error) {
            this.logger?.error(util.format("Error creating new pipeline definition results %s", error));
            throw error
        }

        if (defaultSettings && args.openDefaultPages) {
            await open(`${baseUrl}/_build/${result?.id}`)
        }
    }

    async getGitCommitChanges(args: DevOpsBranchArguments, gitApi: gitm.IGitApi, projectRepo: GitRepository, pipelineRepo: GitRepository, sourceBranch: string, destinationBranch: string, defaultBranch: string, names: string[]): Promise<GitChange[]> {
        const personalAccessTokenRegexp = /^.{76}AZDO.{4}$/;
        let pipelineProject = args.pipelineProject?.length > 0 ? args.pipelineProject : args.projectName
        let results: GitChange[] = []

        let accessToken = args.accessToken?.length > 0 ? args.accessToken : args.accessTokens["499b84ac-1321-427f-aa17-267ca6975798"]
        let config = {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        }
        if (accessToken.length === 52 || personalAccessTokenRegexp.test(accessToken)) {
            config = {
                headers: {
                    'Authorization': `Basic ${Buffer.from(":" + accessToken).toString('base64')}`
                }
            }
        }

        for (var i = 0; i < names.length; i++) {
            this.logger?.info(util.format("Getting changes for %s", names[i]));

            let repoTemplatePath = util.format("/%s/deploy-%s-%s.yml", destinationBranch, names[i], destinationBranch)
            let existingItem = await gitApi.getItem(projectRepo.id, repoTemplatePath, args.projectName, null, VersionControlRecursionType.None, false, true, false, <GitVersionDescriptor>{ versionType: GitVersionType.Branch, version: this.withoutRefsPrefix(sourceBranch)})

            this.logger?.info(util.format("Existing item %s", existingItem?.path));
            if (typeof existingItem === "undefined" || existingItem == null) {
                this.logger?.info(util.format("Pipeline template does not exist %s", repoTemplatePath));
                let templatePath = util.format("/Pipelines/build-deploy-%s-SampleSolution.yml", names[i])
                if (typeof args.settings[`${names[i]}-buildtemplate`] === "string") {
                    templatePath = args.settings[`${names[i]}-buildtemplate`]
                }

                let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args);
                let contentUrl = `${devOpsOrgUrl}${pipelineProject}/_apis/git/repositories/${args.pipelineRepository}/items?path=${templatePath}&includeContent=true&versionDescriptor.version=${this.withoutRefsPrefix(pipelineRepo.defaultBranch)}&versionDescriptor.versionType=branch&api-version=5.0`
                this.logger?.info(util.format("Getting content from %s", contentUrl));

                let response: any = await this.getUrl(contentUrl, config)
                if (response?.content != null) {
                    let commit = <GitChange>{}
                    commit.changeType = VersionControlChangeType.Add
                    commit.item = <GitItem>{}
                    commit.item.path = util.format("/%s/deploy-%s-%s.yml", destinationBranch, names[i], destinationBranch)
                    commit.newContent = <ItemContent>{}

                    commit.newContent.content = response?.content.toString().replace(/BranchContainingTheBuildTemplates/g, defaultBranch)
                    commit.newContent.content = (commit.newContent.content)?.replace(/RepositoryContainingTheBuildTemplates/g, `${pipelineProject}/${pipelineRepo.name}`)
                    commit.newContent.content = (commit.newContent.content)?.replace(/SampleSolutionName/g, destinationBranch)

                    let variableGroup = args.settings[names[i] + "-variablegroup"]
                    if (typeof variableGroup !== "undefined" && variableGroup != '') {
                        commit.newContent.content = (commit.newContent.content)?.replace(/alm-accelerator-variable-group/g, variableGroup)
                    }

                    commit.newContent.contentType = ItemContentType.RawText

                    results.push(commit)
                } else {
                    this.logger?.info(`Error creating new pipeline definition for ${names[i]}: ${JSON.stringify(response)}`);
                    throw response
                }
            }
        }
        return results;
    }
}

type GraphGroup = {
    /**
     * A short phrase to help human readers disambiguate groups with similar names
     */
    description: string

    /**
     * The descriptor is the primary way to reference the graph subject while the system is running. This field will uniquely identify the same graph subject across both Accounts and Organizations.
     */
    descriptor: string

    /**
     * This is the non-unique display name of the graph subject. To change this field, you must alter its value in the source provider.
     */
    displayName: string

    /**
     * This represents the name of the container of origin for a graph member. (For MSA this is "Windows Live ID", for AD the name of the domain, for AAD the tenantID of the directory, for VSTS groups the ScopeId, etc)
     */
    domain: string

    /**
     * [Internal Use Only] The legacy descriptor is here in case you need to access old version IMS using identity descriptor.
     */
    legacyDescriptor: string


    /**
     * The email address of record for a given graph member. This may be different than the principal name.
     */
    mailAddress: string


    /**
     * The type of source provider for the origin identifier (ex:AD, AAD, MSA)
     */
    origin: string

    /**
     * The unique identifier from the system of origin. Typically a sid, object id or Guid. Linking and unlinking operations can cause this value to change for a user because the user is not backed by a different provider and has a different unique id in the new provider.
     */
    originId: string


    /**
     * This is the PrincipalName of this graph member from the source provider. The source provider may change this field over time and it is not guaranteed to be immutable for the life of the graph member by VSTS.
     */
    principalName: string


    /**
     * This field identifies the type of the graph subject (ex: Group, Scope, User).
     */
    subjectKind: string


    /**
     * This url is the full route to the source resource of this graph subject.
     */
    url: string
}

type MembershipResponse = {
    count: number
    value: GraphMembership[]
}

type GraphMembership = {
    containerDescriptor: string
    memberDescriptor: string
}

/**
 * Install Arguments
 */
class DevOpsInstallArguments {

    constructor() {
        this.extensions = []
        this.environments = {}
        this.azureActiveDirectoryServicePrincipal = 'ALMAcceleratorServicePrincipal'
        this.accessTokens = {}
        this.createSecretIfNoExist = true
        this.endpoint = "prod"
        this.settings = {}
    }

    /**
     * The Bearer Auth access token
     */
    accessToken: string


    /**
     * Audance scoped access tokens
     */
    accessTokens: { [id: string]: string }

    /**
     * The power platform endpoint type
     */
    endpoint: string;

    /**
     * The name of the Azure DevOps Organization
     */
    organizationName: string
    /**
     * The name of repository that the Accelerator has been deployed to or will be deployed to
     */
    repositoryName: string

    /**
     * The name of project that the Accelerator pipeline has been deployed to or will be deployed to
     */
    pipelineProjectName: string

    /**
     * The name of repository that the Accelerator pipeline has been deployed to or will be deployed to
     */
    pipelineRepositoryName: string

    /**
     * The name of the project that the Accelerator has been deployed to
     */
    projectName: string

    /**
     * The name of the Azure subscription. Required if access to more than one Azure subscription
     */
    subscription: string

    /**
     * The client id to use for authentication
     */
    clientId: string

    /**
     * The Azure Active directory application name will use to integrate with Azure DevOps
     */
    azureActiveDirectoryServicePrincipal: string

    /**
     * The azure active directory makers group
    */
    azureActiveDirectoryMakersGroup: string

    /**
     * The DevOps extension to install
     */
    extensions: DevOpsExtension[]

    /**
     * Create secret if not exist
     */
    createSecretIfNoExist: boolean

    /**
     * The Azure DevOps environment
     */
    environment: string

    /**
    * The Azure DevOps environments
    */
    environments: { [id: string]: string }

    /**
    * Optional settings
    */
    settings: { [id: string]: string }

    /**
    * The user to associate with this connection
    */
    user: string
}

type DevOpsExtension = {
    /**
     * The extension name
     */
    name: string

    /**
     * The publisher name
     */
    publisher: string
}

/**
 * Branch Arguments
 */
class DevOpsBranchArguments {
    constructor() {
        this.settings = {}
    }

    /**
     * The Bearer Auth access token
     */
    accessToken: string

    /**
     * Scoped access tokens
     */
    accessTokens: { [id: string]: string }

    /**
     * The name of the Azure DevOps Organization
     */
    organizationName: string

    /**
     * The name of repository that the Accelerator has been deployed to or will be deployed to
     */
    repositoryName: string

    /**
     * The name of pipeline templates repository that the Accelerator has been imported
     */
    pipelineProject: string

    /**
     * The name of pipeline templates repository that the Accelerator has been imported
     */
    pipelineRepository: string

    /**
     * The name of the project that the Accelerator has been deployed to
     */
    projectName: string
    /**
     * The source branch to branch from (Optional). If not defined will use default branch
     */
    sourceBranch: string

    /**
     * The source build name to copy setup from> if not defained will create initial values that will need to be updated
     */
    sourceBuildName: string

    /**
     * The name of the branch to create
     */
    destinationBranch: string

    /**
     * Open default web configuration pages
     */
    openDefaultPages: boolean

    /**
    * Optional settings
    */
    settings: { [id: string]: string }
}

type ServiceConnectorReference = string | any

type DevOpsProjectSecurityContext = {
    /**
     * The project id
     */
    projectId: string

    /**
     * The ALM Azure DevOps Group
     */
    almGroup: GraphGroup

    /**
     * The Azure DevOps service for REST API calls
     */
    securityUrl: string

    /**
     * The extension name
     */
    projectDescriptor: string
}

export {
    DevOpsBranchArguments,
    DevOpsInstallArguments,
    DevOpsCommand,
    DevOpsExtension,
    DevOpsProjectSecurityContext
};