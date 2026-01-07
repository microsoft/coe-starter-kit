# CoE Starter Kit Post-Installation Checklist

Use this checklist after importing the CoE Starter Kit Core Components solution to ensure proper setup and avoid common issues.

## Pre-Installation Prerequisites

Before importing the solution:

- [ ] **Environment created** with Dataverse database
- [ ] **English language pack** enabled in the environment
- [ ] **Sufficient storage** available (recommend 10+ GB for large tenants)
- [ ] **Service account created** with proper licenses
- [ ] **DLP policies reviewed** to ensure required connectors are allowed

## Immediate Post-Installation Steps

Complete these steps **immediately** after importing the Core Components solution:

### 1. Configure Environment Variables

- [ ] Navigate to: `Solutions → Center of Excellence – Core Components → Environment variables`
- [ ] Set **Admin eMail** to receive notifications
- [ ] Set **TenantID** to your Azure AD tenant ID (GUID format)
- [ ] Set **Power Automate Environment Variable** to CoE environment ID
- [ ] Review and set any other required variables based on your needs
- [ ] Save all changes

### 2. Set Up Connection References

- [ ] Navigate to: `Solutions → Center of Excellence – Core Components → Connection References`
- [ ] For each connection reference:
  - [ ] Click on the connection reference
  - [ ] Create or select an existing connection
  - [ ] Authenticate with the service account
  - [ ] Verify status shows "Connected"
- [ ] Required connections:
  - [ ] Power Platform for Admins
  - [ ] Dataverse (multiple references)
  - [ ] Office 365 Users
  - [ ] Office 365 Outlook (for notifications)

### 3. Assign Security Roles

- [ ] Navigate to: Power Platform Admin Center → Environments → [CoE Environment] → Users
- [ ] Ensure service account has:
  - [ ] **System Administrator** role in CoE environment
  - [ ] **Environment Admin** role on all environments to inventory
- [ ] Consider assigning **Global Admin** or **Power Platform Admin** for full tenant access

### 4. Enable Required Flows

- [ ] Navigate to: `Solutions → Center of Excellence – Core Components → Cloud flows`
- [ ] Turn **ON** these critical flows:

  **Setup Flow (Run First):**
  - [ ] `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
  
  **Daily Inventory Flows:**
  - [ ] `Admin | Sync Template v3` (main orchestrator)
  - [ ] `Admin | Sync Apps v2`
  - [ ] `Admin | Sync Flows v3`
  
  **Recommended Additional Flows:**
  - [ ] `Admin | Add Environment Variables to Environment Variable Values`
  - [ ] `Admin | Add Shared Connections to Connection Reference`
  - [ ] `Admin | Sync Audit Logs` (if Audit Log solution is installed)

### 5. Run Initial Inventory

- [ ] Open `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
- [ ] Click **Run** button
- [ ] Wait for flow to complete (10-30 minutes typically)
- [ ] Check flow run history for "Succeeded" status
- [ ] If failed, review error messages and resolve issues

### 6. Verify Inventory Collection Started

- [ ] Navigate to: `Admin | Sync Template v3` flow
- [ ] Check 28-day run history
- [ ] Confirm at least one successful run after Setup Wizard
- [ ] Note: May see multiple runs as it processes environments in batches

## Wait Period

**⏳ Allow time for inventory collection to complete:**

- **Small tenant** (< 50 environments, < 100 apps/flows): 30-60 minutes
- **Medium tenant** (50-200 environments, 100-1000 apps/flows): 2-4 hours
- **Large tenant** (> 200 environments, > 1000 apps/flows): 4-24 hours

**Do not proceed to verification until inventory has had adequate time to run.**

## Verification Steps

After waiting for inventory to complete:

### 7. Verify Data in Dataverse

- [ ] Navigate to: https://make.powerapps.com
- [ ] Select your CoE environment
- [ ] Click **Tables** (under Dataverse)
- [ ] Verify these tables contain records:
  - [ ] **Environment** - All your Power Platform environments
  - [ ] **Power Apps App** - Canvas and model-driven apps
  - [ ] **Flow** - Cloud flows from your environments
  - [ ] **Power Apps Connector** - Connectors used in apps and flows
  - [ ] **Maker** - Users who created apps and flows

### 8. Configure Power BI

If using Power BI dashboards:

- [ ] Download Power BI template files from CoE Starter Kit release
- [ ] Open in Power BI Desktop
- [ ] Update data source connection to your CoE environment:
  - [ ] Server: `https://[your-org].crm.dynamics.com`
  - [ ] Database: leave blank or use org name
- [ ] Authenticate with OAuth2
- [ ] Publish to Power BI Service workspace
- [ ] Configure scheduled refresh in Power BI Service
- [ ] Verify reports display data correctly

