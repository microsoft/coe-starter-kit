"use strict";
import { CoeCliCommands } from '../../src/commands/commands';
import { RunArguments, RunCommand } from '../../src/commands/run';
import { mock } from 'jest-mock-extended';
const mockFs = require('mock-fs');
import winston from 'winston';

describe('Related Tests', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new RunCommand(logger);
        var mockCommand = mock<CoeCliCommands>();

        mockFs({
            'test.json': '[{"name":"test", "args":["foo"]}]'
          });
        

        command.creatCoeCliCommands = () => mockCommand
        let args = new RunArguments();
        args.file = 'test.json'

    
        // Act
        
        await command.execute(args)

        // Assert
        expect(mockCommand.execute).toHaveBeenCalled();
    })

    afterEach(() => { mockFs.restore() })
});
