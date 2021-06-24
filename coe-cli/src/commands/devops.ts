"use strict";
import * as azdev from "azure-devops-node-api"
import { IHeaders, IRequestHandler } from "azure-devops-node-api/interfaces/common/VsoBaseInterfaces";
import util from "util"
import * as CoreInterfaces from 'azure-devops-node-api/interfaces/CoreInterfaces';
import { GitRefUpdate, GitCommitRef, GitPush, GitChange, VersionControlChangeType, GitItem, ItemContentType, GitRef, GitImportRequest, GitRepositoryCreateOptions, GitImportRequestParameters, GitImportGitSource, GitAsyncOperationStatus } from 'azure-devops-node-api/interfaces/GitInterfaces';
import * as gitm from "azure-devops-node-api/GitApi"
import * as BuildInterfaces from 'azure-devops-node-api/interfaces/BuildInterfaces';

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
import { EndpointAuthorization, ServiceEndpoint, TaskAgentPool, VariableGroupParameters } from "azure-devops-node-api/interfaces/TaskAgentInterfaces";
import { ProjectReference, VariableGroupProjectReference, VariableValue } from "azure-devops-node-api/interfaces/ReleaseInterfaces";

import * as winston from 'winston';
import { Environment } from "../common/enviroment";
import { Prompt } from "../common/prompt";
import { InstalledExtension } from "azure-devops-node-api/interfaces/ExtensionManagementInterfaces";

import url from 'url';
import { UserRoleAssignmentRef } from "azure-devops-node-api/interfaces/SecurityRolesInterfaces";

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
     accessTokens: { [id: string] : string }

    /**
     * The power platform endpoint type
     */
     endpoint: string;

     /**
      * The name of the Azure DevOps Organization
      */
     organizationName:string
     /**
      * The name of repository that the Accelerator has been deployed to or wil lbe deployed to
      */
     repositoryName: string
     /**
      * The name of the project that the Accelerator has been deployed to
      */
     projectName: string

     /**
      * The name of the Azure account. Required if access to more than one Azure account
      */
    account: string

    /**
     * The client id to use for authentication
     */
    clientId:string

    /**
     * The Azure Active directory application name will use to integrate with Azure DevOps
     */
    azureActiveDirectoryServicePrincipal:string

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
    environments: { [id: string] : string }

    /**
    * Optional settings
    */
    settings:  { [id: string] : string }

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
    accessTokens: { [id: string] : string }
    
    /**
     * The name of the Azure DevOps Organization
     */
    organizationName:string
    /**
     * The name of repository that the Accelerator has been deployed to or wil lbe deployed to
     */
    repositoryName: string
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
    settings:  { [id: string] : string }
}

type ServiceConnectorReference = string | any

 /**
 * Azure DevOps Commands
 */
class DevOpsCommand {
    createWebApi: (orgUrl: string, authHandler: IRequestHandler) => azdev.WebApi
    createAADCommand: () => AADCommand
    getUrl: (url: string) => Promise<string>
    runCommand: (command: string, displayOutput: boolean) => string 
    prompt: Prompt
    getHttpClient: (connection: azdev.WebApi) => httpm.HttpClient
    logger: winston.Logger
    readFile: (path: fs.PathLike | FileHandle, options: { encoding: BufferEncoding, flag?: fs.OpenMode } | BufferEncoding) => Promise<string>
    
