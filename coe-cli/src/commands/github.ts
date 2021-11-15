"use strict";
const { Octokit } = require("@octokit/rest")
import * as winston from 'winston';

/**
 * Github commands
 */
class GitHubCommand {
    createOctoKitRespos: () => any
    logger: winston.Logger

    constructor(logger: winston.Logger) {
        this.logger = logger
        this.createOctoKitRespos = () => new Octokit().rest.repos
    }

    /**
     * Execute the command
     * @param args 
     * @returns 
     */
    async getRelease(args: GitHubReleaseArguments) : Promise<string> {        
        let octokitRepo = this.createOctoKitRespos()

        let results = await octokitRepo.listReleases({
            owner:'microsoft',
            repo:'coe-starter-kit'
          });

        switch ( args.type ) {
            case 'alm': {
                let almRelease = results.data.filter((r: any) => r.name.indexOf('Advanced Makers') >= 0);
                if (almRelease.length > 0) {
                    let asset = almRelease[0].assets.filter((a: any) => a.name.indexOf(args.asset) >= 0)
                    if (asset.length > 0) {
                        return asset[0].browser_download_url
                    } 
                    throw Error("Release not found")
                }                
            }
        }

        throw Error(`Type ${args.type} not supported`)
    }
}

/**
 * Github Release Command Arguments
 */
 class GitHubReleaseArguments {
    /**
     * The type of release asset to retreive
     */
    type: string

     /**
     * The asset to retreive
     */
    asset: string
}


export { 
    GitHubReleaseArguments,
    GitHubCommand
};