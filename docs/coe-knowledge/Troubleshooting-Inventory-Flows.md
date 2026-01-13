# Troubleshooting CoE Inventory Flows

This document provides guidance for troubleshooting issues with CoE Starter Kit inventory flows, particularly when flows and apps tables are not populating with new records.

## Overview

The CoE Starter Kit uses a hierarchical inventory system where the **Admin - Sync Template v4 (Driver)** flow orchestrates data collection across your Power Platform tenant. Understanding this architecture is crucial for troubleshooting inventory issues.

## Inventory Flow Architecture

### Driver Flow
The **Admin - Sync Template v4 (Driver)** flow is the main orchestrator that:
1. Retrieves all environments in your tenant
2. Populates the Environments table in Dataverse
3. Triggers child flows to collect detailed inventory for each environment

### Child Flows
Once environments are synced, the Driver flow triggers these child flows:
- **Admin - Sync Template v4 (Apps)** - Collects Canvas Apps
- **Admin - Sync Template v4 (Model Driven Apps)** - Collects Model-Driven Apps
- **Admin - Sync Template v4 (Flows)** - Collects Cloud Flows
- **Admin - Sync Template v4 (Desktop flows)** - Collects Desktop Flows
- **Admin - Sync Template v4 (Custom Connectors)** - Collects Custom Connectors
- **Admin - Sync Template v4 (Portals)** - Collects Power Pages sites
- **Admin - Sync Template v4 (PVA)** - Collects Copilot Studio bots
- And other resource-specific flows

### Key Dependencies
⚠️ **Critical**: All child flows depend on the Environments table being populated first. If environments are not syncing, no other inventory data will populate.

## Common Issues After Upgrades

After upgrading the CoE Starter Kit (especially from versions before 11/11), you may encounter:

1. **Flows are running but not populating data**
   - Check if the Driver flow is completing successfully
   - Verify that environments are being synced to the Environments table

2. **Long-running flows**
   - Inventory flows can take hours to complete for large tenants
   - This is expected behavior, not a problem

3. **Dependencies not triggered**
   - If the Driver flow fails, child flows won't be triggered
   - Child flows may show as "Waiting" or not running at all

## Troubleshooting Steps

### Step 1: Check Driver Flow Status

1. Navigate to **Power Automate** > **Cloud flows**
2. Search for "Admin - Sync Template v4 (Driver)"
3. Review the **Run history**
   - Look for successful runs (green checkmark)
   - Check completion time (can take 1-4 hours for large tenants)
   - Review any error messages

**Expected behavior**: The Driver flow should complete successfully before child flows populate data.

### Step 2: Verify Environments Table

1. Open the **Power Platform Admin View** app or **CoE Admin Command Center**
2. Navigate to **Environments** table
3. Check if environments are listed with recent **Modified On** dates

**Expected data**: You should see all environments in your tenant with timestamps reflecting the last sync.

### Step 3: Check Child Flow Triggers

1. In Power Automate, search for "Admin - Sync Template v4"
2. For each child flow (Apps, Flows, etc.):
   - Check if the flow is **turned ON**
   - Review the **Run history** for recent activity
   - Look for runs that started after the Driver flow completed

**Common issue**: Child flows may not trigger if:
- The Driver flow didn't complete successfully
- Environments table doesn't have the required data
- Connection references are not configured correctly

### Step 4: Review Flow Dependencies

The flows work in this sequence:
```
Driver Flow (Every 24 hours)
    ↓ (Populates Environments table)
    ├─→ Apps Flow (Triggered per environment)
    ├─→ Flows Flow (Triggered per environment)
    ├─→ Desktop Flows Flow (Triggered per environment)
    ├─→ Model Driven Apps Flow (Triggered per environment)
    ├─→ Custom Connectors Flow (Triggered per environment)
    └─→ Other resource flows (Triggered per environment)
```

### Step 5: Check Connection References

1. Navigate to **Solutions** > **Center of Excellence - Core Components**
2. Select **Connection References**
3. Verify that all connection references are configured:
   - Power Platform for Admins connector
   - Dataverse connector
   - Office 365 Users connector
   - Office 365 Groups connector (if using)

