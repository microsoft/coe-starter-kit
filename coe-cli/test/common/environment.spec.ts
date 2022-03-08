"use strict";
import { Environment } from '../../src/common/environment';

describe('Url', () => {
    test('https://', async () => {
        expect(Environment.getEnvironmentUrl("https://org.crm.dynamics.com")).toBe("https://org.crm.dynamics.com/")
    })

    test('North America default', async () => {
        expect(Environment.getEnvironmentUrl("org")).toBe("https://org.crm.dynamics.com/")
    })

    test('Country region', async () => {
        expect(Environment.getEnvironmentUrl("org", {"region": "SAM"})).toBe("https://org.crm2.dynamics.com/")
    })

    test('DevOps', async () => {
        expect(Environment.getDevOpsOrgUrl("foo")).toBe("https://dev.azure.com/foo/")
    })

    test('DevOps Object', async () => {
        expect(Environment.getDevOpsOrgUrl({ organizationName: 'foo '})).toBe("https://dev.azure.com/foo/")
    })

    test('DevOps Url', async () => {
        expect(Environment.getDevOpsOrgUrl("https://dev.azure.com/foo")).toBe("https://dev.azure.com/foo/")
    })

    test('No settings', async () => {
        expect(Environment.getAzureADAuthEndpoint()).toBe("https://login.microsoftonline.com")
    })

    test('Cloud not set in settings', async () => {
        expect(Environment.getAzureADAuthEndpoint({})).toBe("https://login.microsoftonline.com")
    })

    test('Public cloud in settings', async () => {
        expect(Environment.getAzureADAuthEndpoint({cloud: "Public"})).toBe("https://login.microsoftonline.com")
    })

    test('USGov cloud in settings', async () => {
        expect(Environment.getAzureADAuthEndpoint({ cloud: "USGov" })).toBe("https://login.microsoftonline.us")
    })

    test('German cloud in settings', async () => {
        expect(Environment.getAzureADAuthEndpoint({ cloud: "German" })).toBe("https://login.microsoftonline.de")
    })

    test('China cloud in settings', async () => {
        expect(Environment.getAzureADAuthEndpoint({ cloud: "China" })).toBe("https://login.chinacloudapi.cn")
    })

})

