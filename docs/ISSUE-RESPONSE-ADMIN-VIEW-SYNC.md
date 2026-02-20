# GitHub Issue Response Template - Power Platform Admin View Missing Data

This template can be used when responding to issues where the Power Platform Admin View app is not showing all apps or environments after an upgrade.

---

## Template: Admin View Not Showing Updated Apps or Missing Environments

**Use when:** Users report that the Power Platform Admin View app is:
- Not showing all apps (only apps from a specific date)
- Missing environments in the filter/list
- Not reflecting recent changes after an upgrade

**Response:**

Thank you for reporting this issue. This is a common scenario after upgrading the CoE Starter Kit, and there's a straightforward solution.

### Root Cause

The issue occurs because:

1. **The Driver flow needs to run** - After an upgrade, the **Admin | Sync Template v4 (Driver)** flow needs to execute to refresh your environment list and trigger child sync flows.

2. **Incremental inventory mode is active** - By default, the sync flows run in incremental mode, which only syncs resources modified within the last 7 days. After an upgrade, you need to run a **full inventory** to capture all historical data.

### Solution Steps

I've created a comprehensive troubleshooting guide that covers your exact scenario:

📖 **[Power Platform Admin View Not Showing Updated Apps or Missing Environments](../docs/troubleshooting/admin-view-missing-data.md)**

#### Quick Fix (TL;DR):

**For Missing Environments:**
1. Go to Power Automate → your CoE environment
2. Find and manually run: **Admin | Sync Template v4 (Driver)**
3. Wait for completion (5-30 minutes)
4. Verify environments appear in Dataverse

**For Outdated App Data:**
1. Go to Power Apps → CoE environment → Solutions → Center of Excellence - Core Components
2. Navigate to Environment Variables
3. Set **FullInventory** (`admin_FullInventory`) to `Yes`
4. Wait for sync to complete (may take several hours)
5. ⚠️ **Important**: Set **FullInventory** back to `No` when done

### Detailed Guidance

The troubleshooting guide provides:
- ✅ Step-by-step instructions for each scenario
- ✅ Screenshots and validation steps
- ✅ Common error messages and solutions
- ✅ Post-upgrade checklist to prevent future issues
- ✅ Explanation of incremental vs full inventory modes

### What to Expect

After following the steps:
- ✅ All environments (including "Slaughter and May Development") should appear
- ✅ All apps (including those from before June 2024) should be visible
- ✅ The Power Platform Admin View app should show complete, up-to-date data

### Important Notes

1. **Full inventory takes time**: For large tenants, a full inventory can take several hours. This is normal.

2. **Set FullInventory back to No**: After the full inventory completes, you MUST set the `admin_FullInventory` environment variable back to `No`. Leaving it on will cause performance issues.

3. **Monitor flow runs**: Check the run history of the Driver flow and sync flows to ensure they're completing successfully.

### If You're Still Having Issues

If you've followed the troubleshooting guide and still experience problems, please provide:
- Flow run history screenshots (especially for the Driver flow)
- Any error messages you're seeing
- Confirmation of which steps you've completed
- Current value of the `admin_FullInventory` environment variable

This will help us provide more specific guidance.

### Additional Resources

