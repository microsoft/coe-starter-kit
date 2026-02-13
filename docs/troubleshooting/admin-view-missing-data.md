# Troubleshooting: Power Platform Admin View Not Showing Updated Apps or Missing Environments

## Issue Description

After upgrading the CoE Starter Kit, the **Power Platform Admin View** app may not display:
- Updated list of apps (showing only apps created before a certain date)
- All environments in your tenant (specific environments are missing)
- Complete inventory data

This issue typically occurs after major version upgrades and is related to how the inventory sync flows operate.

## Root Cause

The CoE Starter Kit uses a **hierarchical sync architecture** where:

1. **Admin | Sync Template v4 (Driver)** - The "master" flow that:
   - Runs on a schedule (typically daily)
   - Lists all environments in your tenant
   - Creates or updates environment records in Dataverse
   - **Triggers all other sync flows** by updating environment records

2. **Admin | Sync Template v4 (Apps, Flows, etc.)** - Child flows that:
   - Are triggered automatically when environment records are created/updated
   - Run in **incremental mode** by default (only sync new or recently modified items)
   - Sync specific resource types (Apps, Flows, Connectors, etc.)

3. **SYNC HELPER flows** - Detailed sync flows for individual items

After an upgrade, the sync flows may not have run properly or may be in incremental mode, which explains why:
- **Missing environments**: The Driver flow hasn't executed to refresh the environment list
- **Old app data**: Incremental mode only syncs apps modified within the last 7 days (default setting)

## Quick Diagnosis

Answer these questions to identify your specific issue:

