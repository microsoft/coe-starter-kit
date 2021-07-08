# Upgrade

Upgrade will depend on how you installed the COE cli

## Download

It you downloaded the COE CLI as a zip file or a git clone

- Download the new zip file
- Unzip the zip file to a new folder 

OR

- Pull changes from git

```bash
git pull

```

ONe you have a local version of the coe-cli change to coe-cli folder

```
cd coe-cli

```

### Local Upgrade

In the coe-cli folder run the following commands

1. Install the dependencies

```bash
npm install

```

5. Build the new version

```bash
npm run build

```

6. Update coe-cli to new version

```bash
npm link --force

```

## Docker Image

In the coe-cli folder run the following commands

1. Build new docker image

```bash
docker build -t coe-cli .

```

