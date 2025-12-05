# CoE Starter Kit Troubleshooting Guides

This directory contains detailed troubleshooting guides for common issues encountered when using the Microsoft Power Platform Center of Excellence (CoE) Starter Kit.

## Available Guides

### [Flow Last Run and App Last Launched Data Not Visible](./flow-last-run-app-last-launched.md)

**Issue:** Missing Flow Last Run timestamps and App Last Launched information in CoE dashboards

**Affected Components:** Core Components - Inventory Flows

**Root Cause:** Platform limitation - these fields are only available with BYODL (Data Export) architecture, not Cloud Flows

**Solutions:**
- Use Audit Logs for telemetry (recommended)
- PowerShell for ad-hoc queries
- Plan for Microsoft Fabric integration

---

## How to Use These Guides

1. **Identify Your Issue:** Browse the available guides or search for keywords
2. **Check Root Cause:** Understand why the issue occurs
3. **Review Solutions:** Follow recommended workarounds or fixes
4. **Check Additional Resources:** Links to official Microsoft documentation

## General Troubleshooting Tips

### Before You Start

1. **Check Your Version:** Ensure you're using the latest CoE Starter Kit release
2. **Review Setup:** Verify all setup steps were completed correctly
3. **Search Existing Issues:** Check [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
4. **Check Documentation:** Visit the [official docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

### Common Setup Issues

- **Connections not configured:** Verify all connections are set up with appropriate admin credentials
- **Environment variables missing:** Check that all required environment variables are populated
- **Permissions:** Ensure service accounts have Power Platform Administrator role
- **Flows turned off:** Activate all sync flows after installation

### Getting Help

1. **GitHub Issues:** [Report bugs or ask questions](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
2. **Community Forums:** [Power Apps Community](https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1)
3. **Office Hours:** Check [CoE Office Hours](../CenterofExcellenceResources/OfficeHours/OFFICEHOURS.md) schedule
4. **Documentation:** [Official CoE Starter Kit docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

## Contributing

Found a solution to a common problem? Consider contributing a troubleshooting guide:

1. Create a markdown file in this directory
2. Follow the format of existing guides
3. Include root cause analysis and clear solutions
4. Submit a pull request

See [How to Contribute](../../HOW_TO_CONTRIBUTE.md) for details.

---

*These guides are community-contributed and may be updated as the CoE Starter Kit evolves.*
