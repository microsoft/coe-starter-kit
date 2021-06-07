"use strict";
import CoeCliCommands from '../../src/commands/commands';
import { RunArguments, RunCommand } from '../../src/commands/run';
import { mock } from 'jest-mock-extended';
import * as fs from 'fs'
const mockFs = require('mock-fs');

describe('Related Tests', () => {
    test('Default', async () => {
        // Arrange
        var command = new RunCommand;
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
