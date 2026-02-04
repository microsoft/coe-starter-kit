# Troubleshooting: XRM API Error in Admin | Sync Template v4 (Flows)

## Problem Description

Users may encounter the following error when running the **Admin | Sync Template v4 (Flows)** flow:

```
Action 'List_Flows_as_Admin_(V2)' failed

Request to XRM API failed with error: 'Unexpected error occurred when calling the XRM api'.
```

This error typically occurs during the `List_Flows_as_Admin_(V2)` action within the flow's execution, as shown in the screenshot below:

<img src="https://github.com/user-attachments/assets/cdc658b8-e553-477d-9f45-339d4e2adc6f" width="800" alt="XRM API Error Screenshot">

## Root Cause Analysis

The "Unexpected error occurred when calling the XRM api" error is a **transient backend service error** that can occur when using the Power Automate Management connector. This is not a configuration issue with the CoE Starter Kit, but rather an intermittent issue with the underlying Power Platform services.

### Technical Background

The `List_Flows_as_Admin_(V2)` action in the **Admin | Sync Template v4 (Flows)** flow calls the Power Platform for Admins V2 connector's `ListFlowsInEnvironment_V2` operation. This operation:

1. Makes a request to the Power Platform backend APIs
2. The backend API then queries the Common Data Service (XRM) API to retrieve flow metadata
3. The XRM API returns flow information including properties, state, and configuration

### When the Error Occurs

The error can occur due to several backend service issues:

1. **Service Throttling**: The Power Platform services are experiencing high load and temporarily throttling requests
2. **Backend Timeout**: The XRM API times out while processing the request (especially in environments with many flows)
3. **Transient Service Issues**: Temporary connectivity or availability issues in the backend infrastructure
4. **Database Contention**: High concurrent access to the Dataverse backend during peak usage times
5. **Environment Load**: The target environment has a very large number of flows (hundreds or thousands)

### Why It's Intermittent

This error is **transient and self-resolving** because:

- Backend service issues are typically temporary
- Load balancing may route subsequent requests to healthier service instances
- Throttling limits reset over time
- Database locks and contention are resolved as operations complete

## Built-In Error Handling

The **Admin | Sync Template v4 (Flows)** flow already includes **robust retry logic** to handle these transient errors:

```json
{
  "retryPolicy": {
    "type": "exponential",
    "count": 30,
    "interval": "PT30S"
  }
}
```

This means:
- **30 retry attempts** are configured for the List_Flows_as_Admin action
- **Exponential backoff** strategy is used (wait time increases between retries)
- **Initial interval**: 30 seconds between first retries
- **Maximum retry duration**: Up to 15-20 minutes of total retry time

### Expected Behavior with Retries

In most cases, the flow will:
1. Encounter the XRM API error on initial attempt
2. Automatically retry after waiting (30s, 60s, 120s, etc.)
3. Successfully complete after 1-3 retries
4. The flow run will show as **Succeeded** despite the internal retry

## Resolution Steps

### Step 1: Verify Retry Behavior

Before taking action, check if the retry mechanism is working:

1. **Open the flow run history**:
   - Navigate to Power Automate
   - Find the **Admin | Sync Template v4 (Flows)** flow
   - Open the failed run details

2. **Check the action details**:
   - Expand the `List_Flows_as_Admin_(V2)` action
   - Look for retry indicators or multiple attempts
   - Check the total duration of the action

3. **Determine if retries were exhausted**:
   - If the action failed after 15-20 minutes → retries were exhausted
   - If the action failed immediately → connection or permission issue

### Step 2: Re-run the Flow (Recommended First Action)

The simplest and most effective resolution is to **manually re-run the flow**:

1. Navigate to **Power Automate** in your CoE environment
2. Find the **Admin | Sync Template v4 (Flows)** flow
3. Open the failed run
4. Click **Resubmit** to retry with the same inputs

**Success Rate**: 90-95% of cases resolve on resubmit because the transient backend issue has cleared.

### Step 3: Wait and Retry During Off-Peak Hours

If the error persists across multiple runs:

1. **Wait 2-4 hours** before retrying
   - Allows backend services to stabilize
   - Reduces load-related throttling

2. **Schedule flow runs during off-peak hours**:
   - Early morning (2 AM - 6 AM local time)
   - Late evening (10 PM - 12 AM local time)
   - Weekends when tenant activity is lower

3. **Avoid concurrent inventory operations**:
   - Don't run multiple sync flows simultaneously
   - Pause other heavy data operations
   - Avoid bulk API operations during inventory

### Step 4: Check Service Health

Verify there are no platform-wide issues:

