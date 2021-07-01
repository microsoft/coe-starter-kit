"use strict";
import commander, { command, Command, option, Option, opts } from 'commander';
import { LoginCommand } from './login';
import { AA4AMBranchArguments, AA4AMInstallArguments, AA4AMUserArguments, AA4AMCommand, AA4AMMakerAddArguments } from './aa4am';
import { DevOpsInstallArguments, DevOpsCommand } from './devops';
import { RunArguments, RunCommand } from './run';
import { CLIArguments, CLICommand } from './cli';
import * as winston from 'winston';
import * as readline from 'readline';
import * as fs from 'fs';
const path = require('path')
import { FileHandle } from 'fs/promises';
import { Environment } from '../common/enviroment';

interface TextParseFunction {
    parse: (text:string) => { [id: string] : string } | string | string[]
    command: commander.Command
}

/**
 * Define supported commands across COE Toolkit
 */
class CoeCliCommands {
    createLoginCommand: () => LoginCommand
    createAA4AMCommand: () => AA4AMCommand
    createDevOpsCommand: () => DevOpsCommand
    createRunCommand: () => RunCommand
    createCliCommand: () => CLICommand
    logger: winston.Logger
    readline: readline.ReadLine
    readFile: (path: fs.PathLike | FileHandle, options: { encoding: BufferEncoding, flag?: fs.OpenMode } | BufferEncoding) => Promise<string>
    writeFile: (path: fs.PathLike | FileHandle, data: string | Uint8Array, options?: fs.BaseEncodingOptions & { mode?: fs.Mode, flag?: fs.OpenMode } | BufferEncoding | null) => Promise<void>
    outputText: (text: string) => void
    
    constructor(logger: winston.Logger, defaultReadline: readline.ReadLine = null, defaultFs: any = null ) {
        if (typeof logger === "undefined") {
            this.logger = logger
        }
        this.createLoginCommand = () => new LoginCommand(this.logger)
        this.createAA4AMCommand = () => new AA4AMCommand(this.logger)
        this.createDevOpsCommand = () => new DevOpsCommand(this.logger)
        this.createRunCommand = () => new RunCommand(this.logger)
        this.createCliCommand = () => new CLICommand(this.logger)
        this.readline = defaultReadline
        if (this.readline == null) {
            this.readline = readline.createInterface({
                input: process.stdin,
                output: process.stdout
              })
        }
        if (defaultFs == null) {
            this.readFile = fs.promises.readFile
            this.writeFile = fs.promises.writeFile
        } else {
            this.readFile = defaultFs.readFile
            this.writeFile = defaultFs.writeFile
        }
        this.outputText = (text: string) => console.log(text)
    }

    /**
     * Parse commands from command line
     *
     * @param argv {string[]} - The command line to parse
     * @return {Promise} aync outcome
     *
     */
    async execute(argv: string[]) : Promise<void> {
        const program = new Command();
        program.version('0.0.1');

        this.AddALMAcceleratorForAdvancedMakerCommands(program);
        this.AddRunCommand(program);
        this.AddCliCommand(program);
       
        await program
            .parseAsync(argv);
    }

    setupLogger(args: any) {
        if (typeof this.logger !== "undefined") {
            return;
        }
        this.logger = winston.createLogger({
            format: winston.format.combine(
                winston.format.splat(),
                winston.format.simple()
            ),
            transports: [new winston.transports.Console({ level: typeof args.log === "string" ? args.log : 'info' }),
                new winston.transports.File({
                filename: 'combined.log',
                level: 'verbose',
                format: winston.format.combine(
                    winston.format.timestamp({
                      format: 'YYYY-MM-DD hh:mm:ss A ZZ'
                    }),
                    winston.format.json()
                  ),
                  handleExceptions: true
                })]
            });
    }

