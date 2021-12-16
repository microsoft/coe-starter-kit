"use strict";
import { GitHubReleaseArguments, GitHubCommand } from '../../src/commands/github';
const { Octokit } = require("@octokit/rest")
import winston from 'winston';
import { mock } from 'jest-mock-extended';

describe('Related Tests', () => {
    test('Default', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new GitHubCommand(logger);
        command.createOctoKitRepos = (auth: string) => {
            return {
                listReleases: (releaseArgs: any): any => {
                    return {
                        data: [{
                            name: 'Advanced Makers',
                            assets: [
                                {
                                    name: 'Test1',
                                    browser_download_url: 'https://github.com'
                                }
                            ]
                        }]
                    }
                }
            }
        }       
        let args = new GitHubReleaseArguments();
    
        // Act
        
        args.type = "alm"
        args.asset = 'Test1'
        args.settings = {}
        await command.getRelease(args)

        // Assert
    })

    test('Access Token', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new GitHubCommand(logger)
        let args = new GitHubReleaseArguments();
    
        // Act
        
        args.type = "alm"
        args.asset = 'Test1'
        args.settings = { "pat": "123" } 
        let result = command.getAccessToken(args)

        // Assert
        expect(result).toBe(`Basic ${Buffer.from(args.settings.pat, "utf-8").toString("base64")}`)
    })
});