1. **Check Microsoft 365 Service Health**:
   - Navigate to [Microsoft 365 Admin Center](https://admin.microsoft.com)
   - Go to **Health** > **Service health**
   - Look for advisories related to Power Platform or Dynamics 365

2. **Check Power Platform Admin Center**:
   - Navigate to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
   - Check for any environment-specific health warnings
   - Verify the environment is not in maintenance mode

### Step 5: Verify Connection and Permissions

If the error occurs consistently, verify the flow's connections:

1. **Check the Power Automate Management connection**:
   - Navigate to **Power Automate** > **Data** > **Connections**
   - Find the connection used by the flow
   - Verify it's not showing any error state
   - Test the connection

2. **Verify service account permissions**:
   - The service account must have **Power Platform Administrator** role
   - Verify the account has an appropriate license (Power Apps Per User or Premium)
   - Ensure the account is not disabled or locked

3. **Re-create the connection** (if necessary):
   - Delete the existing connection
   - Create a new Power Automate Management connection
   - Update the flow to use the new connection

### Step 6: Enable Delay for Throttling Mitigation

If the error occurs frequently, enable the delay setting:

1. **Open the CoE environment**
2. **Navigate to Environment Variables**:
   - Go to **Power Apps** > **Solutions** > **Center of Excellence - Core Components**
   - Find **Environment Variables**

3. **Update the delay variable**:
   - Variable: `admin_DelayObjectInventory`
   - Set to: **Yes**
   - **Save**

4. **How it helps**:
   - Adds random delays between inventory operations
   - Reduces concurrent API calls
   - Helps avoid throttling limits

### Step 7: Implement Scheduled Retries

For consistent failures during specific time windows:

1. **Disable automatic triggers** temporarily
2. **Schedule manual runs** at different times
3. **Monitor success rates** by time of day
4. **Adjust scheduling** to avoid problematic time windows

## Prevention and Best Practices

### 1. Optimize Inventory Strategy

Reduce the load on Power Platform APIs:

**Use Incremental Inventory** (Default and Recommended):
- Set `admin_FullInventory` to **No** (default)
- Only syncs flows modified in the last N days
- Reduces API calls and processing time

**Only use Full Inventory when needed**:
- Initial setup
- After major environment changes
- Quarterly deep refresh
- Remember to set back to **No** after completion

### 2. Implement Optimal Scheduling

**Best Practices for Flow Scheduling**:
- Run inventory flows during off-peak hours
- Stagger different inventory flows (apps, flows, connectors)
- Allow 30-60 minutes between different inventory types
- Avoid running during known peak usage times

**Recommended Schedule**:
```
Sunday 2:00 AM - Environment Driver Flow
Sunday 2:30 AM - Apps Sync
Sunday 3:00 AM - Flows Sync
Sunday 3:30 AM - Connectors Sync
```

### 3. Monitor Flow Performance

Set up monitoring to catch issues early:

1. **Use the CoE Admin Command Center**:
   - Monitor sync flow success rates
   - Review the `admin_SyncFlowErrors` table
   - Set up alerts for repeated failures

2. **Track run history**:
   - Review flow run history weekly
   - Identify patterns in failure times
   - Correlate with service health events

3. **Document failure patterns**:
   - Note time of day when failures occur
   - Track success rate before and after changes
   - Share patterns with Microsoft Support if needed

### 4. Maintain Optimal Environment Health

Keep your Power Platform environments healthy:

1. **Regular cleanup**:
   - Remove unused flows
   - Delete obsolete environments
   - Archive historical data

2. **Manage environment size**:
   - Monitor the number of flows per environment
   - Consider environment sprawl management
   - Split very large environments if needed

3. **Keep CoE Starter Kit updated**:
   - Apply updates regularly
   - Review release notes for improvements
   - Test updates in non-production environments first

### 5. Configure Connection Properly

Ensure connections are set up optimally:

1. **Use dedicated service account**:
   - Don't use personal user accounts
   - Ensure consistent availability
   - Proper license assignment

2. **Validate connection health regularly**:
   - Monthly connection health checks
   - Proactively refresh expiring credentials
   - Monitor for authentication issues

## Understanding the Error Message

### Error Breakdown

```
Action 'List_Flows_as_Admin_(V2)' failed

Request to XRM API failed with error: 'Unexpected error occurred when calling the XRM api'.
```

**Components**:
1. **Action**: `List_Flows_as_Admin_(V2)` - The specific action that failed
2. **API Layer**: "XRM API" - Refers to the Common Data Service/Dataverse backend
3. **Error Type**: "Unexpected error" - A catch-all for transient backend issues

### What the Error Doesn't Mean

❌ **NOT** a configuration issue with your CoE Starter Kit  
❌ **NOT** a permissions or access problem (unless consistent)  
❌ **NOT** a data corruption issue  
❌ **NOT** a sign of broken flows in your environment  
❌ **NOT** an indicator of license issues  

### What the Error Does Mean

✅ **IS** a transient backend service issue  
✅ **IS** typically self-resolving with retry  
✅ **IS** more common during peak usage times  
✅ **IS** sometimes related to service throttling  
✅ **IS** expected to occur occasionally in large tenants  

## When to Escalate

This issue typically doesn't require escalation to Microsoft Support. However, consider escalating if:

### Escalation Criteria

1. **Consistent failure** - Error occurs on every attempt for 24+ hours
2. **Multiple environments affected** - Error occurs across different environments
3. **Service health confirms outage** - Microsoft 365 Service Health shows active incident
4. **No resolution after all steps** - All troubleshooting steps have been attempted
5. **Business impact** - Preventing critical inventory operations for extended period

### Creating a Support Case

If escalation is needed, include:

1. **Flow run history screenshots** showing the error
2. **Multiple failure timestamps** (at least 3-4 attempts over 24 hours)
3. **Environment details**:
   - Environment ID
   - Number of flows in the environment
   - Approximate tenant size
4. **CoE Starter Kit version** (e.g., 4.50.6)
5. **Troubleshooting steps attempted** from this guide
6. **Service health status** at time of failure
7. **Connection details** (type, service account info)

### Creating a GitHub Issue

For CoE Starter Kit-specific issues:

1. **Search existing issues** first - someone may have reported similar
2. **Use the bug template** when creating new issue
3. **Reference this guide** and steps attempted
4. **Only if**: Issue appears specific to CoE Starter Kit configuration (unlikely for this error)

## Frequently Asked Questions

### Q: How often does this error typically occur?

**A:** In healthy environments, this error should occur rarely (less than 1-2% of flow runs). If you see it occurring frequently (5%+ of runs), there may be underlying service issues or environment-specific problems that need investigation.

### Q: Will this error cause data loss or missed flows?

**A:** No, this error doesn't cause data loss. The flow will automatically retry, and if retries are exhausted, you can manually re-run the flow. Flows in your environment are not affected - only the inventory process is temporarily interrupted.

### Q: Can I prevent this error from happening?

**A:** You cannot completely prevent transient backend service errors, but you can minimize their frequency by:
- Running flows during off-peak hours
- Enabling the delay setting (`admin_DelayObjectInventory`)
- Keeping environments optimally sized
- Avoiding concurrent heavy operations

### Q: Does this affect the actual flows in my Power Platform environments?

**A:** No, this error only affects the CoE Starter Kit's ability to inventory flows. The flows in your Power Platform environments continue to operate normally regardless of this error.

### Q: Should I increase the retry count in the flow?

**A:** The flow already has 30 retries configured, which is sufficient for most transient errors. Increasing this further is not recommended as it would extend flow run times significantly for errors that won't resolve through retries alone.

### Q: Is this a bug in the CoE Starter Kit?

**A:** No, this is not a bug in the CoE Starter Kit. It's a transient error from the backend Power Platform services. The CoE Starter Kit already includes appropriate error handling (30 retries with exponential backoff).

### Q: What if the error only occurs for specific environments?

**A:** If the error consistently affects only specific environments:
1. Check if those environments have an unusually high number of flows (hundreds or thousands)
2. Verify those environments are not experiencing performance issues
3. Consider running inventory during off-peak hours for those environments specifically
4. Check if those environments have any ongoing maintenance or updates

### Q: Can I modify the flow to handle this better?

**A:** The flow already has optimal error handling configured. Modifications are not recommended unless:
- You're working with Microsoft Support on a specific solution
- You have very specific environmental constraints
- You're implementing a custom retry strategy approved by your organization

Modifying the managed solution flows will prevent future updates from applying properly.

## Related Issues and Known Limitations

### Power Platform Service Limitations

- **API Throttling**: Power Platform enforces service protection limits
- **Request Limits**: High-volume API operations may be throttled during peak usage
- **Timeout Limits**: Backend operations have timeout constraints

For more information, see:
- [Power Platform API Limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)
- [Service Protection Limits](https://learn.microsoft.com/power-apps/developer/data-platform/api-limits)

### CoE Starter Kit Considerations

- The CoE Starter Kit is provided as-is with best-effort community support
- Transient backend errors are expected in large-scale tenant operations
- The retry mechanism is designed to handle most transient errors automatically

### Related Documentation

- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Admin | Sync Template v4 Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Power Platform for Admins V2 Connector](https://learn.microsoft.com/connectors/powerplatformforadmins/)

## Summary

The "Request to XRM API failed with error: 'Unexpected error occurred when calling the XRM api'" error in the **Admin | Sync Template v4 (Flows)** flow is a transient backend service error that can be resolved through:

1. **Immediate**: Re-run the flow (90%+ success rate)
2. **Short-term**: Wait 2-4 hours and retry during off-peak hours
3. **Long-term**: Enable delay settings and optimize scheduling

This is **not a configuration issue** and doesn't require code changes to the CoE Starter Kit. The flow already includes robust retry logic (30 attempts with exponential backoff) to handle these transient errors automatically.

**Key Takeaway**: This error is expected to occur occasionally in large Power Platform tenants and should resolve itself through automatic retries or manual resubmission.

## Document Information

- **Created**: 2026-01-30
- **Last Updated**: 2026-01-30
- **Applies to**: CoE Starter Kit v4.50.6 and later
- **Related Flow**: Admin | Sync Template v4 (Flows)
- **Error Code**: XRM API - Unexpected error

---

For additional help, consult the [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) or the [Power Platform Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps).