    constructor(logger: winston.Logger, defaultFs: any = null) {
        this.logger = logger
        this.createWebApi = (orgUrl: string, authHandler: IRequestHandler) => new azdev.WebApi(orgUrl, authHandler)
        this.createAADCommand = () => new AADCommand(this.logger)
        this.getUrl = async (url: string) => {
            return (await (axios.get<string>(url))).data
        }
        this.runCommand = (command: string, displayOutput: boolean) => {
            if (displayOutput) {
              return execSync(command, <ExecSyncOptionsWithStringEncoding> { stdio: 'inherit', encoding: 'utf8' })
            } else {
              return execSync(command, <ExecSyncOptionsWithStringEncoding> { encoding: 'utf8' })
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
     * @param args Install components required to run AA4AM using Azure CLI commands
     * @returns 
     */
    async install(args: DevOpsInstallArguments): Promise<void> {
        let extensions = path.join(__dirname, '..', '..', '..', 'config', 'AzureDevOpsExtensionsDetails.json')

        let orgUrl = Environment.getDevOpsOrgUrl(args)

        if (args.extensions.length == 0) {
            this.logger?.info('Loading DevOps Extensions Configuration')
            let extensionConfig = JSON.parse(await this.readFile(extensions, 'utf-8'))
            for ( let i = 0; i < extensionConfig.length; i++ ) {
                args.extensions.push(<DevOpsExtension> {
                    name: extensionConfig[i].extensionId,
                    publisher: extensionConfig[i].publisherId
                })
            }    
        }

        let authHandler = azdev.getBearerHandler(typeof args.accessTokens["499b84ac-1321-427f-aa17-267ca6975798"] !== "undefined" ? args.accessTokens["499b84ac-1321-427f-aa17-267ca6975798"] : args.accessToken); 
        let connection = this.createWebApi(orgUrl, authHandler); 

        await this.installExtensions(args, connection)
        
        let repo = await this.importPipelineRepository(args, connection)

        await this.createAdvancedMakersBuildPipelines(args, connection, repo)

        await this.createAdvancedMakersBuildVariables(args, connection)

        await this.createAdvancedMakersServiceConnections(args, connection)
    }

    async installExtensions(args: DevOpsInstallArguments, connection: azdev.WebApi) : Promise<void> {
        if (args.extensions.length == 0) {
            return Promise.resolve()
        }

        this.logger.info(`Checking DevOps Extensions`)

        let extensionsApi = await connection.getExtensionManagementApi()

        let extensions = await extensionsApi.getInstalledExtensions()

        for ( let i = 0; i < args.extensions.length; i++ ) {
            let extension = args.extensions[i]
        
            let match = extensions.filter( (e: InstalledExtension ) => e.extensionId == extension.name && e.publisherId == extension.publisher )
            if ( match.length == 0 ) {
                this.logger.info(`Installing ${extension.name} by ${extension.publisher}`)
                await extensionsApi.installExtensionByName(extension.publisher, extension.name)
            } else {
                this.logger.info(`Extension ${extension.name} by ${extension.publisher} installed`)
            }
        }
    }

    async importPipelineRepository(args: DevOpsInstallArguments, connection: azdev.WebApi) : Promise<GitRepository> {
        let gitApi = await connection.getGitApi()

        this.logger.info(`Checking pipeline repository`)
        let repo = await this.getRepository(args, gitApi)

        let refs = await gitApi.getRefs(repo.id, args.projectName)

        if (refs.length == 0) {
            this.logger?.debug(`Importing ${args.repositoryName}`)
            repo.defaultBranch = "refs/heads/main"
            let importRequest = await gitApi.createImportRequest(<GitImportRequest>{ 
                parameters: <GitImportRequestParameters>{ gitSource: <GitImportGitSource>{ url:"https://github.com/microsoft/coe-alm-accelerator-templates.git" }},
                repository: repo
            }, args.projectName, repo.id)

            
            while (true) {
                let requests = await gitApi.queryImportRequests(args.projectName, repo.id)
                let current = requests.filter(r => r.importRequestId == importRequest.importRequestId)[0] 
                if ( current.status ==  GitAsyncOperationStatus.Completed || current.status ==  GitAsyncOperationStatus.Abandoned || current.status ==  GitAsyncOperationStatus.Failed ) {
                    break;
                }
                await this.sleep(500)
            }

            this.logger?.debug('Setting default branch')
            let headers = <IHeaders>{ };
            headers["Content-Type"] = "application/json"

            let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args)

            await this.getHttpClient(connection).patch(`${devOpsOrgUrl}${args.projectName}/_apis/git/repositories/${repo.id}?api-version=6.0`, '{"defaultBranch":"refs/heads/main"}', headers)
        } else {
            this.logger.info(`Pipeline repository ${args.repositoryName}`)
        }

        return repo;
    }

    private async getRepository(args: DevOpsInstallArguments, gitApi: gitm.IGitApi) : Promise<GitRepository> {
        let repos = await gitApi.getRepositories(args.projectName);
        if (repos.filter(r => r.name == args.repositoryName).length == 0) {
            this.logger?.debug(`Creating repository ${args.repositoryName}`)
            return await gitApi.createRepository(<GitRepositoryCreateOptions>{name: args.repositoryName}, args.projectName)
        } else {
            return repos.filter(r => r.name == args.repositoryName)[0]
        }
    }

    sleep(ms: number)  {
        return new Promise(resolve => setTimeout(resolve, ms))
    }

    /**
     * Create Build pipelines required by the ALM Accelerator for Advanced Makers (AA4AM)
     * @param args The installation paramaters
     * @param connection The authenticated connection
     * @param repo The pipeline repo to a create builds for
     */
    async createAdvancedMakersBuildPipelines(args: DevOpsInstallArguments, connection: azdev.WebApi, repo: GitRepository) : Promise<void> {
        connection = await this.createConnectionIfExists(args, connection)

        if (repo == null) {
            let gitApi = await connection.getGitApi()
            repo = await this.getRepository(args, gitApi)
        }

        let buildApi = await connection.getBuildApi();

        if (typeof buildApi == "undefined") {
            this.logger?.info("Build API missing")
            return
        }

        let taskApi = await connection.getTaskAgentApi()

        let defaultPool = (await taskApi?.getAgentPools())?.filter(p => p.name == "Default")
        let defaultAgentPool = defaultPool?.length > 0 ? defaultPool[0] : undefined

        let builds = await buildApi.getDefinitions(args.projectName)

        let buildNames = ['export-solution-to-git', 'import-unmanaged-to-dev-environment', 'delete-unmanaged-solution-and-components']

        for ( var i = 0; i < buildNames.length; i++ ) {
            let exportBuild = builds.filter(b => b.name == buildNames[i])

            if (exportBuild.length == 0) {
                this.logger?.debug(`Creating build ${buildNames[i]}`)
                await this.createBuild(buildApi, repo, buildNames[i], `/Pipelines/${buildNames[i]}.yml`, defaultAgentPool)
            } else {
                let build = await buildApi.getDefinition(args.projectName, exportBuild[0].id)
                let changes = false

                if ( typeof build.queue === "undefined" ) {
                    this.logger?.debug(`Missing build queue for ${build.name}`)
                    build.queue = <BuildInterfaces.BuildDefinitionReference> { queue: defaultAgentPool }
                    changes = true
                }

                if (changes) {
                    this.logger?.debug(`Updating ${build.name}`)
                    await buildApi.updateDefinition(build, args.projectName, exportBuild[0].id)
                } else {
                    this.logger?.debug(`No changes to ${buildNames[i]}`)
                }
                
            }
        }
    }

    async createAdvancedMakersBuildVariables(args: DevOpsInstallArguments, connection: azdev.WebApi) {
        connection = await this.createConnectionIfExists(args, connection)

        let taskApi = await connection.getTaskAgentApi()

        let groups = await taskApi?.getVariableGroups(args.projectName);

        let global = groups?.filter(g => g.name == "global-variable-group")
        if ( global?.length == 0) {
            let aadCommand = this.createAADCommand()

            let aadArgs = new AADAppInstallArguments()
            aadArgs.account = args.account
            aadArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
            aadArgs.createSecret = args.createSecretIfNoExist
            aadArgs.accessTokens = args.accessTokens
            aadArgs.endpoint = args.endpoint

            let secretInfo = await aadCommand.addSecret(aadArgs, "COE-AA4AM")

            if (!aadArgs.createSecret) {
                this.logger?.warn('Client secret not added for variable group global-variable-group it wil need to be added manually')
            }

            let buildApi = await connection.getBuildApi();
            let builds = await buildApi.getDefinitions(args.projectName)
            let exportBuild = builds.filter(b => b.name == "export-solution-to-git")
            let buildId = exportBuild.length == 1 ? exportBuild[0].id.toString() : ""

            let validationConnection = 'TODO'
            if (typeof args.environments["validation"] !== "undefined" ) {
                // Use the named environment
                validationConnection = args.environments["validation"] 
            }
            if (typeof args.settings["validation"] != "undefined" && validationConnection == "TODO" ) {
                // Use the validation settings
                validationConnection = args.settings["validation"] 
            }
            if (args.environment?.length > 0 && validationConnection == "TODO") {
                // Default to environment 
                validationConnection = args.environment
            }
           
            let paramemeters = <VariableGroupParameters>{ }
            paramemeters.variableGroupProjectReferences = [
                <VariableGroupProjectReference>{
                    name:  'global-variable-group',
                    projectReference:<ProjectReference>{
                        name: args.projectName,
                    }
                }]
            paramemeters.name = 'global-variable-group'
            paramemeters.description = 'ALM Accelerator for Advanced Makers'

            let validationUrl = Environment.getEnvironmentUrl(validationConnection, args.settings)

            paramemeters.variables = {
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
                }, 
                "PipelineIdToLoadJsonValuesFrom": <VariableValue>{ 
                    value: buildId
                },
                "ValidationServiceConnection": <VariableValue>{ 
                    value: validationUrl
                }
            }

            taskApi.addVariableGroup(paramemeters);
        }
        
    }

    async createAdvancedMakersServiceConnections(args: DevOpsInstallArguments, connection: azdev.WebApi, setupEnvironmentConnections: boolean = true) {
        connection = await this.createConnectionIfExists(args, connection)

        let endpoints = await this.getServiceConnections(args, connection)
        let coreApi = await connection.getCoreApi();

        let projects = await coreApi.getProjects()
        let project = projects.filter(p => p.name?.toLowerCase() == args.projectName?.toLowerCase() )

        if (project.length == 0) {
            this.logger?.error(`Azure DevOps project ${args.projectName} not found`)
            return Promise.resolve();
        }

        let aadCommand = this.createAADCommand()
        let aadArgs = new AADAppInstallArguments()
        aadArgs.account = args.account
        aadArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
        aadArgs.createSecret = args.createSecretIfNoExist
        aadArgs.accessTokens = args.accessTokens
        aadArgs.endpoint = args.endpoint

        let keys = Object.keys(args.environments)

        let environments : string[] = []

        if ( args.environment?.length > 0 ) {
            environments.push(args.environment)
        }

        let mapping : { [id: string] : string } = {}

        if ( setupEnvironmentConnections ) {
            for ( var i = 0; i < keys.length; i++) {
                let environmentName = args.environments[keys[i]]
                mapping[environmentName] = keys[i]
                if ( environments.filter( (e:string) => e == environmentName ).length == 0) {
                    environments.push(environmentName)
                }
            }
    
            if (Array.isArray(args.settings["installEnvironments"])) {
                for ( var i = 0; i < args.settings["installEnvironments"].length; i++ ) {
                    let environmentName = args.settings["installEnvironments"][i]
                    if ( typeof args.settings[environmentName] === "string" && environments.filter( (e:string) => e ==  args.settings[environmentName] ).length == 0) {
                        environments.push(args.settings[environmentName])
                    }
                }
            }    
        }

        for ( var i = 0; i < environments.length; i++) {
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
                    authorization: <EndpointAuthorization> {
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
                            projectReference: <ProjectReference> {
                                id: project[0].id,
                                name: args.projectName
                            },
                            name: endpointUrl
                        }
                    ]
                }

                let headers = <IHeaders>{ };
                headers["Content-Type"] = "application/json"
                let webClient = this.getHttpClient(connection);

                let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args)

