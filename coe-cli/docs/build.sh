#!/bin/bash
/mdcollate/target/debug/mdcollate SUMMARY.md | pulldown-cmark -T > coe-cli.html 
tail -n+2 coe-cli.html > coe-cli2.html
echo "<html><head><link href="prism.css" rel="stylesheet" /></head><body><style>" > coe-cli3.html
cat book.css >> coe-cli3.html
echo "</style>" >> coe-cli3.html
cat coe-cli2.html >> coe-cli3.html
echo "<script src='prism.js'></script>" >> coe-cli3.html
echo "</body></html>" >> coe-cli3.html
wkhtmltopdf -B 20 -T 20 -L 20 -R 20 coe-cli3.html "coe-cli.pdf"
rm coe-cli.html
rm coe-cli2.html
#rm coe-cli3.html
pdfunite ebook-cover.pdf coe-cli.pdf "COE Toolkit Command Line Interface.pdf"
rm coe-cli.pdf