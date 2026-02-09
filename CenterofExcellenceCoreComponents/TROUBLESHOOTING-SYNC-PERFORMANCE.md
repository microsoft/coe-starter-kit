# Troubleshooting: Long-Running Sync Template Flows

This guide helps diagnose and resolve performance issues with Admin | Sync Template flows that run for extended periods (>1 hour) or appear stuck in "Running" state.

## 🚨 Common Symptoms

- **Admin | Sync Template v3 (Flow Action Details)** runs for 7+ hours
- **Admin | Sync Template v4 (Flows)** runs for 7+ hours
- Multiple sync flows running concurrently on the same environment
- Flow runs showing "Running" status with no apparent progress
- Throttling errors appearing in flow run history

## 🔍 Root Cause Analysis

### Primary Causes

#### 1. Cascading Environment Table Updates

**Problem**: Multiple sync template flows are triggered by changes to the `admin_environment` table:
- Admin | Sync Template v4 (Driver) updates environment records on a schedule
- Each environment record update triggers multiple child flows simultaneously:
  - Admin | Sync Template v3 (Flow Action Details)
  - Admin | Sync Template v4 (Flows)
  - Admin | Sync Template v4 (Apps)
  - Admin | Sync Template v4 (Solutions)
  - ...and many others (20+ flows total)

**Impact**: When multiple environments are updated at once, dozens of flows can execute concurrently, leading to:
- Dataverse API throttling
- Power Platform connector throttling
- Extended execution times
- Resource contention

#### 2. High Concurrency Settings

**Problem**: Sync template flows have high concurrency settings for performance:
- `repetitions: 50` in foreach loops
- This allows 50 parallel API calls within a single flow run
- Multiple flows running simultaneously multiplies this effect

**Impact**: 
- 5 flows × 50 parallel operations = 250 concurrent API calls
- Easily exceeds Dataverse and connector throttling limits
- Causes flows to retry and extend execution time

#### 3. Large Tenant Data Volume

**Problem**: In large tenants with many flows and environments:
- Admin | Sync Template v3 (Flow Action Details) processes detailed action metadata for every flow
- Each flow can have hundreds of actions
- Processing thousands of flows with detailed actions takes significant time

**Impact**:
- Longer processing time per environment
- More API calls required
- Higher chance of hitting throttling limits

#### 4. Full Inventory Mode

**Problem**: Running with `admin_FullInventory = Yes`:
- Processes ALL flows in ALL environments (not just recent changes)
- Ignores the `admin_InventoryFilter_DaysToLookBack` filter
- Processes significantly more data

**Impact**:
- Can take 6-12+ hours for large tenants
- Not recommended for regular scheduled runs
- Should only be used for initial setup or recovery scenarios

## 🎯 Solutions and Mitigations

### Solution 1: Enable Delay Settings (Recommended)

The CoE Starter Kit includes built-in throttling prevention mechanisms.

#### Steps:
1. Navigate to **Power Apps** → **Solutions** → **Center of Excellence - Core Components**
2. Go to **Environment Variables**
3. Find and update these variables:

| Environment Variable | Current Value | Recommended Value | Purpose |
|---------------------|---------------|-------------------|---------|
| `admin_DelayObjectInventory` | No | **Yes** | Adds random delays (0-2 seconds) in object-level inventory flows to prevent throttling |
| `admin_DelayInventory` | No | **Yes** | Adds delays in the Driver flow to space out environment processing |

4. Save changes
5. Wait for next scheduled Driver run or manually trigger

**Expected Impact**: 
- Flows will take longer but complete successfully
- Reduced throttling errors
- More predictable completion times
- Better resource distribution

### Solution 2: Adjust Inventory Mode

If you're running full inventory regularly, switch to incremental mode.

#### Steps:
1. Navigate to **Environment Variables** in Core Components solution
2. Find `admin_FullInventory` (Full Inventory)
3. Set **Current Value** = `No`
4. Adjust `admin_InventoryFilter_DaysToLookBack` if needed (default: 7 days)

**Expected Impact**:
- Only processes new or recently modified flows
- Significantly faster execution (minutes instead of hours)
- Suitable for regular scheduled runs

**When to Use Full Inventory**:
- Initial setup and first run
- After extended downtime
- When troubleshooting missing inventory data
- Recovery scenarios

⚠️ **Important**: Always set `admin_FullInventory` back to `No` after a full inventory completes.

### Solution 3: Stagger Environment Processing

Reduce the number of environments processed in a single Driver run.

#### Option A: Exclude Environments from Inventory

1. Open the **admin_environment** table in Power Apps
2. For non-critical environments, set **Excuse from Inventory** = `Yes`
3. This prevents the environment from triggering sync flows

#### Option B: Reduce Driver Run Frequency

1. Edit **Admin | Sync Template v4 (Driver)** flow
2. Adjust the recurrence trigger frequency (e.g., from daily to every 2 days)
3. Spreads the load over more time

**Expected Impact**:
- Fewer concurrent flow runs
- Less throttling
- Longer time to complete full tenant inventory

### Solution 4: Monitor and Tune Concurrency

For advanced scenarios, you can adjust flow-level concurrency.

⚠️ **Warning**: Modifying flows directly is not recommended as it prevents upgrades. Only do this if absolutely necessary.

**Alternative Approach**: Use the delay settings (Solution 1) which achieve similar results without modification.

### Solution 5: Check for Throttling Issues

#### Verify Throttling is the Issue:

1. Open the flow run history for the long-running flow
2. Look for action runs with:
   - Status: "Failed" or "Retrying"
   - Error messages containing "429" or "throttle"
   - Long wait times between retries

