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

        command.existsSync = (path: PathLike) => true
        command.readFile = (path: PathLike | FileHandle, options: { encoding: BufferEncoding, flag?: OpenMode } | BufferEncoding) => {
            console.log(path)
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
        expect(output.length).toBe(2)
        expect(output[0]).toBe('<a id="section-test1" class="section"></a>')
        expect(output[1]).toBe('<p>test1.md</p>\n')
    })
});
    