"use strict";
import { AA4AMBranchArguments, AA4AMCommand, AA4AMInstallArguments, AA4AMMakerAddArguments, AA4AMUserArguments } from '../../src/commands/aa4am';
import { LoginCommand } from '../../src/commands/login';
import { DevOpsCommand } from '../../src/commands/devops';
import { mock } from 'jest-mock-extended';
import DynamicsWebApi = require('dynamics-web-api');
import { AADCommand } from '../../src/commands/aad';
import { AxiosStatic } from 'axios';
import winston = require('winston');
import { GitHubCommand } from '../../src/commands/github';
import { PowerPlatformCommand } from '../../src/commands/powerplatform';

describe('Install - AAD', () => {
    test('No command', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AA4AMCommand(logger);
        let mockLogin = mock<LoginCommand>()

        command.createLoginCommand = () => mockLogin

                // Act
        let args = new AA4AMInstallArguments();
        await command.install(args)

        // Assert
        
    })

    test('Called', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AA4AMCommand(logger);

        const mockedLoginCommand = mock<LoginCommand>();
        command.createLoginCommand = () => mockedLoginCommand
        let mockAADCommand = mock<AADCommand>()
        command.createAADCommand = () => mockAADCommand

        mockedLoginCommand.azureLogin.mockResolvedValue({})

        let args = new AA4AMInstallArguments();
        args.components = [ 'aad' ]
        args.subscription = 'A1'
        args.azureActiveDirectoryServicePrincipal = 'P1'
        
        // Act
        await command.install(args)

        // Assert
        expect(mockAADCommand.installAADApplication).toBeCalledTimes(1)
        expect(mockAADCommand.installAADApplication.mock.calls[0][0].subscription).toBe("A1")
        expect(mockAADCommand.installAADApplication.mock.calls[0][0].azureActiveDirectoryServicePrincipal).toBe("P1")
    })
})

describe('Install - DevOps', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AA4AMCommand(logger);

        const mockedLoginCommand = mock<LoginCommand>();
        const mockedDevOpsCommand= mock<DevOpsCommand>();
        
        command.createLoginCommand = () => mockedLoginCommand   
        command.createDevOpsCommand = () => mockedDevOpsCommand    

        mockedLoginCommand.azureLogin.mockResolvedValue({})

        // Act
        let args = new AA4AMInstallArguments();
        args.components = ['devops']
        await command.install(args)

        // Assert
        expect(mockedLoginCommand.azureLogin).toHaveBeenCalled()
        expect(mockedDevOpsCommand.install).toHaveBeenCalled()
    })
})

describe('Install - Enviroment', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AA4AMCommand(logger);
        let addCommand = mock<AADCommand>()
        let mockLogin = mock<LoginCommand>()

        command.createLoginCommand = () => mockLogin

        const mockedPowerPlatformCommand = mock<PowerPlatformCommand>()
        const mockedGitHubCommand= mock<GitHubCommand>();
        const mockedDynamicsWebApi = mock<DynamicsWebApi>();
        const mockAxios = mock<AxiosStatic>();
        
        command.createAADCommand = () => addCommand
        command.createGitHubCommand = () => mockedGitHubCommand    
        command.createPowerPlatformCommand = () => mockedPowerPlatformCommand
        command.createDynamicsWebApi = () => mockedDynamicsWebApi
        command.getAxios = () => mockAxios

        addCommand.getAADApplication.mockReturnValue("A123");
        mockedDynamicsWebApi.executeUnboundFunction.mockResolvedValue({BusinessUnitId:"B1"})
        mockedDynamicsWebApi.executeFetchXmlAll.mockResolvedValue({value:[{}]})
        mockedDynamicsWebApi.associate.mockResolvedValue({})
        mockAxios.post.mockResolvedValue({})

        // Act
        let args = new AA4AMInstallArguments();
        args.components = ['environment']
        args.environment = "1"
        args.accessTokens = {
            'https://1.crm.dynamics.com/': '123'
        }
        args.azureActiveDirectoryServicePrincipal = "123"
        await command.install(args)

        // Assert
        expect(mockedPowerPlatformCommand.importSolution).toHaveBeenCalled()
        expect(mockedGitHubCommand.getRelease).toHaveBeenCalled()
    })
})

