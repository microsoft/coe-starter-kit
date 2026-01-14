# Quick Reference: Disabling CoE Notification Flows

This is a quick reference guide for disabling automatic email notifications in the CoE Starter Kit after upgrading to the December 2025 release.

## TL;DR

If you're receiving unexpected automatic emails from CoE Starter Kit after upgrading to version 4.50.7 (Core) or 3.27.6 (Audit), you need to disable notification flows.

**Quick Steps:**
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Select your CoE environment
3. Open Solutions > Center of Excellence (Core or Audit Components)
4. Turn OFF the flows listed below

## Flows to Disable

### In Center of Excellence – Audit Components:
```
☐ Admin | Inactivity notifications v2 (Start Approval for Apps)
☐ Admin | Inactivity notifications v2 (Start Approval for Flows)
☐ Admin | Inactivity notifications v2 (Check Approval)
☐ Admin | Inactivity notifications v2 (Clean Up and Delete)
☐ Admin | Email Managers Ignored Inactivity notifications
☐ Request Orphaned Objects Reassigned (Parent)
☐ Request Orphaned Objects Reassigned (Child)
☐ Microsoft Teams Admin | Ask for Business Justification
☐ Microsoft Teams Admin | Send Reminder Mail
☐ Microsoft Teams Admin | Weekly Clean Up of Microsoft Teams environments
☐ Admin | Quarantine non-compliant apps
☐ Admin | Set app quarantine status
```

### In Center of Excellence – Core Components:
```
☐ Admin | Compliance Details Request eMail (Apps)
☐ Admin | Compliance Details Request eMail (Chatbots)
☐ Admin | Compliance Details Request eMail (Custom Connectors)
☐ Admin | Compliance Details Request eMail (Desktop Flows)
☐ Admin | Compliance Details Request eMail (Flows)
☐ Admin | Compliance detail request v3
```

## What Still Works?

After disabling these flows, you can still:
- ✅ View inventory in Power BI dashboards
- ✅ Use CoE admin apps
- ✅ Manually monitor and manage resources
- ✅ Run reports

You just won't send automatic emails to end users.

## Full Documentation

For detailed explanations and context, see:
- [Troubleshooting Guide](TROUBLESHOOTING-AUTOMATIC-NOTIFICATIONS.md) - Detailed steps and explanations
- [Upgrade Notes](UPGRADE-NOTES-DECEMBER-2025.md) - Information about the December 2025 release

## Need Help?

- Report issues: [aka.ms/coe-starter-kit-issues](https://aka.ms/coe-starter-kit-issues)
- Browse existing issues: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
