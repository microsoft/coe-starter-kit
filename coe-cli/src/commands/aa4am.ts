"use strict";
import { AADAppInstallArguments, AADCommand} from './aad';
import { LoginCommand} from './login';
import { PowerPlatformImportSolutionArguments, PowerPlatformCommand} from './powerplatform';
import { DevOpsBranchArguments, DevOpsInstallArguments,  DevOpsCommand} from './devops';
import { DeviceCodeRequest, Configuration, AuthenticationResult } from '@azure/msal-node';
import DynamicsWebApi = require('dynamics-web-api');
import open = require('open');
import { execSync, ExecSyncOptionsWithStringEncoding } from 'child_process';
import yesno from 'yesno'; 
import { GitHubCommand, GitHubReleaseArguments } from './github';
import axios, { AxiosStatic } from 'axios';
import * as winston from 'winston';

/**
 * ALM Accelerator for Advanced Makers User Arguments
 */
 class AA4AMInstallArguments {
  constructor() {
     this.environments = {}
     this.endpoint = "prod"
  }

  endpoint: string

   /**
   * The components to install
   */
  components: string[]
  
  /**
   * The Azure active directory account to setup and install to
   */
  account: string

  /**
   * The azure active directory services principal application name
   */
  azureActiveDirectoryServicePrincipal: string

  /**
   * The name of the Azure DevOps Organization
   */
  organizationName: string

  /**
   * The name of the Azure DevOps project
   */
  project: string

  /**
   * The name of the Azure DevOps pipeline repository
   */
  repository: string

  /**
   * The Power Platform organization
   */
  environment: string

  /**
   * The name of the Power Platform Organization
   */
  powerPlatformOrganization: string

  /**
   * The Power Platform organization
   */
  environments: { [id: string] : string }

  /**
   * Create secret if not exist
   */
  createSecretIfNoExist: boolean

   /**
    * Audiance scoped access tokens
    */
   accessTokens: { [id: string] : string }

   /**
    * Solution import method
    */
   importMethod: string
}

/**
 * ALM Accelerator for Advanced Makers User Arguments
 */
class AA4AMUserArguments {
  constructor() {
    this.clientId = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
  }

  /**
   * The client id to authenticate with
   */
   clientId: string

  /**
   * The user command execute
   */
  command: string

  /**
   * The name of the Power Platform environment to add the user to
   */
  environment: string

   /**
   * The id of the user the command should be applied to
   */
  id: string

  /**
  * The usre role
  */
  role: string
}

/**
 * ALM Accelerator for Advanced Makers Branch Arguments
 */
class AA4AMBranchArguments {
  constructor() {
    this.clientId = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
  }

  /**
   * The name of the configuration file to read from
   */
  configFile: string
  /**
   * The client id to authenticate with
   */
  clientId: string

  auth: string
  /**
   * The name of the Azure DevOps Organization
   */
  organizationName: string

  /**
   * The Azure DevOps project name that AA4AM installed ot
   */
  projectName: string

  /**
   * The Azure repo name that AA4AM installed to
   */
  repositoryName: string;

  /**
   * The source branch to copy from
   */
  sourceBranch: string

  /**
   * The source build name to copy setup from> if not defained will create initial values that will need to be updated
   */
  sourceBuildName: string

  /**
   * The destination branch that will be copied to
   */
  destinationBranch: string
}

/**
 * ALM Accelereator for Advanced Makers commands
 */
class AA4AMCommand {
  createLoginCommand: () => LoginCommand
  createDynamicsWebApi: (config:DynamicsWebApi.Config) => DynamicsWebApi
  createAADCommand: () => AADCommand
  createDevOpsCommand: () => DevOpsCommand
  createGitHubCommand: () => GitHubCommand
  createPowerPlatformCommand: () => PowerPlatformCommand
  runCommand: (command: string, displayOutput: boolean) => string 
  prompt: (text: string) => Promise<boolean>
  getAxios: () => AxiosStatic
  logger: winston.Logger
  getPowerAppsEndpoint: (endpoint: string) => string
  getBapEndpoint: (endpoint: string) => string


