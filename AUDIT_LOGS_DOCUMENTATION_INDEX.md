# Audit Logs Performance - Documentation Index

## Overview

This documentation package addresses performance issues with the "Admin | Audit Logs | Sync Audit Logs (V2)" flow, which can take 3+ days to complete.

## Problem Statement

**Root Cause**: The flow defaults to the legacy Office 365 Management API path with three nested sequential loops, resulting in thousands of sequential HTTP calls.

**Symptoms**:
- Flow runs taking 3+ days to complete
- Step "get logs - usegraphapi - loopcontentids - getandprocessevents" is extremely slow
- Backlog of audit data accumulating
- Flow may time out or fail

## Solution Paths

### Path 1: Enable Graph API (Recommended) ✅

**Best for**: Customers who CAN enable Graph API permissions

**Outcome**: 10-100x faster (5-15 minutes vs 3+ days)

**Guide**: [QUICKFIX_AUDIT_LOGS.md](QUICKFIX_AUDIT_LOGS.md)

**Time to implement**: 5 minutes

**What you'll do**:
1. Set environment variable `admin_AuditLogsUseGraphAPI = true`
2. Verify Graph API permissions
3. Test next flow run

---

### Path 2: Office 365 Management API Optimizations (Alternative) ⚡

**Best for**: Customers who CANNOT enable Graph API permissions

**Outcome**: 60-70% faster (6 hours → 2 hours with all optimizations)

#### Quick Start
📄 **[QUICK_REFERENCE_O365_OPTIMIZATIONS.md](QUICK_REFERENCE_O365_OPTIMIZATIONS.md)**
- Implementation checklist
- Phase-by-phase approach
- Expected results at each phase

#### Detailed Guide
📖 **[O365_MANAGEMENT_API_OPTIMIZATIONS.md](O365_MANAGEMENT_API_OPTIMIZATIONS.md)**
- Comprehensive optimization strategies
- Step-by-step instructions
- Performance calculations
- Troubleshooting guide
- Advanced techniques

**Three optimization phases**:

**Phase 1: Quick Configuration (5 minutes)**
- Change time windows
- Adjust flow frequency
- **Impact**: 50% reduction

**Phase 2: Retry Optimization (30 minutes)**
- Reduce retry delays
- Optimize Dataverse retries
- **Impact**: Additional 20-30% reduction

**Phase 3: Advanced Optimizations (45+ minutes)**
- Filter operations
- Optimize Dataverse operations
- Split flows (advanced)
- **Impact**: Additional 10-20% reduction

---

## Complete Documentation Library

### Primary Guides

| Document | Purpose | Audience | Time |
|----------|---------|----------|------|
| [QUICKFIX_AUDIT_LOGS.md](QUICKFIX_AUDIT_LOGS.md) | Enable Graph API (fast path) | All customers with Graph API access | 5 min |
| [QUICK_REFERENCE_O365_OPTIMIZATIONS.md](QUICK_REFERENCE_O365_OPTIMIZATIONS.md) | Quick O365 API optimization checklist | Customers without Graph API | 5 min read |
| [O365_MANAGEMENT_API_OPTIMIZATIONS.md](O365_MANAGEMENT_API_OPTIMIZATIONS.md) | Comprehensive O365 API guide | Customers needing detailed guidance | 15 min read |
| [AUDIT_LOGS_PERFORMANCE.md](AUDIT_LOGS_PERFORMANCE.md) | Complete performance analysis | Technical staff, developers | 20 min read |

### Technical Resources

| Document | Purpose | Audience |
|----------|---------|----------|
| [AUDIT_LOGS_ARCHITECTURE.md](AUDIT_LOGS_ARCHITECTURE.md) | Visual architecture comparison | Technical staff, architects |
| [SOLUTION_SUMMARY.md](SOLUTION_SUMMARY.md) | Project summary and verification | Project managers, reviewers |

### Support Resources

| Document | Purpose | Audience |
|----------|---------|----------|
| [GITHUB_ISSUE_COMMENT.md](GITHUB_ISSUE_COMMENT.md) | GitHub issue response template | Support staff |
| [ISSUE_RESPONSE_AUDIT_LOGS_PERFORMANCE.md](ISSUE_RESPONSE_AUDIT_LOGS_PERFORMANCE.md) | Quick support reference | Support staff |

---

## Decision Tree

```
┌─────────────────────────────────────────┐
│ Flow taking 3+ days to complete?        │
└────────────┬────────────────────────────┘
             │
             ▼
    ┌────────────────────┐
    │ Can you enable     │
    │ Graph API          │
    │ permissions?       │
    └────┬───────────┬───┘
         │           │
       YES          NO
         │           │
         ▼           ▼
    ┌────────┐  ┌──────────────────────┐
    │ GOTO:  │  │ Do you already have  │
    │ QUICK  │  │ concurrency enabled  │
    │ FIX    │  │ (DOP=25)?            │
    └────────┘  └────┬─────────────┬───┘
                     │             │
                    YES           NO
                     │             │
                     ▼             ▼
          ┌──────────────────┐  ┌───────────┐
          │ GOTO: O365       │  │ GOTO:     │
          │ MANAGEMENT API   │  │ AUDIT     │
          │ OPTIMIZATIONS    │  │ LOGS      │
          │ (Advanced)       │  │ PERFORM   │
          └──────────────────┘  │ (Add      │
                                │ Concur    │
                                │ -rency)   │
                                └───────────┘
```

---

## Implementation Workflows

### Workflow A: Graph API Enablement

