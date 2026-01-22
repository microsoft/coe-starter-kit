# CoE Starter Kit - Sovereign Cloud Support

## Overview

This document provides guidance on deploying and upgrading the CoE Starter Kit in sovereign cloud environments, including GCC, GCC High, DoD, and other national clouds.

## Current Status - GCC High Tenants

### Power Platform for Admins V2 Connector Availability

As of January 2026, the **Power Platform for Admins V2** connector has been made available in GCC High tenants. This is a significant milestone that enables sovereign cloud customers to utilize newer versions of the CoE Starter Kit.

### Connector Prerequisites

Before attempting to install or upgrade the CoE Starter Kit in GCC High:

1. **Verify Connector Availability**: Confirm that the "Power Platform for Admins V2" connector is enabled in your GCC High tenant
2. **Admin Center Access**: Ensure you have access to the new Power Platform Admin Center for GCC High
3. **Permissions**: Verify you have the necessary admin permissions to create connections using the connector

## Upgrade Guidance for GCC High Tenants

### Current Version Status

If you are currently on:
- **Core Components**: v4.42 or older
- **Governance Components**: v3.25 or older

And it has been **over a year** since your last upgrade, special considerations apply.

### Recommended Upgrade Path

#### Option 1: Direct Upgrade (Recommended for Most Scenarios)

With the availability of the Power Platform for Admins V2 connector, you can now perform a direct upgrade to the latest version:

1. **Review Release Notes**: Check the [latest release notes](https://github.com/microsoft/coe-starter-kit/releases) to understand new features and breaking changes
2. **Backup Current Configuration**: Export your current environment variables and document custom configurations
3. **Plan for Connection Updates**: Be prepared to recreate connections using the new V2 connector
4. **Follow Standard Upgrade Process**: Use the standard upgrade documentation at https://docs.microsoft.com/power-platform/guidance/coe/after-setup

#### Option 2: Incremental Upgrade (For Heavily Customized Environments)

If you have extensive customizations or complex dependencies:

1. **Assess Customizations**: Document all custom flows, apps, and modifications
2. **Review Major Version Changes**: Focus on significant releases between v4.42 and current
3. **Test in Non-Production**: If possible, test the upgrade path in a development environment first
4. **Consider Staged Migration**: For critical customizations, consider upgrading through intermediate versions

### Key Considerations for Sovereign Clouds

#### 1. Connector Compatibility

- **Power Platform for Admins V2**: Now available in GCC High (as of 2026)
- **Legacy Connectors**: Some older connectors may not be available in sovereign clouds
- **Custom Connectors**: Verify any custom connectors are supported in your cloud environment

#### 2. Feature Availability Delays

Sovereign clouds typically receive features after they are deployed to commercial clouds:

- **Expected Delay**: 2-12 months for major features
- **Communication**: Monitor the Power Platform release planner for sovereign cloud timelines
- **Admin Center**: Feature parity may not be complete; verify functionality post-upgrade

#### 3. Data Residency and Compliance

- **Data Location**: All CoE data remains within the sovereign cloud boundary
- **Audit Logs**: Ensure audit log access is configured correctly for your cloud type
- **Compliance**: Verify that upgraded components maintain required compliance certifications

#### 4. Known Limitations

- **Telemetry Collection**: Some telemetry features may have limited functionality
- **Power BI Integration**: Power BI Government cloud requires separate configuration
- **Microsoft 365 Integration**: Teams and other integrations must use sovereign cloud endpoints

## Step-by-Step Upgrade Process for GCC High

### Pre-Upgrade Checklist

- [ ] Verify Power Platform for Admins V2 connector is available
- [ ] Document current version of all installed components
- [ ] Export and backup environment variables
- [ ] Document all custom configurations and modifications
- [ ] Review release notes for versions between current and target
- [ ] Identify deprecated features or breaking changes
- [ ] Plan maintenance window with users
- [ ] Prepare rollback plan if needed

### Upgrade Steps

1. **Download Latest Release**
   - Navigate to https://github.com/microsoft/coe-starter-kit/releases
   - Download the latest managed solution files
   - Review the release notes for your target version

2. **Update Core Components**
   ```
   - Import CenterofExcellenceCoreComponents_x.xx_managed.zip
   - Update connections to use Power Platform for Admins V2
   - Reconfigure environment variables as needed
   - Test inventory flows
   ```

3. **Update Governance Components**
   ```
   - Import CenterofExcellenceAuditComponents_x.xx_managed.zip
   - Update connections and environment variables
   - Test compliance and governance flows
   ```

4. **Update Additional Components**
   - Import any additional solution files (Nurture, Audit Logs, etc.)
   - Update connections for each component
   - Verify functionality

5. **Post-Upgrade Validation**
   - Test key flows (inventory sync, compliance checks)
   - Verify Power BI dashboards refresh correctly
   - Check app functionality
   - Monitor for errors in flow run history

### Troubleshooting Common Issues

#### Connection Errors After Upgrade

**Symptom**: Flows fail with connection authentication errors

**Solution**:
1. Navigate to each flow in the solution
2. Delete old connections
3. Create new connections using Power Platform for Admins V2
4. Update connection references in flows

#### Missing Inventory Data

**Symptom**: Apps show no data or incomplete inventory

**Solution**:
1. Manually trigger the "Admin | Sync Template v3" flow
2. Allow 2-4 hours for full inventory sync
3. Check flow run history for specific errors
4. Verify admin permissions haven't changed

#### Power BI Dashboard Not Refreshing

**Symptom**: Dashboard shows stale data

**Solution**:
1. Verify Power BI is configured for Government cloud
2. Update connection strings to use sovereign cloud endpoints
3. Reconfigure scheduled refresh with new credentials

## Version-Specific Notes

### Upgrading from v4.42 (2023)

Major changes to be aware of:

1. **Connection References**: Significant changes to how connections are managed
2. **Environment Variables**: New variables added, some deprecated
3. **Flow Updates**: Many flows rewritten for improved performance
4. **Dataverse Schema**: Table schema updates may require data migration
5. **Power BI Reports**: Report structure significantly updated

### Breaking Changes in Recent Versions

Review these milestones for breaking changes:
- [View closed milestones](https://github.com/microsoft/coe-starter-kit/milestones?state=closed)
- Focus on versions between v4.42 and current release

## Additional Resources

### Official Documentation
- CoE Starter Kit Overview: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- Setup Guide: https://learn.microsoft.com/power-platform/guidance/coe/setup
- Upgrade Guide: https://learn.microsoft.com/power-platform/guidance/coe/after-setup

### Sovereign Cloud Resources
- Power Platform US Government: https://learn.microsoft.com/power-platform/admin/powerapps-us-government
- GCC High Service Description: https://learn.microsoft.com/office365/servicedescriptions/office-365-platform-service-description/office-365-us-government/gcc-high-and-dod

### Support Channels
- GitHub Issues: https://github.com/microsoft/coe-starter-kit/issues
- Community Forum: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps

## Frequently Asked Questions

### Q: Can I now upgrade my GCC High tenant to the latest CoE Starter Kit?

**A**: Yes, with the availability of the Power Platform for Admins V2 connector in GCC High, you can now upgrade to recent versions of the CoE Starter Kit. Follow the upgrade guidance in this document.

### Q: Should I upgrade incrementally or directly to the latest version?

**A**: For most scenarios, a direct upgrade to the latest version is recommended. However, if you have extensive customizations or have been on an old version for over a year, review the release notes carefully for breaking changes.

### Q: What happened to issue #8835?

**A**: Issue #8835 was likely closed because the blocking issue (Power Platform for Admins V2 connector availability in GCC High) has been resolved. The connector is now available in sovereign clouds.

### Q: Are all CoE Starter Kit features available in GCC High?

**A**: Most features are available, but some may have limitations due to sovereign cloud constraints:
- Core inventory and governance features: Fully supported
- Power BI dashboards: Supported with Government cloud configuration
- Teams integration: Supported with GCC High Teams
- Certain integrations may require sovereign cloud-specific endpoints

### Q: How long does the upgrade take?

**A**: Plan for 4-8 hours for a complete upgrade including:
- Solution imports: 1-2 hours
- Connection updates: 1-2 hours
- Initial inventory sync: 2-4 hours
- Testing and validation: 1-2 hours

### Q: What if I encounter issues during upgrade?

**A**: 
1. Check flow run history for specific error messages
2. Search existing GitHub issues: https://github.com/microsoft/coe-starter-kit/issues
3. Create a new issue with detailed information if needed
4. Note: The CoE Starter Kit is provided as-is with community support

## Support Notice

The CoE Starter Kit is provided as sample implementations and is not officially supported by Microsoft Support. While the underlying Power Platform features are fully supported, the kit itself is maintained through community contributions and GitHub issues.

For issues:
- CoE Starter Kit specific issues: Report at https://github.com/microsoft/coe-starter-kit/issues
- Power Platform platform issues: Contact Microsoft Support through standard channels

---

**Last Updated**: January 2026
**Applicable Versions**: v4.42 and later
**Cloud Environments**: GCC, GCC High, DoD, and other sovereign clouds
