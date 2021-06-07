"use strict";
import { v4 as uuidv4 } from 'uuid';
import axios, { AxiosStatic } from 'axios';
import fs from 'fs' 
import path from 'path' 
import { CommandLineHelper } from '../common/cli'

/**
 * Powerplatform Command Arguments
 */
class PowerPlatformImportSolutionArguments {
    /**
     * The access token with rigts to connect to Power Platform environment
     */
    accessToken: string

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
  
    constructor() {
        this.getAxios = () => axios
        this.getBinaryUrl = async (url: string) => {
            return Buffer.from((await axios.get(url, { responseType: 'arraybuffer' })).data, 'binary')
        }
        this.getUrl = async (url: string) => (await axios.get<string>(url)).data
        this.getSecureJson = async (url: string, token: string) => (await axios.get<string>(url, { headers: {
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
            }
            case 'pac': {
                await this.importViaPacCli(args)
            }
            default: {
                await this.importViaBrowser(args)
            }
        }
    }

    private async importViaBrowser(args: PowerPlatformImportSolutionArguments): Promise<void> {
        let base64CustomizationFile = (await this.getBinaryUrl(args.sourceLocation))

        await this.deleteIfExists('release.zip')
        await this.writeFile('release.zip', base64CustomizationFile)

        console.log('Complete import in you browser. Steps')
        console.log('1. Open https://make.powerapps.com')
        console.log('2. Select environment you want to import solution into')
        console.log('3. Select Solutions')
        console.log('4. Select Import')
        console.log('5. Select Browse and select release.zip downloaded')
    }

    private async importViaPacCli(args: PowerPlatformImportSolutionArguments): Promise<void> {
        let base64CustomizationFile = (await this.getBinaryUrl(args.sourceLocation))

        await this.deleteIfExists('release.zip')
        await this.writeFile('release.zip', base64CustomizationFile)

        this.cli.runCommand('pac solution import --path release.zip', true)
    }

    /**
     * Import solution implementation using REST API
     * @param args 
     */
    private async importViaApi(args: PowerPlatformImportSolutionArguments): Promise<void> {
        let solutions :any = await this.getSecureJson(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/solutions?$filter=uniquename%20eq%20%27ALMAcceleratorforAdvancedMakers%27`, args.accessToken)

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
    
            // NOTE: This import process does not work as it does not reconnect Canvas to Flow connections
            await this.getAxios().post( `https://${args.environment}.crm.dynamics.com/api/data/v9.0/ImportSolution`, importData, {
                headers: {
                    'Content-Type': 'application/json', 
                    'Authorization': `Bearer ${args.accessToken}`
                }
            })
            solutions = JSON.parse(await this.getUrl(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/solutions?$filter=uniquename%20eq%20%27ALMAcceleratorforAdvancedMakers%27`))
        } else {
            console.debug('Solution already exists')
        }  
        
        await this.fixConnectionReferences(solutions, args)
    }

    async fixConnectionReferences(solutions: any, args: PowerPlatformImportSolutionArguments): Promise<void> {
        if (!await this.cli.validateAzCliReady(args)) {
            return Promise.resolve()
        }

        let solutionId = solutions.value[0].solutionid
        
        let connectionReferences = (await this.getSecureJson(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/connectionreferences`, args.accessToken)).value

        let connectionMatch = connectionReferences?.filter( (c:any) => c.connectionreferencedisplayname == "Microsoft Dataverse (legacy)")

        if (typeof connectionMatch === "undefined" || connectionMatch?.length == 0) {
            console.log('Dataverse Connection not found')
            return Promise.resolve();
        }

        let connectionCorrect = false
        if (connectionMatch[0].connectionreferenceid?.length > 0) {
            console.debug('Dataverse connection connected')
            connectionCorrect = true 
        }

        if (!connectionCorrect)
        {
            let organizationid = JSON.parse(await this.getUrl(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/organizations?$select=organizationid`)).value.organizationid

            let script = path.join(__dirname, '..', '..', 'scripts', 'Microsoft.PowerApps.Administration.PowerShell.ps1')
                
            let connections = JSON.parse(this.cli.runCommand(`Import-Module ${script} -Force; Get-AdminPowerAppConnection | ConvertTo-Json`, false))
    
            let current = JSON.parse(this.cli.runCommand('az accout show', false)).user?.name.toLowerCase()
    
            let connection = connections.filter((c: any) => c.EnvironmentName == organizationid && c.CreatedBy?.userPrincipalName.toLowerCase() && c.ConnectorName == 'shared_commondataservice' )
        
            if (connection.length == 0) {
                console.log('No Microsoft Dataverse (Legacy Found). Please create and rerun setup')
                return Promise.resolve();
            }

            //TODO update connection
        }
        
        //TODO check if flow on
    }

    async updateConnector(args: PowerPlatformConectorUpdate): Promise<void> {
        let solutions : any = JSON.parse(await this.getUrl(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/solutions?$filter=uniquename%20eq%20%27ALMAcceleratorforAdvancedMakers%27`))
        if ( solutions.value?.length == 1 )
        {
            let connectors = JSON.parse(await this.getUrl(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/connectors`))
            let aa4amConnector = connectors.value.filter( (c:any) => c.solutionId == solutions.value[0].solutionId)
            if ( aa4amConnector.length == 1) {
                let existingConnection = JSON.parse(aa4amConnector[0].connectionparameters)
                //TODO
                await this.getAxios().patch(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/connectors(${aa4amConnector[0].connectorid})`, {})
            }
        }
    }

}

export {
    PowerPlatformImportSolutionArguments,
    PowerPlatformConectorUpdate,
    PowerPlatformCommand
};