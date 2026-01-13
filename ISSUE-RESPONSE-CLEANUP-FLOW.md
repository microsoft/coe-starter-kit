# Issue Response: Missing Flows in CoE Inventory

## Summary
The flows missing from your CoE Toolkit inventory are the result of the **CLEANUP - Admin | Sync Template v4 (Check Deleted)** flow operating as designed with its default configuration.

## Root Cause

Yes, the CLEANUP flow **does delete rows** from backend Dataverse tables, including `admin_flows`, when the following conditions are met:

1. ✅ The flow has been deleted from the Power Platform environment
2. ✅ The flow was marked as deleted more than **2 months ago**
3. ✅ The environment variable `admin_DeleteFromCoE` is set to **"yes"** (default)

## How It Works

### Process Flow

```
Flow Deleted from Environment
    ↓
First CLEANUP Flow Run (Weekly on Sunday at 12:00)
    ↓
Record Marked Deleted
- admin_flowdeleted = true
- admin_flowdeletedon = [timestamp]
    ↓
Wait 2 Months (8-9 weeks)
    ↓
CLEANUP Flow Runs Again
    ↓
Record Permanently Deleted from CoE Inventory
```

### Frequency
- **Schedule**: Weekly on Sundays at 12:00 (noon)
- **Grace Period**: 2 months before permanent deletion
- **Affected Tables**: All inventory tables (flows, apps, environments, solutions, connectors, etc.)

## Your Specific Situation

Based on your description:
- ✅ You exported the flow list **one month ago**
- ✅ The CLEANUP flow **is currently enabled**
- ✅ Several flows are now **missing** from `admin_flows`

**Conclusion**: The flows you observed one month ago were likely:
1. Already deleted from the actual environments at that time
2. Marked as deleted by the CLEANUP flow
3. Now past the 2-month grace period
4. Permanently removed from the CoE inventory

## Solution: Retain Historical Records

To preserve historical data for reporting purposes, you have several options:

### ✅ Recommended: Change Environment Variable

**Step-by-Step:**
1. Navigate to your CoE environment in Power Apps (make.powerapps.com)
2. Go to **Solutions** → **Center of Excellence - Core Components**
3. Select **Environment Variables** from the left navigation
4. Find **"Also Delete From CoE"** (`admin_DeleteFromCoE`)
5. Click **Edit** and change **Current Value** to: `no`
6. Click **Save**

**Result:**
- Future deleted flows will be marked as deleted (`admin_flowdeleted = true`)
- Records will **not be permanently deleted** from the database
- You can query historical data by including or filtering records where `admin_flowdeleted = true`
- Full audit trail maintained

**Dashboard Adjustments Needed:**
- Add filter to Power BI reports: `admin_flowdeleted <> true` to show only active flows
- Or create separate historical views that include deleted flows

### Alternative Options

#### Option 2: Export Data for Long-Term Storage
- Create a scheduled flow to export CoE inventory data to:
  - Azure Data Lake
  - Azure SQL Database
  - SharePoint lists
  - Power BI dataflows with historical retention
- Run before the weekly CLEANUP flow
- Implement custom retention policy

#### Option 3: Extend the Grace Period
- Modify the CLEANUP flow to increase the 2-month window to 6 or 12 months
- **Warning**: Requires maintaining a customized solution and may complicate upgrades
- See [CLEANUP Flow FAQ](./CLEANUP-FLOW-FAQ.md) for detailed instructions

#### Option 4: Create Custom Archive
- Build a separate archive table in Dataverse
- Create a flow that copies marked-deleted records before cleanup
- Maintain separate reporting for active vs. archived data

## Verification Query

To check if your flows were marked as deleted (but not yet removed), run this in Power Apps:

**Filter**: `admin_flowdeleted eq true`  
**Sort**: `admin_flowdeletedon descending`

If you see records, they're marked but not yet deleted. If empty, they've been permanently removed.

## Prevention for Future

1. **Immediate**: Change `admin_DeleteFromCoE` to "no" (recommended)
2. **Short-term**: Document your data retention policy
3. **Long-term**: Implement automated exports or archival process
4. **Monitoring**: Set up alerts to track CoE database size if retaining all records

## Documentation Created

I've created two comprehensive guides for this issue:

1. **[CLEANUP-FLOW-FAQ.md](./CLEANUP-FLOW-FAQ.md)** - Detailed FAQ covering:
   - How the CLEANUP flow works
   - Configuration options
   - Data retention strategies
   - Best practices

2. **[TROUBLESHOOTING-MISSING-FLOWS.md](./TROUBLESHOOTING-MISSING-FLOWS.md)** - Troubleshooting guide with:
   - Verification steps
   - Resolution options
   - Data recovery procedures
   - Prevention strategies

Both documents are now referenced in the main README.md for easy discovery.

## Additional Context

### Environment Variable Details
- **Name**: Also Delete From CoE
- **Schema Name**: `admin_DeleteFromCoE`
- **Default Value**: "yes"
- **Introduced**: Version 1.62
- **Type**: String ("yes" or "no")

### Grace Period Logic
The cleanup uses this expression:
```
Get items where:
  admin_flowdeleted = true 
  AND 
  admin_flowdeletedon < [Current Date - 2 Months]
```

This ensures accidentally marked items have time to be corrected before permanent deletion.

## Questions Answered

> **Does the CLEANUP flow delete rows from the backend Dataverse tables when it detects that a flow has been deleted from the environment?**

**A**: Yes, but only after a 2-month grace period and only if `admin_DeleteFromCoE = "yes"` (default).

> **How frequently are flows removed from the inventory?**

**A**: The CLEANUP flow runs weekly on Sundays at 12:00. Flows are deleted 2 months after being marked as deleted.

> **Is there a recommended approach to retain historical records for reporting purposes?**

**A**: Yes - Change `admin_DeleteFromCoE` to "no" to mark flows as deleted but retain them in the database.

> **Could this behavior explain why previously listed flows are now missing?**

**A**: Yes, this is the expected behavior when flows are deleted from environments more than 2 months ago with the default settings.

## References

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Environment Variables Documentation](https://docs.microsoft.com/power-platform/alm/environment-variables)
- [CLEANUP Flow FAQ](./CLEANUP-FLOW-FAQ.md)
- [Troubleshooting Guide](./TROUBLESHOOTING-MISSING-FLOWS.md)

---

**Status**: Working as designed with default configuration  
**Action Required**: Change environment variable to retain historical data  
**Priority**: Medium (preventive action recommended)  
**Version**: CoE Starter Kit v4.50.6
