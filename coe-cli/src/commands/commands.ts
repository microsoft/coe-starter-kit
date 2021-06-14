"use strict";
import commander, { command, Command, option, Option } from 'commander';
import { LoginCommand } from './login';
import { AA4AMBranchArguments, AA4AMInstallArguments, AA4AMUserArguments, AA4AMCommand } from './aa4am';
import { DevOpsInstallArguments, DevOpsCommand } from './devops';
import { RunArguments, RunCommand } from './run';
import { CLIArguments, CLICommand } from './cli';
import * as winston from 'winston';
import * as readline from 'readline';
import * as fs from 'fs';
import { FileHandle } from 'fs/promises';

interface TextParseFunction {
    parse: (text:string) => { [id: string] : string } | string | string[]
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
    readFile: (path: fs.PathLike | FileHandle, options: { encoding: BufferEncoding, flag?: fs.OpenMode } & fs.Abortable | BufferEncoding) => Promise<string>
    writeFile: (path: fs.PathLike | FileHandle, data: string | Uint8Array, options?: fs.BaseEncodingOptions & { mode?: fs.Mode, flag?: fs.OpenMode } & fs.Abortable | BufferEncoding | null) => Promise<void>
    
    
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

        aa4am.command('create')
            .description('Create key services')
            .addOption(createTypeOption)
            .action((options:any) => {
                this.setupLogger(options)
                let command = this.createAA4AMCommand()
                command.create(options.type);
            });

        aa4am.command('generate')
            .command('install')
            .option('-o, --output <name>', 'The output file to generate')
            .allowExcessArguments()
            .action(async (options:any) => {
                let parse : { [id: string] : TextParseFunction } = {}
                parse["environments"] = { parse: (text) => {
                    if (text?.length > 0 && text.indexOf('=') == 0) {
                        return text;
                    }
                    return this.parseSettings(text)
                 } }
                let results = await this.promptForValues(aa4am, 'install', parse)

                if (typeof results.environments === "undefined") {
                    results.environments = {
                        "validation": "contoso-validation",
                        "test": "contoso-test",
                        "prod": "contoso-prod"
                    }
                }
                if (typeof options.output === "string") {
                    this.writeFile(options.output, JSON.stringify(results, null, 2))
                } else {
                    console.log(JSON.stringify(results, null, 2))
                }
            })
    
        aa4am.command('install')
            .description('Initialize a new ALM Accelerators for Makers instance')
            .option('-f, --file <name>', 'The install configuration parameters file')
            .addOption(componentOption)
            .option('-a, --account <name>', 'The Azure Active directory account')
            .option('-d, --aad <name>', 'The azure active directory service principal application', 'ALMAcceleratorServicePrincipal')
            .option('-o, --devopsOrg <organization>', 'The Azure DevOps environment to create the user in')
            .option('-p, --project <name>', 'The Azure DevOps name', 'alm-sandbox')
            .option('-r, --repository <name>', 'The Azure DevOps pipeline repository', "pipelines")
            .option('-e, --environments [names]', 'The Power Platform environment(s) to configure either single or multiple in the format type=name,type2=name2 e.g. validation=org-validation,test=org-test,prod=org-test')
            .option('-s, --settings', 'Optional settings', "createSecret=true")
            .addOption(installOption)
            .addOption(installEndpoint)
            .action(async (options:any) => {
                this.setupLogger(options)
                let command = this.createAA4AMCommand()

                let args = new AA4AMInstallArguments()
                let settings: { [id: string] : string } = {}
                if (options.file?.length > 0) {
                    this.logger?.info("Loading configuration")
                    let optionsFile = JSON.parse(await this.readFile(options.file, { encoding: 'utf-8' }))
                    if ( Array.isArray(optionsFile.environments) ) {
                        optionsFile.environments = optionsFile.environments.join(',')
                    }
                    
                    this.copyValues(optionsFile, args)   
                    settings = this.parseSettings(optionsFile.settings)
                } else {
                    args.components = options.components
                    args.account = options.account
                    args.azureActiveDirectoryServicePrincipal = options.aad
                    args.organizationName = options.devopsOrg
                    args.project = options.project
                    args.repository = options.repository
                    args.powerPlatformOrganization = options.powerPlatformOrg
                    if (options.environments?.length > 0 && options.environments?.indexOf('=')>0) {
                        args.environments = this.parseSettings(options.environments)
                        args.environment = ''
                    } else {
                        args.environment = options.environments
                    }
                    args.importMethod = options.importMethod
                    args.endpoint = options.endpoint
                    settings = this.parseSettings(options.settings)
                }
                args.createSecretIfNoExist = typeof settings["createSecret"] == "undefined" || settings["createSecret"]?.toLowerCase() == "true"
                await command.install(args);
            });

