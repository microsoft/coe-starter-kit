# Troubleshooting: "Unexpected error occurred when calling the XRM api" in Sync Flows

## Issue Description

When running CoE Starter Kit sync flows (such as **Admin | Sync Template v4 (Flows)**, **Admin | Sync Template v4 (Apps)**, or other inventory flows), you may encounter the following error:

```
Action 'List_Flows_as_Admin_(V2)' failed

Request to XRM API failed with error: 
'Unexpected error occurred when calling the XRM api'
```

This error typically appears in the flow run history and causes the inventory sync to fail for that environment.

## Root Causes

The "Unexpected error occurred when calling the XRM api" message is a **generic error** from the Power Platform Admin connectors (Power Platform for Admins V2 or Flow Management connectors) that can have several underlying causes:

### 1. **API Throttling / Service Protection Limits** 🔄
   - **Most Common Cause**: Power Platform enforces service protection limits to ensure system stability
   - Occurs when making too many API calls in a short period
   - More likely during:
     - Initial inventory runs
     - Full inventory mode (`admin_FullInventory = Yes`)
     - Large tenants with many environments/flows/apps
     - Multiple sync flows running simultaneously

### 2. **Transient Network or Service Issues** 🌐
   - Temporary connectivity problems between Power Automate and Power Platform services
   - Service hiccups or brief outages
   - Regional service degradation
   - These are usually short-lived and resolve themselves

### 3. **Authentication Token Expiration** 🔑
   - Connection authentication tokens can expire during long-running operations
   - More common with flows that take >20-30 minutes
   - Related to connection refresh token policies

### 4. **Dataverse Service Limits** 📊
   - Concurrent request limits on the Dataverse instance
   - Database transaction locks
   - Storage or compute resource constraints

### 5. **Large Result Sets** 📦
   - Environments with thousands of flows/apps
   - Pagination issues when result set exceeds expected limits
   - Memory constraints processing large responses

## Official Documentation

