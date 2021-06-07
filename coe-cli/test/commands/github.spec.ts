"use strict";
import { GitHubReleaseArguments, GitHubCommand } from '../../src/commands/github';
const { Octokit } = require("@octokit/rest")
            
describe('Related Tests', () => {
    test('Default', async () => {
        // Arrange
        var command = new GitHubCommand;
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
