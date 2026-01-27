# FAQ: Inactivity Notifications for Governance

## Overview

This document addresses common questions about the Inactivity Notification flows in the CoE Starter Kit Governance solution (Audit Components), specifically the flows that help govern inactive Power Apps and Power Automate flows in your tenant.

---

## Common Questions

### Q: Which environments do the inactivity notification flows scan?

**A: The inactivity notification flows scan ALL environments in your tenant by default**, with the following exceptions:

The flows query the entire `admin_apps` (for apps) and `admin_flows` (for flows) tables, which contain inventory data from across your tenant. However, they **exclude** environments where:
- The environment has been deleted (`admin_environmentdeleted eq true`)
- The environment is marked to be excused from archival flows (`admin_excusefromarchivalflows eq true`)

#### How the Environment Table Relates

The Environment table in Dataverse stores metadata about your environments, including the `admin_excusefromarchivalflows` field. While you may only see a few environments populated in this table initially, the inventory flows populate all environments over time.

**Key Point:** The inactivity flows are **NOT limited to only environments you see selected in the Environment table**. They operate on all apps and flows across your entire tenant, filtering only by the `admin_excusefromarchivalflows` flag.

#### To Exclude Specific Environments from Inactivity Notifications:

1. Open the **Admin - Add Environment Properties** app (part of Core Components)
2. Find the environment you want to exclude
3. Set the **"Excuse from archival flows"** field to **Yes**
4. Save the record

Apps and flows in that environment will no longer be included in inactivity notification scans.

#### Filter Logic in the Flows

The **Admin | Inactivity notifications v2 (Start Approval for Apps)** flow uses this filter:
```
admin_AppEnvironment/admin_excusefromarchivalflows ne true 
and admin_AppEnvironment/admin_environmentdeleted ne true
```

The **Admin | Inactivity notifications v2 (Start Approval for Flows)** flow uses a similar filter for flow environments.

---

### Q: When `admin_ProductionEnvironment` is set to No, can I send approvals to my user account instead of the admin account?

**A: No, there is no direct configuration option to specify a different test user account.** However, you have several options:

#### Understanding the `admin_ProductionEnvironment` Variable

The `admin_ProductionEnvironment` environment variable controls whether the CoE Kit flows are running in a production or test/development mode:

- **When set to Yes (True)**: Approvals and notifications are sent to the actual resource owners (app/flow owners)
- **When set to No (False)**: Approvals and notifications are redirected to the admin account for testing purposes

This design prevents accidentally sending test notifications to real makers while you're testing the governance flows.

#### The Logic in the Inactivity Notification Flows

The flow checks this condition when determining the approval assignee:
```
IF isProd = False OR app is orphaned OR owner is service principal OR owner is null
THEN send approval to admin
ELSE send approval to actual owner
```

The admin email used is determined by the environment variable: **Admin eMail (admin_AdminMail)**

#### Options to Change the Test Recipient

**Option 1: Change the Admin eMail Environment Variable (Recommended)**
1. Go to the CoE Admin Command Center app or directly to the environment variables
2. Find the environment variable **Admin eMail (admin_AdminMail)**
3. Change the value from the current admin email to your desired test user email
4. Save the change
5. All flows will now send test notifications to this email address when `admin_ProductionEnvironment` is No

