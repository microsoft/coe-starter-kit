# Response to Issue: Repeated Quarantine Release Email Notifications

## Issue Summary

User is receiving hundreds of duplicate email notifications stating that their app has been released from quarantine, with emails arriving repeatedly.

## Root Cause Analysis

The issue is caused by an interaction between two flows in the CoE Starter Kit:

1. **Admin | Sync Template v4 (Apps)** - Runs daily to synchronize app inventory from Power Platform APIs to Dataverse
2. **Admin | Set app quarantine status** - Triggers whenever the `admin_appisquarantined` field on the `admin_app` table is modified

### Technical Details

The `Admin | Set app quarantine status` flow uses a Dataverse trigger that monitors the `admin_appisquarantined` field:

```json
"triggers": {
  "When_a_row_is_added,_modified_or_deleted": {
    "subscriptionRequest/filteringattributes": "admin_appisquarantined"
  }
}
```

During the daily sync operation, the **Admin | Sync Template v4 (Apps)** flow updates app records with current data from the Power Platform API, including the `admin_appisquarantined` field. Even if the quarantine status value hasn't changed, the Dataverse webhook can trigger when the record is updated, causing the notification email to be sent repeatedly.

This is a known behavior of Dataverse triggers - they fire on record modification even if the monitored field's value hasn't actually changed.

## Solutions

We've created comprehensive documentation with multiple solutions:

### 1. Troubleshooting Guide
**File**: `TROUBLESHOOTING-QUARANTINE-EMAILS.md`

This document provides:
- Detailed root cause explanation
- 5 different solution approaches (from simple workarounds to permanent fixes)
- Prevention best practices
- Instructions for identifying affected apps
- Related flows information

### 2. Implementation Guide
**File**: `FIX-QUARANTINE-EMAIL-FLOW.md`

This document provides:
- Step-by-step instructions to add deduplication logic
- Field creation guide for tracking last notification date
- Flow modification steps with screenshots
- Alternative simpler approaches
- Testing and verification procedures
- Rollback instructions

## Immediate Workarounds

### Quick Fix (Temporary):
**Turn off the notification flow while planning a permanent fix:**

1. Navigate to Power Automate admin center
2. Find flow: **Admin | Set app quarantine status**
3. Turn off the flow

**Note**: This will stop ALL quarantine notifications, not just duplicates.

### Recommended Permanent Fix:
**Add deduplication logic using a tracking field:**

1. Add a new field `admin_lastquarantinenotificationdate` to the `admin_app` table
2. Modify the flow to check if a notification was sent today before sending another
3. Update the tracking field after sending each notification

Detailed steps are provided in `FIX-QUARANTINE-EMAIL-FLOW.md`.

## Code Changes

We've made the following changes to support the fix:

1. Updated `AdminSetappquarantinestatus` flow JSON to include `admin_quarantineappdate` in the select statement
   - This enables checking when the quarantine status was last changed
   - File: `CenterofExcellenceAuditComponents/SolutionPackage/src/Workflows/AdminSetappquarantinestatus-957255CE-1B93-EC11-B400-000D3A8FC5C7.json`

2. Created comprehensive documentation:
   - `TROUBLESHOOTING-QUARANTINE-EMAILS.md` - Troubleshooting guide
   - `FIX-QUARANTINE-EMAIL-FLOW.md` - Implementation guide

## What Users Should Do

1. **Immediate relief**: Turn off the **Admin | Set app quarantine status** flow temporarily
2. **Review documentation**: Read `TROUBLESHOOTING-QUARANTINE-EMAILS.md` to understand the issue
3. **Implement fix**: Follow `FIX-QUARANTINE-EMAIL-FLOW.md` to add deduplication logic
4. **Re-enable flow**: Turn the flow back on after implementing the fix

## Future Improvements

For future releases, consider:

1. **Built-in deduplication**: Add the `admin_lastquarantinenotificationdate` field to the solution
2. **Flow modification**: Update the flow logic to include deduplication by default
3. **Configuration option**: Add an environment variable to control notification frequency
4. **Batch notifications**: Option to send daily/weekly summary emails instead of immediate notifications

## Testing

The fix has been documented with:
- Step-by-step test procedures
- Verification checklist
- Expected behavior descriptions
- Rollback instructions

Users should test in a development environment before applying to production.

## Additional Context

### Related Flows:
- **Admin | Quarantine non-compliant apps** - Daily scheduled flow that marks apps for quarantine
- **Admin | Sync Template v4 (Apps)** - Daily sync that updates app inventory
- **SYNC HELPER - Apps** - Helper flow that updates individual app records

### Affected Components:
- Solution: Center of Excellence - Audit Components
- Table: `admin_app`
- Field: `admin_appisquarantined`

### Official Documentation:
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Governance Components](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)

## Conclusion

This issue affects users who have:
1. Enabled the Audit Components solution
2. Configured app quarantine flows
3. Apps that have been released from quarantine

The root cause is a known limitation of Dataverse triggers (firing on any update, not just value changes). The provided documentation offers multiple solutions ranging from quick workarounds to permanent fixes with deduplication logic.

Users should implement the recommended fix to prevent duplicate notifications while maintaining the quarantine notification functionality.
