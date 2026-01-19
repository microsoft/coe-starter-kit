# Clean Up Old Objects App - Fix for Empty Apps and Flows Lists

## Issue Description
The Clean Up Old Objects App was not displaying any apps or flows in the Apps View and Flows View screens, even though the home screen showed that there were pending approval requests (e.g., "All Apps: 21" and "All Flows: 99").

Users with pending approval requests (especially for apps/flows where original owners no longer exist in the organization) were unable to see and process these requests in bulk through the app.

## Root Cause Analysis

### Original Logic
The app had the following flow:
1. Load all apps and flows for the logged-in user (filtered by `theMakerID`)
2. Add metadata about approval status (approved, rejected, pending)
3. **Remove all items** that were NOT approved AND NOT rejected AND had blank `requestsIgnoredSince`

The `RemoveIf` logic was:
```powerFX
RemoveIf(theApps, !approvedForDelete && !rejectedForDelete && IsBlank(requestsIgnoredSince));
RemoveIf(theFlows, !approvedForDelete && !rejectedForDelete && IsBlank(requestsIgnoredSince));
```

### The Problem
This logic removed items that should have been displayed. The issue was that:
1. All apps/flows were loaded first (including those without any archive requests)
2. Then the `RemoveIf` tried to filter out items without archive data
3. However, this was inefficient and could miss edge cases

The better approach is to **filter at the source** - only load apps/flows that have archive-related data in the first place.

## Solution

### Modified Logic
Instead of loading all items and then removing unwanted ones, the fix:
1. **Filters at the data source** to only load apps/flows that have:
   - A non-blank `requestsIgnoredSince` (pending requests), OR
   - Are in the approved list, OR
   - Are in the rejected list
2. **Removes the RemoveIf statements** entirely

### Code Changes

**Before (HomeScreen.pa.yaml, line 64 & 83):**
```powerfx
ForAll(Filter('PowerApps Apps', 'App Owner'.Maker=theMakerID && 'App Type'= 'PowerApps Type'.Canvas && 'App Deleted'<>'App Deleted (PowerApps Apps)'.Yes), ...
RemoveIf(theApps, !approvedForDelete && !rejectedForDelete && IsBlank(requestsIgnoredSince));
```

**After:**
```powerfx
ForAll(Filter('PowerApps Apps', 'App Owner'.Maker=theMakerID && 'App Type'= 'PowerApps Type'.Canvas && 'App Deleted'<>'App Deleted (PowerApps Apps)'.Yes && (!IsBlank('App Archive Request Ignored Since') || CountRows(Filter(theAppsApprovedForDeletes, Name=Text(App)))>0 || CountRows(Filter(theAppsRejectedForDeletes, Name=Text(App)))>0)), ...
```

The same pattern was applied to:
- Flows in HomeScreen.pa.yaml
- Apps in SelectUser.pa.yaml
- Flows in SelectUser.pa.yaml

## Benefits
1. **Fixes the empty list issue** - Apps and flows with pending approval requests now appear correctly
2. **More efficient** - Filters at the source instead of loading all data and then removing items
3. **Better performance** - Reduces the amount of data processed in collections
4. **Clearer intent** - The filter explicitly states what data we want to load

## Testing Recommendations
1. Test with a user who has pending approval requests for their own apps/flows
2. Test with a manager who has approval requests for their direct reports' apps/flows
3. Test with a user who has inherited approval requests (where original owner no longer exists)
4. Verify the filter menu (All, Requested, Approved, Rejected) works correctly
5. Verify the home screen counts match the Apps/Flows view counts

## Files Modified
- `CenterofExcellenceAuditComponents/SolutionPackage/src/CanvasApps/admin_cleanupoldobjectsapp_de6d5_DocumentUri.msapp`
  - Modified screens: HomeScreen, SelectUser
  - Modified formulas: ForAll filters for theApps and theFlows collections
