"use strict";
import { GitHubReleaseArguments, GitHubCommand } from '../../src/commands/github';
const { Octokit } = require("@octokit/rest")
import winston from 'winston';
import { mock } from 'jest-mock-extended';
import { Config } from '../../src/common/config';

describe('Related Tests', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new GitHubCommand(logger);
        command.octokitRequest = (request: any) => new Promise<any>((resolve) => resolve({ data: '123' }))
        command.createOctoKitRepos = (auth: string) => {
            return {
                listReleases: (releaseArgs: any): any => {
                    return {
                        data: [{
                            name: 'Advanced Makers',
                            html_url: 'https://github.com/download/something',
                            assets: [
                                {
                                    name: 'Test1',
                                    id: 123,
                                }
                            ]
                        }]
                    }
                }
            }
        }       
        let args = new GitHubReleaseArguments();
    
        // Act
        
        args.type = "coe"
        args.asset = 'Test1'
        args.settings = { installFile: "https://github.com/download/something" }
        Config.data["pat"] = "123"
        let result = await command.getRelease(args)

        // Assert
        expect(result).toBe(`base64:MTIz`)
    })

    test('Access Token', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new GitHubCommand(logger)
        let args = new GitHubReleaseArguments();
        command.octokitRequest = (request: any) => new Promise<any>((resolve) => resolve({ data: '123' }))
    
        // Act
        
        args.type = "alm"
        args.asset = 'Test1'
        Config.data['pat'] = "123" 
        let result = command.getAccessToken(args)

        // Assert
        expect(result).toBe(`token 123`)
    })
});
