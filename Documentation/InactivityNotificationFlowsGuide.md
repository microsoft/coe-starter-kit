# CoE Starter Kit - Inactivity Notification Flows Guide

## Overview

The **Governance Solution** in the CoE Starter Kit includes inactivity notification flows that help identify and manage unused Power Apps and Power Automate flows. This guide explains how these flows work, their lifecycle, and how to troubleshoot common issues.

## Table of Contents

1. [How Inactivity Notifications Work](#how-inactivity-notifications-work)
2. [The Flows Involved](#the-flows-involved)
3. [Archive Approval Table Lifecycle](#archive-approval-table-lifecycle)
4. [Common Scenarios Explained](#common-scenarios-explained)
5. [Troubleshooting Repeated Emails](#troubleshooting-repeated-emails)
6. [Best Practices](#best-practices)
7. [Configuration](#configuration)

---

## How Inactivity Notifications Work

The inactivity notification process helps administrators identify apps and flows that haven't been used in a specified period (default: 6 months) and gives makers an opportunity to either keep or delete them.

### High-Level Process

1. **Weekly Scan**: The system identifies all apps/flows not used in the past 6 months
2. **Approval Request**: Sends approval requests to app/flow owners asking them to confirm if they want to keep or delete the resource
3. **Daily Check**: Processes approval responses and updates records accordingly
4. **Manager Notification**: Notifies managers if their direct reports have ignored approval requests
5. **Cleanup**: After a specified period, deletes resources that were marked for deletion

---

## The Flows Involved

### 1. Admin | Inactivity notifications v2 - Start Approval for Apps

**Trigger**: Weekly (default: Monday)

**Purpose**: Identifies inactive apps and creates approval requests

**Key Actions**:
- Queries all apps not launched or modified in the past 6 months (configurable)
- Checks if an approval already exists (approved, rejected, or pending)
- Creates new approval requests only if:
  - No "Approve" response exists
  - No "Reject" response exists
  - Creates a record in the Archive Approval table
  - Sets `admin_apparchiverequestignoredsince` if the user hasn't responded

**Important**: This flow does NOT send duplicate approvals if a valid approval response already exists.

### 2. Admin | Inactivity notifications v2 - Start Approval for Flows

**Trigger**: Weekly (default: Monday)

**Purpose**: Same as above but for Power Automate flows

**Key Actions**: Similar to the Apps version but targets flows instead

### 3. Admin | Inactivity notifications v2 - Check Approval

**Trigger**: Daily

**Purpose**: Processes approval responses and updates records

**Key Actions**:
- Checks for approval responses from the last 10 days
- Updates Archive Approval records with the response (Approve/Reject)
- **Clears** `admin_apparchiverequestignoredsince` when a response is received
- Sends notifications to admins when resources are rejected

**Critical**: This flow runs daily to ensure responses are processed promptly.

### 4. Admin | Email Managers - Ignored Inactivity notifications - Apps

**Trigger**: Weekly

**Purpose**: Notifies managers when their direct reports ignore approval requests

**Key Actions**:
- Queries apps where `admin_apparchiverequestignoredsince` is older than the configured threshold
- Groups by manager
- Sends summary emails to managers

**Note**: This will continue to send emails weekly until the employee responds to the approval.

### 5. Admin | Inactivity notifications v2 - Clean Up and Delete

**Trigger**: Weekly

**Purpose**: Deletes apps/flows that were marked for deletion after a grace period

**Key Actions**:
- Finds approval records with "Reject" responses older than 21 days (configurable)
- Deletes the apps/flows
- Cleans up Archive Approval records

---

## Archive Approval Table Lifecycle

The `admin_archiveapprovals` table is central to the inactivity notification process. Here's how records flow through this table:

### Lifecycle Stages

#### Stage 1: Approval Created (Week 1)
```
Status: Pending (admin_approvalresponse = null)
Action: Email sent to app/flow owner
App Record: admin_apparchiverequestignoredsince = [creation date]
```

#### Stage 2A: User Approves (Keeps the App/Flow)
```
Status: Approved (admin_approvalresponse = 'Approve')
Action: Check Approval flow processes response
App Record: admin_apparchiverequestignoredsince = null (cleared)
Result: No further emails sent; app/flow is kept
Cleanup: Other pending approvals for this app/flow are deleted
```

The approved record stays in the Archive Approval table indefinitely. The Start Approval flow checks for existing approved records and skips creating new approvals.

**Duration**: Indefinite (until app/flow becomes active again or is manually deleted)

#### Stage 2B: User Rejects (Deletes the App/Flow)
```
Status: Rejected (admin_approvalresponse = 'Reject')
Action: Check Approval flow processes response
App Record: admin_apparchiverequestignoredsince = null (cleared)
Result: 21-day grace period begins
Admin Notified: Email sent to admin about rejection
Cleanup: Other pending approvals for this app/flow are deleted
```

After 21 days, the Clean Up flow deletes the app/flow and the Archive Approval record.

**Duration**: 21 days (then deleted)

#### Stage 2C: User Ignores the Request
```
Status: Pending (admin_approvalresponse = null)
Action: Nothing (approval remains pending)
App Record: admin_apparchiverequestignoredsince = [original creation date]
Result: Manager notification emails sent weekly
```

The approval remains in pending status indefinitely until the user responds.

**Duration**: Indefinite (until user responds)

---

## Common Scenarios Explained

### Scenario 1: First Run - All Inactive Apps Get Emails

**What Happens**:
- Start Approval flow runs for the first time
- Identifies all apps/flows not used in 6 months
- Sends approval requests to all owners
- Creates records in Archive Approval table

**Expected**: This is normal for the first run. Everyone with inactive apps will receive an email.

### Scenario 2: User Clicks "Keep This App" with Justification

**What Should Happen**:
1. User responds "Approve" with business justification
2. Check Approval flow (runs daily) picks up the response
3. Archive Approval record updated with response and comment
4. `admin_apparchiverequestignoredsince` is cleared on the app record
5. **No further emails sent** for this app (approval record exists with "Approve" status)

**Next Week**: Start Approval flow queries inactive apps, finds the existing "Approve" record, and skips this app.

**If User Receives Another Email**: See [Troubleshooting](#troubleshooting-repeated-emails) section.

### Scenario 3: User Ignores the Approval Request

**What Happens**:
1. Approval remains in pending status
2. `admin_apparchiverequestignoredsince` remains set
3. Manager notification flow detects ignored request
4. **Manager receives weekly emails** until employee responds

**To Stop Manager Emails**: Employee must respond to the approval request (either Approve or Reject).

### Scenario 4: App Becomes Active Again

**What Happens**:
- If an app that was previously approved/rejected becomes inactive again in the future, the cycle can restart
- The flow logic checks for existing approvals, but if the app's last modified/launched date is still old, it may create a new cycle

**Expected Behavior**: This is by design. If an app remains inactive despite being "kept," it will eventually trigger new notifications.

---

## Troubleshooting Repeated Emails

If users are receiving repeated inactivity emails even after approving/rejecting, check the following:

### Issue 1: Check Approval Flow Not Running

**Symptom**: Users respond to approvals, but continue receiving emails

**Root Cause**: The daily Check Approval flow is turned off or failing

**Solution**:
1. Go to Power Automate in your CoE environment
2. Find flow: `Admin | Inactivity notifications v2 - Check Approval`
3. Check if it's turned on
4. Review run history for failures
5. Turn it on if disabled; fix any errors if failing

### Issue 2: Timing Mismatch Between Flows

**Symptom**: User responds on Sunday, but receives another email on Monday

**Root Cause**: Start Approval flow runs before Check Approval flow processes the response

**Solution**:
- **Immediate**: Manually run the Check Approval flow before the Start Approval flow runs
- **Long-term**: Adjust the schedule of the Start Approval flow to run later in the week (e.g., Wednesday or Thursday) to give Check Approval more time to process weekend responses

### Issue 3: Approval Responses Not Syncing

**Symptom**: Responses are recorded in the Approvals system but not in Archive Approval table

**Root Cause**: The Check Approval flow's connection to Dataverse or Approvals connector is broken

**Solution**:
1. Check connection references in the Check Approval flow
2. Ensure the Dataverse and Approvals connectors are authenticated
3. Re-test the connections
4. Turn the flow off and back on to refresh connections

### Issue 4: Archive Approval Records Not Being Cleared

**Symptom**: Old approved/rejected records remain in the Archive Approval table

**Root Cause**: This is expected behavior for "Approve" responses. "Reject" responses are cleared after the app is deleted.

**Solution**: This is by design. Approved records stay to prevent duplicate approvals. No action needed.

### Issue 5: Manager Emails Continue After User Response

**Symptom**: Manager still receives weekly emails even though employee responded

**Root Cause**: The `admin_apparchiverequestignoredsince` field wasn't cleared properly

**Solution**:
1. Check the Archive Approval record - does it have a response?
2. Check the app record - is `admin_apparchiverequestignoredsince` null?
3. If not null but response exists, manually clear the field or re-run Check Approval flow
4. Check the "Clear_Ignored_Since" action in the Check Approval flow for errors

### Issue 6: Multiple Approval Requests for Same App

**Symptom**: User receives multiple approval emails for the same app in the same week

**Root Cause**: 
- Multiple Archive Approval records were created (shouldn't happen)
- Flow ran multiple times due to retries

**Solution**:
1. Check Archive Approval table for duplicate records
2. Delete duplicate records manually
3. Review Start Approval flow run history for multiple executions
4. Check if someone is manually triggering the flow

---

## Best Practices

### 1. **Communicate Before Enabling**

Before enabling inactivity flows, communicate with your organization:
- Explain the purpose of inactivity notifications
- Provide a timeline (when emails will start)
- Share guidance on how to respond
- Clarify what happens if they approve vs. reject

### 2. **Start with a Test Group**

- Enable flows for a small group first
- Monitor for issues
- Gather feedback
- Adjust configuration if needed
- Roll out to the entire organization

### 3. **Configure the Inactivity Threshold Appropriately**

The default is 6 months. Consider:
- **3 months**: More aggressive cleanup, more frequent notifications
- **6 months**: Balanced approach (recommended)
- **12 months**: Less aggressive, fewer notifications

Set via environment variable: `InactivityNotifications-PastTime-Interval`

### 4. **Monitor Flow Run History**

Regularly check:
- Start Approval flows: Ensure they run weekly without errors
- Check Approval flow: Ensure it runs daily and processes responses
- Manager notification flow: Review email volume
- Clean Up flow: Verify apps/flows are being deleted as expected

### 5. **Review Archive Approval Data**

Periodically review the Archive Approval table:
- How many pending approvals exist?
- How many approved vs. rejected?
- Are there old pending approvals (> 30 days)?
- Follow up with makers who haven't responded

### 6. **Adjust the Cleanup Grace Period**

The default grace period before deletion is 21 days. You can adjust this in the Clean Up flow logic if needed.

### 7. **Excuse Critical Apps from Archival**

For apps that should never be deleted (even if inactive):
1. Set `admin_appexcusedfromarchival = true` on the app record
2. Or set `admin_excusefromarchivalflows = true` on the environment record

### 8. **Set Up the Clean Up App**

Deploy the **App and Flow Archive and Clean Up View** app:
- Provides a UI for makers to view and respond to approvals
- Easier than navigating email links
- Shows all pending approvals in one place

Configure via environment variable: `CleanUpAppURL`

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `InactivityNotifications-PastTime-Interval` | 6 | How many time units to look back |
| `InactivityNotifications-PastTime-Unit` | Month | Time unit (Day, Week, Month, Year) |
| `admin_AdminMail` | (required) | Admin email for notifications |
| `admin_ProductionEnvironment` | true | If false, sends emails to admin instead of makers (for testing) |

### Flow Schedules

| Flow | Default Schedule | Recommendation |
|------|-----------------|----------------|
| Start Approval for Apps | Weekly (Monday) | Keep weekly; consider mid-week (Wednesday) |
| Start Approval for Flows | Weekly (Monday) | Keep weekly; consider mid-week (Wednesday) |
| Check Approval | Daily | Keep daily for timely processing |
| Email Managers | Weekly | Keep weekly |
| Clean Up and Delete | Weekly | Keep weekly |

### Testing in Non-Production

To test without sending emails to actual makers:
1. Set `admin_ProductionEnvironment = false`
2. All approval emails will go to `admin_AdminMail` instead
3. Test the full lifecycle
4. Set back to `true` before production rollout

---

## Frequently Asked Questions

### Q1: Why do manager emails keep coming even after the employee responded?

**A**: There may be a timing issue or the `admin_apparchiverequestignoredsince` field wasn't cleared. Check the Archive Approval record and ensure the Check Approval flow is running daily.

### Q2: How long does an "Approve" response last?

**A**: Indefinitely. Once approved, the app won't receive new inactivity notifications as long as the Archive Approval record with "Approve" status exists.

### Q3: Can users change their response from "Keep" to "Delete"?

**A**: Not directly through the approval. They would need to contact the admin to update the Archive Approval record manually, or wait for the existing approval to be deleted and a new cycle to start.

### Q4: What happens if an app owner leaves the organization?

**A**: 
- The approval email will fail to deliver
- The app may be flagged as orphaned
- Use the orphaned resources flows to reassign ownership
- The new owner will receive the approval request

### Q5: Can I customize the email templates?

**A**: Yes! The flows use customizable email templates from the `admin_customizedemails` table. You can modify these templates or create localized versions.

### Q6: How do I stop the inactivity process entirely?

**A**: Turn off all five flows mentioned in this guide. However, this is not recommended as it defeats the purpose of governance.

### Q7: Why did I receive an email for an app I use regularly?

**A**: The inactivity check is based on:
- **Last Modified Date**: When the app definition was last changed
- **Last Launched Date**: When the app was last opened

If you use the app but haven't modified it, it may still trigger if "Last Launched Date" isn't being tracked properly. This can happen if analytics aren't enabled or if the app is embedded.

**Solution**: Respond with "Keep" and provide justification. The app will be excused from future notifications.

> **📖 Note**: The "Last Launched Date" field requires Office 365 Audit Logs to be enabled and configured. If you're seeing empty "App Last Launched On" dates, see [QUICKREF-APP-LAST-LAUNCHED-EMPTY.md](../docs/QUICKREF-APP-LAST-LAUNCHED-EMPTY.md) for setup instructions.

---

## Additional Resources

- **Official Documentation**: [Microsoft Power Platform CoE Starter Kit - Governance Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/governance-components)
- **App Last Launched Troubleshooting**: [Quick Reference Guide](../docs/QUICKREF-APP-LAST-LAUNCHED-EMPTY.md) | [Detailed Analysis](../ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md)
- **GitHub Issues**: [Report issues or ask questions](https://github.com/microsoft/coe-starter-kit/issues)
- **Community Forum**: [Power Apps Governance and Administration](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

## Summary

The inactivity notification flows provide a powerful governance mechanism, but they require proper configuration and monitoring. Key takeaways:

1. **The cycle works as designed** when all flows are enabled and running on schedule
2. **Users should respond promptly** to avoid manager notifications
3. **Approved responses are stored indefinitely** to prevent duplicate emails
4. **Rejected responses trigger a 21-day grace period** before deletion
5. **Timing matters**: Ensure Check Approval runs before Start Approval in the weekly cycle
6. **Communication is critical**: Users need to understand the process

By following the best practices and troubleshooting guidance in this document, you can successfully implement and manage the inactivity notification process in your organization.

---

*Last updated: January 2026*
*CoE Starter Kit Version: January 2026*
