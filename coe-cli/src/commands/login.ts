"use strict";
import { PublicClientApplication, DeviceCodeRequest, AuthenticationResult, Configuration } from '@azure/msal-node';
import { DeviceCodeResponse } from "@azure/msal-common";
import * as path from 'path'
import * as fs from 'fs';
import { promisify } from 'util';
import { execSync, ExecSyncOptionsWithStringEncoding } from 'child_process';
import { Prompt } from '../common/prompt';
import winston from 'winston';
import { Environment } from '../../src/common/environment';

const readFile = promisify(fs.readFile);

 /**
 * Azure Active Directory Login Commands
 */
class LoginCommand {
    accessToken: string;
    createClientApp: (config: Configuration) => PublicClientApplication
    runCommand: (command: string, displayOutput: boolean) => string
    logger: winston.Logger
    prompt: Prompt

    constructor(logger: winston.Logger) {
        this.logger = logger 

        this.createClientApp = (config) => {
            return new PublicClientApplication(config)
        } 
        this.runCommand = (command: string, displayOutput: boolean) => {
            if (displayOutput) {
                return execSync(command, <ExecSyncOptionsWithStringEncoding>{ stdio: 'inherit', encoding: 'utf8' })
            } else {
                return execSync(command, <ExecSyncOptionsWithStringEncoding>{ encoding: 'utf8' })
            }
        }
        this.prompt = new Prompt()
    }

    /**
     * Login to Azure DevOps
     *
     * @param args {LoginArguments} - The login arguments
     * @return {Promise} aync outcome
     *
     */
    async execute(args: LoginArguments, settings: { [id: string]: string }) : Promise<AuthenticationResult> {
        var config : any = undefined
        
        if (args?.configFile?.length > 0) {
            let configFile = path.isAbsolute(args?.configFile) ? args?.configFile :path.join(process.cwd(), args?.configFile)
            let json : string = await readFile(configFile, 'utf8');
            config = <Configuration>JSON.parse(json);
        }

        if ( typeof config === "undefined" ) {
            let authEndpoint: string = Environment.getAzureADAuthEndpoint(settings);
            let clientId: string = args.clientId
            config = {
                "authOptions":
                {
                    "clientId": clientId,
                    "authority": authEndpoint + "/common/"
                },
                "request":
                {
                    "deviceCodeUrlParameters": {
                        "scopes": ["499b84ac-1321-427f-aa17-267ca6975798/user_impersonation"]
                    }
                },
                "resourceApi":
                {
                    "endpoint": "https://dev.azure.com"
                }
            }
        }

        // Build MSAL Client Configuration from scenario configuration file
        const clientConfig = {
            auth: config.authOptions
        };
        

        let runtimeOptions: any

        if (!runtimeOptions) {
             runtimeOptions = {
                 deviceCodeCallback: (response: DeviceCodeResponse) => console.log(response.message)
             }
        }
    
        let deviceCodeRequest: DeviceCodeRequest = <DeviceCodeRequest>{
            ...config.request.deviceCodeUrlParameters,
            deviceCodeCallback: (response: DeviceCodeResponse) => console.log(response.message)
        }

        // Check if a timeout was provided at runtime.
        if (runtimeOptions?.timeout) {
             deviceCodeRequest.timeout = runtimeOptions.timeout;
        }

        return this.login(clientConfig, deviceCodeRequest)
    }

    async azureLogin(scopes: string[]) :  Promise<{ [id: string] : string }> {
        let results :  { [id: string] : string } = {}

        let validated = false
        while (!validated) {
            let accounts: any[]
            try {
                accounts = <any[]>JSON.parse(this.runCommand('az account list', false))
            } catch {
                accounts = []
            }

            // Check if accounts
            if (accounts.length == 0) {
                // No accounts are available probably not logged in ... prompt to login
                let ok = await this.prompt.yesno('You are not logged into an account. Try login now (Y/n)?', true)
                if (ok) {
                    this.runCommand('az login --use-device-code --allow-no-subscriptions', true)
                }
            }

            if (accounts.length > 0) {
                this.runCommand('az account show', true)
                validated = true
                for ( var i = 0; i < scopes.length; i++) {
                    this.logger.info(`Get access token for scope ${scopes[i]}`)
                    let token = JSON.parse(this.runCommand(`az account get-access-token --resource ${scopes[i]}`, false))
                    results[scopes[i]] = token.accessToken
                }    
            }
        }

        return results
    }
    
    async login(clientConfig: Configuration, deviceCodeRequest: DeviceCodeRequest) : Promise<AuthenticationResult>
    {
        var self = this
        const pca =  this.createClientApp(clientConfig)
        /**
         * MSAL Usage
         * The code below demonstrates the correct usage pattern of the ClientApplicaiton.acquireTokenByDeviceCode API.
         * 
         * Device Code Grant
         * 
         * In this code block, the application uses MSAL to obtain an Access Token through the Device Code grant.
         * Once the device code request is executed, the user will be prompted by the console application to visit a URL,
         * where they will input the device code shown in the console. Once the code is entered, the promise below should resolve
         * with an AuthenticationResult object.
         * 
         * The AuthenticationResult contains an `accessToken` property. Said property contains a string representing an encoded Json Web Token
         * which can be added to the `Authorization` header in a protected resource request to demonstrate authorization.
         */
        return await pca.acquireTokenByDeviceCode(deviceCodeRequest)
        .then((response) => {
            self.accessToken = response.accessToken
            return response;
        }).catch((error) => {
            this.logger?.error(error)
            return error;
        });
    }
}

/**
 * Login Arguments
 */
 class LoginArguments {
    /**
     * The configuration file to read from
     */
    configFile : string

    /**
     * The Azure Active directory client id to authenticate with 
     */
    clientId : string

    /**
     * The Azure Active Directory authorization url
     */
    auth : string
}

export { 
    LoginArguments,
    LoginCommand
};