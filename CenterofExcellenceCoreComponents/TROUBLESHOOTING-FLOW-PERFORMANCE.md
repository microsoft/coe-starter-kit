# Troubleshooting: Sync Flow Performance and Long Runtimes

This guide helps resolve issues where inventory sync flows (particularly **Admin | Sync Template v3 (Flow Action Details)** and **Admin | Sync Template v4 (Flows)**) run for extended periods (7+ hours) instead of completing within expected timeframes (30 minutes to 2 hours).

## Table of Contents
- [Quick Fix](#quick-fix)
- [Issue Description](#issue-description)
- [Root Cause](#root-cause)
- [Detailed Resolution Steps](#detailed-resolution-steps)
- [Understanding the Environment Variables](#understanding-the-environment-variables)
- [Expected Runtime After Fix](#expected-runtime-after-fix)
- [Advanced Troubleshooting](#advanced-troubleshooting)
- [Prevention](#prevention)

---

## Quick Fix

If your sync flows are taking 7+ hours to complete:

1. Navigate to **Power Apps** → **Solutions** → **Center of Excellence - Core Components** → **Environment Variables**
2. Find `admin_DelayObjectInventory` and set **Current Value** = `Yes`
3. Find `admin_DelayInventory` and verify **Current Value** = `Yes` (should already be Yes)
4. Find `admin_FullInventory` and verify **Current Value** = `No` (for regular scheduled runs)
5. Wait for the next **Admin | Sync Template v4 (Driver)** run to apply the changes

✅ **Expected Result**: Flow completion times will return to 30-90 minutes for v4 Flows and 1-2 hours for v3 Flow Action Details.

---

## Issue Description

### Symptoms
- **Admin | Sync Template v3 (Flow Action Details)** runs for 7+ hours
- **Admin | Sync Template v4 (Flows)** runs for extended periods
- Multiple sync flows triggered simultaneously on environment table changes
- Flow runs show many retries or long wait times between actions

### Affected Flows
- Admin | Sync Template v3 (Flow Action Details)
- Admin | Sync Template v4 (Flows)
- Admin | Sync Template v4 (Apps)
- Admin | Sync Template v4 (Cloud Flows)
- Other inventory sync flows triggered by environment updates

### When This Occurs
This issue typically manifests when:
- Multiple environments are being inventoried simultaneously
- The Driver flow updates many environment records at once
- Delay settings are disabled (`admin_DelayObjectInventory = No`)
- Running in full inventory mode (`admin_FullInventory = Yes`) without delays

---

## Root Cause

### The Throttling Cascade

When the **Admin | Sync Template v4 (Driver)** flow updates environment records in the CoE Dataverse environment, it triggers 20+ child flows simultaneously (one for each environment). Without delay settings enabled, this creates a **cascade of concurrent API calls**:

1. **Driver flow** updates 20+ environment records
2. Each update triggers **multiple child flows** (Apps, Flows, Connectors, etc.)
3. Each child flow makes **hundreds to thousands** of Dataverse API calls
4. Total concurrent calls can reach **50,000+ per minute**

### Dataverse Throttling Limits

Microsoft Dataverse enforces service protection limits:
- **6,000 API requests per 5 minutes** per user
- **52,429 API requests per 5 minutes** per tenant (depending on licenses)
- **20 concurrent requests** per user

**Reference**: [Dataverse Service Protection Limits](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/api-limits)

### What Happens When Limits Are Exceeded

When flows exceed these limits:
1. Dataverse returns **429 (TooManyRequests)** errors
2. Power Automate automatically **retries with exponential backoff**
3. Initial retry: Wait 1 minute
4. Subsequent retries: Wait 2 min → 4 min → 8 min → 16 min → 32 min...
5. Total retry time can extend flows from **minutes to hours**

### Why Delays Fix This

The `admin_DelayObjectInventory` variable adds a **randomized delay** (1-5 minutes) before each environment's inventory starts. This:
- ✅ Spreads API calls over time instead of all at once
- ✅ Keeps request rate under throttling limits
- ✅ Eliminates retry cascades
- ✅ Reduces total runtime despite adding delays

**Paradox**: Adding delays makes flows complete **faster** by avoiding throttling.

---

## Detailed Resolution Steps

### Step 1: Verify Current Settings

1. Open **Power Apps** → Your CoE Environment
2. Navigate to **Solutions** → **Center of Excellence - Core Components**
3. Click **Environment Variables**
4. Check the current values of these three variables:

| Variable Name | Current Value Should Be | Description |
|--------------|------------------------|-------------|
| `admin_DelayObjectInventory` | **Yes** | Adds delay for object inventory (apps, flows, etc.) |
| `admin_DelayInventory` | **Yes** | Adds delay for environment-level inventory |
| `admin_FullInventory` | **No** | Only "Yes" when running initial inventory or troubleshooting |

### Step 2: Update Delay Settings

If `admin_DelayObjectInventory` is set to `No`:

1. Click on **admin_DelayObjectInventory**
2. In the **Current Value** field, enter: `Yes`
3. Click **Save**

If `admin_DelayInventory` is set to `No` (should already be Yes by default):

1. Click on **admin_DelayInventory**
2. In the **Current Value** field, enter: `Yes`
3. Click **Save**

### Step 3: Verify Full Inventory Is Disabled

Unless you're running an initial inventory or troubleshooting:

1. Click on **admin_FullInventory**
2. Verify **Current Value** = `No`
3. If it's set to `Yes`, change it to `No` and click **Save**

⚠️ **Important**: Running full inventory with delays disabled causes the longest runtimes. Always enable delays when running full inventory.

### Step 4: Wait for Next Driver Run

The delay settings are read when flows are triggered. They will take effect:
- On the next **Admin | Sync Template v4 (Driver)** scheduled run
- OR when you manually trigger the Driver flow
- OR when environment records are updated

You do **NOT** need to:
- ❌ Turn flows off and back on
- ❌ Restart Power Automate
- ❌ Re-import solutions

### Step 5: Monitor Flow Performance

After the settings are applied:

1. Go to **Power Automate** → **Cloud flows**
2. Find **Admin | Sync Template v3 (Flow Action Details)**
3. Click on the flow and view **Run history**
4. Check the most recent run:
   - ✅ **Expected**: Completes in 1-2 hours
   - ❌ **Still slow**: Continue to Advanced Troubleshooting

---

## Understanding the Environment Variables

### admin_DelayObjectInventory

**Purpose**: Prevents API throttling for object-level inventory (apps, flows, connectors, etc.)

**How it works**:
- When `Yes`: Adds a random delay (1-5 minutes) before processing each environment
- When `No`: Processes all environments simultaneously

**Default Value** (as of v4.51+): `Yes`  
**Recommendation**: Keep set to `Yes` for all tenants

**When to use `No`**:
- ⚠️ Small tenants with <5 environments (testing/demo)
- ⚠️ Debugging specific flow issues
- ⚠️ Only when you understand the throttling risk

### admin_DelayInventory

**Purpose**: Adds general delays for Dataverse health

**How it works**:
- When `Yes`: Implements delay logic in main inventory flows
- When `No`: No delays (only for debugging)

**Default Value**: `Yes`  
**Recommendation**: **Always keep set to `Yes`**

**When to use `No`**:
- ⚠️ Never recommended for production
- Only for debugging in isolated test environments

### admin_FullInventory

**Purpose**: Controls incremental vs. full inventory mode

**How it works**:
- When `No`: Only syncs new or recently modified resources (incremental)
- When `Yes`: Syncs ALL resources in ALL environments (full inventory)

**Default Value**: `No`  
**Recommendation**: Keep set to `No` for regular scheduled runs

**When to use `Yes`**:
- ✅ Initial CoE setup (first-time inventory)
- ✅ Troubleshooting missing resources
- ✅ After major tenant changes
- ⚠️ **MUST** have both delay variables set to `Yes` when using full inventory

**After full inventory completes**: Set back to `No`

---

## Expected Runtime After Fix

With delay settings properly configured:

### Incremental Mode (admin_FullInventory = No)

| Flow | Environment Count | Expected Runtime |
|------|------------------|------------------|
| Admin \| Sync Template v4 (Flows) | 1-10 envs | 15-45 minutes |
| Admin \| Sync Template v4 (Flows) | 10-50 envs | 30-90 minutes |
| Admin \| Sync Template v4 (Flows) | 50+ envs | 1-2 hours |
| Admin \| Sync Template v3 (Flow Action Details) | 1-10 envs | 30-60 minutes |
| Admin \| Sync Template v3 (Flow Action Details) | 10-50 envs | 1-2 hours |
| Admin \| Sync Template v3 (Flow Action Details) | 50+ envs | 2-3 hours |

### Full Inventory Mode (admin_FullInventory = Yes)

| Tenant Size | Expected Runtime |
|-------------|------------------|
| Small (<100 apps/flows) | 2-4 hours |
| Medium (100-1000 apps/flows) | 4-8 hours |
| Large (1000+ apps/flows) | 8-12 hours |
| Enterprise (10,000+ apps/flows) | 12-24+ hours |

⚠️ **Full inventory mode is resource-intensive**. Plan accordingly and run during off-peak hours.

---

## Advanced Troubleshooting

If flows are still slow after enabling delays:

### Check License Allocation

Insufficient Power Apps licenses reduce API limits:

1. Verify the service account has **Power Apps Per User** or **Power Apps Premium**
2. Check tenant-level API capacity in **Power Platform Admin Center**
3. Review if you need to purchase additional capacity

**Test your license allocation**:
```
Power Automate > Monitor > API Limits
```

Look for **429 errors** or **throttling warnings** in flow runs.

### Verify Connector Permissions

The service account must have:
- ✅ System Administrator role in CoE environment
- ✅ Power Platform Admin role in Microsoft Entra ID
- ✅ Permissions to call Microsoft Dataverse connector
- ✅ Permissions to call HTTP with Azure AD connector

### Check for Concurrent Manual Triggers

If someone is manually triggering flows while scheduled runs are happening:
- Pause manual troubleshooting during scheduled inventory
- Schedule Driver flow for off-peak hours (e.g., 2 AM local time)

### Review Flow Run History for Specific Errors

1. Go to the slow-running flow
2. Click on a recent run
3. Expand each action and look for:
   - **429 errors** → Throttling (enable delays)
   - **401/403 errors** → Permissions issue
   - **500 errors** → Dataverse service issue
   - **Timeout errors** → Network or performance issue

### Increase Lookback Window (If Using Incremental Mode)

If you're missing recent changes:

1. Find `admin_InventoryFilter_DaysToLookBack`
2. Increase from default `7` to `14` or `30`
3. This increases runtime but ensures better coverage

### Consider Splitting Inventory by Environment Groups

For very large tenants (100+ environments):
- Use environment filters to split inventory into batches
- Run different batches at different times
- This is an advanced configuration not covered in this guide

---

## Prevention

### For New Installations

✅ **Default settings (v4.51+) already prevent this issue**  
✅ `admin_DelayObjectInventory` defaults to `Yes`  
✅ `admin_DelayInventory` defaults to `Yes`  

No action needed if installing fresh.

### For Existing Installations

If you're upgrading from older versions:

1. ✅ Review environment variables after each upgrade
2. ✅ Verify delay settings are enabled
3. ✅ Test flow performance after upgrade
4. ✅ Read upgrade release notes for environment variable changes

### Best Practices

1. **Monitor regularly**: Check flow run times weekly
2. **Set alerts**: Configure failure alerts for critical flows
3. **Off-peak scheduling**: Run Driver flow during low-usage hours
4. **Incremental by default**: Only use full inventory when necessary
5. **Document settings**: Keep a record of your environment variable configurations

### When to Re-enable Delays After Debugging

If you temporarily disabled delays for troubleshooting:
- ✅ Re-enable immediately after debugging session
- ✅ Don't leave delays disabled overnight
- ✅ Set a reminder to restore production settings

---

## Summary

### The Problem
Concurrent flow executions exceed Dataverse API limits, causing throttling and exponential retry backoff that extends runtimes from minutes to hours.

### The Solution
Enable delay environment variables to spread API calls over time:
- `admin_DelayObjectInventory = Yes`
- `admin_DelayInventory = Yes`

### The Result
- ✅ Flows complete in 30 minutes to 2 hours instead of 7+ hours
- ✅ No throttling errors
- ✅ Predictable, consistent performance
- ✅ Better tenant health

### Key Takeaway
**Adding delays makes flows faster** by preventing throttling retries.

---

## Related Documentation

- [CoE Core Components README](./README.md)
- [PVA Sync Troubleshooting](./TROUBLESHOOTING-PVA-SYNC.md)
- [Upgrade Troubleshooting](../TROUBLESHOOTING-UPGRADES.md)
- [Dataverse Service Protection Limits](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/api-limits)
- [CoE Starter Kit Official Docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

---

**Document Version**: 1.0  
**Last Updated**: January 2026  
**Applies to**: CoE Starter Kit v4.24.3+
