import walkSync from "walk-sync";
import { execSync } from "child_process";
import path from  "path";
import fs from "fs";
import { URL } from 'url';
const __dirname = new URL('.', import.meta.url).pathname.substr(1);

console.log(__dirname)
const paths = walkSync(__dirname, {globs: ["**/*.mmd"]})

let mmdc = path.normalize(path.join(__dirname, '../node_modules/.bin/mmdc'))

for ( let i = 0; i < paths.length; i++) {
    console.log(paths[i])
    let fullPath = path.normalize(path.join(__dirname, paths[i]))
    let newPath = fullPath.replace(".mmd", ".png")
    let css = fullPath.replace(".mmd", ".css")
    if (fs.existsSync(css)) {
        execSync(`${mmdc} -i ${fullPath} -o ${newPath} -C ${css}`)
        execSync(`${mmdc} -i ${fullPath} -o ${newPath.replace(".png", ".svg")} -C ${css}`)
    } else {
        execSync(`${mmdc} -i ${fullPath} -o ${newPath}`)
    }
}