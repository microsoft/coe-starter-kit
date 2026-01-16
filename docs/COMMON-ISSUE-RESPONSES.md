# Common CoE Starter Kit Issue Responses

This document contains templates for responding to common CoE Starter Kit issues on GitHub.

## Connection Timeout During Solution Import

**Issue Type**: Platform/Service Issue  
**Applies To**: All CoE solutions (Core, Governance, Nurture, Audit Log, etc.)

### Response Template

Thank you for reporting this issue. The connection timeout you're experiencing during solution import is a **platform-level issue** related to Power Platform services, not a defect in the CoE Starter Kit code itself.

This is a known issue that can occur due to various factors including:
- Temporary Power Platform service issues or high load
- Browser session/cache problems
- Network connectivity
- Large number of connections causing extended load times

### Recommended Solutions

Please try the following troubleshooting steps:

1. **Retry the Import**: Click the "Try again" button in the error dialog, or close and restart the import after waiting a few minutes.

2. **Clear Browser Cache**: Clear your browser cache and cookies, then try importing in an Incognito/Private browsing window.

3. **Try a Different Browser**: Use Microsoft Edge (Chromium-based), Chrome, or Firefox. Ensure your browser is up to date.

4. **Check Network**: Ensure stable internet connection, and try disabling VPN if applicable.

5. **Import During Off-Peak Hours**: Try importing during non-peak hours to avoid service load issues.

