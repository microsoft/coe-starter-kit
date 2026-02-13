# Troubleshooting: Deleted Status Reset Issue

## Issue Description

### Symptom
The "Flow Deleted" field (or "App Deleted" field) in the CoE Starter Kit inventory tables changes back to "No" after being marked as "Deleted" by the CLEANUP flows.

### Specific Behavior Observed
1. The CLEANUP flow runs (e.g., Sunday) and correctly marks deleted flows/apps with `admin_flowdeleted = true` or `admin_appdeleted = true`
2. The next day (e.g., Monday morning), the status changes back to "No" (`admin_flowdeleted = false`)
3. The "Flow Modified On" or "App Modified On" field shows an update timestamp
4. Re-running the CLEANUP flow marks them as deleted again, but the cycle repeats

## Root Cause

The issue was caused by the SYNCHELPER flows unconditionally resetting the deleted status fields when updating inventory metadata:

- **SYNCHELPER-CloudFlows**: When inventorying flows, it explicitly set `admin_flowdeleted: false` during record updates
- **SYNCHELPER-Apps**: When inventorying apps, it explicitly set `admin_appdeleted: false` during record updates

### Why This Happened
The regular inventory sync runs daily (or more frequently) and processes all flows/apps to update their metadata (display name, connections, modified date, etc.). As part of these updates, the SYNCHELPER flows were resetting the deleted status fields, overwriting the markers set by the CLEANUP flows.

## Solution

The fix removes the explicit reset of deleted status fields from the SYNCHELPER flows' update operations.

### Files Modified
1. **SYNCHELPER-CloudFlows-A44274DF-02DA-ED11-A7C7-0022480813FF.json**
   - Removed: `"item/admin_flowdeleted": false,`
   - Removed: `"item/admin_flowdeletedon": "@null",`
   - From two update actions: "Upsert_Flow_record" and "Upsert_Flow_record_(creator_not_found)"

2. **SYNCHELPER-Apps-B677AA25-8DE4-ED11-A7C7-0022480813FF.json**
   - Removed: `"item/admin_appdeleted": false,`
   - Removed: `"item/admin_appdeletedon": "@null",`
   - From two update actions: "Upsert_App_record" and "Upsert_App_record_(creator_not_found)"

3. **AdminSyncTemplatev4Desktopflows-AF083528-7E73-EE11-9AE7-000D3A341FFF.json**
   - Removed: `"item/admin_rpadeleted": false,`
   - Removed: `"item/admin_rpadeletedon": "@null",`
   - From two update actions for desktop flows (RPA)

4. **AdminSyncTemplatev4ModelDrivenApps-7C7AC6E2-1B7C-EE11-8179-000D3A341FFF.json**
   - Removed: `"item/admin_appdeleted": false,`
   - Removed: `"item/admin_appdeletedon": "@null",`
   - From two update actions for model-driven apps

5. **AdminSyncTemplatev4CustomConnectors-AE1EF367-1B3E-EB11-A813-000D3A8F4AD6.json**
   - Removed: `"item/admin_connectordeleted": false,`
   - Removed: `"item/admin_connectordeletedon": "@null",`  
   - From eight update actions for custom connectors

6. **AdminSyncTemplatev4Portals-CEAD57C0-A080-EE11-8179-000D3A341FFF.json**
   - Removed: `"item/admin_portaldeleted": false,`
   - Removed: `"item/admin_portaldeletedon": "@null",`
   - From two update actions for portals

7. **AdminSyncTemplatev4Solutions-838B0BC0-8494-EE11-BE37-000D3A341B0E.json**
   - Removed: `"item/admin_solutiondeleted": false,`
   - Removed: `"item/admin_solutiondeletedon": "@null",`
   - From two update actions for solutions

8. **AdminSyncTemplatev4Driver-74157AA1-A8AC-EE11-A569-000D3A341D27.json**
   - Removed: `"item/admin_environmentdeleted": false,`
   - Removed: `"item/admin_environmentdeletedon": "@null",`
   - From two update actions for environments

9. **AdminSyncTemplatev4AiModels-E5601A14-5494-EE11-BE37-000D3A3411D9.json**
   - Removed: `"item/admin_aideleted": false,`
   - Removed: `"item/admin_aideletedon": "@null",`
   - From two update actions for AI models

10. **AdminSyncTemplatev4BusinessProcessFlows-6B10220E-5494-EE11-BE37-000D3A3411D9.json**
    - Removed: `"item/admin_businessprocessflowdeleted": false,`
    - Removed: `"item/admin_businessprocessflowdeletedon": "@null",`
    - From two update actions for business process flows