  constructor(logger: winston.Logger) {
      this.logger = logger
      this.createAADCommand = () => new AADCommand(this.logger)
      this.createLoginCommand = () => new LoginCommand(this.logger)
      this.createDynamicsWebApi = (config:DynamicsWebApi.Config) => new DynamicsWebApi(config)
      this.createDevOpsCommand = () => new DevOpsCommand(this.logger)
      this.createGitHubCommand = () => new GitHubCommand(this.logger)
      this.createPowerPlatformCommand = () => new PowerPlatformCommand(this.logger)
      this.runCommand = (command: string, displayOutput: boolean) => {
        if (displayOutput) {
          return execSync(command, <ExecSyncOptionsWithStringEncoding> { stdio: 'inherit', encoding: 'utf8' })
        } else {
          return execSync(command, <ExecSyncOptionsWithStringEncoding> { encoding: 'utf8' })
        }
      }
      this.prompt = async (text: string) => await yesno({question:text})
      this.getAxios = () => axios
      this.getPowerAppsEndpoint = (endpoint: string) => {
        return new PowerPlatformCommand(undefined).mapEndpoint('powerapps', endpoint)
      }
      this.getBapEndpoint = (endpoint: string) => {
       return new PowerPlatformCommand(undefined).mapEndpoint('bap', endpoint)
     }
  }

  async create(type:string) {
    switch (type.toLowerCase()) {
      case "development": {
          this.logger?.info("To create a community edition developer environment")
          this.logger?.info("https://web.powerapps.com/community/signup")
          break
      }
      case "devops": {
          this.logger?.info("You can start with 'Start Free' and login with your organization account")
          this.logger?.info("https://azure.microsoft.com/en-us/services/devops/")
      }
    }
  }

  /**
   * Install the components required to run the ALM Accelerator for Advanecd Makers
   * @param args {AA4AMInstallArguments} - The install parameters
   */
  async install(args: AA4AMInstallArguments) : Promise<void> { 
    args.accessTokens = await this.getAccessTokens(args)

    if (args.components?.filter(a => a == "all" || a == "aad").length > 0) {
      await this.installAADApplication(args)
    }

    if (args.components?.filter(a => a == "all" || a == "devops").length > 0) {
      await this.installDevOpsComponents(args)
    }

    if (args.components?.filter(a => a == "all" || a == "environment").length > 0) {
      await this.installPowerPlatformComponents(args)
    }
  }

  /**
   * Create the service principal required to manage solutions between Azure DevOps and the Power Platform environments
   * @param args 
   * @returns 
   */
  async installAADApplication(args: AA4AMInstallArguments) : Promise<void> {
    let aad = this.createAADCommand()

    this.logger?.info("Install AAD application")

    let install = new AADAppInstallArguments()
    install.account = args.account
    install.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal

    await aad.installAADApplication(install)
  }

  async installDevOpsComponents(args: AA4AMInstallArguments) : Promise<void> {
    this.logger?.info("Install DevOps Components")

    let command = this.createDevOpsCommand();
    let devOpsInstall = new DevOpsInstallArguments()
    devOpsInstall.organizationName = args.organizationName
    devOpsInstall.projectName = args.project
    devOpsInstall.repositoryName = args.repository
    devOpsInstall.accessTokens = args.accessTokens
    devOpsInstall.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
    devOpsInstall.account = args.account
    devOpsInstall.createSecretIfNoExist = args.createSecretIfNoExist
    devOpsInstall.environment = args.environment
    devOpsInstall.environments = args.environments
    await command.install(devOpsInstall)
  }

  /**
   * Import the latest version of the ALM Accelerator For Advanced Makers managed solution
   * @param args 
   */
  async installPowerPlatformComponents(args: AA4AMInstallArguments) : Promise<void> {
    this.logger?.info("Install PowerPlatform Components")

    let command = this.createPowerPlatformCommand();
    let importArgs = new PowerPlatformImportSolutionArguments()
    importArgs.accessToken = args.accessTokens[`https://${args.environment}.crm.dynamics.com`]
    importArgs.environment = args.environment
    importArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
    importArgs.createSecret = args.createSecretIfNoExist

    let github = this.createGitHubCommand();
    let gitHubArguments = new GitHubReleaseArguments();
    gitHubArguments.type = 'aa4am'
    gitHubArguments.asset = 'ALMAcceleratorForAdvancedMakers'
    importArgs.sourceLocation = await github.getRelease(gitHubArguments)
    importArgs.importMethod = args.importMethod
    importArgs.endpoint = args.endpoint
    importArgs.accessTokens = args.accessTokens

    await command.importSolution(importArgs)
  }

