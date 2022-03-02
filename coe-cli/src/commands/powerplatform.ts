"use strict";
import { v4 as uuidv4 } from 'uuid';
import axios, { AxiosResponse, AxiosStatic } from 'axios';
import fs from 'fs'
import { CommandLineHelper } from '../common/cli'
import { AADAppInstallArguments, AADCommand } from './aad';
import * as winston from 'winston';
import { Environment } from '../common/environment';
import * as urlModule from 'url';
import { ALMCommand, ALMUserArguments } from './alm';
import * as readline from 'readline';
import { ReadLineManagement } from '../common/readLineManagement'
import { Config } from '../common/config';

/**
 * Powerplatform commands
 */
class PowerPlatformCommand {

    getBinaryUrl: (url: string, authorization: string) => Promise<Buffer>
    getUrl: (url: string, authorization: string) => Promise<string>
    getSecureJson: (url: string, accessToken: string) => Promise<any>
    getAxios: () => AxiosStatic
    deleteIfExists: (name: string) => Promise<void>
    writeFile: (name: string, data: Buffer) => Promise<void>
    cli: CommandLineHelper
    createAADCommand: () => AADCommand
    createALMCommand: () => ALMCommand
    logger: winston.Logger
    readline: any
    outputText: (text: string) => void
    config: { [id: string]: any; } = {}

    constructor(logger: winston.Logger, defaultReadline: readline.ReadLine = null) {
        this.logger = logger

        this.getAxios = () => axios
        this.getBinaryUrl = async (url: string, authorization : string = null) => {
            let headers : {
                [id: string]: string;
            } = { 
                responseType: 'arraybuffer'
            }
            if ( authorization != null && authorization?.length > 0 ) {
                headers["Authorization"] = authorization
                headers["Accept"] = "application/octet-stream"
            }
            return Buffer.from((await this.getAxios().get(url, headers)).data, 'binary')
        }
        this.getUrl = async (url: string, authorization : string = null) => {
            let headers : {
                [id: string]: string;
            } = {            }
            if ( authorization != null) {
                headers["Authorization"] = authorization
            }
            return (await this.getAxios().get<string>(url, headers)).data
        }
        this.getSecureJson = async (url: string, token: string) => (await this.getAxios().get<any>(url, {
            headers: {
                'Authorization': 'Bearer ' + token,
                'Content-Type': 'appplication/json'
            }
        })).data
        this.deleteIfExists = async (name: string) => {
            if (fs.existsSync(name)) {
                await fs.promises.unlink(name)
            }
        }
        this.writeFile = async (name: string, data: Buffer) => fs.promises.writeFile(name, data, 'binary')
        this.cli = new CommandLineHelper
        this.createAADCommand = () => { return new AADCommand(this.logger) }
        this.createALMCommand = () => { return new ALMCommand(this.logger) }
        this.readline = defaultReadline
        this.outputText = (text: string) => console.log(text)
        this.config = Config.data
    }

    /**
      * Add an Azure Active Directoiry user as administrator
      * Read more https://docs.microsoft.com/en-us/powershell/module/microsoft.powerapps.administration.powershell/new-powerappmanagementapp
      * @param appId The application id to be added as administrator
      * @param args The additional arguments required to complete install 
      * @returns Promise
      */
    async addAdminUser(appId: string, args: PowerPlatformAdminSetupArguments): Promise<void> {
        let bapUrl = this.mapEndpoint("bap", args.endpoint)
        let apiVersion = "2020-06-01"
        let authService = Environment.getAuthenticationUrl(bapUrl)
        let accessToken = args.accessTokens[authService]
        let results: AxiosResponse<any>
        try {
            // Reference
            // Source: Microsoft.PowerApps.Administration.PowerShell
            results = await this.getAxios().put<any>(`${bapUrl}providers/Microsoft.BusinessAppPlatform/adminApplications/${appId}?api-version=${apiVersion}`, {}, {
                headers: {
                    "Authorization": `Bearer ${accessToken}`,
                    "Content-Type": "application/json"
                }
            })
            this.logger?.info("Added Admin Application for Azure Application")
        } catch (err) {
            this.logger?.info("Error adding Admin Application for Azure Application")
            this.logger?.error(err.response.data.error)
            return Promise.reject(err)
        }
    }
    /**
     * Import Solution action
     * @param args 
     * @returns 
     */
    async importSolution(args: PowerPlatformImportSolutionArguments): Promise<void> {
        switch (args.importMethod) {
            case 'api': {
                await this.importViaApi(args)
                break;
            }
            case 'pac': {
                await this.importViaPacCli(args)
                break;
            }
            default: {
                await this.importViaBrowser(args)
                break;
            }
        }
    }

