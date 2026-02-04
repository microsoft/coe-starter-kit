# GitHub Issue Response - Inactivity Notification Emails

This template can be used when responding to issues related to repeated inactivity notification emails, manager notifications, or questions about the Archive Approval lifecycle.

---

## Template: Repeated Inactivity Emails After Approval

**Use when:** Users report receiving repeated inactivity emails even after clicking "Keep this App/Flow" or providing justification

**Response:**

Thank you for your question about the inactivity notification flows in the Governance Solution!

### Quick Answer

The behavior you're experiencing is typically caused by one of these issues:

1. **Timing mismatch**: The weekly "Start Approval" flow runs before the daily "Check Approval" flow processes your response
2. **Check Approval flow not running**: The flow that processes approval responses is turned off or failing
3. **Connection issues**: The Check Approval flow's connections need to be refreshed

### How It's Supposed to Work

Here's the expected lifecycle:

**Week 1: Approval Created**
- Start Approval flow identifies your inactive app/flow
- Sends you an approval request email
- Creates a record in the Archive Approval table

**Your Response: "Keep this App"**
- You respond "Approve" with business justification
- Check Approval flow (runs **daily**) picks up your response within 24 hours
- Updates the Archive Approval record with your response
- Clears the tracking field (`admin_apparchiverequestignoredsince`)

**Week 2 and Beyond: No More Emails**
- Start Approval flow runs again
- Checks for existing approval responses
- Finds your "Approve" response
- **Skips your app** - no new email sent

### Troubleshooting Steps

Please try the following:

#### Step 1: Verify Check Approval Flow is Running

1. Go to Power Automate in your CoE environment
2. Search for: `Admin | Inactivity notifications v2 - Check Approval`
3. Check if the flow is **turned on**
4. Review the **run history** - does it run daily? Are there any failures?
5. If it's off, turn it on. If there are failures, check the error details.

#### Step 2: Check Your Approval Response

1. Go to Dataverse in your CoE environment
2. Open the **Archive Approval** table (`admin_archiveapprovals`)
3. Find the record for your app (search by app name or your email)
4. Check the `admin_approvalresponse` field:
   - Should be "Approve" if you clicked "Keep"
   - Should be "Reject" if you clicked "Delete"
   - If it's empty (null), your response wasn't processed

#### Step 3: Verify Timing

If you responded late in the week (e.g., Sunday) and received another email on Monday:
- This is a timing issue
- The Start Approval flow runs **weekly** (default: Monday)
- The Check Approval flow runs **daily** but may not have processed your weekend response yet

**Recommendation**: Adjust the Start Approval flow schedule to run mid-week (Wednesday or Thursday) to allow more time for response processing.

### Complete Documentation

I've created a comprehensive guide that covers:
- The complete lifecycle of inactivity notifications
- Detailed explanations of all five flows involved
- Common scenarios and troubleshooting
- Best practices and FAQ

📖 **[Inactivity Notification Flows - Complete Guide](./InactivityNotificationFlowsGuide.md)**

### Specific Answers to Your Questions

> 1. How does the complete cycle work for the 1st instance and when does the 2nd cycle trigger?

**Answer**: 
- **First Instance**: Approval created → Email sent → User responds → Response processed daily → Archive Approval updated
- **Second Cycle**: Only triggers if the app remains inactive AND there's no existing "Approve" or "Reject" response
- **If Approved**: No second cycle - the approval record stays indefinitely to prevent duplicate emails
- **If Rejected**: App deleted after 21 days, then a new cycle could start if somehow the app reappears
- **If Ignored**: Approval remains pending; manager notifications sent weekly until user responds

> 2. What happens when the flow runs for 2nd and 3rd time after a user clicked "Keep"?

**Answer**: 
When the Start Approval flow runs again (2nd, 3rd, subsequent times), it:
1. Queries all inactive apps
2. Checks for existing Archive Approval records with "Approve" status
3. **Skips** apps that have been approved
4. Does NOT send new emails to users who already approved

If users ARE receiving new emails, this indicates the Check Approval flow didn't process the response properly (see troubleshooting above).

> 3. Why do manager notification emails trigger every week?

**Answer**: 
The "Email Managers - Ignored Inactivity notifications" flow is **designed** to send weekly emails to managers when:
- An employee has a pending (ignored) approval request
- The `admin_apparchiverequestignoredsince` field is set on the app record

**To stop manager emails**: The employee must respond to the approval (either Approve or Reject). Once they respond, the Check Approval flow clears the `admin_apparchiverequestignoredsince` field, and manager emails stop.

**If manager emails continue after employee response**: Check that the `admin_apparchiverequestignoredsince` field was properly cleared. See the troubleshooting guide.

> 4. Is there documentation or best practices?

**Answer**: 
Yes! Please review the **[Inactivity Notification Flows Guide](./InactivityNotificationFlowsGuide.md)** which covers:
- How to configure the flows
- Best practices for rollout
- Testing in non-production environments
- Communication strategies
- Flow schedules and recommendations
- When to excuse apps from archival

### Next Steps

