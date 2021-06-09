"use strict";
import { PowerPlatformImportSolutionArguments, PowerPlatformConectorUpdate, PowerPlatformCommand } from '../../src/commands/powerplatform';
import { mock } from 'jest-mock-extended';
import { AxiosStatic } from 'axios';
import winston from 'winston';
            
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

        // Act
        
        await command.importSolution(args)

        // Assert
    })
});
