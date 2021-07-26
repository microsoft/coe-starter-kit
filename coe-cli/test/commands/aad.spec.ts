"use strict";
import { AADAppInstallArguments, AADCommand } from '../../src/commands/aad';
import { mock } from 'jest-mock-extended';
import winston = require('winston');
import { AxiosStatic } from 'axios';
import { Prompt } from '../../src/common/prompt';

describe('Install - Group', () => {
    test('Error - AAD No Account', async () => {
        let logger = mock<winston.Logger>()
        var command = new AADCommand(logger);
        command.runCommand = (command: string, displayOutput: boolean) => {
            if (command.startsWith("az ad group list")) {
                return "[]"
            }

            if (command.startsWith("az ad group list")) {
                return "[]"
            }

            if (command.startsWith("az ad group create")) {
                return '{ "objectId": "O123" }'
            }
            
            return "{}"
        }
        
        // Act
        let args = new AADAppInstallArguments();

        await command.installAADGroup(args)
    })
});

describe('User Group', () => {
    test('Add User To Group', async () => {
        let logger = mock<winston.Logger>()
        var command = new AADCommand(logger);
        command.runCommand = (command: string, displayOutput: boolean) => {
            if (command.indexOf('az ad user show')) {
                return '{"objectId":"123"}'
            }

            if (command.indexOf('az ad group member check')) {
                return '{"value":false}'
            }

            return "{}"
        }
        
        // Act
        command.addUserToGroup("U1", "G1")
    })

    test('User Exists', async () => {
        let logger = mock<winston.Logger>()
        var command = new AADCommand(logger);
        command.runCommand = (command: string, displayOutput: boolean) => {
            if (command.indexOf('az ad user show')) {
                return '{"objectId":"123"}'
            }

            if (command.indexOf('az ad group member check')) {
                return '{"value":false}'
            }

            return "{}"
        }
        
        // Act
        command.addUserToGroup("U1", "G1")
    })
});


describe('Install - AAD User', () => {
    test('Error - AAD No Account', async () => {
        // Arrange
        let logger = mock<winston.Logger>()
        var command = new AADCommand(logger);
        command.runCommand = (command: string, displayOutput: boolean) => {
            if (command.startsWith("az account list")) {

                return "[]"
            }
            return ""
        }
        let mockPrompt = mock<Prompt>()
        command.prompt = mockPrompt

        mockPrompt.yesno.mockResolvedValue(false)
        
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
            if (command.startsWith("az account list")) {
                return accountList
            }
            if (command.startsWith("az ad app list")) {
                return '[{"appId":"123", "replyUrls":[]}]'
            }
            
            if (command.startsWith("az ad app permission list-grants")) {
                return '[{"appId":"123"}]'
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
            if (command.startsWith("az account list")) {
                return accountList
            }
            if (command.startsWith("az ad app list")) {
                return '[{"appId":"123"}]'
            }

            if (command.startsWith("az ad app permission list-grants")) {
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