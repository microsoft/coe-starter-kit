# Audit Logs Performance Optimization Guide

## Issue: Sync Audit Logs (V2) Flow Takes Multiple Days to Complete

### Problem Description
The "Admin | Audit Logs | Sync Audit Logs (V2)" flow can take 3+ days to complete when processing large volumes of audit log data, particularly when using the Office 365 Management API path.

### Root Cause Analysis

The flow supports two different API approaches for fetching audit logs:

#### 1. **Graph API Path** (Recommended - Optimized)
- **Status**: Available and recommended
- **Environment Variable**: `admin_AuditLogsUseGraphAPI` = `true`
- **Architecture**: Single optimized loop with concurrency
  - Query is submitted to Graph API backend
  - Graph API processes the query asynchronously
  - Results are retrieved with pagination (500 records per page)
  - Single `ApplyEvents` loop with **concurrency = 25** processes all events
- **Performance**: Significantly faster due to backend filtering and parallel processing

#### 2. **Office 365 Management API Path** (Legacy - Performance Issues)
- **Status**: Legacy, kept for backward compatibility
- **Environment Variable**: `admin_AuditLogsUseGraphAPI` = `false` (default)
- **Architecture**: Three nested loops with limited concurrency
  ```
  LoopContentIDs (Sequential, no concurrency)
    └─ GetAndProcessEvents (Sequential, no concurrency) ← BOTTLENECK
       └─ Apply_to_each_Audit_Log (Parallel, concurrency = 25)
  ```
- **Performance Impact**:
  - **Sequential processing** at two outer loop levels
  - Each iteration requires an HTTP call to fetch content
  - Example calculation for 1 hour of audit logs:
    - 100 ContentIDs × 10 events each = 1,000 sequential HTTP calls
    - At ~5 seconds per HTTP call = 5,000 seconds (~1.4 hours)
    - Flow runs hourly, accumulating over days = 3+ days backlog

### Performance Bottleneck Details

When using the Office 365 Management API:

1. **LoopContentIDs** (Outer Loop)
   - Iterates through content blob identifiers
   - **No concurrency** = Sequential execution
   - Cannot process multiple content IDs in parallel

2. **GetAndProcessEvents** (Middle Loop - CRITICAL BOTTLENECK)
   - Nested inside LoopContentIDs
   - **No concurrency** = Sequential execution
   - Makes HTTP call for each ContentID to fetch events
   - Each HTTP call includes:
     - Network latency
     - Authentication
     - API processing time
     - Retry logic (up to 5 attempts with 30-second waits)
   - This is the primary cause of the 3+ day completion time

3. **Apply_to_each_Audit_Log** (Inner Loop)
   - Processes individual audit log events
   - Has concurrency = 25 (parallel processing)
   - Updates Dataverse records
   - Least impactful on overall performance

## Solutions and Recommendations

### Solution 1: Enable Graph API (RECOMMENDED)

**This is the preferred and officially recommended approach.**

#### Steps:
1. Open your Power Platform admin center
2. Navigate to your CoE environment
3. Go to **Solutions** → **Center of Excellence - Core Components**
4. Find and edit the environment variable: **Audit Logs - Use Graph API**
   - Schema name: `admin_AuditLogsUseGraphAPI`
5. Set the value to: **`true`**
6. Save the changes

#### Benefits:
- ✅ Significantly faster performance (10-100x improvement)
- ✅ Backend filtering and query optimization by Microsoft Graph
- ✅ Single optimized loop with parallel processing (concurrency = 25)
- ✅ Better API throttling management
- ✅ More reliable and scalable architecture
- ✅ This is the modern, supported approach

#### Requirements:
- Ensure your app registration has the required Graph API permissions:
  - `AuditLogsQuery.Read.All` (Application permission)
  - Delegated or Application permission for Graph API access
- The flow already includes the necessary logic to use Graph API

#### Why This Works:
The environment variable description in the flow states:
> "If true, uses the AuditLogQuery api in Graph to gather audit logs. If false (default), continues to use the old Office 365 Management API to gather them. Default due to legacy behavior but its not the preferred technique due to lack of backend filtering."

### Solution 2: Add Concurrency to Office 365 Management API Loops (Alternative)

**Only use this if you cannot enable Graph API due to organizational constraints.**

If you must continue using the Office 365 Management API, you can improve performance by adding concurrency to the nested loops.

#### Limitations:
- Power Automate limits: Maximum 50 concurrent iterations per loop
- API throttling: Office 365 Management API has rate limits
- Recommended starting concurrency: **10** (to avoid throttling)

