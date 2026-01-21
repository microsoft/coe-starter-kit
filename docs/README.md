# CoE Starter Kit Troubleshooting Documentation

This directory contains troubleshooting guides for common issues encountered when using the CoE Starter Kit.

## Available Troubleshooting Guides

### Data Sync Issues
- [AI Credits Usage Data Not Updating](TROUBLESHOOTING-AI-CREDITS-USAGE.md) - Learn why AI Credits Usage data stops updating and how to fix it

## General Troubleshooting Steps

### For Data Not Updating Issues
If any data in your CoE Power BI report is not updating (Apps, Flows, AI Credits, etc.):

1. **Check if Sync Flows are On**
   - Navigate to Power Automate → Solutions → Core Components
   - Verify all "Admin | Sync Template v4" flows are turned **On**
   - Check the "Admin | Audit Logs" flows if audit data is missing

2. **Review Flow Run History**
   - Open each flow and check the Run History
   - Look for failed runs (red status)
   - Click on failed runs to see error details

3. **Verify Dataverse Tables Have New Data**
   - Navigate to your CoE Dataverse environment
   - Open the relevant tables (admin_apps, admin_flows, admin_aicreditsusages, etc.)
   - Check if rows exist with recent Modified On dates
   - If no new rows exist, the sync flows are not running or receiving data

4. **Check the Sync Flow Errors Table**
   - Navigate to Tables → Sync Flow Errors (`admin_syncflowerrorses`)
   - Look for recent error entries
   - Use error messages to diagnose specific issues

5. **Manually Trigger Sync Flows**
   - Run the **Admin | Sync Template v4 (Driver)** flow to trigger all sync flows
   - Or manually run individual sync flows for specific data types

6. **Refresh Power BI Report**
   - After confirming new data in Dataverse, refresh the Power BI report
   - New data should appear in the visualizations

## Common Causes of Data Sync Issues

### Flow is Turned Off
- **Symptom**: No new data appears after a certain date
- **Solution**: Turn on the relevant sync flow

### Authentication Failures
- **Symptom**: Flow runs fail with "Unauthorized" or authentication errors
- **Solution**: 
  - Re-authenticate connection references
  - Verify the flow owner has necessary permissions
  - Check if app registrations or service principals are configured correctly

### Insufficient Permissions
- **Symptom**: Flow runs fail when accessing specific environments
- **Solution**: 
  - Ensure the flow owner has System Administrator role in all environments
  - Verify Power Platform Admin or Global Admin permissions

### Environment Not Configured
- **Symptom**: Data from some environments is missing
- **Solution**:
  - Check if environments are marked as "Excuse from Inventory" (admin_excusefrominventory)
  - Verify environments have Dataverse (admin_hascds = true)
  - Ensure environments are not deleted (admin_environmentdeleted = false)

### Flow Throttling
- **Symptom**: Flow runs slowly or times out
- **Solution**:
  - Enable the "DelayObjectInventory" environment variable
  - This adds random delays to prevent throttling
  - Consider running flows during off-peak hours

## Need More Help?

### Official Documentation
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Troubleshooting Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-troubleshooting)

### Community Support
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) - Report bugs or ask questions
- [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps) - General Power Platform governance questions

### When Opening an Issue
Please include:
1. **CoE Starter Kit version** (e.g., 4.50.6)
2. **Solution affected** (Core Components, Audit Logs, etc.)
3. **App or flow name** (if applicable)
4. **Steps to reproduce** the issue
5. **Screenshots** of errors or unexpected behavior
6. **Flow run error details** (if available)
7. **What you've already tried** to fix the issue
# CoE Starter Kit Documentation

This directory contains additional documentation and guides for the CoE Starter Kit.

## Available Documentation

### [Service Principal Support Guide](./ServicePrincipalSupport.md)
Comprehensive guide on using Service Principals with the CoE Starter Kit, including:
- Understanding Service Principals vs Service Accounts
- Component-specific support details
- Migration guidance from Service Account to Service Principal
- Best practices and FAQs

## Official Documentation

For complete setup instructions and documentation, please visit:
- [Microsoft Power Platform CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

## Contributing

If you'd like to contribute to the documentation, please see [HOW_TO_CONTRIBUTE.md](../HOW_TO_CONTRIBUTE.md) in the root of this repository.

## Questions and Issues

- **Questions**: Use the [Question issue template](../.github/ISSUE_TEMPLATE/5-coe-starter-kit-question.yml)
- **Bug Reports**: Use the appropriate [issue template](../.github/ISSUE_TEMPLATE/)
- **Discussions**: Visit [GitHub Discussions](https://github.com/microsoft/coe-starter-kit/discussions)