describe('Add User', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AA4AMCommand(logger);

        const mockedLoginCommand= mock<LoginCommand>();
        const mockedDynamicsWebApi= mock<DynamicsWebApi>();

        command.createLoginCommand = () => mockedLoginCommand
        command.createDynamicsWebApi = (config:DynamicsWebApi.Config) => mockedDynamicsWebApi
        command.getAxios = () => mock<AxiosStatic>()

        mockedLoginCommand.azureLogin.mockResolvedValue({});

        mockedDynamicsWebApi.executeUnboundFunction.mockReturnValue(Promise.resolve({
            BusinessUnitId: '123'
        }))

        mockedDynamicsWebApi.executeFetchXmlAll.mockImplementation((type:string, query:string) => {
            let response = <DynamicsWebApi.MultipleResponse<any>>{}
            switch (type) {
                case 'systemusers':
                    response.value = [{systemuserid: 'S1'}]
                    break;
                case 'roles':
                    response.value = [{roleid: 'R11'}]
                    break;
            }
            return Promise.resolve(response)
        })

        mockedDynamicsWebApi.associate.mockReturnValue(Promise.resolve())
        
        // Act
        let args = new AA4AMUserArguments();
        args.id = "123"
        await command.addUser(args)

        // Assert
        expect(mockedLoginCommand.azureLogin).toHaveBeenCalled()
        expect(mockedDynamicsWebApi.executeUnboundFunction).toHaveBeenCalled()
        expect(mockedDynamicsWebApi.executeFetchXmlAll).toHaveBeenCalled()
        expect(mockedDynamicsWebApi.associate).toHaveBeenCalled()
    })
})

describe('Maker Add', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()

        let mockAADCommand = mock<AADCommand>()
        let mockDevOps = mock<DevOpsCommand>()
        let mockLogin = mock<LoginCommand>()
        
        var command = new AA4AMCommand(logger);
        command.createAADCommand = () => mockAADCommand
        command.createDevOpsCommand = () => mockDevOps
        command.createLoginCommand = () => mockLogin

        mockLogin.azureLogin.mockResolvedValue({})

        let args = new AA4AMMakerAddArguments();
        args.azureActiveDirectoryMakersGroup = "G1"
        args.azureActiveDirectoryServicePrincipal = "P1"
        args.endpoint = "prod"
        args.organizationName = "dev12345"
        args.project = "proj1"
        args.user = "U1"
        args.environment = "E1"
        args.settings = { 'region': 'NAM' }

        // Act
        await command.addMaker(args)

        // Assert
        expect(mockDevOps.createAdvancedMakersServiceConnections).toBeCalledTimes(1)

        expect(mockLogin.azureLogin).toBeCalledTimes(1)

        expect(mockDevOps.createAdvancedMakersServiceConnections.mock.calls[0][0].azureActiveDirectoryServicePrincipal).toBe(args.azureActiveDirectoryServicePrincipal)
        expect(mockDevOps.createAdvancedMakersServiceConnections.mock.calls[0][0].endpoint).toBe(args.endpoint)
        expect(mockDevOps.createAdvancedMakersServiceConnections.mock.calls[0][0].organizationName).toBe(args.organizationName)
        expect(mockDevOps.createAdvancedMakersServiceConnections.mock.calls[0][0].projectName).toBe(args.project)
        expect(mockDevOps.createAdvancedMakersServiceConnections.mock.calls[0][0].createSecretIfNoExist).toBe(true)
        expect(mockDevOps.createAdvancedMakersServiceConnections.mock.calls[0][0].environment).toBe(args.environment)
        
        expect(mockAADCommand.addUserToGroup).toBeCalledTimes(1) 
        expect(mockAADCommand.addUserToGroup.mock.calls[0][0]).toBe("U1")       
        expect(mockAADCommand.addUserToGroup.mock.calls[0][1]).toBe("G1")       
    })
})

describe('Branch', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AA4AMCommand(logger);

        const mockedLoginCommand= mock<LoginCommand>();
        const mockedDevOpsCommand= mock<DevOpsCommand>();

        command.createLoginCommand = () => mockedLoginCommand
        command.createDevOpsCommand = () => mockedDevOpsCommand

        let tokens : { [id: string] : string } = {}
        tokens["499b84ac-1321-427f-aa17-267ca6975798"] = "ABC"
        mockedLoginCommand.azureLogin.mockResolvedValue(tokens);
        mockedDevOpsCommand.branch.mockReturnValue(Promise.resolve())
    
        // Act
        let args = new AA4AMBranchArguments();
        await command.branch(args)

        // Assert
        expect(mockedLoginCommand.azureLogin).toHaveBeenCalled()
        expect(mockedDevOpsCommand.branch).toHaveBeenCalled()
    })
});