11. **AdminSyncTemplatev3FlowActionDetails-7EBB10A6-5041-EB11-A813-000D3A8F4AD6.json**
    - Removed: `"item/admin_flowactiondetaildeleted": false,`
    - Removed: `"item/admin_flowactiondetaildeletedon": "@null",`
    - From one update action for flow action details

### How It Works Now
After the fix:
1. ✅ When a flow/app is **successfully retrieved** from the API → The SYNCHELPER updates metadata BUT preserves the existing deleted status
2. ✅ When a flow/app **fails to retrieve** from the API (404 not found) → The SYNCHELPER correctly sets deleted status to `true`
3. ✅ The CLEANUP flows can mark items as deleted, and this status **persists** through inventory sync runs

## Verification Steps

After applying this fix, you can verify the solution works correctly:

1. **Delete a flow or app** from its original environment
2. **Run the CLEANUP flow** (CLEANUP – Admin | Sync Template v4 (Check Deleted))
3. **Verify** the flow/app is marked as deleted in the CoE inventory table:
   - Check `admin_flowdeleted = true` or `admin_appdeleted = true`
   - Check `admin_flowdeletedon` has a timestamp
4. **Wait for the next inventory sync** to run (or manually trigger it)
5. **Verify again** that the deleted status is **still true** (not reset to false)
6. **Check over multiple days** to ensure the status remains stable

## Technical Details

### Flow Execution Order
- **Inventory Sync** (AdminSyncTemplatev4Flows or AdminSyncTemplatev4Apps): Runs daily or triggered manually
  - Calls SYNCHELPER-CloudFlows or SYNCHELPER-Apps for each flow/app
  - Updates metadata: display name, connections, modified date, state, etc.
  
- **CLEANUP Flow** (CLEANUP – Admin | Sync Template v4 (Check Deleted)): Runs weekly (typically Sunday)
  - Calls CLEANUPHELPER flows for each entity type
  - Marks items that no longer exist in source environments as deleted

### Update Logic in SYNCHELPER Flows

**Before Fix:**
```json
{
  "item/admin_flowdeleted": false,
  "item/admin_flowdeletedon": "@null",
  "item/admin_displayname": "@outputs('Get_Flow_as_Admin')?['body/properties/displayName']",
  ...other fields...
}
```

**After Fix:**
```json
{
  "item/admin_displayname": "@outputs('Get_Flow_as_Admin')?['body/properties/displayName']",
  ...other fields...
  // admin_flowdeleted and admin_flowdeletedon are NOT included
  // This preserves their current values in the database
}
```

### Deletion Detection Logic (Unchanged)
The logic that sets items as deleted when they don't exist is still intact:
```json
// When Get_Flow_as_Admin or Get_App_as_Admin FAILS (404 error)
{
  "item/admin_flowdeleted": true,
  "item/admin_flowdeletedon": "@utcNow()"
}
```

## Impact Assessment

### What Changes
- Flows and apps marked as deleted will **stay deleted** until they are actually restored or the records are cleaned up
- The inventory sync will no longer reset deletion markers

### What Doesn't Change
- New flows/apps are still inventoried normally
- Existing flows/apps metadata updates work the same way
- The CLEANUP flow behavior is unchanged
- Detection of truly deleted items (when API returns 404) still works correctly

## Related Components

This fix addresses the issue for:
- ✅ Cloud Flows (Power Automate flows) - SYNCHELPER-CloudFlows
- ✅ Canvas Apps - SYNCHELPER-Apps  
- ✅ Model-driven Apps - AdminSyncTemplatev4ModelDrivenApps
- ✅ Desktop Flows (RPA) - AdminSyncTemplatev4Desktopflows
- ✅ Custom Connectors - AdminSyncTemplatev4CustomConnectors
- ✅ Portals - AdminSyncTemplatev4Portals
- ✅ Solutions - AdminSyncTemplatev4Solutions
- ✅ Environments - AdminSyncTemplatev4Driver
- ✅ AI Models - AdminSyncTemplatev4AiModels
- ✅ Business Process Flows - AdminSyncTemplatev4BusinessProcessFlows
- ✅ Flow Action Details - AdminSyncTemplatev3FlowActionDetails
- ℹ️ Power Virtual Agents (PVA) - Uses component state logic, not affected by this issue
- ℹ️ Other entity types without deleted tracking are not affected

## Upgrade Notes

If you are upgrading from a previous version:
1. Import the updated CoE Core Components solution
2. The SYNCHELPER flows will be updated automatically
3. No manual configuration changes required
4. Existing deletion markers will be preserved going forward

## Additional Resources

- CoE Starter Kit Documentation: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- Setup Instructions: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components
- GitHub Issues: https://github.com/microsoft/coe-starter-kit/issues
