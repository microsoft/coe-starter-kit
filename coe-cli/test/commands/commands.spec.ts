"use strict";
import { CoeCliCommands, TextParseFunction } from '../../src/commands/commands'
import { LoginCommand } from '../../src/commands/login'
import { AA4AMCommand } from '../../src/commands/aa4am'
import { RunCommand } from '../../src/commands/run'
import { CLICommand } from '../../src/commands/cli'
import { mock } from 'jest-mock-extended';
import { DevOpsCommand } from '../../src/commands/devops';
import winston from 'winston';
import readline = require('readline');
import commander, { command, Command, Option } from 'commander';
import * as fs from 'fs';
import { Prompt } from '../../src/common/prompt';

describe('AA4AM', () => {

    test('Install aad', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        let mockAA4AMCommand = mock<AA4AMCommand>(); 
        commands.createAA4AMCommand = () => mockAA4AMCommand;

        mockAA4AMCommand.install.mockReturnValue(Promise.resolve())

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'install', '-c', 'aad', '-a', '123'])

        // Assert
        expect(mockAA4AMCommand.install).toHaveBeenCalled()
        expect(JSON.stringify(mockAA4AMCommand.install.mock.calls[0][0].components)).toBe(JSON.stringify(['aad']))
        expect(mockAA4AMCommand.install.mock.calls[0][0].account).toBe("123")
        expect(mockAA4AMCommand.install.mock.calls[0][0].azureActiveDirectoryServicePrincipal).toBe("ALMAcceleratorServicePrincipal")
    })

    test('User', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        let mockAA4AMCommand = mock<AA4AMCommand>(); 
        commands.createAA4AMCommand = () => mockAA4AMCommand;

        mockAA4AMCommand.install.mockReturnValue(Promise.resolve())

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'user', 'add', '-e', 'E1', '-i', '123'])

        // Assert
        expect(mockAA4AMCommand.addUser).toHaveBeenCalled()
        expect(mockAA4AMCommand.addUser.mock.calls[0][0].environment).toBe('E1')
        expect(mockAA4AMCommand.addUser.mock.calls[0][0].id).toBe('123')
        expect(mockAA4AMCommand.addUser.mock.calls[0][0].role).toBe('System Administrator')
    })

    test('Install', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        let mockAA4AMCommand = mock<AA4AMCommand>(); 
        commands.createAA4AMCommand = () => mockAA4AMCommand;

        mockAA4AMCommand.install.mockReturnValue(Promise.resolve())

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'install', '-a', '123', '-o', 'testorg', '-p', 'alm-sandbox', '-e', 'crm-org', "-r", "repo1"])

        // Assert
        expect(mockAA4AMCommand.install).toHaveBeenCalled()
        expect(mockAA4AMCommand.install.mock.calls[0][0].account).toBe("123")
        expect(mockAA4AMCommand.install.mock.calls[0][0].organizationName).toBe("testorg")
        expect(mockAA4AMCommand.install.mock.calls[0][0].project).toBe("alm-sandbox")
        expect(mockAA4AMCommand.install.mock.calls[0][0].environment).toBe("crm-org")
        expect(mockAA4AMCommand.install.mock.calls[0][0].repository).toBe("repo1")
        expect(mockAA4AMCommand.install.mock.calls[0][0].createSecretIfNoExist).toBe(true)
    })

    test('Install - File', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger, null, {
            readFile: () => Promise.resolve(`{
                "account": "123",
                "organizationName": "testorg",
                "project": "alm-sandbox",
                "environment": "crm-org",
                "repository": "repo1"
            }`)
        });
        let mockAA4AMCommand = mock<AA4AMCommand>(); 
        commands.createAA4AMCommand = () => mockAA4AMCommand;

        mockAA4AMCommand.install.mockReturnValue(Promise.resolve())

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'install', '-f', 'test.json'])

        // Assert
        expect(mockAA4AMCommand.install).toHaveBeenCalled()
        expect(mockAA4AMCommand.install.mock.calls[0][0].account).toBe("123")
        expect(mockAA4AMCommand.install.mock.calls[0][0].organizationName).toBe("testorg")
        expect(mockAA4AMCommand.install.mock.calls[0][0].project).toBe("alm-sandbox")
        expect(mockAA4AMCommand.install.mock.calls[0][0].environment).toBe("crm-org")
        expect(mockAA4AMCommand.install.mock.calls[0][0].repository).toBe("repo1")
        expect(mockAA4AMCommand.install.mock.calls[0][0].createSecretIfNoExist).toBe(true)
    })

    test('Install - Multi Environment', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        let mockAA4AMCommand = mock<AA4AMCommand>(); 
        commands.createAA4AMCommand = () => mockAA4AMCommand;

        mockAA4AMCommand.install.mockReturnValue(Promise.resolve())

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'install', '-a', '123', '-o', 'testorg', '-p', 'alm-sandbox', "-r", "repo1", "-e", "validation=test1,test=test2"])

        // Assert
        expect(mockAA4AMCommand.install).toHaveBeenCalled()
        expect(mockAA4AMCommand.install.mock.calls[0][0].account).toBe("123")
        expect(mockAA4AMCommand.install.mock.calls[0][0].organizationName).toBe("testorg")
        expect(mockAA4AMCommand.install.mock.calls[0][0].project).toBe("alm-sandbox")
        expect(mockAA4AMCommand.install.mock.calls[0][0].environment).toBe("")
        expect(mockAA4AMCommand.install.mock.calls[0][0].repository).toBe("repo1")
        expect(mockAA4AMCommand.install.mock.calls[0][0].environments["validation"]).toBe("test1")
        expect(mockAA4AMCommand.install.mock.calls[0][0].environments["test"]).toBe("test2")
        expect(mockAA4AMCommand.install.mock.calls[0][0].createSecretIfNoExist).toBe(true)
    })

    test('Add Connection', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        let mockLoginCommand = mock<LoginCommand>(); 
        let mockDevOpsCommand = mock<DevOpsCommand>(); 
        commands.createLoginCommand = () => mockLoginCommand;
        commands.createDevOpsCommand = () => mockDevOpsCommand;

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'connection', 'add', '-e', 'E1', '-o', 'O1', '-p', 'P1'])

        // Assert
        expect(mockLoginCommand.azureLogin).toHaveBeenCalled()
        expect(mockDevOpsCommand.createAdvancedMakersServiceConnections).toHaveBeenCalled()
        expect(mockDevOpsCommand.createAdvancedMakersServiceConnections.mock.calls[0][0].environment).toBe("E1")
        expect(mockDevOpsCommand.createAdvancedMakersServiceConnections.mock.calls[0][0].organizationName).toBe("O1")
        expect(mockDevOpsCommand.createAdvancedMakersServiceConnections.mock.calls[0][0].projectName).toBe("P1")
    })
})

