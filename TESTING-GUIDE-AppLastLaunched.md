# Testing and Deployment Guide

## Summary of Changes

This fix addresses the mismatch between the CoE Starter Kit Dashboard (Power BI) and the PowerApps App table's "App Last Launched On" field.

### What Was Changed
- Modified the `AdminAuditLogsUpdateDataV2` flow in the CoE Core Components solution
- Added explicit retrieval of the audit log's `admin_creationtime` field
- Updated all references to use the explicitly retrieved value instead of relying on trigger outputs

### Why This Fixes The Issue
The Dataverse webhook trigger may not reliably include all custom fields in its output payload. By explicitly retrieving the audit log record using the GetItem operation, we ensure we always have the correct event timestamp (when the app was actually launched) rather than potentially using the record creation time in Dataverse.

## Deployment Steps

### Option 1: Deploy Full Solution Update
1. Import the updated CoE Core Components solution (version 4.50.7 or later)
2. Follow the standard upgrade process as documented in the CoE Starter Kit documentation
3. Ensure all flows are turned on after the import

### Option 2: Manual Flow Update (Advanced)
If you have customizations and cannot import the full solution:

1. Open the `Admin | Audit Logs - Update Data V2` flow in your CoE environment
2. Edit the flow
3. In the `Update_Data` → `Derive_and_Update_App_Data` scope:
   - Add a new action after `AppID` called `Get_Audit_Log_Creation_Time`
   - Use the "Get a row by ID" action (Dataverse connector)
   - Set:
     - Table: Audit Logs (`admin_auditlogs`)
     - Row ID: `@triggerOutputs()?['body/admin_auditlogid']`
     - Select columns: `admin_creationtime`
   - Configure retry policy: Exponential, 10 attempts, 10 second interval
4. Update the `GetApp` action to run after `Get_Audit_Log_Creation_Time` instead of `AppID`
5. In the `Update_Last_Launched_if_newer` condition, replace both instances of `@triggerOutputs()?['body/admin_creationtime']` with `@outputs('Get_Audit_Log_Creation_Time')?['body/admin_creationtime']`
6. Save the flow

## Testing Steps

### 1. Verify Flow Operation
1. Navigate to the CoE environment in Power Automate
2. Open the `Admin | Audit Logs - Update Data V2` flow
3. Check the run history to ensure it's running successfully
4. Open a recent successful run and verify:
   - The `Get_Audit_Log_Creation_Time` action completed successfully
   - The `Update_App_Last_Launch_Date` action ran and updated the app record
   - Check the outputs to confirm the timestamp looks correct

### 2. Test with a Real App Launch
1. Launch a PowerApp that has auditing enabled
2. Wait for the audit log sync flow to process the event (usually 15-30 minutes)
3. Wait for the `Admin | Audit Logs - Update Data V2` flow to trigger
4. Check the flow run history for any errors
5. Verify the app's `admin_applastlaunchedon` field was updated:
   - Go to the PowerApps App table in Dataverse
   - Find your app
   - Check the "App Last Launched On" field
   - It should match the time you launched the app

### 3. Verify Dashboard Consistency
1. Open the CoE Starter Kit Dashboard in Power BI
2. Navigate to the "App Deep Dive" tab
3. Find the app you tested with
4. Compare the "Latest Launched on" date with the "App Last Launched On" in the Dataverse table
5. They should now match (within a few minutes of sync time)

## Troubleshooting

### Flow Fails with "Record Not Found"
**Cause**: The audit log record ID in the trigger is incorrect or the record was deleted.

**Resolution**: 
- Check that the `Admin | Audit Logs - Sync Audit Logs V2` flow is running correctly
- Verify audit log records are being created in Dataverse
- Check that records are not being automatically deleted by retention policies

### App Last Launched Date Still Not Updating
**Possible Causes**:
1. The `Admin | Audit Logs - Update Data V2` flow is disabled
   - **Resolution**: Enable the flow
2. The flow is failing but errors are not visible
   - **Resolution**: Check flow analytics and error logs in the Flow run history
3. Auditing is not enabled for PowerApps in your tenant
   - **Resolution**: Enable auditing in the Microsoft 365 Security & Compliance Center
4. The app record in Dataverse is missing or has incorrect data
   - **Resolution**: Run a full inventory sync using the `Admin | Sync Template v4 (Apps)` flow

### Dashboard Still Shows Different Dates
**Cause**: Power BI cache or the dashboard is using a different data source.

**Resolution**:
- Refresh the Power BI dataset
- Check if the dashboard is using a different measure or table for "Latest Launched on"
- Verify the Power BI data source connections are correct

## Expected Behavior After Fix

1. When a user launches a PowerApp:
   - Audit event is captured in Microsoft 365
   - `Admin | Audit Logs - Sync Audit Logs V2` creates a record in Dataverse with the correct event time
   - `Admin | Audit Logs - Update Data V2` is triggered
   - The flow explicitly retrieves the audit log's `admin_creationtime`
   - If this time is newer than the app's current `admin_applastlaunchedon`, it updates the field

2. The PowerApps App table in Dataverse will have accurate "App Last Launched On" dates
3. The CoE Dashboard will show consistent "Latest Launched on" dates that match the table

## Performance Impact

- **Additional API Call**: One extra Dataverse GetItem call per app launch event
- **Impact**: Negligible - the flow already makes multiple API calls and has retry policies
- **Benefit**: More reliable data synchronization

## Rollback Procedure

If you need to roll back this change:

1. Export the current version of your CoE Core Components solution as a backup
2. Reimport the previous version (4.50.6 or earlier)
3. Or manually remove the `Get_Audit_Log_Creation_Time` action and revert the references back to `@triggerOutputs()?['body/admin_creationtime']`

## Support

If you continue to experience issues after applying this fix:
1. Check the flow run history for detailed error messages
2. Review the troubleshooting steps above
3. Open a new issue on the CoE Starter Kit GitHub repository with:
   - Flow run history screenshots
   - Error messages
   - Version information
   - Steps you've already tried
