# Upgrade Notes - December 2025 Release

## CoE Starter Kit December 2025 Release

### Versions
- **CoE Core Components**: 4.50.7
- **CoE Audit Components**: 3.27.6

## Important: Automatic Email Notifications

### ⚠️ Action Required After Upgrade

After upgrading to this release, you may notice that notification and governance flows are enabled in your environment. This can result in automatic emails being sent to Power Platform users in your organization.

### What Changed?

Some notification and governance flows may be automatically enabled during the upgrade process. Once enabled, these flows will:
- Evaluate existing inventory data
- Send emails to users based on compliance and governance rules
- Trigger inactivity notifications
- Request compliance details for apps, flows, and chatbots

### Who Is Affected?

Organizations that:
- Upgraded from CoE Core Components version 4.50.6 or earlier to 4.50.7
- Upgraded from CoE Audit Components version 3.27.5 or earlier to 3.27.6
- Have existing Power Platform resources in their inventory
- Did not previously have these notification flows enabled

### Types of Emails Sent

Users may receive emails such as:
- "Note from your Power Platform Admin: This flow appears to be unused; can we delete?"
- "Note from your Power Platform Admin: Submit compliance details for your chatbot"
- "Note from your Power Platform Admin: Your employees have stale Power Platform objects"

### Immediate Action Steps

If you want to **stop automatic emails** while maintaining CoE Starter Kit functionality:

1. Navigate to [make.powerapps.com](https://make.powerapps.com)
2. Select your CoE environment
3. Go to **Solutions**
4. Disable the notification flows listed in the [troubleshooting guide](TROUBLESHOOTING-AUTOMATIC-NOTIFICATIONS.md)

For detailed instructions, see: [Troubleshooting: Automatic Email Notifications After Upgrade](TROUBLESHOOTING-AUTOMATIC-NOTIFICATIONS.md)

### What Still Works After Disabling Flows?

After disabling these notification flows, the following CoE Starter Kit features continue to work normally:
- ✅ Inventory collection
- ✅ Power BI dashboards
- ✅ CoE apps (Admin Command Center, Power Platform Admin View, etc.)
- ✅ Manual governance and monitoring
- ✅ Compliance and reporting views

Only automatic email notifications to end users will be stopped.

### Planning to Use Notification Features?

If you want to use these governance and notification features:

1. **Review configuration first**: Ensure notification thresholds and rules align with your governance policies
2. **Test in a non-production environment**: Validate behavior before enabling in production
3. **Communicate with users**: Inform your organization about the governance policies and notifications they will receive
4. **Enable gradually**: Turn on flows incrementally to manage the impact

### Related Documentation

- [Troubleshooting: Automatic Email Notifications](TROUBLESHOOTING-AUTOMATIC-NOTIFICATIONS.md)
- [CoE Starter Kit Setup Guide](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [CoE Starter Kit After Setup](https://docs.microsoft.com/power-platform/guidance/coe/after-setup)
- [Governance Components Overview](https://docs.microsoft.com/power-platform/guidance/coe/governance-components)

## Questions or Issues?

If you experience issues or have questions:
1. Review the [troubleshooting guide](TROUBLESHOOTING-AUTOMATIC-NOTIFICATIONS.md)
2. Check [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
3. Submit a new issue at [aka.ms/coe-starter-kit-issues](https://aka.ms/coe-starter-kit-issues)
