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

2. Change to the docs folder

```bash
cd coe-cli/docs
```

3. Build e-book generation docker image

```bash
docker build -t cli-mdbook .
```

3. Generate a new version of the e-book using PowerShell and the docker image created above.

```powershell
.\build.ps1
```