# CoE Starter Kit - Troubleshooting Documentation

This directory contains troubleshooting guides and FAQs to help resolve common issues with the CoE Starter Kit.

## Available Guides

### [FAQ - Common Issues](FAQ-COMMON-ISSUES.md)
Quick answers to frequently asked questions including:
- Inventory and data synchronization
- Admin View issues  
- Setup and configuration
- Permissions and licensing
- Performance and throttling
- Best practices

### [Troubleshooting: Inventory Sync](TROUBLESHOOTING-INVENTORY-SYNC.md)
Detailed step-by-step guide for diagnosing and fixing inventory synchronization issues, including:
- Power Platform Admin View not updating
- Missing apps, flows, or environments
- Outdated data in dashboards
- Full vs incremental inventory
- Connection and permission issues

### [Issue Response Templates](ISSUE-RESPONSE-TEMPLATES.md)
For maintainers: Ready-to-use response templates for common issues including:
- Inventory sync problems
- Missing data in Admin View
- "None" inventory method issues
- Post-upgrade problems
- How to customize responses

## Quick Links

### Most Common Issues

1. **[Admin View is empty or missing data](TROUBLESHOOTING-INVENTORY-SYNC.md#solution-1-run-full-inventory-most-common-fix)**
   - Set `FullInventory = Yes`
   - Run Driver flow manually
   - Wait for completion

2. **[Inventory method shows "None"](FAQ-COMMON-ISSUES.md#q-my-data-is-showing-as-none-for-inventory-method-is-this-correct)**
   - Flows are not configured
   - Follow setup documentation

3. **[Data stopped updating after upgrade](FAQ-COMMON-ISSUES.md#scenario-i-just-upgraded-and-now-nothing-works)**
   - Reconfigure connections
   - Verify environment variables
   - Turn on flows
   - Run full inventory

### Official Resources

- [CoE Starter Kit Official Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

## Contributing

If you've encountered and resolved an issue not covered here, please consider contributing:

1. Check if the issue is already documented
2. Follow the [contribution guidelines](../HOW_TO_CONTRIBUTE.md)
3. Submit a pull request with your addition

## Need Help?

If these guides don't resolve your issue:

1. **Search** [existing GitHub issues](https://github.com/microsoft/coe-starter-kit/issues)
2. **Report** a new issue using the [bug template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
3. **Include** diagnostic information:
   - CoE Starter Kit version
   - Flow run history and error messages
   - Environment variable values
   - Service account permissions

---

**Note:** The CoE Starter Kit is best-effort and community-supported. While the underlying Power Platform features are fully supported by Microsoft Support, the kit itself is not. Report issues on GitHub for community assistance.
