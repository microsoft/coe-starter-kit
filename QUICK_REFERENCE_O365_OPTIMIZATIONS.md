# Quick Reference: O365 Management API Optimizations

## For customers with concurrency already enabled (DOP=25) but still experiencing slow performance

### The Problem
- Graph API cannot be enabled
- Concurrency on both LoopContentIDs and GetAndProcessEvents is already set to 25
- Flow still takes 6+ hours to complete

### The Solution: Multi-Layered Optimization

## Phase 1: Quick Configuration Changes (5 minutes) ✅

**No code changes required - just environment variable adjustments:**

| Setting | Location | Current | Change To | Why |
|---------|----------|---------|-----------|-----|
| Minutes to Look Back | Environment Variable | 65 | **30** | Process 50% less data per run |
| End Time Minutes Ago | Environment Variable | 0 | **60** | More complete audit data (less retries) |
| Flow Recurrence | Flow Trigger | Every 1 hour | **Every 30 minutes** | Smaller, frequent batches |

**How to implement:**
1. Power Platform Admin Center → CoE Environment → Solutions
2. Open "Center of Excellence - Core Components"
3. Edit environment variables:
   - `admin_AuditLogsMinutestoLookBack` → 30
   - `admin_AuditLogsEndTimeMinutesAgo` → 60
4. Edit flow trigger: Change from "1 hour" to "30 minutes"

**Expected result:** Runtime reduces from ~6 hours to ~3 hours per run

---

## Phase 2: Retry Delay Optimization (30 minutes) ⚡

**Requires flow JSON editing:**

### Change 1: Reduce HTTP Retry Wait
Find line ~1796, change:
```json
"count": 30  →  "count": 5
```

### Change 2: Reduce Dataverse Retry Count
Find lines ~1095 and 2041, change:
```json
"count": 20  →  "count": 5
"interval": "PT20S"  →  "interval": "PT5S"
```

**Expected result:** Additional 20-30% time reduction (3 hours → 2.4 hours)

---

## Phase 3: Operation Filtering (45 minutes) 🎯

**Add filter to only process needed operations:**

Current: Processes all audit events
Recommended: Only process LaunchPowerApp and DeletePowerApp

**Expected result:** Additional 10-20% reduction (2.4 hours → 2 hours)

---

## Combined Impact

| Phase | Runtime | Improvement |
|-------|---------|-------------|
| Starting point (with DOP=25) | 6 hours | Baseline |
| After Phase 1 (time windows) | 3 hours | 50% faster |
| After Phase 2 (retry delays) | 2.4 hours | 20% faster |
| After Phase 3 (filtering) | 2 hours | 17% faster |
| **Total Improvement** | **2 hours** | **67% faster** |

---

## Detailed Documentation

📖 **Full Guide**: [O365_MANAGEMENT_API_OPTIMIZATIONS.md](O365_MANAGEMENT_API_OPTIMIZATIONS.md)

Includes:
- Step-by-step implementation instructions
- Line numbers and exact code changes
- Performance calculations and estimates
- Troubleshooting guide
- Advanced strategies (flow splitting, etc.)
- Success metrics and monitoring

---

## Implementation Checklist

### Phase 1 - Configuration (Do This First!)
- [ ] Update `admin_AuditLogsMinutestoLookBack` to 30
- [ ] Update `admin_AuditLogsEndTimeMinutesAgo` to 60
- [ ] Change flow recurrence to 30 minutes
- [ ] Test 3-4 flow runs
- [ ] Measure runtime (should be ~3 hours)

### Phase 2 - Retry Delays (If More Speed Needed)
- [ ] Export solution as unmanaged
- [ ] Extract flow JSON
- [ ] Change Delay2 from 30s to 5s
- [ ] Change GetApp_-_Deleted retry from 20 to 5
- [ ] Change retry interval from PT20S to PT5S
- [ ] Re-import solution
- [ ] Test and measure runtime (should be ~2.4 hours)

### Phase 3 - Operation Filtering (If Even More Speed Needed)
- [ ] Add FilterToRequiredOperations action
- [ ] Configure filter for LaunchPowerApp and DeletePowerApp only
- [ ] Update FilterEvents to use filtered results
- [ ] Test and measure runtime (should be ~2 hours)

---

## Quick Troubleshooting

**Issue:** Still taking too long after Phase 1
- Check: Is flow actually running every 30 minutes?
- Check: Are environment variables updated correctly?
- Check: Is tenant extremely high volume (5000+ events/hour)?

**Issue:** Missing audit events after changes
- Increase `admin_AuditLogsEndTimeMinutesAgo` to 90 or 120
- Verify flow is completing successfully (no errors)
- Check Dataverse records for completeness

**Issue:** More Power Automate usage
- Expected: More frequent runs = more API calls
- Monitor: Monthly API usage in admin center
- Adjust: Can reduce frequency to every 45 minutes if needed

---

## When to Contact Support

If after implementing all phases runtime is still multiple days:

**Document and provide:**
- Current configuration (concurrency, time windows)
- Average events per run
- Specific bottleneck steps from flow history
- Error patterns and retry statistics
- Proof that Graph API cannot be enabled

**Contact:** Microsoft Support with tenant ID, flow run IDs, and documentation above

---

## Remember

⚠️ **Office 365 Management API will always be slower than Graph API** due to architectural limitations.

✅ **These optimizations significantly improve O365 API performance** but Graph API remains the recommended approach when possible.

🎯 **Realistic expectation:** With all optimizations, expect 2-3 hours per run (vs. current 3+ days), which allows flow to keep up if running every 30 minutes.
