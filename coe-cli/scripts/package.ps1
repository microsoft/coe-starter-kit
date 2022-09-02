# The following warnings in the output of this script are expected and can be ignored as there's no run time impact:
#> Warning Cannot include file %1 into executable.
#  The file must be distributed with executable as %2.
#  %1: node_modules\open\xdg-open
#  %2: path-to-executable/xdg-open
#> Warning Failed to make bytecode node16-x64 for file /snapshot/coe-cli/node_modules/marked-terminal/node_modules/ansi-escapes/index.js
#> Warning Failed to make bytecode node16-x64 for file /snapshot/coe-cli/node_modules/marked-terminal/node_modules/ansi-escapes/index.js
#> Warning Failed to make bytecode node16-x64 for file C:\snapshot\coe-cli\node_modules\marked-terminal\node_modules\ansi-escapes\index.js
# Replace the Copy-Item commands below with any distrubution commands you need to run to copy the files to the target location.
node -p "'export const LIB_VERSION = ' + JSON.stringify(require('./package.json').version) + ';'" > src/version.ts
npm run build
npm link
npx pkg -t linux,macos,win ./coe --out-path dist
Copy-Item ./dist/coe-win.exe ../../coe-alm-accelerator-templates/Coe-Cli/coe-cli.exe
Copy-Item ./dist/coe-linux ../../coe-alm-accelerator-templates/Coe-Cli/linux/coe-cli
Copy-Item ./dist/coe-win.exe ../../coe-alm-accelerator-templates-azdo/Coe-Cli/coe-cli.exe
Copy-Item ./dist/coe-linux ../../coe-alm-accelerator-templates-azdo/Coe-Cli/linux/coe-cli
./dist/coe-win.exe --version