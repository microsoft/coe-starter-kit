"use strict";
import { PowerPlatformImportSolutionArguments, PowerPlatformCommand, Solution, Component, ComponentPermissions } from '../../src/commands/powerplatform';
import { mock } from 'jest-mock-extended';
import { AxiosRequestConfig, AxiosStatic, AxiosResponse, AxiosResponseHeaders } from 'axios';
import winston from 'winston';
import { AADAppSecret, AADCommand } from '../../src/commands/aad';
import { CommandLineHelper } from '../../src/common/cli';
            
describe('Import', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new PowerPlatformCommand(logger);
        command.getUrl = (_url: string) => { return Promise.resolve('{"value":[]}') }
        command.getBinaryUrl = (_url: string) => {
            return Promise.resolve(Buffer.from(''))
        }

        command.getAxios = () => mock<AxiosStatic>();

        let args = new PowerPlatformImportSolutionArguments();
        args.importMethod = 'browser'

        // Act
        
        await command.importSolution(args)

        // Assert
    })
});

describe('API Import', () => {
    test('Default - No solution found', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new PowerPlatformCommand(logger);
        command.getUrl = (_url: string) => { return Promise.resolve('{"value":[]}') }
        command.getBinaryUrl = (_url: string) => {
            return Promise.resolve(Buffer.from(''))
        }
        let mockAxios = mock<AxiosStatic>();
        let mockCli = mock<CommandLineHelper>()
        let readline : any = {
            question: (_query: string, callback: (answer: string) => void) => {
                // Respond dont want to create connection
                callback('n')
            }
        }
        
        command.getAxios = () => mockAxios
        command.cli = mockCli

        command.readline = readline
        command.outputText = (_text: string) => {}

        mockCli.validateAzCliReady.mockResolvedValue(true)

        mockAxios.get.mockImplementation((url: string, _config: AxiosRequestConfig) => {
            let response : Promise<AxiosResponse<any>> = null
            response = mockResponse(url, '/solutions', { value: [] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/environments?', { value: [ { properties: {
                namne: 'ENV1',
                linkedEnvironmentMetadata: { domainName: "test", name: "ABC" }
            }}] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/connectors', { value: [] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/WhoAmI', { UserId: "U123" })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/systemusers', { value: [
                { azureactivedirectoryobjectid: "A123"}
            ] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/connections', { value: [

            ] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/workflows', { value: [] })
            if (response != null ) {
                return response
            }

            return mockResponse(url, '', { })
        } )

        let args = new PowerPlatformImportSolutionArguments();
        args.importMethod = 'api'
        args.environment = "test"
        args.endpoint = "prod"
        args.setupPermissions = false
        args.sourceLocation = "https://www.github.com/foo"

        // Act
        
        await command.importSolution(args)

        // Assert
    })
    
    test('Default - No solution found with Auth', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new PowerPlatformCommand(logger);
        command.getUrl = (_url: string) => { return Promise.resolve('{"value":[]}') }
        command.getBinaryUrl = (_url: string) => {
            return Promise.resolve(Buffer.from(''))
        }
        let mockAxios = mock<AxiosStatic>();
        let mockCli = mock<CommandLineHelper>()
        let readline : any = {
            question: (_query: string, callback: (answer: string) => void) => {
                // Respond dont want to create connection
                callback('n')
            }
        }
        
        command.getAxios = () => mockAxios
        command.cli = mockCli

        command.readline = readline
        command.outputText = (_text: string) => {}

        mockCli.validateAzCliReady.mockResolvedValue(true)

        mockAxios.get.mockImplementation((url: string, _config: AxiosRequestConfig) => {
            let response : Promise<AxiosResponse<any>> = null
            response = mockResponse(url, '/solutions', { value: [] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/environments?', { value: [ { properties: {
                namne: 'ENV1',
                linkedEnvironmentMetadata: { domainName: "test", name: "ABC" }
            }}] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/connectors', { value: [] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/WhoAmI', { UserId: "U123" })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/systemusers', { value: [
                { azureactivedirectoryobjectid: "A123"}
            ] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/connections', { value: [

            ] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/workflows', { value: [] })
            if (response != null ) {
                return response
            }

            return mockResponse(url, '', { })
        } )

        let args = new PowerPlatformImportSolutionArguments();
        args.importMethod = 'api'
        args.environment = "test"
        args.endpoint = "prod"
        args.setupPermissions = false
        args.sourceLocation = "base64:12345=="
        args.authorization = "token ABC"

        // Act
        
        await command.importSolution(args)

        // Assert
    })

    test('Solution found', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new PowerPlatformCommand(logger);
        command.getUrl = (_url: string) => { return Promise.resolve('{"value":[]}') }
        command.getBinaryUrl = (_url: string) => {
            return Promise.resolve(Buffer.from(''))
        }
        let mockAxios = mock<AxiosStatic>();
        let mockAad = mock<AADCommand>()
        let mockCli = mock<CommandLineHelper>()
        command.getAxios = () => mockAxios
        command.createAADCommand = () => mockAad
        command.cli = mockCli 

        mockCli.validateAzCliReady.mockResolvedValue(true)

        mockAad.addSecret.mockResolvedValue(<AADAppSecret> {
            clientSecret: "VALUE"
        })

        mockAxios.get.mockImplementation((url: string, _config: AxiosRequestConfig) => {
            let response : Promise<AxiosResponse<any>> = null
            response = mockResponse(url, '/solutions', { value: [ { solutionid: 'S1' }] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/environments?', { value: [ { properties: {
                name: "ABC",
                linkedEnvironmentMetadata: { domainName: "test" }
            }}] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/connectors', { value: [
                {
                    name: 'cat_5Fcustomazuredevops',
                    connectorinternalid: 'CONNECTION1',
                    connectionparameters: JSON.stringify({
                        token: {
                            oAuthSettings: {
                                clientId: "OLD"
                            }
                        }
                    })
                }
            ] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/WhoAmI', { UserId: "U123" })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/systemusers', { value: [
                { azureactivedirectoryobjectid: "A123"}
            ] })
            if (response != null ) {
                return response
            }

            if ( url.indexOf('/solutioncomponentdefinitions') > 0 ) {
                response = mockResponse(url, '/solutioncomponentdefinitions', { value: [{
                    "solutioncomponenttype": 10049
                }] })
                return response
            }

            if ( url.indexOf('/solutioncomponents') > 0 ) {
                response = mockResponse(url, '/solutioncomponents', { value: [{
                    "objectid": '7f6187bb-2586-4e5d-b195-2396533999fc'
                }] })
                return response
            }

            if ( url.indexOf('/connectionreferences') > 0 ) {
                response = mockResponse(url, '/connectionreferences', { value: [{
                    connectionid: 'ABC',
                    connectorid: '/shared_test'
                }] })
                return response
            } 

            response = mockResponse(url, '/connections', { value: [{
                name: 'ABC',
                properties: {
                    createdBy: {
                        id: 'A123'
                    },
                    apiId: 'http://text.crm.dynamics.com/apis/shared_commondataservice'
                }
            }] })

            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/workflows', { value: [ {
                solutionid: "S1",
                statecode: 1,
                statuscode: 2
            }] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/apis/CONNECTION1', {
                properties: {
                    apiDefinitions: {
                        originalSwaggerUrl: 'http://www.microsoft.com/XYZZY'
                    }
                }
            })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, 'http://www.microsoft.com/XYZZY', {
                data: ''
            })
            if (response != null ) {
                return response
            }

            return mockResponse(url, '', {})
        })

        mockAxios.patch.mockImplementation((url: string, _config: AxiosRequestConfig) => {
            let response = mockResponse(url, '/apis/CONNECTION1', {
                status: 'Updated'
            })
            if (response != null ) {
                return response
            }
        })

        let args = new PowerPlatformImportSolutionArguments();
        args.importMethod = 'api'
        args.environment = "test"
        args.endpoint = "prod"
        args.setupPermissions = false

        command.readline = {
            question: (question: string, callback: any) => {
                callback('y')
            },
            close: () => {}
        }

        // Act
        
        await command.importSolution(args)

        // Assert
        expect(mockAad.addSecret).toBeCalledTimes(1)
    })

    test('Solution found - New Connection', async () => {

        // Arrange
        let logger = mock<winston.Logger>()
        
        var command = new PowerPlatformCommand(logger);
        command.getUrl = (_url: string) => { return Promise.resolve('{"value":[]}') }
        command.getBinaryUrl = (_url: string) => {
            return Promise.resolve(Buffer.from(''))
        }
        let mockAxios = mock<AxiosStatic>();
        let mockAad = mock<AADCommand>()
        let mockCli = mock<CommandLineHelper>()
        command.getAxios = () => mockAxios
        command.createAADCommand = () => mockAad
        command.cli = mockCli 

        mockCli.validateAzCliReady.mockResolvedValue(true)

        mockAad.addSecret.mockResolvedValue(<AADAppSecret> {
            clientSecret: "VALUE"
        })

        let readline : any = {
            question: (_query: string, callback: (answer: string) => void) => {
                // Respond want to create connection
                callback('y')
            },
            close: () => {}
        }
        command.readline = readline

        let connectionReferencesCount = 0

        mockAxios.get.mockImplementation((url: string, _config: AxiosRequestConfig) => {
            let response : Promise<AxiosResponse<any>> = null
            response = mockResponse(url, '/solutions', { value: [ { solutionid: 'S1' }] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/environments?', { value: [ { properties: {
                name: "ABC",
                linkedEnvironmentMetadata: { domainName: "test" }
            }}] })
            if (response != null ) {
                return response
            }

            if ( url.indexOf('/solutioncomponentdefinitions') > 0 ) {
                response = mockResponse(url, '/solutioncomponentdefinitions', { value: [{
                    "solutioncomponenttype": 10049
                }] })
                return response
            }

            if ( url.indexOf('/solutioncomponents') > 0 ) {
                response = mockResponse(url, '/solutioncomponents', { value: [{
                    "objectid": '7f6187bb-2586-4e5d-b195-2396533999fc'
                }] })
                return response
            }

            if ( url.indexOf('/connectionreferences') > 0 && connectionReferencesCount == 0 ) {
                response = mockResponse(url, '/connectionreferences', { value: [{
                    connectionid: null,
                    connectorid: '/shared_test',
                     properties: {
                        createdBy: {
                            id: "U123"
                        }
                    }
                }] })
                connectionReferencesCount++
                return response
            } 

            if ( url.indexOf('/connectionreferences') > 0 && connectionReferencesCount > 0 ) {
                response = mockResponse(url, '/connectionreferences', { value: [{
                    connectionid: 'ABC',
                    connectorid: '/shared_test',
                    properties: {
                        createdBy: {
                            id: "U123"
                        }
                    }
                }] })
                connectionReferencesCount++
                return response
            }

            response = mockResponse(url, '/connectors', { value: [
                {
                    name: 'cat_5Fcustomazuredevops',
                    connectorinternalid: 'CONNECTION1',
                    connectionparameters: ''
                }
            ] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/WhoAmI', { UserId: "U123" })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/systemusers', { value: [
                { azureactivedirectoryobjectid: "A123"}
            ] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/connections', { value: [{
                properties: {
                    name: 'ABC',
                    createdBy: {
                        id: 'A123'
                    },
                    apiId: 'http://text.crm.dynamics.com/apis/shared_test'
                }
            }] })

            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/workflows', { value: [ {
                solutionid: "S1",
                statecode: 1,
                statuscode: 2
            }] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/apis/CONNECTION1', {
                properties: {
                    apiDefinitions: {
                        originalSwaggerUrl: 'http://www.microsoft.com/XYZZY'
                    }
                }
            })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, 'http://www.microsoft.com/XYZZY', {
                data: ''
            })
            if (response != null ) {
                return response
            }

            return mockResponse(url, '', {})
        })

        mockAxios.patch.mockImplementation((url: string, _config: AxiosRequestConfig) => {
            let response = mockResponse(url, '/apis/CONNECTION1', {
                status: 'Updated'
            })
            if (response != null ) {
                return response
            }
        })

        let args = new PowerPlatformImportSolutionArguments();
        args.importMethod = 'api'
        args.environment = "test"
        args.endpoint = "prod"
        args.setupPermissions = false

        // Act
        
        await command.importSolution(args)

        // Assert
        expect(mockAad.addSecret).toBeCalledTimes(1)
    })
});

