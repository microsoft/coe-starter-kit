"use strict";
import * as winston from 'winston';
import * as marked from 'marked'
import * as fs from 'fs';
import * as path from 'path';
import { FileHandle } from 'fs/promises';
const {EOL} = require('os');
import slash from 'slash';
import normalizeUrl from 'normalize-url';

/**
 * Ebook commands
 */
class EbookCommand {
    logger: winston.Logger
    readFile: (path: fs.PathLike | FileHandle, options: { encoding: BufferEncoding, flag?: fs.OpenMode } | BufferEncoding) => Promise<string>
    writeFile: (path: fs.PathLike | FileHandle, data: string | Uint8Array) => Promise<void>
    existsSync: (path: fs.PathLike) => boolean
    outputText: (text: string) => void
    
    constructor(logger: winston.Logger, defaultFs: any = null) {
        this.logger = logger

        if (defaultFs == null) {
            this.readFile = fs.promises.readFile
            this.writeFile = fs.promises.writeFile
            this.existsSync = fs.existsSync
        } else {
            this.readFile = defaultFs.readFile
            this.writeFile = defaultFs.writeFile
            this.existsSync = defaultFs.existsSync
        }
        this.outputText = (text: string) => console.log(text)
    }

    /**
     * Create the e-book content
     * @param args 
     * @returns 
     */
    async create(args: EbookArguments) : Promise<void> {
        let content : string[] = ['<html><head><link href="prism.css" rel="stylesheet" /><link href="book.css" rel="stylesheet" /></head><body><img class="cover" src="./images/ebook-cover.png" />']

        let toc : string[] = ['<div class="page"><ul class="toc">']
        let tocLevels: number[] = []

        for ( let l = 0; l < args.tocLevel; l++) {
            tocLevels.push(0)
        }

        marked.marked.use({
            pedantic: false,
            gfm: true,
            breaks: false,
            sanitize: false,
            smartLists: true,
            smartypants: false,
            xhtml: false
          });
        
        let docsPath : string = args.docsPath

        if ( ! path.isAbsolute(docsPath)) {
            docsPath = path.normalize(path.join(__dirname, '..', '..', '..', docsPath))
        } else {
            docsPath = path.normalize(docsPath)
        }
          
        let indexFile = path.join(docsPath, "index.txt")

        if (!this.existsSync(indexFile)) {
            this.logger?.error(`Unable to find index file ${indexFile}`)
            return Promise.resolve()
        }

        let data = await this.readFile(indexFile, 'utf-8')
        const lines = data.split(/\r?\n/);
        let fileReferences : { [id: string]: string[]; } = {}
        let links: string[] = []

        for ( var i = 0; i < lines.length; i++ ) {
            content.push('<div class="page">') 
            if ( lines[i].startsWith("#") || lines[i]?.trim().length == 0 ) {
                // Skip comment or empty line
                continue;
            }

            let file = path.normalize(path.join(docsPath, lines[i]))
            let md = await this.readFile(file, 'utf-8')
            let tokens = marked.Lexer.lex(md)
            let fileid = lines[i].replace(/\//g, '-').replace(".md", '')

            this.logger?.debug(`Importing ${file}`)

            fileReferences[fileid] = []
    
            marked.marked.walkTokens(tokens, (token) => {
                
                if ( token.type == "image" ) {
                    if ( !path.isAbsolute(token.href) && !token.href.startsWith('http') ) {
                        let relativePath = path.normalize(path.join(path.dirname(file), token.href))
                        relativePath = "." + relativePath.replace(docsPath, "").replace(/\\/g,'/')
                        this.logger?.debug(`Updating image from ${token.href} to ${relativePath}`)
                        token.href = relativePath
                    }
                }
                if ( token.type == "link" ) {
                    if (token.href.startsWith("#")) {
                        let oldLink = token.href
                        token.href = "#" + fileid + "-" + token.href.replace("#","").replace(/ /g,'-')

                        if ( fileReferences[fileid].indexOf(token.href) < 0 ) {
                            fileReferences[fileid].push(token.href)
                        }
                        
                        this.logger?.debug(`Updating markdown link ${oldLink} to ${token.href}`)
                        return
                    }
                    if (token.href.indexOf(".md") > 0 && !token.href.startsWith('http')) {
                        let reference = token.href
                        let fileName = reference.indexOf("#") > 0 ? reference.split('#')[0] : reference
                        let section = reference.indexOf("#") > 0 ? reference.split('#')[1] : ""
                        let targetFile = path.normalize(path.join(path.dirname(file), fileName))
                        let relativeFile = targetFile.replace(docsPath,"")
                        // Change to unix like path
                        relativeFile = relativeFile.replace(/\\/g,'/')
                        if (relativeFile.startsWith('/')) {
                            relativeFile = relativeFile.substr(1)
                        }

                        let newReference = ""
                        if ( section.length == 0 ) {
                            // Not a reference fo an internal part of the file
                            // Assume link is to the start of the file
                            newReference += "#section-"
                        }
                        newReference += relativeFile.replace(/\//g,'-').replace(".md","")
                        if ( section.length > 0 ) {
                            // Add link to heaing inside the document
                            newReference += "-" + section.toLowerCase().replace(/ /g,'-')
                        }

                        this.logger?.debug(`Updating markdown link ${token.href} to ${newReference}`)

                        if ( fileReferences[fileid].indexOf(newReference) < 0 ) {
                            fileReferences[fileid].push(newReference)
                        }

                        token.href = newReference
                        return
                    }
                    if ( !path.isAbsolute(token.href) && !token.href.startsWith('http') ) {
                        let href = (<any>marked.Lexer.lex(token.raw.replace(/\\/g,'/'))[0]).tokens[0].href
                        let relativePath = slash(path.normalize(path.join(path.dirname(file), href)))
                        
                        let offset = "./"
                        let commonPath = docsPath
                        // Assume that in docs path
                        relativePath = relativePath.replace(docsPath,"")

                        // Check if still have absolute path
                        while ( path.isAbsolute(relativePath) ) {
                            // Move up one folder
                            offset += "../" 
                            commonPath = slash(path.normalize(path.join(commonPath, "..")))

                            // Try remove new common path folder
                            relativePath = relativePath.replace(commonPath,"")
                            if ( relativePath.startsWith('/')) {
                                relativePath = relativePath.substr(1)
                            }
                        }

                        let newPath = "."
                        if ( args.repoPath?.length > 0 ) {
                            newPath = args.repoPath
                            if ( ! newPath.endsWith('/')) {
                                newPath += '/'
                            }
                            relativePath = normalizeUrl(newPath + offset + relativePath)
                        } else {
                            relativePath = newPath + relativePath
                        }

                        if ( fileReferences[fileid].indexOf(relativePath) < 0 ) {
                            fileReferences[fileid].push(relativePath)
                        }

                        this.logger?.debug(`Updating link from ${href} to ${relativePath}`)
                        token.href = relativePath
                    }
                }
            })
    
            const renderer = new marked.Renderer();
    
            renderer.heading = (text, level) => {
                  const escapedText = "#" + fileid + '-' + text.toLowerCase().replace(/[^\w]+/g, '-');

                  if (links.indexOf(escapedText) < 0) {
                    links.push(escapedText)
                  }

                  if (level <= args.tocLevel) {
                      if ( level < args.tocLevel) {
                          for ( let l = level; l < args.tocLevel; l++) {
                              tocLevels[l] = 0
                          }
                      }
                      tocLevels[level - 1] = tocLevels[level - 1] + 1
                      let label = ''
                      for (let l = 0; l < level; l++) {
                        if (label.length > 0) {
                            label += "."
                        }
                        label += tocLevels[l]
                      }
                    toc.push(`<li class="toc-${level}"><a href="${escapedText}">${label} ${text}</a><li>`)
                  }
              
                  return `
<h${level}>
    <a id="${escapedText.replace("#", "")}" class="anchor">
        <span class="header-link"></span>
    </a>
    ${text}
</h${level}>`;
                }
    
            const parser = new marked.Parser({ renderer: renderer });

            let html = parser.parse(tokens)
            let fileReference = `section-${fileid}`
            let documentLink = `<a id="${fileReference}" class="section"></a>`

            if (links.indexOf(`#${fileReference}`) < 0) {
                // Add link to document start
                links.push(`#${fileReference}`)
            }

            if ( typeof args.htmlFile === "undefined" || args.htmlFile?.length == 0) {
                this.outputText(documentLink);
                this.outputText(html);
            } else {
                content.push(documentLink)
                content.push(html)
            }

            content.push('</div>') 
        }

        if ( args.htmlFile?.length > 0) {
            content.push(`<script src='prism.js'></script></body></html>`)

            let htmlFile = args.htmlFile
            if ( !path.isAbsolute(args.htmlFile) ) {
                htmlFile = path.normalize(path.join(docsPath, htmlFile))
            }

            toc.push("</ul></div>")

            content.splice(1, 0, toc.join(EOL))
            await this.writeFile(htmlFile, content.join(EOL))
        }

        this.logger?.info("Checking links")
        for ( var i = 0; i < lines.length; i++ ) {
            let fileid = lines[i].replace(/\//g, '-').replace(".md", '')
            let missing: string[] = []
            for ( var l = 0; l < fileReferences[fileid]?.length; l++ ) {
                if ( fileReferences[fileid][l].startsWith("#") && links.indexOf(fileReferences[fileid][l]) < 0 ) {
                    if (fileReferences[fileid][l].startsWith("#section-"))
                        missing.push(`Unable to page ${fileReferences[fileid][l].replace('#section-','')}`)
                    else {
                        missing.push(`Unable to find heading ${fileReferences[fileid][l]}`)
                    }
                }
            }

            if ( missing.length > 0 ) {
                this.logger?.info(lines[i])
                for ( var l = 0; l < missing.length; l ++) {
                    this.logger?.error(missing[l])
                }
            }

        }

        return Promise.resolve();
    }
}

/**
 * Ebook Command Arguments
 */
 class EbookArguments {
    /**
     * The path to the documents
     */
    docsPath: string

    /**
     * The path to the repo where the document files are located
     */
    repoPath: string

    /**
     * The name of the combined HTML file to create
     */
    htmlFile: string

     /**
     * The table of contents level
     */
    tocLevel: number
}

export { 
    EbookArguments,
    EbookCommand
};