## Maker Add Generate

### Description

Generate configuration file to add an Maker to an installed the ALM Accelerator

### Examples

Example command line

```bash
coe alm generate maker add -o user.json
```

To use the generated configuration file

```bash
coe alm maker add \
    -f user.json
```

Read more on [maker add command](../../maker/add.md)

### Parameters

#### -o, --output

**Optional** name of the output JSON file to be created. If **-o** argument not found JSON results will be displayed in the console