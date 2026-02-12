# Issue Response Template: Duplicate Flows in Setup Wizard

## When to Use This Template

Use this template when responding to issues where users report seeing duplicate flows in the CoE Setup and Upgrade Wizard during the "Run setup flows" step.

**Example Issue Symptoms:**
- Same flow appears multiple times (e.g., "Admin | Sync Template v3 Configure Emails" shown twice)
- User mentions similar to issue #10284
- Screenshot shows duplicate entries in the wizard

## Response Template

---

Thank you for reporting this issue! This is a known scenario that can occur when there are duplicate records in the CoE Solution Metadata table.

### Quick Summary

**Issue**: Duplicate flow entries appear in the Setup Wizard  
**Root Cause**: Multiple metadata records exist for the same flow in the CoE Solution Metadata table  
**Impact**: Display issue only - both entries point to the same actual flow  
**Fix Time**: 5-10 minutes

### Immediate Workaround

You can proceed with setup despite the duplicate display:
1. Either duplicate entry will work - they both point to the same flow
2. Click one of them to run the flow
3. After setup completes, follow the cleanup steps below

### Permanent Fix: Clean Up Duplicate Metadata

**Option 1: Using Power Apps Maker Portal** (Recommended)

1. Go to [Power Apps](https://make.powerapps.com)
2. Navigate to your **CoE environment**
3. Select **Tables** → **CoE Solution Metadata**  
4. Click **Edit data**
5. Filter by Object Name containing "Configure Emails" (or the duplicate flow name)
6. Find the duplicate records (same Object Name, different record IDs)
7. Keep the most recent record (check Created On/Modified On dates)
8. Delete the older duplicate(s)
9. Refresh the Setup Wizard

**Option 2: Re-run the Metadata Sync Flow**

1. Open Power Automate in your CoE environment
2. Find "Admin | Sync Template v3 CoE Solution Metadata"
3. Run it manually
4. Wait for successful completion
5. Refresh the Setup Wizard

### Detailed Troubleshooting Guide

For comprehensive steps, screenshots, and prevention tips, see:  
📖 [**Troubleshooting: Duplicate Flows in Setup Wizard**](../Documentation/TROUBLESHOOTING-DUPLICATE-FLOWS-SETUP-WIZARD.md)

### Why This Happens

The Setup Wizard displays flows based on records in the CoE Solution Metadata table. If duplicate records exist (which can happen during failed upgrades, multiple metadata sync runs, or manual data entry), each record creates a separate entry in the wizard, even though they point to the same actual flow.

The metadata sync flow has logic to prevent this, but in certain edge cases (timing, errors, manual intervention), duplicates can still be created.

### Prevention

- Only run "Admin | Sync Template v3 CoE Solution Metadata" when needed
- Follow upgrade documentation carefully
- Don't manually create metadata records
- Check for errors after running the metadata sync

### Related Issues

This is similar to #10284. The root cause is the same - duplicate metadata records.

### Next Steps

1. Try the cleanup steps above
2. If the duplicate persists, check:
   - Are there more than 2 records for the same flow?
   - Do you have any manual customizations to the metadata table?
   - Are you running a custom version of the metadata sync flow?
3. If you still need help, please provide:
   - Screenshot showing the duplicates
   - Number of duplicate records found in the metadata table
   - Version of CoE Starter Kit you're using
   - Any custom modifications to the solution

---

## For Issue Responders

### Quick Diagnostics Questions

If the user needs more help, ask:

1. "How many duplicate entries do you see for the flow?"
2. "Can you check the CoE Solution Metadata table - how many records exist with that Object Name?"
3. "Did you recently upgrade or import the solution multiple times?"
4. "Are you running the standard CoE Starter Kit or a customized version?"

### Escalation Criteria

Escalate or request more information if:
- User reports more than 5 duplicate entries
- User cannot access the Dataverse table to clean up
- Duplicates persist after cleanup attempts
- User reports other unusual behavior (flows not running, errors, etc.)

### Closing the Issue

After providing the fix:

```markdown
I'm closing this issue as it's a data quality issue (duplicate metadata records) rather than a code bug. 

**Summary**: Duplicate metadata records in your environment caused duplicate display in the Setup Wizard.

**Resolution**: Clean up duplicate records using the steps in the troubleshooting guide.

If you encounter issues following the cleanup steps, please:
1. Review the [detailed troubleshooting guide](../Documentation/TROUBLESHOOTING-DUPLICATE-FLOWS-SETUP-WIZARD.md)
2. Ensure you have the necessary permissions to edit Dataverse tables
3. Open a new issue if the problem persists after cleanup

Thank you for using the CoE Starter Kit! 🎉
```

---

**Template Version**: 1.0  
**Last Updated**: February 2026  
**Maintained By**: CoE Starter Kit Community
