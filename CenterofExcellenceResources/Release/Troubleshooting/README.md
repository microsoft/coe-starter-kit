# CoE Starter Kit - Troubleshooting Guides

This directory contains troubleshooting guides for common issues encountered with the Microsoft Power Platform Center of Excellence (CoE) Starter Kit.

## Available Guides

### [Missing Connector Information in Power Apps Reports](./Missing-Connector-Information.md)
**Issue**: After installing the November 2025 version, connector information is missing from Power Apps reports even though sync flows run successfully.

**Covers**:
- Diagnosing incomplete inventory syncs
- Checking licensing and pagination limits
- Verifying environment inventory settings
- Validating data in Dataverse tables
- Refreshing Power BI reports
- Handling API throttling issues

## General Troubleshooting Resources

### Official Documentation
- **CoE Starter Kit Overview**: [https://learn.microsoft.com/power-platform/guidance/coe/starter-kit](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- **Setup Guide**: [https://learn.microsoft.com/power-platform/guidance/coe/setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- **After Setup & Upgrades**: [https://learn.microsoft.com/power-platform/guidance/coe/after-setup](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)
- **Known Limitations**: [https://learn.microsoft.com/power-platform/guidance/coe/limitations](https://learn.microsoft.com/power-platform/guidance/coe/limitations)

### Community Support
- **GitHub Issues**: [https://github.com/microsoft/coe-starter-kit/issues](https://github.com/microsoft/coe-starter-kit/issues)
- **Power Platform Governance Community**: [https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

## Common Troubleshooting Patterns

### 1. Sync Flow Issues
Most inventory and data sync issues can be resolved by:
- Checking flow run history for errors
- Verifying service account licensing
- Running manual full inventory via the Driver flow
- Ensuring environment variables are configured correctly

### 2. Licensing and Pagination
- Trial licenses will hit pagination limits
- Ensure the service account has a proper Power Apps or Power Automate license
- Review connector usage limits

### 3. Data Not Appearing in Reports
When data syncs successfully but doesn't appear in reports:
- Check Power BI dataset refresh status
- Verify data exists in Dataverse tables
- Review report filters and slicers
- Confirm environment is not excluded from inventory

### 4. Environment Variables
Always verify environment variables after installation or upgrades:
- Power Automate Environment Variable
- is All Environments Inventory
- DelayInventory (for large tenants)
- Inventory and Telemetry settings

### 5. Solution Updates and Unmanaged Layers
- Remove unmanaged customization layers before applying updates
- Document customizations separately
- Follow the upgrade guide precisely

## Before Opening an Issue

When encountering a problem:

1. **Search existing issues**: Your issue may already be documented with a solution
2. **Check official documentation**: The setup and limitations docs cover many scenarios
3. **Review flow run history**: Most issues show error details in flow runs
4. **Verify basic configuration**: Environment variables, licensing, and connections

## Opening a New Issue

If you need to open a new issue, please provide:

- **Clear description**: What is not working as expected?
- **Solution version**: Which version of the CoE Starter Kit are you using?
- **Component**: Which app, flow, or component is affected?
- **Steps to reproduce**: Detailed steps to recreate the issue
- **Screenshots**: Visual evidence of the problem
- **Flow run details**: Error messages, run history, timestamps
- **Environment info**: Cloud vs. GCC, licensing type, tenant size
- **What you've tried**: Troubleshooting steps already attempted

## Contributing Troubleshooting Guides

Have you resolved a tricky issue? Consider contributing a troubleshooting guide:

1. Fork the repository
2. Create a new markdown file in this directory
3. Follow the template structure:
   - Issue Description
   - Symptoms
   - Root Causes
   - Troubleshooting Steps
   - Prevention and Best Practices
   - Additional Resources
4. Submit a pull request

See [HOW_TO_CONTRIBUTE.md](../../../HOW_TO_CONTRIBUTE.md) for detailed contribution guidelines.

## Important Disclaimer

The CoE Starter Kit is:
- **Provided as-is** with no official Microsoft support SLA
- A **community-driven template** meant to be customized
- Supported on a **best-effort basis** via GitHub issues
- **Not a product**, but a set of starter templates

For production issues requiring immediate support, consider:
- Microsoft Premier Support for Power Platform
- Paid consulting services from Microsoft partners
- Internal customization and support resources

## Related Resources

- [Release Notes](../Notes/CoEStarterKit/RELEASENOTES.md)
- [Office Hours](../../OfficeHours/OFFICEHOURS.md)
- [How to Contribute](../../../HOW_TO_CONTRIBUTE.md)
