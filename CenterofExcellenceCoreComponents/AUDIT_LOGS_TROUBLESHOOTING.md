# Audit Logs Sync Flow - Troubleshooting Guide

## Overview
The "Admin | Audit Logs | Sync Audit Logs (V2)" flow retrieves audit log data from Microsoft 365 to track Power Platform usage and operations. This guide helps you troubleshoot and optimize the flow to prevent excessive data consumption.

## Common Issue: "Flow consuming unusually large amount of data"

### Problem Description
Power Automate may automatically turn off the flow with the message: "It's consuming an unusually large amount of data so it was turned off." This happens when the flow exceeds Microsoft's data transfer limits for flows.

### Root Causes

1. **High-volume audit data**: Organizations with many users and frequent Power Platform activity generate large volumes of audit logs
2. **Unbounded pagination**: Previous versions had very high iteration limits (5000+ iterations)
3. **High concurrency**: Parallel processing of many records simultaneously
4. **Large page sizes**: Retrieving too many records per API call

### Recent Changes to Reduce Data Consumption

The flow has been optimized with the following changes:

#### 1. Reduced Pagination Limits
- **Office 365 Management API path**: Reduced from 5000 to 50 iterations
- **Graph API path**: Reduced from 100 to 20 iterations
- **Timeout**: Reduced from 10 hours to 1 hour for Management API

#### 2. Reduced Page Size
- **Graph API records**: Reduced from $top=500 to $top=100 records per page

#### 3. Lower Concurrency
- **Parallel processing**: Reduced from 25 to 5 concurrent operations
- This prevents excessive simultaneous API calls and data transfer

### Configuration Best Practices

#### Environment Variables to Optimize

**1. Audit Logs - Minutes to Look Back** (`admin_AuditLogsMinutestoLookBack`)
- **Default**: 65 minutes
- **Recommendation**: Keep at 65-75 minutes for hourly runs
- **Impact**: Longer lookback = more data per run

**2. Audit Logs - End Time Minutes Ago** (`admin_AuditLogsEndTimeMinutesAgo`)
- **Default**: 0 (most recent data)
- **Recommendation**: Set to 2820 (48 hours ago) for complete data without processing load
- **Impact**: 
  - `0` = Most current data, but may miss late-arriving logs
  - `2820` = Complete data from 48 hours ago (all logs have arrived), but data is not current

**3. Audit Logs - Use Graph API** (`admin_AuditLogsUseGraphAPI`)
- **Default**: false (uses Office 365 Management API)
- **Recommendation**: Set to `true` to use Graph API for better backend filtering
- **Impact**: Graph API provides better filtering capabilities and may reduce data transfer

### Monitoring and Prevention

#### 1. Monitor Flow Runs
- Check flow run history regularly
- Look for patterns of increased duration or data usage
- Review runs that approach the 1-hour timeout

#### 2. Adjust Trigger Frequency
If data consumption is still high:
- **Current**: Hourly trigger
- **Alternative**: Run every 2-4 hours
- **Trade-off**: Less frequent updates but lower data consumption

#### 3. Filter Audit Data
The flow currently filters for:
- `LaunchPowerApp` operations
- `DeletePowerApp` operations
- Record Type 256 (Power Platform events)

Consider whether you need all these operations or can narrow the scope.

### Troubleshooting Steps

#### Step 1: Check Current Configuration
1. Open the Sync Audit Logs (V2) flow
2. Review the environment variables:
   - `admin_AuditLogsMinutestoLookBack`
   - `admin_AuditLogsEndTimeMinutesAgo`
   - `admin_AuditLogsUseGraphAPI`

#### Step 2: Review Recent Run History
1. Check the last 10-20 flow runs
2. Look for patterns:
   - Are runs consistently approaching timeout?
   - Is the number of API calls increasing?
   - How many audit log records are being processed?

#### Step 3: Implement Recommended Changes

**Option A: Use Graph API (Recommended)**
1. Set `admin_AuditLogsUseGraphAPI` to `true`
2. This provides better backend filtering and may reduce data transfer

**Option B: Delay Processing Window**
1. Set `admin_AuditLogsEndTimeMinutesAgo` to `2820` (48 hours)
2. This ensures complete data but with a delay
3. Reduces likelihood of processing partial data multiple times

**Option C: Reduce Frequency**
1. Change trigger from hourly to every 2-4 hours
2. Adjust `admin_AuditLogsMinutestoLookBack` accordingly:
   - 2-hour runs: Set to 125 minutes
   - 4-hour runs: Set to 245 minutes

#### Step 4: Monitor After Changes
1. Turn the flow back on
2. Monitor for 24-48 hours
3. Check that runs complete successfully within limits
4. Verify audit log data is being captured as expected

### Understanding the Limits

The flow now has these built-in protections:

| Limit Type | Old Value | New Value | Purpose |
|------------|-----------|-----------|---------|
| Management API iterations | 5000 | 50 | Prevent processing too many pages |
| Management API timeout | 10 hours | 1 hour | Force completion within reasonable time |
| Graph API iterations | 100 | 20 | Limit page processing |
| Graph API page size | 500 | 100 | Reduce data per API call |
| Concurrent processing | 25 | 5 | Reduce parallel data transfer |

### When to Contact Support

Contact Microsoft Support or open a GitHub issue if:
1. Flow still gets turned off after implementing recommendations
2. You need to process more than 50 pages of audit data per hour
3. You have specific compliance requirements that require more frequent/comprehensive data collection
4. You experience consistent API throttling or failures

### Additional Resources

- [Microsoft 365 Management Activity API Reference](https://learn.microsoft.com/en-us/office/office-365-management-api/office-365-management-activity-api-reference)
- [Microsoft Graph Audit Log API](https://learn.microsoft.com/en-us/graph/api/resources/security-auditlog-overview)
- [Power Automate Limits and Configuration](https://learn.microsoft.com/en-us/power-automate/limits-and-config)
- [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)

## FAQ

**Q: Will reducing limits cause me to miss audit logs?**
A: No, if properly configured. The flow will process audit logs in smaller batches. You may need to:
- Run more frequently, OR
- Use the Graph API with backend filtering, OR
- Set the lookback window to process older, complete data

**Q: Should I use Graph API or Management API?**
A: Graph API is recommended (`admin_AuditLogsUseGraphAPI = true`) because:
- Better server-side filtering
- More efficient data transfer
- Better handling of large datasets

**Q: My organization has very high audit volumes. What should I do?**
A: Consider:
1. Using Graph API for better filtering
2. Running every 2-4 hours instead of hourly
3. Setting `admin_AuditLogsEndTimeMinutesAgo` to 2820 to process complete 48-hour-old data
4. Implementing a custom solution if you need real-time audit data at very high volumes

**Q: How do I know if my changes are working?**
A: Monitor these indicators:
- Flow runs complete successfully within 30-45 minutes
- No warning messages about data consumption
- Audit log records are still being captured in Dataverse
- No gaps in the audit log timeline

**Q: Can I increase the limits back if needed?**
A: Yes, you can modify the flow JSON directly, but:
- Start with small increases (e.g., 50 → 75 iterations)
- Monitor closely after each change
- Understand the risk of exceeding data limits
- Consider the recommendations in this guide first
