"use strict";
const { Octokit } = require("@octokit/rest")
import { Config } from '../common/config';
import * as winston from 'winston';

/**
 * Github commands
 */
class GitHubCommand {
    createOctoKitRepos: (auth: string) => any
    logger: winston.Logger
    config: { [id: string]: any; } = {}

    constructor(logger: winston.Logger) {
        this.logger = logger
        this.createOctoKitRepos = (auth: string) => {
            if ( auth?.length > 0 ) {
                return new Octokit({ auth: auth }).rest.repos
            }
            return new Octokit().rest.repos
        }
        this.config = Config.data
    }

    /**
     * Execute the command
     * @param args 
     * @returns 
     */
    async getRelease(args: GitHubReleaseArguments) : Promise<string> {        
        let octokitRepo = this.createOctoKitRepos(this.config["pat"])

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

    public getAccessToken(args: GitHubReleaseArguments) : string {
        if ( args.settings["pat"]?.length > 0 ) {
            let buff =  Buffer.from(args.settings["pat"], 'utf-8');
            let base64data = buff.toString('base64');
            return `Basic ${base64data}`
        }
        return ""
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

    /*
    Optional settings
    */
    settings: {
        [id: string]: string;
    }
}


export { 
    GitHubReleaseArguments,
    GitHubCommand
};