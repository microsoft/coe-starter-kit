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
import { Command, Option } from 'commander';
import { OpenMode, PathLike } from 'fs';
import { FileHandle } from 'fs/promises';

describe('AA4AM', () => {

    test('Install aad', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        commands.outputText = (text:string) => {}

        let mockAA4AMCommand = mock<AA4AMCommand>(); 
        commands.createAA4AMCommand = () => mockAA4AMCommand;

        mockAA4AMCommand.install.mockReturnValue(Promise.resolve())

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'install', '-c', 'aad', '--subscription=123'])

        // Assert
        expect(mockAA4AMCommand.install).toHaveBeenCalled()
        expect(JSON.stringify(mockAA4AMCommand.install.mock.calls[0][0].components)).toBe(JSON.stringify(['aad']))

        expect(mockAA4AMCommand.install.mock.calls[0][0].subscription).toBe("123")
        expect(mockAA4AMCommand.install.mock.calls[0][0].azureActiveDirectoryServicePrincipal).toBe("ALMAcceleratorServicePrincipal")
    })

    test('User', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        commands.outputText = (text:string) => {}

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
        commands.outputText = (text:string) => {}

        let mockAA4AMCommand = mock<AA4AMCommand>(); 
        commands.createAA4AMCommand = () => mockAA4AMCommand;

        mockAA4AMCommand.install.mockReturnValue(Promise.resolve())

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'install', '--subscription', '123', '-o', 'testorg', '-p', 'alm-sandbox', '--environments', 'crm-org', "-r", "repo1"])

        // Assert
        expect(mockAA4AMCommand.install).toHaveBeenCalled()
        expect(mockAA4AMCommand.install.mock.calls[0][0].subscription).toBe("123")
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
        commands.outputText = (text:string) => {}

        let mockAA4AMCommand = mock<AA4AMCommand>(); 
        commands.createAA4AMCommand = () => mockAA4AMCommand;

        mockAA4AMCommand.install.mockReturnValue(Promise.resolve())

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'install', '-f', 'test.json'])

        // Assert
        expect(mockAA4AMCommand.install).toHaveBeenCalled()
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
        commands.outputText = (text:string) => {}

        let mockAA4AMCommand = mock<AA4AMCommand>(); 
        commands.createAA4AMCommand = () => mockAA4AMCommand;

        mockAA4AMCommand.install.mockReturnValue(Promise.resolve())

        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'install', '--subscription=123', '-o', 'testorg', '-p', 'alm-sandbox', "-r", "repo1", "-e", "validation=test1,test=test2"])

        // Assert
        expect(mockAA4AMCommand.install).toHaveBeenCalled()
        expect(mockAA4AMCommand.install.mock.calls[0][0].subscription).toBe("123")
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
        commands.outputText = (text:string) => {}

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
        let readline : any = { 
            question: (prompt: string, callback: (answer: string) => void) => {
                callback('foo')
            }
        }
        var commands = new CoeCliCommands(logger, null);
        commands.readline = readline
        let mockLoginCommand = mock<LoginCommand>(); 
        let mockDevOpsCommand = mock<DevOpsCommand>(); 
        commands.createLoginCommand = () => mockLoginCommand;
        commands.createDevOpsCommand = () => mockDevOpsCommand;
        commands.outputText = (text) => {}

        const program = new Command();
        program.command('install')
            .option("-m, mode <name>", "Mode name")

        // Act
        let result = await commands.promptForValues(program, 'install', [], [], {})

        // Assert
        expect(result.mode).toBe("foo")
    })

    
    test('Generate sub settings', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline : any = { 
            question: (prompt: string, callback: (answer: string) => void) => {
            if (prompt.indexOf('Mode') >= 0) {
                callback('foo')
                return
            }

            if (prompt.indexOf('Item 1') >= 0) {
                callback('test1')
                return
            }

            callback('')
        }}
        var commands = new CoeCliCommands(logger, null);
        commands.readline = readline
        let mockLoginCommand = mock<LoginCommand>(); 
        let mockDevOpsCommand = mock<DevOpsCommand>(); 
        commands.createLoginCommand = () => mockLoginCommand;
        commands.createDevOpsCommand = () => mockDevOpsCommand;
        commands.outputText = (text) => {}


        const program = new Command();
        let install = program.command('install')
        install.option("-m, --mode <name>", "Mode name")
        install.option("-s, --settings <settings>", "Optional settings")

        const settings = new Command()
            .command('settings')
        settings.option("-i, --item1", "Item 1");          

        // Act
        let result = await commands.promptForValues(program, 'install', [], [], { 'settings': {
            parse: (text) => text,
            command: settings
        } })

        // Assert
        expect(result.mode).toBe("foo")
        expect(result.settings['item1']).toBe("test1")
    })



    test('Generate Array property', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline : any = {
            question: (prompt: string, callback: (answer: string) => void) => {
                callback('1,2')
            }
        }
        var commands = new CoeCliCommands(logger, null);
        commands.readline = readline
        let mockLoginCommand = mock<LoginCommand>(); 
        let mockDevOpsCommand = mock<DevOpsCommand>(); 
        commands.createLoginCommand = () => mockLoginCommand;
        commands.createDevOpsCommand = () => mockDevOpsCommand;
        commands.outputText = (text:string) => {}

        const program = new Command();
        program.command('install')
            .option("-m, modes [name]", "Mode name")

        // Act
        let result = await commands.promptForValues(program, 'install', [], [], {})

        // Assert
        expect(JSON.stringify(result.modes)).toBe(JSON.stringify(["1", "2"]))
    })

    test('Generate Option - Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline : any = {
            question: (prompt: string, callback: (answer: string) => void) => {
                callback('')
            }
        }
        var commands = new CoeCliCommands(logger, null);
        commands.readline = readline
        let mockLoginCommand = mock<LoginCommand>(); 
        let mockDevOpsCommand = mock<DevOpsCommand>(); 
        commands.createLoginCommand = () => mockLoginCommand;
        commands.createDevOpsCommand = () => mockDevOpsCommand;
        commands.outputText = (text:string) => {}

        let componentOption = new Option('-c, --components [component]', 'The component(s) to install').default(["A"]).choices(['A', 'B', 'C', 'D']);

        const program = new Command();
        program.command('install')
            .addOption(componentOption)

        // Act
        let result = await commands.promptForValues(program, 'install', [], [], {})

        // Assert
        expect(JSON.stringify(result.components)).toBe(JSON.stringify(["A"]))
    })
});

