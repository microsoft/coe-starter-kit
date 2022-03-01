"use strict";
import { AADAppInstallArguments, AADCommand} from './aad';
import { LoginCommand} from './login';
import { PowerPlatformImportSolutionArguments, PowerPlatformCommand} from './powerplatform';
import { DevOpsBranchArguments, DevOpsInstallArguments,  DevOpsCommand} from './devops';
import DynamicsWebApi = require('dynamics-web-api');
import open = require('open');
import { execSync, ExecSyncOptionsWithStringEncoding } from 'child_process';

import { GitHubCommand, GitHubReleaseArguments } from './github';
import axios, { AxiosStatic } from 'axios';
import * as winston from 'winston';
import { Environment } from '../common/environment'
import { Config } from '../common/config';

/**
 * ALM Accelerator for Makers commands
 */
class ALMCommand {
  createLoginCommand: () => LoginCommand
  createDynamicsWebApi: (config:DynamicsWebApi.Config) => DynamicsWebApi
  createAADCommand: () => AADCommand
  createDevOpsCommand: () => DevOpsCommand
  createGitHubCommand: () => GitHubCommand
  createPowerPlatformCommand: () => PowerPlatformCommand
  runCommand: (command: string, displayOutput: boolean) => string 
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
          this.logger?.info("https://azure.microsoft.com/services/devops/")
      }
    }
  }

  /**
   * Install the components required to run the ALM Accelerator for Makers
   * @param args {ALMInstallArguments} - The install parameters
   */
  async install(args: ALMInstallArguments) : Promise<void> { 
    this.logger.info("Install started")

    args.accessTokens = await this.getAccessTokens(args)
    this.logger.info("Access tokens loaded")

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
  async installAADApplication(args: ALMInstallArguments) : Promise<void> {
    let aad = this.createAADCommand()

    this.logger?.info("Install AAD application")

    let install = new AADAppInstallArguments()
    install.subscription = args.subscription
    install.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
    install.azureActiveDirectoryMakersGroup = args.azureActiveDirectoryMakersGroup
    install.accessTokens = args.accessTokens
    install.endpoint = args.endpoint
    install.settings = args.settings

    await aad.installAADApplication(install)

    aad.installAADGroup(install)
  }

  async installDevOpsComponents(args: ALMInstallArguments) : Promise<void> {
    this.logger?.info("Install DevOps Components")

    let command = this.createDevOpsCommand();
    let devOpsInstall = new DevOpsInstallArguments()
    devOpsInstall.organizationName = args.organizationName
    devOpsInstall.projectName = args.project
    devOpsInstall.repositoryName = args.repository
    devOpsInstall.pipelineRepositoryName = args.pipelineRepository
    devOpsInstall.accessTokens = args.accessTokens
    devOpsInstall.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
    devOpsInstall.azureActiveDirectoryMakersGroup = args.azureActiveDirectoryMakersGroup
    devOpsInstall.subscription = args.subscription
    devOpsInstall.createSecretIfNoExist = args.createSecretIfNoExist
    devOpsInstall.environment = args.environment
    devOpsInstall.environments = args.environments
    devOpsInstall.endpoint = args.endpoint
    devOpsInstall.settings = args.settings

    await command.install(devOpsInstall)
  }

  /**
   * Import the latest version of the ALM Accelerator For Power Platform managed solution
   * @param args 
   */
  async installPowerPlatformComponents(args: ALMInstallArguments) : Promise<void> {
    this.logger?.info("Install PowerPlatform Components")

    let environmentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)
    
    let command = this.createPowerPlatformCommand();
    let importArgs = new PowerPlatformImportSolutionArguments()

    importArgs.accessToken = typeof args.accessTokens !== "undefined" ? args.accessTokens[environmentUrl] : undefined
    importArgs.environment = typeof args.environment === "string" ? args.environment : args.environments["0"]
    importArgs.azureActiveDirectoryMakersGroup = args.azureActiveDirectoryMakersGroup
    importArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal    
    importArgs.createSecret = args.createSecretIfNoExist
    importArgs.settings = args.settings

    importArgs.sourceLocation = args.settings["installFile"]?.length > 0 ? args.settings["installFile"] : ''
    if ( args.settings["installFile"]?.length > 0 && !args.settings["installFile"].startsWith("https://") ) {
      importArgs.sourceLocation = args.settings["installFile"]
    }

    if (importArgs.sourceLocation == '' || args.settings["installFile"].startsWith("https://")) {
      let github = this.createGitHubCommand();
      let gitHubArguments = new GitHubReleaseArguments();
      gitHubArguments.type = 'coe'
      gitHubArguments.asset = 'CenterofExcellenceALMAccelerator'
      if ( typeof args.settings['installSource'] === "string" && args.settings['installSource'].length > 0 ) {
        gitHubArguments.type = args.settings['installSource'] 
      }
      if ( typeof args.settings['installAsset'] === "string" && args.settings['installAsset'].length > 0 ) {
        gitHubArguments.asset = args.settings['installAsset'] 
      }
      gitHubArguments.settings = args.settings
      importArgs.sourceLocation = await github.getRelease(gitHubArguments)
      importArgs.authorization = github.getAccessToken(gitHubArguments)
    }
    
    importArgs.importMethod = args.importMethod
    importArgs.endpoint = args.endpoint
    importArgs.accessTokens = args.accessTokens

    let environments : string[] = []
    if ( args.environment?.length > 0 ) {
      environments.push(args.environment)
    }
    let environmentNames = Object.keys(args.environments)
    for ( var i = 0; i < environmentNames.length; i++ ) {
      let name = args.environments[environmentNames[i]]
      if (environments.filter((e : string) => e == name).length == 0) {
        environments.push(name)
      }      
    }

    for ( var i = 0; i < environments.length; i++ ) {
      let userArgs = new ALMUserArguments()
      userArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
      userArgs.environment = environments[i]
      userArgs.settings = args.settings
      await this.addUser(userArgs)
    }

      await command.importSolution(importArgs)
      let aadCommand = this.createAADCommand()
      let aadId = aadCommand.getAADApplication(args)
      await command.addAdminUser(aadId, args)
  }

  /**
   * Add maker to Azure DevOps with service connection and maker user AAD group
   * @param args 
   */
  async addMaker(args: ALMMakerAddArguments) : Promise<void> {
    
    let devOps = this.createDevOpsCommand()
    let install = new DevOpsInstallArguments()
    install.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
    install.azureActiveDirectoryMakersGroup = args.azureActiveDirectoryMakersGroup
    install.organizationName = args.organizationName
    install.projectName = args.project
    install.user = args.user
    install.createSecretIfNoExist = typeof args.settings["createSecret"] === "undefined" || args.settings["createSecret"] != "false"
    install.accessTokens = await this.getAccessTokens(args)
    install.endpoint = args.endpoint
    install.environment = args.environment

    await devOps.createMakersServiceConnections(install, null, false)

    let aad = this.createAADCommand()
    aad.addUserToGroup(args.user, args.azureActiveDirectoryMakersGroup)
  }

  /**
   * Add Application user to Power Platform Dataverse environment 
   *
   * @param args {ALMBranchArguments} - User request
   * @return - async outcome
   *
   */
   async addUser(args: ALMUserArguments) : Promise<void> {    
      let accessTokens = await this.getAccessTokens(args)

      let id = args.id

      if (typeof id == "undefined" && args.azureActiveDirectoryServicePrincipal?.length > 0) {
        let aad = this.createAADCommand();
        let aadArgs = new AADAppInstallArguments()
        aadArgs.azureActiveDirectoryServicePrincipal = args.azureActiveDirectoryServicePrincipal
        aadArgs.settings = args.settings

        this.logger?.info(`Searching for application ${args.azureActiveDirectoryServicePrincipal}`)
        id = await aad.getAADApplication(aadArgs)
      }

      let environmentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)

      this.logger?.verbose(`Checking user ${args.azureActiveDirectoryServicePrincipal} exists in ${environmentUrl}`)
      var dynamicsWebApi = this.createDynamicsWebApi({
        webApiUrl: `${environmentUrl}api/data/v9.1/`,
        onTokenRefresh: (dynamicsWebApiCallback) => dynamicsWebApiCallback(accessTokens[environmentUrl])
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
              <condition attribute="applicationid" operator="eq" value="${id}" />
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
          this.logger?.debug(`Creating application user in ${args.environment}`)
          let user = { "applicationid": id, "businessunitid@odata.bind": `/businessunits(${businessUnitId})`}
          this.logger?.info('Creating system user')
          await this.getAxios().post(`${environmentUrl}api/data/v9.1/systemusers`, user, {
            headers: {
              "Authorization": `Bearer ${accessTokens[environmentUrl]}`,
              "Content-Type": "application/json"
            }
          })

          await dynamicsWebApi.executeFetchXmlAll("systemusers", query).then(function (response) {
            match = response
          }).catch(error => {
            this.logger?.error(error)
          });
        } catch (err) {
          this.logger?.error(err)
          throw err
        }
      }

      let roleName = args.role
      if ( typeof roleName === "undefined" ) {
        roleName = typeof args.settings["role"] === "string" ? args.settings["role"] : "System Administrator"
      }
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

      this.logger?.info(`Associating application user ${id} with role ${roleName}`)
      await dynamicsWebApi.associate("systemusers", match?.value[0].systemuserid, "systemuserroles_association", "roles", roles.value[0].roleid )
        .catch(err => { this.logger?.error(err)})    
   }

  /**
   * Login and Branch an Azure DevOps repository 
   *
   * @param args {ALMBranchArguments} - The branch request
   * @return - async outcome
   *
   */
  async branch(args: ALMBranchArguments) : Promise<void> {
    this.logger?.info("Setup branch")
    this.logger?.verbose(JSON.stringify(args))

    let branchArgs = new DevOpsBranchArguments();
    if (args.accessToken === undefined || args.accessToken.length == 0) {
        this.logger?.info("Getting access tokens")
        let tokens = await this.getAccessTokens(args)
        branchArgs.accessToken = tokens["499b84ac-1321-427f-aa17-267ca6975798"];
    }
    else {
        this.logger?.info("Using supplied access token")
        branchArgs.accessToken = args.accessToken;
    }
    branchArgs.organizationName = args.organizationName;
    branchArgs.projectName = args.projectName;
    branchArgs.repositoryName = args.repositoryName;
    branchArgs.pipelineRepository = args.pipelineRepository;
    branchArgs.sourceBuildName = args.sourceBuildName;
    branchArgs.destinationBranch = args.destinationBranch;
    branchArgs.settings = args.settings;
    branchArgs.openDefaultPages = true;

    let devopsCommand = this.createDevOpsCommand();
    await devopsCommand.branch(branchArgs)
    this.logger?.info("Branch option complete")
  }

  async getAccessTokens(args: any) : Promise<{ [id: string] : string }>  {
    this.logger.info( "Start get access tokens")

    let login = this.createLoginCommand()   

    let scopes = ["499b84ac-1321-427f-aa17-267ca6975798"]

    if (args.environment?.length) {
      this.logger.info( `Get access token for ${args.environment}`)
      let enviromentUrl = Environment.getEnvironmentUrl(args.environment, args.settings)
      scopes.push(enviromentUrl)
      if (typeof args.endpoint === "string") {
        let getBapEndpoint = this.getBapEndpoint(args.endpoint)
        scopes.push(getBapEndpoint)
        scopes.push(this.getPowerAppsEndpoint(args.endpoint))
        let authEndPoint = Environment.getAuthenticationUrl(getBapEndpoint)
        scopes.push(authEndPoint)
      }
    }

    if ((typeof args.environments === "object") && Object.keys(args.environments).length > 0) {
      let keys = Object.keys(args.environments)
      for ( var i = 0; i < keys.length; i++) {
        let enviromentUrl = Environment.getEnvironmentUrl(args.environments[keys[i]], args.settings)
        scopes.push(enviromentUrl)
      }
      if (typeof args.endpoint === "string") {
        let getBapEndpoint = this.getBapEndpoint(args.endpoint)
        scopes.push(getBapEndpoint)
        let authEndPoint = Environment.getAuthenticationUrl(getBapEndpoint)
        scopes.push(authEndPoint)
      }
    }

    return login?.azureLogin(scopes)
  }
}

