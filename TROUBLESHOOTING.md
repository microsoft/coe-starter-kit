# CoE Starter Kit Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the Center of Excellence (CoE) Starter Kit.

## Table of Contents
- [Power BI Dashboard Not Refreshing](#power-bi-dashboard-not-refreshing)
- [Connector Issues](#connector-issues)
- [Flow Failures](#flow-failures)
- [Data Collection Issues](#data-collection-issues)
- [General Troubleshooting Steps](#general-troubleshooting-steps)

---

## Power BI Dashboard Not Refreshing

### Symptoms
- Power BI Dashboard shows outdated data (e.g., "Data updated 7/15/25")
- Dashboard data hasn't changed after multiple manual refreshes
- Charts and visuals show old information

### Common Causes and Solutions

#### 1. Check Power BI Dataset Refresh Status
**Problem**: The underlying Power BI dataset may have failed to refresh.

**Solution**:
1. Open Power BI Service (app.powerbi.com)
2. Navigate to the workspace containing your CoE Dashboard
3. Find the dataset associated with your dashboard
4. Check the "Refresh history" to see if refreshes are failing
5. Review any error messages in the refresh history

#### 2. Verify Dataverse Connection
**Problem**: The connection from Power BI to Dataverse may be broken or expired.

**Solution**:
1. In Power BI Service, go to Settings > Datasets
2. Select your CoE Dashboard dataset
3. Navigate to "Data source credentials"
4. Ensure all connections are authenticated and not showing errors
5. Re-authenticate if necessary using an account with:
   - Power Platform Administrator or Global Administrator role
   - Access to the environment where CoE is installed

#### 3. Check if CoE Flows are Running
**Problem**: If CoE flows aren't running, no new data is being collected in Dataverse, so Power BI has nothing new to show.

**Solution**:
See the [Flow Failures](#flow-failures) section below to diagnose and fix flow issues.

#### 4. Verify Scheduled Refresh is Configured
**Problem**: Power BI dataset may not have scheduled refresh enabled.

**Solution**:
1. In Power BI Service, go to Settings > Datasets
2. Select your CoE Dashboard dataset
3. Navigate to "Scheduled refresh"
4. Ensure refresh is enabled and configured (recommended: daily)
5. Click "Refresh now" to trigger an immediate refresh

#### 5. Check Power BI Capacity Limits
**Problem**: Your Power BI capacity may have reached its limits, preventing refreshes.

**Solution**:
1. Check your Power BI capacity metrics
2. Verify you have available refresh slots
3. If using Power BI Pro, note the 8 refresh limit per day
4. Consider upgrading to Power BI Premium if needed

---

## Connector Issues

### Power Platform for Admins V2 Connector Won't Reconnect

#### Symptoms
- Unable to reconnect the "Power Platform for Admins V2" connector
- Connection shows as "Failed" or "Needs authentication"
- Flows using this connector are failing

#### Common Causes and Solutions

#### 1. Service Principal vs User Authentication
**Problem**: The connector may require service principal authentication which isn't properly configured.

**Solution**:
1. Check if you're using a service principal for authentication
2. If yes, verify the service principal has:
   - Power Platform Administrator role
   - Appropriate API permissions in Azure AD
   - Valid, non-expired credentials
3. If using user authentication, ensure the user has:
   - Power Platform Administrator or Global Administrator role
   - Not using MFA that could interrupt authentication

#### 2. Re-create the Connection
**Problem**: The connection may be corrupted or in a bad state.

**Solution**:
1. Navigate to Power Platform Admin Center > Data > Connections
2. Find the "Power Platform for Admins V2" connection
3. Delete the existing connection
4. Create a new connection:
   - Go to the environment where CoE is installed
   - Navigate to Solutions > Center of Excellence - Core Components
   - Find a flow that uses the connector (e.g., "Admin | Sync Template v4")
   - Edit the flow
   - Remove and re-add the connector
   - Save and test the flow

#### 3. Check Connector Permissions
**Problem**: Your account may not have sufficient permissions to use the connector.

**Solution**:
1. Verify you have one of these roles:
   - Power Platform Administrator
   - Dynamics 365 Administrator
   - Global Administrator
2. Check that the connector isn't blocked by DLP policies:
   - Go to Power Platform Admin Center > Policies > Data policies
   - Verify "Power Platform for Admins V2" is in the "Business" data group
   - If blocked, work with your admin to allow the connector

#### 4. Connector Version Issues
**Problem**: You may be using an outdated version of the connector.

**Solution**:
1. Check if there's a newer version of the "Power Platform for Admins V2" connector
2. Update flows to use the latest connector version
3. Remove old connections and create new ones with the updated connector

#### 5. Tenant-Level Restrictions
**Problem**: Your tenant may have restrictions preventing the connector from working.

**Solution**:
1. Check with your Global Administrator if there are any tenant-level restrictions
2. Verify the connector is allowed in your tenant
3. Check if conditional access policies are blocking the connection
4. Ensure the service endpoints for Power Platform are accessible

---

## Flow Failures

### Symptoms
- CoE flows show "Failed" status
- Flows stopped running (e.g., since July/August)
- No new data appearing in Dataverse tables

### Common Causes and Solutions

#### 1. Check Flow Run History
**Problem**: Flows may be failing with specific errors.

**Solution**:
1. Navigate to Power Automate (make.powerautomate.com)
2. Go to the environment where CoE is installed
3. Select Solutions > Center of Excellence - Core Components
4. Open each key flow (Admin | Sync Template v4, etc.)
5. Check the "Run history" for errors
6. Common errors and their solutions:
   - **Authentication errors**: Reconnect the connector (see [Connector Issues](#connector-issues))
   - **Timeout errors**: Flow may need optimization or increased timeout settings
   - **Permission errors**: Ensure the flow owner has admin rights
   - **API limit errors**: Implement throttling or reduce API calls

#### 2. Verify Flow Ownership
**Problem**: The flow owner may have left the organization or lost permissions.

**Solution**:
1. Check who owns the flows
2. If the owner is inactive or lacks permissions, reassign ownership:
   - As an admin, edit the flow
   - Change the owner to an active admin account
   - Save and turn the flow back on

#### 3. Check Flow Triggers
**Problem**: Scheduled triggers may be disabled or misconfigured.

**Solution**:
1. Open each CoE flow
2. Check the trigger configuration:
   - For scheduled flows, verify the recurrence is set correctly
   - Ensure the flow is "On" (not turned off)
   - Check if the trigger is within API limits

#### 4. Verify Environment Variables
**Problem**: Environment variables may be misconfigured after an upgrade.

**Solution**:
1. Navigate to Solutions > Center of Excellence - Core Components
2. Check "Environment variables"
3. Verify all required variables are set with correct values:
   - Environment URLs
   - Admin email addresses
   - Feature flags
   - API endpoints
4. Update any missing or incorrect values
5. Restart the affected flows

#### 5. Review DLP Policies
**Problem**: Data Loss Prevention policies may be blocking connectors used by flows.

**Solution**:
1. Go to Power Platform Admin Center > Policies > Data policies
2. Check policies applied to your CoE environment
3. Ensure all connectors used by CoE flows are in the same data group (usually "Business"):
   - Dataverse
   - Power Platform for Admins V2
   - Office 365 Users
   - Office 365 Outlook
   - HTTP
4. If connectors are blocked, work with your admin to adjust policies

---

## Data Collection Issues

### Symptoms
- Dataverse tables are empty or have old data
- No new apps, flows, or connectors appearing in CoE tables
- Dashboard shows incomplete information

### Common Causes and Solutions

#### 1. Check Inventory Flows
**Problem**: The inventory collection flows may not be running.

**Solution**:
1. Verify these key flows are running successfully:
   - Admin | Sync Template v4 (Apps)
   - Admin | Sync Template v4 (Flows)
   - Admin | Sync Template v4 (Desktop Flows)
   - Admin | Sync Template v4 (Connectors)
   - Admin | Sync Template v4 (Model-Driven Apps)
   - Admin | Sync Template v4 (Portals)
2. Check their run history for errors
3. Manually trigger each flow to test
4. Verify the flows are scheduled correctly (typically daily)

#### 2. Verify Admin API Access
**Problem**: The account running flows may not have access to Power Platform Admin APIs.

**Solution**:
1. Ensure the account has one of these roles:
   - Power Platform Administrator
   - Dynamics 365 Administrator
   - Global Administrator
2. Test API access:
   - Open Power Platform Admin Center
   - Navigate to Environments
   - Verify you can see all environments in your tenant
3. If you can't see all environments, you lack the required permissions

#### 3. Check Data Export Method
**Problem**: If using Data Export, it may not be configured correctly.

**Solution**:
1. Verify Data Export is properly configured in your CoE setup
2. Check the Data Export sync job status
3. Ensure the data export schedule is running
4. Review the data export logs for errors

#### 4. Review Dataverse Table Permissions
**Problem**: Flows may not have permissions to write to Dataverse tables.

**Solution**:
1. Verify the flow owner has the correct security roles:
   - Power Platform Administrator
   - System Administrator (in Dataverse)
2. Check that CoE tables have the correct permissions configured
3. Ensure the application user (if used) has appropriate permissions

---

## General Troubleshooting Steps

### After Upgrading CoE Starter Kit

If you've recently upgraded to a new version (like the November release), follow these steps:

1. **Turn off all flows** before upgrading
2. **Update environment variables** with correct values for your environment
3. **Reconnect all connections**:
   - Delete old connections that show errors
   - Create new connections with admin accounts
   - Update flows to use the new connections
4. **Test key flows** one by one:
   - Admin | Sync Template v4 (start with Apps)
   - Check run history for success
   - Verify data appears in Dataverse
5. **Turn on remaining flows** after confirming core flows work
6. **Trigger a Power BI refresh** to see updated data

### Diagnostic Checklist

When troubleshooting any issue, go through this checklist:

- [ ] I have Power Platform Administrator or Global Administrator role
- [ ] All CoE flows are turned "On"
- [ ] I can see all environments in Power Platform Admin Center
- [ ] All connections show "Connected" status (not "Failed")
- [ ] I've checked flow run history and see successful runs
- [ ] Environment variables are configured correctly
- [ ] No DLP policies are blocking required connectors
- [ ] I've triggered a manual Power BI dataset refresh
- [ ] Power BI dataset refresh history shows successful refreshes
- [ ] Dataverse tables contain recent data (check modified date)

### Getting Help

If you've tried these troubleshooting steps and still have issues:

1. **Check the documentation**: https://docs.microsoft.com/power-platform/guidance/coe/starter-kit
2. **Review existing issues**: https://github.com/microsoft/coe-starter-kit/issues
3. **File a new issue**: Use the appropriate template at https://github.com/microsoft/coe-starter-kit/issues/new/choose
   - For bugs: Use the Bug Report template
   - For questions: Use the Question template
4. **Join Office Hours**: Check [Office Hours schedule](https://github.com/microsoft/coe-starter-kit/wiki/Office-Hours)

### Useful Links

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Setup Guide](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [CoE Upgrade Guide](https://docs.microsoft.com/power-platform/guidance/coe/after-setup#installing-upgrades)
- [Power BI Dashboard Setup](https://docs.microsoft.com/power-platform/guidance/coe/setup-powerbi)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
- [Power BI Service](https://app.powerbi.com)

---

## Frequently Asked Questions (FAQ)

### Q: My dashboard shows "(Blank)" for "# Created in the last month". Why?

**A**: This could be due to:
1. No new resources were created in the last month
2. The data collection flows haven't run recently - check flow run history
3. The Power BI dataset hasn't refreshed - trigger a manual refresh
4. A filter or date calculation issue in the Power BI report - verify the date fields in your data

### Q: Why did my flows stop running in July/August?

**A**: Common reasons include:
1. **License expiration**: Check if your Power Automate licenses expired
2. **Owner changes**: The flow owner may have left or changed roles
3. **Connector updates**: Microsoft may have updated connectors, requiring reconnection
4. **DLP policy changes**: Your admin may have implemented new policies
5. **Service plan changes**: Your service plan may have changed

### Q: How often should the Power BI dashboard update?

**A**: This depends on your configuration:
- **CoE Flows**: Most sync flows run daily (configurable in the flow trigger)
- **Power BI Dataset Refresh**: Configure in Power BI Service (recommended: daily)
- **End-to-end update time**: Typically 24-48 hours from resource creation to appearing in dashboard

### Q: Can I use a service principal instead of a user account?

**A**: Yes, but:
1. The service principal must have Power Platform Administrator role
2. Not all flows support service principal authentication
3. Some connectors require user context and won't work with service principals
4. You'll need to configure the service principal in Azure AD and Power Platform

### Q: What permissions do I need to run the CoE Starter Kit?

**A**: Minimum requirements:
- **Power Platform Administrator** or **Global Administrator** role
- **Power BI Pro** or **Premium** license (for dashboards)
- **Power Automate** license (Premium Connector license for some features)
- **Dataverse** storage capacity
- **Ability to create connections** in the target environment

### Q: How do I know if my data collection is working?

**A**: Check these indicators:
1. **Flow run history**: All sync flows show successful runs
2. **Dataverse tables**: Tables have recent data (check "Modified On" column)
3. **Record counts**: Table record counts increase over time
4. **Power BI dashboard**: Data is current and matches what you see in admin center

### Q: My upgrade didn't fix my issues. What should I do?

**A**: After upgrading:
1. Don't expect the upgrade to automatically fix configuration issues
2. Follow the post-upgrade steps in the [documentation](https://docs.microsoft.com/power-platform/guidance/coe/after-setup#installing-upgrades)
3. Reconnect all connections (this is critical)
4. Update environment variables
5. Test flows individually
6. If issues persist, review the [General Troubleshooting Steps](#general-troubleshooting-steps)

---

*Last Updated: November 2024*
