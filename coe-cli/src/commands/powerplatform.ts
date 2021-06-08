"use strict";
import { v4 as uuidv4 } from 'uuid';
import axios, { AxiosStatic } from 'axios';
import fs from 'fs' 
import path from 'path' 
import { CommandLineHelper } from '../common/cli'
import { AADAppInstallArguments, AADCommand } from './aad';

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

    /**
     * The Azure Active Directory Service principal to assign to the custom connector
     */
    azureActiveDirectoryServicePrincipal: string

    /**
     * Create a new secret for 
     */
    createSecret: boolean
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
    createAADCommand: () => AADCommand
  
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
        this.createAADCommand = () => { return new AADCommand() }
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

        await this.cli.runCommand('pac solution import --path release.zip', true)
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
    
            console.debug('Importing managed solution')
            await this.getAxios().post( `https://${args.environment}.crm.dynamics.com/api/data/v9.0/ImportSolution`, importData, {
                headers: {
                    'Content-Type': 'application/json', 
                    'Authorization': `Bearer ${args.accessToken}`
                }
            })
            solutions = await this.getSecureJson(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/solutions?$filter=uniquename%20eq%20%27ALMAcceleratorforAdvancedMakers%27`, args.accessToken)
        } else {
            console.debug('Solution already exists')
        }  

        if (!await this.cli.validateAzCliReady(args)) {
            return Promise.resolve()
        }
        
        await this.fixConnectionReferences(solutions, args)

        await this.fixFlows(solutions, args)
    }

    async fixConnectionReferences(solutions: any, args: PowerPlatformImportSolutionArguments): Promise<void> {
        let whoAmI = await this.getSecureJson(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/WhoAmI`, args.accessToken)

        let aadInfo = (await this.getSecureJson(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/systemusers?$filter=systemuserid eq '${whoAmI.UserId}'&$select=azureactivedirectoryobjectid`, args.accessToken))

        let script = path.join(__dirname, '..', '..', '..', 'scripts', 'Microsoft.PowerApps.Administration.PowerShell.psm1')
                
        let command = `pwsh -c "try{ Import-Module '${script}' -Force; Get-AdminPowerAppConnection | ConvertTo-Json } catch {}"`
        let data = await this.cli.runCommand(command, false)
        let connections = JSON.parse(data)

        let connection = connections.filter((c: any) => c.CreatedBy?.id == aadInfo.value[0].azureactivedirectoryobjectid && c.ConnectorName == 'shared_commondataservice' )
        
        if (connection.length == 0) {
            console.log('No Microsoft Dataverse (Legacy Found). Please create and rerun setup')
            return Promise.resolve();
        } else {
            let connectionReferences = (await this.getSecureJson(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/connectionreferences?$filter=solutionid eq '${solutions.value[0].solutionid}'`, args.accessToken)).value
            let connectionMatch = connectionReferences?.filter( (c:any) => c.connectionreferencelogicalname.startsWith('cat_CDSDevOps') )

            if (typeof connectionMatch === "undefined" || connectionMatch?.length == 0) {
                console.log('Dataverse Connection not found')
                return Promise.resolve();
            } else {
                if (connectionMatch[0].connectionid == null) {
                    let update = {
                        "connectionid": `${connection[0].ConnectionName}`
                    }
                     try{
                        await this.getAxios().patch(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/connectionreferences(${connectionMatch[0].connectionreferenceid})`, update, { headers: {
                            'Authorization': 'Bearer ' + args.accessToken,
                            'Content-Type': 'application/json',
                            'OData-MaxVersion': '4.0',
                            'OData-Version': '4.0',
                            'If-Match': '*'  
                        }})
                     } catch (err) {
                         console.log(err)
                     }
                } else {
                    console.debug("Connection already connected")
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
        let flows = (await this.getSecureJson(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/workflows?$filter=solutionid eq '${solutions.value[0].solutionid}'`, args.accessToken))
        for ( let i = 0; i < flows.value?.length; i++ ) {
            let flow = flows.value[i]
            if (flow.statecode == 0 && flow.statuscode == 1) {
                let flowUpdate = {
                    statecode: 1,
                    statuscode: 2
                }
                console.debug(`Enabling flow ${flow.name}`)
                await this.getAxios().patch(`https://${args.environment}.crm.dynamics.com/api/data/v9.0/workflows(${flow.workflowid})`, flowUpdate, { headers: {
                            'Authorization': 'Bearer ' + args.accessToken,
                            'Content-Type': 'application/json',
                            'OData-MaxVersion': '4.0',
                            'OData-Version': '4.0',
                            'If-Match': '*'  
                        }})
            }
        }
    }
}

export {
    PowerPlatformImportSolutionArguments,
    PowerPlatformConectorUpdate,
    PowerPlatformCommand
};
