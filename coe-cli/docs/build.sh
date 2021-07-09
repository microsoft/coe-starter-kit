#!/bin/bash

sed -i 's/class="undefined/class="language-/g' 'COE Toolkit Command Line Interface.html' 

echo '-----------------------------------------------------------------------------------------'
echo Documents Spell Check
echo '-----------------------------------------------------------------------------------------'
mdspell --en-us -n -r "**/*.md"

echo '-----------------------------------------------------------------------------------------'
echo Documents Grammar Check
echo '-----------------------------------------------------------------------------------------'
cd /lang
node grammar.js

echo '-----------------------------------------------------------------------------------------'
echo Generating PDF File
echo '-----------------------------------------------------------------------------------------'
cd /docs
chromium --headless --disable-gpu --print-to-pdf='COE Toolkit Command Line Interface.pdf' --no-margin 'COE Toolkit Command Line Interface.html' --no-sandbox