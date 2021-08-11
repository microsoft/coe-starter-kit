## Adding a new Command

To add a new sample command you can use the following command to template the initial setup of the TypeScript command and the jest unit test. 

```bash
cd coe-cli
coe cli add -n sample
```

### Connecting the command to the command line

One you have unit test completed for your new command 

1. Review [https://www.npmjs.com/package/commander](https://www.npmjs.com/package/commander) on commands, options

1. Update [commands.ts](../../src/commands/commands.ts) to include a new command or sub command

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

3. Update [commands.spec.ts](..\..\test\commands\commands.spec.ts) to include unit tests

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

        commands.createSampleCommand = () => { return mockSampleCommand }

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