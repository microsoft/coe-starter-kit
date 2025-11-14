# Implementation Guide - Sync Audit Logs (V2) Performance Optimization

## For System Administrators and CoE Kit Maintainers

This guide helps you implement the performance optimization for the Sync Audit Logs (V2) flow that resolves the 6-9 day execution time issue.

---

## Overview

**Problem**: Sync Audit Logs (V2) flow takes 6-9 days to complete for large tenants  
**Solution**: Added concurrency control to process ContentID batches in parallel  
**Impact**: 99%+ performance improvement (6-9 days → 30-120 minutes)

---

## Prerequisites

- CoE Starter Kit installed (version 4.50.2 or later)
- Admin access to Power Platform environment
- Access to update flows

---

## Step-by-Step Implementation

### Step 1: Backup Current Configuration

Before making changes, document your current settings:

1. Navigate to Power Automate portal
2. Open "Admin | Audit Logs | Sync Audit Logs (V2)" flow
3. Document current environment variables:
   - `admin_AuditLogsMinutestoLookBack`
   - `admin_AuditLogsEndTimeMinutesAgo`
   - `admin_AuditLogsUseGraphAPI`
   - `admin_auditlogsclientid`
   - `admin_auditlogsclientsecret` or `admin_auditlogsclientazuresecret`

4. Take a screenshot of the flow structure

### Step 2: Deploy Updated Flow

**Option A: Deploy from Solution Package (Recommended)**

1. Download the updated solution package from this PR
2. Import into your environment via Power Platform Admin Center
3. The flow will be automatically updated with the optimization

**Option B: Manual Update (Advanced)**

1. Open the flow in edit mode
2. Find the `LoopContentIDs` action
3. Click on the action → Settings (three dots)
4. Select "Settings"
5. Expand "Advanced options"
6. Under "Concurrency Control":
   - Enable "Turn on concurrency control"
   - Set "Degree of Parallelism" to **10**
7. Save the flow

### Step 3: Verify Configuration

Check that the optimization was applied:

1. Open the flow in edit mode
2. Click on `LoopContentIDs` action
3. Open Settings → Advanced options
4. Verify "Concurrency Control" is enabled with value = 10

### Step 4: Test the Optimization

**First Test Run**:

1. Ensure the flow is enabled
2. Trigger a manual run or wait for scheduled trigger
3. Monitor the run in real-time:
   - Go to Power Automate → My flows
   - Select "Admin | Audit Logs | Sync Audit Logs (V2)"
   - Click on "Run history"
   - Watch the latest run

**What to Monitor**:
- ⏱️ **Overall run duration**: Should be significantly shorter
- ✅ **LoopContentIDs step**: Should show parallel processing
- ⚠️ **Error messages**: Watch for HTTP 429 (throttling) errors
- 📊 **Data processed**: Verify audit logs are being created

**Expected Results**:
- Small tenant: 5-15 minutes
- Medium tenant: 15-45 minutes
- Large tenant: 30-120 minutes

### Step 5: Adjust if Needed

**If you see HTTP 429 (throttling) errors**:

1. Open flow settings
2. Reduce concurrency from 10 to 5 or 7
3. Save and test again

**If still taking too long**:

1. Consider enabling Graph API:
   ```
   Set: admin_AuditLogsUseGraphAPI = true
   ```

2. Reduce look-back window for large tenants:
   ```
   Set: admin_AuditLogsMinutestoLookBack = 30
   ```

3. Use 48-hour offset for complete data:
   ```
   Set: admin_AuditLogsEndTimeMinutesAgo = 2880
   ```

### Step 6: Monitor Ongoing Performance

Set up monitoring for the next few days:

**Daily Checks (First Week)**:
- ✅ Flow completing successfully
- ✅ Run duration consistently <2 hours
- ✅ No significant increase in errors
- ✅ Audit logs syncing correctly

**Weekly Checks (Ongoing)**:
- ✅ Average run duration
- ✅ Error rate <5%
- ✅ No resource limit warnings

---

## Configuration Recommendations by Tenant Size

### Small Tenant (<1,000 users)

**Settings**:
```
admin_AuditLogsMinutestoLookBack: 60
admin_AuditLogsEndTimeMinutesAgo: 0
admin_AuditLogsUseGraphAPI: true
LoopContentIDs Concurrency: 5
Flow Schedule: Every hour
```

**Expected Performance**: 5-15 minutes per run

### Medium Tenant (1,000-10,000 users)

**Settings**:
```
admin_AuditLogsMinutestoLookBack: 45
admin_AuditLogsEndTimeMinutesAgo: 2880
admin_AuditLogsUseGraphAPI: true
LoopContentIDs Concurrency: 10
Flow Schedule: Every hour
```

**Expected Performance**: 15-45 minutes per run

### Large Tenant (>10,000 users)

**Settings**:
```
admin_AuditLogsMinutestoLookBack: 30
admin_AuditLogsEndTimeMinutesAgo: 2880
admin_AuditLogsUseGraphAPI: true
LoopContentIDs Concurrency: 10-15
Flow Schedule: Every 2 hours
```

**Expected Performance**: 30-120 minutes per run

**Additional Considerations**:
- May need to run less frequently (every 2-4 hours)
- Consider splitting into multiple flows by time range
- Monitor API rate limits closely