                // https://docs.microsoft.com/en-us/rest/api/azure/devops/serviceendpoint/endpoints/create?view=azure-devops-rest-6.0
                let create = await webClient.post(`${devOpsOrgUrl}${args.projectName}/_apis/serviceendpoint/endpoints?api-version=6.0-preview.4`, JSON.stringify(ep), headers)

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

    async assignUserToServiceConnector(project: CoreInterfaces.TeamProjectReference, endpoint: ServiceConnectorReference, args: DevOpsInstallArguments, connection: azdev.WebApi) {
        if ( args.user?.length > 0 ) {
            let webClient = this.getHttpClient(connection);
            let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args)
    
            if ( typeof endpoint === "string") {
                let results = await webClient.get(`${devOpsOrgUrl}${args.projectName}/_apis/serviceendpoint/endpoints?api-version=6.0-preview.4`);
                let endpointJson = await results.readBody()
                this.logger?.debug(endpointJson)
                let endpoints = <any[]>(JSON.parse(endpointJson).value)
                this.logger?.debug(endpoints)

                let endPointMatch = endpoints.filter ( (ep: any) => ep.url == endpoint)

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

            let connectorMatch = connectorData.value?.filter( (c: any) => c.identity.id == userId )

            if ( connectorMatch?.length == 0 ) {
                let headers = <IHeaders>{ };
                headers["Content-Type"] = "application/json"
                
                let newRole = [{
                    "roleName": "User",
                    "userId": userId
                }]

                //https://docs.microsoft.com/en-us/rest/api/azure/devops/securityroles/roleassignments/set%20role%20assignments?view=azure-devops-rest-6.1
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

        // https://docs.microsoft.com/en-us/rest/api/azure/devops/ims/identities/read%20identities?view=azure-devops-rest-6.0#by-email
        let query = await client.get(`${devOpsOrgUrl.replace("https://dev", "https://vssps.dev")}_apis/identities?searchFilter=General&filterValue=${user}&queryMembership=None&api-version=6.0`)
        let identityJson = await query.readBody()
        let users = JSON.parse(identityJson)
        this.logger?.debug(`Found ${users.value?.length} user(s)`)
        this.logger?.verbose(users)

        this.logger?.debug(`Searching for ${user}`)
        let userMatch = users.value?.filter((u:any) => u.properties?.Account['$value']?.toLowerCase() == user?.toLowerCase())

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
    async getServiceConnections(args: DevOpsInstallArguments, connection: azdev.WebApi) : Promise<ServiceEndpoint[]> {
        let webClient = this.getHttpClient(connection);
        let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args, args.settings)
        let request = await webClient.get(`${devOpsOrgUrl}${args.projectName}/_apis/serviceendpoint/endpoints?api-version=6.0-preview.4`)
        let data = await request.readBody()
        this.logger?.debug(data)
        return <ServiceEndpoint[]>(JSON.parse(data).value)
    }

    private async createConnectionIfExists( args: DevOpsInstallArguments, connection: azdev.WebApi) : Promise<azdev.WebApi> {
        if ( connection == null) {
            let authHandler = azdev.getBearerHandler(args.accessToken?.length > 0 ? args.accessToken : args.accessTokens["499b84ac-1321-427f-aa17-267ca6975798"], true); 
            let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args, args.settings)
            return this.createWebApi(devOpsOrgUrl, authHandler); 
        }
        return connection
    }

    async createBuild(buildApi: IBuildApi, repo: GitRepository, name: string, yamlFilename: string, defaultPool: TaskAgentPool) : Promise<BuildInterfaces.BuildDefinition> {
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
        newBuild.queue = <BuildInterfaces.BuildDefinitionReference> { queue: defaultPool }
       
        return buildApi.createDefinition(newBuild, repo.project.name)
    }
    

    /**
     * Create new branch in Azure DevOps repository
     *
     * @param args {DevOpsBranchArguments} - The branch request
     * @return {Promise} aync outcome
     *
     */
    async branch(args: DevOpsBranchArguments) : Promise<void> {
        let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args, args.settings)
        let authHandler = azdev.getBearerHandler(args.accessToken); 
        let connection = this.createWebApi(devOpsOrgUrl, authHandler); 

        let core = await connection.getCoreApi()
        let project : CoreInterfaces.TeamProject = await core.getProject(args.projectName)

        if (typeof project !== "undefined") {
            this.logger?.info(util.format("Found project %s", project.name))

            let gitApi = await connection.getGitApi()

            let repo = await this.createBranch(args, project, gitApi);

            if (repo != null) {
                await this.createBuildForBranch(args, project, repo, connection);

                await this.setBranchPolicy(args, repo, connection);    
            }
        }
    }

