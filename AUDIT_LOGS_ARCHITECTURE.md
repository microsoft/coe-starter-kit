# Audit Logs V2 Flow Architecture Comparison

## Office 365 Management API Path (Default - SLOW)

```
┌─────────────────────────────────────────────────────────────┐
│  Sync Audit Logs (V2) - Office 365 Management API Path     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌─────────────────────────────────────────┐
        │  LoopContentIDs (Outer Loop)            │
        │  ⚠️ SEQUENTIAL - No Concurrency         │
        │  Processes: 100-1000+ ContentIDs        │
        └──────────────┬──────────────────────────┘
                       │ For each ContentID...
                       ▼
        ┌─────────────────────────────────────────┐
        │  GetAndProcessEvents (Middle Loop)       │
        │  🔴 BOTTLENECK - SEQUENTIAL              │
        │  Makes HTTP call for each ContentID      │
        │  Processes: 1-50 events per ContentID    │
        └──────────────┬──────────────────────────┘
                       │ For each event...
                       ▼
        ┌─────────────────────────────────────────┐
        │  Apply_to_each_Audit_Log (Inner Loop)   │
        │  ✅ Parallel - Concurrency = 25          │
        │  Updates Dataverse records               │
        └─────────────────────────────────────────┘

Performance Calculation:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
100 ContentIDs × 10 events each = 1,000 sequential HTTP calls
At ~5 seconds per call = 5,000 seconds ≈ 1.4 hours
Running hourly over days = 3+ days backlog ❌
```

## Graph API Path (Recommended - FAST)

```
┌─────────────────────────────────────────────────────────────┐
│  Sync Audit Logs (V2) - Graph API Path                     │
│  Environment Variable: admin_AuditLogsUseGraphAPI = true    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌─────────────────────────────────────────┐
        │  Submit AuditLogQuery to Graph API      │
        │  Backend processing by Microsoft Graph   │
        │  Filtering and optimization server-side  │
        └──────────────┬──────────────────────────┘
                       │
                       ▼
        ┌─────────────────────────────────────────┐
        │  Wait for query completion (async)       │
        │  Polling with 60-second intervals        │
        │  Typical wait: 1-5 minutes               │
        └──────────────┬──────────────────────────┘
                       │
                       ▼
        ┌─────────────────────────────────────────┐
        │  Retrieve paginated results              │
        │  $top=500 records per page               │
        │  Automatic pagination handling           │
        └──────────────┬──────────────────────────┘
                       │
                       ▼
        ┌─────────────────────────────────────────┐
        │  ApplyEvents (Single Loop)               │
        │  ✅ Parallel - Concurrency = 25          │
        │  Processes all events efficiently        │
        │  Updates Dataverse records               │
        └─────────────────────────────────────────┘

Performance:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Backend filtering + Single parallel loop
Typical completion: 5-15 minutes ✅
10-100x faster than Office 365 Management API
```

## Key Differences

| Aspect | Office 365 Management API | Graph API |
|--------|---------------------------|-----------|
| **Loop Nesting** | 3 nested loops | 1 single loop |
| **Concurrency** | Sequential at 2 levels | Parallel (25) |
| **HTTP Calls** | 1000+ sequential calls | 1 query + pagination |
| **Backend Processing** | None (client-side) | Yes (server-side filtering) |
| **Typical Duration** | 1-24+ hours | 5-15 minutes |
| **Performance** | ❌ Poor | ✅ Excellent |
| **Status** | Legacy (backward compatibility) | Modern (recommended) |

## Flow Decision Logic

```
┌─────────────────────────────────────────────┐
│  Sync Audit Logs (V2) Flow Starts          │
└────────────────┬────────────────────────────┘
                 │
                 ▼
        ┌────────────────────┐
        │ Check Environment  │
        │ Variable:          │
        │ admin_Audit        │
        │ LogsUseGraphAPI    │
        └────────┬───────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
    true              false
    (Fast)         (Slow - Default)
        │                 │
        ▼                 ▼
┌───────────────┐  ┌──────────────────┐
│  Graph API    │  │  Office 365      │
│  Path         │  │  Management API  │
│  (Optimized)  │  │  Path            │
│               │  │  (3 nested loops)│
│  5-15 min     │  │  1-24+ hours     │
└───────────────┘  └──────────────────┘
```

## Performance Impact Visualization

### Office 365 Management API (Sequential Processing)

```
Time →
Hour 1: |████████████████████████████████████████| Processing...
Hour 2: |████████████████████████████████████████| Processing...
Hour 3: |████████████████████████████████████████| Processing...
...     |████████████████████████████████████████| Processing...
Day 3:  |████████████████████████████████████████| Still processing...
        ❌ Flow taking 3+ days to complete
```

### Graph API (Parallel Processing)

```
Time →
Min 1-5:  |██████████| Backend processing query
Min 5-15: |████| Retrieving & processing results in parallel
          ✅ Flow completes in 5-15 minutes
```

## Recommendation

**Always enable Graph API** for production use:

```powershell
# Set environment variable
admin_AuditLogsUseGraphAPI = true
```

**Benefits:**
- ✅ 10-100x faster
- ✅ Server-side optimization
- ✅ Single parallel loop
- ✅ Better throttling management
- ✅ Modern, supported approach
- ✅ Scales with tenant size

**Only use Office 365 Management API if:**
- You have specific organizational constraints
- Graph API permissions cannot be granted
- You understand the performance implications

---

For implementation details and troubleshooting, see [AUDIT_LOGS_PERFORMANCE.md](AUDIT_LOGS_PERFORMANCE.md)
