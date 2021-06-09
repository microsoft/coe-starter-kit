import { LoginArguments, LoginCommand } from '../../src/commands/login';
import * as msal from '@azure/msal-node';
import { mock } from 'jest-mock-extended';
import winston from 'winston';

test('Init', async () => {
    // Arrange
    let logger = mock<winston.Logger>()
    var command = new LoginCommand(logger);
    
    let mockResult = mock<msal.AuthenticationResult>();
    mockResult.accessToken= "ABC"

    let promise = Promise.resolve(mockResult);
    const mockedClass2 = mock<msal.PublicClientApplication>();
    mockedClass2.acquireTokenByDeviceCode.mockReturnValue(promise);
    command.createClientApp = (config: any) => mockedClass2


    let args = new LoginArguments();
    args.clientId = '123'

    // Act
    await command.execute( args );

    // Assert
    expect(mockedClass2.acquireTokenByDeviceCode).toHaveBeenCalled()
    expect(command.accessToken).toBe("ABC")
})