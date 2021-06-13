"use strict";
import path = require('path');
import { execSync, ExecSyncOptionsWithStringEncoding } from 'child_process';
import yesno from 'yesno';
import * as winston from 'winston';
import { PowerPlatformCommand } from './powerplatform';
import axios, { AxiosResponse, AxiosStatic } from 'axios';

/**
 * Azure Active Directory User Arguments
 */
class AADAppInstallArguments {
    
    constructor() {
        this.accessTokens = {}
    }

    /** 
     * The power platform endpoint to interact with
     */
    endpoint: string;

    /**
    * Audiance scoped access tokens
    */
    accessTokens: { [id: string] : string }

    /**
    * The name of the Azure account
    */
    account: string

    /**
     * Azure Active directory application name
     */
    azureActiveDirectoryServicePrincipal: string

    /**
     * Create secret for application
     */
    createSecret: boolean
}

type AADAppSecret = {
    tenantId: string,
    clientId: string,
    clientSecret: string
}

/**
 * AML Accelereator for Advanced Makers commands
 */
class AADCommand {
    runCommand: (command: string, displayOutput: boolean) => string
    prompt: (text: string) => Promise<boolean>
    logger: winston.Logger
    getAxios: () => AxiosStatic

    constructor(logger: winston.Logger) {
        this.logger = logger
        this.runCommand = (command: string, displayOutput: boolean) => {
            if (displayOutput) {
                return execSync(command, <ExecSyncOptionsWithStringEncoding>{ stdio: 'inherit', encoding: 'utf8' })
            } else {
                return execSync(command, <ExecSyncOptionsWithStringEncoding>{ encoding: 'utf8' })
            }
        }
        this.getAxios = () => axios
        this.prompt = async (text: string) => await yesno({ question: text })
    }

    getAADApplication(args: AADAppInstallArguments): string {
        let app = <any[]>JSON.parse(this.runCommand(`az ad app list --filter "displayName eq '${args.azureActiveDirectoryServicePrincipal}'"`, false))

        if (app.length == 1) {
            return app[0].appId
        }

        return null
    }

    /**
     * Create the service principal required to manage solutions between Azure DevOps and the Power Platform environments
     * @param args 
     * @returns 
     */
    async installAADApplication(args: AADAppInstallArguments): Promise<void> {

        if (await this.validateAzCliReady(args)) {
            let script = path.join(__dirname, '..', '..', '..', 'scripts', 'New-AzureAdAppRegistration.ps1')
            let manifest = path.join(__dirname, '..', '..', '..', 'config', 'manifest.json')

            // Call powershell script to register a new Azure active directory Application
            let command = `pwsh -c ". '${script}'; New-AzureAdAppRegistration -DisplayName '${args.azureActiveDirectoryServicePrincipal}' -ManifestPath '${manifest}'"`
            this.runCommand(command, true)

            // Find the created application and register the management application 
            let app = <any[]>JSON.parse(this.runCommand(`az ad app list --filter "displayName eq '${args.azureActiveDirectoryServicePrincipal}'"`, false))

            if (app.length == 1) {
                let pp = new PowerPlatformCommand(this.logger)
                let bapUrl = pp.mapEndpoint("bap", args.endpoint)
                let apiVersion = "2020-06-01"
                let accessToken = args.accessTokens[bapUrl]
                let results: AxiosResponse<any>
                try{
                    // Reference
                    // Source: Microsoft.PowerApps.Administration.PowerShell
                    results = await this.getAxios().put<any>(`${bapUrl}providers/Microsoft.BusinessAppPlatform/adminApplications/${app[0].appId}?api-version=${apiVersion}`, {
                        headers: {
                            "Authorization": `Bearer ${accessToken}`,
                            "Content-Type": "application/json"
                        }
                    })
                    this.logger?.info("Added Admin Application for Azure Application")
                } catch (err) {
                    this.logger?.info("Error adding Admin Application for Azure Application")
                    this.logger?.error(err.response.data.error)
                    throw err
                }

                let match = 0
                app[0].replyUrls?.forEach( (u:string) => {
                    if ( u == "https://global.consent.azure-apim.net/redirect") {
                        match++
                    }
                })

                if ( app[0].replyUrls.length == 0 || match == 0) {
                    this.logger?.debug('Adding reply url https://global.consent.azure-apim.net/redirect')
                    this.runCommand(`az ad app update --id ${app[0].appId} --reply-urls https://global.consent.azure-apim.net/redirect`, true)
                }
            } else {
                this.logger?.info(`Application ${args.azureActiveDirectoryServicePrincipal} not found`)
                return Promise.resolve()
            }
        }
    }

