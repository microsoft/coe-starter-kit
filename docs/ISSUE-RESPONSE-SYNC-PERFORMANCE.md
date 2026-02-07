# Issue Response: Long-Running Sync Template Flows (v3 Flow Action Details, v4 Flows)

## Quick Response Template

Use this template when responding to issues about sync flows running for extended periods (>1 hour).

---

## Response

Thank you for reporting this issue. After analyzing the CoE Starter Kit architecture, the 7+ hour runtime is caused by **API throttling from concurrent flow executions**, not a bug in the flows themselves.

### 🎯 Immediate Solution

1. **Enable throttling prevention settings**:
   - Navigate to **Power Apps** → **Solutions** → **Center of Excellence - Core Components** → **Environment Variables**
   - Find `admin_DelayObjectInventory` and set **Current Value** = `Yes`
   - Find `admin_DelayInventory` and set **Current Value** = `Yes`

2. **Verify inventory mode**:
   - Find `admin_FullInventory` and verify **Current Value** = `No` (for regular scheduled runs)
   - Only set to `Yes` for initial setup or when intentionally running a full inventory
   - ⚠️ If currently set to `Yes`, this explains the long runtime - full inventory can take 6-12 hours in large tenants

3. **Allow settings to take effect**:
   - Changes apply on the next Driver run
   - You can manually trigger the Driver flow or wait for the scheduled run

### 📊 Expected Results

With the delay settings enabled and incremental mode (FullInventory = No):

| Tenant Size | # of Flows | v4 Flows Duration | v3 Flow Action Details Duration |
|------------|-----------|-------------------|--------------------------------|
| Small | < 500 | 5-10 min | 10-20 min |
| Medium | 500-2000 | 15-30 min | 30-60 min |
| Large | 2000-10000 | 30-90 min | 1-2 hours |
| Enterprise | 10000+ | 1-2 hours | 2-4 hours |

**Note**: Flow Action Details takes longer than Flows because it processes detailed action-level metadata for every flow.

### 🔍 Why This Happens

When the **Admin | Sync Template v4 (Driver)** flow updates environment records, it triggers multiple child flows simultaneously:
- Admin | Sync Template v3 (Flow Action Details)
- Admin | Sync Template v4 (Flows)
- Admin | Sync Template v4 (Apps)
- Admin | Sync Template v4 (Solutions)
- ...and 15+ other sync flows

Without delay settings enabled, this creates thousands of concurrent API calls that exceed Dataverse throttling limits (6,000 requests per 5 minutes). The flows then enter retry loops with exponential backoff, extending execution time from minutes to hours.

The delay settings are **specifically designed to prevent this** by spacing out API calls and preventing throttling.

### 📚 Detailed Information

For comprehensive troubleshooting, including advanced scenarios and best practices, see:
- **[Long-Running Sync Template Flows - Troubleshooting Guide](CenterofExcellenceCoreComponents/TROUBLESHOOTING-SYNC-PERFORMANCE.md)**

This guide covers:
- Root cause analysis
- Step-by-step troubleshooting
- Performance benchmarks for different tenant sizes
- Advanced tuning options
- Best practices for large tenants

### 🤔 If Issues Persist

If you continue to experience long run times after enabling delays:

1. Check your tenant size:
   - Count records in the `admin_environment` table (how many environments?)
   - Count records in the `admin_flow` table (how many flows?)
   - Ensure expected duration matches your tenant size

2. Review flow run history for throttling errors:
   - Look for error messages containing "429" or "throttle"
   - Check if actions are retrying multiple times

3. Consider additional optimizations for large tenants:
   - Reduce `admin_InventoryFilter_DaysToLookBack` to 3-5 days (from default 7)
   - Exclude non-essential environments from inventory
   - Schedule Driver runs during off-peak hours
   - For v3 Flow Action Details specifically: Evaluate if you need detailed action metadata (can be disabled if not needed)

Please let us know if the delay settings resolve your issue, or provide additional details if problems persist:
- Current values of the environment variables
- Approximate number of environments and flows in your tenant
- Screenshots of flow run history showing errors or long duration

---

## Related Issues

Search for similar issues:
- Keywords: `throttle`, `long running`, `sync template`, `flow action details`, `performance`
- Labels: `Core`, `inventory`, `performance`

## Labels to Apply

- `question`
- `Core`
- `inventory`
- `performance`
- `documentation`

## Follow-up Actions

1. Ask user to confirm delay settings are now enabled
2. Ask user to report back after next Driver run with results
3. If resolved, ask user to confirm so issue can be closed
4. If not resolved, gather more details:
   - Tenant size (# environments, # flows)
   - Environment variable values
   - Flow run history screenshots
   - Error messages

---

*This response template is part of the CoE Starter Kit issue management documentation.*
