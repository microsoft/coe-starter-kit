# Audit Log Sync Flow Troubleshooting Guide

## Overview
This guide helps administrators troubleshoot and optimize the "Admin | Audit Logs | Sync Audit Logs (V2)" flow to prevent excessive data consumption and service throttling.

## Quick Fix Checklist

If your audit log flow was turned off due to excessive data usage:

### ☑️ Step 1: Verify Environment Variables
Check these environment variables in your CoE environment:

| Variable | Recommended Value | Purpose |
|----------|------------------|---------|
| `admin_AuditLogsMaxPages` | **50** (default) | Limits pagination iterations to prevent excessive API calls |
| `admin_AuditLogsConcurrency` | **5** (default) | Reduces concurrent operations to lower data consumption |
| `admin_AuditLogsMinutestoLookBack` | **60** (updated default) | Reduces time window overlap between runs |
| `admin_AuditLogsUseGraphAPI` | **true** | Uses more efficient Graph API instead of Office 365 Management API |
| `admin_AuditLogsEndTimeMinutesAgo` | **0** (for current data) or **2820** (for complete data) | Controls how far back to start looking for audit logs |

### ☑️ Step 2: Adjust Configuration for Your Needs

#### For High-Volume Tenants (>10,000 apps, >1,000 daily app launches)
```
admin_AuditLogsMaxPages: 20-30
admin_AuditLogsConcurrency: 3-5
admin_AuditLogsMinutestoLookBack: 60
admin_AuditLogsEndTimeMinutesAgo: 2820  (48 hours ago)
Flow Schedule: Every 2 hours
```

#### For Medium-Volume Tenants (1,000-10,000 apps)
```
admin_AuditLogsMaxPages: 50 (default)
admin_AuditLogsConcurrency: 5 (default)
admin_AuditLogsMinutestoLookBack: 60
admin_AuditLogsEndTimeMinutesAgo: 0  (current)
Flow Schedule: Every 1 hour
```

#### For Low-Volume Tenants (<1,000 apps)
```
admin_AuditLogsMaxPages: 100
admin_AuditLogsConcurrency: 10
admin_AuditLogsMinutestoLookBack: 60
admin_AuditLogsEndTimeMinutesAgo: 0
Flow Schedule: Every 1 hour
```

### ☑️ Step 3: Enable Graph API
1. Navigate to your CoE environment
2. Find environment variable `admin_AuditLogsUseGraphAPI`
3. Set current value to `true`
4. Save changes

**Why?** Graph API provides better filtering and more efficient data retrieval than the Office 365 Management API.

### ☑️ Step 4: Test Flow
1. Turn on the "Admin | Audit Logs | Sync Audit Logs (V2)" flow
2. Trigger a manual run
3. Monitor the run:
   - Should complete in < 10 minutes
   - Check "Actions" count (should be < 10,000 per run)
   - Verify no loops hit maximum iterations

### ☑️ Step 5: Monitor for 24 Hours
- Check flow runs every few hours
- Look for any failures or timeouts
- Verify data is being synced correctly
- Monitor action consumption in Power Platform admin center

## Understanding the Environment Variables

### admin_AuditLogsMaxPages
**What it does**: Controls maximum number of times the flow will paginate through audit log results.

**Impact**:
- Higher values = More complete data but higher consumption
- Lower values = Less data consumption but may miss some events

**Calculation**:
- Graph API: `MaxPages × 500 records per page = max records per run`
- Office 365 API: `MaxPages × variable content IDs per page`

**Example**: With MaxPages=50 and Graph API, you can retrieve up to 25,000 audit log records per run.

### admin_AuditLogsConcurrency
**What it does**: Controls how many audit log events are processed simultaneously.

**Impact**:
- Higher values = Faster processing but more Dataverse operations
- Lower values = Slower processing but reduced load

**Recommendation**: 
- Start with 5
- Increase to 10 if flow takes too long and you have available API capacity
- Decrease to 3 if experiencing throttling