    /**
     * Add a secret to an existing AAD application
     * @param args 
     * @returns 
     */
     async addSecret(args: AADAppInstallArguments, name: string): Promise<AADAppSecret> {
         
        if (await this.validateAzCliReady(args)) {
            let result = <AADAppSecret>{}
            
            let accounts = <any[]>JSON.parse(this.runCommand(`az account list --query [?isDefault]`, false))
            result.tenantId = accounts[0].tenantId

            let apps = <any[]>JSON.parse(this.runCommand(`az ad app list --filter "displayName eq '${args.azureActiveDirectoryServicePrincipal}'"`, false))

            if (apps.length == 1) {
                result.clientId = apps[0].appId

                let suffix = ''
                let match = 0;
                apps[0].passwordCredentials?.forEach( (element:any) => {
                    if (element.customKeyIdentifier?.startsWith(name)) {
                        match++
                    }
                });
                if (match > 0) {
                    suffix = `-${match + 1}`
                }

                if (args.createSecret) {
                    this.logger?.info(`Creating AAD password for ${args.azureActiveDirectoryServicePrincipal}`)

                    name = name.replace('-', '')
                    let newName = `${name}${suffix}`.length > (15) ? `${name}${suffix}`.substr(0,15) : name
                    this.logger?.info(`Creating secret for ${newName}`)
                    let creds = JSON.parse(this.runCommand(`az ad app credential reset --id ${apps[0].appId} --append --credential-description ${newName}`, false))
                    result.clientSecret = creds.password
                    result.tenantId = creds.tenant
                }
            }

            return Promise.resolve(result)
        }
    }

    async validateAzCliReady(args: AADAppInstallArguments): Promise<boolean> {
        let pwshVersion = ''
        try {
            pwshVersion = this.runCommand('pwsh --version', false)
        } catch {

        }
        if (pwshVersion?.length == 0 || typeof pwshVersion == "undefined") {
            this.logger?.info('Powershell Core not installed or could not not be found. Visit https://aka.ms/powershell to install or check your environment.')
            return Promise.resolve(false)
        }

        let validated = false
        while (!validated) {
            let accounts: any[]
            try {
                accounts = <any[]>JSON.parse(this.runCommand('az account list', false))
            } catch {
                accounts = []
            }

            // Check if tenant assigned
            if (typeof (args.account) == "undefined" || (args.account.length == 0)) {
                if (accounts.length == 0) {
                    // No accounts are available probably not logged in ... prompt to login
                    let ok = await this.prompt('You are not logged into an account. Try login now (y/n)?')
                    if (ok) {
                        this.runCommand('az login --use-device-code --allow-no-subscriptions', true)
                    } else {
                        return Promise.resolve(false);
                    }
                }

                if (accounts.length > 0) {
                    let defaultAccount = accounts.filter((a: any) => (a.isDefault));
                    if (accounts.length == 1) {
                        // Only one accounr assigned to the user account use that
                        args.account = accounts[0].id
                    }
                    if (defaultAccount.length == 1 && accounts.length > 1) {
                        // More than one account assigned to this account .. confirm if want to use the current default tenant
                        let ok = await this.prompt(`Use default tenant ${defaultAccount[0].tenantId} in account ${defaultAccount[0].name} (y/n)?`);
                        if (ok) {
                            // Use the default account
                            args.account = defaultAccount[0].id
                        }
                    }
                    if (typeof (args.account) == "undefined" || (args.account.length == 0)) {
                        this.logger?.info("Missing account, run az account list to and it -a argument to assign the account")
                        return Promise.resolve(false);
                    }
                }
            }

            if (accounts.length > 0) {
                let match = accounts.filter((a: any) => (a.id == args.account || a.name == args.account) && (a.isDefault));
                if (match.length != 1) {
                    this.logger?.info(`${args.account} is not the default account. Check you have run az login and have selected the correct default account using az account set --subscription`)
                    this.logger?.info('Read more https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az_account_set')
                    return Promise.resolve(false)
                } else {
                    return Promise.resolve(true)
                }
            }
        }
    }
}

export {
    AADAppInstallArguments,
    AADAppSecret,
    AADCommand
};