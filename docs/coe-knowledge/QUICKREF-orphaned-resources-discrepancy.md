# Quick Reference: Orphaned Resources Count Discrepancy

> **TL;DR:** Different counts between CoE and PPAC Advisor are **normal and expected** due to timing, scope, and methodology differences.

## The Issue

CoE Starter Kit shows **~150 orphaned resources** while PPAC Advisor shows **~70 orphaned resources**.

## Why This Happens

| Aspect | CoE Starter Kit | PPAC Advisor |
|--------|----------------|--------------|
| **Update Frequency** | Your configured schedule (e.g., daily) | Near real-time |
| **Data Source** | Sync flows from configured environments | All tenant environments |
| **Definition** | Owner account doesn't exist in Azure AD | Microsoft's internal criteria |
| **Resource Types** | All configured types | Filtered for admin attention |

## Quick Fix

1. ✅ **Check last sync:** When did `Admin | Sync Template v4 (Driver)` last run?
2. ✅ **Run cleanup flows:** Enable and run `CLEANUP - Admin | Sync Template v4 (Check Deleted)`
3. ✅ **Verify environments:** Are all environments included in CoE inventory?
4. ✅ **Wait for sync:** Allow time for flows to complete

## Expected Behavior

- **Small differences (10-20%):** Completely normal
- **Large differences (100%+):** Check sync flow status and environment coverage
- **CoE higher than PPAC:** Likely counting historical/soft-deleted resources
- **PPAC higher than CoE:** Sync may be outdated or missing environments

## When to Investigate

- Sync flows are failing
- Cleanup flows are disabled
- Large, unexplained discrepancy (>100 resources)
- Counts are diverging over time

## Resources

- **Detailed FAQ:** [orphaned-resources-faq.md](orphaned-resources-faq.md)
- **Response Template:** [issue-response-orphaned-resources.md](issue-response-orphaned-resources.md)
- **Common Responses:** [COE-Kit-Common GitHub Responses.md](COE-Kit-Common%20GitHub%20Responses.md#orphaned-resources)

## Still Need Help?

Provide in your issue:
- Last successful sync flow run timestamp
- Specific count difference (e.g., "150 vs 70")
- Resource types affected (Apps, Flows, etc.)
- Screenshots of both views

---

**Bottom Line:** Use CoE for detailed tracking and PPAC for quick checks. Both are correct for their respective purposes.
