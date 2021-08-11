const fs = require('fs');
const axios = require('axios');
const StreamZip = require('node-stream-zip');

(async () => {
    console.log("Checking language tool downloaded")
    if (!fs.existsSync('/lang/LanguageTool-5.4.zip')) {
        console.log("Downloading tools")
        await downloadFile('https://languagetool.org/download/LanguageTool-5.4.zip', '/lang/LanguageTool-5.4.zip')
        await unzipFile('/lang/LanguageTool-5.4.zip', '/lang')
    }
}
)()

async function downloadFile(fileUrl, outputLocationPath) {
    const writer = fs.createWriteStream(outputLocationPath);
  
    return axios({
      method: 'get',
      url: fileUrl,
      responseType: 'stream',
    }).then(response => {
  
      //ensure that the user can call `then()` only when the file has
      //been downloaded entirely.
  
      return new Promise((resolve, reject) => {
        response.data.pipe(writer);
        let error = null;
        writer.on('error', err => {
          error = err;
          writer.close();
          reject(err);
        });
        writer.on('close', () => {
          if (!error) {
            resolve(true);
          }
          //no need to call the reject here, as it will have been called in the
          //'error' stream;
        });
      });
    });
  }

  function unzipFile(filePath, extractPath) {
    return new Promise((resolve, reject) => {
      const zip = new StreamZip({ file: filePath });
  
      console.log('Extracting ...');
  
      zip
        .on('error', reject)
        .on('ready', () => {
          zip.extract(null, extractPath, (error, count) => {
            if (error) {
              return reject(error);
            }
  
            console.log(`Done! Extracted ${count} entries to "${extractPath}"`);
            zip.close();
  
            return resolve();
          });
        });
    });
  }