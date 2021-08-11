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
        command.createOctoKitRespos = () => {
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
        
        args.type = "aa4am"
        args.asset = 'Test1'
        await command.getRelease(args)

        // Assert
    })
});
