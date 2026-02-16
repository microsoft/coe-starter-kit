# Troubleshooting: Desktop Flows Not Appearing in CoE Inventory

## Quick Diagnosis

**Symptoms:**
- ✅ "Admin | Sync Template v4 (Desktop flows)" shows successful runs
- ❌ Some or all desktop flows are missing from `admin_rpas` table
- ❌ Desktop flows visible in Power Automate maker portal but not in CoE Dashboard
- 🟡 Some environments show "[]" output while others show "click to download"

**Most Common Cause:** You're running in **incremental inventory mode** (default), which only syncs new or recently modified desktop flows.

---

## Solution 1: Run Full Inventory (Recommended)

The quickest way to get all desktop flows into your inventory is to run a full inventory.

### Steps:

1. **Navigate to Power Apps**
   - Go to [Power Apps](https://make.powerapps.com)
   - Select your **CoE environment**

2. **Open Environment Variables**
   - Go to **Solutions** → **Center of Excellence - Core Components**
   - Click **Environment Variables** from the left navigation

3. **Enable Full Inventory**
   - Find `FullInventory` (Schema name: `admin_FullInventory`)
   - Click to edit
   - Set **Current Value** = `Yes`
   - Click **Save**

4. **Wait for Sync**
   - The next time "Admin | Sync Template v4 (Desktop flows)" runs, it will sync **all** desktop flows
   - This may take longer than usual (especially for large tenants)
   - Check the flow run history to confirm completion

5. **⚠️ IMPORTANT: Disable Full Inventory**
   - After sync completes, **immediately** set `FullInventory` back to `No`
   - Leaving it enabled will cause unnecessary API calls and performance issues

### Verification:

```sql
-- Run this query in Power Automate / Dataverse
-- Check how many desktop flows are inventoried
SELECT COUNT(*) FROM admin_rpas 
WHERE admin_rpadeleted = false
```

Compare this count with the number of desktop flows in your environments.

---

## Solution 2: Manually Flag Desktop Flows for Inventory

If you only need to sync specific desktop flows, you can manually flag them.

### Steps:

1. **Navigate to CoE Environment**
   - Go to [Power Apps](https://make.powerapps.com)
   - Select your **CoE environment**

2. **Open Desktop Flows Table**
   - Go to **Tables** → Search for `admin_rpas`
   - Click **Data**

3. **Find the Desktop Flow**
   - Locate the desktop flow record (if it exists)
   - If it doesn't exist, you'll need to use Solution 1 or 3

4. **Flag for Inventory**
   - Open the record
   - Set `admin_inventoryme` = `Yes`
   - Save

5. **Wait for Next Sync**
   - The next time the sync flow runs, it will inventory this desktop flow

---

## Solution 3: Trigger Sync for Specific Environment

If desktop flows are missing for a specific environment, you can manually trigger a sync.

### Steps:

1. **Navigate to Environments Table**
   - Go to [Power Apps](https://make.powerapps.com) → Your CoE environment
   - Go to **Tables** → Search for `admin_environments`
   - Click **Data**

2. **Find the Environment**
   - Locate the environment with missing desktop flows

3. **Edit the Environment Record**
   - Change any field (e.g., add a space to `admin_displayname`)
   - Save the record

4. **Wait for Sync**
   - This will trigger the sync flow for that environment
   - Check flow run history for "Admin | Sync Template v4 (Desktop flows)"

---

## Understanding Incremental vs Full Inventory

### Incremental Mode (Default - `FullInventory = No`)

**What gets synced:**
- ✅ **New desktop flows** not yet in the inventory
- ✅ **Manually flagged flows** (`admin_inventoryme = true`)
- ❌ **Existing flows** already in inventory (unless flagged)

**Why this mode:**
- Efficient for large tenants (reduces API calls)
- Avoids throttling and performance issues
- Suitable for ongoing operations after initial setup

**When flows are missing:**
- Desktop flows created before CoE setup may not be in inventory
- Desktop flows need to be synced during initial setup via full inventory

### Full Inventory Mode (`FullInventory = Yes`)

**What gets synced:**
- ✅ **ALL desktop flows** from **ALL environments**
- ✅ Updates metadata for all existing desktop flows
- ✅ Creates missing records

**When to use:**
- ✅ **After initial CoE Starter Kit setup** (first-time sync)
- ✅ **After upgrade** to catch any missed desktop flows
- ✅ **When troubleshooting** missing desktop flows
- ✅ **Quarterly or monthly** for data refresh (then disable)

**⚠️ Performance impact:**
- Takes significantly longer (hours for large tenants)
- Increases API calls to Power Platform
- May trigger throttling if you have many environments/flows

---

## Advanced Troubleshooting

### Check Flow Run History

1. **Navigate to Flow**
   - Go to [Power Automate](https://make.powerautomate.com)
   - Select your **CoE environment**
   - Find "Admin | Sync Template v4 (Desktop flows)"

2. **Check Recent Runs**
   - Click **Run history**
   - Find runs for the affected environment
   - Look for the **Inventory Desktop Flows (RPAs) for this envt** scope

3. **Check Action Outputs**
   - Expand **List_Envt_Desktop_Flows** action
   - Check if desktop flows are returned: `body.value` should show your flows
   - If empty `[]`, see "No Desktop Flows Returned" below

### No Desktop Flows Returned

If `List_Envt_Desktop_Flows` returns `[]` but you see flows in the maker portal:

#### Cause 1: Desktop Flow Type Filter

The flow uses this filter: `category eq 6 and uiflowtype ne 101`

- `category eq 6` = Desktop flows (RPA)
- `uiflowtype ne 101` = Excludes certain desktop flow types

**Check:**
- Are the flows standard desktop flows or a special type?
- Check the `uiflowtype` field in the Dataverse `workflows` table

#### Cause 2: Permissions Issue

The flow runs with the CoE System User identity.

**Check:**
1. Verify the CoE System User has **System Administrator** role in the environment
2. Verify the connection to Dataverse is using the correct account
3. Check for DLP policies blocking the connector

**Fix:**
- Go to Power Platform Admin Center
- Navigate to the environment → Users
- Ensure the CoE System User is listed with System Administrator role

#### Cause 3: Environment Configuration

**Check these conditions** (flow terminates if any are true):
- ❌ `admin_environmentdeleted = true` → Environment is deleted
- ❌ `admin_hascds = false` → Environment doesn't have Dataverse
- ❌ `admin_excusefrominventory = true` → Environment excluded from inventory
- ❌ `admin_environmentruntimestate ≠ "Enabled"` → Environment not enabled

**Fix:**
1. Go to **Tables** → `admin_environments`
2. Find the environment
3. Check these fields and correct if needed

---

## Environment Variables Reference

| Variable | Schema Name | Default | Description |
|----------|-------------|---------|-------------|
| **Full Inventory** | `admin_FullInventory` | No | When `Yes`, syncs ALL desktop flows from ALL environments. Set to `No` after running. |
| **Days To Look Back** | `admin_InventoryFilter_DaysToLookBack` | 7 | Not used for desktop flows (unlike cloud flows/PVA). Desktop flows use only "new" vs "existing" logic. |
| **Delay Object Inventory** | `admin_DelayObjectInventory` | No | When `Yes`, adds delays between API calls to avoid throttling. Enable if experiencing throttling. |

---

## FAQ

### Q: Why do some environments show "[]" while others show data?

**A:** Environments with "[]" likely have desktop flows that are already in the inventory (from a previous sync). In incremental mode, these flows are **not re-synced** unless flagged. Use full inventory to sync all flows.

### Q: How often should I run full inventory?

**A:** 
- ✅ **Once** during initial setup
- ✅ **Once** after each major upgrade
- ✅ **Monthly or quarterly** for data refresh (optional)
- ❌ **Not continuously** - set back to `No` immediately after running

### Q: Will desktop flows sync automatically after being created?

**A:** Yes, **new** desktop flows (not yet in inventory) will be synced in incremental mode. The issue only affects flows created **before** the CoE setup or flows that were missed.

### Q: What about desktop flow runs?

**A:** Desktop flow runs are synced by a separate flow: **"Admin | Sync Template v4 (Desktop Flow - Runs)"**. This troubleshooting guide focuses on syncing the desktop flow **definitions** themselves.

### Q: How can I verify my desktop flows are synced?

**A:**
1. Go to **Power Apps** → Your CoE environment
2. Go to **Tables** → `admin_rpas`
3. Click **Data**
4. Verify your desktop flows are listed
5. Check `admin_rpadeleted` = `false` (not deleted)

### Q: Can I exclude specific environments from desktop flow sync?

**A:** Yes, set `admin_excusefrominventory = true` on the environment record in the `admin_environments` table.

---

## Related Issues

This issue is similar to:
- **PVA bots not appearing** → See [TROUBLESHOOTING-PVA-SYNC.md](TROUBLESHOOTING-PVA-SYNC.md)
- **Cloud flows not appearing** → Check "Admin | Sync Template v4 (Cloud flows)"

All sync flows use incremental inventory by default.

---

## When to Seek Additional Help

If you've tried all solutions above and desktop flows still aren't appearing:

1. ✅ **Check GitHub Issues**: Search for [similar issues](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+desktop+flow+inventory)
2. ✅ **Open a New Issue**: Include:
   - CoE Starter Kit version
   - Screenshots of flow run history
   - Screenshots of `List_Envt_Desktop_Flows` output
   - Environment configuration details
   - Whether full inventory was run
3. ✅ **CoE Community**: Join [CoE Starter Kit community calls](https://aka.ms/coeofficehours)

---

**Document Version:** 1.0  
**Last Updated:** February 2026  
**Related Documentation:**
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Troubleshooting PVA Sync](TROUBLESHOOTING-PVA-SYNC.md)