### admin_AuditLogsMinutestoLookBack
**What it does**: Determines the time window for retrieving audit logs.

**Impact**:
- Larger window = More events retrieved per run
- With hourly schedule, default 60 minutes means minimal overlap

**Best Practice**:
- For hourly runs: Use 60 minutes
- For 2-hour runs: Use 120 minutes
- For 4-hour runs: Use 240 minutes

### admin_AuditLogsEndTimeMinutesAgo
**What it does**: Sets how far back from "now" to end the audit log query.

**Trade-offs**:
- **Value: 0** (default)
  - ✅ Gets most recent data
  - ❌ May miss logs (they can take up to 48 hours to appear)
  - ✅ Best for real-time monitoring
  
- **Value: 2820** (48 hours ago)
  - ✅ Gets complete data (all logs should be available)
  - ❌ Data is always 48 hours old
  - ✅ Best for compliance and complete historical records

**Recommendation**: 
- Use 0 if you need near real-time visibility
- Use 2820 if you need guaranteed complete data

## Common Issues and Solutions

### Issue 1: Flow Keeps Timing Out
**Symptoms**: Flow runs exceed 1 hour, multiple retry attempts

**Solutions**:
1. Reduce `admin_AuditLogsMaxPages` to 20-30
2. Reduce `admin_AuditLogsConcurrency` to 3
3. Change flow schedule to run every 2 hours
4. Enable Graph API if not already enabled

### Issue 2: Missing Audit Log Events
**Symptoms**: Some app launches or deletions not recorded

**Solutions**:
1. Increase `admin_AuditLogsMaxPages` (try 100)
2. Verify `admin_AuditLogsEndTimeMinutesAgo` setting:
   - If set to high value (e.g., 2820), it will take 48 hours to see new events
   - Consider setting to 0 for real-time data
3. Check if audit logging is enabled in Microsoft 365 admin center
4. Verify flow is running on schedule

### Issue 3: Excessive API Consumption
**Symptoms**: Platform limits reached, flow automatically disabled

**Solutions**:
1. **Immediate**: 
   - Set `admin_AuditLogsMaxPages` to 20
   - Set `admin_AuditLogsConcurrency` to 3
   - Change schedule to every 2-4 hours
   
2. **Short-term**:
   - Enable Graph API
   - Set `admin_AuditLogsEndTimeMinutesAgo` to 2820
   - Monitor consumption for 1 week
   
3. **Long-term**:
   - Consider if you need all audit log events
   - Review retention policies
   - Implement data archiving strategy

### Issue 4: Duplicate Audit Log Records
**Symptoms**: Same event recorded multiple times

**Solutions**:
1. Reduce `admin_AuditLogsMinutestoLookBack` to 60
2. Ensure flow is not running more frequently than the lookback window
3. Check for manually triggered runs overlapping with scheduled runs

### Issue 5: Graph API Queries Taking Too Long
**Symptoms**: "WaitUntilQueryFinished" loop times out

**Solutions**:
1. This is expected for large data volumes (Graph API can take 30-60 minutes to prepare results)
2. Reduce the time window by adjusting `admin_AuditLogsMinutestoLookBack`
3. Consider splitting into multiple flows for different time ranges
4. Fallback: Disable Graph API temporarily (`admin_AuditLogsUseGraphAPI = false`)

## Monitoring Best Practices

### Daily Checks
- [ ] Verify flow ran successfully
- [ ] Check run duration (should be < 10 minutes for most tenants)
- [ ] Spot check audit log data in Power Apps for accuracy

### Weekly Checks
- [ ] Review total API consumption in Power Platform admin center
- [ ] Check for any failed flow runs
- [ ] Verify audit log count trends (should be relatively stable)

### Monthly Checks
- [ ] Review and optimize configuration based on actual usage
- [ ] Clean up old audit log records if needed
- [ ] Update documentation with any configuration changes

## Data Consumption Estimation

Use this table to estimate your data consumption:

| Tenant Size | Apps | Daily Launches | Estimated API Calls/Day | Recommended MaxPages |
|-------------|------|----------------|------------------------|---------------------|
| Small | <500 | <1,000 | <50,000 | 100 |
| Medium | 500-5,000 | 1,000-10,000 | 50,000-500,000 | 50 |
| Large | 5,000-20,000 | 10,000-50,000 | 500,000-2,000,000 | 30 |
| Enterprise | >20,000 | >50,000 | >2,000,000 | 20 |

**Note**: These are estimates. Monitor your actual consumption and adjust accordingly.

## Emergency Response Procedure

If your flow is consuming excessive data and needs immediate intervention:

### Step 1: Stop the Flow (1 minute)
1. Navigate to Power Automate
2. Find "Admin | Audit Logs | Sync Audit Logs (V2)"
3. Turn off the flow

### Step 2: Assess the Situation (5 minutes)
1. Check last flow run history
2. Look for loops that hit maximum iterations
3. Check total actions executed
4. Note the time window that was being processed

### Step 3: Apply Emergency Settings (5 minutes)
Set these conservative values:
```
admin_AuditLogsMaxPages: 10
admin_AuditLogsConcurrency: 3
admin_AuditLogsMinutestoLookBack: 60
admin_AuditLogsEndTimeMinutesAgo: 2820
admin_AuditLogsUseGraphAPI: true
```

### Step 4: Test with Manual Run (10 minutes)
1. Turn on the flow
2. Trigger a manual run
3. Monitor closely
4. Verify it completes in < 5 minutes

### Step 5: Resume Normal Operations (ongoing)
1. If test successful, keep flow on with hourly schedule
2. Monitor for 24 hours
3. Gradually increase limits if needed
4. Document the incident and resolution

## Getting Help

### CoE Starter Kit Community
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Community Forums](https://powerusers.microsoft.com/)

### Microsoft Support
- For platform throttling issues: Open support ticket with Microsoft
- Include flow run URLs and error messages
- Reference this troubleshooting guide

### Recommended Next Steps
1. Review the [Audit Log Data Consumption Analysis](./AUDIT_LOG_DATA_CONSUMPTION_ANALYSIS.md)
2. Implement the phased improvements outlined in the analysis
3. Join the CoE Starter Kit community for ongoing support

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-10-28 | Created troubleshooting guide | Address excessive data consumption issue |
| 2025-10-28 | Added environment variables for MaxPages and Concurrency | Provide configuration controls for administrators |
| 2025-10-28 | Updated default MinutestoLookBack from 65 to 60 | Reduce overlap between hourly runs |
| 2025-10-28 | Reduced default MaxPages from 5000/100 to 50 | Prevent excessive pagination |
| 2025-10-28 | Reduced default Concurrency from 25 to 5 | Lower parallel operations load |

## FAQ

**Q: Will reducing MaxPages cause me to miss audit log events?**
A: Only if your tenant generates more events than the limit. With MaxPages=50 and Graph API, you can retrieve 25,000 events per hour, which is sufficient for most tenants. Monitor your first few runs to ensure coverage.

**Q: Should I use Graph API or Office 365 Management API?**
A: Graph API is recommended. It's more efficient and provides better filtering. Office 365 Management API should only be used if Graph API is not available or not working in your region.

**Q: How do I know if my settings are optimal?**
A: Monitor flow runs for 1 week. Optimal settings will:
- Complete in < 10 minutes
- Not hit pagination limits (check for "Until" loops reaching maximum count)
- Capture all expected audit events
- Stay well below platform API limits

**Q: Can I disable audit log sync entirely?**
A: Yes, but you'll lose visibility into app usage patterns. Consider reducing frequency (e.g., daily) instead of disabling completely.

**Q: What happens to audit log data older than my retention period?**
A: The flow doesn't automatically delete old data. You may want to create a separate flow or manual process to archive or delete records older than your retention policy (e.g., 90 days).
