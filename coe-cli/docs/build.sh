#!/bin/bash
mdbook build
cd book
pandoc  -V geometry:margin=2cm -f epub "COE Toolkit Command Line Interface.epub" -o "coe-cli.pdf"
pandoc  -f epub "COE Toolkit Command Line Interface.epub" -o "coe-cli.docx"
pdfunite ../ebook-cover.pdf coe-cli.pdf "COE Toolkit Command Line Interface.pdf" 
cd ..