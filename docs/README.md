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
# CoE Starter Kit Documentation

This directory contains additional documentation, troubleshooting guides, and resources for the Microsoft Power Platform Center of Excellence (CoE) Starter Kit.

## Documentation Index

### Troubleshooting Guides

- **[Troubleshooting: Entity 'admin_flow' Does Not Exist Error](troubleshooting-sync-helper-cloud-flows-entity-not-exist.md)**  
  Comprehensive guide for resolving the "Entity 'admin_flow' With Id = [GUID] Does Not Exist" error in SYNC HELPER - Cloud Flows

### Issue Response Templates

- **[Issue Response: PowerPages Sessions](ISSUE-RESPONSE-PowerPages-Sessions.md)**  
  Template for responding to PowerPages sessions-related issues

- **[Issue Response: Entity admin_flow Does Not Exist](ISSUE-RESPONSE-entity-admin-flow-not-exist.md)**  
  Template for responding to admin_flow entity not exist errors

- **[General Issue Response Templates](issue-response-templates.md)**  
  Collection of templates for common issue responses

### Feature Documentation

- **[Enhancement Analysis: PowerPages Sessions](ENHANCEMENT-ANALYSIS-PowerPages-Sessions.md)**  
  Analysis and documentation for PowerPages sessions feature

- **[Service Principal Support](ServicePrincipalSupport.md)**  
  Information about using service principals with the CoE Starter Kit

### Cloud Deployment Guides

- **[Sovereign Cloud Support](sovereign-cloud-support.md)**  
  Guidance for deploying CoE Starter Kit in sovereign clouds (GCC, GCC High, DoD)

- **[GCC High Upgrade Quick Start](gcc-high-upgrade-quickstart.md)**  
  Quick start guide for upgrading CoE Starter Kit in GCC High environments

### Solution Information

- **[Solution Summary](SOLUTION_SUMMARY.md)**  
  High-level summary of CoE Starter Kit solutions and components

## Additional Resources

### Official Documentation

For comprehensive setup instructions, feature documentation, and best practices, visit the official Microsoft Learn documentation:

📖 [Power Platform CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

### GitHub Resources

- **[Main Repository](https://github.com/microsoft/coe-starter-kit)**
- **[Release Notes](../CenterofExcellenceResources/Release/Notes/CoEStarterKit/RELEASENOTES.md)**
- **[Issues and Support](https://github.com/microsoft/coe-starter-kit/issues)**
- **[Contributing Guide](../HOW_TO_CONTRIBUTE.md)**

### Community Resources

- **[Power Platform Community - Governance and Administration](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)**
- **[CoE Office Hours](../CenterofExcellenceResources/OfficeHours/OFFICEHOURS.md)**

## Common Topics

### Setup and Installation

- [Initial Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Environment Setup Best Practices](https://learn.microsoft.com/power-platform/guidance/coe/setup-environment)
- [Upgrading the CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/setup-upgrade)

### Data Management

- [Data Retention and Maintenance Guide](../CenterofExcellenceResources/DataRetentionAndMaintenance.md)
- [Quick Start: Data Cleanup](../CenterofExcellenceResources/QuickStart-DataCleanup.md)

### Administration

- [Admin Role Requirements FAQ](../CenterofExcellenceResources/FAQ-AdminRoleRequirements.md)

## Getting Help

### Before Creating an Issue

1. **Search existing issues**: Check if your question or problem has already been reported
2. **Review documentation**: Consult the official Microsoft Learn documentation
3. **Check troubleshooting guides**: Review the guides in this directory
4. **Visit the community**: Ask questions in the Power Platform Community forums

### Creating a New Issue

When creating a new issue, please:

1. **Use the appropriate template**: Select the correct issue template for your situation
2. **Provide details**: Include version numbers, error messages, and screenshots
3. **Describe your environment**: Note any unique configurations or constraints
4. **List steps tried**: Mention troubleshooting steps you've already attempted

[Create a New Issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

## Contributing

We welcome contributions to the documentation! Please see the [Contributing Guide](../HOW_TO_CONTRIBUTE.md) for information on how to contribute.

### Documentation Guidelines

When contributing documentation:

- Use clear, concise language
- Include step-by-step instructions where appropriate
- Add screenshots or diagrams for complex concepts
- Link to official Microsoft Learn documentation for foundational topics
- Follow the existing structure and formatting conventions

## Support Statement

The CoE Starter Kit is provided as-is with best-effort support through the GitHub community. For issues requiring official Microsoft support, please contact your Microsoft account representative.

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

**Last Updated**: 2026-01-22  
**CoE Starter Kit Version**: 4.50.8+
