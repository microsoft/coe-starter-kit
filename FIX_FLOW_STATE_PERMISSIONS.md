# Fix: Flow State Display Issue in CoE Admin Command Center

## Issue
Users with System Administrator role in the CoE environment were unable to see the correct state of flows in the CoE Admin Command Center app. All flows appeared as "Off" (turned off) even when they were actually running, while the service account that installed the CoE could see the correct states.

## Root Cause
The canvas app "CoE Admin Command Center – CoE Flows" (`admin_commandcentercoeflowspage_bd424_DocumentUri.msapp`) was using `PowerAutomateManagement.AdminGetFlow()` to retrieve flow states.

The `AdminGetFlow()` API requires:
1. Tenant admin or environment admin permissions, AND
2. Owner or co-owner permissions on each specific flow

When non-service-account users (even with System Administrator role) accessed the app, they would fail the permission check on flows they didn't own, causing the error handler to return a default "Stopped" state.

## Solution
Changed the canvas app to use `PowerAutomateManagement.GetFlow()` instead of `AdminGetFlow()`.

The `GetFlow()` API respects the user's permissions to the flow:
- Returns flow state for flows the user owns, co-owns, or has been granted access to
- Works correctly for users with appropriate flow-level permissions
- Does not require admin-level access to each individual flow

## Files Changed
- `CenterofExcellenceCoreComponents/SolutionPackage/src/CanvasApps/admin_commandcentercoeflowspage_bd424_DocumentUri.msapp`
  - Screen1.fx.yaml: Line 97 changed from `AdminGetFlow` to `GetFlow`

## Impact
After this fix:
- Users with System Administrator role who have been granted access to CoE flows will see the correct flow states
- The app will respect the user's actual permissions to view flow information
- No longer requires users to be owners of every CoE flow to see their states

## Deployment
This fix will be included in the next release of the CoE Starter Kit. Users can:
1. Wait for the next official release and upgrade their solution
2. Import the updated solution from this repository

## Additional Notes
There was a commented-out line in the original code suggesting this was a known issue:
```
//    theState: IfError(PowerAutomateManagement.GetFlow(CoE_Envt, ThisRecord.theGUID).properties.state, "Error"), //switch to this so Admin SR can use
```

This fix implements that suggested change.

## Related Issues
- Issue: [CoE Starter Kit - BUG] Flow states showing incorrectly for non-service-account users
- Version: 5.40.6
- Solution: Core
- Component: CoE Admin Command Center – CoE Flows