6. **Check Service Health**: Verify Power Platform service status:
   - [Microsoft 365 Service Health Dashboard](https://admin.microsoft.com/Adminportal/Home#/servicehealth)
   - [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)

For detailed troubleshooting steps, please see our [Troubleshooting Guide](../docs/TROUBLESHOOTING.md#connection-timeout-during-solution-import).

### If the Issue Persists

If you've tried all the above steps and the issue persists:
- For Power Platform service issues, contact Microsoft Support through your standard support channel
- Provide: solution version, environment details, full error message with Widget ID, and steps already tried

**Note**: The CoE Starter Kit is a sample implementation and is not officially supported by Microsoft Support. However, the underlying Power Platform features and services are fully supported.

---

## Solution Import - Prerequisites Not Met

**Issue Type**: Configuration Issue  
**Applies To**: All CoE solutions

### Response Template

Thank you for reporting this issue. Before importing CoE solutions, please ensure all prerequisites are met:

**Prerequisites**:
1. **Environment Type**: Production environment (not Trial) with sufficient capacity
2. **Permissions**: System Administrator role in the target environment
3. **Language**: English language pack enabled in the environment
4. **Licensing**: Appropriate licenses for connectors used (Premium, per-app/per-user)
5. **Dependencies**: For dependent solutions (Governance, Nurture), ensure Core Components are installed first

Please review the complete prerequisites in the [setup documentation](https://docs.microsoft.com/power-platform/guidance/coe/setup#prerequisites).

If you've met all prerequisites and still experience issues, please provide:
- Solution name and version
- Environment type and region
- Specific error message or screenshot
- Which prerequisite step you're stuck on

---

## BYODL (Bring Your Own Data Lake)

**Issue Type**: Deprecated Feature  
**Applies To**: Data Export / BYODL setup

### Response Template

Thank you for your question about BYODL (Bring Your Own Data Lake).

**Important**: BYODL is **no longer recommended** for new implementations. Microsoft is moving toward Microsoft Fabric as the recommended approach for advanced analytics and data lake scenarios.

**Current Recommendations**:
- For new implementations: Use the standard **Cloud Flows** method for inventory and telemetry
- For existing BYODL users: Continue current implementation but plan migration path to Fabric when available
- Avoid investing in new BYODL setups

For more information:
- [Data Export service deprecation](https://docs.microsoft.com/power-platform/admin/data-export-service-deprecation)
- [Microsoft Fabric integration](https://docs.microsoft.com/power-platform/guidance/coe/fabric)

---

## License/Trial Environment Limitations

**Issue Type**: Licensing Issue  
**Applies To**: Pagination, Connection limits

### Response Template

Thank you for reporting this issue. The behavior you're experiencing is related to **licensing limitations** when using Trial or insufficient license profiles.

**Trial Environment Limitations**:
- Pagination limits on connector operations
- Reduced API call quotas
- Limited storage capacity
- Cannot be used for production CoE implementations

**Validation**:
To test if your license is adequate, run the following flows:
1. Admin | Sync Template v3 (flows)
2. Check the flow run history for pagination warnings

**Solution**:
- Upgrade to a Production environment with appropriate licensing
- Ensure users running the flows have Premium licenses (per-user or per-app)
- Review the [licensing requirements](https://docs.microsoft.com/power-platform/guidance/coe/setup#licensing-requirements)

---

## Language/Localization Issues

**Issue Type**: Configuration Issue  
**Applies To**: All solutions

### Response Template

Thank you for reporting this issue. The CoE Starter Kit currently **supports English only**.

**Requirements**:
- The environment must have the English language pack installed and enabled
- Solution components are not localized for other languages
- Custom localization is the responsibility of implementers if needed

**Solution**:
1. Ensure English language pack is enabled in your environment
2. Review the [language requirements](https://docs.microsoft.com/power-platform/guidance/coe/setup#prerequisites)
3. If you need multi-language support, you'll need to customize the solutions

For guidance on customizing the kit, see: [Modifying Components](https://docs.microsoft.com/power-platform/guidance/coe/modify-components)

---

## Inventory Flows Not Running / No Data

**Issue Type**: Configuration Issue  
**Applies To**: Core Components inventory

### Response Template

Thank you for reporting this issue. If your inventory flows are not running or not collecting data, please check:

**Common Causes**:
1. Flows not turned on
2. Connections not properly configured
3. Environment variables not set correctly
4. Insufficient permissions for the user running flows
5. Flow triggers not scheduled or triggered

**Troubleshooting Steps**:
1. Verify all flows in the Core solution are turned **On**
2. Check flow run history for errors
3. Validate all environment variables are configured per the [setup guide](https://docs.microsoft.com/power-platform/guidance/coe/setup-core-components)
4. Ensure the user account has appropriate admin permissions
5. Manually trigger the "Admin | Sync Template v3" flows to test
6. Check for errors in the "admin_SyncFlowErrors" table

**Full Inventory**:
If you need to run a complete inventory:
1. Turn off all flows except the driver flows
2. Clear existing data (if starting fresh)
3. Run the driver flows manually
4. Monitor progress in the admin app

For detailed setup instructions, see: [Core Components Setup](https://docs.microsoft.com/power-platform/guidance/coe/setup-core-components)

---

## Solution Update/Upgrade Issues

**Issue Type**: Upgrade Issue  
**Applies To**: All solutions

### Response Template

Thank you for reporting this upgrade issue.

**Before Upgrading**:
1. **Remove unmanaged layers**: Unmanaged customizations will block updates. Remove all unmanaged layers from the solution before upgrading.
2. **Review release notes**: Check the [release notes](https://github.com/microsoft/coe-starter-kit/releases) for breaking changes
3. **Backup**: Export your current solution and data before upgrading
4. **Test**: Test the upgrade in a development environment first

**Upgrade Process**:
1. Follow the [upgrade documentation](https://docs.microsoft.com/power-platform/guidance/coe/after-setup#installing-upgrades)
2. Import the new version as an **upgrade** (not new)
3. Update environment variables if needed
4. Turn flows back on after upgrade completes

**If Upgrade Fails**:
- Check for unmanaged customizations blocking the upgrade
- Review error messages for specific component conflicts
- Consider exporting customizations, removing them, upgrading, then reapplying

For more details, see: [Modifying and Upgrading](https://docs.microsoft.com/power-platform/guidance/coe/modify-components)

---

## Additional Resources

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Guide](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [Troubleshooting Guide](../docs/TROUBLESHOOTING.md)
- [Release Notes](https://github.com/microsoft/coe-starter-kit/releases)
- [Community Discussions](https://github.com/microsoft/coe-starter-kit/discussions)