    /**
     * Create branch in Azure Devops Repo
     * @param args - The branch arguments
     * @param project Th project to create the project in
     * @param gitApi The open git API connection to create the 
     * @returns 
     */
    async createBranch(args: DevOpsBranchArguments, project: CoreInterfaces.TeamProject, gitApi: gitm.IGitApi) : Promise<GitRepository> {
        var repos = await gitApi.getRepositories(project.id);
        var matchingRepo: GitRepository;

        let repositoryName = args.repositoryName
        if ( typeof repositoryName === "undefined" || repositoryName?.length == 0) {
            // No repository defined assume it is the project name
            repositoryName = args.projectName
        }

        let foundRepo = false
        for ( let i = 0; i < repos.length; i++ ) {
            let repo = repos[i]

            if ( repo.name.toLowerCase() == repositoryName.toLowerCase() ) {
                foundRepo = true
                matchingRepo = repo

                this.logger?.debug(`Found matching repo ${repositoryName}`)

                let refs = await gitApi.getRefs(repo.id, undefined, "heads/");

                if (refs.length == 0) {
                    this.logger.info("No commits to this repository yet. Initialize this repository before creating new branches")
                    return Promise.resolve(null)
                }

                let sourceBranch = args.sourceBranch;
                if (typeof sourceBranch === "undefined" || args.sourceBranch?.length == 0) {
                    sourceBranch = this.withoutRefsPrefix(repo.defaultBranch)
                }

                let sourceRef = refs.filter(f => f.name == util.format("refs/heads/%s", sourceBranch))
                if (sourceRef.length == 0) {
                    this.logger?.error(util.format("Source branch [%s] not found", sourceBranch))
                    this.logger?.debug('Existing branches')
                    for ( var refIndex = 0; refIndex < refs.length; refIndex++ ) {
                        this.logger?.debug(refs[refIndex].name)
                    }
                    return matchingRepo;
                }

                let destinationRef = refs.filter(f => f.name == util.format("refs/heads/%s", args.destinationBranch))
                if (destinationRef.length > 0) {
                    this.logger?.error("Destination branch already exists")
                    return matchingRepo;
                }

                let newRef = <GitRefUpdate> {};
                newRef.repositoryId = repo.id
                newRef.oldObjectId = sourceRef[0].objectId
                newRef.name = util.format("refs/heads/%s", args.destinationBranch)

                let newGitCommit = <GitCommitRef> {}
                newGitCommit.comment = "Add DevOps Pipeline"
                newGitCommit.changes = await this.getGitCommitChanges(args.destinationBranch, this.withoutRefsPrefix(repo.defaultBranch), ['validation', 'test', 'prod'])

                let gitPush = <GitPush> {}
                gitPush.refUpdates = [ newRef ]
                gitPush.commits = [ newGitCommit ]

                this.logger?.info(util.format('Pushing new branch %s',args.destinationBranch))
                await gitApi.createPush(gitPush, repo.id, project.name)
            }
        }

        if (!foundRepo && repositoryName?.length > 0 ) {
            this.logger?.info(util.format("Repo %s not found", repositoryName))
            this.logger?.info('Did you mean?')
            repos.forEach( repo => {
                if ( repo.name.startsWith(repositoryName[0]) ) {
                    this.logger?.info(repo.name)
                }
            });
        }

        return matchingRepo;
    }