#### Common Throttling Messages:
```
Rate limit exceeded. Try again in XX seconds.
API rate limit quota exceeded for operation...
Too many requests
```

If you see these, the delay settings (Solution 1) will help.

### Solution 6: Optimize Data Volume

#### For Flow Action Details Specifically:

The v3 Flow Action Details flow processes detailed metadata for every action in every flow. In large tenants, this can be excessive.

**Consider**:
1. **Evaluate necessity**: Do you need detailed flow action metadata?
   - Used by: Advanced analytics, dependency tracking
   - Not used by: Basic inventory, governance features

2. **Selective disabling**: If not needed, you can turn off this flow:
   - Navigate to the flow in the solution
   - Turn off **Admin | Sync Template v3 (Flow Action Details)**
   - Other flows will continue to work

⚠️ **Impact**: You'll lose detailed action-level flow metadata in reports.

## 📊 Expected Performance Benchmarks

### Normal Performance (with delays enabled):

| Tenant Size | Environments | Flows | Expected Time | Notes |
|------------|--------------|-------|---------------|-------|
| Small | 1-10 | < 500 | 15-30 min | Per Driver run |
| Medium | 10-50 | 500-2000 | 30-90 min | Per Driver run |
| Large | 50-200 | 2000-10000 | 1-3 hours | Per Driver run |
| Enterprise | 200+ | 10000+ | 3-6 hours | Per Driver run |

### Full Inventory Performance:

**Multiply normal performance by 5-10x** when running with `admin_FullInventory = Yes`.

### Flow Action Details Specific:

This flow typically takes **2-3x longer** than the Flows sync because it processes action-level details.

## 🔧 Troubleshooting Steps

### Quick Diagnosis Checklist:

1. **Check delay settings**
   - [ ] `admin_DelayObjectInventory` = Yes?
   - [ ] `admin_DelayInventory` = Yes?

2. **Check inventory mode**
   - [ ] `admin_FullInventory` = No (for regular runs)?
   - [ ] `admin_InventoryFilter_DaysToLookBack` = appropriate value (7-30 days)?

3. **Check flow run history**
   - [ ] Look for throttling errors (429, rate limit)
   - [ ] Check for failed actions with retries
   - [ ] Verify flows are actually progressing (check timestamps)

4. **Check tenant size**
   - [ ] How many environments? (check admin_environment table)
   - [ ] How many flows? (check admin_flow table)
   - [ ] Is this expected performance for your size?

5. **Check concurrent runs**
   - [ ] Are multiple Driver runs happening simultaneously?
   - [ ] Are there multiple environment updates happening at once?

### Advanced Troubleshooting:

#### If flows are truly stuck (not progressing):

1. **Cancel the running flow instance**
   - Open the flow run
   - Click "Cancel"
   - Wait for confirmation

2. **Turn off the flow temporarily**
   - Prevents new triggers while investigating

3. **Check for environmental issues**:
   - Connector authentication problems
   - Network connectivity issues
   - Dataverse health issues
   - Service outages (check [status.powerplatform.microsoft.com](https://status.powerplatform.microsoft.com))

4. **Review recent changes**:
   - Did you recently upgrade the solution?
   - Were environment variables modified?
   - Were connections re-authenticated?

#### If throttling persists after enabling delays:

1. **Increase the lookback window** to reduce data volume:
   - Set `admin_InventoryFilter_DaysToLookBack` = 3 or 5 (instead of 7)

2. **Reduce Driver run frequency**:
   - Change from daily to every 2-3 days

3. **Exclude non-essential environments**:
   - Set "Excuse from Inventory" = Yes for dev/test environments

4. **Contact support**:
   - If throttling persists, you may be hitting tenant-level limits
   - Contact Microsoft Support for limit increases

## 💡 Best Practices

### For Regular Operations:

1. ✅ **Always enable delay settings** (`admin_DelayObjectInventory` = Yes, `admin_DelayInventory` = Yes)
2. ✅ **Run incremental mode** (`admin_FullInventory` = No) for scheduled syncs
3. ✅ **Use appropriate lookback window** (7-14 days for most tenants)
4. ✅ **Schedule Driver runs during off-peak hours** (nights, weekends)
5. ✅ **Monitor flow run history regularly** for trends and issues
6. ✅ **Exclude non-production environments** from inventory if not needed

### For Initial Setup:

1. ✅ **Enable delays first** before starting
2. ✅ **Run full inventory once** with `admin_FullInventory` = Yes
3. ✅ **Allow 6-12 hours** for completion in large tenants
4. ✅ **Set back to incremental mode** after completion
5. ✅ **Validate data** before relying on dashboards

### For Large Tenants (1000+ flows):

1. ✅ **Always use delays** (non-negotiable)
2. ✅ **Consider selective inventory** (exclude environments)
3. ✅ **Use shorter lookback windows** (3-5 days)
4. ✅ **Schedule less frequent runs** (every 2-3 days)
5. ✅ **Monitor storage** and set up retention policies
6. ✅ **Evaluate if Flow Action Details is necessary** (can be disabled)

## 📚 Related Documentation

- [CoE Starter Kit - Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [CoE Starter Kit - Inventory and Audit](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#inventory-and-audit)
- [Data Retention and Maintenance Guide](../CenterofExcellenceResources/DataRetentionAndMaintenance.md)
- [Power Platform Service Limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)

## 🤝 Getting Help

If you continue to experience issues after trying these solutions:

1. **Search existing issues**: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. **Create a new issue** with:
   - CoE Starter Kit version
   - Tenant size (# environments, # flows)
   - Environment variable settings
   - Flow run history screenshots
   - Error messages
   - Steps already attempted

---

*This guide is part of the CoE Starter Kit troubleshooting documentation.*
