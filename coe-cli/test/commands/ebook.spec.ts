"use strict";
import { EbookArguments, EbookCommand } from '../../src/commands/ebook';
import { mock } from 'jest-mock-extended';
import winston from 'winston';
import { OpenMode, PathLike } from 'fs';
import { FileHandle } from 'fs/promises';
            
describe('Create Tests', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new EbookCommand(logger);
        let output : string[] = []
        command.outputText = (text) => output.push(text)
        let args = new EbookArguments();

        command.readFile = (path: PathLike | FileHandle, options: { encoding: BufferEncoding, flag?: OpenMode } | BufferEncoding) => {
            if ( path.toString().indexOf('index.txt') ) {
                return Promise.resolve('test1.md')
            }
            if ( path.toString().indexOf('test1.md') ) {
                return Promise.resolve(`Test`)
            }
            return Promise.reject("Unknown file")
        }

        args.docsPath = "./docs"
    
        // Act
        await command.create(args)

        // Assert
        expect(output.length).toBe(1)
        console.log(output)
    })
});
    