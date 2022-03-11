import url, { URL } from 'url';

export abstract class Environment {         
    
    public static getEnvironments(environments: any, settings?: { [id: string] : string }):  { [id: string] : string } {
        if ( typeof environments === "object"){
            return environments
        }

        if ( typeof environments === "string"){
            let results :{ [id: string] : string } = {}
            let parts = environments.split(",")
            for (let i = 0; i < parts.length; i++ ) {
                results[i.toString()] = this.getEnvironmentUrl(parts[i], settings)
            }
            return results
        }

        return {}
    }

    public static getAzureADAuthEndpoint(settings?: { [id: string]: string }): string {
        let endpoint = 'https://login.microsoftonline.com'

        let cloud = ''
        if (typeof settings !== "undefined" && "cloud" in settings && typeof settings["cloud"] === "string") {
            cloud = settings["cloud"]
        }

        if (typeof settings !== "undefined" && "cloud" in settings && Array.isArray(settings["cloud"]) && settings["cloud"].length > 0) {
            cloud = settings["cloud"][0]
        }

        switch (cloud.toUpperCase()) {
            case "PUBLIC": {
                endpoint = 'https://login.microsoftonline.com'
                break;
            }
            case 'USGOV': {
                endpoint = 'https://login.microsoftonline.us'
                break;
            }
            case 'GERMAN': {
                endpoint = 'https://login.microsoftonline.de'
                break;
            }
            case 'CHINA': {
                endpoint = 'https://login.chinacloudapi.cn'
                break;
            }
        }
        return endpoint
    }

    public static getEnvironmentUrl(name: string, settings?: { [id: string] : string }): string {
        let environmentUrl : url.URL = null
        let defaultDomain = '.crm.dynamics.com'
        // https://docs.microsoft.com/power-platform/admin/new-datacenter-regions

        let region = ''
        if (typeof settings !== "undefined" && typeof settings["region"] === "string") {
            region = settings["region"]
        }
        
        if (typeof settings !== "undefined" && Array.isArray(settings["region"]) && settings["region"].length > 0) {
            region = settings["region"][0]
        }

        switch ( region.toUpperCase() ) {
            case "NAM": {
                defaultDomain = '.crm.dynamics.com'
                break;
            }
            case 'DEU': {
                defaultDomain = '.crm.microsoftdynamics.de'
                break;
            }
            case 'SAM': {
                defaultDomain = '.crm2.dynamics.com'
                break;
            }
            case 'CAN': {
                defaultDomain = '.crm3.dynamics.com'
                break;
            }
            case 'EUR': {
                defaultDomain = '.crm4.dynamics.com'
                break;
            }
            case 'FRA': {
                defaultDomain = '.crm12.dynamics.com'
                break;
            }
            case 'APJ': {
                defaultDomain = '.crm5.dynamics.com'
                break;
            }
            case 'OCE': {
                defaultDomain = '.crm6.dynamics.com'
                break;
            }
            case 'JPN': {
                defaultDomain = '.crm7.dynamics.com'
                break;
            }
            case 'IND': {
                defaultDomain = '.crm8.dynamics.com'
                break;
            }
            case 'GCC': {
                defaultDomain = '.crm9.dynamics.com'
                break;
            }
            case 'GCC HIGH': {
                defaultDomain = '.crm.microsoftdynamics.us'
                break;
            }
            case 'GBR': {
                defaultDomain = '.crm11.dynamics.com'
                break;
            }
            case 'ZAF': {
                defaultDomain = '.crm14.dynamics.com'
                break;
            }
            case 'UAE': {
                defaultDomain = '.crm15.dynamics.com'
                break;
            }
            case 'GER': {
                defaultDomain = '.crm16.dynamics.com'
                break;
            }
            case 'CHE': {
                defaultDomain = '.crm17.dynamics.com'
                break;
            }
            case 'CHN': {
                defaultDomain = '.crm.dynamics.cn'
                break;
            }
        }
        try {
            environmentUrl = new url.URL(name)
        } catch {
            environmentUrl = new url.URL(`https://${name}${defaultDomain}`)
        }
        return `https://${environmentUrl.hostname}/`
    }

    public static getDevOpsOrgUrl(args: any, settings?: { [id: string] : string }): string {
        let orgName = typeof args === "string" ? args : args.organizationName
        try {
            let urlOrg = new url.URL(orgName)
            
            if ( urlOrg.hostname.toLowerCase() == "dev.azure.com") {
                orgName = urlOrg.pathname.split('/')[1]
            }
        } catch {

        }
        return `https://dev.azure.com/${orgName?.trim()}/`
    }

    public static getAuthenticationUrl(resource: string): string {
        let resourceUrl = new URL(resource)

       switch ( resourceUrl.hostname ) {
            case "management.azure.com": { return "https://management.azure.com/" }
            case "api.powerapps.com": { return "https://service.powerapps.com/" }
            case "api.apps.appsplatform.us": { return "https://service.apps.appsplatform.us/" }
            case "tip1.api.powerapps.com": { return "https://service.powerapps.com/" }
            case "tip2.api.powerapps.com": { return "https://service.powerapps.com/" }
            case "graph.windows.net": { return "https://graph.windows.net/" }
            case "api.bap.microsoft.com": { return "https://service.powerapps.com/" }
            case "tip1.api.bap.microsoft.com": { return "https://service.powerapps.com/" }
            case "tip2.api.bap.microsoft.com": { return "https://service.powerapps.com/" }
            case "api.flow.microsoft.com": { return "https://service.flow.microsoft.com/" }
            case "api.flow.appsplatform.us": { return "https://service.flow.appsplatform.us/" }
            case "tip1.api.flow.microsoft.com": { return "https://service.flow.microsoft.com/" }
            case "tip2.api.flow.microsoft.com": { return "https://service.flow.microsoft.com/" }
            case "gov.api.bap.microsoft.us": { return "https://gov.service.powerapps.us/" }
            case "high.api.bap.microsoft.us": { return "https://high.service.powerapps.us/" }
            case "api.bap.appsplatform.us": { return "https://service.apps.appsplatform.us/" }
            case "gov.api.powerapps.us": { return "https://gov.service.powerapps.us/" }
            case "high.api.powerapps.us": { return "https://high.service.powerapps.us/" }
            case "gov.api.flow.microsoft.us": { return "https://gov.service.flow.microsoft.us/" }
            case "high.api.flow.microsoft.us": { return "https://high.service.flow.microsoft.us/" }
        }

        throw new Error(`Unknown resource ${resourceUrl}`)
    }
}
