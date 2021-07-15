# CLI Development

This section outlines the following key sections on the CoE CLI. The information below can help guide you in making contributions back to the open source repository.

- [Quick Start](#quick-start) - Provides set of links of the technology used to build and test the CLI

- [Contributions](#contributions) - Links to wider contributor guidance

- [Development Environment Setup](#development-environment-setup) - How to edit the CLI using Visual Studio Code

- [Adding A New Command](./adding-new-command.md) - How to add a new CLI command

- [Documentation](./documentation.md) - Adding documentation for commands

## Quick Start

The coe-cli command line application makes use of following components

1. [NodeJS](https://nodejs.org/en/) to provide cross platform support
1. TypeScript to leverage published type definitions for dependent components
1. Jest for unit tests. 

### Initial Commands

1. Change to co-cli folder

```bash
cd coe-cli
```

2. Install dependent components

```bash
npm install
```

3. Build from the source code

```bash
npm run build
```

4. Install the coe command

```bash
npm link
```

## Understand The Concepts

### Documentation 

Documentation is critical for users of the CoE understanding the commands. The [documentation](./documentation.md) pages describe how to add or modify CoE CLI, the generated [E-Book](./ebook.md) and associated help documentation.

### Development Frameworks

If you are new to TypeScript the following links may help
- [Typescript docs](https://www.typescriptlang.org/docs/)
- [Getting Started with TypeScript - Learning Module](https://docs.microsoft.com/en-us/learn/modules/typescript-get-started/)

If you are new to unit testing with Jest you can start with 
- [Jest getting started](https://jestjs.io/docs/getting-started)

### Contributions

Review the general [Contribution Guidance](../../../CONTRIBUTING).

### Development Environment Setup

You can edit and debug the cli using Visual Studio Code

1. If you do not have Visual Studio Code you can visit [https://code.visualstudio.com/Download](https://code.visualstudio.com/Download)

1. Once installed Open the coe-cli folder in Visual Studio Code

1. The [.vscode/launch.json](../../.vscode/launch.json) file contains a preconfigured debug launch command

1. You can edit the [sample.json](../../sample.json) file to the commands that you want to debug

1. Place breakpoints in the TypeScript files you want to debug and Press F5 to start debugging

NOTES:

- Depending on the command you want to debug you may be prompted to login in the DEBUG CONSOLE

- If you are testing with a different account you will need to log out of any existing Azure CLI sessions

```bash
az logout

```

### Debugging Commands

You can debug the coe-cli application commands using Visual Studio Code. 

1. Change the sample.json to the command or commands you want to run
1. Open the coe-cli folder in Visual Studio Code
1. Place breakpoints in the TypeScript code you want to debug
1. Press F5 or Select Run -> Start Debugging