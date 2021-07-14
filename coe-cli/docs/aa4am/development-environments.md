## Development Environments

Each advanced maker will need a development environment created. Advanced makers can use a community environment to work in. Community environments can be accessed from the sign-up page https://web.powerapps.com/community/signup

### Admin Maker Setup

As Azure DevOps Administrator you will need to register each advanced maker environment. The following command will add the required service connection to the development environment and setup security for the user

```bash
coe aa4am maker add \
  -o https://dev.azure.com/dev12345 \
  -p alm-sandbox \
  -e https://org12345-dev.crm.dynamics.com \
  -u username@contoso.com
```

More information on the [coe aa4am maker add](../help/aa4am/maker/add.md) command

### Read Next

- Complete the [Install Overview](./readme.md#install-overview)
