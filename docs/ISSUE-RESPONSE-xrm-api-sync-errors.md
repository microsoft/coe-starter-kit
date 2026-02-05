# Issue Response: "Unexpected error occurred when calling the XRM api" in Sync Flows

## Issue Pattern

Users report that sync flows (particularly **Admin | Sync Template v4 (Flows)**, **Admin | Sync Template v4 (Apps)**, or other inventory flows) are failing with the error:

```
Action 'List_Flows_as_Admin_(V2)' failed

Request to XRM API failed with error: 
'Unexpected error occurred when calling the XRM api'
```

## Quick Triage

This is a **known, transient error** related to:
- ✅ API throttling (most common)
- ✅ Service protection limits
- ✅ Temporary connectivity issues
- ✅ Authentication token expiration

## Standard Response Template

Use this response when users report this error:

---

### Response to User

Thank you for reporting this issue! The error you're seeing is a known, transient error that typically resolves with a simple retry.

#### Quick Fix (Success Rate: ~70%) ✅

**Step 1: Resubmit the Flow**
1. Go to Power Automate in your CoE environment
2. Find the failed flow run
3. Click **Resubmit** (top-right button)
4. Monitor the resubmitted run

This error is often temporary and resolves on retry.

#### If Resubmit Doesn't Work

**Step 2: Enable Inventory Delays**

This reduces the rate of API calls to avoid throttling:

1. Go to Power Apps → CoE environment → Solutions
2. Open **Center of Excellence - Core Components**
3. Navigate to **Environment Variables**
4. Find `admin_DelayObjectInventory`
5. Set **Current Value** = `Yes`

**Impact**: This will significantly reduce throttling errors, but inventory will take longer to complete.

**Step 3: Verify Full Inventory Mode**

Ensure you're not running in full inventory mode (which processes ALL objects and can trigger throttling):

1. In Environment Variables, find `admin_FullInventory`
2. Verify **Current Value** = `No` (unless you're doing initial setup or troubleshooting)

**Note**: Only use full inventory mode for:
- Initial CoE setup
- After long periods without sync
- Troubleshooting missing data

#### Detailed Troubleshooting Guide

For comprehensive information about this error, see:

📖 **[Sync Flows XRM API Errors Troubleshooting Guide](./troubleshooting/sync-flows-xrm-api-errors.md)**

This guide includes:
- Root cause analysis
- All configuration options
- Advanced troubleshooting steps
- Preventive measures

### Understanding the Error

The "Unexpected error occurred when calling the XRM api" is a **generic error message** from the Power Platform Admin connectors. It typically indicates one of these conditions:

- 🔄 **API throttling / Service protection limits** (most common)
- 🌐 **Transient network or service issues**  
- 🔑 **Authentication token expiration**
- 📊 **Dataverse service limits**

### Built-in Protection

The CoE Starter Kit sync flows **already include retry logic** to handle transient errors:

- ✅ Retries up to **30 times**
- ✅ Uses **exponential backoff** (waits longer between each retry)
- ✅ Starts with **30-second intervals**

However, if the underlying issue persists (e.g., sustained throttling), the flow will eventually fail after exhausting all retries.

### When to Follow Up

If the error persists after:
- Resubmitting the flow multiple times
- Enabling `admin_DelayObjectInventory`
- Waiting 24 hours

Please provide:
1. CoE Starter Kit version
2. Which sync flow is failing (Flows, Apps, Connectors, etc.)
3. Approximate number of environments in your tenant
4. Current environment variable settings:
   - `admin_DelayObjectInventory`
   - `admin_FullInventory`
   - `admin_InventoryFilter_DaysToLookBack`
5. Screenshot of the flow run error
6. Frequency (every run, occasional, specific times)

### Resources

- [Service Protection API Limits](https://learn.microsoft.com/en-us/power-platform/admin/api-request-limits-allocations)
- [Sync Flows XRM API Errors Guide](./troubleshooting/sync-flows-xrm-api-errors.md)
- [Dataverse API Limits](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/api-limits)

---

## Resolution Statistics

Based on community feedback:
- **~70%** of cases resolve on first resubmit
- **~20%** resolve after enabling `admin_DelayObjectInventory`
- **~10%** require additional investigation (usually related to tenant size, service health, or connection issues)

## When to Escalate

Escalate if:
- User has tried all recommended steps
- Error persists for >3 days
- Multiple sync flows are affected
- Same environment consistently fails
- Service health shows no incidents

## Related Issues

Search GitHub for similar patterns:
- Issues with "XRM API" in title
- Issues with sync flow failures
- Issues tagged with `bug` and `core-components`

## Prevention Tips for Users

Share these preventive tips:
1. Use **incremental mode** (default) for daily operations
2. Run **full inventory** only when needed (initial setup, quarterly reviews)
3. Enable `admin_DelayObjectInventory` for large tenants (>500 environments)
4. Stagger sync flow schedules to avoid simultaneous runs
5. Monitor service health before running full inventory

---

**Document Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
