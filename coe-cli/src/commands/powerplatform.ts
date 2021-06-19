"use strict";
import { v4 as uuidv4 } from 'uuid';
import axios, { AxiosResponse, AxiosStatic } from 'axios';
import fs from 'fs' 
import { CommandLineHelper } from '../common/cli'
import { AADAppInstallArguments, AADCommand } from './aad';
import * as winston from 'winston';
import { Environment } from '../common/enviroment';
import * as urlModule from 'url';

/**
 * Powerplatform Command Arguments
 */
class PowerPlatformImportSolutionArguments {
    constructor() {
        this.accessTokens = {}
        this.settings = {}
    }

    /**
     * The access token with rigts to connect to Power Platform environment
     */
    accessToken: string

    /**
    * Audiance scoped access tokens
    */
    accessTokens: { [id: string] : string }

    /**
     * The endpoint to connect to
     */
    endpoint: string

    /**
     * The name of the Power Platform Organization that the solution wil be imported into
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
     * Import method
     */
    importMethod: string

    /**
     * The Azure Active Directory Service principal to assign to the custom connector
     */
    azureActiveDirectoryServicePrincipal: string

    /**
     * Create a new secret for 
     */
    createSecret: boolean

    /**
    * Optional settings
    */
    settings:  { [id: string] : string }
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

/**
 * Powerplatform commands
 */
class PowerPlatformCommand {
    getBinaryUrl: (url: string) => Promise<Buffer>    
    getUrl: (url: string) => Promise<string>    
    getSecureJson: (url: string, accessToken: string) => Promise<any>    
    getAxios: () => AxiosStatic
    deleteIfExists: (name: string) => Promise<void>
    writeFile: (name: string, data: Buffer) =>Promise<void>
    cli: CommandLineHelper
    createAADCommand: () => AADCommand
    logger: winston.Logger
  
    constructor(logger: winston.Logger) {
        this.logger = logger
        
        this.getAxios = () => axios
        this.getBinaryUrl = async (url: string) => {
            return Buffer.from((await this.getAxios().get(url, { responseType: 'arraybuffer' })).data, 'binary')
        }
        this.getUrl = async (url: string) => (await this.getAxios().get<string>(url)).data
        this.getSecureJson = async (url: string, token: string) => (await this.getAxios().get<any>(url, { headers: {
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'appplication/json'
          }})).data
        this.deleteIfExists = async (name: string) => { 
            if ( fs.existsSync(name)) {
                await fs.promises.unlink(name)
            }
        }
        this.writeFile = async (name: string, data: Buffer) => fs.promises.writeFile(name, data, 'binary')
        this.cli = new CommandLineHelper
        this.createAADCommand = () => { return new AADCommand(this.logger) }
    }

    /**
     * Map endpoints to defined power platform endpoints
     * @param endpoint 
     * @returns 
     */
    mapEndpoint (type: string, endpoint: string) :string {
        switch ( type ) {
            case 'powerapps': {
                    switch ( endpoint ) {
                        case "prod": { return "https://api.powerapps.com/"}            
                        case "usgov":     { return "https://gov.api.powerapps.us/" }
                        case "usgovhigh": { return "https://high.api.powerapps.us/" }
                        case "dod":       { return "https://api.apps.appsplatform.us/" }
                        case "china":     { return "https://api.powerapps.cn/" }
                        case "preview":   { return "https://preview.api.powerapps.com/" }
                        case "tip1":      { return "https://tip1.api.powerapps.com/"}
                        case "tip2":      { return "https://tip2.api.powerapps.com/" }
                        default: { throw Error("Unsupported endpoint '${this.endpoint}'") }
                    }
                }
            case 'bap': {
                    switch ( endpoint ) {
                        case "prod": { return "https://api.bap.microsoft.com/"}            
                        case "usgov":     { return "https://gov.api.bap.microsoft.us/" }
                        case "usgovhigh": { return "https://high.api.bap.microsoft.us/" }
                        case "dod":       { return "https://api.bap.appsplatform.us/" }
                        case "china":     { return "https://api.bap.partner.microsoftonline.cn/" }
                        case "preview":   { return "https://preview.api.bap.microsoft.com/" }
                        case "tip1":      { return "https://tip1.api.bap.microsoft.com/"}
                        case "tip2":      { return "https://tip2.api.bap.microsoft.com/" }
                        default: { throw Error("Unsupported endpoint '${this.endpoint}'") }
                    }
                }
        }
    }