**Issue**: Missing or invalid connections will cause flows to fail silently.

### Step 6: Monitor Flow Execution

To track flow execution in real-time:

1. **Set up Flow Checker** (if available in your tenant)
2. **Review Run History** for each flow:
   - Driver flow should run once per day
   - Child flows should run multiple times (once per environment)
3. **Check for timeouts**: Flows have a 30-day execution limit

### Step 7: Force a Full Inventory Run

If flows haven't populated data after an upgrade:

1. **Manually trigger the Driver flow**:
   - Go to the Driver flow
   - Click **Run** > **Run flow**
   - Wait for completion (can take 1-4 hours)

2. **Monitor child flow triggers**:
   - After Driver completes, child flows should trigger automatically
   - Check run history within 15-30 minutes

3. **Check for environment variables**:
   - Ensure `PowerAutomate Environment Variable` is set correctly
   - Verify `Individual Admin` setting if using individual admin mode

## Common Root Causes

### 1. Driver Flow Not Completing
**Symptoms**: Apps and Flows tables remain empty
**Cause**: Driver flow fails or times out before triggering child flows
**Solution**: 
- Review Driver flow run history for errors
- Check API limits and throttling
- Verify admin connector permissions

### 2. Licensing Issues
**Symptoms**: Pagination errors, partial data collection
**Cause**: Insufficient Power Platform licenses
**Solution**: Ensure the account running flows has appropriate admin licenses

### 3. API Throttling
**Symptoms**: Flows fail intermittently with 429 errors
**Cause**: Too many API calls in short period
**Solution**: 
- Flows are designed with retry logic
- Wait for automatic retry
- Consider running during off-peak hours

### 4. Connection Reference Issues
**Symptoms**: Flows show as successful but don't populate data
**Cause**: Invalid or expired connections
**Solution**: Recreate connection references with admin account

### 5. Environment Filters
**Symptoms**: Only some environments populate data
**Cause**: Environment filters configured in flows
**Solution**: Review and update filter conditions in Driver flow

## Monitoring Tips

### Daily Checks
- Review Driver flow run history
- Check Environments table for recent updates
- Spot-check Apps and Flows tables for new records

### Weekly Audits
- Compare record counts with actual tenant resources
- Review flow failure notifications
- Check for missing environments or applications

### After Upgrades
- Allow 48 hours for full inventory to complete
- Manually trigger Driver flow if needed
- Verify all child flows are turned on

## Performance Expectations

| Tenant Size | Expected Duration |
|-------------|------------------|
| Small (<100 apps) | 30-60 minutes |
| Medium (100-500 apps) | 1-2 hours |
| Large (500-2000 apps) | 2-4 hours |
| Extra Large (>2000 apps) | 4-8 hours |

**Note**: These are approximate times for the complete inventory cycle.

## Getting Help

If issues persist after following these steps:

1. **Document the issue**:
   - Driver flow run history and status
   - Child flow run history (Apps, Flows)
   - Any error messages or failure details
   - Tenant size (approximate number of apps/flows)

2. **Check existing issues**: Search [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)

3. **Create a new issue**: Include:
   - Solution version (from environment variables)
   - Upgrade date (when you upgraded to current version)
   - Inventory method (v4 Sync flows)
   - Detailed error messages and screenshots
   - Run history from Driver and child flows

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Inventory Flows Overview](https://learn.microsoft.com/power-platform/guidance/coe/core-components#inventory-flows)
- [Troubleshooting Guide](https://learn.microsoft.com/power-platform/guidance/coe/troubleshoot)

## Related Topics

- [Understanding CoE Inventory](https://learn.microsoft.com/power-platform/guidance/coe/core-components#what-data-is-collected)
- [Cleanup and Maintenance Flows](https://learn.microsoft.com/power-platform/guidance/coe/core-components#cleanup-flows)
- [Environment Management](https://learn.microsoft.com/power-platform/guidance/coe/core-components#environment-management)
