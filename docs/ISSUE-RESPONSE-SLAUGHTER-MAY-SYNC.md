# Issue Response: Power Platform Admin View Not Updating - Slaughter and May Development Environment Missing

**Issue**: After upgrading to CoE Starter Kit v4.50.6 in November 2025, the Power Platform Admin View app is not showing:
- The "Slaughter and May Development" environment
- Apps created after June 2024
- Complete list of apps in various environments

**Status**: DOCUMENTATION PROVIDED - Solution available

---

## Summary

This is a **known behavior** after CoE Starter Kit upgrades, not a bug in the solution itself. The issue stems from:

1. **Missing environment in the list**: The Driver flow needs to run to refresh the environment inventory
2. **Outdated app data**: The sync flows are running in incremental mode (default), which only syncs apps modified within the last 7 days

## Root Cause Analysis

### Understanding the Sync Architecture

The CoE Starter Kit uses a hierarchical sync system:

```
Admin | Sync Template v4 (Driver)  [Master Flow - Lists ALL Environments]
    ↓
    Creates/Updates Environment Records in Dataverse
    ↓
    Automatically triggers child flows when environment records are updated:
        ├── Admin | Sync Template v4 (Apps)  [Syncs Canvas Apps]
        ├── Admin | Sync Template v4 (Cloud Flows)  [Syncs Cloud Flows]
        ├── Admin | Sync Template v4 (Model-Driven Apps)  [Syncs Model-Driven Apps]
        └── Other resource-specific sync flows...
            ↓
            Each child flow may call SYNC HELPER flows for detailed item sync:
                ├── SYNC HELPER - Apps
                ├── SYNC HELPER - Cloud Flows
                └── Other helpers...
```

### Why Your Environment Is Missing

**Issue**: "Slaughter and May Development" environment not visible

**Cause**: After the upgrade, the **Admin | Sync Template v4 (Driver)** flow has not executed successfully to refresh the environment list in Dataverse.

**Why this happens**:
- After solution upgrade, flow connections may need to be updated
- The Driver flow may not have run on its schedule yet
- The flow may have encountered errors during its last run

### Why Apps Are Outdated (Only Showing June 2024)

**Issue**: Only apps created before June 2024 are visible

**Cause**: The sync flows are operating in **incremental inventory mode** (default), which only syncs:
- New apps (not yet in inventory)
- Apps modified within the last 7 days
- Apps manually flagged for sync

**Why this happens**:
- After upgrade, the inventory defaults to incremental mode
- Historical apps (created/modified before the lookback window) are not re-synced
- You need to run a **full inventory** to capture all apps across all time periods

### About "Admin | Sync Template v4 (Environments)" Flow

**Note**: There is no separate flow named "Admin | Sync Template v4 (Environments)". The **Admin | Sync Template v4 (Driver)** flow IS the environment sync flow. It handles:
- Discovering all environments in your tenant
- Creating/updating environment records in Dataverse
- Triggering all child sync flows

## Solution

### Step 1: Trigger the Driver Flow (Fix Missing Environment)

This will refresh your environment list and make "Slaughter and May Development" visible.

