# How to Fix: Admin | Set app quarantine status Flow to Prevent Duplicate Emails

## Overview

This document provides step-by-step instructions to modify the **Admin | Set app quarantine status** flow to prevent duplicate email notifications.

## Problem

The flow triggers whenever the `admin_appisquarantined` field is modified, even if the value hasn't actually changed. This causes duplicate email notifications when the **Admin | Sync Template v4 (Apps)** flow updates app records during daily sync operations.

## Solution

Add deduplication logic to check if a notification was recently sent before sending another one.

## Prerequisites

- Access to the CoE Starter Kit environment
- Security role with permissions to edit flows
- Understanding of Power Automate flow modifications

## Implementation Steps

### Step 1: Add Tracking Field to admin_app Table

1. Navigate to Power Apps (https://make.powerapps.com)
2. Select your CoE environment
3. Go to **Tables** > **admin_app**
4. Click **+ New** > **Column**
5. Create a new column with these settings:
   - **Display name**: Last Quarantine Notification Date
   - **Name**: `admin_lastquarantinenotificationdate`
   - **Data type**: Date and Time
   - **Format**: Date and time
   - **Behavior**: User local
   - **Description**: Tracks when the last quarantine status notification was sent to prevent duplicate emails
6. Click **Save**

### Step 2: Modify the Flow - Add Variable

1. Navigate to Power Automate (https://flow.microsoft.com)
2. Select your CoE environment
3. Find and edit the flow: **Admin | Set app quarantine status**
4. Find the action **Initialize emailGUID** (at the top of the flow)
5. After this action, add a new action: **Initialize variable**
   - **Name**: `ShouldSendNotification`
   - **Type**: Boolean
   - **Value**: `true`

### Step 3: Modify Get_App Action

1. Find the action **Get App** in the flow
2. Edit the action
3. In the **Select columns** field, add: `admin_lastquarantinenotificationdate`
   - Current: `admin_displayname, admin_appdeleted, admin_appisquarantined`
   - Updated: `admin_displayname, admin_appdeleted, admin_appisquarantined, admin_quarantineappdate, admin_lastquarantinenotificationdate`
4. Save the action

### Step 4: Add Deduplication Logic for Release Notification

1. Find the **Quarantine_or_Release** condition in the flow
2. In the **yes** branch (release branch), find the action **Get Row - Send an email - release** scope
3. Before the **Send an email - release** action, add a new **Condition** action:
   - **Name**: Check if notification already sent today
   - **Condition**:
     ```
     @or(
       empty(outputs('Get_App')?['body/admin_lastquarantinenotificationdate']),
       less(
         outputs('Get_App')?['body/admin_lastquarantinenotificationdate'],
         addDays(utcNow(), -1)
       )
     )
     ```
4. Move the **Send an email - release** action inside the **yes** branch of this new condition
5. In the **yes** branch, after sending the email, add an **Update a row** action:
   - **Table name**: admin_app
   - **Row ID**: `@triggerOutputs()?['body/admin_appid']`
   - **Last Quarantine Notification Date**: `@utcNow()`

### Step 5: Add Deduplication Logic for Quarantine Notification

1. In the **Quarantine_or_Release** condition, go to the **no** branch (quarantine branch)
2. Find the action **Get Row - Send an email - quarantine** scope
3. Before the **Send an email - quarantine** action, add a new **Condition** action:
   - **Name**: Check if notification already sent today - quarantine
   - **Condition**: Same as Step 4
4. Move the **Send an email - quarantine** action inside the **yes** branch of this new condition
5. In the **yes** branch, after sending the email, add an **Update a row** action:
   - **Table name**: admin_app
   - **Row ID**: `@triggerOutputs()?['body/admin_appid']`
   - **Last Quarantine Notification Date**: `@utcNow()`

### Step 6: Test the Fix

1. Save the flow
2. Test by manually updating an app's quarantine status:
   - First change: Should send email
   - Immediate second change with same status: Should NOT send email (already sent today)
   - Next day: Should send email again if status changes

## Alternative: Simpler Fix Using Quarantine Date

If you prefer a simpler approach that leverages the existing `admin_quarantineappdate` field:

### For Release Notifications:

Add a condition before sending the release email:
```
@empty(outputs('Get_App')?['body/admin_quarantineappdate'])
```

This checks if the quarantine date has already been cleared. If it's null, it means the app was just released.

### For Quarantine Notifications:

Add a condition before sending the quarantine email:
```
@greater(
  outputs('Get_App')?['body/admin_quarantineappdate'],
  addDays(utcNow(), -1)
)
```

This checks if the quarantine date was set within the last 24 hours.

## Rollback Instructions

If you need to rollback the changes:

1. Export a backup of the flow before making changes
2. To rollback:
   - Turn off the modified flow
   - Delete the modified flow
   - Reimport the original flow from your backup or solution

## Verification

After implementing the fix:

1. Monitor the flow run history for 3-5 days
2. Check email notifications received by app owners
3. Verify that duplicate emails have stopped
4. Confirm that legitimate status change notifications are still sent

## Additional Notes

- **Impact**: This change only affects email notifications, not the actual quarantine/release functionality
- **Performance**: Minimal performance impact - adds one condition check per run
- **Compatibility**: Compatible with all versions of CoE Starter Kit that include the Audit Components
- **Testing**: Thoroughly test in a development environment before deploying to production

## Support

If you encounter issues:
1. Review the flow run history for errors
2. Check the `admin_lastquarantinenotificationdate` field is being updated correctly
3. Ensure the field was added to the Get App action's select columns
4. Verify the conditions are evaluating correctly

For additional help, refer to [TROUBLESHOOTING-QUARANTINE-EMAILS.md](./TROUBLESHOOTING-QUARANTINE-EMAILS.md)
