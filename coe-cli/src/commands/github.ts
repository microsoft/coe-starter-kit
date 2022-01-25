"use strict";
const { Octokit } = require("@octokit/rest")
import { Config } from '../common/config';
import * as winston from 'winston';
import axios from 'axios';

/**
 * Github commands
 */
class GitHubCommand {
    createOctoKitRepos: (auth: string) => any
    logger: winston.Logger
    config: { [id: string]: any; } = {}
    octokitRequest: (request: any) => Promise<any>

    constructor(logger: winston.Logger) {
        this.logger = logger
        this.createOctoKitRepos = (auth: string) => {
            if ( auth?.length > 0 ) {
                return new Octokit({ auth: auth }).rest.repos
            }
            return new Octokit().rest.repos
        }
        this.config = Config.data
        this.octokitRequest = async (request: any) => {
            let octokit = new Octokit()
            return await octokit.request(request)
        }
    }

    /**
     * Execute the command
     * @param args 
     * @returns 
     */
    async getRelease(args: GitHubReleaseArguments) : Promise<string> {        
        let octokitRepo = this.createOctoKitRepos(this.config["pat"])

        try {
            let results = await octokitRepo.listReleases({
                owner:'microsoft',
                repo:'coe-starter-kit'
            });
            switch ( args.type ) {
                case 'coe': {
                    let almRelease = results.data.filter((r: any) => r.name.indexOf('CoE Starter Kit') >= 0);
                    if ( args.settings["installFile"]?.length > 0 && args.settings["installFile"].startsWith("https://") ) {
                        almRelease = results.data.filter((r: any) => r.html_url == args.settings["installFile"]);
                    }
                    if (almRelease.length > 0) {
                        let asset = almRelease[0].assets.filter((a: any) => a.name.indexOf(args.asset) >= 0)
                        if (asset.length > 0) {
                            let headers = null
                            if(this.config["pat"]?.length > 0) {
                                headers = {
                                    authorization: `token ${this.config["pat"]}`,
                                    accept: 'application/octet-stream'
                                }
                            } else {
                                headers = {
                                    accept: 'application/octet-stream'
                                }
                            }
                            let download = await this.octokitRequest({
                                url: '/repos/{owner}/{repo}/releases/assets/{asset_id}',
                                headers: headers,
                                owner: 'microsoft',
                                repo: 'coe-starter-kit',
                                asset_id: asset[0].id
                            })

                            const buffer = Buffer.from(download.data);
                            return 'base64:' + buffer.toString('base64');
                        } 
                        throw Error("Release not found")
                    }                
                }
            }
    
            throw Error(`Type ${args.type} not supported`)
        } catch (ex) {
            this.logger.error(ex)
        }
        
    }

    public getAccessToken(args: GitHubReleaseArguments) : string {
        if ( Config.data["pat"]?.length > 0 ) {
            return `token ${Config.data["pat"]}`
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