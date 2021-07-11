## Install Generate

### Description

Generate install configuration file for installation of the ALM Accelerator for Advanced Makers (AA4AM)

### Examples

Example command line

```bash
coe aa4am generate install -o install.json
```

To use the generated install file

```bash
coe aa4am install -f install.json
```

Read more on [install command](../install.md)

### Parameters

#### -o, --output

**Optional** name of the output JSON file to be created. If **-o** argument not found JSON results will be displayed in the console

### -s, --includeSchema

Defaults to **true** to reference and copy JSON schema in the same folder as the --output file. 

If **false** then it will not reference or create the schema file