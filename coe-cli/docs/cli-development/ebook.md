# E-Book

The COE CLI command packages up the documentation and associated help files as a single e-book that can be distributed a PDF file. This approach allows offline consumption of the documentation and ordering of the content to help the reader consume the content.

The approach has the following main components

1. A cover page **ebook-cover.md** that that is inserted as the first page of the e-book

2. A **index.txt** file that controls the reading order of the content

3. The e-book style sheet **book.css**

4. Prism.js stylesheet **prism.css** and JavaScript **prism.js** required for formatting of the code samples

5. **build.sh** shell script to create the PDF document

## E-Book Update

To update this e-book with new content you will need access to docker to generate new versions of the pdf file using the following steps


1. Build the HTML e-book version

```bash
coe ebook generate
```

If you are building an e-book for a a branch that is not the main branch you can specify the path to the git hub repository e.g

```bash
coe ebook generate -r https://github.com/microsoft/coe-starter-kit/tree/coe-cli/coe-cli/docs
```

2. Change to the docs folder

```bash
cd coe-cli/docs
```

3. Build e-book generation docker image

```bash
docker build -t cli-mdbook .
```

4. Generate a new version of the e-book using PowerShell and the docker image created above.

```powershell
.\build.ps1
```

5. script will generate a file named **COE Toolkit Command Line Interface.pdf** in the docs folder

## Spell Check Process

The [build.sh](..\build.sh) make use of [mdspell](https://www.npmjs.com/package/markdown-spellcheck) to spell check the markdown files using US english (en-US).

mdspell is installed inside the [cli-mdbook docker image](../dockerfile) and executed by the [build.ps1](../build.ps1). If you need to add an exclusion for a work you can add changes to [.spelling](../.spelling) file. Each work should be on a separate line.

## E-Book Customization

The [ebook.ts](../../src/commands/ebook.ts) controls the process of 

1. Parsing the markdown files

2. Combining the markdown files into a single HTML file

3. Updating references between files and within a markdown file 

4. Adding links between files

5. Referencing links to non markdown links to reference the GitHub project

