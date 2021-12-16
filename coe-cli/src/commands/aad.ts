"use strict";
import path = require('path');
import { execSync, ExecSyncOptionsWithStringEncoding } from 'child_process';
import * as winston from 'winston';
import { PowerPlatformCommand } from './powerplatform';
import axios, { AxiosResponse, AxiosStatic } from 'axios';
import { Environment } from '../common/environment';
import { Prompt } from '../common/prompt';

/**
 * ALM Accelereator for Makers commands
 */
class AADCommand {
  
    runCommand: (command: string, displayOutput: boolean) => string
    prompt: Prompt
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
        this.prompt = new Prompt()
    }

    getAADGroup(args: IMakerGroup): string {
        let json = this.runCommand(`az ad group list --display-name "${args.azureActiveDirectoryMakersGroup}"`, false)
        let groups = <any[]>JSON.parse(json)

        if (groups.length == 1) {
            return groups[0].objectId
        }

        return null
    }

    /**
     * Install AAD Group
     * @param args 
     * @returns 
     */
    installAADGroup(args: AADAppInstallArguments): string {
        if ( args.azureActiveDirectoryMakersGroup?.length == 0 ) {
            this.logger?.info('Skipping group create')
            return null;
        }

        let group : string = this.getAADGroup(args)
        if ( group === null) {
            this.logger?.info(`Creating ${args.azureActiveDirectoryMakersGroup} group`)
            let createJson = this.runCommand(`az ad group create --display-name "${args.azureActiveDirectoryMakersGroup}" --description "Application Lifecycle Management Accelerator for Makers" --mail-nickname="null"`, false)
            group = JSON.parse(createJson).objectId
        } else {
            this.logger?.info(`Group ${args.azureActiveDirectoryMakersGroup} exists`)
        }
        return group
    }
    
    getAADApplication(args: IAADApplicationArguments): string {
        let app = <any[]>JSON.parse(this.runCommand(`az ad app list --filter "displayName eq '${args.azureActiveDirectoryServicePrincipal}'"`, false))

        if (app.length == 1) {
            return app[0].appId
        }

        return null
    }

    /**
     * Add user to group
     * @param user The object ID of the contact, group, user, or service principal.
     * @param azureActiveDirectoryMakersGroup Group's object id or display name(prefix also works if there is a unique match).
     */
    addUserToGroup(user: string, azureActiveDirectoryMakersGroup: string) {
        let userInfo = JSON.parse(this.runCommand(`az ad user show --id ${user}`, false))

        if (typeof userInfo === "object" && typeof userInfo.objectId === "string") {
            let result = JSON.parse(this.runCommand(`az ad group member check --group ${azureActiveDirectoryMakersGroup} --member-id ${userInfo.objectId}`, false))
            let exists : Boolean = (result.value == true)

            if (!exists) {
                this.logger?.info(`Add ${userInfo.objectId} to ${azureActiveDirectoryMakersGroup}`)
                this.runCommand(`az ad group member add --group ${azureActiveDirectoryMakersGroup} --member-id ${userInfo.objectId}`, false)
            } else {
                this.logger?.info(`User exists in ${azureActiveDirectoryMakersGroup}`)
            }
            
        } else {
            this.logger?.info(`Unable add user to ${azureActiveDirectoryMakersGroup}`)
            this.logger?.debug(userInfo)
        }
    }

    /**
     * Create the service principal required to manage solutions between Azure DevOps and the Power Platform environments
     * @param args 
     * @returns 
     */
    async installAADApplication(args: AADAppInstallArguments): Promise<void> {

        if (await this.validateAzCliReady(args)) {
            let manifest = path.join(__dirname, '..', '..', '..', 'config', 'manifest.json')

            // Find if application has been created already
            let app = <any[]>JSON.parse(this.runCommand(`az ad app list --filter "displayName eq '${args.azureActiveDirectoryServicePrincipal}'"`, false))

            if (app.length == 0) {
                this.logger?.info(`Creating application ${args.azureActiveDirectoryServicePrincipal}`)
                let createCommand = `az ad app create --display-name "${args.azureActiveDirectoryServicePrincipal}" --available-to-other-tenants false --required-resource-accesses "${manifest}"`
                let appCreateText = this.runCommand(createCommand, false)
                let appCreate = JSON.parse(appCreateText)
                if ( typeof appCreate.Error !== "undefined") {
                    this.logger.error(appCreate.Error)
                }
                app = <any[]>JSON.parse(this.runCommand(`az ad app list --filter "displayName eq '${args.azureActiveDirectoryServicePrincipal}'"`, false))
                this.logger?.info("Creating application service principal")
                this.runCommand(`az ad sp create --id ${app[0].appId}`, false)
            }

            if (app.length == 1) {
                this.logger.info("Application exists")

                let permissions : any[]
                let waiting = true
                let attempt = 0
                while ( waiting ) {
                    if (attempt > 60) {
                        break
                    }
                    try {
                        permissions= <any[]>JSON.parse(this.runCommand(`az ad app permission list-grants --id ${app[0].appId}`, false))
                        if (permissions.length >= 0) {
                            break
                        }
                    } catch {

                    }
                    this.logger?.debug(`Waiting attempt ${attempt}`)
                    await this.sleep(1000)
                    attempt++
                }
                 
                if (permissions?.length < 3) {
                    this.logger.info("Administration grant not set")

                    this.logger?.info("Granting Azure DevOps delegated admin consent")
                    this.grantAdminDelegatedPermissions(app[0].appId, '499b84ac-1321-427f-aa17-267ca6975798', 'ee69721e-6c3a-468f-a9ec-302d16a4c599')
                    
                    this.logger?.info("Granting PowerApps-Advisor delegated admin consent")
                    this.grantAdminDelegatedPermissions(app[0].appId, 'c9299480-c13a-49db-a7ae-cdfe54fe0313', 'd533b86d-8f67-45f0-b8bb-c0cee8da0356')

                    this.logger?.info("Granting Dynamics CRM delegated admin consent")
                    this.grantAdminDelegatedPermissions(app[0].appId, '00000007-0000-0000-c000-000000000000', '78ce3f0f-a1ce-49c2-8cde-64b5c0896db4')

                    try {
                        permissions= <any[]>JSON.parse(this.runCommand(`az ad app permission list-grants --id ${app[0].appId}`, false))
                    } catch {

                    }
                } 
                
                if (permissions?.length == 3) {
                    this.logger?.info("Admin permissions granted")
                } else {
                    this.logger.info("Unable to verify that Administration permissions set")
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

    grantAdminDelegatedPermissions(appId: string, apiId: string, scope: string) {
        // https://github.com/Azure/azure-cli/issues/12137#issuecomment-596567479
        let result = this.runCommand(`az ad app permission grant --id ${appId} --api ${apiId} --scope ${scope}`, false)
        this.logger?.debug(result)
    }

    sleep(ms: number) {
        return new Promise((resolve) => {
            setTimeout(resolve, ms);
        });
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
        let validated = false
        while (!validated) {
            let accounts: any[]
            try {
                accounts = <any[]>JSON.parse(this.runCommand('az account list', false))
            } catch {
                accounts = []
            }

            // Check if tenant assigned
            if (typeof (args.subscription) == "undefined" || (args.subscription.length == 0)) {
                if (accounts.length == 0) {
                    // No accounts are available probably not logged in ... prompt to login
                    let ok = await this.prompt.yesno('You are not logged into an account. Try login now (y/n)?', true)
                    if (ok) {
                        this.runCommand('az login --use-device-code --allow-no-subscriptions', true)
                    } else {
                        return Promise.resolve(false);
                    }
                }

                if (accounts.length > 0) {
                    let defaultAccount = accounts.filter((a: any) => (a.isDefault));
                    if (accounts.length == 1) {
                        // Only one subscription assigned to the user account use that
                        args.subscription = accounts[0].id
                    }
                    if (defaultAccount.length == 1 && accounts.length > 1) {
                        // More than one account assigned to this account .. confirm if want to use the current default tenant
                        let ok = await this.prompt.yesno(`Use default tenant ${defaultAccount[0].tenantId} in account ${defaultAccount[0].name} (y/n)?`, true);
                        if (ok) {
                            // Use the default account
                            args.subscription = defaultAccount[0].id
                        }
                    }
                    if (typeof (args.subscription) == "undefined" || (args.subscription.length == 0)) {
                        this.logger?.info("Missing subscription, run az account list to and it -a argument to assign the default subscription/account")
                        return Promise.resolve(false);
                    }
                }
            }

            if (accounts.length > 0) {
                let match = accounts.filter((a: any) => (a.id == args.subscription || a.name == args.subscription) && (a.isDefault));
                if (match.length != 1) {
                    this.logger?.info(`${args.subscription} is not the default account. Check you have run az login and have selected the correct default account using az account set --subscription`)
                    this.logger?.info('Read more https://docs.microsoft.com/cli/azure/account?view=azure-cli-latest#az_account_set')
                    return Promise.resolve(false)
                } else {
                    return Promise.resolve(true)
                }
            }
        }
    }
}

/**
 * Azure Active Directory User Arguments
 */
 class AADAppInstallArguments {
    
    constructor() {
        this.accessTokens = {}
        this.settings = {}
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
    * The name of the Azure subscription
    */
    subscription: string

    /**
     * Azure Active directory application name
     */
    azureActiveDirectoryServicePrincipal: string

    /**
     * Azure Active directory makers group
     */
    azureActiveDirectoryMakersGroup: string

    /**
     * Create secret for application
     */
    createSecret: boolean

    /**
    * Optional settings
    */
    settings:  { [id: string] : string }
}

type AADAppSecret = {
    tenantId: string,
    clientId: string,
    clientSecret: string
}

interface IMakerGroup {
    azureActiveDirectoryMakersGroup: string
}

interface IAADApplicationArguments {
    azureActiveDirectoryServicePrincipal: string
}

export {
    AADAppInstallArguments,
    AADAppSecret,
    AADCommand,
    IAADApplicationArguments
};