        let fix = aa4am.command('fix')
            .description('Attempt to fix install components')
                   
        fix.command('build')
            .description('Attempt to build components')
            .option('-o, --devopsOrg <organization>', 'The Azure DevOps environment validate')
            .option('-p, --project <name>', 'The Azure DevOps name')
            .addOption(installEndpoint)
            .option('-r, --repository <name>', 'The Azure DevOps pipeline repository', "pipelines").action(async (options:any) => {
                this.setupLogger(options)
                let login = this.createLoginCommand()
                let command = this.createDevOpsCommand()
                let args = new DevOpsInstallArguments()
                args.organizationName = options.devopsOrg
                args.projectName = options.project
                args.repositoryName = options.repository
                args.accessTokens = await login.azureLogin(["499b84ac-1321-427f-aa17-267ca6975798"])
                args.endpoint = options.endpoint

                await command.createAdvancedMakersBuildPipelines(args, null, null)
            })

        let connection = aa4am.command('connection')
            .description('Manage connections')
        
        connection.command("add")
            .description("Add a new connection")
            .requiredOption('-o, --organization <name>', 'The Azure DevOps organization')
            .requiredOption('-p, --project <name>', 'The Azure DevOps project to add to')
            .requiredOption('-e, --environment <name>', 'The environment add conection to')
            .addOption(installEndpoint)
            .option('-a, --aad <name>', 'The azure active directory service principal application', 'ALMAcceleratorServicePrincipal')
            .action(async (options:any) => {
                this.setupLogger(options)
                let login = this.createLoginCommand()
                let command = this.createDevOpsCommand()
                let args = new DevOpsInstallArguments()
                args.organizationName = options.organization
                args.clientId = options.clientid
                if (typeof options.aad !== "undefined") {
                    args.azureActiveDirectoryServicePrincipal = options.aad
                }
                args.projectName = options.project
                args.environment = options.environment
                args.clientId = options.clientid
                args.accessTokens = await login.azureLogin(["499b84ac-1321-427f-aa17-267ca6975798"])
                args.endpoint = options.endpoint
                                                       
                try {
                    await command.createAdvancedMakersServiceConnections(args, null)
                } catch (err) {
                    this.logger?.error(err)
                }
                
            })
       
        let user = aa4am.command('user')
            .description('Create Admin user in Dataverse Environment')
        
        user.command("add")
            .requiredOption('-e, --environment <organization>', 'The environment to create the user in')
            .requiredOption('-i, --id <id>', 'The unique identifier of the user')
            .option('-r, --role <name>', 'The user role', 'System Administrator')
            .action((options: any) => {
                this.setupLogger(options)
                let command = this.createAA4AMCommand()
                let args = new AA4AMUserArguments();
                args.command = options.command
                args.id = options.id
                args.environment = options.environment
                args.role = options.role
                command.addUser(args);
            });