```
1. Read: QUICKFIX_AUDIT_LOGS.md
2. Set: admin_AuditLogsUseGraphAPI = true
3. Verify: Graph API permissions
4. Test: Next flow run
5. Monitor: Should complete in 5-15 minutes
6. Done! ✓
```

### Workflow B: O365 API with Concurrency

```
1. Read: AUDIT_LOGS_PERFORMANCE.md (Solution 2)
2. Edit: Flow JSON to add concurrency
3. Test: Next flow run
4. Monitor: Should improve significantly
5. If still slow → Go to Workflow C
```

### Workflow C: O365 API Advanced Optimizations

```
1. Read: QUICK_REFERENCE_O365_OPTIMIZATIONS.md
2. Implement: Phase 1 (time windows) - 5 min
3. Test: Monitor 3-4 runs
4. If needed: Phase 2 (retry delays) - 30 min
5. Test: Monitor 3-4 runs
6. If needed: Phase 3 (filtering) - 45 min
7. Test: Monitor 3-4 runs
8. Review: O365_MANAGEMENT_API_OPTIMIZATIONS.md for more options
```

---

## Performance Comparison

| Scenario | Configuration | Expected Runtime | Documentation |
|----------|---------------|------------------|---------------|
| **Baseline** | Default O365 API, no concurrency | 3+ days | N/A |
| **With Concurrency** | O365 API, DOP=25 on both loops | 6 hours | AUDIT_LOGS_PERFORMANCE.md |
| **Phase 1 Optimized** | + Time window adjustments | 3 hours | QUICK_REFERENCE_O365_OPTIMIZATIONS.md |
| **Phase 2 Optimized** | + Retry optimization | 2.4 hours | QUICK_REFERENCE_O365_OPTIMIZATIONS.md |
| **Phase 3 Optimized** | + Operation filtering | 2 hours | O365_MANAGEMENT_API_OPTIMIZATIONS.md |
| **Graph API** | admin_AuditLogsUseGraphAPI=true | 5-15 minutes | QUICKFIX_AUDIT_LOGS.md |

---

## Key Environment Variables

| Variable | Schema Name | Default | Recommended (O365) | Recommended (Graph) |
|----------|-------------|---------|-------------------|-------------------|
| Use Graph API | `admin_AuditLogsUseGraphAPI` | false | false | **true** |
| Minutes to Look Back | `admin_AuditLogsMinutestoLookBack` | 65 | **30** | 65 |
| End Time Minutes Ago | `admin_AuditLogsEndTimeMinutesAgo` | 0 | **60** | 0 |
| Flow Recurrence | (Flow Trigger) | 1 hour | **30 minutes** | 1 hour |

---

## Success Metrics

After implementing optimizations, you should see:

✅ **Flow Runtime**
- Graph API: 5-15 minutes
- O365 API (all optimizations): 2-3 hours
- O365 API (Phase 1 only): 3 hours

✅ **Backlog**
- Zero backlog (flow catches up to current time)
- Audit data is current

✅ **Errors**
- Minimal retry failures (< 5%)
- No timeout errors

✅ **Consistency**
- Flow completes successfully on every run
- Audit data is complete

---

## Troubleshooting

### "Still taking too long"
1. Verify configuration is correct
2. Check tenant audit volume (high-activity tenants need more optimization)
3. Review flow run history for specific bottlenecks
4. Consider advanced optimizations (flow splitting)

### "Missing audit events"
1. Increase `admin_AuditLogsEndTimeMinutesAgo` to 90-120
2. Verify flow is completing successfully
3. Check Dataverse for record counts

### "Higher Power Automate usage"
1. Expected with more frequent runs
2. Monitor monthly API limits
3. Adjust frequency if needed (every 45 min instead of 30)

### "Need more help"
1. Review [O365_MANAGEMENT_API_OPTIMIZATIONS.md](O365_MANAGEMENT_API_OPTIMIZATIONS.md) troubleshooting section
2. Document current configuration and metrics
3. Contact Microsoft Support with documentation

---

## Related Resources

- **CoE Starter Kit Setup**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Setup Audit Logs**: https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog
- **Graph AuditLog API**: https://learn.microsoft.com/graph/api/resources/security-auditlogquery
- **O365 Management API**: https://learn.microsoft.com/office/office-365-management-api/office-365-management-activity-api-reference
- **Power Automate Limits**: https://learn.microsoft.com/power-automate/limits-and-config

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-12-08 | 1.0 | Initial documentation package |
| 2025-12-11 | 2.0 | Added O365 Management API advanced optimizations |

---

## Support

This documentation is part of the CoE Starter Kit community solution.

- **Report Issues**: [CoE Starter Kit GitHub](https://aka.ms/coe-starter-kit-issues)
- **Platform Issues**: Contact Microsoft Support
- **Community**: [Power Platform Community](https://powerusers.microsoft.com/)

---

## Quick Links

🚀 **Quick Start**: [QUICKFIX_AUDIT_LOGS.md](QUICKFIX_AUDIT_LOGS.md)  
📋 **Quick Reference**: [QUICK_REFERENCE_O365_OPTIMIZATIONS.md](QUICK_REFERENCE_O365_OPTIMIZATIONS.md)  
📖 **Detailed Guide**: [O365_MANAGEMENT_API_OPTIMIZATIONS.md](O365_MANAGEMENT_API_OPTIMIZATIONS.md)  
📊 **Performance Analysis**: [AUDIT_LOGS_PERFORMANCE.md](AUDIT_LOGS_PERFORMANCE.md)  
🏗️ **Architecture**: [AUDIT_LOGS_ARCHITECTURE.md](AUDIT_LOGS_ARCHITECTURE.md)
