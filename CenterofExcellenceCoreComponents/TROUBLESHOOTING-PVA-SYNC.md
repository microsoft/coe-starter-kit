# Troubleshooting: Not All Copilot Studio Agents (PVA Bots) Appearing in Inventory

## Issue Description

You may notice that not all Copilot Studio agents (Power Virtual Agents/bots) are appearing in the `admin_pva` table or Power BI Dashboard, even though the **Admin | Sync Template v4 (PVA)** flow shows successful runs.

## Quick Diagnosis

Before diving into detailed troubleshooting, answer these questions to quickly identify your issue:

**Q1: Is this the first time running the inventory, or have some bots been synced successfully before?**
- **First time / Initial setup**: Go to [Option 1: Run a Full Inventory](#option-1-run-a-full-inventory-recommended)
- **Some bots synced, but missing specific ones**: Continue to Q2

**Q2: When were the missing bots last modified?**
- **More than 7 days ago**: Go to [Option 1: Run a Full Inventory](#option-1-run-a-full-inventory-recommended) or [Option 3: Increase the Lookback Window](#option-3-increase-the-lookback-window)
- **Within the last 7 days**: Continue to Q3

**Q3: Are the missing bots in all environments or specific environment(s)?**
- **Specific environment(s)**: Go to [Check for Environment-Specific Issues](#check-for-environment-specific-issues)
- **All environments**: Go to [Check for Permission Issues](#check-for-permission-issues)

**Q4: Are all bots published in Copilot Studio?**
- **No, some are drafts**: Only **published** bots appear in the inventory. Publish the bots first.
- **Yes, all published**: Continue to [Root Cause](#root-cause) section below

## Root Cause

The **Admin | Sync Template v4 (PVA)** flow operates in different modes depending on environment variable settings. By default, it runs in **incremental inventory mode**, which only syncs:

1. **New bots** - Bots that exist in the environment but are not yet in the inventory table
2. **Manually flagged bots** - Bots with the `admin_inventoryme` field set to `true`
3. **Recently modified bots** - Bots that have been modified within the last N days (controlled by the `admin_InventoryFilter_DaysToLookBack` environment variable, default is 7 days)

**Important Note About Bot States:**
- The flow syncs **all bots** regardless of their state (Published, Draft/Unpublished, or Deleted)
- Bots are marked in the inventory with their `componentstate`: Published (0), Unpublished (1), Deleted (2), or Deleted Unpublished (3)
- The Power BI Dashboard may filter to show only Published bots by default
- If you only see published bots in the dashboard but expect to see drafts too, check your Power BI report filters

This means that:
- Bots that haven't been modified recently will not be re-inventoried in incremental mode
- If a bot was somehow skipped or missed in a previous run, it won't be picked up again unless it's modified or manually flagged
- Bots that were created or published a long time ago may have been missed if they existed before the initial inventory run

## Solution Options

### Option 1: Run a Full Inventory (Recommended)

A full inventory will scan and sync ALL bots across ALL environments, regardless of modification date.

**Steps:**

1. Navigate to the CoE environment in Power Apps (make.powerapps.com)
2. Go to **Solutions** → **Center of Excellence - Core Components**
3. Select **Environment Variables** from the left navigation
4. Find the environment variable: **FullInventory** (`admin_FullInventory`)
5. Update the **Current Value** to `Yes` (or `true`)
6. Wait for the sync flows to run (they are triggered by environment updates)
7. **Important:** After the full inventory completes, set **FullInventory** back to `No` (or `false`)

**Note:** Full inventory runs can be resource-intensive and may take several hours to complete for large tenants. Only run full inventory when necessary.

### Option 2: Manually Flag Specific Bots for Inventory

If you know specific bots are missing, you can manually flag them for the next sync cycle.

**Steps:**

1. Navigate to the CoE environment in Power Apps (make.powerapps.com)
2. Go to **Tables** → **PVA** (`admin_pva`)
3. Find the bot record(s) that are missing or need updating
   - If the bot doesn't exist, you may need to create a placeholder record with the `admin_botid` field
4. Set the **Inventory Me** (`admin_inventoryme`) field to `Yes` (or `true`)
5. Wait for the next sync cycle to run

**Note:** This approach only works if the bot record already exists in the inventory table.

### Option 3: Increase the Lookback Window

If bots are being modified but the window is too short, you can increase the number of days to look back.

**Steps:**

1. Navigate to the CoE environment in Power Apps (make.powerapps.com)
2. Go to **Solutions** → **Center of Excellence - Core Components**
3. Select **Environment Variables** from the left navigation
4. Find the environment variable: **InventoryFilter_DaysToLookBack** (`admin_InventoryFilter_DaysToLookBack`)
5. Update the **Current Value** to a larger number (e.g., `30` or `60` days)
6. Wait for the sync flows to run

**Note:** Increasing this value will cause more bots to be scanned in each sync cycle, which may increase flow execution time and API calls.

### Option 4: Trigger Manual Environment Sync

The PVA sync flow is triggered when an environment record is created or updated. You can manually trigger a sync for a specific environment.

**Steps:**

1. Navigate to the CoE environment in Power Apps (make.powerapps.com)
2. Go to **Tables** → **Environment** (`admin_environment`)
3. Find the environment record that contains the missing bots
4. Open the record and make a small change (e.g., add a note or update a text field)
5. Save the record
6. This will trigger the **Admin | Sync Template v4 (PVA)** flow for that environment

## Verify the Solution

After implementing one of the solutions above, verify that all bots are now appearing:

1. Check the **admin_pva** table in the CoE environment
2. Review the Power BI Dashboard to confirm all expected bots are visible
3. Check the flow run history of **Admin | Sync Template v4 (PVA)** to ensure successful executions

## Understanding "Skipped" Branches in Flow Runs

When you review the flow run history and see "skipped" branches, this is **normal behavior**. The flow has multiple conditional branches that determine which bots to inventory:

- **"Check if PVAs can and should be retrieved for this environment"** - Skips if the environment is deleted, doesn't have CDS, is excluded from inventory, or is not enabled
- **"Count PVAs"** - Skips if there are PVAs found (only runs if the query returns zero results)
- **"Look for new PVAs"** - Only runs if not in full inventory mode
- **"Look for rpas manually flagged for inventory"** - Only runs if not in full inventory mode
- **"Look for ones modified since date"** - Only runs if not in full inventory mode

Skipped branches do NOT indicate an error - they are part of the flow's conditional logic.

## Common Scenarios and Causes

### Scenario 1: Newly Created Bots Not Appearing
**Cause:** The bot was created in an environment that hasn't been synced yet, or the bot hasn't been published.

**Solution:** 
- Ensure the bot is published in Copilot Studio
- Wait for the next sync cycle (typically runs when environments are updated)
- Or use Option 4 to manually trigger an environment sync

### Scenario 2: Old Bots Missing After Initial Setup
**Cause:** The initial inventory may have missed some bots if they weren't modified recently.

**Solution:** Run a full inventory (Option 1) to capture all historical bots.

### Scenario 3: Bots in Specific Environments Not Appearing
**Cause:** The environment may be excluded from inventory or the flow may lack permissions.

**Solution:**
- Check the environment record in the `admin_environment` table
- Ensure `admin_excusefrominventory` is set to `No` (or `false`)
- Ensure `admin_hascds` is set to `Yes` (or `true`)
- Ensure `admin_environmentdeleted` is set to `No` (or `false`)
- Ensure `admin_environmentruntimestate` is set to `Enabled`
- Verify that the CoE service account has appropriate permissions to the environment

### Scenario 4: Bots Appear as "Orphaned"
**Cause:** The bot owner cannot be determined or the owner is not in the Makers table.

**Solution:** This is expected behavior for system-owned or deleted-owner bots. The flow will mark them as `admin_pvaisorphaned = Yes`.

## Related Environment Variables

Key environment variables that control PVA sync behavior:

| Variable Name | Default Value | Description |
|--------------|---------------|-------------|
| `admin_FullInventory` | `false` (No) | When `true`, scans ALL bots regardless of modification date |
| `admin_InventoryFilter_DaysToLookBack` | `7` | Number of days to look back for modified bots in incremental mode |
| `admin_DelayObjectInventory` | `true` (Yes) as of v4.51+ | When `true`, adds a random delay (1-300 minutes) before syncing to avoid throttling |
| `admin_PowerAutomateEnvironmentVariable` | Environment-specific | Base URL for Power Automate (e.g., `https://flow.microsoft.com/manage/environments/`) |

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Inventory and Telemetry Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

## Advanced Troubleshooting

### Check Flow Run History for Specific Environment

1. Navigate to **Cloud flows** in the CoE environment
2. Find **Admin | Sync Template v4 (PVA)**
3. View **28-day run history**
4. Filter runs by the environment that has missing bots
5. Open a recent successful run and examine:
   - **List_Envt_PVAs** action - How many bots were retrieved from the environment?
   - **List_Inventory_Bots** action - How many bots are currently in the inventory for this environment?
   - **Look_for_PVAs_to_Inventory** scope - How many bots were added to the inventory array?
   - **For_each_item_to_inventory** loop - Did it process the expected number of bots?

### Check for Permission Issues

The flow might not have permissions to read bots from certain environments. Look for these signs:

1. In the flow run history, check if **Terminate_if_no_access** action was executed
2. Look for 401 or 403 error codes in failed actions
3. Verify that the CoE service account (the user or service principal running the flow) has:
   - **System Administrator** role in the target environment
   - **Power Platform Administrator** or **Dynamics 365 Administrator** tenant role

### Check for API Throttling or Timeouts

If you have environments with a very large number of bots (hundreds or thousands), the flow might experience throttling or timeouts:

1. Check flow run history for timeout errors or retries
2. Look for patterns where the flow consistently fails or times out for specific environments
3. Consider enabling **DelayObjectInventory** environment variable to add delays between syncs
4. Check if pagination is working correctly - the flow should retrieve up to 100,000 records

### Verify Dataverse Connection Health

1. Navigate to **Connections** in the CoE environment
2. Find the **Dataverse** connection used by the sync flows (usually named **CoE Core Dataverse** or similar)
3. Verify the connection is not expired or broken
4. Test the connection by clicking **Test** or trying to use it in a simple flow

### Check for Environment-Specific Issues

Some environments may be intentionally or unintentionally excluded from inventory:

1. Navigate to **Tables** → **Environment** (`admin_environment`)
2. Find the environment record for the environment with missing bots
3. Verify these field values:
   - `admin_excusefrominventory` = No (false)
   - `admin_hascds` = Yes (true)
   - `admin_environmentdeleted` = No (false)
   - `admin_environmentruntimestate` = Enabled
   - `admin_environmentcdsinstanceurl` is populated correctly

### Compare Actual Bots vs Inventory

To identify exactly which bots are missing:

1. Query the `bots` table directly in the target environment using **Advanced Find** or **Dataverse Web API**
2. Query the `admin_pvas` table in the CoE environment for bots in the target environment
3. Compare the bot IDs to identify gaps
4. Use the **admin_inventoryme** field to manually flag missing bots for the next sync

## Still Having Issues?

If you've tried all troubleshooting steps above and are still experiencing issues:

1. Collect diagnostics:
   - Flow run history with detailed action outputs
   - `admin_syncflowerrorses` table records
   - Environment configuration (`admin_environment` record)
   - List of missing bot IDs and names
   - Query results showing bots in source environment vs inventory
2. File an issue on the [CoE Starter Kit GitHub](https://github.com/microsoft/coe-starter-kit/issues) with:
   - Solution version
   - Environment details
   - Flow run history screenshots
   - Description of missing bots (how many, which environments, when created)
   - All collected diagnostics
