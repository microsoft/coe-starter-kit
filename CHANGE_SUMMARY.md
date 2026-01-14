# Summary of Changes: Disable Notification Flows by Default

## Issue Description

After upgrading to CoE Starter Kit version 4.50.7 (Core Components) and 3.27.6 (Audit Components) in December 2025, users reported receiving thousands of unexpected automatic emails. These emails included:

- "Note from your Power Platform Admin: This flow appears to be unused; can we delete?"
- "Note from your Power Platform Admin: Submit compliance details for your chatbot"
- "Note from your Power Platform Admin: Your employees have stale Power Platform objects"

Additionally, some flows had the potential for destructive actions like deleting environments or quarantining apps.

## Root Cause

Notification and governance flows were configured with:
- `StateCode=0` (Active)
- `StatusCode=1` (Activated)

This meant they were **enabled by default** when the solution was installed or upgraded. Users had no warning or opportunity to configure these flows before they started sending emails or taking governance actions.

## Solution Implemented

Changed 18 flows in Core Components and Audit Components to be **disabled by default**:
- `StateCode=1` (Draft/Inactive)
- `StatusCode=2` (Draft)

### Flows Modified

#### Audit Components (12 flows)

**Inactivity Notification Flows (5):**
1. Admin | Inactivity notifications v2 (Start Approval for Apps)
2. Admin | Inactivity notifications v2 (Start Approval for Flows)
3. Admin | Inactivity notifications v2 (Check Approval)
4. Admin | Inactivity notifications v2 (Clean Up and Delete)
5. Admin | Email Managers Ignored Inactivity notifications

**Orphaned Objects Flows (2):**
6. Request Orphaned Objects Reassigned (Parent)
7. Request Orphaned Objects Reassigned (Child)

**Microsoft Teams Governance Flows (3):**
8. Microsoft Teams Admin | Ask for Business Justification when Microsoft Teams environment is created
9. Microsoft Teams Admin | Send Reminder Mail
10. Microsoft Teams Admin | Weekly Clean Up of Microsoft Teams environments ⚠️

**App Quarantine Flows (2):**
11. Admin | Quarantine non-compliant apps ⚠️
12. Admin | Set app quarantine status ⚠️

#### Core Components (6 flows)

**Compliance Detail Request Flows (6):**
1. Admin | Compliance Details Request eMail (Apps)
2. Admin | Compliance Details Request eMail (Chatbots)
3. Admin | Compliance Details Request eMail (Custom Connectors)
4. Admin | Compliance Details Request eMail (Desktop Flows)
5. Admin | Compliance Details Request eMail (Flows)
6. Admin | Compliance detail request v3

### Documentation Added

1. **NOTIFICATION_FLOWS_GUIDE.md**
   - Comprehensive guide to all notification flows
   - How to enable flows properly
   - Configuration best practices
   - Troubleshooting tips

2. **STOP_AUTOMATIC_EMAILS.md**
   - Immediate fix for affected users
   - Step-by-step instructions to disable flows
   - Quick reference guide

3. **README.md**
   - Prominent notice about the December 2025 change
   - Links to detailed guides

## Benefits

### For End Users
✅ No unexpected emails after upgrades
✅ No surprise destructive actions (environment deletion, app quarantine)
✅ Clear communication about what governance features are available

### For Administrators
✅ Full control over when to enable notification features
✅ Time to configure and test before enabling
✅ Ability to pilot with small groups before organization-wide rollout
✅ Clear documentation on setup and best practices

### For the Product
✅ Follows principle of least surprise
✅ Aligns with security best practice (opt-in for potentially disruptive features)
✅ Reduces support burden from unexpected behavior
✅ Improves upgrade experience

## Breaking Change?

**No** - This is a fix, not a breaking change:

- **Existing installations**: Users already using these flows can continue using them. The flows remain in the solution and work exactly as before when enabled.
- **New installations**: Admins must explicitly enable flows, which is the expected behavior for governance features.
- **Upgrades**: While flows will be disabled after upgrade, this fixes the actual problem where they were unexpectedly enabled. Admins can re-enable them with proper configuration.

## Migration Guide for Affected Users

If you upgraded to 4.50.7/3.27.6 and experienced the issue:

1. **Immediate**: Disable the flows using instructions in STOP_AUTOMATIC_EMAILS.md
2. **Review**: Read NOTIFICATION_FLOWS_GUIDE.md to understand each flow
3. **Configure**: Set up environment variables and email templates
4. **Test**: Enable flows in a test environment first
5. **Communicate**: Inform your maker community about the upcoming notifications
6. **Enable**: Turn on flows selectively using Setup Wizard or manually

## Future Enhancements

Potential improvements for future releases:

1. **Setup Wizard Integration**: Add a dedicated section in Setup Wizard for notification flows
2. **Environment Variables**: Create master "Enable Notifications" toggle
3. **Email Preview**: Allow admins to preview emails before enabling flows
4. **Phased Rollout**: Support enabling flows for specific environments or user groups first
5. **Notification Dashboard**: Central place to manage all notification settings

## Technical Details

### Files Modified

18 XML files in `*/SolutionPackage/src/Workflows/*` directories:
- Changed `<StateCode>0</StateCode>` to `<StateCode>1</StateCode>`
- Changed `<StatusCode>1</StatusCode>` to `<StatusCode>2</StatusCode>`

### Testing Considerations

1. Verify flows are disabled after solution import
2. Test enabling flows through Power Automate portal
3. Test enabling flows through Setup Wizard
4. Verify email templates are correct when enabled
5. Validate environment variables are properly set
6. Test with pilot users before production rollout

## References

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Governance Components](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)
- [GitHub Issue](https://github.com/microsoft/coe-starter-kit/issues/) - Link to original issue

## Credits

This change was made in response to user feedback about unexpected behavior after the December 2025 release. Thanks to the community for reporting this issue promptly.