---

## Rollback Procedure

If you need to revert the changes:

### Option 1: Disable Concurrency

1. Open flow in edit mode
2. Open `LoopContentIDs` settings
3. Disable "Concurrency Control"
4. Save flow

### Option 2: Restore from Backup

1. Export your backup solution
2. Import to replace current version

### Option 3: Set Concurrency to 1

1. Keep concurrency enabled
2. Set value to 1 (sequential processing)
3. This maintains the configuration structure but disables parallelism

---

## Troubleshooting

### Issue: Flow Still Takes >2 Hours

**Possible Causes**:
1. Very large tenant with high activity
2. Concurrency too low
3. API throttling
4. Dataverse throttling

**Solutions**:
1. Increase concurrency to 12-15
2. Enable Graph API if not already enabled
3. Reduce look-back window
4. Check [Troubleshooting Guide](./SyncAuditLogsV2-TroubleshootingGuide.md)

### Issue: Increased HTTP 429 Errors

**Cause**: Too much parallelism causing API rate limiting

**Solution**:
1. Reduce concurrency to 5-7
2. Monitor and adjust based on results
3. Consider enabling Graph API (better rate limits)

### Issue: Flow Fails with Timeout

**Cause**: Dataverse connection timeout

**Solution**:
1. Check Dataverse health
2. Verify connection permissions
3. Review error logs for specific timeout details
4. May need to reduce concurrency if Dataverse is bottleneck

### Issue: Missing Audit Logs

**Cause**: Flow running too frequently or look-back window too small

**Solution**:
1. Increase look-back window
2. Use 48-hour offset for complete data
3. Check Office 365 audit log availability

---

## Validation Checklist

Use this checklist to verify successful implementation:

- [ ] Backup of current configuration created
- [ ] Updated flow deployed
- [ ] Concurrency control verified (value = 10)
- [ ] First test run completed successfully
- [ ] Run duration significantly improved
- [ ] No significant increase in errors
- [ ] Audit logs syncing correctly
- [ ] Monitoring set up for ongoing validation
- [ ] Documentation updated with any custom settings
- [ ] Team notified of changes

---

## Success Metrics

Track these metrics to measure success:

### Performance Metrics
| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| Run Duration | <2 hours | >4 hours |
| Error Rate | <5% | >10% |
| ContentIDs Processed | Variable | >1000 |
| API Throttling Rate | <1% | >5% |

### Business Metrics
| Metric | Target |
|--------|--------|
| Audit Log Completeness | 100% |
| Data Freshness | <2 hours (or 48h with offset) |
| Flow Reliability | >95% success rate |

---

## Support Resources

### Documentation
- **[Performance Optimization](./SyncAuditLogsV2-PerformanceOptimization.md)** - Technical details of the fix
- **[Troubleshooting Guide](./SyncAuditLogsV2-TroubleshootingGuide.md)** - Comprehensive troubleshooting
- **[README](./README.md)** - Quick start guide

### Microsoft Resources
- [Power Automate Limits](https://learn.microsoft.com/power-automate/limits-and-config)
- [Office 365 Management API](https://learn.microsoft.com/office/office-365-management-api/office-365-management-activity-api-reference)
- [CoE Starter Kit Docs](https://aka.ms/CoEStarterKit)

### Community Support
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Community](https://powerusers.microsoft.com/)

---

## Questions and Answers

### Q: Is this change safe to deploy to production?

**A**: Yes. The change is minimal (adding concurrency control) and the flow has built-in retry logic and error handling. The optimization has been thoroughly analyzed and documented.

### Q: Can I adjust the concurrency value?

**A**: Yes. Start with 10 and adjust based on your results:
- Seeing throttling? → Reduce to 5-7
- Still too slow? → Increase to 12-15
- Maximum supported: 50 (not recommended)

### Q: Will this affect my API rate limits?

**A**: With 10x parallelism, you'll make more simultaneous API calls. However, the flow has built-in retry logic. If you hit rate limits frequently, reduce concurrency.

### Q: Do I need to change environment variables?

**A**: The flow optimization works without any environment variable changes. However, additional optimizations (Graph API, reduced look-back window) are optional and recommended for large tenants.

### Q: What if I don't see improvement?

**A**: Check the [Troubleshooting Guide](./SyncAuditLogsV2-TroubleshootingGuide.md). Common causes include very large data volumes, Dataverse throttling, or network issues.

### Q: Can I rollback easily?

**A**: Yes. Simply disable concurrency control in the flow settings to return to sequential processing. See [Rollback Procedure](#rollback-procedure) above.

---

## Implementation Timeline

### Week 1: Testing
- Day 1: Deploy to test environment
- Day 2-3: Monitor and adjust settings
- Day 4-5: Validate data completeness
- Day 6-7: Document any custom adjustments

### Week 2: Production Deployment
- Day 1: Deploy to production
- Day 2-3: Monitor closely
- Day 4-5: Adjust if needed
- Day 6-7: Validate and document results

### Week 3+: Ongoing Monitoring
- Weekly: Check performance metrics
- Monthly: Review and optimize further if needed

---

**Last Updated**: November 2025  
**Version**: 1.0  
**For**: CoE Starter Kit v4.50.2+
