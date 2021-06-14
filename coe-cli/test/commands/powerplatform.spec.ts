"use strict";
import { PowerPlatformImportSolutionArguments, PowerPlatformCommand } from '../../src/commands/powerplatform';
import { mock } from 'jest-mock-extended';
import { AxiosRequestConfig, AxiosStatic, AxiosResponse } from 'axios';
import winston from 'winston';
import { AADAppSecret, AADCommand } from '../../src/commands/aad';
            
describe('Import', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new PowerPlatformCommand(logger);
        command.getUrl = (url: string) => { return Promise.resolve('{"value":[]}') }
        command.getBinaryUrl = (url: string) => {
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
        command.getUrl = (url: string) => { return Promise.resolve('{"value":[]}') }
        command.getBinaryUrl = (url: string) => {
            return Promise.resolve(Buffer.from(''))
        }
        let mockAxios = mock<AxiosStatic>();

        command.getAxios = () => mockAxios

        mockAxios.get.mockImplementation((url: string, config: AxiosRequestConfig) => {
            let response : Promise<AxiosResponse<any>> = null
            response = mockResponse(url, '/solutions', { value: [] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/environments', { value: [ { properties: {
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

            response = mockResponse(url, '/connections', { value: [] })
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

        // Act
        
        await command.importSolution(args)

        // Assert
    })   

    test('Solution found', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new PowerPlatformCommand(logger);
        command.getUrl = (url: string) => { return Promise.resolve('{"value":[]}') }
        command.getBinaryUrl = (url: string) => {
            return Promise.resolve(Buffer.from(''))
        }
        let mockAxios = mock<AxiosStatic>();
        let mockAad = mock<AADCommand>()

        command.getAxios = () => mockAxios
        command.createAADCommand = () => mockAad

        mockAad.addSecret.mockResolvedValue(<AADAppSecret> {
            clientSecret: "VALUE"
        })

        mockAxios.get.mockImplementation((url: string, config: AxiosRequestConfig) => {
            let response : Promise<AxiosResponse<any>> = null
            response = mockResponse(url, '/solutions', { value: [ { solitionid: 'S1' }] })
            if (response != null ) {
                return response
            }

            response = mockResponse(url, '/environments', { value: [ { properties: {
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

            response = mockResponse(url, '/connections', { value: [{
                properties: {
                    createdBy: {
                        id: 'U123',
                        apiId: 'http://text.crm.dynamics.com/apis/CONNECTION-NAME'
                    }
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

            throw new Error(`Unknown url ${url}`)
        })

        mockAxios.patch.mockImplementation((url: string, config: AxiosRequestConfig) => {
            console.log(url)
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

        // Act
        
        await command.importSolution(args)

        // Assert
        expect(mockAad.addSecret).toBeCalledTimes(1)
    })
});

function mockResponse(url:string, contains: string, data: any) : Promise<AxiosResponse<any>> {
    if ( url.indexOf(contains) >= 0 || contains.length == 0 ) {
        let response : AxiosResponse<any> = 
                {
                    data: data,
                    status: 200,
                    statusText: "OK",
                    headers: [],
                    config: {}
                };
        return Promise.resolve(response)
    }
    return null
}

