"use strict";
import { Environment } from '../../src/common/enviroment';


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
})