1. ✅ Review the **[complete guide](./InactivityNotificationFlowsGuide.md)**
2. ✅ Check if the Check Approval flow is running daily
3. ✅ Verify approval responses are being recorded in the Archive Approval table
4. ✅ Consider adjusting the Start Approval flow schedule to avoid timing conflicts
5. ✅ Set `admin_ProductionEnvironment = false` to test in dev/test environments

### If Issues Persist

If you've tried the above and are still experiencing issues, please provide:
- Screenshots of the Check Approval flow run history
- Screenshot of an Archive Approval record showing the response
- Screenshot of the app record showing the `admin_apparchiverequestignoredsince` field value
- Timeline: When did the user respond? When did they receive the next email?

This will help us diagnose the specific issue.

---

## Template: Manager Notification Questions

**Use when:** Users ask why managers are receiving weekly emails

**Response:**

Thank you for asking about manager notifications in the inactivity flows!

### What's Happening

The **"Admin | Email Managers - Ignored Inactivity notifications"** flow is designed to notify managers when their direct reports **ignore** (don't respond to) inactivity approval requests.

**It runs weekly** and sends emails to managers if:
- An employee has a pending approval request
- The employee hasn't responded within the configured time period
- The `admin_apparchiverequestignoredsince` field is set on the app/flow record

### This is By Design ✅

Manager notifications are **intentional** and serve an important governance purpose:
- Encourages accountability
- Helps managers understand what their team is building
- Prompts action on abandoned resources

### How to Stop Manager Emails

Manager emails will stop automatically when:
1. **Employee responds** to the approval request (Approve or Reject)
2. Check Approval flow processes the response
3. The `admin_apparchiverequestignoredsince` field is cleared

### If Manager Emails Continue After Employee Response

This indicates a problem with the Check Approval flow. See the **[Troubleshooting Guide](./InactivityNotificationFlowsGuide.md#troubleshooting-repeated-emails)** for detailed steps.

### Best Practices

1. **Communicate the process** to both employees and managers before enabling
2. **Set clear expectations** about response timeframes
3. **Provide clear instructions** in the approval email on how to respond
4. **Monitor** the Archive Approval table for old pending requests
5. **Follow up** with employees who don't respond within 2-3 weeks

### Additional Resources

- **[Complete Inactivity Flows Guide](./InactivityNotificationFlowsGuide.md)**
- **[Microsoft Docs - Governance Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/governance-components)**

---

## Template: How Long Does an Approval Last?

**Use when:** Users ask about approval expiration or cleanup

**Response:**

Great question about the Archive Approval lifecycle!

### Approval Duration by Response Type

**"Approve" (Keep this App/Flow)**
- Duration: **Indefinite**
- The Archive Approval record stays in the table permanently
- Prevents duplicate approval requests
- The app/flow is excused from future inactivity notifications (as long as the approval exists)

**"Reject" (Delete this App/Flow)**
- Duration: **21 days** (grace period)
- After 21 days, the Clean Up flow deletes the app/flow
- The Archive Approval record is also deleted
- Admin receives notification when something is marked for deletion

**No Response (Ignored)**
- Duration: **Indefinite** (until user responds)
- Approval remains in "Pending" status
- Manager receives weekly notification emails
- Can be responded to at any time

### What Happens to Old Approvals?

- **Approved records**: Stay indefinitely (by design)
- **Rejected records**: Deleted after app/flow deletion (21 days)
- **Pending records**: Remain until responded to or manually cleaned up

### Can Approvals Be Manually Removed?

Yes, administrators can manually delete Archive Approval records from Dataverse. However:
- ⚠️ Deleting an "Approve" record may trigger new approval emails if the app is still inactive
- ⚠️ Only delete if you understand the implications

### See Also

- **[Archive Approval Table Lifecycle](./InactivityNotificationFlowsGuide.md#archive-approval-table-lifecycle)**
- **[Common Scenarios](./InactivityNotificationFlowsGuide.md#common-scenarios-explained)**

---

## Notes for Responders

### Key Points to Remember

1. **Be clear about the weekly/daily schedule**: Start Approval (weekly) vs. Check Approval (daily)
2. **Emphasize timing**: Responses may take up to 24 hours to process
3. **Manager emails are intentional**: They serve a governance purpose
4. **Link to the complete guide**: Don't try to explain everything in the issue - point to the documentation
5. **Ask for specifics**: If troubleshooting, get flow run history, table records, timelines

### Common Follow-up Questions

- "How do I turn off manager notifications?" → Explain the governance purpose, but yes, you can turn off the flow
- "Can I change the 6-month threshold?" → Yes, via `InactivityNotifications-PastTime-Interval` environment variable
- "Can I exclude certain apps?" → Yes, set `admin_appexcusedfromarchival = true`
- "Can I test this without sending real emails?" → Yes, set `admin_ProductionEnvironment = false`

### When to Escalate

Create a separate bug issue if:
- Check Approval flow is running successfully but responses aren't being recorded
- `admin_apparchiverequestignoredsince` isn't being cleared despite valid responses
- Multiple duplicate Archive Approval records are being created for the same app
- Flow is failing with connector or permission errors

---

**Template Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
