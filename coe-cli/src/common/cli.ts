import { execSync, ExecSyncOptionsWithStringEncoding } from 'child_process';
import yesno from 'yesno';

export class CommandLineHelper {
    async validateAzCliReady(args: any): Promise<boolean> {
        let pwshVersion = ''
        try {
            pwshVersion = this.runCommand('pwsh --version', false)
        } catch {

        }
        if (pwshVersion?.length == 0 || typeof pwshVersion == "undefined") {
            console.log('Powershell Core not installed or could not not be found. Visit https://aka.ms/powershell to install or check your environment.')
            return Promise.resolve(false)
        }

        let validated = false
        while (!validated) {
            let accounts: any[]
            try {
                accounts = <any[]>JSON.parse(this.runCommand('az account list', false))
            } catch {
                accounts = []
            }

            // Check if tenant assigned
            if (typeof (args.account) == "undefined" || (args.account.length == 0)) {
                if (accounts.length == 0) {
                    // No accounts are available probably not logged in ... prompt to login
                    let ok = await this.prompt('You are not logged into an account. Try login now (y/n)?')
                    if (ok) {
                        this.runCommand('az login --use-device-code --allow-no-subscriptions', true)
                    } else {
                        return Promise.resolve(false);
                    }
                }

                if (accounts.length > 0) {
                    let defaultAccount = accounts.filter((a: any) => (a.isDefault));
                    if (accounts.length == 1) {
                        // Only one accounr assigned to the user account use that
                        args.account = accounts[0].id
                    }
                    if (defaultAccount.length == 1 && accounts.length > 1) {
                        // More than one account assigned to this account .. confirm if want to use the current default tenant
                        let ok = await this.prompt(`Use default tenant ${defaultAccount[0].tenantId} in account ${defaultAccount[0].name} (y/n)?`);
                        if (ok) {
                            // Use the default account
                            args.account = defaultAccount[0].id
                        }
                    }
                    if (typeof (args.account) == "undefined" || (args.account.length == 0)) {
                        console.log("Missing account, run az account list to and it -a argument to assign the account")
                        return Promise.resolve(false);
                    }
                }
            }

            if (accounts.length > 0) {
                let match = accounts.filter((a: any) => (a.id == args.account || a.name == args.account) && (a.isDefault));
                if (match.length != 1) {
                    console.log(`${args.account} is not the default account. Check you have run az login and have selected the correct default account using az account set --subscription`)
                    console.log('Read more https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az_account_set')
                    return Promise.resolve(false)
                } else {
                    return Promise.resolve(true)
                }
            }
        }
    }
    
    runCommand(command: string, displayOutput: boolean) {
        if (displayOutput) {
            return execSync(command, <ExecSyncOptionsWithStringEncoding>{ stdio: 'inherit', encoding: 'utf8' })
        } else {
            return execSync(command, <ExecSyncOptionsWithStringEncoding>{ encoding: 'utf8' })
        }
    }

    async prompt(text: string) : Promise<boolean> {
        return await yesno({ question: text })
    }
}
