# Troubleshooting: Automatic Email Notifications After Upgrade

## Issue Overview

After upgrading to CoE Starter Kit version 4.50.7 (Core Components) and 3.27.6 (Audit Components) released in December 2025, some users may experience automatic email notifications being sent to employees. These emails were not sent in previous versions.

## Affected Email Notifications

The following types of automatic emails may be triggered after the upgrade:

- "Note from your Power Platform Admin: This flow appears to be unused; can we delete?"
- "Note from your Power Platform Admin: Submit compliance details for your chatbot"
- "Note from your Power Platform Admin: Your employees have stale Power Platform objects"
- Other inactivity, compliance, and governance notifications

## Root Cause

During the upgrade to the December 2025 release, certain notification and governance flows may be automatically enabled in your environment. Once enabled, these flows immediately evaluate existing inventory and compliance data collected by the CoE Starter Kit and begin sending emails to end users based on configured thresholds and conditions.

This is expected behavior when these flows are enabled, but it can be unexpected if you were not planning to activate these governance features.

## Resolution

To continue using the CoE Starter Kit for manual monitoring and administration **without sending automatic emails**, you need to disable the notification flows.

### Step 1: Access the CoE Solutions

1. Navigate to [https://make.powerapps.com](https://make.powerapps.com)
2. Select your CoE environment from the environment picker
3. Go to **Solutions**
4. Open either **Center of Excellence – Core Components** or **Center of Excellence – Audit Components** depending on which flows you need to disable

### Step 2: Disable Notification Flows

#### Audit Components Solution

Turn **OFF** the following flows in the **Center of Excellence – Audit Components** solution:

- Admin | Inactivity notifications v2 (Start Approval for Apps)
- Admin | Inactivity notifications v2 (Start Approval for Flows)
- Admin | Inactivity notifications v2 (Check Approval)
- Admin | Inactivity notifications v2 (Clean Up and Delete)
- Admin | Email Managers Ignored Inactivity notifications
- Request Orphaned Objects Reassigned (Parent)
- Request Orphaned Objects Reassigned (Child)
- Microsoft Teams Admin | Ask for Business Justification
- Microsoft Teams Admin | Send Reminder Mail
- Microsoft Teams Admin | Weekly Clean Up of Microsoft Teams environments
- Admin | Quarantine non-compliant apps
- Admin | Set app quarantine status

#### Core Components Solution

Turn **OFF** the following flows in the **Center of Excellence – Core Components** solution:

- Admin | Compliance Details Request eMail (Apps)
- Admin | Compliance Details Request eMail (Chatbots)
- Admin | Compliance Details Request eMail (Custom Connectors)
- Admin | Compliance Details Request eMail (Desktop Flows)
- Admin | Compliance Details Request eMail (Flows)
- Admin | Compliance detail request v3

### Step 3: Verify

Once these flows are turned off:
- Automatic email notifications will stop immediately
- The CoE Starter Kit will continue to function normally for inventory visibility, reporting, and manual governance
- You can still use Power BI dashboards and apps for monitoring

## Enabling Notifications in the Future

If you want to enable these notification features in the future:

1. **Review the configuration**: Before enabling any notification flows, review their configuration to ensure they align with your governance policies
2. **Test in a non-production environment**: Consider testing the notification flows in a test environment first
3. **Communicate with users**: Inform your Power Platform users about the governance policies and what emails they might receive
4. **Enable gradually**: Turn on flows one at a time to better control the impact

## Related Documentation

- [CoE Starter Kit Setup](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [CoE Starter Kit After Setup](https://docs.microsoft.com/power-platform/guidance/coe/after-setup)
- [Governance Components](https://docs.microsoft.com/power-platform/guidance/coe/governance-components)
- [Core Components](https://docs.microsoft.com/power-platform/guidance/coe/core-components)

## Need More Help?

If you continue to experience issues:

1. Check the [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
2. Review the [CoE Starter Kit documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
3. Submit a new issue at [aka.ms/coe-starter-kit-issues](https://aka.ms/coe-starter-kit-issues)

## Version Information

This issue has been observed in:
- **CoE Core Components**: Version 4.50.7 (December 2025 release)
- **CoE Audit Components**: Version 3.27.6 (December 2025 release)

## Summary

Automatic email notifications after upgrading the CoE Starter Kit are expected when notification flows are enabled. To prevent these emails while maintaining other CoE functionality, disable the specific notification and governance flows listed above. The CoE Starter Kit will continue to collect inventory data and provide dashboards for manual monitoring without sending automated emails to end users.
