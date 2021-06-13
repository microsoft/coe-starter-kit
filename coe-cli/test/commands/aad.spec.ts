"use strict";
import { AADAppInstallArguments, AADCommand } from '../../src/commands/aad';
import { mock } from 'jest-mock-extended';
import winston = require('winston');
import { AxiosStatic } from 'axios';

describe('Install - AAD User', () => {
    test('Error - Powershell Not Installed', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AADCommand(logger);
        command.runCommand = (command: string, displayOutput: boolean) => {
            if (command.startsWith("pwsh --version")) {
                throw Error("pwsh not found")
            }
            return ""
        }

        let args = new AADAppInstallArguments();
        
        // Act
        await command.installAADApplication(args)

        // Assert
    })

    test('Error - AAD No Account', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AADCommand(logger);
        command.runCommand = (command: string, displayOutput: boolean) => {
            if (command.startsWith("pwsh --version")) {
                return "PowerShell X.XX"
            }
            if (command.startsWith("az account list")) {

                return "[]"
            }
            return ""
        }
        command.prompt = (text) => Promise.resolve(false)
        
        // Act
        let args = new AADAppInstallArguments();

        await command.installAADApplication(args)

        // Assert
        
    })

    test('Single AAD Account', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AADCommand(logger);

        let accountList =  '[{"id":"A1", "isDefault": true}]'

        expect(JSON.parse(accountList).length).toBe(1)
        command.runCommand = (command: string, displayOutput: boolean) => {
            if (command.startsWith("pwsh --version")) {
                return "PowerShell X.XX"
            }
            if (command.startsWith("az account list")) {
                return accountList
            }
            if (command.startsWith("az ad app list")) {
                return '[{"appId":"123", "replyUrls":[]}]'
            }
            return ""
        }
        command.getAxios = () => mock<AxiosStatic>()

        let args = new AADAppInstallArguments();
        args.endpoint = "prod"
        
        // Act
        await command.installAADApplication(args)

        // Assert
        
    })
})

describe('AAD User Secret', () => {
    test('App Exists', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AADCommand(logger);
        let accountList =  '[{"id":"A1", "isDefault": true}]'

        expect(JSON.parse(accountList).length).toBe(1)
        command.runCommand = (command: string, displayOutput: boolean) => {
            if (command.startsWith("pwsh --version")) {
                return "PowerShell X.XX"
            }
            if (command.startsWith("az account list")) {
                return accountList
            }
            if (command.startsWith("az ad app list")) {
                return '[{"appId":"123"}]'
            }
            return ""
        }

        let args = new AADAppInstallArguments();
        args.createSecret = true

        let sampleSecret = {
            "appId": "5c8ebc1f-0000-0000-0000-000000000000",
            "name": "5c8ebc1f-0000-0000-0000-000000000000",
            "password": "sometext",
            "tenant": "e23770ec-0000-0000-0000-000000000000"
            }

        command.runCommand = (text: string, displayOutput:boolean) => {
            if (text.startsWith("pwsh --version")) {
                return "PowerShell X.XX"
            }
            if (text.startsWith("az account list")) {
                return accountList
            }
            if (text.startsWith("az ad app list")) {
                return `[{"appId":"${sampleSecret.appId}"}]`
            }
            if (text.startsWith('az ad app credential')) {
                return JSON.stringify(sampleSecret)
            }
            return "[]"
        }
      
        // Act
        let result = await command.addSecret(args, "Test")

        // Assert
        expect(result.tenantId).toBe(sampleSecret.tenant)
        expect(result.clientId).toBe(sampleSecret.appId)
        expect(result.clientSecret).toBe(sampleSecret.password)
    })
})