"use strict";

import { CoeCliCommands } from './commands/commands'
import { Config } from './common/config';

(async function () {
  await Config.init()
  var commands = new CoeCliCommands(undefined)
  await commands.execute(process.argv)
})();