 /**
 * Import solution implementation using REST API
 * @param args 
 */
    private async importViaApi(args: PowerPlatformImportSolutionArguments): Promise<void> {
        try {
            let environmentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)

            let almSolutionName = 'CenterofExcellenceALMAccelerator'
    
            let solutions: any = await this.getSecureJson(`${environmentUrl}api/data/v9.0/solutions?$filter=uniquename%20eq%20%27${almSolutionName}%27`, args.accessToken)
    
            if (solutions.value.length == 0 || this.config.upgrade == true) {
                let base64CustomizationFile : string = ""
                if ( args.sourceLocation?.startsWith("base64:"))
                {
                    base64CustomizationFile = args.sourceLocation.substring(7)
                } else {
                    base64CustomizationFile = (await fs.promises.readFile(args.sourceLocation, { encoding: 'base64' }))
                }
    
                let importData = {
                    "OverwriteUnmanagedCustomizations": true,
                    "PublishWorkflows": true,
                    "CustomizationFile": `${base64CustomizationFile}`,
                    "ImportJobId": uuidv4(),
                    "HoldingSolution": false
                };
    
                this.logger?.info('Importing managed solution')
                // https://docs.microsoft.com/dynamics365/customer-engagement/web-api/importsolution?view=dynamics-ce-odata-9
                await this.getAxios().post(`${environmentUrl}api/data/v9.0/ImportSolution`, importData, {
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${args.accessToken}`
                    }
                })
                
                // https://docs.microsoft.com/dynamics365/customer-engagement/web-api/solution?view=dynamics-ce-odata-9
                solutions = await this.getSecureJson(`${environmentUrl}api/data/v9.0/solutions?$filter=uniquename%20eq%20%27${almSolutionName}%27`, args.accessToken)
            } else {
                this.logger?.info('Solution already exists')
    
                // TODO: Check if new version is an upgrade
            }
    
            if (!await this.cli.validateAzCliReady(args)) {
                return Promise.resolve()
            }
    
            let environment = await this.getEnvironment(args)
    
            if (environment != null) {
                let solution: Solution = solutions.value[0]
    
                await this.fixCustomConnectors(environment.name, args)
    
                await this.fixConnectionReferences(environment.name, solutions, args)
    
                await this.fixFlows(solutions, args)
    
                await this.addApplicationUsersToEnvironments(args)
    
                if (args.setupPermissions) {
                    await this.shareMakerApplication(solution, environment.name, args)
                }
            }    
        } catch (ex) {
            this.logger.error(ex)
        }
    }

    private async importViaBrowser(args: PowerPlatformImportSolutionArguments): Promise<void> {
        let base64CustomizationFile = (await this.getBinaryUrl(args.sourceLocation, args.authorization))

        await this.deleteIfExists('release.zip')
        await this.writeFile('release.zip', base64CustomizationFile)

        this.logger?.info('Complete import in you browser. Steps')
        this.logger?.info('1. Open https://make.powerapps.com')
        this.logger?.info('2. Select environment you want to import solution into')
        this.logger?.info('3. Select Solutions')
        this.logger?.info('4. Select Import')
        this.logger?.info('5. Select Browse and select release.zip downloaded')
    }

    private async importViaPacCli(args: PowerPlatformImportSolutionArguments): Promise<void> {
        let base64CustomizationFile = (await this.getBinaryUrl(args.sourceLocation, args.authorization))

        await this.deleteIfExists('release.zip')
        await this.writeFile('release.zip', base64CustomizationFile)

        await this.cli.runCommand('pac solution import --path release.zip', true)
    }





    /**
 * Map endpoints to defined power platform endpoints
 * @param endpoint 
 * @returns 
 */
    mapEndpoint(type: string, endpoint: string): string {
        switch (type) {
            case 'powerapps': {
                switch (endpoint) {
                    case "prod": { return "https://api.powerapps.com/" }
                    case "usgov": { return "https://gov.api.powerapps.us/" }
                    case "usgovhigh": { return "https://high.api.powerapps.us/" }
                    case "dod": { return "https://api.apps.appsplatform.us/" }
                    case "china": { return "https://api.powerapps.cn/" }
                    case "preview": { return "https://preview.api.powerapps.com/" }
                    case "tip1": { return "https://tip1.api.powerapps.com/" }
                    case "tip2": { return "https://tip2.api.powerapps.com/" }
                    default: { throw Error("Unsupported endpoint '${this.endpoint}'") }
                }
            }
            case 'bap': {
                switch (endpoint) {
                    case "prod": { return "https://api.bap.microsoft.com/" }
                    case "usgov": { return "https://gov.api.bap.microsoft.us/" }
                    case "usgovhigh": { return "https://high.api.bap.microsoft.us/" }
                    case "dod": { return "https://api.bap.appsplatform.us/" }
                    case "china": { return "https://api.bap.partner.microsoftonline.cn/" }
                    case "preview": { return "https://preview.api.bap.microsoft.com/" }
                    case "tip1": { return "https://tip1.api.bap.microsoft.com/" }
                    case "tip2": { return "https://tip2.api.bap.microsoft.com/" }
                    default: { throw Error("Unsupported endpoint '${this.endpoint}'") }
                }
            }
        }
    }


    async fixCustomConnectors(environment: string, args: PowerPlatformImportSolutionArguments): Promise<void> {
        this.logger?.info("Checking connectors")

        let environmentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)

        let connectors = (await this.getSecureJson(`${environmentUrl}api/data/v9.0/connectors`, args.accessToken)).value
        let connectorMatch = connectors?.filter((c: any) => c.name.startsWith('cat_5Fcustomazuredevops'))

        if (connectorMatch?.length == 1) {
            this.logger?.debug("Found connector")
            let aad = this.createAADCommand();
            let addInstallArgs = new AADAppInstallArguments();
            addInstallArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
            addInstallArgs.azureActiveDirectoryMakersGroup = args.azureActiveDirectoryMakersGroup
            addInstallArgs.createSecret = args.createSecret
            addInstallArgs.accessTokens = args.accessTokens
            addInstallArgs.endpoint = args.endpoint

            let clientid = aad.getAADApplication(addInstallArgs)

            if (typeof connectorMatch[0].connectionparameters === "undefined" || connectorMatch[0].connectionparameters?.length == 0 || connectorMatch[0].connectionparameters == "{}" ) {
                this.logger?.info("Applying default connection information")
                connectorMatch[0].connectionparameters = JSON.stringify({
                    "token": {
                        "type": "oauthSetting",
                        "oAuthSettings": {
                            "identityProvider": "aad",
                            "clientId": "UPDATE",
                            "scopes": [],
                            "redirectMode": "Global",
                            "redirectUrl": "https://global.consent.azure-apim.net/redirect",
                            "properties": {
                                "IsFirstParty": "False",
                                "AzureActiveDirectoryResourceId": "499b84ac-1321-427f-aa17-267ca6975798",
                                "IsOnbehalfofLoginSupported": true
                            },
                            "customParameters": {
                                "loginUri": {
                                    "value": "https://login.windows.net"
                                },
                                "tenantId": {
                                    "value": "common"
                                },
                                "resourceUri": {
                                    "value": "499b84ac-1321-427f-aa17-267ca6975798"
                                },
                                "enableOnbehalfOfLogin": {
                                    "value": "false"
                                }
                            }
                        }
                    },
                    "token:TenantId": {
                        "type": "string",
                        "metadata": {
                            "sourceType": "AzureActiveDirectoryTenant"
                        },
                        "uiDefinition": {
                            "constraints": {
                                "required": "false",
                                "hidden": "true"
                            }
                        }
                    }
                })
            }

            let connectionParameters = JSON.parse(connectorMatch[0].connectionparameters)
            
            if (typeof connectionParameters.token != undefined && connectionParameters.token.oAuthSettings.clientId != clientid || connectionParameters.token.oAuthSettings.properties.AzureActiveDirectoryResourceId != "499b84ac-1321-427f-aa17-267ca6975798") {
                this.logger?.debug("Connector needs update")
                let powerAppsUrl = this.mapEndpoint("powerapps", args.endpoint)
                let bapUrl = this.mapEndpoint("bap", args.endpoint)
                let token = args.accessTokens[bapUrl]
                let connectorName = connectorMatch[0].connectorinternalid

                // Based on work of paconn update (see below)
                let url = `${powerAppsUrl}providers/Microsoft.PowerApps/apis/${connectorName}/?$filter=environment eq '${environment}'&api-version=2016-11-01`
                let secret = await aad.addSecret(addInstallArgs, "Custom")

                let getConnection: AxiosResponse<any>
                try {
                    getConnection = await this.getAxios().get(url, {
                        headers: {
                            "Authorization": `Bearer ${token}`,
                            "Content-Type": "application/json"
                        }
                    })
                } catch (err) {
                    this.logger?.error(err)
                }

                let data = getConnection.data

                // Fetch the existing swagger to pass to open api specification below
                let original = await this.getAxios().get(data.properties.apiDefinitions.originalSwaggerUrl)

                url = `${powerAppsUrl}providers/Microsoft.PowerApps/apis/${connectorName}/?$filter=environment eq '${environment}'&api-version=2016-11-01`
                let updateConnection: AxiosResponse<any>
                try {
                    if ( typeof connectionParameters.token != "undefined" )
                    {
                        // Based on work of paconn update of 
                        // https://github.com/microsoft/PowerPlatformConnectors/blob/1b81ada7b083302b59c33d9ed6b14cb2ac8a0785/tools/paconn-cli/paconn/operations/upsert.py

                        if (typeof connectionParameters.token.oAuthSettings.customParameters !== "undefined") {
                            connectionParameters.token.oAuthSettings.customParameters.resourceUri.value = "499b84ac-1321-427f-aa17-267ca6975798"
                        }
                        
                        if (typeof connectionParameters.token.oAuthSettings.properties !== "undefined") {
                            connectionParameters.token.oAuthSettings.properties.AzureActiveDirectoryResourceId = "499b84ac-1321-427f-aa17-267ca6975798"
                        }

                        let update = {
                            properties: {
                                connectionParameters: {
                                    token: {
                                        oAuthSettings: {
                                            clientId: clientid,
                                            clientSecret: secret.clientSecret,
                                            properties: connectionParameters.token.oAuthSettings.properties,
                                            customParameters: connectionParameters.token.oAuthSettings.customParameters,
                                            identityProvider: connectionParameters.token.oAuthSettings.identityProvider,
                                            redirectMode: connectionParameters.token.oAuthSettings.redirectMode,
                                            scopes: connectionParameters.token.oAuthSettings.scopes
                                        },
                                        type: "oAuthSetting"
                                    }
                                },
                                backendService: data.properties.backendService,
                                environment: { name: environment },
                                description: data.properties.description,
                                openApiDefinition: original.data,
                                policyTemplateInstances: data.properties.policyTemplateInstances
                            }

                        }
                        updateConnection = await this.getAxios().patch(url, update, {
                            headers: {
                                "Authorization": `Bearer ${token}`,
                                "Content-Type": "application/json;charset=UTF-8"
                            }
                        })
                    }
                } catch (err) {
                    this.logger?.error(err)
                }

                this.logger?.info("Connnection updated")
                this.logger?.debug(updateConnection?.status)
            }
        }
    }

    async getEnvironment(args: PowerPlatformImportSolutionArguments): Promise<PowerPlatformEnvironment> {
        let bapUrl = this.mapEndpoint("bap", args.endpoint)
        let apiVersion = "2019-05-01"
        let accessToken = args.accessTokens[bapUrl]
        let results: AxiosResponse<any>
        try {
            // Reference
            // https://docs.microsoft.com/power-platform/admin/list-environments
            results = await this.getAxios().get<any>(`${bapUrl}providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?api-version=${apiVersion}`, {
                headers: {
                    "Authorization": `Bearer ${accessToken}`,
                    "Content-Type": "application/json"
                }
            })
        } catch (err) {
            this.logger?.error(err.response.data.error)
            throw err
        }

        this.logger?.debug('Searching for environment')
        let domainName = args.environment
        try {
            let domainUrl = new urlModule.URL(domainName)
            domainName = domainUrl.hostname.split(".")[0]
        } catch {

        }

        let environments = <PowerPlatformEnvironment[]>results.data.value

        let match = environments.filter((e: PowerPlatformEnvironment) => e.properties?.linkedEnvironmentMetadata?.domainName.toLowerCase() == domainName.toLowerCase())
        if (match.length == 1) {
            this.logger?.debug('Found environment')
            return match[0]
        } else {
            Promise.reject(`Environment ${domainName} not found`)
            return null
        }
    }

    async fixConnectionReferences(environment: string, solutions: any, args: PowerPlatformImportSolutionArguments): Promise<void> {
        if ( typeof solutions == undefined || typeof solutions.value == undefined || solutions.value.length <= 0 ) {
            this.logger?.error("No solution found")
            return
        }

        this.logger?.info("Check connection reference")

        let environmentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)

        let whoAmI = await this.getSecureJson(`${environmentUrl}api/data/v9.0/WhoAmI`, args.accessToken)

        let aadInfo = (await this.getSecureJson(`${environmentUrl}api/data/v9.0/systemusers?$filter=systemuserid eq '${whoAmI.UserId}'&$select=azureactivedirectoryobjectid`, args.accessToken))

        let solutionComponentTypes = (await this.getSecureJson(`${environmentUrl}api/data/v9.0/solutioncomponentdefinitions?$filter=primaryentityname eq 'connectionreference'`, args.accessToken))

        let solutionComponentType = solutionComponentTypes.value[0].solutioncomponenttype

        let connectionReferenceSolutionComponents = (await this.getSecureJson(`${environmentUrl}api/data/v9.0/solutioncomponents?$orderby=componenttype&$filter=_solutionid_value eq '${solutions.value[0].solutionid}' and componenttype eq ${solutionComponentType}`, args.accessToken))

        this.logger?.debug('Query environment connections')
        let powerAppsUrl = this.mapEndpoint("powerapps", args.endpoint)
        let bapUrl = this.mapEndpoint("bap", args.endpoint)
        let token = args.accessTokens[bapUrl]
        
        // Source: Microsoft.PowerApps.Administration.PowerShell.psm1
        let url = `${powerAppsUrl}providers/Microsoft.PowerApps/scopes/admin/environments/${environment}/connections?api-version=2016-11-01`

        let stopped = false
        let connected : string[] = []
        let connection: any = null
        while ( !stopped ) {
            for ( var i = 0; i < connectionReferenceSolutionComponents.value.length; i++)
            {
                let connectionReferenceId = connectionReferenceSolutionComponents.value[i].objectid

                if ( connected.indexOf(connectionReferenceId) >= 0) {
                    if ( connected.length == connectionReferenceSolutionComponents.value.length ) {
                        stopped = true
                        break
                    }
                    continue
                }

                let connectionReferenceUrl = `${environmentUrl}api/data/v9.0/connectionreferences?$filter=connectionreferenceid eq '${connectionReferenceId}'`
                let connectionReferences = (await this.getSecureJson(connectionReferenceUrl, args.accessToken)).value
    
                let unconnectedConnectionReferences = connectionReferences.filter((con: any) => con.connectionid == null)
                let connectedConnectionReferences = connectionReferences.filter((con: any) => con.connectionid != null)

                if ( connectedConnectionReferences.length == 1 ) {
                    let connectionResults = await this.getAxios().get(url, {
                        headers: {
                            Authorization: `Bearer ${token}`
                        }
                    })
                    
                    connection = connectionResults.data.value.filter((c: any) => c.name == connectedConnectionReferences[0].connectionid)
               
                    if ( connection.length == 1 ) {
                        connected.push(connectionReferenceId)
                        continue
                    }
                }
    
                let connectionTypeParts = unconnectedConnectionReferences[0]?.connectorid?.split('/')
                let connectionType = unconnectedConnectionReferences.length > 0 && typeof connectionTypeParts !== "undefined" ? connectionTypeParts[connectionTypeParts.length - 1] : ""

                if ( connectionType == '' && connectedConnectionReferences.length > 0 ) {
                    connectionTypeParts = connectedConnectionReferences[0]?.connectorid?.split('/')
                    connectionType = connectedConnectionReferences.length > 0 && typeof connectionTypeParts !== "undefined" ? connectionTypeParts[connectionTypeParts.length - 1] : ""
                }

                
                let connectionResults = await this.getAxios().get(url, {
                    headers: {
                        Authorization: `Bearer ${token}`
                    }
                })
                
                connection = connectionResults.data.value.filter((c: any) => c.properties.createdBy?.id == aadInfo.value[0].azureactivedirectoryobjectid && c.properties.apiId?.endsWith(`/${connectionType}`))
                
                if ( connection.length == 0 )
                {
                    if ( unconnectedConnectionReferences.length > 0 ) {
                        this.logger?.error(`Missing '${unconnectedConnectionReferences[0].connectionreferencedisplayname}' connection reference`)
                    }
                    
                    this.readline = ReadLineManagement.setupReadLine(this.readline)
                    let result = await new Promise((resolve, reject) => {
                        this.readline.question("Create connection now (Y/n)? ", (answer: string) => {
                            if ( answer.length == 0 || answer.toLowerCase() == 'y') {
                                resolve('y')
                            } else {
                                resolve('n')
                            }
                        })
                    })
                    if (result == 'y') {
                        this.outputText(`Create a connection by opening page https://make.powerapps.com/environments/${environment}/connections/available?apiName=${connectionType} in your browser`)
                        result = await new Promise((resolve, reject) => {
                            this.readline.question("Check again now (Y/n)? ", (answer: string) => {
                                if ( answer.length == 0 || answer.toLowerCase() == 'y') {
                                    resolve('y')
                                } else {
                                    resolve('n')
                                }
                            })
                        })                    
                    }
                    if (result == 'n') {
                        this.logger?.info("Exiting install")
                        stopped = true
                        return Promise.resolve();
                    }
        
                    connectionResults = await this.getAxios().get(url, {
                        headers: {
                            Authorization: `Bearer ${token}`
                        }
                    })
                }
                
                connection = connectionResults.data.value.filter((c: any) => c.properties.createdBy?.id == aadInfo.value[0].azureactivedirectoryobjectid && c.properties.apiId?.endsWith(`/${connectionType}`))
    
                if ( connection.length > 0 )
                {
                    try {
                        let update = {
                            "connectionid": `${connection[0].name}`
                        }
        
                        await this.getAxios().patch(`${environmentUrl}api/data/v9.0/connectionreferences(${unconnectedConnectionReferences[0].connectionreferenceid})`, update, {
                            headers: {
                                'Authorization': 'Bearer ' + args.accessToken,
                                'Content-Type': 'application/json',
                                'OData-MaxVersion': '4.0',
                                'OData-Version': '4.0',
                                'If-Match': '*'
                            }
                        })
                        this.logger?.info("Connection reference updated")
    
                        connected.push(connectionReferenceId)
                    } catch (err) {
                        this.logger?.error(err)
                    }
                }
            }
        }