    AddALMAcceleratorForAdvancedMakerCommands(program: commander.Command) {
        var aa4am = program.command('aa4am')
        .description('ALM Accelerator For Advanced Makers');

        let componentOption = new Option('-c, --components [component]', 'The component(s) to install').default(["all"]).choices(['all', 'aad', 'devops', 'environment']);
        componentOption.variadic = true

        let installOption = new Option('-m, --importMethod <method>', 'The import method').default("api").choices(['browser', 'pac', 'api']);

        let installEndpoint = new Option('--endpoint <name>', 'The endpoint').default("prod").choices(['prod', 'usgov', 'usgovhigh', 'dod', 'china', 'preview', 'tip1', 'tip2']);

        let createTypeOption = new Option('-t, --type <type>', 'The service type to create').choices(['devops', 'development']);

        let logOption = new Option('-l, --log <log>', 'The log level').default(["info"]).choices(['error', 'warn', "info", "verbose", "debug"]);

        let regionOptions = new Option("--region", "The region to deploy to").default(["NAM"])                
                .choices(['NAM',
                    'DEU',
                    'SAM',
                    'CAN',
                    'EUR',
                    'FRA',
                    'APJ',
                    'OCE',
                    'JPN',
                    'IND',
                    'GCC',
                    'GCC High',
                    'GBR',
                    'ZAF',
                    'UAE',
                    'GER',
                    'CHE']);

        aa4am.command('create')
            .description('Create key services')
            .addOption(logOption)
            .addOption(createTypeOption)
            .action((options:any) => {
                this.setupLogger(options)
                let command = this.createAA4AMCommand()
                command.create(options.type);
                this.readline.close()
            });

        let generate = aa4am.command('generate')
        
        generate.command('install')
            .option('-o, --output <name>', 'The output file to generate')
            .addOption(logOption)
            .option('-s, --includeSchema <name>', 'Include schema', "true")
            .allowExcessArguments()
            .action(async (options:any) => {
                this.setupLogger(options)
                this.logger?.info("Generate Install start")

                let parse : { [id: string] : TextParseFunction } = {}

                let environments = new Option("--installEnvironments", "The environments to setup connections and applications user permissions").default(['validation',
                'test',
                'prod'])          
                .choices(['validation',
                    'test',
                    'prod'])

                const settings = new Command()
                    .command('settings')
                
                settings.addOption(environments)
                settings.option("--validation", "Validation Environment Name", "yourenvironment-validation");     
                settings.option("--test", "Test Environment Name", "yourenvironment-test");     
                settings.option("--prod", "Test Environment Name", "yourenvironment-prod");     
                settings.option("--createSecret", "Create and Assign Secret values for Azure Active Directory Service Principal", "true");     
                settings.addOption(regionOptions)

                parse["environments"] = { parse: (text) => {
                    if (text?.length > 0 && text.indexOf('=') < 0) {
                        return text;
                    }
                    return this.parseSettings(text)
                    },
                    command: undefined
                }

                parse["settings"] = {
                    parse: (text) => text,
                    command: settings
                }

                this.logger?.debug("Prompting for values")
                let results = await this.promptForValues(aa4am, 'install', ["file"], parse)

                if (typeof results.settings === "string") {
                    results.settings = this.parseSettings(results.settings)
                }

                if (typeof results.components === "string") {
                    results.components = results.components.split(',')
                }

                if (typeof results.settings?.region === "undefined") {
                    if (typeof results.settings === "undefined") {
                        results.settings = {}
                    }
                    // Set default region https://docs.microsoft.com/en-us/power-platform/admin/new-datacenter-regions
                    results.settings.region = "NAM"
                }

                if (typeof options.output === "string") {
                    if ( options.includeSchema === "true") {
                        results["$schema"] = "./aa4am.schema.json"
                        let schemaFile =  path.join(__dirname, '..', '..', '..', 'config', 'aa4am.schema.json')
                        this.writeFile(path.join(path.dirname(options.output), "aa4am.schema.json" ), await this.readFile(schemaFile, { encoding: 'utf-8' }))
                    }
                    this.writeFile(options.output, JSON.stringify(results, null, 2))
                    
                } else {
                    this.outputText(JSON.stringify(results, null, 2))
                }

                this.readline.close()
                this.logger?.info("Generate Install end")
            })

            generate.command('maker')
                .command("add")
                .option('-o, --output <name>', 'The output file to generate')
                .addOption(logOption)
                .allowExcessArguments()
                .action(async (options:any) => {
                    this.setupLogger(options)
                    this.logger?.info("Generate Maker start")

                    let parse : { [id: string] : TextParseFunction } = {}

                    const settings = new Command()
                        .command('settings')
                    settings.option("--createSecret", "Create and Assign Secret values for Azure Active Directory Service Principal", "true");     
                    settings.addOption(regionOptions)

                    parse["settings"] = {
                        parse: (text) => text,
                        command: settings
                    }

                    this.logger?.debug("Prompting for values")
                    let results = await this.promptForValues(maker, 'add', ["file"], parse)

                    if (typeof results.settings === "string") {
                        results.settings = this.parseSettings(results.settings)
                    }

                    if (typeof results.settings?.region === "undefined") {
                        if (typeof results.settings === "undefined") {
                            results.settings = {}
                        }
                        // Set default region https://docs.microsoft.com/en-us/power-platform/admin/new-datacenter-regions
                        results.settings.region = "NAM"
                    }

                    if (typeof options.output === "string") {
                        this.writeFile(options.output, JSON.stringify(results, null, 2))
                    } else {
                        this.outputText(JSON.stringify(results, null, 2))
                    }

                    this.readline.close()
                    this.logger?.info("Generate maker end")
                })
    
        aa4am.command('install')
            .description('Initialize a new ALM Accelerators for Makers instance')
            .option('-f, --file <name>', 'The install configuration parameters file')
            .addOption(logOption)
            .addOption(componentOption)
            .option('-d, --aad <name>', 'The azure active directory service principal application. Will be created if not exists', 'ALMAcceleratorServicePrincipal')
            .option('-g, --group <name>', 'The azure active directory servicemaker group. Will be created if not exists', 'ALMAcceleratorForAdvancedMakers')
            .option('-o, --devOpsOrganization <organization>', 'The Azure DevOps organization to install into')
            .option('-p, --project <name>', 'The Azure DevOps project name. Must already exist', 'alm-sandbox')
            .option('-r, --repository <name>', 'The Azure DevOps pipeline repository. Will be created if not exists', "pipelines")
            .option('-e, --environments <names>', 'The Power Platform environment to install Managed solution to')
            .option('-s, --settings <namevalues>', 'Optional settings', "createSecret=true")
            .addOption(installOption)
            .addOption(installEndpoint)
            .option('-a, --account <name>', 'The Azure Active directory account (Optional select azure subscription if access to multiple subscriptions)')
            .action(async (options:any) => {
                this.setupLogger(options)
                this.logger?.info("Install start")

                let command = this.createAA4AMCommand()

                let args = new AA4AMInstallArguments()
                let settings: { [id: string] : string } = {}
                if (options.file?.length > 0) {
                    this.logger?.info("Loading configuration")
                    let optionsFile = JSON.parse(await this.readFile(options.file, { encoding: 'utf-8' }))
                    if ( Array.isArray(optionsFile.environments) ) {
                        optionsFile.environments = this.parseSettings(optionsFile.environments.join(','))
                        if ( optionsFile.environments.length == 1 ) {
                            optionsFile.environment = optionsFile.environments[0]
                        }
                    }

                    if ( typeof optionsFile.environments === "string") {
                        optionsFile.environments = this.parseSettings(optionsFile.environments)
                        optionsFile.environment = optionsFile.environments['0']
                    }

                    if ( typeof optionsFile.components === "string") {
                        options.components = optionsFile.components.split(',')
                    }
                    
                    this.copyValues(optionsFile, args, {
                        "aad": "azureActiveDirectoryServicePrincipal",
                        "group": "azureActiveDirectoryMakersGroup",
                        "devOpsOrganization": "organizationName"
                    })   

                    if ( Array.isArray(optionsFile.level) && optionsFile.level.length > 0) {
                        for ( var t = 0; t < this.logger.transports.length; t++) {
                            let transport = this.logger.transports[t]
                            transport.level = optionsFile.level[0]
                        }
                    }

                    settings = typeof optionsFile.settings === "string" ? this.parseSettings(optionsFile.settings) : optionsFile.settings
                } else {
                    args.components = options.components
                    args.account = options.account
                    args.azureActiveDirectoryServicePrincipal = options.aad
                    args.azureActiveDirectoryMakersGroup = options.group
                    args.organizationName = options.devOpsOrganization
                    args.project = options.project
                    args.repository = options.repository
                    if (options.environments?.length > 0 && options.environments?.indexOf('=')>0) {
                        args.environments = this.parseSettings(options.environments)
                        args.environment = ''
                    } else {
                        args.environment = options.environments
                    }
                    args.importMethod = options.importMethod
                    args.endpoint = options.endpoint
                    args.settings = this.parseSettings(options.settings)
                }
                args.createSecretIfNoExist = typeof settings == "undefined" || typeof settings["createSecret"] == "undefined" || settings["createSecret"]?.toLowerCase() == "true"
                args.environments = Environment.getEnvironments(args.environments, args.settings)

                this.logger?.info("Starting install")
                await command.install(args);

                this.readline.close()
                this.logger?.info("Install end")
            });

        let fix = aa4am.command('fix')
            .description('Attempt to fix install components')
                   
        fix.command('build')
            .description('Attempt to build components')
            .option('-o, --devOpsOrganization <organization>', 'The Azure DevOps environment validate')
            .option('-p, --project <name>', 'The Azure DevOps name')
            .addOption(installEndpoint)
            .option('-r, --repository <name>', 'The Azure DevOps pipeline repository', "pipelines")
            .addOption(logOption).action(async (options:any) => {
                this.setupLogger(options)
                this.logger?.info("Build start")

                let login = this.createLoginCommand()
                let command = this.createDevOpsCommand()
                let args = new DevOpsInstallArguments()
                args.organizationName = options.organization
                args.projectName = options.project
                args.repositoryName = options.repository
                args.accessTokens = await login.azureLogin(["499b84ac-1321-427f-aa17-267ca6975798"])
                args.endpoint = options.endpoint

                await command.createAdvancedMakersBuildPipelines(args, null, null)

                this.readline.close()
                this.logger?.info("Build end")
            })

        let connection = aa4am.command('connection')
            .description('Manage connections')
        
        connection.command("add")
            .description("Add a new connection")
            .requiredOption('-o, --devOpsOrganization <name>', 'The Azure DevOps organization')
            .requiredOption('-p, --project <name>', 'The Azure DevOps project to add to', 'alm-sandbox')
            .requiredOption('-e, --environment <name>', 'The environment add conection to')
            .addOption(installEndpoint)
            .option('-a, --aad <name>', 'The azure active directory service principal application', 'ALMAcceleratorServicePrincipal')
            .option('-u, --user <name>', 'The optional azure active directory user to assign to the connection')
            .option('-s, --settings <namevalues>', 'Optional settings')
            .addOption(logOption)
            .action(async (options:any) => {                
                this.setupLogger(options)
                this.logger?.info("Add start")
                let login = this.createLoginCommand()
                let command = this.createDevOpsCommand()
                let args = new DevOpsInstallArguments()
                args.organizationName = options.devOpsOrganization
                args.clientId = options.clientid
                if (typeof options.aad !== "undefined") {
                    args.azureActiveDirectoryServicePrincipal = options.aad
                }
                args.projectName = options.project
                args.environment = options.environment
                args.clientId = options.clientid
                args.accessTokens = await login.azureLogin(["499b84ac-1321-427f-aa17-267ca6975798"])
                args.endpoint = options.endpoint
                args.settings = this.parseSettings(options.settings)
                args.user = options.user
                                                       
                try {
                    await command.createAdvancedMakersServiceConnections(args, null, false)
                } catch (err) {
                    this.logger?.error(err)
                }

                this.readline.close()
                this.logger?.info("Add end")
            })

        let maker = aa4am.command('maker')
            .description('Manage Advanced makers')

        maker.command("add")
            .option('-f, --file <name>', 'The install configuration parameters file from')
            .requiredOption('-o, --devOpsOrganization <name>', 'The Azure DevOps organization')
            .requiredOption('-p, --project <name>', 'The Azure DevOps project to add to', 'alm-sandbox')
            .requiredOption('-e, --environment <organization>', 'The environment to create the Service Principal Application User in')
            .requiredOption('-u, --user <name>', 'The user to add as a advanced maker')
            .requiredOption('-g, --group <name>', 'The azure active directory makers group.', 'ALMAcceleratorForAdvancedMakers')
            .option('-a, --aad <name>', 'The azure active directory service principal application', 'ALMAcceleratorServicePrincipal')
            .option('-r, --role <name>', 'The user role', 'System Administrator')
            .addOption(installEndpoint)
            .option('-s, --settings <namevalues>', 'Optional settings')
            .action(async (options: any) => {
                this.setupLogger(options)
                this.logger?.info("Add start")

                let args = new AA4AMMakerAddArguments()

                if ( typeof options.file === "string" && options.file?.length > 0 ) {
                    this.logger?.info("Loading configuration")
                    let optionsFile = JSON.parse(await this.readFile(options.file, { encoding: 'utf-8' }))
                    
                    this.copyValues(optionsFile, args, {
                        "aad": "azureActiveDirectoryServicePrincipal",
                        "group": "azureActiveDirectoryMakersGroup",
                        "devOpsOrganization": "organizationName"
                    })   
                } else {
                    args.user = options.user
                    args.organizationName = options.devOpsOrganization
                    args.project = options.project
                    args.azureActiveDirectoryServicePrincipal = options.aad
                    args.azureActiveDirectoryMakersGroup = options.group
                    args.role = options.role
                    args.endpoint = options.endpoint
                    args.environment = options.environment
                    args.settings = this.parseSettings(options.settings)
                }

                if (args.user.length == 0) {
                    this.logger?.info("No user specified")
                    return Promise.resolve()
                }

                let command = this.createAA4AMCommand()
                await command.addMaker(args)

                this.logger?.info("Add end")
            });
            
       
        let user = aa4am.command('user')
            .description('Create Admin user in Dataverse Environment')
        
        user.command("add")
            .requiredOption('-e, --environment <organization>', 'The environment to create the user in')
            .option('-i, --id <id>', 'The unique identifier of the user')
            .option('-a, --aad <name>', 'The azure active directory service principal application', 'ALMAcceleratorServicePrincipal')
            .option('-r, --role <name>', 'The user role', 'System Administrator')
            .option('-s, --settings <namevalues>', 'Optional settings')
            .addOption(logOption)
            .action(async (options: any) => {
                this.setupLogger(options)
                this.logger?.info("Add start")
                let command = this.createAA4AMCommand()
                let args = new AA4AMUserArguments();
                args.command = options.command
                args.id = options.id
                if (typeof options.aad !== "undefined") {
                    args.azureActiveDirectoryServicePrincipal = options.aad
                }
                args.environment = options.environment
                args.role = options.role
                args.settings = this.parseSettings(options.settings)
                await command.addUser(args);

                this.readline.close()
                this.logger?.info("Add end")
            });

        aa4am.command('branch')
            .description('Create a new Application Branch')
            .option('-o, --devOpsOrganization <name>', 'The Azure DevOps Organization name')
            .option('-r, --repository <name>', 'The Azure DevOps name')
            .option('-p, --project <name>', 'The Azure DevOps name')
            .option('--source <name>', 'The source branch to copy from')
            .option('--source-build <name>', 'The source build to copy from')
            .option('-d, --destination <name>', 'The branch to create')
            .option('-s, --settings <namevalues>', 'Optional settings')
            .addOption(logOption)
            .action(async (options: any) : Promise<void> => {
                this.setupLogger(options)
                this.logger?.info("Branch start")
                let args = new AA4AMBranchArguments();
                args.organizationName = options.devOpsOrganization
                args.repositoryName = options.repository
                args.projectName = options.project
                args.sourceBranch = options.source
                args.sourceBuildName = options.sourceBuild
                args.destinationBranch = options.destination
                args.settings = this.parseSettings(options.settings)

                let command = this.createAA4AMCommand()
                await command.branch(args)

                this.readline.close()
                this.logger?.info("Branch end")
            });

        return aa4am;
    }

