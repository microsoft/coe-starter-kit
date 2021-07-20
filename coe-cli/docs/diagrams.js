const walkSync = require("walk-sync");
const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");
const paths = walkSync(__dirname, {globs: ["**/*.mmd"]});

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