    /**
     * 
     * @param args Set the default vlidation branch policy to a branch
     * @param repo The repository that the branch belongs to
     * @param connection The authentcated connection to the Azure DevOps WebApi
     */
    async setBranchPolicy(args: DevOpsBranchArguments, repo: GitRepository, connection: azdev.WebApi) : Promise<void> {
        let policyApi = await connection.getPolicyApi();
        if (policyApi == null) {
            return
        }

        let policyTypes = await policyApi.getPolicyTypes(args.projectName)
        let buildTypes = policyTypes.filter(p => { if (p.displayName == 'Build') { return true } })

        let buildApi = await connection.getBuildApi();
        let builds = await buildApi.getDefinitions(args.projectName)
        let buildMatch = builds.filter ( b => { if ( b.name == `deploy-validation-${args.destinationBranch}` ) { return true } } )

        if ( buildTypes.length > 0 )
        {
            let existingConfigurations = await policyApi.getPolicyConfigurations(args.projectName);
            let existingPolices = existingConfigurations.filter( (policy: PolicyConfiguration) => 
                {
                    if ( policy.settings.scope?.length == 1
                    && policy.settings.scope[0].refName == `ref/heads/${args.destinationBranch}`
                    && policy.settings.scope[0].repositorytId == repo.id
                    && policy.type.id == policyTypes[0].id ) {
                        return true
                    }
                })

            if ((existingPolices.length == 0) && (buildMatch.length > 0)) {
                let newPolicy = <PolicyConfiguration>{}
                newPolicy.settings = {}
                newPolicy.settings.buildDefinitionId = buildMatch[0].id
                newPolicy.settings.displayName = 'Build Validation'
                newPolicy.settings.filenamePatterens = [`/${args.destinationBranch}/*`]
                newPolicy.settings.manualQueueOnly = false
                newPolicy.settings.queueOnSourceUpdateOnly = false
                newPolicy.settings.validDuration = 0
                let repoRef = { refName: `refs/heads/${args.destinationBranch}`, matchKind: 'Exact',  repositoryId:  repo.id }
                newPolicy.settings.scope = [repoRef]
                newPolicy.type = buildTypes[0]
                newPolicy.isBlocking = true
                newPolicy.isEnabled = true
                newPolicy.isEnterpriseManaged = false

                this.logger?.info('Checking branch policy')
                await policyApi.createPolicyConfiguration(newPolicy, args.projectName)
            } else {
                this.logger?.info('Branch policy already created')
            }
        }
    }

