import { LoginArguments, LoginCommand } from '../../src/commands/login';
import { Environment } from '../../src/common/environment';
import * as msal from '@azure/msal-node';
import { mock } from 'jest-mock-extended';
import winston from 'winston';

test('Init', async () => {
    // Arrange
    let logger = mock<winston.Logger>()
    var command = new LoginCommand(logger);
    
    let mockResult = mock<msal.AuthenticationResult>();
    mockResult.accessToken= Environment.getAzureADAuthEndpoint({cloud: "USGov"});

    let promise = Promise.resolve(mockResult);
    const mockedClass2 = mock<msal.PublicClientApplication>();
    mockedClass2.acquireTokenByDeviceCode.mockReturnValue(promise);
    command.createClientApp = (config: any) => mockedClass2


    let args = new LoginArguments();
    args.clientId = '123'

    // Act
    await command.execute( args, {cloud: "USGov"} );

    // Assert
    expect(mockedClass2.acquireTokenByDeviceCode).toHaveBeenCalled()
    expect(command.accessToken).toBe("https://login.microsoftonline.us")
})