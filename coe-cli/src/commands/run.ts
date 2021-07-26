"use strict";
import * as path from 'path'
import * as fs from 'fs';
import { CoeCliCommands } from './commands'
import * as winston from 'winston';

/**
 * Run commands
 */
class RunCommand {
    creatCoeCliCommands: () => CoeCliCommands
    logger: winston.Logger
  
    constructor(logger: winston.Logger) {
        this.logger = logger
        this.creatCoeCliCommands = () => { 
            let command = new CoeCliCommands(this.logger)
            command.logger = this.logger
            return command
        }
    }

    /**
     * Execute the command
     * @param args 
     * @returns 
     */
    async execute(args: RunArguments) : Promise<void> {
        let configFile = path.isAbsolute(args.file) ? args.file : path.join(process.cwd(), args.file)
        let json = await fs.promises.readFile(args.file, 'utf8')

        let data : any[] = JSON.parse(json)
        
        let commands : RunCommandInfo[] = []

        for ( let i=0; i < data.length; i++ ) {
            commands.push(<RunCommandInfo>data[i])
        }

        let executor = this.creatCoeCliCommands();

        for ( var i = 0; i < commands.length; i++) {
            this.logger?.info(`Running ${commands[i].name}`)
            let childArgs : string[] = []
            childArgs.push('node')
            childArgs.push('run')
            commands[i].args?.forEach(arg => childArgs.push(arg))
            await executor.execute(childArgs)
        }
    }
}


/**
 * Run Command Arguments
 */
 class RunArguments {
    /**
     * Some text argument
     */
    file: string
}

/**
 * Run Command Arguments
 */
 class RunCommandInfo {
    /**
     * Some text argument
     */
    name: string
    args: string[]
}


export { 
    RunArguments,
    RunCommand
};