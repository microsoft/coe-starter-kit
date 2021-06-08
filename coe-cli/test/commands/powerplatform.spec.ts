"use strict";
import { PowerPlatformImportSolutionArguments, PowerPlatformConectorUpdate, PowerPlatformCommand } from '../../src/commands/powerplatform';
import { mock } from 'jest-mock-extended';
import { AxiosStatic } from 'axios';
            
describe('Import', () => {
    test('Default', async () => {
        // Arrange
        var command = new PowerPlatformCommand;
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
