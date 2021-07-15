const fs = require('fs');
const path = require('path');
const child_process = require('child_process');

(async () => {
    let indexFile = path.join("/docs", "index.txt")

    if (!fs.existsSync(indexFile)) {
        this.logger?.error(`Unable to find index file ${indexFile}`)
        return
    }

    let grammarIgnoreFile = path.join("/docs", "grammar-ignore.txt")
    let grammarIgnoreData = await fs.promises.readFile(grammarIgnoreFile, 'utf-8')
    const grammarIgnore = grammarIgnoreData.split(/\r?\n/);

    let data = await fs.promises.readFile(indexFile, 'utf-8')
    const lines = data.split(/\r?\n/);
    let errors = 0
    let firstErrorInFile = true
    for ( var i = 0; i < lines.length; i++ ) {
        if ( lines[i].startsWith("#") || lines[i]?.trim().length == 0 ) {
            // Skip comment or empty line
            continue;
        }
        
        let fileName = lines[i]
        let results = JSON.parse(await checkFile(path.join('/docs', lines[i])))

        for (let i = 0; i < results.matches.length; i++) {
            let display = false
            switch (results.matches[i].rule.issueType) {
                case 'grammer': 
                case 'duplication': 
                case 'typographical': 
                    display = grammarIgnore.filter( ignore => ignore == results.matches[i].rule.id || ignore == results.matches[i].rule.category.id ).length == 0
                    break;
            }
            if ( display ) {
                errors++
                if ( firstErrorInFile ) {
                    console.log('-----------------------------------------------------------')
                    console.log(fileName)
                    firstErrorInFile = false
                }
                console.log(results.matches[i].rule)
                console.log(results.matches[i].context)
            }
        }
        if ( firstErrorInFile ) {
            console.log(`${fileName} - OK`)
        }
    }

    

    console.log('===========================================================')
    console.log(`${errors} error(s)`)
    console.log('===========================================================')

    process.exit();
})()

function checkFile(file) {
    return new Promise((resolve, reject) => {
        let command = `cat ${file} | java -jar /lang/LanguageTool-5.4/languagetool-commandline.jar -l en-US --json - > /lang/response.json`
        child_process.execSync(command);
        const data = fs.readFileSync('/lang/response.json',{encoding:'utf8', flag:'r'});
        resolve(data)
    })
}