        this.readline?.close()
        this.readline = null
    }

    /**
     * Start any closed flows for the solution
     * @param solutions 
     * @param args 
     */
    async fixFlows(solutions: any, args: PowerPlatformImportSolutionArguments): Promise<void> {
        this.logger?.info("Checking flow enabled")

        if (typeof solutions === "undefined" || solutions.value.length == 0) {
            this.logger?.info("Unable to update flow, solution not found")
            return Promise.resolve()
        }

        let environmentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)

        let flows = (await this.getSecureJson(`${environmentUrl}api/data/v9.0/workflows?$filter=solutionid eq '${solutions.value[0].solutionid}'`, args.accessToken))
        for (let i = 0; i < flows.value?.length; i++) {
            let flow = flows.value[i]
            if (flow.statecode == 0 && flow.statuscode == 1) {
                let flowUpdate = {
                    statecode: 1,
                    statuscode: 2
                }
                this.logger?.debug(`Enabling flow ${flow.name}`)
                await this.getAxios().patch(`${environmentUrl}api/data/v9.0/workflows(${flow.workflowid})`, flowUpdate, {
                    headers: {
                        'Authorization': 'Bearer ' + args.accessToken,
                        'Content-Type': 'application/json',
                        'OData-MaxVersion': '4.0',
                        'OData-Version': '4.0',
                        'If-Match': '*'
                    }
                })
                this.logger?.debug(`Patch complete for ${flow.name}`)
            }
        }
    }

    async addApplicationUsersToEnvironments(args: PowerPlatformImportSolutionArguments) {
        let environments: string[] = []
        if (Array.isArray(args.settings["installEnvironments"])) {
            for (var i = 0; i < args.settings["installEnvironments"].length; i++) {
                let environmentName = args.settings["installEnvironments"][i]
                if (typeof args.settings[environmentName] === "string" && environments.filter((e: string) => e == args.settings[environmentName]).length == 0) {
                    environments.push(args.settings[environmentName])
                }
            }
        }

        let alm = this.createALMCommand()
        let almArgs = new ALMUserArguments()

        for (var i = 0; i < environments.length; i++) {
            almArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
            almArgs.environment = environments[i]
            await alm.addUser(almArgs)
        }
    }

    async shareMakerApplication(solution: Solution, environment: string, args: PowerPlatformImportSolutionArguments): Promise<void> {
        let environmentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)

        let powerAppsUrl = this.mapEndpoint("powerapps", args.endpoint)
        let bapUrl = this.mapEndpoint("bap", args.endpoint)
        let accessToken = args.accessTokens[bapUrl]

        let config = {
            headers: {
                'Authorization': 'Bearer ' + args.accessToken,
                'Content-Type': 'application/json',
                'OData-MaxVersion': '4.0',
                'OData-Version': '4.0',
                'If-Match': '*'
            }
        }

        let powerAppsConfig = {
            headers: {
                'Authorization': 'Bearer ' + accessToken,
                'Content-Type': 'application/json',
                'OData-MaxVersion': '4.0',
                'OData-Version': '4.0',
                'If-Match': '*'
            }
        }

        let command = this.createAADCommand();
        let aadGroupId = command.getAADGroup(args)

        this.logger?.debug("Searching for solution components")
        // https://docs.microsoft.com/dynamics365/customerengagement/on-premises/developer/entities/msdyn_solutioncomponentsummary?view=op-9-1
        let componentQuery = await this.getAxios().get(`${environmentUrl}api/data/v9.0/msdyn_solutioncomponentsummaries?%24filter=(msdyn_solutionid%20eq%20${solution.solutionid})&api-version=9.1`, config)

        let components = <Component[]>componentQuery.data.value
        this.logger?.verbose(components)

        let makeCanvasApp = "ALM Accelerator for Power Platform"
        let componentMatch = components.filter((c: Component) => { return c.msdyn_displayname == makeCanvasApp })

        if (componentMatch.length == 1) {
            let appName = componentMatch[0].msdyn_objectid

            this.logger?.debug("Searching for permissions")
            let url = `${powerAppsUrl}providers/Microsoft.PowerApps/apps/${appName}/permissions?$expand=permissions($filter=environment eq '${environment}')&api-version=2020-06-01`
            let permssionsRequest = await this.getAxios().get(url, powerAppsConfig)
            let permissions = <ComponentPermissions[]>permssionsRequest.data.value

            if (permissions.filter((p: ComponentPermissions) => { return p.properties.principal.displayName == args.azureActiveDirectoryMakersGroup }).length == 0) {



                let apiInvokeConfig = {
                    headers: {
                        'Authorization': 'Bearer ' + accessToken,
                        'Content-Type': 'application/json',
                        'x-ms-path-query': `/providers/Microsoft.PowerApps/apps/${appName}/modifyPermissions?$filter=environment eq '${environment}'&api-version=2020-06-01`
                    }
                }

                this.logger?.info(`Adding CanView permissions for group ${args.azureActiveDirectoryMakersGroup}`)
                url = `${powerAppsUrl}api/invoke`
                let response = await this.getAxios().post(url, {
                    put: [{
                        properties: {
                            roleName: "CanView",
                            principal: {
                                email: args.azureActiveDirectoryMakersGroup,
                                id: aadGroupId,
                                "type": "Group", "tenantId": null
                            }, "NotifyShareTargetOption": "DoNotNotify"
                        }
                    }]
                }, apiInvokeConfig)
                this.logger?.verbose(response.data)
            }
        } else {
            this.logger?.error(`Unable to find ${makeCanvasApp}`)
        }

        this.logger?.info(`Checking ${args.azureActiveDirectoryMakersGroup} permissions`)
        await this.assignRoleToAADGroup(args.azureActiveDirectoryMakersGroup, aadGroupId, 'ALM Power App Access', environmentUrl, config)
    }

    async assignRoleToAADGroup(aadGroupName: string, aadGroupId: string, roleName: string, environmentUrl: string, config: { headers: { Authorization: string; 'Content-Type': string; 'OData-MaxVersion': string; 'OData-Version': string; 'If-Match': string; }; }) {

        this.logger?.info(`Checking if role ${roleName} exists`)
        let roleQuery = await this.getAxios().get(`${environmentUrl}api/data/v9.0/roles?$filter=name eq '${roleName}'`, config)
        if (roleQuery.data.value?.length == 1) {
            this.logger?.info("Role found")
            let roleId = roleQuery.data.value[0].roleid

            this.logger?.info(`Searching for assigned roles for ${aadGroupName}`)
            let aadPermissionsQuery = await this.getAxios().get(`${environmentUrl}api/data/v9.0/teams(azureactivedirectoryobjectid=${aadGroupId},membershiptype=0)/teamroles_association/$ref`, config)
            let match = aadPermissionsQuery.data.value?.filter((r: any) => (r['@odata.id'].indexOf(roleId) >= 0))
            if (match.length == 0) {
                this.logger?.info("Role not yet assigned, adding role")
                let aadPermissionsUpdate = await this.getAxios().post(`${environmentUrl}api/data/v9.0/teams(azureactivedirectoryobjectid=${aadGroupId},membershiptype=0)/teamroles_association/$ref`, {
                    "@odata.id": `${environmentUrl}api/data/v9.0/roles(${roleId})`
                }, config)

                if (aadPermissionsUpdate.status == 200 || aadPermissionsUpdate.status == 204) {
                    this.logger?.info(`Assigned ${aadGroupName} to ALM Power App Access role`)
                }
            }
        } else {
            this.logger.error("Security Role ALM Power App Access not found")
        }
    }
}

