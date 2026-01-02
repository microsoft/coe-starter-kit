# CoE Starter Kit - Troubleshooting Guides

This directory contains troubleshooting guides for common issues encountered when setting up and using the Center of Excellence (CoE) Starter Kit.

## Available Guides

### Setup and Configuration Issues

- **[Apps and Flows Not Appearing in Power BI Dashboards](PowerBI-Dashboard-No-Data.md)** - Comprehensive guide for troubleshooting when your Power BI dashboards don't show app and flow data after initial setup.

## Before You Start Troubleshooting

Before diving into specific troubleshooting guides, ensure you have:

1. ✅ Reviewed the [official setup documentation](https://docs.microsoft.com/power-platform/guidance/coe/setup)
2. ✅ Verified you followed all setup steps in order
3. ✅ Checked [existing issues](https://aka.ms/coe-starter-kit-issues) to see if your problem has been reported
4. ✅ Reviewed the [FAQ](https://docs.microsoft.com/power-platform/guidance/coe/faq)

## General Troubleshooting Tips

### 1. Check Flow Run History
Most CoE Starter Kit functionality depends on flows running successfully. Always check:
- Flow status (ON/OFF)
- Run history
- Error messages
- Connection authentication

### 2. Verify Permissions
The service account running CoE flows needs:
- Power Platform Administrator or Dynamics 365 Administrator role
- Proper licenses
- Access to all environments you want to monitor

### 3. Review Environment Variables
Incorrect environment variables are a common source of issues:
- Admin email
- Environment ID
- Tenant ID
- Any custom configuration values

### 4. Wait for Scheduled Operations
Many CoE operations run on schedules:
- Initial inventory can take 24+ hours
- Flows typically run daily
- Data refresh happens on schedule

### 5. Check Dataverse Tables
Verify data is being collected properly:
- Open the environment in Power Apps
- Check tables for records
- Look at Created On dates

## Getting Help

If you can't resolve your issue using these guides:

1. **Search existing issues**: https://github.com/microsoft/coe-starter-kit/issues
2. **Check the wiki**: https://github.com/microsoft/coe-starter-kit/wiki
3. **Review documentation**: https://docs.microsoft.com/power-platform/guidance/coe/starter-kit
4. **Create a new issue**: https://aka.ms/coe-starter-kit-issues

When creating an issue, please include:
- CoE Starter Kit version
- Solution component (Core, Governance, Nurture, etc.)
- Specific app or flow affected
- Error messages or screenshots
- Steps to reproduce
- What you've already tried

## Contributing

Found a solution to a common issue? Consider contributing a troubleshooting guide:
1. Create a detailed markdown file in this directory
2. Add it to the list above
3. Submit a pull request

See [HOW_TO_CONTRIBUTE.md](../HOW_TO_CONTRIBUTE.md) for more information.

## Additional Resources

- **CoE Starter Kit Documentation**: https://docs.microsoft.com/power-platform/guidance/coe/starter-kit
- **Setup Guide**: https://docs.microsoft.com/power-platform/guidance/coe/setup
- **Community Forum**: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps
- **Release Notes**: https://github.com/microsoft/coe-starter-kit/releases

## Disclaimer

The CoE Starter Kit is a community-supported solution. While the underlying Power Platform features are fully supported, the kit itself represents sample implementations. For issues with the kit, use GitHub issues. For issues with core Power Platform features, contact Microsoft Support through your standard support channel.