**Option 2: Set `admin_ProductionEnvironment` to Yes and Test with Real Owners**
- Set `admin_ProductionEnvironment` to Yes
- Create a few test apps/flows owned by your test account
- Mark them as inactive (don't launch them for the configured inactivity period)
- Let the flow run and you'll receive the actual approval
- **Caution:** This approach will send approvals to all real resource owners, not just your test account

**Option 3: Modify the Flow (Not Recommended)**
- You could manually edit the flow to add logic for a separate test user variable
- **Not recommended** because:
  - It will create an unmanaged layer on the flow
  - You won't receive future updates to this flow
  - It adds maintenance complexity

**Recommendation:** Use Option 1 and change the `admin_AdminMail` environment variable to your test user account during testing, then change it back to the actual admin email when moving to production.

---

### Q: How do I configure which apps and flows are considered "inactive"?

**A:** Use the **InactivityNotifications-PastTime-Interval (admin_ArchivalPastTimeInterval)** environment variable.

**Default Value:** 6 (months)

This variable controls how far back the flows look when checking the last launched date (for apps) or last run date (for flows).

**Example:**
- If set to 6: Apps that haven't been launched in the past 6 months are considered inactive
- If set to 3: Apps that haven't been launched in the past 3 months are considered inactive

**To Change:**
1. Open the environment variables in your CoE Kit environment
2. Find **InactivityNotifications-PastTime-Interval**
3. Set the desired number of months
4. Save the change

---

### Q: How do I prevent specific apps or flows from receiving inactivity notifications?

**A:** There are two ways to exclude resources from inactivity notifications:

#### Option 1: Excuse Individual Apps/Flows from Archival

1. Open the **Power Platform Admin View** model app (Core Components)
2. Navigate to Apps or Flows
3. Find the specific app or flow
4. Set the **"Excuse from archival"** field to **Yes**
5. Save the record

This app/flow will be excluded from future inactivity notification scans.

#### Option 2: Excuse an Entire Environment from Archival

Follow the steps in the first question above to set `admin_excusefromarchivalflows` to Yes for the environment.

---

### Q: What happens when an approval is ignored or no response is received?

**A:** The CoE Kit includes additional flows to handle ignored approvals:

- **Admin | Email Managers - Ignored Inactivity notifications (Apps)**
- **Admin | Email Managers - Ignored Inactivity notifications (Flows)**

These flows send escalation emails to managers of resource owners who haven't responded to inactivity notifications within a configured timeframe.

---

### Q: What happens if an approval is rejected?

**A:** When an owner approves to keep their app/flow:
- No action is taken; the resource continues to exist
- The approval record is marked as approved

When an owner rejects (chooses to archive):
- The **Admin | Inactivity notifications v2 (Clean Up and Delete)** flow is triggered
- Depending on your configuration, the app/flow may be:
  - Marked for deletion
  - Actually deleted
  - Shared with a designated admin/team before deletion

Check the cleanup flow configuration for your specific environment's behavior.

---

### Q: How often do the inactivity notification flows run?

**A:** By default, the inactivity notification flows are configured to run **weekly on Mondays**.

You can modify the schedule by:
1. Opening the flow in edit mode
2. Modifying the **Recurrence** trigger
3. Changing the frequency (Daily, Weekly, Monthly) and schedule
4. Saving the flow

**Best Practice:** Running weekly provides a good balance between staying current and not overwhelming users with notifications.

---

### Q: Can I customize the approval notification emails?

**A:** Yes, the flows contain HTML templates for the notification emails that can be customized.

The emails are composed using variables:
- `htmlHeader` - CSS styling
- `htmlBodyStart` - Opening HTML and header
- `htmlBodyStop` - Closing HTML

**To Customize:**
1. Edit the inactivity notification flow
2. Find the "Initialize" actions that set up the HTML variables
3. Modify the HTML/CSS to match your organization's branding
4. Test the changes thoroughly before deploying to production

**Caution:** Customizing the flow creates an unmanaged layer and you won't receive updates to the customized actions in future versions.

---

### Q: What data is needed for these flows to work?

**A:** The inactivity notification flows depend on data collected by the **Core Components** solution:

**Required Data:**
- Environment inventory (from Core sync flows)
- App inventory with launch dates (from Core sync flows)
- Flow inventory with run dates (from Core sync flows)
- User information (from Office 365 Users connector)

**Required Environment Variables:**
- `admin_ProductionEnvironment` - Production vs. test mode
- `admin_ArchivalPastTimeInterval` - How many months to look back
- `admin_AdminMail` - Admin email for test mode and orphaned resources
- `admin_PowerAppEnvironmentVariable` - Maker portal URL
- `admin_PowerAutomateEnvironmentVariable` - Flow management URL
- `admin_AdmineMailPreferredLanguage` - Language for admin notifications

**Setup Steps:**
1. Install and configure Core Components first
2. Run initial inventory sync (can take 24-48 hours)
3. Verify data is being collected in Dataverse
4. Install Audit Components (which includes inactivity notifications)
5. Configure environment variables
6. Test with `admin_ProductionEnvironment` set to No

---

### Q: Do these flows work for orphaned apps and flows (where the owner has left the organization)?

**A:** Yes! The flows have special logic to handle orphaned resources:

**For Orphaned Apps/Flows:**
- The flow detects when a user lookup (owner) returns 404 (user not found)
- It automatically marks the resource as orphaned
- Approvals are redirected to the admin account (`admin_AdminMail`)
- Variable `isReassigned` is set to `true` to indicate the approval was reassigned

**For Service Principal Owners:**
- Apps/flows owned by service principals are also redirected to admin
- This prevents sending approvals to non-user accounts

This ensures that cleanup can still happen even when the original owner is no longer available.

---

### Q: What connectors are required for the inactivity notification flows?

**A:** The following connectors are used:

1. **Dataverse** - To query apps, flows, environments, and approvals
2. **Office 365 Users** - To get user information and check if users still exist
3. **Approvals** - To create and manage approval requests
4. **Office 365 Outlook** (or equivalent) - To send email notifications

All of these are standard connectors included with most Microsoft 365 licenses.

---

### Q: Can I use custom approvals or integrate with another system?

**A:** Yes, but it requires flow customization:

The flows use the standard **Approvals** connector. You can modify the flows to:
- Send approvals to a custom system
- Use a different notification method (Teams, SharePoint, etc.)
- Integrate with ServiceNow, Jira, or other ticketing systems

**Important:** Any modifications create an unmanaged layer and prevent automatic updates to those flows.

---

### Q: How do I test the flows before going to production?

**A:** Follow this testing approach:

#### Step 1: Set Up Test Mode
1. Set `admin_ProductionEnvironment` to **No**
2. Set `admin_AdminMail` to your test user account (see question 2 above)

#### Step 2: Create Test Data
1. Create a test app or flow
2. Don't launch/run it for longer than your configured inactivity period
3. Wait for the inactivity flow to run (or manually trigger it)

#### Step 3: Verify Behavior
1. Check that you received the approval notification
2. Verify the approval links work correctly
3. Test both approve and reject actions
4. Confirm the cleanup flow behaves as expected

#### Step 4: Move to Production
1. Set `admin_ProductionEnvironment` to **Yes**
2. Set `admin_AdminMail` back to the actual admin email
3. Monitor the first few runs to ensure everything works correctly
4. Communicate with your maker community about the new governance process

---

### Q: What languages are supported for notifications?

**A:** The inactivity notification flows support multiple languages through the user's preferred language setting.

**How It Works:**
- The flow reads the user's `preferredLanguage` property from Azure AD/Office 365
- Email content is selected based on this language preference
- If the user's language is not set or not supported, it defaults to **en-US (English)**

**Admin Notifications:**
- Use the language specified in **Admin eMail Preferred Language (admin_AdmineMailPreferredLanguage)** environment variable
- Default: en-US

**Important Note:** While the CoE Starter Kit supports multiple languages for certain features, complete localization varies by component. Check the official documentation for the most current language support.

---

## Best Practices

### 1. **Start with Test Mode**
- Always test with `admin_ProductionEnvironment = No` first
- Use a small inactivity period (e.g., 1 month) for initial testing
- Gradually increase the period as you gain confidence

### 2. **Communicate with Makers**
- Announce the governance program before enabling inactivity notifications
- Provide clear guidance on what "inactive" means
- Explain how to request exceptions
- Share the approval process and timeline

### 3. **Configure Appropriate Thresholds**
- 6 months is a reasonable default for most organizations
- Consider your organization's app lifecycle
- Different thresholds may be appropriate for production vs. non-production environments

### 4. **Exclude Critical Environments**
- Set `admin_excusefromarchivalflows = Yes` for production environments if needed
- Consider excluding environments with business-critical apps
- Use the "Excuse from archival" flag for specific high-value resources

### 5. **Monitor and Refine**
- Review the first month of approvals to identify patterns
- Adjust thresholds based on feedback
- Track approval response rates
- Refine your exception criteria

### 6. **Plan for Orphaned Resources**
- Establish a process for reviewing orphaned app approvals
- Designate a team to handle resources with no clear owner
- Document decisions for future reference

---

## Troubleshooting

### Issue: No approvals are being created

**Check:**
1. Are there actually inactive apps/flows in your tenant?
2. Is the Core inventory sync running successfully?
3. Are there environments excluded via `admin_excusefromarchivalflows`?
4. Is the flow running successfully (check run history)?
5. Are there any errors in the flow run history?

### Issue: Approvals go to the wrong person

**Check:**
1. Is `admin_ProductionEnvironment` set correctly?
2. Is `admin_AdminMail` set to the correct email?
3. Is the owner information in the app/flow record correct?
4. Has the owner left the organization (404 lookup)?

### Issue: Apps are not being deleted after rejection

**Check:**
1. Is the **Admin | Inactivity notifications v2 (Clean Up and Delete)** flow turned on?
2. Check the cleanup flow run history for errors
3. Verify the flow has the necessary permissions
4. Confirm the approval record is properly linked to the app

### Issue: Getting duplicate approvals

**Check:**
1. Are you running multiple instances of the flow?
2. Check if the flow is being triggered more frequently than intended
3. Verify the `admin_apparchiverequestignoredsince` field is being updated properly

---

## Related Flows

The inactivity notification system includes several interconnected flows:

| Flow Name | Purpose | Frequency |
|-----------|---------|-----------|
| **Admin \| Inactivity notifications v2 (Start Approval for Apps)** | Identifies inactive apps and starts approval process | Weekly (default) |
| **Admin \| Inactivity notifications v2 (Start Approval for Flows)** | Identifies inactive flows and starts approval process | Weekly (default) |
| **Admin \| Inactivity notifications v2 (Check Approval)** | Checks status of pending approvals | Configured schedule |
| **Admin \| Inactivity notifications v2 (Clean Up and Delete)** | Executes cleanup for rejected approvals | When triggered |
| **Admin \| Email Managers - Ignored Inactivity notifications (Apps)** | Sends escalation emails for ignored app approvals | Configured schedule |
| **Admin \| Email Managers - Ignored Inactivity notifications (Flows)** | Sends escalation emails for ignored flow approvals | Configured schedule |

---

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Governance Components Documentation](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)
- [Audit Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Environment Variables Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-environment-variables)
- [App and Flow Lifecycle Management](https://learn.microsoft.com/power-platform/guidance/adoption/manage-app-lifecycle)

---

## Need Help?

If you have questions about inactivity notifications:

1. Review the official [CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. Search [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar questions
3. Ask questions in GitHub Issues using the Question template
4. Engage with the community in [Power Apps Community forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
5. Join [CoE Starter Kit Office Hours](https://aka.ms/coeofficehours)

---

**Applies to:** CoE Starter Kit Audit Components (Governance flows)  
**Version:** Updated for current releases (2024+)  
**Last Updated:** January 2026
