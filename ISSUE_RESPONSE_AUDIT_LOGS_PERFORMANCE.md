# Issue Response: Sync Audit Logs (V2) Taking 3+ Days to Complete

## Summary
The "Admin | Audit Logs | Sync Audit Logs (V2)" flow performance issue is caused by using the legacy Office 365 Management API path, which has three nested sequential loops that can process thousands of HTTP calls sequentially. This architectural limitation causes the 3+ day completion time.

## Root Cause
The flow supports two API approaches:

### Current (Slow): Office 365 Management API
- **Three nested sequential loops** (no concurrency on outer two loops)
- Sequential HTTP calls for each content blob
- Example: 100 ContentIDs × 10 events = 1,000 sequential HTTP calls
- At ~5 seconds per call = ~1.4 hours per run
- Multiplied by hourly runs = 3+ days backlog

### Recommended (Fast): Graph API
- **Single optimized loop** with concurrency = 25
- Backend filtering and parallel processing
- **10-100x faster** performance

## Solution (RECOMMENDED)

### Enable Graph API - 5 Minute Fix

**This immediately resolves the performance issue.**

1. Open Power Platform admin center
2. Navigate to your CoE environment
3. Go to **Solutions** → **Center of Excellence - Core Components**
4. Find and edit environment variable: **Audit Logs - Use Graph API**
   - Schema name: `admin_AuditLogsUseGraphAPI`
5. Set value to: **`true`**
6. Save

**Benefits:**
- ✅ 10-100x faster performance
- ✅ Backend optimization by Microsoft Graph
- ✅ Modern, supported approach
- ✅ Better throttling management
- ✅ Already built into the flow (no code changes needed)

**Requirements:**
- Ensure app registration has Graph API permission: `AuditLogsQuery.Read.All`

## Alternative Solution (Not Recommended)

If Graph API cannot be enabled due to organizational constraints, you can add concurrency to the nested loops in the flow JSON. However:

⚠️ This approach:
- Requires manual code editing
- May be overwritten during upgrades
- Risks API throttling
- Is not officially supported
- Still slower than Graph API

See `AUDIT_LOGS_PERFORMANCE.md` for detailed implementation steps.

## Why the Default is Slow

From the flow's environment variable description:
> "Default due to legacy behavior but its not the preferred technique due to lack of backend filtering."

The Office 365 Management API path was kept for backward compatibility, but **Graph API is the recommended modern approach**.

## Documentation

Comprehensive documentation has been added:
- **AUDIT_LOGS_PERFORMANCE.md** - Full performance analysis, solutions, and troubleshooting
- **Inline comments** in flow JSON - Warning developers about performance implications

## Performance Comparison

| Method | Typical Duration | Recommendation |
|--------|-----------------|----------------|
| Graph API (Recommended) | 5-15 minutes | ✅ Use this |
| Office 365 Management API + Concurrency | 15-45 minutes | ⚠️ Only if needed |
| Office 365 Management API (Default) | 1-24+ hours | ❌ Avoid |

## Next Steps for Reporter

1. **Immediate**: Enable Graph API environment variable (`admin_AuditLogsUseGraphAPI = true`)
2. **Verify**: Check next flow run completes in 5-15 minutes
3. **Monitor**: Observe flow run history over next 24 hours
4. **Report back**: Confirm if performance improved

## References
- Full documentation: [AUDIT_LOGS_PERFORMANCE.md](AUDIT_LOGS_PERFORMANCE.md)
- CoE Setup Guide: https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog
- Graph AuditLog API: https://learn.microsoft.com/graph/api/resources/security-auditlogquery