        aa4am.command('branch')
            .description('Create a new Application Branch')
            .option('-o, --organization <name>', 'The Azure DevOps Organization name')
            .option('-r, --repository <name>', 'The Azure DevOps name')
            .option('-p, --project <name>', 'The Azure DevOps name')
            .option('-s, --source <name>', 'The source branch to copy from')
            .option('-sb, --source-build <name>', 'The source build to copy from')
            .option('-d, --destination <name>', 'The branch to create')
            .action(async (options: any) : Promise<void> => {
                this.setupLogger(options)
                let args = new AA4AMBranchArguments();
                args.organizationName = options.organization
                args.repositoryName = options.repository
                args.projectName = options.project
                args.sourceBranch = options.source
                args.sourceBuildName = options.sourceBuild
                args.destinationBranch = options.destination

                let command = this.createAA4AMCommand()
                await command.branch(args)
                return Promise.resolve()
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
            });
    }

    parseSettings(setting: string) : { [id: string] : string } {
        let result : { [id: string] : string } = {}
        let arr = setting?.split(',');
        arr?.forEach(el => {
            if (el.indexOf('=') > -1) {
              const keyVal = el.split('=');
              result[keyVal[0].toLowerCase()] = keyVal[1]
            }
          });
        return result;
    } 

    copyValues(source: any, destination: any) {
        let sourceKeys = Object.keys(source)

        for ( let i = 0; i < sourceKeys.length; i++ ) {
            destination[sourceKeys[i]] = source[sourceKeys[i]]
        }
    }

    async promptForValues(command: commander.Command, name: string, parse:  { [id: string] : TextParseFunction }) : Promise<any> {
        let values: any = {}
        let match = command.commands.filter( (c: commander.Command) => c.name() == name)
        if (match.length == 1) {
            let options : Option[] = <Option[]>(<any>match[0]).options
            this.logger?.info(`Please provide your ${name} options`)
            for ( var i = 0; i < options.length ; i++ ) {
                await new Promise((resolve) => {
                    if (options[i].argChoices?.length > 0) {
                        console.log(`> Which choices for ${options[i].description}`)
                        for ( let c = 0; c < options[i].argChoices.length; c++) {
                            console.log(`  ${c}: ${options[i].argChoices[c]}`)
                        }
                        if (typeof options[i].defaultValue !== "undefined") {
                            console.log(`Default value(s) ${options[i].defaultValue}`)
                        }
                        this.readline.question(`+ Your selection(s) seperated by commas:`, (answer: string) => {
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
                                    if (indexValue >= 0 && indexValue < options[i].argChoices.length) {
                                        results.push(options[i].argChoices[indexValue])
                                    }
                                }

                                let optionName = options[i].name()
                                values[optionName] = results
                                resolve(results)
                                return
                            }
                            if (typeof options[i].defaultValue !== "undefined") {
                                let optionName = options[i].name()
                                values[optionName] = options[i].defaultValue
                            }
                            resolve(options[i].defaultValue)
                        });
                    } else {
                        let defaultText: string = ''
                        if (typeof options[i].defaultValue !== "undefined") {
                            defaultText = ` (Default ${options[i].defaultValue})`
                        }
                        this.readline.question(`> ${options[i].description} ${options[i].flags}${defaultText}:`, (answer: string) => {
                            let optionName = options[i].name()
                            if (answer?.length > 0) {
                                let parser = parse[optionName]
                                if ( typeof parser !== "undefined") {
                                    values[optionName] = parser.parse(answer)
                                    resolve(answer)
                                    return;
                                }
    
                                if (options[i].flags.indexOf("[") > 0 && answer.indexOf(',') > 0) {
                                    values[optionName] = answer.split(',')
                                } else {
                                    values[optionName] = answer
                                }    
                                resolve(answer)
                                return                        
                            }
                            if (typeof options[i].defaultValue !== "undefined") {
                                values[optionName] = options[i].defaultValue
                                resolve(options[i].defaultValue)
                                return;
                            }
                            resolve(answer)
                        });
                    }
                })  
            }
            this.readline.close()
        }
        return values
    }
}

export { 
    CoeCliCommands,
    TextParseFunction
};