type ComponentPermissionsProperty = {
    roleName: string,
    principal: PowerPlatformIdentity
    scope: string
    notifyShareTargetOption: string
    inviteGuestToTenant: boolean
}

type ComponentPermissions = {
    name: string
    id: string
    type: string
    properties: ComponentPermissionsProperty
}

type Solution = {
    /**
    * Date and time when the solution was created.
    */
    createdon: string

    /**
     * Description of the solution.
     */
    description: string

    /**
     * User display name for the solution.
     */
    friendlyname: string

    /**
     * Date and time when the solution was installed/upgraded.
     */
    installedon: string

    /**
     * Information about whether the solution is api managed.
     */
    isapimanaged: boolean

    /**
     * Indicates whether the solution is managed or unmanaged.
     */
    ismanaged: boolean

    /**
     * Indicates whether the solution is visible outside of the platform.
     */
    isvisible: boolean

    /**
     * Date and time when the solution was last modified.
     */
    modifiedon: string

    /**
     * Read Only
     */
    pinpointassetid: string

    /**
     * Identifier of the publisher of this solution in Microsoft Pinpoint.
     */
    pinpointpublisherid: string

    /**
     * Default locale of the solution in Microsoft Pinpoint.
     */
    pinpointsolutiondefaultlocale: string


    /**
     * Identifier of the solution in Microsoft Pinpoint.
     */
    pinpointsolutionid: number

    /**
     * Unique identifier of the solution.
     */
    solutionid: string

    /**
     * Solution package source organization version
     */
    solutionpackageversion: string

    /**
     * Solution Type
     */
    solutiontype: number

    /**
     * The template suffix of this solution
     */
    templatesuffix: string

    /**
     * thumbprint of the solution signature
     */
    thumbprint: string

    /**
     * The unique name of this solution
     */
    uniquename: string


    /**
     * Date and time when the solution was updated.
     */
    updatedon: string

    /**
     * Contains component info for the solution upgrade operation
     */
    upgradeinfo: string

    versionnumber: number
}