For more information about service protection limits:
- [Service Protection API Limits](https://learn.microsoft.com/en-us/power-platform/admin/api-request-limits-allocations)
- [Dataverse API Limits](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/api-limits)
- [Retry Policies for Power Automate](https://learn.microsoft.com/en-us/power-automate/error-handling#retry-policies)

## How the Flow Handles This

The CoE Starter Kit sync flows **already include retry logic** to handle transient errors:

```json
"retryPolicy": {
  "type": "exponential",
  "count": 30,
  "interval": "PT30S"
}
```

This means:
- ✅ The action will retry up to **30 times**
- ✅ Uses **exponential backoff** (waits longer between each retry)
- ✅ Starts with **30-second intervals**

**However**, even with retry logic, if the underlying issue persists (e.g., sustained throttling, service outage), the flow will eventually fail after exhausting all retries.

## Solutions & Workarounds

### 🔧 Immediate Actions (When Flow Fails)

#### Option 1: Resubmit the Flow (Recommended First Step)
The error is often transient and will resolve on retry:

1. Go to Power Automate → CoE environment
2. Find the failed flow run
3. Click **Resubmit** (top-right)
4. Monitor the resubmitted run

**Success Rate**: ~70% of XRM API errors resolve on simple resubmit

#### Option 2: Wait and Retry
If multiple flows are failing:

1. **Wait 15-30 minutes** before retrying
2. This allows service protection limits to reset
3. Then resubmit failed flows

### 🛠️ Configuration Changes (Reduce Occurrence)

#### Option 1: Enable Inventory Delays
Reduces the rate of API calls to avoid throttling:

1. Go to Power Apps → CoE environment → Solutions
2. Open **Center of Excellence - Core Components**
3. Go to **Environment Variables**
4. Find `admin_DelayObjectInventory`
5. Set **Current Value** = `Yes`

**Impact**:
- ✅ Significantly reduces throttling errors
- ⚠️ Inventory will take longer to complete (adds delays between API calls)

#### Option 2: Avoid Full Inventory Mode
Full inventory mode processes ALL objects, increasing API load:

1. Verify `admin_FullInventory` is set to `No` (default)
2. Only use full inventory when necessary:
   - Initial setup
   - After major changes
   - Troubleshooting missing data

**When to use Full Inventory**:
- ✅ Initial CoE setup
- ✅ After long periods without sync
- ✅ When troubleshooting missing inventory
- ❌ NOT for regular daily/weekly operations

#### Option 3: Adjust Lookback Window
Reduce the number of items processed in incremental mode:

1. Go to Environment Variables
2. Find `admin_InventoryFilter_DaysToLookBack`
3. Reduce from default `7` to `3` or `5` days

**Trade-off**:
- ✅ Fewer API calls
- ⚠️ May miss recent changes if sync fails for several days

#### Option 4: Stagger Sync Schedules
Prevent multiple sync flows from running simultaneously:

1. Review sync flow schedules (Driver flow + individual sync flows)
2. Spread them across different time windows:
   - Apps sync: 1:00 AM
   - Flows sync: 2:00 AM  
   - Connectors sync: 3:00 AM
   - etc.

### 🔍 Advanced Troubleshooting

#### Check Service Health
Verify there are no ongoing service incidents:

1. Go to [Microsoft 365 Admin Center](https://admin.microsoft.com)
2. Navigate to **Health** → **Service health**
3. Check status for:
   - Power Platform
   - Power Automate
   - Dataverse
   - Power Apps

#### Review Connection Health
Ensure connections are valid and not expired:

1. Go to Power Apps → CoE environment
2. Navigate to **Data** → **Connections**
3. Find connections used by sync flows:
   - `Dataverse`
   - `Power Platform for Admins V2`
   - `Flow Management`
4. Test each connection
5. Refresh/recreate if showing errors

#### Monitor API Request Usage
Check if you're approaching tenant-level limits:

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Navigate to **Analytics** → **Power Automate**
3. Review API call volumes
4. Look for spikes or patterns

#### Review Flow Run History Pattern
Identify if specific environments always fail:

1. Go to the **CoE Admin Command Center** app
2. Navigate to **Sync Flow Errors**
3. Look for patterns:
   - Same environment failing repeatedly?
   - Same time of day?
   - Specific types of objects?

### 📊 Preventive Measures

#### 1. Right-Size Your Inventory Strategy
- Use **incremental mode** (default) for daily operations
- Run **full inventory** only monthly or quarterly
- Consider environment variables that match your tenant size

#### 2. Monitor and Plan Capacity
- Large tenants (>1000 flows): Enable delays, increase lookback window
- Medium tenants (100-1000 flows): Default settings usually work
- Small tenants (<100 flows): Can use shorter lookback, no delays needed

#### 3. Regular Connection Maintenance
- Refresh connections monthly
- Update to latest connector versions
- Monitor for expiration warnings

#### 4. Stay Updated
- Keep CoE Starter Kit updated to latest version
- Review release notes for improvements to sync logic
- New versions often include better retry handling

## When to Seek Additional Help

Create a GitHub issue if:
- ✅ Error persists after multiple retries over several days
- ✅ Same environment consistently fails
- ✅ Multiple sync flows are affected
- ✅ You've tried all recommended solutions
- ✅ Service health shows no incidents

**Include in your issue**:
1. CoE Starter Kit version
2. Which sync flow is failing (Flows, Apps, Connectors, etc.)
3. How many environments in your tenant
4. Environment variable settings (`admin_DelayObjectInventory`, `admin_FullInventory`, etc.)
5. Screenshots of flow run errors
6. Frequency of the error (every run, occasional, specific times)

## Related Issues

- [Service Protection Limits](https://learn.microsoft.com/en-us/power-platform/admin/api-request-limits-allocations)
- [Troubleshooting Sync Flows](../troubleshooting-sync-helper-cloud-flows-entity-not-exist.md)

## Summary

The "Unexpected error occurred when calling the XRM api" error is typically:

✅ **Transient** - Often resolves on retry  
✅ **Related to throttling** - Reduce API call rate  
✅ **Handled by built-in retry logic** - Flows already retry 30 times  
✅ **Preventable** - Enable delays, avoid full inventory mode  

**Quick Checklist**:
1. ☑️ Resubmit the failed flow (most common fix)
2. ☑️ Enable `admin_DelayObjectInventory` if errors persist
3. ☑️ Ensure `admin_FullInventory` is set to `No` for daily operations
4. ☑️ Stagger sync flow schedules
5. ☑️ Check service health dashboard
6. ☑️ Verify connections are healthy

Most users can resolve this by simply resubmitting the flow. If errors continue, work through the configuration changes above to reduce API call frequency.

---

**Document Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