    AddRunCommand(program: commander.Command) {
        var run = program.command('run')
            .description('Run a set of commands')
            .option('-f, --file <filename>', 'The run configuration json file')
            .action(async (options: any) : Promise<void> => {
                this.setupLogger(options)
                let args = new RunArguments();
                args.file = options.file;
                let command = this.createRunCommand();
                await command.execute(args)

                this.readline.close()
            });
    }

    AddCliCommand(program: commander.Command) {
        let run = program.command('cli')
            .description('Manage the cli applicaton')
        run.command("about")
            .description('Open web page to discover more about COE cli')
            .action(async (options: any) : Promise<void> => {
                this.setupLogger(options)
                let command = this.createCliCommand()
                await command.about()

                this.readline.close()
            })
        run.command("add")
            .description('Add a new command to the cli application')
            .requiredOption('-n, --name <name>', 'The name of the new command to add')
            .action(async (options: any) : Promise<void> => {
                this.setupLogger(options)
                let args = new CLIArguments();
                args.name = options.name;
                let command = this.createCliCommand();
                await command.add(args)

                this.readline.close()
            });
    }

    parseSettings(setting: string) : { [id: string] : string } {
        let result : { [id: string] : string } = {}

        if ( setting?.length > 0) {
            let arr = setting?.split(',');
            for ( let i = 0; i < arr.length; i++){
                if (arr[i].indexOf('=') > -1) {
                    const keyVal = arr[i].split('=');
                    result[keyVal[0].toLowerCase()] = keyVal[1]
                } else {
                    result[i.toString()] = arr[i]
                }
            }
        }

        return result;
    } 