    /**
     * Import Solution action
     * @param args 
     * @returns 
     */
    async importSolution(args: PowerPlatformImportSolutionArguments): Promise<void> {
        switch ( args.importMethod ) {
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

    private async importViaBrowser(args: PowerPlatformImportSolutionArguments): Promise<void> {
        let base64CustomizationFile = (await this.getBinaryUrl(args.sourceLocation))

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
        let base64CustomizationFile = (await this.getBinaryUrl(args.sourceLocation))

        await this.deleteIfExists('release.zip')
        await this.writeFile('release.zip', base64CustomizationFile)

        await this.cli.runCommand('pac solution import --path release.zip', true)
    }

    /**
     * Import solution implementation using REST API
     * @param args 
     */
    private async importViaApi(args: PowerPlatformImportSolutionArguments): Promise<void> {
        let enviromentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)
        let solutions :any = await this.getSecureJson(`${enviromentUrl}api/data/v9.0/solutions?$filter=uniquename%20eq%20%27ALMAcceleratorforAdvancedMakers%27`, args.accessToken)

        if ( solutions.value.length == 0 )
        {
            let base64CustomizationFile = (await this.getBinaryUrl(args.sourceLocation)).toString('base64')

            let importData = {
                "OverwriteUnmanagedCustomizations": true,
                "PublishWorkflows": true,
                "CustomizationFile": `${base64CustomizationFile}`,
                "ImportJobId": uuidv4(),
                "HoldingSolution": false
            };
    
            this.logger?.info('Importing managed solution')
            await this.getAxios().post( `${enviromentUrl}api/data/v9.0/ImportSolution`, importData, {
                headers: {
                    'Content-Type': 'application/json', 
                    'Authorization': `Bearer ${args.accessToken}`
                }
            })
            solutions = await this.getSecureJson(`${enviromentUrl}api/data/v9.0/solutions?$filter=uniquename%20eq%20%27ALMAcceleratorforAdvancedMakers%27`, args.accessToken)
        } else {
            this.logger?.info('Solution already exists')
        }  

        if (!await this.cli.validateAzCliReady(args)) {
            return Promise.resolve()
        }

        await this.fixCustomConnectors(args)
        
        await this.fixConnectionReferences(solutions, args)

        await this.fixFlows(solutions, args)
    }

    async fixCustomConnectors(args: PowerPlatformImportSolutionArguments) : Promise<void> {
        this.logger?.info("Checking connectors")

        let environment = await this.getEnvironment(args)

        let enviromentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)
       
        let connectors = (await this.getSecureJson(`${enviromentUrl}api/data/v9.0/connectors`, args.accessToken)).value
        let connectorMatch = connectors?.filter( (c:any) => c.name.startsWith('cat_5Fcustomazuredevops') )

        if (connectorMatch.length == 1 ) {
            this.logger?.debug("Found connector")
            let aad = this.createAADCommand();
            let addInstallArgs = new AADAppInstallArguments();
            addInstallArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
            addInstallArgs.createSecret = args.createSecret
            addInstallArgs.accessTokens = args.accessTokens
            addInstallArgs.endpoint = args.endpoint

            let connectionParameters = JSON.parse(connectorMatch[0].connectionparameters)

            let clientid = aad.getAADApplication(addInstallArgs)
            if (connectionParameters.token.oAuthSettings.clientId != clientid) {
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
                    // Based on work of paconn update of 
                    // https://github.com/microsoft/PowerPlatformConnectors/blob/1b81ada7b083302b59c33d9ed6b14cb2ac8a0785/tools/paconn-cli/paconn/operations/upsert.py
                    let update = {
                        properties: {
                            connectionParameters: {
                                token: {
                                    oAuthSettings: {
                                        clientId: clientid,
                                        clientSecret: secret.clientSecret,
                                        customParameters: data.properties.connectionParameters.token.oAuthSettings.customParameters,
                                        identityProvider: data.properties.connectionParameters.token.oAuthSettings.identityProvider,
                                        redirectMode: data.properties.connectionParameters.token.oAuthSettings.redirectMode,
                                        scopes: data.properties.connectionParameters.token.oAuthSettings.scopes
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
                } catch (err) {
                    this.logger?.error(err)
                }
                
                this.logger?.info("Connnection updated")
                this.logger?.debug(updateConnection?.status)
            }
        }
    }

    async getEnvironment(args: PowerPlatformImportSolutionArguments) : Promise<string> {
        let bapUrl = this.mapEndpoint("bap", args.endpoint)
        let apiVersion = "2019-05-01"
        let accessToken = args.accessTokens[bapUrl]
        let results: AxiosResponse<any>
        try{
            // Reference
            // https://docs.microsoft.com/en-us/power-platform/admin/list-environments
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

        let match = results.data.value.filter((e: any) => e.properties?.linkedEnvironmentMetadata?.domainName.toLowerCase() == domainName.toLowerCase() )
        if ( match.length == 1 ) {
            this.logger?.debug('Found environment')
            return match[0].name
        } else {
            Promise.reject(`Environment ${domainName} not found`)
            return ""
        }
    }

    async fixConnectionReferences(solutions: any, args: PowerPlatformImportSolutionArguments): Promise<void> {
        this.logger?.info("Check connection reference")

        let enviromentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)

        let whoAmI = await this.getSecureJson(`${enviromentUrl}api/data/v9.0/WhoAmI`, args.accessToken)

        let aadInfo = (await this.getSecureJson(`${enviromentUrl}api/data/v9.0/systemusers?$filter=systemuserid eq '${whoAmI.UserId}'&$select=azureactivedirectoryobjectid`, args.accessToken))

        this.logger?.debug('Query environment connecctions')
        let environment = await this.getEnvironment(args)
        let powerAppsUrl = this.mapEndpoint("powerapps", args.endpoint)
        let bapUrl = this.mapEndpoint("bap", args.endpoint)
        let token = args.accessTokens[bapUrl]
        // Source: Microsoft.PowerApps.Administration.PowerShell.psm1
        let url = `${powerAppsUrl}providers/Microsoft.PowerApps/scopes/admin/environments/${environment}/connections?api-version=2016-11-01`
        let connectionResults = await this.getAxios().get(url, { headers: {
            Authorization: `Bearer ${token}`
        }})
        let connection = connectionResults.data.value.filter((c: any) => c.properties.createdBy?.id == aadInfo.value[0].azureactivedirectoryobjectid && c.properties.apiId?.split('apis/')[1] == 'shared_commondataservice')
       
        if (connection.length == 0) {
            this.logger?.error('No Microsoft Dataverse (Legacy Found). Please create and rerun setup')
            return Promise.resolve();
        } else {
            
            let connectionReferences = (await this.getSecureJson(`${enviromentUrl}api/data/v9.0/connectionreferences?$filter=solutionid eq '${solutions.value[0].solutionid}'`, args.accessToken)).value
            let connectionMatch = connectionReferences?.filter( (c:any) => c.connectionreferencelogicalname.startsWith('cat_CDSDevOps') )

            if (typeof connectionMatch === "undefined" || connectionMatch?.length == 0) {
                this.logger?.info('Dataverse Connection not found')
                return Promise.resolve();
            } else {
                this.logger?.info("Connection found")
                if (connectionMatch[0].connectionid == null) {
                    this.logger?.info("Connection id needs to be updated")
                    let update = {
                        "connectionid": `${connection[0].name}`
                    }
                     try{
                        await this.getAxios().patch(`${enviromentUrl}api/data/v9.0/connectionreferences(${connectionMatch[0].connectionreferenceid})`, update, { headers: {
                            'Authorization': 'Bearer ' + args.accessToken,
                            'Content-Type': 'application/json',
                            'OData-MaxVersion': '4.0',
                            'OData-Version': '4.0',
                            'If-Match': '*'  
                        }})
                        this.logger?.info("Connection reference updated")
                     } catch (err) {
                        this.logger?.error(err)
                     }
                } else {
                    this.logger?.debug("Connection already connected")
                }
            }
        }
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

        let enviromentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)

        let flows = (await this.getSecureJson(`${enviromentUrl}api/data/v9.0/workflows?$filter=solutionid eq '${solutions.value[0].solutionid}'`, args.accessToken))
        for ( let i = 0; i < flows.value?.length; i++ ) {
            let flow = flows.value[i]
            if (flow.statecode == 0 && flow.statuscode == 1) {
                let flowUpdate = {
                    statecode: 1,
                    statuscode: 2
                }
                this.logger?.debug(`Enabling flow ${flow.name}`)
                await this.getAxios().patch(`${enviromentUrl}api/data/v9.0/workflows(${flow.workflowid})`, flowUpdate, { headers: {
                            'Authorization': 'Bearer ' + args.accessToken,
                            'Content-Type': 'application/json',
                            'OData-MaxVersion': '4.0',
                            'OData-Version': '4.0',
                            'If-Match': '*'  
                        }})
                this.logger?.debug(`Patch complete for ${flow.name}`)
            }
        }
    }
}

export {
    PowerPlatformImportSolutionArguments,
    PowerPlatformConectorUpdate,
    PowerPlatformCommand
};