/**
 * ALM Accelerator for Makers User Arguments
 */
 class ALMInstallArguments {
  constructor() {
     this.environments = {}
     this.endpoint = "prod"
     this.settings = {}
  }

  endpoint: string

   /**
   * The components to install
   */
  components: string[]
  
  /**
   * The Azure active directory subscription to setup and install to
   */
  subscription: string

  /**
   * The azure active directory services principal application name
   */
  azureActiveDirectoryServicePrincipal: string

  /**
   * The azure active directory makers group
   */
  azureActiveDirectoryMakersGroup: string

  /**
   * The name of the Azure DevOps Organization
   */
  organizationName: string

  /**
   * The name of the Azure DevOps project
   */
  project: string

  /**
   * The name of the Azure DevOps solution repository
   */
  repository: string

  /**
   * The name of the Azure DevOps pipeline repository
   */
  pipelineRepository: string

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
    * Audience scoped access tokens
    */
   accessTokens: { [id: string] : string }

   /**
    * Solution import method
    */
   importMethod: string

   /**
    * Optional settings
    */
   settings:  { [id: string] : string }
}

/**
 * ALM Accelerator for Makers User Arguments
 */
class ALMUserArguments {
  constructor() {
    this.clientId = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
    this.settings = {}
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
   * The name of the azure active directory service principal to lookup
   */
  azureActiveDirectoryServicePrincipal: string

  /**
  * The user role
  */
  role: string

  /**
    * Optional settings
    */
   settings:  { [id: string] : string }
}

/**
 * ALM Accelerator for Makers Add Arguments
 */
 class ALMMakerAddArguments {
  constructor() {
    this.settings = {}
  }