    copyValues(source: any, destination: any, mappings:{ [id: string] : string } ) {
        let sourceKeys = Object.keys(source)

        let mappingKeys = Object.keys(mappings)

        for ( let i = 0; i < sourceKeys.length; i++ ) {
            let newName = sourceKeys[i]          
            let newMappedName = mappingKeys.filter(m => m == newName)
            newName = newMappedName.length == 1 ? mappings[newMappedName[0]] : newName
            destination[newName] = source[sourceKeys[i]]
        }
    }

    async promptForValues(command: commander.Command, name: string, ignore: string[], parse:  { [id: string] : TextParseFunction }) : Promise<any> {
        let values: any = {}
        let match = command.commands.filter( (c: commander.Command) => c.name() == name)
        let parseKeys = Object.keys(parse)

        if (match.length == 1) {
            let options : Option[] = <Option[]>(<any>match[0]).options

            this.outputText(`NOTE: To accept any default value just press ENTER`)
            this.outputText('');
            this.outputText(`Please provide your ${name} options`)
            for ( var i = 0; i < options.length ; i++ ) {
                let optionName = options[i].long.replace("--","")

                if ( ignore.includes(optionName) ) {
                    continue;
                }

                let optionParseMatch = parseKeys.filter( ( p: string) => p == optionName )

                if (optionParseMatch.length == 1 && typeof parse[optionParseMatch[0]].command !== "undefined") {
                    let childOptions = <Option[]>(<any>parse[optionParseMatch[0]].command).options
                    let childValues = {}

                    this.outputText(`> Which options for ${options[i].description}`)
                    for ( var c = 0 ; c < childOptions.length; c++ ) {
                        await this.promptOption(childOptions[c], childValues, parse, 2)
                    }

                    values[optionName] = childValues
                } else {
                    await this.promptOption(options[i], values, parse)
                }
            }
        }
        this.readline.close()
        return values
    }

