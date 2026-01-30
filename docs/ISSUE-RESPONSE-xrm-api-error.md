# GitHub Issue Response Template - XRM API Error in Admin | Sync Template v4 (Flows)

## Use Case
Use this template when responding to issues related to the "Request to XRM API failed with error: 'Unexpected error occurred when calling the XRM api'" error in **Admin | Sync Template v4 (Flows)**.

---

## Response Template

Thank you for reporting this issue! This is a **transient backend service error** that occurs when the Power Automate Management connector temporarily cannot reach the Power Platform backend services.

### What This Error Means

The error message `Request to XRM API failed with error: 'Unexpected error occurred when calling the XRM api'` indicates:

✅ **Transient backend service issue** - temporary connectivity or availability problem  
✅ **Self-resolving** - typically clears up on its own or with retry  
✅ **Not a configuration issue** - your CoE Starter Kit is configured correctly  
✅ **Expected in large tenants** - can occur occasionally during peak usage  

❌ **NOT** a bug in the CoE Starter Kit  
❌ **NOT** a permissions or license issue (unless persistent)  
❌ **NOT** data corruption or loss  

### Built-In Error Handling

The **Admin | Sync Template v4 (Flows)** flow already includes **robust retry logic**:
- **30 automatic retry attempts** with exponential backoff
- **30-second intervals** between retries
- **15-20 minutes** of total retry time

In most cases, the flow will succeed after a few retries without any action needed.

### Quick Resolution (Try This First) ✅

**Option 1: Resubmit the Flow** (90%+ success rate)

1. Navigate to **Power Automate** in your CoE environment
2. Find the **Admin | Sync Template v4 (Flows)** flow
3. Open the failed run
4. Click **Resubmit** to retry with the same inputs

**Why this works**: The transient backend issue has likely cleared by the time you resubmit.

**Option 2: Wait and Retry During Off-Peak Hours**

If resubmission fails:
1. **Wait 2-4 hours** before retrying
2. **Schedule the run during off-peak hours**:
   - Early morning (2 AM - 6 AM local time)
   - Late evening (10 PM - 12 AM local time)
   - Weekends

### Additional Resolution Steps

If the error persists after multiple attempts:

**Step 1: Enable Delay Setting** (Helps with throttling)
1. Open **Power Apps** > **Solutions** > **Center of Excellence - Core Components**
2. Navigate to **Environment Variables**
3. Set `admin_DelayObjectInventory` to **Yes**
4. Save and re-run the flow

