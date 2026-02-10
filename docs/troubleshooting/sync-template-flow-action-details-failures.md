# Troubleshooting: Sync Template Flow Action Details Failures

## Issue Description

Users may experience frequent failures with the **Admin | Sync Template v3 (Flow action Details)** flow, specifically on the "Get flow as Admin" action. This can also affect other Sync Template flows that make calls to the Power Automate Management API.

## Symptoms

- Flow runs show failures on "Get flow as Admin" action
- Flow run history shows intermittent failures without clear error patterns
- Errors may include:
  - HTTP 429 (Too Many Requests) - Throttling
  - HTTP 503 (Service Unavailable) - Transient service issues
  - Timeout errors
  - Connection errors

## Root Cause

The Power Automate Management API (and other Power Platform APIs) can experience:
- **Throttling**: When making many API calls in succession, the service may throttle requests
- **Transient failures**: Temporary service issues or network problems
- **Rate limiting**: Service protection limits to ensure platform stability

Without retry policies, these actions fail immediately when encountering such issues, even though they might succeed if retried with exponential backoff.

## Solution

This issue has been resolved by adding **exponential retry policies** to all Power Automate Management API actions in the affected flows.

### What Changed

The following flows have been updated with retry policies:

1. **AdminSyncTemplatev3FlowActionDetails** (3 actions)
   - Get_Flow_as_Admin
   - Get_Flow_Permissions_Check
   - Get_Flow

2. **AdminSyncTemplatev3CoESolutionMetadata** (1 action)
   - ListFlowsInEnvironment_V2

3. **AdminSyncTemplatev4BYODLFlowProperties** (1 action)
   - ListFlowsInEnvironment_V2

4. **AdminSyncTemplatev4Flows** (1 action)
   - ListFlowsInEnvironment_V2

### Retry Policy Configuration

All Flow Management API actions now include:

```json
{
  "retryPolicy": {
    "type": "exponential",
    "count": 10,
    "interval": "PT10S"
  }
}
```

This means:
- **Type**: Exponential backoff (delays increase exponentially between retries)
- **Count**: Up to 10 retry attempts
- **Interval**: Starting with 10 seconds between first retry

With exponential backoff, the retry intervals will be approximately:
- 1st retry: ~10 seconds
- 2nd retry: ~20 seconds
- 3rd retry: ~40 seconds
- And so on, up to 10 attempts

## How to Apply the Fix

### For New Installations

The fix is included in CoE Starter Kit versions **after January 2026**. No action needed.

### For Existing Installations

To apply this fix to your existing CoE Starter Kit installation:

1. **Upgrade to the latest version** of the Core Components solution
   - Download the latest release from [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
   - Follow the [upgrade guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

2. **Import the solution**
   - The retry policies will be applied automatically when you import the updated solution
   - No manual configuration is required

3. **Verify the fix**
   - After upgrade, check the flow run history
   - Failures should significantly decrease
   - Any remaining failures will show multiple retry attempts in the run history

## Expected Behavior After Fix

- **Improved reliability**: Transient failures will be automatically retried
- **Better resilience**: API throttling will be handled gracefully
- **Fewer flow failures**: Most temporary issues will be resolved automatically
- **Longer run times**: Flows may take longer to complete if retries are needed, but this is expected behavior

## When to Seek Additional Help

Contact support or create a GitHub issue if:

1. **Persistent failures** continue after upgrade despite retry attempts
2. **All retry attempts fail** consistently (check flow run details for error messages)
3. **New error patterns** emerge that are different from throttling/transient issues
4. **Performance issues** occur due to excessive retry attempts

## Related Documentation

- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Power Platform API Limits and Throttling](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)
- [Power Automate Retry Policies](https://learn.microsoft.com/azure/logic-apps/logic-apps-exception-handling#retry-policies)
- [Troubleshooting CoE Starter Kit](../../TROUBLESHOOTING-UPGRADES.md)

## Additional Information

### Why Retry Policies Are Important

Power Platform APIs are shared services that implement service protection to ensure fair usage across all tenants. This means:

- **Rate limits**: A maximum number of requests per time period
- **Throttling**: Automatic slowdown when limits are approached
- **Service protection**: Temporary blocks when excessive requests are detected

Retry policies allow flows to:
- Automatically handle these protection mechanisms
- Wait for service capacity to become available
- Succeed without manual intervention

### Best Practices

1. **Monitor flow runs**: Check the flow run history regularly to identify patterns
2. **Review retry attempts**: Look at the action details to see how many retries were needed
3. **Adjust sync schedules**: If consistent throttling occurs, consider spreading out flow runs
4. **Report persistent issues**: If errors continue despite retries, investigate further

---

**Last Updated**: February 2026  
**Applies to**: CoE Starter Kit Core Components v4.50.6 and earlier