    async promptOption(option: Option, data: any, parse:  { [id: string] : TextParseFunction }, offset: number = 0) : Promise<void> {
        return new Promise((resolve, reject) => {
            try {
                if (option.argChoices?.length > 0) {
                    let offsetText = new Array(offset).join( ' ' )
                    this.outputText(`${offsetText}> Which choices for ${option.description}`)
                    for ( let c = 0; c < option.argChoices.length; c++) {
                        this.outputText(`  ${c}: ${option.argChoices[c]}`)
                    }
                    if (typeof option.defaultValue !== "undefined") {
                        this.outputText(`Default value(s) ${option.defaultValue}`)
                    }
                    this.readline.question(`+ Your selection(s) seperated by commas for ${option.long?.replace("--","")}:`, (answer: string) => {
                        if (answer?.length > 0) {
                            let indexes : number[] = []
                            let results: string[] = []
                            this.logger?.debug(`Received answer ${answer}`)
                            if (answer.split(',').length > 0) {
                                let indexParts = answer.split(',')
                                for (let n = 0; n < indexParts.length; n++ ) {
                                    indexes.push(Number.parseInt(indexParts[n]))
                                }
                            } else {
                                indexes.push(Number.parseInt(answer))
                            }
            
                            for (let index = 0 ; index < indexes.length; index++) {
                                let indexValue = indexes[index]
                                if (indexValue >= 0 && indexValue < option.argChoices.length) {
                                    results.push(option.argChoices[indexValue])
                                }
                            }
            
                            let optionName = option.name()
                            data[optionName] = results.join(',')
                            resolve()
                            return
                        }
                        if (typeof option.defaultValue !== "undefined") {
                            let optionName = option.name()
                            data[optionName] = option.defaultValue
                        }
                        resolve()
                    });
                } else {
                    let defaultText: string = ''
                    if (typeof option.defaultValue !== "undefined") {
                        defaultText = ` (Default ${option.defaultValue})`
                    }
                    this.readline.question(`> ${option.description}${defaultText}:`, (answer: string) => {
                        let optionName = option.name()
                        if (answer?.length > 0) {
                            let parser = parse[optionName]
                            if ( typeof parser !== "undefined") {
                                data[optionName] = parser.parse(answer)
                                resolve()
                                return;
                            }

                            if (option.flags.indexOf("[") > 0 && answer.indexOf(',') > 0) {
                                data[optionName] = answer.split(',')
                            } else {
                                data[optionName] = answer
                            }  
                            resolve()  
                            return                        
                        }
                        if (typeof option.defaultValue !== "undefined") {
                            data[optionName] = option.defaultValue
                            resolve()
                            return;
                        }
                        resolve()
                    });
                }
                
            } catch ( err ) {
                console.log(err)
                this.logger?.error(err)
                reject()
            }   
        })
    }
}

export { 
    CoeCliCommands,
    TextParseFunction
};