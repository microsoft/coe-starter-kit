## E-Book

The CoE CLI command packages up the documentation and associated help files as a single e-book that can be distributed a PDF file. This approach allows offline consumption of the documentation and ordering of the content to help the reader consume the content.

### Quick Start

1. Change to the coe-cli docs folder

```bash
cd coe-cli/docs
```

2. Build the required docker image

```bash
docker build -t cli-mdbook .
```

2. Create the e-book using PowerShell

```bash
npm run ebook
```

### Understand the Concepts

The generated e-book approach has the following main components

1. A cover page [ebook-cover.png](../images/ebook-cover.png) image and table of contents are automatically as first pages of the e-book

2. A [index.txt](../index.txt) file that controls the reading order of the content

3. The e-book style sheet [book.css](../book.css)

4. Prism.js stylesheet [prism.css](../prism.css) and JavaScript [prism.js](../prism.js) required for formatting of the code samples

5. **build.sh** shell script to create the PDF document

#### E-Book Update

To update this e-book with new content you will need access to docker to generate new versions of the pdf file using the following steps

1. Change to the docs folder

```bash
cd coe-cli/docs
```

2. Build e-book generation docker image

```bash
docker build -t cli-mdbook .
```

3. Generate a new version of the e-book using PowerShell and the docker image created above.

```powershell
npm run ebook
```

4. The script will generate a file named **Power Platform CoE Toolkit Command Line Interface.pdf** in the docs folder

Notes: 
- If you are building an e-book for a branch that is not the main branch you can specify the path to the git hub repository e.g.

```bash
coe ebook generate \
    -r https://github.com/microsoft/coe-starter-kit/tree/coe-cli/coe-cli/docs
```

#### Spell Check Process

The [build.sh](../build.sh) makes use of [mdspell](https://www.npmjs.com/package/markdown-spellcheck) to spell check the markdown files using US english (en-US).

The mdspell node application is installed inside the [cli-mdbook docker image](../dockerfile) and executed by the [build.ps1](../build.ps1). If you need to add an exclusion for a work you can add changes to [.spelling](../.spelling) file. Each word or phrase should be on a separate line.

#### Grammar Checks

The [LanguageTool](https://languagetool.org/) writing assistant uses the Java bases command line tool inside the docker image to perform duplication, grammar and typographical checks using en-US. The language tool integration is implemented in [grammar.js](../grammar.js). The [grammar-ignore.txt](../grammar-ignore.txt) file contains a list of rules that will be ignored.

#### E-Book Customization

The [ebook.ts](../../src/commands/ebook.ts) controls the process of 

1. Parsing the markdown files

2. Combining the markdown files into a single HTML file

3. Updating references between files and within a markdown file 

4. Adding links between files

5. Referencing links to non markdown links to reference the GitHub project