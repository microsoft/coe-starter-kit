# Overview

Upgrade will depend on how you installed the COE cli

## Zip Download

It you downloaded the COE CLI as a zip file

1. Download the new zip file

2. Unzip the zip file to a new folder

3. Change to coe-cli folder

```
cd coe-cli
```

4. Install the dependencies

```bash
npm install
```

5. Build the new version

```bash
npm run build
```

6. Update coe to new version

```bash
npm link --force
```

## Git Clone

1. Pull the latest version

```bash
git pull
```

2. Change to coe-cli folder

```
cd coe-cli
```

3. Build the new version

```bash
npm run build
```

Notes:
1. The new version will now be globally available

## Docker Image

1. Unzip the zip file or pull the latest version of the code

2. Change to coe-cli folder

```
cd coe-cli
```

2. Build new docker image

```bash
docker build -t coe-cli .
```

