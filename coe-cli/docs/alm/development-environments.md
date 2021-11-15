## Development Environments

Each maker will need a development environment created. Makers can use a community environment to work in. Community environments can be accessed from the sign-up page https://web.powerapps.com/community/signup

### Admin Maker Setup

As Azure DevOps Administrator you will need to register each maker environment. The following command will add the required service connection to the development environment and setup security for the user

```bash
coe alm maker add \
  -o https://dev.azure.com/dev12345 \
  -p alm-sandbox \
  -e https://org12345-dev.crm.dynamics.com \
  -u username@contoso.com
```

More information on the [coe alm maker add](../help/alm/maker/add.md) command

### Read Next

- Complete the [Install Overview](./readme.md#install-overview)