#### Implementation:
Edit the flow JSON to add concurrency to the sequential loops:

**For LoopContentIDs** (line ~1713):
```json
"LoopContentIDs": {
  "type": "Foreach",
  "foreach": "@variables('ContentIDs')",
  "runtimeConfiguration": {
    "concurrency": {
      "repetitions": 10
    }
  },
  "actions": { ... }
}
```

**For GetAndProcessEvents** (line ~1749):
```json
"GetAndProcessEvents": {
  "type": "Foreach",
  "foreach": "@body('ParseContentIDs')",
  "runtimeConfiguration": {
    "concurrency": {
      "repetitions": 10
    }
  },
  "actions": { ... }
}
```

#### Performance Improvement Estimate:
- With concurrency = 10 on both loops:
  - 100 ContentIDs / 10 = 10 batches
  - 10 events / 10 = 1 batch per ContentID
  - Total time: ~10 × 1 × 5 seconds = 50 seconds (vs. 5000 seconds)
  - **100x faster** than sequential processing

#### Risks and Considerations:
- ⚠️ Higher API throttling risk
- ⚠️ Increased resource consumption
- ⚠️ May require tuning based on tenant size and API limits
- ⚠️ Not officially supported/recommended by Microsoft
- ⚠️ May be overwritten during solution upgrades

### Solution 3: Increase Sync Frequency (Workaround)

If neither solution above is viable:

1. Reduce the audit log lookback window
2. Run the flow more frequently (every 15-30 minutes instead of hourly)
3. Process smaller batches of data per run

Edit environment variables:
- `admin_AuditLogsMinutestoLookBack`: Reduce from 65 to 30 minutes
- Adjust the flow trigger from hourly to every 30 minutes

#### Trade-offs:
- More frequent runs = more API calls = higher resource usage
- Smaller batches = less risk of timeouts
- Still slower than Graph API approach

## Monitoring and Troubleshooting

### How to Check Current Performance:

1. Open Power Automate → **Cloud flows**
2. Find: **Admin | Audit Logs | Sync Audit Logs (V2)**
3. Review run history:
   - Check **Duration** of recent runs
   - Look for runs that exceed 1 hour
   - Identify which path is being used (Graph API vs. Office 365 Management API)

### Performance Indicators:

| Scenario | Expected Duration | Status |
|----------|------------------|--------|
| Graph API path | 5-15 minutes | ✅ Optimal |
| Office 365 Management API with concurrency | 15-45 minutes | ⚠️ Acceptable |
| Office 365 Management API without concurrency | 1-24+ hours | ❌ Poor |

### Troubleshooting Steps:

1. **Verify which API path is being used**:
   - Check the environment variable `admin_AuditLogsUseGraphAPI`
   - Review flow run details to see which branch executed

2. **Check for API throttling**:
   - Look for HTTP 429 errors in flow run history
   - Review retry attempts in the flow logs

3. **Review audit log volume**:
   - High activity tenants generate more audit logs
   - Consider adjusting the lookback window

4. **Check app registration permissions**:
   - Ensure Graph API permissions are granted and consented
   - Verify the client secret or certificate is valid

## Best Practices

1. ✅ **Always enable Graph API** (`admin_AuditLogsUseGraphAPI = true`)
2. ✅ Monitor flow run duration regularly
3. ✅ Adjust lookback window based on tenant activity
4. ✅ Ensure proper Graph API permissions
5. ⚠️ Only use Office 365 Management API if absolutely necessary
6. ⚠️ If using Office 365 Management API, add concurrency carefully
7. ⚠️ Start with low concurrency values (10) and increase gradually

## Related Documentation

- [CoE Starter Kit Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Audit Logs](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Microsoft Graph AuditLog Queries API](https://learn.microsoft.com/graph/api/resources/security-auditlogquery)
- [Office 365 Management Activity API](https://learn.microsoft.com/office/office-365-management-api/office-365-management-activity-api-reference)

## Version Information

- **Flow Name**: Admin | Audit Logs | Sync Audit Logs (V2)
- **Flow ID**: BCCF2957-AE51-EF11-A316-6045BD039C1F
- **Solution**: Center of Excellence - Core Components
- **Introduced Version**: 4.33.14
- **Current Version**: 4.50.1 (as reported in issue)

## Support

This is part of the CoE Starter Kit, which is a community-supported solution.

- Report issues: [CoE Starter Kit GitHub Issues](https://aka.ms/coe-starter-kit-issues)
- For underlying platform issues: Contact Microsoft Support through your standard support channel