describe('Get Environment', () => {
    test('Full url', async () => {
        let logger = mock<winston.Logger>()
        var command = new PowerPlatformCommand(logger);
        let mockAxios = mock<AxiosStatic>();
        command.getAxios = () => mockAxios

        mockAxios.get.mockResolvedValue({
            data: {
                value: [
                    {
                        name: '123',
                        properties: {
                            linkedEnvironmentMetadata:{
                                domainName: 'foo'
                            }
                        } 
                    }
                ]
            }
        })

        let args = new PowerPlatformImportSolutionArguments()
        args.environment  = 'https://foo.crm.dynamic.com'
        args.endpoint = "prod"
        args.setupPermissions = false

        // Act
        let env = await command.getEnvironment(args)

        // Assert
        expect(env.name).toBe("123")
    })

    test('Full url different domain case', async () => {
        let logger = mock<winston.Logger>()
        var command = new PowerPlatformCommand(logger);
        let mockAxios = mock<AxiosStatic>();
        command.getAxios = () => mockAxios

        mockAxios.get.mockResolvedValue({
            data: {
                value: [
                    {
                        name: '123',
                        properties: {
                            linkedEnvironmentMetadata:{
                                domainName: 'FOO'
                            }
                        } 
                    }
                ]
            }
        })

        let args = new PowerPlatformImportSolutionArguments()
        args.environment  = 'https://foo.crm.dynamic.com'
        args.endpoint = "prod"
        args.setupPermissions = false
     
        // Act
        let env = await command.getEnvironment(args)

        // Assert
        expect(env.name).toBe("123")
    })
})

