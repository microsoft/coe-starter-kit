# GitHub Issue Response

## Thank you for reporting this issue!

You're receiving hundreds of duplicate email notifications about apps being released from quarantine. This is a known interaction between the CoE Starter Kit flows, and we've created comprehensive documentation to help you resolve it.

## Root Cause

The issue occurs due to an interaction between two flows:

1. **Admin | Sync Template v4 (Apps)** - Runs daily to sync app inventory
2. **Admin | Set app quarantine status** - Triggers when the `admin_appisquarantined` field is modified

The sync flow updates app records daily, which triggers the notification flow even when the quarantine status hasn't actually changed. This causes the same notification to be sent repeatedly.

## Immediate Solution

To stop the duplicate emails immediately:

1. Navigate to Power Automate (https://flow.microsoft.com)
2. Select your CoE environment
3. Find the flow: **Admin | Set app quarantine status**
4. Turn OFF the flow

**Note**: This will stop ALL quarantine notifications temporarily, not just duplicates.

## Permanent Fix

We've created comprehensive documentation with multiple solution approaches:

### 📚 Documentation Files Created

1. **[QUARANTINE-EMAIL-FIX-README.md](./QUARANTINE-EMAIL-FIX-README.md)** - Quick reference guide
2. **[TROUBLESHOOTING-QUARANTINE-EMAILS.md](./TROUBLESHOOTING-QUARANTINE-EMAILS.md)** - Detailed troubleshooting with 5 solution approaches
3. **[FIX-QUARANTINE-EMAIL-FLOW.md](./FIX-QUARANTINE-EMAIL-FLOW.md)** - Step-by-step implementation guide

### Recommended Approach: Add Deduplication Logic

The best permanent solution is to add a tracking field that prevents duplicate notifications within 24 hours:

**High-level steps**:
1. Add a `admin_lastquarantinenotificationdate` field to the `admin_app` table
2. Modify the flow to check if a notification was sent today before sending another
3. Update the field after each notification

**Detailed steps**: See [FIX-QUARANTINE-EMAIL-FLOW.md](./FIX-QUARANTINE-EMAIL-FLOW.md)

## Why This Happens

The Dataverse trigger in the notification flow fires on ANY modification to the `admin_appisquarantined` field, not just when the value changes. During daily sync operations, this field gets updated even when the value is the same, causing the trigger to fire and send duplicate emails.

This is a known behavior of Dataverse webhooks - they don't natively distinguish between "value changed" and "record updated with same value."

## Code Changes in This PR

1. **Flow JSON Update**: Added `admin_quarantineappdate` to the Get App action's select statement
   - File: `AdminSetappquarantinestatus-957255CE-1B93-EC11-B400-000D3A8FC5C7.json`
   - This enables the deduplication logic described in the documentation

2. **Comprehensive Documentation**: Four detailed markdown files covering troubleshooting, implementation, and quick reference

## Next Steps

1. **Review Documentation**: Start with [QUARANTINE-EMAIL-FIX-README.md](./QUARANTINE-EMAIL-FIX-README.md)
2. **Choose Solution**: Select the approach that best fits your environment
3. **Implement Fix**: Follow [FIX-QUARANTINE-EMAIL-FLOW.md](./FIX-QUARANTINE-EMAIL-FLOW.md) for detailed steps
4. **Test**: Verify in development environment before deploying to production
5. **Monitor**: Check that duplicate emails stop and legitimate notifications still work

## Additional Support

If you need help implementing the fix:
- Review all documentation files in this PR
- Check for similar issues in [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- Ask questions in the comments of this issue

## Alternative Solutions

The documentation includes 5 different approaches ranging from simple workarounds to advanced optimizations. Choose based on your:
- Technical expertise
- Available time
- Environment constraints
- Notification preferences (real-time vs batch)

All options are detailed in [TROUBLESHOOTING-QUARANTINE-EMAILS.md](./TROUBLESHOOTING-QUARANTINE-EMAILS.md).

---

We apologize for the inconvenience caused by the duplicate emails. The documentation we've created should help you resolve this issue permanently. Please let us know if you have any questions or need clarification on any of the steps!