**Detailed Instructions**: [Solution 1 in Troubleshooting Guide](troubleshooting/admin-view-missing-data.md#solution-1-trigger-the-driver-flow-to-refresh-environments)

**Quick Steps**:
1. Go to [Power Automate](https://make.powerautomate.com)
2. Select your **CoE environment**
3. Navigate to **My flows** or **Solutions** → **Center of Excellence - Core Components**
4. Find: **Admin | Sync Template v4 (Driver)**
5. Verify the flow is **On** (not suspended)
6. Check and update flow **connections** if needed (look for warning icons)
7. Click **Run** → **Run flow**
8. Wait for completion (5-30 minutes)
9. Verify run history shows **Succeeded**
10. Check Dataverse: Go to Tables → Environment (`admin_environment`)
11. Confirm "Slaughter and May Development" now appears

**Expected Result**: Your missing environment will now be listed.

### Step 2: Run Full Inventory (Fix Outdated App Data)

This will sync all apps across all environments, including those created before June 2024.

**Detailed Instructions**: [Solution 2 in Troubleshooting Guide](troubleshooting/admin-view-missing-data.md#solution-2-run-a-full-inventory-to-capture-all-apps)

**Quick Steps**:
1. Go to [Power Apps](https://make.powerapps.com)
2. Select your **CoE environment**
3. Navigate to **Solutions** → **Center of Excellence - Core Components**
4. Click **Environment Variables**
5. Find: **FullInventory** (or `admin_FullInventory`)
6. Set **Current Value** to: `Yes` (or `true`)
7. Save the change
8. **Option A**: Wait for the scheduled Driver flow run (slower but safer)
9. **Option B**: Manually trigger the Driver flow again (faster)
10. Monitor flow runs in Power Automate (may take several hours)
11. Verify data: Go to Tables → PowerApps App (`admin_app`)
12. Check that apps from all time periods now appear
13. ⚠️ **CRITICAL**: Set **FullInventory** back to `No` after completion

**Expected Result**: All apps, including those from before June 2024, will be visible in the Power Platform Admin View.

### Step 3: Verify Data in Power Platform Admin View

After both steps complete:

1. Open the **Power Platform Admin View** app
2. Select **PowerApps Apps**
3. Filter the environment column
4. Type "Slaughter" in the filter
5. Verify "Slaughter and May Development" appears in the list
6. Select that environment
7. Confirm you see a complete list of apps, including recent ones

## Important Notes

### ⏱️ Timeline Expectations

- **Driver Flow**: 5-30 minutes depending on number of environments
- **Full Inventory**: 
  - Small tenants (< 100 apps): 30 minutes - 1 hour
  - Medium tenants (100-500 apps): 1-3 hours
  - Large tenants (500+ apps): 3-8 hours
  - Very large tenants (1000+ apps): 8+ hours

### ⚠️ Critical: Set FullInventory Back to No

After the full inventory completes, you **MUST** set `admin_FullInventory` back to `No`.

**Why this matters**:
- Leaving it enabled will cause flows to re-scan ALL resources every time they run
- This consumes excessive API calls
- May cause throttling/rate limiting
- Impacts tenant performance
- Increases costs

### 🔍 Monitoring Progress

To monitor full inventory progress:

1. Go to Power Automate → Cloud flows
2. Filter by solution: Center of Excellence - Core Components
3. Watch for these flows running:
   - Admin | Sync Template v4 (Driver) - Runs first
   - Admin | Sync Template v4 (Apps) - Starts after Driver
   - Admin | Sync Template v4 (Cloud Flows) - Runs for each environment
   - SYNC HELPER flows - Run for individual resources

4. Check run history for each flow
5. Look for "Succeeded" status
6. If you see failures, review error messages

## Comprehensive Documentation

For complete details, troubleshooting, and additional scenarios, see:

📖 **[Power Platform Admin View Not Showing Updated Apps or Missing Environments - Full Troubleshooting Guide](troubleshooting/admin-view-missing-data.md)**

This guide includes:
- ✅ Detailed step-by-step instructions with screenshots
- ✅ Common error messages and solutions
- ✅ Flow connection troubleshooting
- ✅ Permission requirements
- ✅ Post-upgrade checklist
- ✅ Understanding incremental vs full inventory
- ✅ Best practices for ongoing maintenance

## Recommended Post-Upgrade Process

To avoid this issue after future upgrades:

### Before Upgrade:
1. ✅ Remove all unmanaged layers from CoE solutions
2. ✅ Document current environment variable settings
3. ✅ Export customizations if needed

### Immediately After Upgrade:
1. ✅ Verify all flows imported successfully
2. ✅ Update flow connections
3. ✅ Manually run the Driver flow
4. ✅ Run a full inventory
5. ✅ Verify data in Admin View app
6. ✅ Set FullInventory back to No

### Ongoing:
1. ✅ Monitor Driver flow runs (should run daily)
2. ✅ Run full inventory quarterly
3. ✅ Set up alerts for flow failures
4. ✅ Review sync flow run history weekly

## If You're Still Having Issues

If you've followed these steps and still have problems, please provide:

1. **Flow run history screenshots** for:
   - Admin | Sync Template v4 (Driver)
   - Admin | Sync Template v4 (Apps)
   - Any flows showing failures

2. **Error messages**: Full text of any errors

3. **Environment variable values**:
   - Current value of `admin_FullInventory`
   - Current value of `admin_InventoryFilter_DaysToLookBack`

4. **Verification steps completed**:
   - Which steps from above you've completed
   - What results you saw
   - Where the process is stuck

5. **Environment details**:
   - Number of environments in your tenant
   - Approximate number of apps
   - Any DLP policies or conditional access that might affect connectors

## Additional Resources

- [CoE Starter Kit - Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [CoE Starter Kit - After Setup/Upgrades](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)
- [Troubleshooting Upgrades](../TROUBLESHOOTING-UPGRADES.md)
- [Power Platform Admin Connector Documentation](https://learn.microsoft.com/connectors/powerplatformforadmins/)
- [Understanding Service Protection Limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)

## Previous Issue Reference

You mentioned that a previous issue was closed before you could implement the fix. I apologize for that experience. 

**For this issue**:
- The solution is documented comprehensively above
- The troubleshooting guide is now part of the repository for future reference
- You can bookmark the guide for future upgrades
- Feel free to reopen or comment if you encounter specific problems during implementation

**Going forward**:
- Issues should remain open until the user confirms the solution works
- If an issue is auto-closed, please comment to reopen
- The new documentation should prevent similar issues after future upgrades

---

**Document Status**: SOLUTION PROVIDED  
**Next Action**: User to follow Step 1 and Step 2, then report results  
**Related Documentation**: [admin-view-missing-data.md](troubleshooting/admin-view-missing-data.md)  
**Created**: January 2026  
**CoE Version**: Applies to v4.17+ with v4 sync architecture
