# Troubleshooting CoE Starter Kit Solution Import Errors

This document provides guidance on resolving common import errors when installing or upgrading CoE Starter Kit solutions.

## Table of Contents
- [Common Import Errors](#common-import-errors)
- [Error 80097376 - BadGateway](#error-80097376---badgateway)
- [Error 80072031 - Operation Status Unknown](#error-80072031---operation-status-unknown)
- [General Troubleshooting Steps](#general-troubleshooting-steps)
- [Best Practices for Solution Upgrades](#best-practices-for-solution-upgrades)
- [When to Contact Support](#when-to-contact-support)

---

## Common Import Errors

When importing or upgrading CoE Starter Kit solutions, you may encounter transient errors related to Power Platform service connectivity, flow deployment, or resource provisioning. Most of these errors are temporary and can be resolved by following the troubleshooting steps in this guide.

---

## Error 80097376 - BadGateway

### Error Details
- **Error Code**: 80097376
- **Common Message**: "Error while importing workflow type ModernFlow name [Flow Name]: Flow server error returned with status code 'BadGateway'"
- **Affected Components**: Typically affects flows during solution import/upgrade

### Root Cause
This error indicates a temporary connectivity or service availability issue between Power Platform services. It commonly occurs when:
- The Flow service is experiencing temporary service degradation
- Network connectivity issues between Power Platform services
- The environment is under heavy load
- Service endpoints are temporarily unavailable

### Resolution Steps

#### Step 1: Wait and Retry
1. Wait 5-10 minutes before attempting another import
2. Navigate to **Solutions** in Power Platform admin center
3. Delete the partially imported solution if it exists (if import failed)
4. Re-import the solution using the same managed solution file

#### Step 2: Check Service Health
1. Visit [Microsoft 365 Service Health Dashboard](https://admin.microsoft.com/Adminportal/Home#/servicehealth)
2. Check for any active incidents affecting Power Platform or Power Automate
3. If there's an active incident, wait for Microsoft to resolve it before retrying

#### Step 3: Import During Off-Peak Hours
If the error persists:
1. Schedule the import during off-peak hours (typically evenings or weekends)
2. Ensure no other large operations are running in the environment
3. Temporarily disable any flows that might be running during import

#### Step 4: Import in Stages (If Applicable)
For large solution upgrades:
1. Review dependencies and consider importing dependent solutions first
2. Ensure all prerequisites are met (connections, environment variables, etc.)
3. Clear browser cache before attempting import

### Prevention
- Always test upgrades in a development or test environment first
- Document any customizations that might conflict with the upgrade
- Review release notes for breaking changes or special upgrade instructions
- Schedule production upgrades during maintenance windows

---

## Error 80072031 - Operation Status Unknown

### Error Details
- **Error Code**: 80072031
- **Common Message**: "This operation completed without reporting its status. The end time is unknown and has been set to the start time. You can safely retry the operation."
- **Affected Components**: Can affect any solution component during import

### Root Cause
This error occurs when the solution import operation completes but fails to report its completion status properly. This is typically caused by:
- Service communication timeouts
- Long-running import operations
- Background processes taking longer than expected
- Platform service temporarily unable to update operation status

### Resolution Steps

#### Step 1: Verify Import Status
1. Navigate to **Solutions** in the Power Platform admin center
2. Check if the solution appears in the solutions list
3. Verify the version number matches the expected version
4. Check if flows are present and enabled

#### Step 2: Check for Partial Import
1. Review solution components to identify any missing items
2. Check flow connection references and ensure they're configured
3. Verify environment variables are set correctly
4. Review any apps or other components in the solution

#### Step 3: Retry the Import
As the error message indicates, it's safe to retry:
1. If the solution is partially imported, delete it first
2. Wait 5-10 minutes
3. Re-import the solution
4. Monitor the import progress

#### Step 4: Alternative Import Method
If standard import continues to fail:
1. Try importing via PowerShell using the Power Platform CLI
2. Use smaller batch operations if possible
3. Ensure adequate API rate limits and service capacity

### Example PowerShell Import
```powershell
# Install Power Platform CLI if not already installed
# pac install latest

# Authenticate
pac auth create --url https://yourorg.crm.dynamics.com

# Import solution
pac solution import --path "CenterofExcellenceCoreComponents_managed.zip" --async
```

---

## General Troubleshooting Steps

### Pre-Import Checklist
- [ ] Review the [official setup documentation](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [ ] Verify you have the correct license (Premium licenses required for most components)
- [ ] Ensure you're importing into the correct environment
- [ ] Check that all prerequisite solutions are installed and up to date
- [ ] Verify environment has sufficient storage capacity
- [ ] Ensure you have System Administrator or System Customizer role

### During Import
1. **Monitor Progress**: Don't navigate away during import
2. **Don't Interrupt**: Allow the import to complete fully
3. **Note Errors**: Document any error messages completely
4. **Screenshot Issues**: Capture screenshots of errors for support

### Post-Import
1. **Verify Components**: Check that all expected components are present
2. **Configure Connections**: Set up required connection references
3. **Set Environment Variables**: Configure all required environment variables
4. **Test Functionality**: Run basic tests to ensure components work
5. **Enable Flows**: Turn on flows as needed based on setup instructions

---

## Best Practices for Solution Upgrades

### Planning Phase
1. **Review Release Notes**: Always read release notes before upgrading
   - [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases)
   - [Upgrade Documentation](https://docs.microsoft.com/power-platform/guidance/coe/after-setup)

2. **Test in Non-Production**: 
   - Create a copy of production in a test environment if possible
   - Test the upgrade process completely before production
   - Document any issues encountered

3. **Backup Before Upgrade**:
   - Export existing solution as backup
   - Document current environment variable values
   - Screenshot current configurations

### Execution Phase
1. **Schedule Maintenance Window**: 
   - Notify users of planned downtime
   - Schedule during low-usage periods
   - Allow sufficient time (2-4 hours recommended)

2. **Disable Flows Before Upgrade**:
   - Turn off scheduled flows to prevent conflicts
   - Document which flows were disabled
   - Plan to re-enable after successful upgrade

3. **Monitor and Document**:
   - Keep detailed notes during upgrade
   - Screenshot any warnings or errors
   - Note timestamps for troubleshooting

### Post-Upgrade Phase
1. **Verify Functionality**:
   - Test key flows and apps
   - Verify data synchronization
   - Check reports and dashboards

2. **Update Connections**:
   - Refresh any connection references if needed
   - Test connections to external systems
   - Verify permissions are still valid

3. **Re-enable Flows**:
   - Turn flows back on systematically
   - Monitor for errors
   - Test critical flows manually

---

## Specific Guidance for DLP-Related Flow Errors

The "DLP Request | Sync Policy to Dataverse (Child)" flow and related DLP flows are part of the DLP Impact Analysis feature. If you encounter errors specific to these flows:

### Prerequisites
1. Ensure you have the Power Platform for Admins connector configured
2. Verify your account has appropriate admin permissions
3. Check that DLP policies exist in your tenant (if you plan to use this feature)

### If You Don't Use DLP Features
If you don't plan to use the DLP Impact Analysis features:
1. You can safely skip errors related to DLP flows during import
2. After import, you can disable these flows if not needed
3. The core inventory and other features will still function

### If You Use DLP Features
1. Ensure all DLP-related connection references are configured
2. Set up the required environment variables for DLP features
3. Follow the [DLP setup documentation](https://docs.microsoft.com/power-platform/guidance/coe/setup-dlp-policies)

---

## When to Contact Support

### Contact Microsoft Support If:
- Errors persist after 3-4 retry attempts over 24 hours
- Service health dashboard shows no issues
- Import succeeds in test environment but fails in production
- Error messages indicate data corruption or security issues
- You receive errors not documented here

### Report Issues on GitHub If:
- You discover a bug in the solution code
- You have a feature request
- You want to contribute improvements
- [Open an issue here](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

### Information to Provide
When reporting issues, include:
- Exact error code and full error message
- Solution version you're trying to import (source and target)
- Environment details (region, type, license)
- Steps you've already tried
- Screenshots of errors
- Timeline of events

---

## Additional Resources

### Official Documentation
- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [Upgrade Instructions](https://docs.microsoft.com/power-platform/guidance/coe/after-setup)
- [Modifying Components](https://docs.microsoft.com/power-platform/guidance/coe/modify-components)

### Community Resources
- [Power Platform Community Forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- [GitHub Discussions](https://github.com/microsoft/coe-starter-kit/discussions)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

### Support
- **CoE Starter Kit**: This is a best-effort, community-supported toolkit. Use GitHub for issues.
- **Power Platform**: For platform-level support, use official Microsoft support channels.
- **Service Health**: Monitor at [https://admin.microsoft.com/servicehealth](https://admin.microsoft.com/servicehealth)

---

## Version History
- **2025-11-19**: Initial version - Added guidance for error codes 80097376 and 80072031

---

**Note**: The CoE Starter Kit is provided as-is and is not covered by Microsoft support. For issues with the toolkit itself, please use the [GitHub repository](https://github.com/microsoft/coe-starter-kit). For issues with the Power Platform service, please contact Microsoft support through your normal channels.
