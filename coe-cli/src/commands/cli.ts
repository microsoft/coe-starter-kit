"use strict";
import * as path from 'path'
import * as fs from 'fs';
import { Project, ts } from "ts-morph";
import pascalcase = require('pascalcase');
import open = require('open');
const fsPromises = fs.promises;
import * as winston from 'winston';


/**
 * CLI commands
 */
class CLICommand {
    public writeFile: (name: string, content: string) => Promise<void>
    logger: winston.Logger

    constructor(logger: winston.Logger) {
        this.logger = logger
        this.writeFile = async (name: string, content: string) => await fsPromises.writeFile(name, content)
    }

     /**
     * Open the about page for the cli
     */
    async about() : Promise<void> {
        await open('https://aka.ms/coe-cli')
    }

    /**
     * Add a new script command
     * @param args 
     * @returns 
     */
    async add(args: CLIArguments) : Promise<void> {
        await this.createScript('source', args.name);
        await this.createScript('test', args.name);

        // TODO: Update commands.ts to include new command
        const project = new Project({ compilerOptions: { outDir: "dist", declaration: true, target: ts.ScriptTarget.Latest } });
        project.addSourceFilesAtPaths("src/**/*{.d.ts,.ts}");
        const sourceFile = project.getSourceFileOrThrow(path.join(process.cwd(), 'src/commands/commands.ts'));

        // TODO: Update commands.spec.ts to test new comamnd

        var imports = sourceFile.getImportDeclarations()

        await sourceFile.emit(); 
    }

    async createScript(type: string, name: string) : Promise<void> {
        let newCommandName = pascalcase(name)
    
        if (type == 'source')
        {
            let commmandScript = path.join(process.cwd(), `src/commands/${name.toLowerCase()}.ts`)
    
            if (!fs.existsSync(commmandScript)) {
                this.logger?.info(`Creating ${commmandScript}`)
                await this.writeFile(commmandScript, `"use strict";
import * as winston from 'winston';

/**
 * ${newCommandName} commands
 */
class ${newCommandName}Command {
    logger: winston.Logger
    
    constructor(logger: winston.Logger) {
        this.logger = logger
    }

    /**
     * Execute the command
     * @param args 
     * @returns 
     */
    async execute(args: ${newCommandName}Arguments) : Promise<void> {
        this.logger?.info(args.comments)
        return Promise.resolve();
    }
}

/**
 * Ebook Command Arguments
 */
 class EbookArguments {
    /**
     * Some text argument
     */
    comments: string
}

export { 
    ${newCommandName}Arguments,
    ${newCommandName}Command
};`)
            } else {
                this.logger?.info('Script file already exists')
            }    
        }
    
        if (type == 'test')
        {
            let commmandScript = path.join(process.cwd(), `test/commands/${name.toLowerCase()}.spec.ts`)
            
            if (!fs.existsSync(commmandScript)) {
                this.logger?.info(`Creating ${commmandScript}`)
                await this.writeFile(commmandScript, `"use strict";
import { ${newCommandName}Arguments, ${newCommandName}Command } from '../../src/commands/${name.toLowerCase()}';
import { mock } from 'jest-mock-extended';
import winston from 'winston';
            
describe('Related Tests', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new ${newCommandName}Command(logger);
        let args = new ${newCommandName}Arguments();
    
        // Act
        
        await command.execute(args)

        // Assert
    })
});
    `)
            } else {
                this.logger?.info('Test script file already exists')
            }    
        }
    }
    
}

/**
 * CLI Command Arguments
 */
 class CLIArguments {
    /**
     * Some text argument
     */
    name: string
}

export { 
    CLIArguments,
    CLICommand
};