# Flow State Visibility Fix - CoE Admin Command Center

## Issue Description
Users with System Administrator role in the CoE environment were unable to see the correct flow state (On/Off) in the CoE Admin Command Center - CoE Flows page. All flows appeared as "Off" even when they were actually enabled, when viewed from non-service-account users.

## Root Cause
The CoE Flows page app was using the `PowerAutomateManagement.AdminGetFlow()` API to retrieve flow state information. This API requires **Power Platform Admin** permissions at the tenant level, not just System Administrator role in the CoE environment. 

Key findings:
- Service accounts used for CoE installation typically have Power Platform Admin permissions
- Regular users with only System Administrator role in the CoE environment lack these tenant-level admin permissions
- The AdminGetFlow API call would fail silently for non-admin users, defaulting flows to "Stopped" state

## Solution Implemented
The fix replaces the Power Automate Management connector API call with a direct read from the Dataverse `Processes` (workflow) table, which is accessible to users with System Administrator role in the CoE environment.

### Technical Details

**Before:**
```powerFX
theState: IfError(PowerAutomateManagement.AdminGetFlow(CoE_Envt, ThisRecord.theGUID).properties.state, "Err"),
```

**After:**
```powerFX
theState: If(First(Filter(Processes, 'Workflow Unique Identifier'= GUID(ThisRecord.theGUID))).'Status Reason' = 'Status Reason (Processes)'.'On', "Started", "Stopped"),
```

### Benefits of This Approach
1. **No admin permissions required**: Users only need System Administrator role in the CoE environment
2. **More reliable**: Reads directly from Dataverse, eliminating API permission issues
3. **Better performance**: Single Dataverse query instead of multiple API calls
4. **Consistent with existing pattern**: The app already uses the Processes table for checking unmanaged layers

## Files Modified
- `CenterofExcellenceCoreComponents/SolutionPackage/src/CanvasApps/admin_commandcentercoeflowspage_bd424_DocumentUri.msapp`

## Testing Recommendations
1. Test with a service account that has Power Platform Admin permissions
2. Test with a user account that has only System Administrator role in the CoE environment
3. Verify that flow states (On/Off) display correctly for both user types
4. Test the "Turn On/Off" flow functionality to ensure it still works

## Permission Requirements
After this fix, users accessing the CoE Admin Command Center - CoE Flows page need:
- **System Administrator** security role in the CoE environment
- **No tenant-level admin permissions required**

## Additional Notes
- The app still uses `PowerAutomateManagement.ListFlowsInEnvironment()` for retrieving newly published flow GUIDs, which does not require admin permissions
- The "Turn On/Off" functionality uses Dataverse Patch operations on the Processes table, which works with System Administrator role
- This fix aligns with the commented suggestion in the original code (line 95) to switch from AdminGetFlow to a non-admin approach

## Related Issues
This fix resolves permission-based visibility issues where non-admin users could not see flow states correctly in the CoE Admin Command Center.
