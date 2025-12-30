# CoE Starter Kit - Notification Flows Guide

## Overview

The CoE Starter Kit includes several flows that send automatic email notifications to users and admins. These flows are designed to help with governance and compliance, but they are now **disabled by default** to give organizations full control over when and how they implement these notifications.

## Important Change (December 2025 Update)

**Previous Behavior (versions prior to December 2025):**
- Notification flows were enabled by default when installing or upgrading the CoE Starter Kit
- This caused unexpected emails to be sent to employees after upgrades

**Current Behavior (December 2025 and later):**
- All notification flows are now **disabled by default**
- Administrators must explicitly enable the flows they want to use
- This gives organizations full control over their communication with makers and users

## Notification Flows

### Inactivity Notifications (Audit Components)

These flows identify and notify owners of unused Power Platform resources:

1. **Admin | Inactivity notifications v2 (Start Approval for Apps)** - Identifies unused apps and asks owners if they can be deleted
2. **Admin | Inactivity notifications v2 (Start Approval for Flows)** - Identifies unused flows and asks owners if they can be deleted
3. **Admin | Inactivity notifications v2 (Check Approval)** - Processes approval responses
4. **Admin | Inactivity notifications v2 (Clean Up and Delete)** - Deletes approved resources
5. **Admin | Email Managers Ignored Inactivity notifications** - Notifies managers of ignored notifications

**Email Subject Example:** "Note from your Power Platform Admin: This flow appears to be unused; can we delete?"

**Trigger:** Weekly recurrence (Monday)

### Compliance Detail Request Flows (Core Components)

These flows request compliance information from makers:

1. **Admin | Compliance Details Request eMail (Apps)** - Requests compliance details for apps
2. **Admin | Compliance Details Request eMail (Chatbots)** - Requests compliance details for chatbots
3. **Admin | Compliance Details Request eMail (Custom Connectors)** - Requests compliance details for custom connectors
4. **Admin | Compliance Details Request eMail (Desktop Flows)** - Requests compliance details for desktop flows
5. **Admin | Compliance Details Request eMail (Flows)** - Requests compliance details for cloud flows
6. **Admin | Compliance detail request v3** - Main orchestration flow for compliance requests

**Email Subject Example:** "Note from your Power Platform Admin: Submit compliance details for your chatbot"

**Trigger:** When the Admin Risk Assessment State is modified on resources

### Orphaned Objects Reassignment Flows (Audit Components)

These flows handle resources left by users who have left the organization:

1. **Request Orphaned Objects Reassigned (Parent)** - Identifies orphaned objects and notifies managers
2. **Request Orphaned Objects Reassigned (Child)** - Processes reassignment for each manager

**Email Subject Example:** "Note from your Power Platform Admin: Your employees have stale Power Platform objects"

**Trigger:** Weekly recurrence

## How to Enable Notification Flows

If you want to use these notification flows, follow these steps:

### Option 1: Enable via Power Automate Portal

1. Go to [Power Automate](https://make.powerautomate.com)
2. Select your CoE environment
3. Navigate to **Solutions** → **Center of Excellence - Core Components** or **Center of Excellence - Audit Components**
4. Find the flow you want to enable (see flow names above)
5. Click on the flow name
6. Click **Turn on** in the command bar
7. Configure any required settings (connection references, environment variables, etc.)

### Option 2: Enable via Setup Wizard (Recommended)

The CoE Starter Kit includes setup wizards that can help you configure notification flows:

1. Open the **CoE Setup Wizard** app
2. Navigate to the **Inactivity Process** or **Compliance** section
3. Follow the wizard to configure and enable the flows
4. The wizard will guide you through setting up:
   - Email templates and styling
   - Thresholds for compliance (e.g., number of days since last use)
   - Approval workflows
   - Admin contact information

## Configuration Best Practices

Before enabling notification flows:

1. **Review Email Templates**: Customize the email content to match your organization's tone and branding
2. **Set Appropriate Thresholds**: Configure environment variables to define what constitutes "inactive" or "non-compliant"
3. **Test with a Small Group**: Enable flows for a pilot group before rolling out organization-wide
4. **Communicate with Makers**: Let your maker community know about the notification process in advance
5. **Configure Admin Contacts**: Set the `admin_AdminMail` environment variable to ensure admin notifications go to the right place

## Key Environment Variables

- `admin_AdminMail` - Email address for admin notifications
- `admin_ComplianceAppsNumberDaysSincePublished` - Days threshold for app compliance
- `admin_ComplianceAppsNumberUsersShared` - User count threshold for app compliance
- `admin_ComplianceAppsNumberLaunchesLast30Days` - Launch count threshold for app compliance

## Troubleshooting

### I'm getting unexpected emails after upgrading

If you upgraded from a version prior to December 2025 and started receiving emails:

1. The flows were enabled by default in previous versions
2. To stop the emails immediately, disable the flows using the steps above
3. When you're ready to use them, re-enable with proper configuration

### How do I customize the email content?

1. Open the flow in edit mode
2. Find the "Send email" action
3. Modify the subject and body as needed
4. Use environment variables like `admin_eMailBodyStart`, `admin_eMailHeaderStyle`, and `admin_eMailBodyStop` for consistent branding
5. Save and test the flow

### The flows are failing

Common issues:
- **Missing connections**: Ensure all connection references are properly configured
- **Permission issues**: The flow owner needs appropriate admin permissions
- **Missing environment variables**: Configure all required environment variables in the solution

## Learn More

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Governance Processes](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)

## Support

For issues or questions:
- Review the [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- Check [existing discussions](https://github.com/microsoft/coe-starter-kit/discussions)
- Submit a new issue using the appropriate template

**Note**: The CoE Starter Kit is provided as-is and is not covered by Microsoft support. Community support is available via GitHub.
