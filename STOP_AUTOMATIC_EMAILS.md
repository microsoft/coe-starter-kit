# Immediate Fix: Stop Automatic Emails After CoE Update

## Problem

After upgrading to CoE Starter Kit version 4.50.7 (Core Components) or 3.27.6 (Audit Components) in December 2025, you may be experiencing thousands of automatic emails being sent to your employees with subjects like:

- "Note from your Power Platform Admin: This flow appears to be unused; can we delete?"
- "Note from your Power Platform Admin: Submit compliance details for your chatbot"
- "Note from your Power Platform Admin: Your employees have stale Power Platform objects"

## Immediate Solution

To stop these emails **immediately**, follow these steps:

### Step 1: Access Your CoE Environment

1. Go to [Power Automate](https://make.powerautomate.com)
2. Switch to your CoE environment (the environment where you installed the CoE Starter Kit)

### Step 2: Disable Inactivity Notification Flows (Audit Components)

Navigate to **Solutions** → **Center of Excellence - Audit Components** and disable these flows:

1. **Admin | Inactivity notifications v2 (Start Approval for Apps)**
2. **Admin | Inactivity notifications v2 (Start Approval for Flows)**
3. **Admin | Inactivity notifications v2 (Check Approval)**
4. **Admin | Inactivity notifications v2 (Clean Up and Delete)**
5. **Admin | Email Managers Ignored Inactivity notifications**

**To disable each flow:**
- Click on the flow name
- Click the three dots (...) or **Turn off** button
- Confirm the action

### Step 3: Disable Compliance Request Flows (Core Components)

Navigate to **Solutions** → **Center of Excellence - Core Components** and disable these flows:

1. **Admin | Compliance Details Request eMail (Apps)**
2. **Admin | Compliance Details Request eMail (Chatbots)**
3. **Admin | Compliance Details Request eMail (Custom Connectors)**
4. **Admin | Compliance Details Request eMail (Desktop Flows)**
5. **Admin | Compliance Details Request eMail (Flows)**
6. **Admin | Compliance detail request v3**

### Step 4: Disable Orphaned Objects and Microsoft Teams Governance Flows (Audit Components)

Navigate to **Solutions** → **Center of Excellence - Audit Components** and disable these flows:

1. **Request Orphaned Objects Reassigned (Parent)**
2. **Request Orphaned Objects Reassigned (Child)**
3. **Microsoft Teams Admin | Ask for Business Justification when Microsoft Teams environment is created**
4. **Microsoft Teams Admin | Send Reminder Mail**
5. **Microsoft Teams Admin | Weekly Clean Up of Microsoft Teams environments** (⚠️ This can delete environments!)
6. **Admin | Quarantine non-compliant apps** (⚠️ This can quarantine apps!)

### Step 5: Verify Flows Are Disabled

Check the flow status to ensure all notification flows show "Off" or "Suspended"

## Why Did This Happen?

In versions prior to December 2025, these notification flows were enabled by default. During an upgrade, they were automatically activated, causing emails to be sent without prior configuration or notification.

## Future Upgrades

Starting with the next release after December 2025, these flows will be **disabled by default**. You will need to explicitly enable them when you're ready to use them.

## Next Steps

Once the immediate issue is resolved:

1. **Plan Your Governance Strategy**: Decide which notification flows align with your governance goals
2. **Configure Settings**: Set up environment variables and email templates to match your organization's needs
3. **Pilot Test**: Enable flows for a small group first
4. **Communicate**: Inform your maker community about upcoming notifications
5. **Enable Gradually**: Turn on flows one at a time to ensure they work as expected

See [NOTIFICATION_FLOWS_GUIDE.md](./NOTIFICATION_FLOWS_GUIDE.md) for detailed configuration guidance.

## Additional Help

If you continue to experience issues:
- Check the [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- Review the [official documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- File a new issue with details about your specific situation

## Contact for Current Issue

If you're experiencing this issue after the December 2025 update and need help:
1. Disable the flows immediately using the steps above
2. File an issue on GitHub with:
   - Your current version numbers
   - When the upgrade occurred
   - How many emails were sent
   - Which flows are causing issues