### 9. Set Up Scheduled Runs

Verify flows are scheduled to run automatically:

- [ ] `Admin | Sync Template v3` - Should run daily
- [ ] Check trigger configuration (schedule or recurrence)
- [ ] Adjust schedule if needed for your timezone/preferences
- [ ] Ensure schedule is **enabled** (not just flow turned on)

### 10. Configure Notifications (Optional)

- [ ] Review notification flows in the solution
- [ ] Enable notification flows if desired
- [ ] Configure email recipients
- [ ] Test notifications are working

## Ongoing Maintenance Checklist

After initial setup, perform these checks weekly or monthly:

### Weekly Health Check

- [ ] Review flow run history for failures
- [ ] Check that inventory data is being updated (Modified On dates)
- [ ] Verify Power BI dashboards show recent data
- [ ] Address any flow errors or suspensions

### Monthly Review

- [ ] Review Dataverse storage consumption
- [ ] Check for any new DLP policy conflicts
- [ ] Verify service account licenses are active
- [ ] Review and archive old audit logs (if applicable)
- [ ] Check for CoE Starter Kit updates

### Quarterly Tasks

- [ ] Review and update environment variables as needed
- [ ] Verify all connection references are still authenticated
- [ ] Check official documentation for best practices updates
- [ ] Consider upgrading to latest CoE Starter Kit version
- [ ] Review and optimize Power BI datasets/reports

## Troubleshooting

If you encounter issues during setup:

### Common Issue: Flows Not Running

**Checklist:**
- [ ] Flows are turned ON (not just enabled once)
- [ ] Connection references are authenticated
- [ ] Environment variables have values
- [ ] Service account has proper permissions
- [ ] DLP policies allow required connectors

**Solution:** See [Troubleshooting Guide](./Troubleshooting-Inventory-and-Dashboards.md#issue-2-inventory-collection-not-starting)

### Common Issue: No Data in Dashboards

**Checklist:**
- [ ] Initial inventory has completed (check timeframes above)
- [ ] Dataverse tables have records
- [ ] Power BI is connected to correct environment
- [ ] Power BI dataset has been refreshed
- [ ] Service account has proper license (not trial)

**Solution:** See [Quick Reference](./Quick-Reference-Dashboard-Issues.md)

### Common Issue: Flow Failures

**Common Errors:**
- **Permission errors** → Assign proper roles to service account
- **Pagination errors** → Verify service account has premium license (not trial)
- **Connection errors** → Re-authenticate connection references
- **DLP errors** → Adjust DLP policies or use DLP-compliant setup

**Solution:** See [Troubleshooting Guide](./Troubleshooting-Inventory-and-Dashboards.md#issue-3-inventory-flows-failing)

## License Verification

**Critical:** Verify your service account has proper licensing:

### Test License Adequacy

Create a test flow:
1. New cloud flow in CoE environment
2. Add action: **List rows** (Dataverse connector)
3. Select table: **Environments**
4. Set **Row count**: 5000
5. Run the flow

**Expected Results:**
- ✅ **Success with results**: License is adequate
- ❌ **Pagination error**: License is insufficient - upgrade required
- ❌ **Returns exactly 100 records**: Trial license - upgrade required

### Required Licenses

Service account needs **one** of:
- Power Apps per user license (premium)
- Power Automate per user license
- Office 365 E3/E5
- Dynamics 365 license

**Trial licenses are NOT sufficient.**

## Success Criteria

You've successfully set up the CoE Starter Kit when:

✅ All required flows show "On" status (not suspended)
✅ Flows run successfully on schedule
✅ Dataverse tables contain inventory data
✅ Power BI dashboards display tenant data
✅ No recurring flow failures
✅ Service account has proper licenses
✅ New apps/flows appear in inventory within 24 hours

## Getting Help

If you've completed this checklist and still have issues:

1. **Review our documentation:**
   - [Quick Reference: Dashboard Issues](./Quick-Reference-Dashboard-Issues.md)
   - [Comprehensive Troubleshooting Guide](./Troubleshooting-Inventory-and-Dashboards.md)
   - [Common GitHub Responses](./COE-Kit-Common-GitHub-Responses.md)

2. **Check official documentation:**
   - [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
   - [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

3. **Search existing issues:**
   - [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

4. **Create a new issue:**
   - Use the [bug report template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
   - Include details from this checklist
   - Note which steps you completed
   - Include error messages and screenshots

## Additional Resources

- **Official Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Release Notes**: https://github.com/microsoft/coe-starter-kit/releases
- **GitHub Discussions**: https://github.com/microsoft/coe-starter-kit/discussions
- **Community Forums**: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps

---

*Last Updated: 2026-01-07*
*Print this checklist and check off items as you complete them to ensure nothing is missed.*