    withoutRefsPrefix(refName: string): string
    {
        if (!refName.startsWith("refs/heads/"))
        {
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
    async createBuildForBranch(args: DevOpsBranchArguments, project: CoreInterfaces.TeamProject, repo: GitRepository, connection: azdev.WebApi) : Promise<void> {
        let buildClient = await connection.getBuildApi()

        let definitions = await buildClient.getDefinitions(project.name)

        let taskApi  = await connection.getTaskAgentApi()
        let defaultAgent : TaskAgentPool[] = []
        defaultAgent = (await taskApi?.getAgentPools())?.filter(a => a.name == "Default");

        let devOpsOrgUrl = Environment.getDevOpsOrgUrl(args, args.settings)
        let baseUrl = `$(devOpsOrgUrl}${args.projectName}`

        let defaultAgentPool = defaultAgent?.length > 0 ? defaultAgent[0] : undefined

        if (typeof args.settings["validation"] === "undefined") {
            let taskApi = await connection.getTaskAgentApi()
            let groups = await taskApi?.getVariableGroups(args.projectName, "global-variable-group")
            if (groups?.length == 1) {
                args.settings["validation"] = groups[0].variables["ValidationServiceConnection"]?.value
            }
        }

        await this.cloneBuildSettings(definitions, buildClient, project, repo, baseUrl, args, "validation", args.destinationBranch, false, defaultAgentPool);
        await this.cloneBuildSettings(definitions, buildClient, project, repo, baseUrl, args, "test", args.destinationBranch, false, defaultAgentPool);
        await this.cloneBuildSettings(definitions, buildClient, project, repo, baseUrl, args, "prod", args.destinationBranch, false, defaultAgentPool);
    }

    async cloneBuildSettings(pipelines: BuildInterfaces.BuildDefinitionReference[], client: IBuildApi, project: CoreInterfaces.TeamProject, repo: GitRepository, baseUrl: string, args: DevOpsBranchArguments, template: string, createInBranch: string, required: boolean, defaultPool: TaskAgentPool) : Promise<void> {

        let source = args.sourceBuildName
        let destination =args.destinationBranch

        var destinationBuildName = util.format("deploy-%s-%s", template, destination);
        var destinationBuilds = pipelines.filter(p => p.name == destinationBuildName);

        var sourceBuildName =  util.format("deploy-%s-%s", template, source);
        var sourceBuilds = pipelines.filter(p => p.name == sourceBuildName);

        let destinationBuild = destinationBuilds.length > 0 ? await client.getDefinition(destinationBuilds[0].project.name, destinationBuilds[0].id) : null
        let sourceBuild = sourceBuilds.length > 0 ? await client.getDefinition(sourceBuilds[0].project?.name, sourceBuilds[0].id) : null

        if (destinationBuild != null && sourceBuild != null) {
            let destinationKeys = Object.keys(destinationBuild.variables)
            let sourceKeys = Object.keys(sourceBuild.variables)
            if (destinationKeys.length==0 && sourceKeys.length >0) {
                destinationBuild.variables = sourceBuild.variables
                
                this.logger?.debug(util.format("Updating %s environment variables", destinationBuildName))
                await client.updateDefinition(destinationBuild, destinationBuild.project.name, destinationBuild.id)
                return;
            }
        }

        if (destinationBuild != null) {
            return;
        }

        let defaultSettings = false
        if ( sourceBuild == null ) {
            if ( required ) {
                throw Error(util.format("Source build %s not found, but required", sourceBuildName))
            } 

            this.logger?.debug(`Source build ${sourceBuildName} not found`)
            let possibles =  pipelines.filter(p => p.name?.startsWith(`deploy-${template}`))
            if ( possibles.length > 0 ) {
                sourceBuildName = possibles[0].name
                sourceBuild = possibles.length > 0 ? await client.getDefinition(possibles[0].project?.name, possibles[0].id) : null
                this.logger?.debug(`Selecting ${sourceBuildName} to copy settings from`)
            }

            if (sourceBuild == null) {
                defaultSettings = true
                this.logger?.debug(`Matching ${template} build not found, will apply default settings`)
                this.logger?.debug(`Applying default service connection. You will need to update settings with you environment teams`)
                sourceBuild = <BuildInterfaces.BuildDefinition>{};
                sourceBuild.repository = <BuildInterfaces.BuildRepository>{}
                sourceBuild.repository.id = repo.id
                sourceBuild.repository.name = repo.name
                sourceBuild.repository.url = repo.url
                sourceBuild.repository.type = 'TfsGit'
                let environmentName = ''
                let seviceConnection = ''

                let validationName = typeof (args.settings["validation"] === "string") ? args.settings["validation"] : "yourenviromenthere-validation"
                let testName = typeof (args.settings["test"] === "string") ? args.settings["test"] : "yourenviromenthere-test"
                let prodName = typeof (args.settings["prod"] === "string") ? args.settings["prod"] : "yourenviromenthere-prod"

                switch (template?.toLowerCase()) {
                    case "validation": {
                        environmentName = 'Validation'
                        seviceConnection = Environment.getEnvironmentUrl(validationName, args.settings)
                        break;
                    }
                    case "test": {
                        environmentName = 'Test'
                        seviceConnection = Environment.getEnvironmentUrl(testName, args.settings)
                        break;
                    }
                    case "prod": {
                        environmentName = 'Production'
                        seviceConnection = Environment.getEnvironmentUrl(prodName, args.settings)
                        break;
                    }
                }
                sourceBuild.variables = {
                    EnvironmentName: <BuildInterfaces.BuildDefinitionVariable>{},
                    ServiceConnection: <BuildInterfaces.BuildDefinitionVariable>{}
                }
                sourceBuild.variables.EnvironmentName.value = environmentName
                sourceBuild.variables.ServiceConnection.value = seviceConnection
            }
        }

        this.logger?.info(util.format("Creating new build %s", destinationBuildName));
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
        if (sourceBuild.queue != null) {
            newBuild.queue = sourceBuild.queue
        } else {
            newBuild.queue = <BuildInterfaces.BuildDefinitionReference> {
                 queue: defaultPool
            }
        }
        
        let result = await client.createDefinition(newBuild, project.name);

        if (defaultSettings && args.openDefaultPages) {
            await open(`${baseUrl}/_build/${result?.id}`)
        }
    }

    async getGitCommitChanges(destinationBranch: string, defaultBranch: string, names: string[]): Promise<GitChange[]> {
        let results : GitChange[] = []
        for ( let i = 0; i < names.length; i++ ) {
            let url = util.format("https://raw.githubusercontent.com/microsoft/coe-alm-accelerator-templates/main/Pipelines/build-deploy-%s-SampleSolution.yml", names[i]);
            
            let response = await this.getUrl(url)

            let commit = <GitChange>{}
            commit.changeType = VersionControlChangeType.Add
            commit.item = <GitItem>{}
            commit.item.path = util.format("/%s/deploy-%s-%s.yml", destinationBranch, names[i], destinationBranch)
            commit.newContent = <ItemContent>{}
            commit.newContent.content = (response)?.replace(/BranchContainingTheBuildTemplates/g, defaultBranch)
            commit.newContent.content = (commit.newContent.content)?.replace(/RepositoryContainingTheBuildTemplates/g, 'pipelines')
            commit.newContent.content = (commit.newContent.content)?.replace(/SampleSolutionName/g, destinationBranch)
            commit.newContent.contentType = ItemContentType.RawText

            results.push(commit)
        }
        return results;
    }
}

export { 
    DevOpsBranchArguments,
    DevOpsInstallArguments,
    DevOpsCommand,
    DevOpsExtension
};