  /**
   * The user to add
   */
  user: string

  /**
   * The Azure DevOps Organization
   */
  organizationName: string

  /**
   * The Azure DevOps project
   */
  project: string

  /**
   * The name of the Power Platform environment to add the user to
   */
  environment: string

  /**
   * The Power Platform endpoint
   */
  endpoint: string

  /**
   * The name of the azure active directory service principal to lookup
   */
  azureActiveDirectoryServicePrincipal: string

  /**
   * The name of the azure active directory group to add the user to
   */
  azureActiveDirectoryMakersGroup: string

  /**
    * Optional settings
    */
  settings:  { [id: string] : string }
}

/**
 * ALM Accelerator for Makers Branch Arguments
 */
class ALMBranchArguments {
  constructor() {
    this.clientId = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
    this.settings = {}
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
   * The Azure DevOps project name that ALM installed ot
   */
  projectName: string

  /**
   * The Azure repo name that ALM installed to
   */
  repositoryName: string;

   /**
   * The Azure repo name that contains ALM pipeline templates
   */
  pipelineRepository: string

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

  /**
   * The destination branch that will be copied to
   */
  accessToken: string

  /**
    * Optional settings
    */
  settings:  { [id: string] : string }
}

export { 
  ALMBranchArguments,
  ALMInstallArguments,
  ALMUserArguments,
  ALMMakerAddArguments,
  ALMCommand
};