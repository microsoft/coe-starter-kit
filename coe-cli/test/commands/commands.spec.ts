"use strict";
import CoeCliCommands from '../../src/commands/commands'
import { LoginCommand } from '../../src/commands/login'
import { AA4AMCommand } from '../../src/commands/aa4am'
import { RunCommand } from '../../src/commands/run'
import { CLICommand } from '../../src/commands/cli'
import * as msal from '@azure/msal-node';
import { mock } from 'jest-mock-extended';
import { DevOpsCommand } from '../../src/commands/devops';


describe('AA4AM', () => {

    test('Install aad', async () => {
        // Arrange
        var commands = new CoeCliCommands();
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
        var commands = new CoeCliCommands();
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
        var commands = new CoeCliCommands();
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

    test('Install - Multi Environment', async () => {
        // Arrange
        var commands = new CoeCliCommands();
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
        var commands = new CoeCliCommands();
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
});

describe('Run', () => {
    test('Execute', async () => {
        // Arrange
        var commands = new CoeCliCommands();
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
        var commands = new CoeCliCommands();
        let mockCliCommand = mock<CLICommand>(); 

        commands.createCliCommand = () => mockCliCommand
        mockCliCommand.add.mockResolvedValue()
        
        // Act
        await commands.execute(['node', 'commands.spec', 'cli', 'add', '-n', 'sample'])

        // Assert
        expect(mockCliCommand.add).toHaveBeenCalled()
    })
});

