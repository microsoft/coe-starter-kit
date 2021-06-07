"use strict";
import { AA4AMBranchArguments, AA4AMCommand, AA4AMInstallArguments, AA4AMUserArguments } from '../../src/commands/aa4am';
import { LoginCommand } from '../../src/commands/login';
import { DevOpsCommand } from '../../src/commands/devops';
import { mock } from 'jest-mock-extended';
import DynamicsWebApi = require('dynamics-web-api');
import { AADCommand } from '../../src/commands/aad';
import { AxiosStatic } from 'axios';

describe('Install - AAD', () => {
    test('No command', async () => {
        // Arrange
        var command = new AA4AMCommand();
        
        // Act
        let args = new AA4AMInstallArguments();
        await command.install(args)

        // Assert
        
    })

    test('Called', async () => {
        // Arrange
        var command = new AA4AMCommand();
        const mockedLoginCommand = mock<LoginCommand>();
        command.createLoginCommand = () => mockedLoginCommand
        let mockAADCommand = mock<AADCommand>()
        command.createAADCommand = () => mockAADCommand

        mockedLoginCommand.azureLogin.mockResolvedValue({})

        let args = new AA4AMInstallArguments();
        args.components = [ 'aad' ]
        args.account = 'A1'
        args.azureActiveDirectoryServicePrincipal = 'P1'
        
        // Act
        await command.install(args)

        // Assert
        expect(mockAADCommand.installAADApplication).toBeCalledTimes(1)
        expect(mockAADCommand.installAADApplication.mock.calls[0][0].account).toBe("A1")
        expect(mockAADCommand.installAADApplication.mock.calls[0][0].azureActiveDirectoryServicePrincipal).toBe("P1")
    })
})

describe('Install - DevOps', () => {
    test('Default', async () => {
        // Arrange
        var command = new AA4AMCommand();
        const mockedLoginCommand = mock<LoginCommand>();
        const mockedDevOpsCommand= mock<DevOpsCommand>();
        
        command.createLoginCommand = () => mockedLoginCommand   
        command.createDevOpsCommand = () => mockedDevOpsCommand    
        command.prompt = (text) => Promise.resolve(false)

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

describe('Add User', () => {
    test('Default', async () => {
        // Arrange
        var command = new AA4AMCommand();

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
        await command.addUser(args)

        // Assert
        expect(mockedLoginCommand.azureLogin).toHaveBeenCalled()
        expect(mockedDynamicsWebApi.executeUnboundFunction).toHaveBeenCalled()
        expect(mockedDynamicsWebApi.executeFetchXmlAll).toHaveBeenCalled()
        expect(mockedDynamicsWebApi.associate).toHaveBeenCalled()
    })
})

describe('Branch', () => {
    test('Default', async () => {
        // Arrange
        var command = new AA4AMCommand();

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