describe('Prompt for Option', () => {
    test('Default Value', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline : any = {
            question: ( title:string, callback: (answer: string) => void) => {
                callback('')
            }
        }
        var commands = new CoeCliCommands(logger, null);
        commands.readline = readline
        commands.outputText = (text:string) => {}

        let option = <Option> {
            description: 'Option1',
            argChoices: [],
            name: () => { return "option1"},
            defaultValue: 'ABC'

        }

        let data : any = {}

        // Act
        await commands.promptOption('', [], option, data, {})

        // Assert
        expect(data.option1).toBe('ABC')
    })

    test('Single Arg', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline : any = {
            question: ( title:string, callback: (answer: string) => void) => {
                callback('a')
            }
        }
        var commands = new CoeCliCommands(logger, null);
        commands.readline = readline
        commands.outputText = (text:string) => {}

        let option = <Option> {
            description: 'Option1',
            argChoices: [],
            name: () => { return "option1"}
        }

        let data : any = {}

        // Act
        await commands.promptOption('', [], option, data, {})

        // Assert
        expect(data.option1).toBe('a')
    })

    test('Single Arg - Help', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline : any = {
            question: ( title:string, callback: (answer: string) => void) => {
                call++
                if (call == 1) {
                    callback('?')
                }
                else {
                    callback('a')
                }
            }
        }
        var commands = new CoeCliCommands(logger, null);
        let output: string[] = []
        commands.outputText = (text)=> output.push(text)
        commands.readline = readline

        commands.existsSync = (path: PathLike) => true
        commands.readFile = (path: PathLike | FileHandle, options: { encoding: BufferEncoding, flag?: OpenMode } | BufferEncoding) => {
            return Promise.resolve(`# Test

## Options

### --option1
Some text

### --next

Other`)
         }

        let call : number = 0

        let option = <Option> {
            description: 'Option1',
            argChoices: [],
            long: 'name',
            flags: '--foo',
            name: () => { return "option1"}
        }

        let data : any = {}

        // Act
        await commands.promptOption('help/foo.md', [], option, data, {})

        // Assert
        expect(data.option1).toBe('a')
        expect(output.filter((text: string) => text.indexOf("Some text")>= 0).length).toBe(1)
    })

    test('Array', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline : any = {
            question: ( title:string, callback: (answer: string) => void) => {
                callback('a,b')
            }
        }
        var commands = new CoeCliCommands(logger, null);
        commands.readline = readline
        commands.outputText = (text:string) => {}

        let option = <Option> {
            description: 'Option1',
            flags: '--value [values]',
            argChoices: [],
            name: () => { return "option1"}
        }

        let data : any = {}

        // Act
        await commands.promptOption('', [], option, data, {})

        // Assert
        expect(JSON.stringify(data.option1)).toBe(JSON.stringify(['a','b']))
    })

    test('Args - Select Multiple', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline : any = {
            question:( title:string, callback: (answer: string) => void) => {
                callback('0,1')
            }
        }
        var commands = new CoeCliCommands(logger, null);
        commands.readline = readline
        commands.outputText = (text:string) => {}

        let option = <Option> {
            description: 'Option1',
            flags: '--value [values]',
            argChoices: [ 'Arg 1', 'Arg 2', 'Arg 3' ],
            name: () => { return "option1"}
        }

        let data : any = {}

        // Act
        await commands.promptOption('', [], option, data, {})

        // Assert
        expect(data.option1).toBe('Arg 1,Arg 2')
    })

    test('Args - Select Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let readline : any = {
            question: ( title:string, callback: (answer: string) => void) => {
                callback('')
            }
        }
        var commands = new CoeCliCommands(logger, null);
        commands.readline = readline
        commands.outputText = (text:string) => {}

        let option = <Option> {
            description: 'Option1',
            flags: '--value [values]',
            argChoices: [ 'Arg 1', 'Arg 2', 'Arg 3' ],
            name: () => { return "option1"},
            defaultValue: [ 'Arg 1' ],
        }

        let data : any = {}

        // Act
        await commands.promptOption('', [], option, data, {})

        // Assert
        expect(JSON.stringify(data.option1)).toBe(JSON.stringify(['Arg 1']))
    })
})