type Component = {
    msdyn_name: string
    msdyn_modifiedon: string
    msdyn_createdon: string
    msdyn_iscustomizable: string
    msdyn_iscustomizablename: string
    msdyn_solutionid: string
    msdyn_ismanaged: string
    msdyn_ismanagedname: string
    organizationid: string
    msdyn_displayname: string
    msdyn_objecttypecode: string
    msdyn_objectid: string
    msdyn_description: string
    msdyn_componenttype: string
    msdyn_componenttypename: string
    msdyn_componentlogicalname: string
    msdyn_primaryidattribute: string
    msdyn_total: string
    msdyn_executionorder: string
    msdyn_isolationmode: string
    msdyn_sdkmessagename: string
    msdyn_connectorinternalid: string
    msdyn_isappaware: string
    msdyn_iscustom: string
    msdyn_synctoexternalsearchindex: string
    msdyn_logicalcollectionname: string
    msdyn_canvasappuniqueid: string
    msdyn_solutioncomponentsummaryid: string
    msdyn_deployment: string
    msdyn_executionstage: string
    msdyn_owner: string
    msdyn_fieldsecurity: string
    msdyn_typename: string
    msdyn_eventhandler: string
    msdyn_statusname: string
    msdyn_isdefault: string
    msdyn_publickeytoken: string
    msdyn_iscustomname: string
    msdyn_workflowcategoryname: string
    msdyn_subtype: string
    msdyn_owningbusinessunit: string
    msdyn_workflowcategory: string
    msdyn_isauditenabledname: string
    msdyn_isdefaultname: string
    msdyn_isappawarename: string
    msdyn_istableenabled: string
    msdyn_fieldtype: string
    msdyn_relatedentity: string
    msdyn_schemaname: string
    msdyn_version: string
    msdyn_uniquename: string
    msdyn_status: string
    msdyn_relatedentityattribute: string
    msdyn_workflowidunique: string
    msdyn_isauditenabled: string
    msdyn_primaryentityname: string
    msdyn_culture: string
}

