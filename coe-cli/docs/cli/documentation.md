# Documentation

Documentation is key to understanding how the cli works. As new commands are added consider the folowing

- [Add Markdown Pages](#add-markdown-pages) - Describe the functionality for end users
- [Recording Command Line](#recording-command-line) to demonstrate process

## Add Markdown Pages

Add new pages to [docs](..\docs) that describes the new command and how it is expected to be used.

Consider adding the following to the page
1. Static images that summarize teh operation
1. [Recording Command Line](#recording-command-line) to demonstrate process

## Recording Command Line

To include a short animated recording of commands and the expected output you can use the following process

A. Install termtosvg in a unix terminal

```bash
pip3 install --user termtosvg
```

This process will work cross platform and any of the following options could be used:

   i) Native unix shell on MacOs or Linux distributions

   ii) Docker images with a unix shell

   iii) [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) on Windows


B. Record the session to a cast file

```bash
termtosvg record test.cast
```

The generated cast file is a simple text file that can be edited with any text editor.

C. Remove pauses using [term-trim.ps1](..\..\scripts\term-trim.ps1)

```bash
./term-trim.ps1 -Input test.cast -Output test2.cast -Trim 1
```

D. Generate the svg file

```bash
termtosvg render test2.cast test.svg -t window_frame
```
 


