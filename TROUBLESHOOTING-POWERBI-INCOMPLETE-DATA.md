# Troubleshooting: Power BI Reports Showing Incomplete Data

## Overview
This guide helps troubleshoot scenarios where Power BI reports in the CoE Starter Kit show incomplete or missing data across different report types.

## Common Symptoms

- Environment Capacity report shows fewer environments than expected
- Application or Flow reports missing resources
- User/Maker data incomplete
- Capacity metrics showing zeros or blanks
- Report visuals displaying "No data" or partial results

## General Root Causes

### 1. Licensing and Pagination
**Most Common Issue**: Service account lacks proper licensing, causing pagination limits on API calls.

**Symptoms**:
- Consistent cutoff at ~50 records
- Data appears for some environments/apps but not others
- New resources not appearing in reports

**Resolution**: See [Licensing Requirements](#licensing-requirements) below.

### 2. Sync Flow Status
**Issue**: Inventory sync flows not running or completing successfully.

**Symptoms**:
- Outdated data in reports
- Missing newly created resources
- Flow run history shows failures

**Resolution**: See [Sync Flow Health Check](#sync-flow-health-check) below.

### 3. Power BI Refresh Schedule
**Issue**: Power BI datasets not refreshing after data updates in Dataverse.

**Symptoms**:
- Data in Dataverse is correct, but reports show old data
- Manual refresh works, but scheduled refresh fails

**Resolution**: See [Power BI Refresh Configuration](#power-bi-refresh-configuration) below.

### 4. Dataverse Data Issues
**Issue**: Data not being written to Dataverse tables correctly.

**Symptoms**:
- Empty tables or tables with fewer records than expected
- Null values in key fields
- Inconsistent record counts between related tables

**Resolution**: See [Dataverse Data Validation](#dataverse-data-validation) below.

### 5. Environment Variable Configuration
**Issue**: Environment variables not configured correctly.

**Symptoms**:
- Flows running but not collecting expected data
- Specific environments or resources excluded

**Resolution**: See [Environment Variable Verification](#environment-variable-verification) below.

---

## Troubleshooting Procedures

### Licensing Requirements

**Required Licenses** (one of the following for the service account):
- **Power Automate Process license** (recommended for production)
- **Power Apps Per User license** (full, not trial)
- **Power Automate Per User with RPA**

**License Test**:
```
1. Check assigned licenses in Microsoft 365 Admin Center
2. Verify license is active (not expired or trial)
3. Confirm license includes "Premium" connectors access
```

**How to Verify Pagination Limits**:
1. Open Power Automate flow run history
2. Find the "Get Environments" or "List Apps" action
3. Check the output count
4. Compare to total tenant resources

**If pagination limit detected**:
- Upgrade service account license immediately
- Re-run all sync flows after license assignment
- Wait 24 hours for full license propagation

### Sync Flow Health Check

**Key Flows to Monitor**:
1. **Admin | Sync Template v4 (Driver)** - Orchestrates all inventory sync
2. **Admin | Sync Template v4 (Apps)** - Syncs canvas and model-driven apps
3. **Admin | Sync Template v4 (Flows)** - Syncs cloud flows
4. **CLEANUP HELPER - Environment Capacity** - Syncs capacity data

**Health Check Steps**:
```
1. Navigate to make.powerautomate.com
2. Select CoE environment
3. Go to Solutions → Center of Excellence - Core Components
4. For each key flow:
   a. Verify flow is "On"
   b. Check run history (last 7 days)
   c. Review error details for failures
   d. Verify last successful run date
```

**Common Flow Errors**:
| Error | Cause | Resolution |
|-------|-------|------------|
| "Forbidden" or "401" | Permission issue | Verify service account has admin role |
| "Timeout" | Large tenant, slow API | Split sync into batches or run off-peak |
| "Rate limit exceeded" | Too many API calls | Add delays between calls, schedule syncs |
| "Connection not found" | Missing connection reference | Recreate connections in solution |

**Manual Sync Trigger**:
1. Open "Admin | Sync Template v4 (Driver)"
2. Click "Run" → "Run flow"
3. Monitor execution (can take 30-90 minutes for large tenants)
4. Check child flows also complete successfully

### Power BI Refresh Configuration

**Verify Refresh Schedule**:
```
1. Open Power BI workspace
2. Locate CoE Starter Kit datasets
3. Settings → Scheduled refresh
4. Verify:
   - Refresh is enabled
   - Schedule runs AFTER sync flows complete
   - Credentials are valid
   - No recent refresh failures
```

**Recommended Refresh Schedule**:
- Sync flows: Daily at 2:00 AM
- Power BI refresh: Daily at 6:00 AM (4 hours after sync)

**Manual Refresh Test**:
1. Navigate to Power BI dataset
2. Click "Refresh now"
3. Monitor for errors
4. Verify data updates in reports

**Credential Issues**:
- Re-enter Dataverse credentials if refresh fails
- Use service account credentials (not personal)
- Ensure account has "Read" permission on all CoE tables

### Dataverse Data Validation

**Key Tables to Check**:
| Table | Expected Data |
|-------|---------------|
| admin_environment | All environments in tenant |
| admin_app | All canvas apps |
| admin_flow | All cloud flows |
| admin_maker | All app/flow creators |
| admin_connector | All connectors |

**Validation Steps**:
```
1. Go to make.powerapps.com
2. Select CoE environment
3. Navigate to Tables
4. For each table above:
   a. Open table
   b. Select "Data" tab
   c. Count total records
   d. Compare to expected count
   e. Check "Modified On" dates
   f. Verify key fields are populated
```

**SQL Query to Validate** (use Advanced Find or Power Apps):
```
Count of Environments: SELECT COUNT(*) FROM admin_environment
Count of Apps: SELECT COUNT(*) FROM admin_app
Count of Flows: SELECT COUNT(*) FROM admin_flow
```

**If Data is Missing**:
- Check if "Excuse from Inventory" is set to "Yes" for environments
- Verify sync flows completed for specific object types
- Review flow run history for specific environment/app failures

### Environment Variable Verification

**Critical Environment Variables**:

| Variable | Purpose | Expected Value |
|----------|---------|----------------|
| `admin_isFullTenantInventory` | Controls inventory scope | `true` (for full tenant) |
| `admin_PowerAutomateEnvironmentVariable` | Power Automate URL | `https://flow.microsoft.com/manage/environments/` (commercial) |
| `admin_SyncFlowTimeout` | Sync timeout duration | 30-60 minutes |

**How to Verify**:
```
1. Go to Solutions → Center of Excellence - Core Components
2. Navigate to Environment Variables
3. For each variable above:
   a. Verify "Current Value" is set
   b. Confirm value matches expected
   c. Update if incorrect
4. Re-run sync flows after changes
```

**Update Environment Variable**:
1. Open the environment variable
2. Click "Edit" or "+ New value"
3. Set the "Current value"
4. Save and publish
5. Restart affected flows

---

## Specific Report Issues

### Environment Capacity Report
**Issue**: Shows only few environments instead of all.

**Specific Causes**:
- Capacity API expansion failures
- Missing "CLEANUP HELPER - Environment Capacity" flow execution

**Solution**: See [TROUBLESHOOTING-ENVIRONMENT-CAPACITY-POWERBI.md](./TROUBLESHOOTING-ENVIRONMENT-CAPACITY-POWERBI.md)

### App/Flow Reports Missing Data
**Issue**: Some apps or flows not appearing in reports.

**Specific Causes**:
- Child sync flows for specific resource types not running
- Environments excluded from inventory
- Deleted resources still cached

**Solution**:
1. Run "CLEANUP-AdminSyncTemplatev4-CheckDeleted" flow
2. Verify "Admin | Sync Template v4 (Apps)" and "Flows" ran successfully
3. Check environment exclusion settings

### Maker/User Data Incomplete
**Issue**: User names showing as system accounts or blanks.

**Specific Causes**:
- Office 365 Users connection not configured
- Insufficient permissions to read user profiles

**Solution**:
1. Verify Office 365 Users connector connection
2. Grant service account User.Read.All API permission
3. Re-run sync flows

---

## Best Practices

### Monitoring
- Set up flow run alerts for sync flow failures
- Create a Power BI report to track sync flow health
- Review error logs weekly

### Scheduling
- Run inventory sync during off-peak hours
- Stagger sync flows for large tenants (70+ environments)
- Ensure Power BI refresh runs after sync completes

### Maintenance
- Keep CoE Starter Kit updated to latest version
- Review and apply monthly updates from Microsoft
- Document customizations for troubleshooting

### Performance
- For 50+ environments: Consider batching sync operations
- Use "Excuse from Inventory" for dev/test environments (carefully)
- Monitor API throttling and adjust accordingly

---

## Escalation

If issues persist after following these procedures:

1. **Gather Diagnostics**:
   - CoE Starter Kit version
   - Service account license details
   - Flow run history screenshots (with errors)
   - Dataverse table record counts
   - Power BI refresh error messages

2. **Check Known Issues**:
   - [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
   - [Release Notes](https://github.com/microsoft/coe-starter-kit/releases)
   - [Microsoft Learn Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)

3. **Open GitHub Issue**:
   - Use the "Question" template
   - Provide all diagnostic information
   - Tag with appropriate labels (e.g., "Core", "Power BI")

4. **Community Support**:
   - CoE Starter Kit community calls
   - Power Platform community forums

---

## Quick Reference Checklist

When Power BI shows incomplete data:

- [ ] Verify service account has proper license (not trial)
- [ ] Check "Admin | Sync Template v4 (Driver)" flow ran successfully
- [ ] Confirm child sync flows completed without errors
- [ ] Validate Dataverse tables have expected record counts
- [ ] Ensure Power BI dataset refreshed after sync
- [ ] Verify `admin_isFullTenantInventory` is set to `true`
- [ ] Check no environments are incorrectly excluded from inventory
- [ ] Review environment variable configuration
- [ ] Test manual sync and refresh

---

## Additional Resources

- [CoE Starter Kit Official Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Setup Inventory Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Troubleshooting Inventory](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#troubleshooting)
- [Power BI Reports Setup](https://learn.microsoft.com/en-us/power-platform/guidance/coe/power-bi)
- [Limitations and Known Issues](https://learn.microsoft.com/en-us/power-platform/guidance/coe/limitations)