type PowerPlatformIdentity = {
    id: string
    displayName: string
    type: string
    tenantId: string
}

type EnvironmentCapacity = {
    capacityType: string
    actualConsumption: number
    ratedConsumption: number
    capacityUnit: string
    updatedOn: string
}

type EnvironmentAddon = {
    addonType: string
    allocated: number
    addonUnit: string
}

type EnvironmentProperties = {
    azureRegion: string
    displayName: string
    description: string
    createdTime: string
    createdBy: PowerPlatformIdentity
    lastModifiedTime: string
    provisioningState: string
    creationType: string
    environmentSku: string
    isDefault: string,
    capacity: EnvironmentCapacity[]
    addons: EnvironmentAddon[]
    clientUris: { [id: string]: string }
    runtimeEndpoints: { [id: string]: string }
    databaseType: string
    linkedEnvironmentMetadata: { [id: string]: any }
    notificationMetadata: { [id: string]: string }
    retentionPeriod: string
}

type PowerPlatformEnvironment = {
    id: string
    type: string
    location: string
    name: string
    properties: EnvironmentProperties
}


/**
 * Powerplatform Command Arguments
 */
class PowerPlatformImportSolutionArguments {

    constructor() {
        this.accessTokens = {}
        this.settings = {}
        this.setupPermissions = true
    }