  /**
   * Add Application user to Power Platform Dataverse environment 
   *
   * @param args {AA4AMBranchArguments} - User request
   * @return - async outcome
   *
   */
   async addUser(args: AA4AMUserArguments) : Promise<void> {    
      let accessTokens = await this.getAccessTokens(args)

      this.logger?.info("Adding user")

      this.logger?.verbose("Checking user")
      var dynamicsWebApi = this.createDynamicsWebApi({
        webApiUrl: `https://${args.environment}.crm.dynamics.com/api/data/v9.1/`,
        onTokenRefresh: (dynamicsWebApiCallback) => dynamicsWebApiCallback(accessTokens[`https://${args.environment}.crm.dynamics.com`])
      });

      let businessUnitId = ''

      await dynamicsWebApi.executeUnboundFunction("WhoAmI").then(function (response) {
        businessUnitId = response.BusinessUnitId
      })
      .catch(error => {
        this.logger?.error(error)
      });
      
      let query = `<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false" no-lock="true">
      <entity name="systemuser">
          <attribute name="applicationid" />
          <filter type="and">
              <condition attribute="applicationid" operator="eq" value="${args.id}" />
          </filter>
      </entity>
      </fetch>`
      
      this.logger?.verbose("Query system users")
      let match : DynamicsWebApi.MultipleResponse<any> 
      await dynamicsWebApi.executeFetchXmlAll("systemusers", query).then(function (response) {
          match = response
      }).catch(error => {
        this.logger?.error(error)
      });

      if (match?.value.length > 0) {
        this.logger?.debug('User exists')
      } else {
        try{
          this.logger?.debug('Creating application user')
          let user = { "applicationid": args.id, "businessunitid@odata.bind": `/businessunits(${businessUnitId})`}
          this.logger?.info('Creating system user')
          await this.getAxios().post(`https://${args.environment}.crm.dynamics.com/api/data/v9.1/systemusers`, user, {
            headers: {
              "Authorization": `Bearer ${accessTokens[`https://${args.environment}.crm.dynamics.com`]}`,
              "Content-Type": "application/json"
            }
          })
        } catch (err) {
          this.logger?.error(err)
          throw err
        }
      }
     
      let roleName = args.role
      let roleQuery = `<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false" no-lock="true">
      <entity name="role">
          <attribute name="roleid" />
          <filter type="and">
              <condition attribute="name" operator="eq" value="${roleName}" />
              <condition attribute="businessunitid" operator="eq" value="${businessUnitId}" />
          </filter>
      </entity>
      </fetch>`
      
      let roles : DynamicsWebApi.MultipleResponse<any> 
      await dynamicsWebApi.executeFetchXmlAll("roles", roleQuery).then(function (response) {
          roles = response
      }).catch(error => {
        this.logger?.error(error)
      });

      if (roles?.value.length == 0) { 
        this.logger?.debug(`Role ${roleName} does not exist`)
        return Promise.resolve();
      } 

      this.logger?.info(`Associating application user ${args.id} with role ${roleName}`)
      await dynamicsWebApi.associate("systemusers", match?.value[0].systemuserid, "systemuserroles_association", "roles", roles.value[0].roleid )
        .catch(err => { this.logger?.error(err)})    
   }

  /**
   * Login and Branch an Azure DevOps repository 
   *
   * @param args {AA4AMBranchArguments} - The branch request
   * @return - async outcome
   *
   */
  async branch(args: AA4AMBranchArguments) : Promise<void> {
    let tokens = await this.getAccessTokens(args)

    this.logger?.info("Setup branch")
    this.logger?.verbose(JSON.stringify(args))

    let branchArgs = new DevOpsBranchArguments();
    branchArgs.accessToken = tokens["499b84ac-1321-427f-aa17-267ca6975798"];
    branchArgs.organizationName = args.organizationName;
    branchArgs.projectName = args.projectName;
    branchArgs.repositoryName = args.repositoryName;
    branchArgs.sourceBuildName = args.sourceBuildName;
    branchArgs.destinationBranch = args.destinationBranch;
    branchArgs.openDefaultPages = true;

    let devopsCommand = this.createDevOpsCommand();
    await devopsCommand.branch(branchArgs)
  }

  async getAccessTokens(args: any) : Promise<{ [id: string] : string }>  {
    let login = this.createLoginCommand()   

    let scopes = ["499b84ac-1321-427f-aa17-267ca6975798"]

    if (args.environment?.length) {
      scopes.push(`https://${args.environment}.crm.dynamics.com`)
      if (typeof args.endpoint === "string") {
        scopes.push(this.getBapEndpoint(args.endpoint))
        scopes.push(this.getPowerAppsEndpoint(args.endpoint))
      }
    }

    if ((typeof args.environments === "object") && Object.keys(args.environments).length > 0) {
      let keys = Object.keys(args.environments)
      for ( var i = 0; i < keys.length; i++) {
        scopes.push(`https://${args.environments[keys[i]]}.crm.dynamics.com`)
      }
      if (typeof args.endpoint === "string") {
        scopes.push(this.getBapEndpoint(args.endpoint))
      }
    }

    return login?.azureLogin(scopes)
  }
}

export { 
  AA4AMBranchArguments,
  AA4AMInstallArguments,
  AA4AMUserArguments,
  AA4AMCommand
};