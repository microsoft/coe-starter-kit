# Bug Fix: App Last Launched Date Mismatch

## Issue Description
Users reported a mismatch between the "Latest Launched on" date shown in the CoE Starter Kit Dashboard (Power BI) and the "App Last Launched On" date stored in the PowerApps App table in Dataverse.

### Symptoms
- Power BI Dashboard shows newer launch dates for apps
- Dataverse table (admin_App.admin_applastlaunchedon) shows older dates
- The mismatch persists even though audit flows are running successfully

## Root Cause
The `AdminAuditLogsUpdateDataV2` flow was relying on `@triggerOutputs()?['body/admin_creationtime']` to retrieve the audit event's creation time from the trigger payload. However, Dataverse webhook triggers may not reliably include all custom fields in the trigger output, potentially causing the flow to use incorrect timestamp values or fail to retrieve the field entirely.

## Solution
Added an explicit action `Get_Audit_Log_Creation_Time` that retrieves the audit log record using the Dataverse connector's GetItem operation, specifically selecting the `admin_creationtime` field. This ensures we always have the correct event timestamp when updating the app's last launched date.

### Changes Made
1. **New Action**: Added `Get_Audit_Log_Creation_Time` action that explicitly retrieves the audit log record
   - Runs after the `AppID` action succeeds
   - Uses GetItem operation on `admin_auditlogs` entity
   - Selects only the `admin_creationtime` field for efficiency
   - Includes retry policy for resilience

2. **Updated Dependencies**: Modified `GetApp` action to run after `Get_Audit_Log_Creation_Time` instead of directly after `AppID`

3. **Updated References**: Changed all references from `@triggerOutputs()?['body/admin_creationtime']` to `@outputs('Get_Audit_Log_Creation_Time')?['body/admin_creationtime']` in:
   - The comparison condition that checks if the new date is newer
   - The update action that sets `admin_applastlaunchedon`

## Impact
- **Positive**: Ensures accurate "App Last Launched On" dates in the Dataverse table
- **Positive**: Resolves mismatch between dashboard and table data  
- **Performance**: Adds one additional Dataverse API call per app launch event (negligible impact given retry policies already exist)
- **Compatibility**: Fully backward compatible; no breaking changes to data model or API contracts

## Testing Recommendations
1. Monitor the `AdminAuditLogsUpdateDataV2` flow run history to ensure it completes successfully
2. Compare "Latest Launched On" dates in Power BI dashboard with `admin_applastlaunchedon` values in Dataverse
3. Verify that app launch events from the audit log correctly update the app records
4. Check that the flow's error handling still works correctly if the audit log record is not found

## Related Files
- `/CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminAuditLogsUpdateDataV2-1D8BF7B1-D787-EE11-8179-000D3A3411D9.json`

## Version
Fixed in CoE Starter Kit Core Components version 4.50.7 (pending release)

## Additional Notes
This fix addresses the data synchronization issue but does not change how the Power BI dashboard queries data. The dashboard may query the audit log table directly for some visualizations, which is expected behavior. After applying this fix, both data sources should show consistent values.
