# Overview

This document outlines on how to make a contribution to add or amend a cli command. 

The coe-cli command line application makes use of following components

1. NodeJs to provide cross platform support
1. TypeScript to leverage published type definitions for dependent components
1. Jest for unit tests. 

## Getting Starting

Review review the general [Contribution Guidence](../CONTRIBUTING). Specifically for the coe-cli the following sections will help

- [Environment Setup](#environment-setup)
   - [Local Setup](#local-setup)
   - [Docker Setup](#docker-setup)
   - [Development Environment Setup](#development-environment-setup)
- [NPM Commands](#npm-commands)
- [Quick Start](#quick-start)
   - [Adding A New Command](#adding-a-new-command)
   - [Connecting the command to the command line](#connecting-the-command-to-the-command-line)
   - [Debugging commands](#debugging-commands)

## Environment Setup

To build the COE CLI cli application you have two choices.
1. Local setup with install of NodeJs and Azure CLI
2. Linux docker build using node image

### Local Setup

1. You will need a local copy of node and npm installed.

[Node Download](https://nodejs.org/en/download/)

You will need typescript installed to compile the application

```bash
npm install -g typescript
```

2. Install Azure CLI 

https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

### Docker Setup

But using docker you will not need a local installation of node. The docker image makes use of a known node version to build the coe-cli into a docker image. To build a local docker image you can do the following command line option.

```bash
cd coe-cli
docker build -t coe-cli . 
```

To run via docker

```bash
docker run -it -rm coe-cli
```

The [Readme](./README#) provides guidance on how to install the command line application

#### Install Components

To install Azure Active directory and Azure DevOps components

 ```bash
docker run -it --rm coe-cli coe aa4am install -o CRM317291
```

## Development Environment Setup

You can edit and debug the cli using Visual Studio Code

1. If you dont have it installed visit [https://code.visualstudio.com/Download](https://code.visualstudio.com/Download)

1. Open the coe-cli folder

1. The [.vscode\launch.json](.vscode\launch.json) file contains a pre configured debug launch command

1. You can edit the [sample.json](sample.json) file to the commands that you want to debug

1. Place breakpoints in the TypeScript files you want to debug and Press F5 to start debugging

   - Note depending on the command you want to debug you mey be prompted to login in the DEBUG CONSOLE

## NPM Commands

1. Run unit tests

```bash
npm run test
```


1. Build production version

```bash
npm run prod
```

## Quick Start

### Technology

If you are new to TypeScript the following links may help
- [Typescript docs](https://www.typescriptlang.org/docs/)
- [Getting Started with TypeScript - Learning Module](https://docs.microsoft.com/en-us/learn/modules/typescript-get-started/)

If you are new to unit testing with Jest you can start with 
- [Jest getting started](https://jestjs.io/docs/getting-started)

### Adding a new Command

To add a new sample command you can use the following command to template the initial setup of the TypeScript command and the jest unit test. 

```bash
cd coe-cli
coe cli add -n sample
```

## Connecting the command to the command line

One you have unit test completed for your new command 

1. Review [https://www.npmjs.com/package/commander](https://www.npmjs.com/package/commander) on commands, options

1. Update [commands.ts](.\src\commands\commands.ts) to include a new command or sub command

- Import your files at the top of the file

```typescript
import { SampleArguments, SampleCommand} from './sample';
```

- Add function for mock injection

```typescript
    createSampleCommand: () => SampleCommand
```

- Create command in the constructor function

```typescript
       this.createSampleCommand = () => new SampleCommand
```

- Add function

```typescript
    AddSampleCommand(program: commander.Command) {
        var run = program.command('sample')
            .description('A new sample command')
            .option('-c, --comment <comment>', 'The comment for the command')
            .action(async (options: any) : Promise<void> => {
                let args = new SampleArguments();
                args.comment = options.comment;
                let command = this.createSampleCommand();
                await command.execute(args)
            });
    }
```

- Register new command to init function 

```typescript
        this.AddSampleCommand(program);
```

3. Update [commands.spec.ts](.\test\commands\commands.spec.ts) to include unit tests


- Include reference to the command

```typescript
import { SampleCommand } from '../../src/commands/sample'
```

- Add a set of Jest tests

```typescript
describe('Sample', () => {
    test('Execute', async () => {
        // Arrange
        var commands = new CoeCliCommands();
        let mockSampleCommand = mock<SampleCommand>(); 

        commands.createSampleCommand = () => mockSampleCommand
        mockSampleCommand.execute.mockResolvedValue()
        
        // Act
        await commands.execute(['node', 'commands.spec', 'sample', '-c', 'Some comment'])

        // Assert
        expect(mockSampleCommand.execute).toHaveBeenCalled()
    })
});
```

4. Run the unit tests with new changes

```bash
npm run test
```

### Debugging Commands

You can debug the coe-cli application commands using Visual Studio Code. 

1. Change the sample.json to the command or commands you want to run
1. Open the coe-cli folder in Visual Studio Code
1. Place breakpoints in the TypeScript code you want to debug
1. Press F5 or Select Run -> Start Debugging

