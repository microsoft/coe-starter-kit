"use strict";

import { CoeCliCommands } from './commands/commands'

(async function () {
  var commands = new CoeCliCommands(undefined)
  await commands.execute(process.argv)
})();