**Q1: Are you missing environments in the Environment filter?**
- **Yes** → Go to [Solution 1: Trigger the Driver Flow](#solution-1-trigger-the-driver-flow-to-refresh-environments)

**Q2: Can you see your environments, but apps are outdated (e.g., only showing apps from June 2024)?**
- **Yes** → Go to [Solution 2: Run a Full Inventory](#solution-2-run-a-full-inventory-to-capture-all-apps)

**Q3: Are the sync flows showing up in your solution?**
- **No, flows are missing** → Go to [Solution 3: Verify Flow Import](#solution-3-verify-flow-import-after-upgrade)

## Solution 1: Trigger the Driver Flow to Refresh Environments

The Driver flow is the foundation of the sync architecture. After an upgrade, you need to ensure it runs to refresh your environment list.

### Steps:

1. **Navigate to Power Automate**
   - Go to [https://make.powerautomate.com](https://make.powerautomate.com)
   - Select your **CoE environment** from the environment picker

2. **Locate the Driver Flow**
   - Go to **My flows** or **Solutions** → **Center of Excellence - Core Components**
   - Search for: **Admin | Sync Template v4 (Driver)**

3. **Verify the Flow Exists and Is Active**
   - Check that the flow appears in the list
   - Status should be **On** (not suspended or off)
   - If the flow is **Off**, turn it on

4. **Check Flow Connections**
   - Open the flow in edit mode
   - Verify all connections are valid (no warning icons)
   - If connections need updating:
     - Click on each connection warning
     - Re-authenticate or select the correct connection
     - Save the flow

5. **Manually Run the Flow**
   - Click on the flow name
   - Click **Run** → **Run flow**
   - Wait for completion (may take 5-30 minutes depending on tenant size)

6. **Verify Flow Run History**
   - After the flow completes, check the run history
   - Ensure it shows **Succeeded**
   - Review the outputs to confirm environments were listed

7. **Check for Environment Records in Dataverse**
   - Go to [https://make.powerapps.com](https://make.powerapps.com)
   - Select your CoE environment
   - Go to **Tables** → **Environment** (`admin_environment`)
   - Verify your missing environment(s) now appear in the list
   - Check the **Modified On** date to confirm recent updates

### Expected Result:
- All environments in your tenant should now be listed in the Environment table
- The missing environment (e.g., "Slaughter and May Development") should now appear
- This will automatically trigger child sync flows for these environments

## Solution 2: Run a Full Inventory to Capture All Apps

By default, sync flows run in **incremental mode**, which only syncs resources modified within the last 7 days. After an upgrade or if you're missing historical data, you need to run a **full inventory**.

### Steps:

1. **Navigate to Environment Variables**
   - Go to [https://make.powerapps.com](https://make.powerapps.com)
   - Select your **CoE environment**
   - Go to **Solutions** → **Center of Excellence - Core Components**
   - Click **Environment Variables** in the left navigation

2. **Locate the FullInventory Variable**
   - Search for: **FullInventory** (Display Name) or `admin_FullInventory` (Schema Name)

3. **Enable Full Inventory Mode**
   - Click on the **FullInventory** environment variable
   - In the **Current Value** section, click **+ New value** (if no current value exists) or **Edit** (if a value exists)
   - Set the value to: `Yes` (or `true`)
   - Click **Save**

4. **Trigger the Inventory Flows**
   
   You have two options:

   **Option A: Wait for Scheduled Run (Recommended for Large Tenants)**
   - The Driver flow will run on its schedule (typically daily)
   - When it updates environment records, child sync flows will automatically trigger in full inventory mode
   - This spreads the load over time

   **Option B: Manually Trigger (Faster, but More Resource Intensive)**
   - Go to Power Automate
   - Navigate to **Admin | Sync Template v4 (Driver)**
   - Click **Run** → **Run flow**
   - This will immediately trigger all child sync flows in full inventory mode

5. **Monitor Progress**
   - Go to Power Automate → **Cloud flows**
   - Filter by solution: **Center of Excellence - Core Components**
   - Look for flows running:
     - **Admin | Sync Template v4 (Driver)** - Should complete first
     - **Admin | Sync Template v4 (Apps)** - Will start after Driver updates environments
     - **SYNC HELPER - Apps** - Will run for each app
   
   **Note**: Full inventory can take **several hours to complete** for large tenants (1000+ apps)

6. **Verify App Data**
   - Go to **Tables** → **PowerApps App** (`admin_app`)
   - Check the **Modified On** dates - they should be recent
   - Verify apps created before June 2024 now appear
   - Check the record count - it should match your expected app count

7. **Disable Full Inventory Mode (CRITICAL)**
   - After the full inventory completes, **immediately** set `admin_FullInventory` back to `No` (or `false`)
   - **Why this matters**: Leaving full inventory enabled will cause sync flows to re-scan ALL resources on every run, which:
     - Consumes excessive API calls
     - May cause throttling
     - Impacts performance
     - Increases costs

### Expected Result:
- All apps across all environments (including those created before June 2024) should now appear in the inventory
- The Power Platform Admin View app should display the complete app list
- Filtering by environment should show all apps in that environment

## Solution 3: Verify Flow Import After Upgrade

If you don't see the expected sync flows after upgrade, they may not have imported correctly.

### Steps:

1. **Check Which Flows Exist**
   - Go to Power Automate
   - Select your CoE environment
   - Go to **Solutions** → **Center of Excellence - Core Components**
   - Navigate to **Cloud flows**

2. **Verify Key Flows Are Present**
   
   Essential flows that must exist:
   - ✅ **Admin | Sync Template v4 (Driver)**
   - ✅ **Admin | Sync Template v4 (Apps)**
   - ✅ **Admin | Sync Template v4 (Cloud Flows)**
   - ✅ **Admin | Sync Template v4 (Custom Connectors)**
   - ✅ **SYNC HELPER - Apps**
   - ✅ **SYNC HELPER - Cloud Flows**

3. **If Flows Are Missing**
   
   **Cause**: The solution upgrade failed to import all components
   
   **Solution**:
   - Re-download the Core Components solution from the [latest release](https://github.com/microsoft/coe-starter-kit/releases)
   - Import the solution again (as an upgrade)
   - Follow the [upgrade guidance](../../TROUBLESHOOTING-UPGRADES.md) for best practices

4. **Check for Unmanaged Layers**
   
   Unmanaged customizations can block flow updates:
   - In the solution, select a flow
   - Click **Advanced** → **See solution layers**
   - If you see **Unmanaged** layers, remove them:
     - Select the unmanaged layer
     - Click **Remove unmanaged layer**
   - Repeat for all flows with unmanaged layers

## Additional Troubleshooting

### Check Flow Run History

1. Go to Power Automate → Cloud flows
2. Select the flow you want to check
3. Click **Run history**
4. Review recent runs:
   - **Succeeded**: Flow completed successfully
   - **Failed**: Open the run and review error messages
   - **Skipped**: Conditional branches were not executed (may be normal)

### Common Error Messages

**Error: "TooManyRequests"**
- **Cause**: Service protection limits exceeded
- **Solution**: See [TROUBLESHOOTING-UPGRADES.md](../../TROUBLESHOOTING-UPGRADES.md) for detailed guidance

**Error: "Connection not configured"**
- **Cause**: Flow connections need to be set up or re-authenticated
- **Solution**: Edit the flow and update all connections

**Error: "Access denied" or "Forbidden"**
- **Cause**: The account running the flows doesn't have sufficient permissions
- **Solution**: Ensure the flow owner has:
  - Power Platform Administrator or Global Administrator role
  - System Administrator role in the CoE environment
  - See [FAQ-AdminRoleRequirements.md](../../CenterofExcellenceResources/FAQ-AdminRoleRequirements.md)

### Check Environment Variable Configuration

Other environment variables that affect sync behavior:

| Variable | Schema Name | Default | Impact |
|----------|-------------|---------|--------|
| **FullInventory** | `admin_FullInventory` | No | Controls full vs incremental mode |
| **InventoryFilter_DaysToLookBack** | `admin_InventoryFilter_DaysToLookBack` | 7 | Days to look back for modified resources in incremental mode |
| **DelayObjectInventory** | `admin_DelayObjectInventory` | No | Adds random delay to avoid throttling |

To check these:
1. Go to Solutions → Center of Excellence - Core Components → Environment Variables
2. Review current values
3. Adjust as needed for your scenario

## Recommended Post-Upgrade Process

To avoid these issues after future upgrades, follow this process:

### Immediately After Upgrade:

1. ✅ **Remove unmanaged layers** before upgrading
   - Use CoE Admin Command Center
   - Or manually remove via solution layers

2. ✅ **Verify flow import**
   - Check that all sync flows exist
   - Verify flows are in "On" state

3. ✅ **Update connections**
   - Edit each flow
   - Ensure all connections are valid
   - Save the flows

4. ✅ **Run the Driver flow manually**
   - Trigger Admin | Sync Template v4 (Driver)
   - Verify it completes successfully

5. ✅ **Run a full inventory**
   - Set `admin_FullInventory` to `Yes`
   - Wait for sync to complete (may take hours)
   - Set `admin_FullInventory` back to `No`

6. ✅ **Verify data in Power Platform Admin View**
   - Open the app
   - Check that environments are listed
   - Verify apps appear with recent data
   - Test filters and views

### Ongoing Maintenance:

- **Monitor flow runs**: Check the Driver flow runs daily
- **Review error notifications**: Set up alerts for flow failures
- **Run full inventory periodically**: Quarterly or when you notice missing data
- **Keep environment variables updated**: Adjust `DaysToLookBack` based on your needs

## Understanding Incremental vs Full Inventory

### Incremental Inventory (Default)
**When it runs**: Every time the Driver flow updates environment records (typically daily)

**What it syncs**:
- New resources (not yet in inventory)
- Resources modified within the last N days (default 7 days)
- Resources manually flagged (`admin_inventoryme = true`)

**Benefits**:
- ✅ Efficient (fewer API calls)
- ✅ Faster execution
- ✅ Suitable for daily operations
- ✅ Reduces throttling risk

**Limitations**:
- ❌ Won't capture historical resources
- ❌ May miss resources if initial sync was incomplete
- ❌ Requires full inventory for complete data

### Full Inventory
**When to use**:
- Initial setup / first-time configuration
- After major upgrades
- When data appears incomplete or outdated
- Quarterly maintenance (recommended)

**What it syncs**:
- ALL resources across ALL environments
- Regardless of modification date
- Complete refresh of inventory

**Important Notes**:
- ⚠️ Can take several hours for large tenants
- ⚠️ Generates many API calls
- ⚠️ Must set back to `No` after completion
- ⚠️ Run during off-peak hours if possible

## Still Having Issues?

If you've followed all steps and still experience problems:

1. **Search existing issues**: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. **Check official documentation**: [CoE Starter Kit Docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
3. **Review upgrade guide**: [TROUBLESHOOTING-UPGRADES.md](../../TROUBLESHOOTING-UPGRADES.md)
4. **Report a new issue**: Include:
   - CoE Starter Kit version
   - Steps you've already tried
   - Flow run history screenshots
   - Specific error messages
   - Environment details

## Related Documentation

- [Troubleshooting: PVA Sync Issues](../../CenterofExcellenceCoreComponents/TROUBLESHOOTING-PVA-SYNC.md)
- [Troubleshooting: Upgrade Issues](../../TROUBLESHOOTING-UPGRADES.md)
- [Core Components README](../../CenterofExcellenceCoreComponents/README.md)
- [Official CoE Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

---

**Document Version**: 1.0  
**Last Updated**: January 2026  
**Applies To**: CoE Starter Kit v4.17+ (with v4 sync flows)