describe('Prompt For Values', () => {
    test('Generate Text property', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline = mock<readline.ReadLine>()
        var commands = new CoeCliCommands(logger, readline);
        let mockLoginCommand = mock<LoginCommand>(); 
        let mockDevOpsCommand = mock<DevOpsCommand>(); 
        commands.createLoginCommand = () => mockLoginCommand;
        commands.createDevOpsCommand = () => mockDevOpsCommand;
        commands.outputText = (text) => {}

        readline.question.mockImplementation((prompt: string, callback: (answer: string) => void) => {
            callback('foo')
        })

        const program = new Command();
        program.command('install')
            .option("-m, mode <name>", "Mode name")

        // Act
        let result = await commands.promptForValues(program, 'install', {})

        // Assert
        expect(result.mode).toBe("foo")
        expect(readline.close).toBeCalledTimes(1)
    })

    test('Generate sub settings', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline = mock<readline.ReadLine>()
        var commands = new CoeCliCommands(logger, readline);
        let mockLoginCommand = mock<LoginCommand>(); 
        let mockDevOpsCommand = mock<DevOpsCommand>(); 
        commands.createLoginCommand = () => mockLoginCommand;
        commands.createDevOpsCommand = () => mockDevOpsCommand;
        commands.outputText = (text) => {}

        readline.question.mockImplementation((prompt: string, callback: (answer: string) => void) => {
            if (prompt.indexOf('mode') >= 0) {
                callback('foo')
            }

            if (prompt.indexOf('item1') >= 0) {
                callback('test1')
            }

            callback('')
        })

        const program = new Command();
        let install = program.command('install')
        install.option("-m, --mode <name>", "Mode name")
        install.option("-s, --settings <settings>", "Optional settings")

        const settings = new Command()
            .command('settings')
        settings.option("-i, --item1", "Item 1");          

        // Act
        let result = await commands.promptForValues(program, 'install', { 'settings': {
            parse: (text) => text,
            command: settings
        } })

        // Assert
        expect(result.mode).toBe("foo")
        expect(result.settings['item1']).toBe("test1")
        expect(readline.close).toBeCalledTimes(1)
    })

    test('Generate Array property', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline = mock<readline.ReadLine>()
        var commands = new CoeCliCommands(logger, readline);
        let mockLoginCommand = mock<LoginCommand>(); 
        let mockDevOpsCommand = mock<DevOpsCommand>(); 
        commands.createLoginCommand = () => mockLoginCommand;
        commands.createDevOpsCommand = () => mockDevOpsCommand;
        commands.outputText = (text:string) => {}

        readline.question.mockImplementation((prompt: string, callback: (answer: string) => void) => {
            callback('1,2')
        })

        const program = new Command();
        program.command('install')
            .option("-m, modes [name]", "Mode name")

        // Act
        let result = await commands.promptForValues(program, 'install', {})

        // Assert
        expect(JSON.stringify(result.modes)).toBe(JSON.stringify(["1", "2"]))
        expect(readline.close).toBeCalledTimes(1)
    })

    test('Generate Option - Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline = mock<readline.ReadLine>()
        var commands = new CoeCliCommands(logger, readline);
        let mockLoginCommand = mock<LoginCommand>(); 
        let mockDevOpsCommand = mock<DevOpsCommand>(); 
        commands.createLoginCommand = () => mockLoginCommand;
        commands.createDevOpsCommand = () => mockDevOpsCommand;
        commands.outputText = (text:string) => {}

        readline.question.mockImplementation((prompt: string, callback: (answer: string) => void) => {
            callback('')
        })

        let componentOption = new Option('-c, --components [component]', 'The component(s) to install').default(["A"]).choices(['A', 'B', 'C', 'D']);

        const program = new Command();
        program.command('install')
            .addOption(componentOption)

        // Act
        let result = await commands.promptForValues(program, 'install', {})

        // Assert
        expect(JSON.stringify(result.components)).toBe(JSON.stringify(["A"]))
        expect(readline.close).toBeCalledTimes(1)
    })
});

describe('Run', () => {
    test('Execute', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        let mockRunCommand = mock<RunCommand>(); 

        commands.createRunCommand = () => mockRunCommand
        mockRunCommand.execute.mockResolvedValue()
        
        // Act
        await commands.execute(['node', 'commands.spec', 'run', '-f', 'test.json'])

        // Assert
        expect(mockRunCommand.execute).toHaveBeenCalled()
    })
});

describe('CLI', () => {
    test('Execute', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        let mockCliCommand = mock<CLICommand>(); 

        commands.createCliCommand = () => mockCliCommand
        mockCliCommand.add.mockResolvedValue()
        
        // Act
        await commands.execute(['node', 'commands.spec', 'cli', 'add', '-n', 'sample'])

        // Assert
        expect(mockCliCommand.add).toHaveBeenCalled()
    })
});
