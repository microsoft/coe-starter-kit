# Quarantine Email Notification Fix

## Problem Description

Users were receiving repeated email notifications stating that an app has been released from quarantine (or quarantined), even when the quarantine status hadn't actually changed.

## Root Cause Analysis

The issue occurred due to the interaction between two workflows:

1. **SYNCHELPER-Apps** workflow regularly syncs app data from Power Apps API to Dataverse, including the `admin_appisquarantined` field
2. **Admin | Set app quarantine status** workflow is triggered whenever the `admin_appisquarantined` field is modified

The problem sequence:
1. An app gets released from quarantine (manually or automatically)
2. The workflow sends a "released from quarantine" email
3. The workflow clears the `admin_quarantineappdate` field
4. Later, the SYNCHELPER-Apps workflow runs and updates the `admin_appisquarantined` field based on the current API status
5. Even though the status didn't change, updating the field triggers the workflow again
6. The workflow sends another "released from quarantine" email

This created a loop where emails were sent every time the sync ran, even when no actual status change occurred.

## Solution

The fix adds conditional checks before sending emails to ensure they are only sent when an actual status change has occurred:

### For Release from Quarantine Emails
- **Condition**: Only send email if `admin_quarantineappdate` is NOT null
- **Logic**: If the quarantine date exists, it means the app was previously quarantined, so a release notification is appropriate
- **Result**: No email is sent if the app was never quarantined or if a release email was already sent

### For Quarantine Emails
- **Condition**: Only send email if `admin_quarantineappdate` IS null
- **Logic**: If the quarantine date doesn't exist, it means the app is being quarantined for the first time
- **Result**: No email is sent if the app was already quarantined and a notification was already sent

## Changes Made

### Modified File
- `CenterofExcellenceAuditComponents/SolutionPackage/src/Workflows/AdminSetappquarantinestatus-957255CE-1B93-EC11-B400-000D3A8FC5C7.json`

### Specific Changes

1. **Updated Get_App action** to include `admin_quarantineappdate` in the select query:
   ```json
   "$select": "admin_displayname, admin_appdeleted,admin_appisquarantined,admin_quarantineappdate"
   ```

2. **Added conditional check for release emails**:
   - New action: `Check_if_app_was_previously_quarantined`
   - Condition: `admin_quarantineappdate` is NOT null
   - Only sends release email if this condition is met

3. **Added conditional check for quarantine emails**:
   - New action: `Check_if_app_was_not_previously_quarantined`
   - Condition: `admin_quarantineappdate` IS null
   - Only sends quarantine email if this condition is met

## Expected Behavior After Fix

### Scenario 1: App is quarantined for the first time
- ✅ Quarantine email IS sent (date is null, condition met)
- ✅ `admin_quarantineappdate` is set to current date/time
- ✅ Future sync runs will NOT trigger another email (date is no longer null)

### Scenario 2: App is released from quarantine
- ✅ Release email IS sent (date exists, condition met)
- ✅ `admin_quarantineappdate` is cleared (set to null)
- ✅ Future sync runs will NOT trigger another email (date is now null)

### Scenario 3: Sync runs without status change
- ✅ No email is sent (conditions prevent duplicate notifications)
- ✅ Workflow still updates other fields as needed

## Testing Recommendations

1. **Test quarantine flow**:
   - Mark an app for quarantine
   - Verify single email is sent
   - Run sync multiple times
   - Confirm no duplicate emails

2. **Test release flow**:
   - Release an app from quarantine
   - Verify single email is sent
   - Run sync multiple times
   - Confirm no duplicate emails

3. **Test edge cases**:
   - Apps that were never quarantined
   - Apps that were quarantined multiple times historically
   - Apps in testing environments (non-production)

## Benefits

- ✅ Eliminates duplicate email notifications
- ✅ Reduces inbox clutter for makers and admins
- ✅ Maintains accurate quarantine status tracking
- ✅ No impact on existing quarantine/release functionality
- ✅ Minimal changes to workflow logic

## Backward Compatibility

This fix is fully backward compatible:
- Existing apps with quarantine dates will work correctly
- Apps without quarantine dates will work correctly
- No database schema changes required
- No changes to external APIs or integrations
