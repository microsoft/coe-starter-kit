import * as readline from 'readline';

export class Prompt {         
    public async yesno(text: string, defaultValue: boolean): Promise<boolean> {

        let rl =  readline.createInterface({
            terminal: false, 
            input: process.stdin,
            output: process.stdout
          })

        return new Promise((resolve) => {
            rl.question(text, (answer) => {
                if ( typeof answer === "undefined" || answer?.length == 0 ) {
                    resolve(defaultValue)
                }
                rl.close()

                switch ( answer.trim().toLowerCase()) {
                    case "y": {
                        resolve(true)
                    }
                    case "yes": {
                        resolve(true)
                    }
                    case "n": {
                        resolve(false)
                    }
                    case "no": {
                        resolve(false)
                    }
                    default: {
                        resolve(!defaultValue)
                    }
                }
            })
        })
    }
}