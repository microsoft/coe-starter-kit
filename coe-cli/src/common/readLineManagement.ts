import * as readline from 'readline';

export class ReadLineManagement {
    static setupReadLine(existing: readline.ReadLine) : readline.ReadLine {
        if (existing == null) {
            return readline.createInterface({
                input: process.stdin,
                output: process.stdout
              })
        } else {
            return existing
        }
    }
}