- [CoE Starter Kit Setup - Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Troubleshooting Upgrades](../../TROUBLESHOOTING-UPGRADES.md)
- [Understanding CoE Inventory Flows](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#inventory-flows)

Let me know if you have any questions!

---

## Template: Sync Flows Missing After Upgrade

**Use when:** Users report specific sync flows are missing after upgrade

**Response:**

Thank you for reporting that the **Admin | Sync Template v4 (Environments)** flow is missing.

### About Flow Names and Architecture

There's a common point of confusion here. The CoE Starter Kit v4 uses a specific flow architecture:

**The flow structure is:**
- **Admin | Sync Template v4 (Driver)** - The master flow that lists all environments and triggers other syncs
- **Admin | Sync Template v4 (Apps)** - Syncs canvas apps
- **Admin | Sync Template v4 (Cloud Flows)** - Syncs cloud flows
- **Admin | Sync Template v4 (Model Driven Apps)** - Syncs model-driven apps
- *...and other resource-specific sync flows*

**Note**: There is **no separate "Admin | Sync Template v4 (Environments)" flow**. The Driver flow handles environment discovery and synchronization.

### What You Should See

In your CoE environment, under Solutions → Center of Excellence - Core Components → Cloud flows, you should have:

✅ **Admin | Sync Template v4 (Driver)** - This is the environment sync flow  
✅ **Admin | Sync Template v4 (Apps)** - For syncing apps  
✅ **SYNC HELPER - Apps** - Helper flow for app details  

### Verify Your Flows

1. Go to Power Automate → your CoE environment
2. Navigate to Solutions → Center of Excellence - Core Components
3. Click on Cloud flows
4. Search for flows starting with "Admin | Sync Template v4"
5. Verify the **Driver** flow exists and is turned on

### If Flows Are Actually Missing

If you genuinely don't see the expected sync flows:

1. **Check solution import**: The upgrade may not have completed successfully
   - Review the solution import history
   - Look for any error messages

2. **Re-import the solution**: 
   - Download the latest Core Components solution from [Releases](https://github.com/microsoft/coe-starter-kit/releases)
   - Import as an upgrade
   - Follow the [upgrade troubleshooting guide](../../TROUBLESHOOTING-UPGRADES.md)

3. **Remove unmanaged layers**: 
   - Use the CoE Admin Command Center
   - Or manually remove via solution layers
   - Then re-import the solution

### Next Steps

Please check your flows and confirm:
- Does the **Admin | Sync Template v4 (Driver)** flow exist?
- What is its status (On/Off/Suspended)?
- What other "Admin | Sync Template v4" flows do you see?

This will help determine if flows are genuinely missing or if there's confusion about naming.

---

## Template: Data Is Outdated / Not Refreshing

**Use when:** Users report data is not updating or shows only old records

**Response:**

Thank you for reporting that your data appears outdated (showing only apps/resources from [DATE]).

This is a characteristic behavior of the **incremental inventory mode**, which is the default setting after installation and upgrades.

### Why This Happens

The CoE Starter Kit sync flows operate in two modes:

**Incremental Mode (Default)**:
- Syncs only NEW resources (not yet in inventory)
- Syncs resources modified within the last 7 days
- Efficient for daily operations
- Won't re-sync historical data

**Full Inventory Mode**:
- Syncs ALL resources regardless of modification date
- Complete refresh of inventory
- Required after upgrades or initial setup
- Must be run manually

### The Solution

You need to run a **full inventory** to capture all historical resources:

1. Navigate to: Power Apps → CoE environment → Solutions → Center of Excellence - Core Components
2. Click **Environment Variables**
3. Find **FullInventory** (`admin_FullInventory`)
4. Set Current Value to `Yes`
5. Wait for sync completion (may take hours for large tenants)
6. ⚠️ **CRITICAL**: Set back to `No` after completion

### Detailed Guide

For complete step-by-step instructions, see:
📖 [Power Platform Admin View Missing Data Troubleshooting](../docs/troubleshooting/admin-view-missing-data.md#solution-2-run-a-full-inventory-to-capture-all-apps)

### Timeline Expectations

- **Small tenants** (< 100 apps): 30 minutes to 1 hour
- **Medium tenants** (100-500 apps): 1-3 hours
- **Large tenants** (500+ apps): 3-8 hours
- **Very large tenants** (1000+ apps): 8+ hours

This is normal and expected. The flows are making thousands of API calls to refresh all data.

### After Full Inventory Completes

1. ✅ Set `admin_FullInventory` back to `No`
2. ✅ Verify data in Power Platform Admin View app
3. ✅ Check that apps from all time periods now appear
4. ✅ Confirm environment filters work correctly

### Ongoing Maintenance

- Run full inventory **quarterly** or when data appears incomplete
- The daily incremental sync will keep new/modified resources up to date
- Consider increasing `admin_InventoryFilter_DaysToLookBack` if 7 days is too short

Let me know if you have questions!

---

## Notes for Responders

### Key Points to Remember

1. **Be specific about flow names**: The Driver flow handles environments; there's no separate "Environments" sync flow
2. **Emphasize the importance of setting FullInventory back to No**: This is critical for performance
3. **Set expectations on timing**: Full inventory takes hours for large tenants
4. **Link to the detailed troubleshooting guide**: Don't repeat all steps in the issue comment

### Common Follow-up Questions

**Q: "How do I know when full inventory is done?"**
A: Monitor the flow run history. When you see no new "Admin | Sync Template v4" flows running, it's complete. Check the table record counts to verify.

**Q: "Can I run full inventory during business hours?"**
A: Yes, but it will consume API quota. For very large tenants, consider running during off-peak hours.

**Q: "Do I need to turn flows off before upgrade?"**
A: No, but ensure no flows are running during the solution import. You may want to temporarily disable scheduled triggers.

**Q: "Will this fix missing data in Power BI dashboards?"**
A: Yes, once the Dataverse tables are updated, the Power BI dashboards will reflect the new data on the next refresh.

### Escalation Criteria

Create or reference separate issues for:
- Actual bugs in sync flow logic
- Flows genuinely missing after upgrade (not just misnamed)
- Consistent flow failures with error messages
- Performance issues during full inventory
- Data not appearing even after full inventory completes

### Related Issues

When responding, search for and link to related issues:
- Similar reports of missing data
- Previous upgrade issues
- Flow import problems

---

**Template Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