describe('Run', () => {
    test('Execute', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        commands.outputText = (text:string) => {}
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

describe('Help', () => {
    test('Main', async () => {
        await expectFile(['node', 'commands.spec', 'help'], 'help\\readme.md')
    })

    test('aa4am', async () => {
        await expectFile(['node', 'commands.spec', 'help', 'aa4am'], 'help\\aa4am\\readme.md')
    })

    test('aa4am genenerate', async () => {
        await expectFile(['node', 'commands.spec', 'help', 'aa4am', 'generate'], 'help\\aa4am\\generate\\readme.md')
    })
    
    test('aa4am genenerate install', async () => {
        await expectFile(['node', 'commands.spec', 'help', 'aa4am', 'generate', 'install'], 'help\\aa4am\\generate\\install.md')
    })

    test('aa4am install', async () => {
        await expectFile(['node', 'commands.spec', 'help', 'aa4am', 'install'], 'help\\aa4am\\install.md')
    })
});

describe('Branch', () => {
    test('Main', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var commands = new CoeCliCommands(logger);
        commands.outputText = (text:string) => {}
        let mockAA4AMCommand = mock<AA4AMCommand>(); 

        commands.createAA4AMCommand = () => mockAA4AMCommand
        mockAA4AMCommand.branch.mockResolvedValue()
        
        // Act
        await commands.execute(['node', 'commands.spec', 'aa4am', 'branch', '-o', 'https://dev.azure.com/contoso', '-p', 'alm-sandbox', '--pipelineRepository', 'templates', '-d', 'NewSolution1'])

        // Assert
        expect(mockAA4AMCommand.branch).toHaveBeenCalled()
    })
});

const expectFile = async (args: string[], name: string) : Promise<void> => {
    // Arrange
    let logger = mock<winston.Logger>()
    var commands = new CoeCliCommands(logger);
    let readFileName = ''

    commands.readFile = (path: PathLike | FileHandle, options: { encoding: BufferEncoding, flag?: OpenMode } | BufferEncoding) => {
       readFileName = <string>path
       return Promise.resolve('')
    }
    commands.outputText = (text) => {}
   
    // Act
    await commands.execute(args)

    // Assert
    expect(readFileName.indexOf(name) >= 0).toBeTruthy()
}