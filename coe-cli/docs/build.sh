#!/bin/bash

sed -i 's/class="undefined/class="language-/g' 'Power Platform CoE Toolkit Command Line Interface.html' 

echo '-----------------------------------------------------------------------------------------'
echo Documents Spell Check
echo '-----------------------------------------------------------------------------------------'
mdspell --en-us -n -r "**/*.md"

echo '-----------------------------------------------------------------------------------------'
echo Documents Grammar Check
echo '-----------------------------------------------------------------------------------------'
if [[ ${#SKIP_GRAMMAR} -gt 0 || ${#DOCX} -gt 0 ]]; then
    echo Skipping
else
    cd /lang
    node grammar.js
fi

if [[ ${#DOCX} -gt 0 ]]; then
    echo '-----------------------------------------------------------------------------------------'
    echo Generating DOCX File
    echo '-----------------------------------------------------------------------------------------'
    pandoc 'Power Platform CoE Toolkit Command Line Interface.html' -o 'Power Platform CoE Toolkit Command Line Interface.docx'
else
    echo '-----------------------------------------------------------------------------------------'
    echo Generating PDF File
    echo '-----------------------------------------------------------------------------------------'
    cd /docs
    chromium --headless --disable-gpu --print-to-pdf='Power Platform CoE Toolkit Command Line Interface.pdf' --no-margin 'Power Platform CoE Toolkit Command Line Interface.html' --no-sandbox
fi