    /**
     * The access token with rigts to connect to Power Platform environment
     */
    accessToken: string

    /**
    * Audiance scoped access tokens
    */
    accessTokens: { [id: string]: string }

    /**
     * The endpoint to connect to
     */
    endpoint: string

    /**
     * The name of the Power Platform Organization that the solution will be imported into
     */
    organizationName: string

    /**
     * The Power Platform environment that the solution wil be imported into
     */
    environment: string

    /**
     * The source location to retrieve the unmanaged solution from
     */
    sourceLocation: string

    /**
     * The optional authorization header for the source location
     */
    authorization: string

    /**
     * Import method
     */
    importMethod: string

    /**
     * The Azure Active Directory Service principal to assign to the custom connector
     */
    azureActiveDirectoryServicePrincipal: string

    /**
     * The azure active directory makers group
     */
    azureActiveDirectoryMakersGroup: string

    /**
     * Create a new secret for 
     */
    createSecret: boolean

    /**
    * Optional settings
    */
    settings: { [id: string]: string }

    /**
     * Check if permissions should be configured
     */
    setupPermissions: boolean;
}

class PowerPlatformConectorUpdate {
    /**
    * The name of the Azure Account
    */
    account: string

    /**
     * Azure Active directory application name
     */
    azureActiveDirectoryServicePrincipal: string

    /**
    * The Power Platform environment that the solution wil be imported into
    */
    environment: string

    /**
    * The Power Platform environment that the solution wil be imported into
    */
    solution: string
}

type PowerPlatformConnection = {
    name: string
    id: string
}

interface PowerPlatformAdminSetupArguments {
    endpoint: string

    /**
    * Audiance scoped access tokens
    */
    accessTokens: { [id: string]: string }
}

export {
    PowerPlatformImportSolutionArguments,
    PowerPlatformConectorUpdate,
    PowerPlatformCommand,
    PowerPlatformEnvironment,
    Solution,
    Component,
    ComponentPermissions
};
