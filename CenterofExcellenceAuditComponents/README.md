# Center of Excellence - Audit Components

This solution contains audit and governance components for the CoE Starter Kit, including inactivity notification flows and compliance management features.

## Components

### Flows

#### Inactivity Notification Flows
- **Admin | Inactivity Notifications v2 (Start Approval for Apps)** - Identifies inactive Power Apps and starts approval processes
- **Admin | Inactivity Notifications v2 (Start Approval for Flows)** - Identifies inactive Power Automate flows and starts approval processes
- **Admin | Inactivity Notifications v2 (Check Approval)** - Checks approval status and takes action
- **Admin | Inactivity Notifications v2 (Clean Up and Delete)** - Cleans up and deletes approved inactive resources

### Environment Variables

Key environment variables used by this solution:

- **InactivityNotifications-PastTime-Interval** (`admin_ArchivalPastTimeInterval`)
  - Controls how far back to look for inactive resources
  - Default: 6
  - Type: Decimal number

- **InactivityNotifications-PastTime-Unit** (`admin_ArchivalPastTimeUnit`)
  - The time unit for the interval (Day, Week, Month, Year)
  - Default: Month
  - Type: Text

## Common Issues

### Environment Variables Not Reflecting in Flows

If you update environment variable values and they don't appear to take effect in the flows:

**This is a known behavior.** Power Automate flows cache environment variable values and do not automatically refresh when you republish customizations.

**Solution:** See the [Troubleshooting Environment Variables Guide](../TROUBLESHOOTING-ENVIRONMENT-VARIABLES.md) for detailed resolution steps.

**Quick Fix:**
1. Turn off the affected flow
2. Turn on the affected flow
3. The flow will now use the updated environment variable values

## Documentation

For complete setup and configuration instructions, see:
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Governance Components Documentation](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)

## Support

For issues or questions:
1. Check the [Troubleshooting Guide](../TROUBLESHOOTING-ENVIRONMENT-VARIABLES.md)
2. Review [existing GitHub issues](https://github.com/microsoft/coe-starter-kit/issues)
3. Create a [new issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) if needed