**Step 2: Check Service Health**
1. Visit [Microsoft 365 Admin Center](https://admin.microsoft.com) > **Health** > **Service health**
2. Look for advisories related to Power Platform or Dynamics 365
3. Check [Power Platform Admin Center](https://admin.powerplatform.microsoft.com) for environment health warnings

**Step 3: Verify Connection**
1. Navigate to **Power Automate** > **Data** > **Connections**
2. Find the **Power Automate Management** connection used by the flow
3. Verify it's not showing any error state
4. Test the connection
5. If needed, recreate the connection

### Detailed Troubleshooting Guide

For comprehensive troubleshooting steps, prevention strategies, and technical details, please see:

📖 **[Troubleshooting Guide: XRM API Error in Admin | Sync Template v4 (Flows)](troubleshooting/admin-sync-flows-xrm-api-error.md)**

This guide includes:
- Detailed root cause analysis
- Step-by-step resolution procedures
- Best practices for prevention
- FAQs and edge cases
- When to escalate to Microsoft Support

### Expected Behavior

This error is **expected to occur occasionally** in Power Platform environments, especially:
- During peak usage times (business hours)
- In large tenants with many flows
- During platform maintenance windows
- When backend services are under high load

**Frequency**: In healthy environments, this should occur in less than 1-2% of flow runs. If you see it more frequently (5%+), there may be an underlying issue.

### Prevention Tips

To minimize the frequency of this error:

1. ✅ **Run inventory flows during off-peak hours**
2. ✅ **Enable delay setting** (`admin_DelayObjectInventory = Yes`)
3. ✅ **Use incremental inventory** (set `admin_FullInventory = No`)
4. ✅ **Avoid concurrent heavy operations**
5. ✅ **Keep environments optimally sized**

### When This Becomes a Concern

Please re-open or escalate this issue if:

1. ❗ **Persistent failure** - Error occurs on every attempt for 24+ hours
2. ❗ **Multiple environments affected** - Error occurs across all environments
3. ❗ **Service health confirms outage** - Microsoft 365 Service Health shows active incident
4. ❗ **No resolution after all steps** - All troubleshooting steps attempted
5. ❗ **Business impact** - Critical inventory operations blocked for extended period

### Important Note

**This is NOT a bug in the CoE Starter Kit.** It's a transient error from the backend Power Platform services that the CoE Starter Kit cannot prevent. The flow already includes optimal error handling (30 retries with exponential backoff).

---

## Additional Context for Responders

### Technical Details

**Flow**: Admin | Sync Template v4 (Flows)  
**Action**: List_Flows_as_Admin_(V2)  
**Connector**: Power Platform for Admins V2 (Power Automate Management)  
**Operation**: ListFlowsInEnvironment_V2  
**Error Source**: XRM API (Common Data Service/Dataverse backend)  

**Retry Policy**:
```json
{
  "type": "exponential",
  "count": 30,
  "interval": "PT30S"
}
```

### Common Causes

1. **Service Throttling** - Power Platform experiencing high load
2. **Backend Timeout** - XRM API timeout (especially with many flows)
3. **Transient Service Issues** - Temporary connectivity issues
4. **Database Contention** - High concurrent Dataverse access
5. **Environment Load** - Target environment has very large number of flows

### Diagnostic Questions

When gathering more information, ask:

1. How frequently does this error occur? (What % of flow runs?)
2. Is it happening at specific times of day?
3. Does it affect all environments or just specific ones?
4. Have you tried resubmitting the flow?
5. What is your CoE Starter Kit version?
6. How many flows do you have in the affected environment(s)?
7. Are you running full inventory or incremental inventory?

### Decision Tree

```
Does error occur on every attempt for 24+ hours?
├─ Yes → Check service health, escalate if platform issue
└─ No → Expected transient error
    ├─ Occurs frequently (>5% of runs) → Enable delay setting, schedule off-peak
    └─ Occurs rarely (<2% of runs) → Normal, no action needed
```

### Related GitHub Issues

Search for similar issues using keywords:
- "XRM API"
- "Unexpected error"
- "List_Flows_as_Admin"
- "Admin Sync Template Flows"

### Microsoft Learn References

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Power Platform API Limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)
- [Power Platform for Admins V2 Connector](https://learn.microsoft.com/connectors/powerplatformforadmins/)

---

## Closing Statement (If Resolving Issue)

I'm closing this issue as this is **expected behavior** - a transient backend service error that should resolve through:
1. Automatic retries (already built into the flow)
2. Manual resubmission
3. Waiting and retrying during off-peak hours

The flow already includes optimal error handling (30 retries with exponential backoff). This is not a bug in the CoE Starter Kit.

Please follow the troubleshooting guide and feel free to re-open if:
- The error persists after trying the resolution steps
- It occurs consistently (every attempt for 24+ hours)
- Multiple environments are affected

For questions about the CoE Starter Kit or to report new issues, please use the [issue templates](https://github.com/microsoft/coe-starter-kit/issues/new/choose).

---

## Example Response for Specific Scenario

### Scenario: User Reports Frequent Failures During Business Hours

Thank you for providing those details! Since you're experiencing this error frequently during business hours (9 AM - 5 PM), this is likely related to **service throttling during peak usage times**.

**Recommended Solution**:

1. **Reschedule your inventory flows to off-peak hours**:
   - Ideal time: 2 AM - 6 AM in your timezone
   - This avoids the peak tenant activity window
   
2. **Enable the delay setting**:
   - Set `admin_DelayObjectInventory` to **Yes**
   - This adds random delays between operations to reduce API pressure

3. **Use incremental inventory** (if not already):
   - Set `admin_FullInventory` to **No**
   - Only syncs flows modified in the last 7 days
   - Reduces API calls significantly

**Expected Result**: Moving to off-peak hours should reduce this error from ~10-15% of runs to <2%.

Please try these changes and let us know if the error rate decreases!

---

## Template Version

- **Version**: 1.0
- **Created**: 2026-01-30
- **Last Updated**: 2026-01-30
- **Related Documentation**: docs/troubleshooting/admin-sync-flows-xrm-api-error.md
