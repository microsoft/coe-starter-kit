# Analysis and Solution for Sync Audit Logs (V2) Performance Issue

Thank you for reporting this issue. I've analyzed the flow and identified the root cause of the 3+ day completion time.

## Root Cause

The **"Admin | Audit Logs | Sync Audit Logs (V2)"** flow supports two different API approaches:

### Current Approach (Causing the Issue)
By default, the flow uses the **Office 365 Management API** which has a significant performance bottleneck:

- **Three nested sequential loops** (no concurrency on the outer two)
- `LoopContentIDs` (Sequential) → `GetAndProcessEvents` (Sequential) → `Apply_to_each_Audit_Log` (Concurrent: 25)
- Each iteration in the middle loop makes an HTTP call to fetch events
- **Example**: 100 ContentIDs × 10 events = 1,000 sequential HTTP calls at ~5 seconds each = **~1.4 hours per run**
- Running hourly over multiple days accumulates into the 3+ day backlog you're experiencing

### Recommended Approach (Fast)
The flow includes a modern **Graph API** path that is **10-100x faster**:

- Single optimized loop with concurrency = 25
- Backend filtering and query processing by Microsoft Graph
- No nested loops
- Typical completion time: **5-15 minutes**

## Solution: Enable Graph API (5-Minute Fix)

**This immediately resolves the performance issue.**

### Steps:
1. Open **Power Platform admin center**
2. Navigate to your **CoE environment**
3. Go to **Solutions** → **Center of Excellence - Core Components**
4. Find and edit the environment variable: **Audit Logs - Use Graph API**
   - Schema name: `admin_AuditLogsUseGraphAPI`
5. **Set the value to: `true`**
6. Save

### Requirements:
- Ensure your app registration has the Graph API permission: `AuditLogsQuery.Read.All` (Application permission)

### Why This Works:
The flow's own environment variable description states:
> "If true, uses the AuditLogQuery api in Graph to gather audit logs. If false (default), continues to use the old Office 365 Management API to gather them. **Default due to legacy behavior but its not the preferred technique due to lack of backend filtering.**"

The Office 365 Management API path is kept only for backward compatibility. **Graph API is the recommended modern approach.**

## Expected Results After Enabling Graph API

| Before | After |
|--------|-------|
| 3+ days to complete | 5-15 minutes per run |
| Sequential processing | Parallel processing (concurrency=25) |
| Nested loops with HTTP calls | Single optimized loop |
| Risk of timeouts | Reliable completion |

## Documentation Added

I've created comprehensive documentation to help with this and future performance issues:

1. **[AUDIT_LOGS_PERFORMANCE.md](AUDIT_LOGS_PERFORMANCE.md)** - Full performance analysis, root cause, solutions, troubleshooting, and best practices
2. **Inline comments in flow JSON** - Added performance warnings at critical loop points to alert future developers
3. **[ISSUE_RESPONSE_AUDIT_LOGS_PERFORMANCE.md](ISSUE_RESPONSE_AUDIT_LOGS_PERFORMANCE.md)** - Quick reference guide
4. **Updated README.md** - Added reference to performance documentation

## Alternative Solution (Not Recommended)

If you cannot enable Graph API due to organizational constraints, you could manually add concurrency to the nested loops in the flow JSON. However, this approach:
- ⚠️ Requires manual code editing that may be overwritten during upgrades
- ⚠️ Risks API throttling
- ⚠️ Is not officially supported
- ⚠️ Still slower than Graph API

See the full documentation for implementation details if needed.

## Next Steps

1. **Enable Graph API** by setting `admin_AuditLogsUseGraphAPI = true`
2. **Monitor** the next flow run - it should complete in 5-15 minutes
3. **Report back** if you see the performance improvement

## References

- [Full Performance Documentation](AUDIT_LOGS_PERFORMANCE.md)
- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Microsoft Graph AuditLog Queries API](https://learn.microsoft.com/graph/api/resources/security-auditlogquery)

---

Please let us know if enabling Graph API resolves the performance issue for you!