describe('Share', () => {
    test('Application not found', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        let mockAAD = mock<AADCommand>()
        var command = new PowerPlatformCommand(logger);
        
        let args = new PowerPlatformImportSolutionArguments()
        let mockAxios = mock<AxiosStatic>()
        command.getAxios = () => mockAxios
        command.createAADCommand = () => mockAAD

        args.endpoint = "prod"

        mockAxios.get.mockImplementation((url: string, _config: AxiosRequestConfig) => {
            let response = {}
            if (url.indexOf('api/data/v9.0/msdyn_solutioncomponentsummaries') > 0) {
                response = [
                ]
            }
            return Promise.resolve({data:{ value: response }})
        })


        let solution = <Solution> {
            solutionid: "S123"
        }

        // Act


        await command.shareMakerApplication(solution, "E1", args)

        // Assert
        expect(command.logger.error).toBeCalled()
    })

    test('Application found, no pemissions - Add', async () => {
        // Arrange
        let logger = mock<winston.Logger>()

        let args = new PowerPlatformImportSolutionArguments()
        let mockAxios = mock<AxiosStatic>()
        let mockAADcommand = mock<AADCommand>()

        var command = new PowerPlatformCommand(logger);
        command.getAxios = () => mockAxios
        command.createAADCommand = () => mockAADcommand

        mockAxios.get.mockImplementation((url: string, _config: AxiosRequestConfig) => {
            let response = {}
            if (url.indexOf('api/data/v9.0/msdyn_solutioncomponentsummaries') > 0) {
                response = [
                    <Component> {
                        msdyn_displayname: "ALM Accelerator for Power Platform",
                        msdyn_objectid: "C1"
                    }
                ]
            }

            if (url.indexOf('/providers/Microsoft.PowerApps/apps/C1/permissions') > 0) {
                response = [                   
                ]
            }

            if (url.indexOf('/api/data/v9.0/teams') > 0) {
                response = [                   
                ]
            }

            if (url.indexOf('/api/data/v9.0/roles') > 0) {
                response = [ { roleId: "R1"} ]
            }

            return Promise.resolve({data:{ value: response }})
        })

        mockAxios.post.mockResolvedValue({})

        mockAADcommand.getAADGroup.mockReturnValue("ID")

        let solution = <Solution> {
            solutionid: "S123"
        }

        args.azureActiveDirectoryMakersGroup = "G1"
        args.endpoint = "prod"

        // Act


        await command.shareMakerApplication(solution, "E1", args)

        // Assert
        expect(command.logger.error).toBeCalledTimes(0)
        expect(mockAADcommand.getAADGroup).toBeCalledTimes(1)
        expect(mockAxios.post).toBeCalledTimes(2)
    })
})

function mockResponse(url:string, contains: string, data: any) : Promise<AxiosResponse<any>> {
    if ( url.indexOf(contains) >= 0 || contains.length == 0 ) {
        let response : AxiosResponse<any> = 
                {
                    data: data,
                    status: 200,
                    statusText: "OK",
                    headers: null,
                    config: {}
                };
        return Promise.resolve(response)
    }
    return null
}


