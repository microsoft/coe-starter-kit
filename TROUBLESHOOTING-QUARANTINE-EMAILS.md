# Troubleshooting: Repeated Quarantine Release Email Notifications

## Issue Description

Users receiving hundreds of duplicate email notifications stating that their app has been released from quarantine, with emails arriving daily or repeatedly for the same app.

Example email content:
```
Your app has been released from quarantine.

Your app compliance status has been reviewed, and the app has now been released
from quarantine. Users who you've shared your app with can now launch the app again.
```

## Root Cause

The repeated email notifications are caused by the interaction between two flows in the CoE Starter Kit:

1. **Admin | Sync Template v4 (Apps)** - Runs daily to sync app inventory from Power Platform
2. **Admin | Set app quarantine status** - Triggers when the `admin_appisquarantined` field is modified

### Technical Details

The `Admin | Set app quarantine status` flow uses a Dataverse trigger that monitors changes to the `admin_appisquarantined` field on the `admin_app` table:

```json
"triggers": {
  "When_a_row_is_added,_modified_or_deleted": {
    "type": "OpenApiConnectionWebhook",
    "inputs": {
      "parameters": {
        "subscriptionRequest/message": 3,
        "subscriptionRequest/entityname": "admin_app",
        "subscriptionRequest/filteringattributes": "admin_appisquarantined"
      }
    }
  }
}
```

During the daily sync, even if the quarantine status value hasn't changed, updating the record can trigger the Dataverse webhook, causing the notification email to be sent repeatedly.

## Solutions

### Solution 1: Add a "Last Notification Sent" Tracking Field (Recommended)

**Best for:** Production environments where you want to maintain email notifications but prevent duplicates.

**Implementation Steps:**

1. Add a new field to the `admin_app` table:
   - Field Name: `admin_lastquarantinenotificationdate`
   - Field Type: Date and Time
   - Description: "Tracks when the last quarantine status notification was sent"

2. Modify the **Admin | Set app quarantine status** flow:
   - Add a condition before sending email to check if notification was already sent today
   - Update the `admin_lastquarantinenotificationdate` field after sending email
   
   Example logic:
   ```
   IF (
     admin_lastquarantinenotificationdate is null 
     OR 
     admin_lastquarantinenotificationdate < Today
   ) THEN
     Send Email
     Update admin_lastquarantinenotificationdate to Now()
   END IF
   ```

### Solution 2: Modify the Trigger to Use Change Tracking

**Best for:** Environments where you can modify flow triggers and have change tracking enabled.

**Implementation Steps:**

1. Enable change tracking on the `admin_app` table if not already enabled
2. Modify the **Admin | Set app quarantine status** flow trigger to check if the value actually changed:
   - Add a "Get row" action to retrieve the previous value
   - Add a condition to compare old value vs new value
   - Only send email if the value has actually changed

### Solution 3: Disable Automatic Notifications

**Best for:** Environments that prefer manual notification control or don't need real-time notifications.

**Implementation Steps:**

1. Turn off the **Admin | Set app quarantine status** flow
2. Create a scheduled flow (weekly or as needed) that:
   - Queries apps where quarantine status changed recently
   - Sends batched notification emails
   - Marks apps as "notification sent"

### Solution 4: Modify Sync Flow to Only Update When Changed

**Best for:** Advanced users comfortable with flow modifications.

**Implementation Steps:**

1. Modify the **Admin | Sync Template v4 (Apps)** flow
2. Before updating the `admin_appisquarantined` field:
   - Compare the current Dataverse value with the API value
   - Only update the field if the values differ
3. This prevents unnecessary trigger firing

### Solution 5: Temporary Workaround - Turn Off the Flow

**Best for:** Immediate relief while planning a permanent solution.

**Implementation Steps:**

1. Navigate to Power Automate admin center
2. Find the flow: **Admin | Set app quarantine status**
   - Display Name: `Admin | Set app quarantine status`
   - Solution: `Center of Excellence - Audit Components`
3. Turn off the flow
4. **Note:** This will stop ALL quarantine notification emails, not just duplicates

## Prevention Best Practices

1. **Monitor Flow Run History**
   - Regularly check the **Admin | Set app quarantine status** flow run history
   - Look for patterns of repeated runs for the same app

2. **Use Environment Variables**
   - Configure the `ProductionEnvironment` variable correctly
   - In non-production environments, emails go to admins instead of makers

3. **Implement Deduplication Logic**
   - Always include timestamp-based deduplication for notification flows
   - Consider using a notification tracking table

4. **Test Changes in Development**
   - Test flow modifications in a development environment first
   - Verify that notifications are sent only when appropriate

## Identifying Affected Apps

To identify which apps are triggering repeated notifications:

1. Navigate to the **Admin | Set app quarantine status** flow
2. View the run history (last 28 days)
3. Export the run history to Excel
4. Group by App ID to identify apps with multiple runs
5. Investigate why these apps are being updated repeatedly

## Related Flows

The following flows interact with the quarantine functionality:

- **Admin | Quarantine non-compliant apps** - Marks apps for quarantine after x days of non-compliance
- **Admin | Set app quarantine status** - Executes quarantine/unquarantine and sends notifications
- **Admin | Sync Template v4 (Apps)** - Syncs app inventory including quarantine status
- **SYNC HELPER - Apps** - Helper flow that updates app records with current status

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Compliance Process Documentation](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

## Support

If you continue to experience issues after implementing these solutions:

1. Check for similar issues in the [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. Create a new issue with:
   - Solution version
   - Steps already attempted
   - Flow run history screenshots
   - Number of duplicate emails received

## Version History

- **2026-01-06**: Initial documentation created
