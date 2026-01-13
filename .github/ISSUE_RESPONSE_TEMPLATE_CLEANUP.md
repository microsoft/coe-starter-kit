# GitHub Issue Response Template

## Issue: Missing Flows in CoE Toolkit Inventory

Thank you for reporting this issue. This is expected behavior when the CLEANUP flow is enabled with default settings. I've analyzed your situation and created comprehensive documentation to help resolve it.

---

### Quick Answer to Your Questions

**Q: Does the CLEANUP flow delete rows from backend Dataverse tables?**  
**A**: Yes, when `admin_DeleteFromCoE = "yes"` (default), it permanently deletes records 2 months after marking them as deleted.

**Q: How frequently are flows removed?**  
**A**: The CLEANUP flow runs weekly (Sundays at 12:00). Flows deleted from environments are permanently removed from CoE inventory after 2 months.

**Q: How to retain historical records?**  
**A**: Change the environment variable `admin_DeleteFromCoE` to `"no"`. This will mark flows as deleted but retain them in the database.

**Q: Why are flows missing?**  
**A**: Flows deleted from environments more than 2 months ago have been permanently removed from CoE inventory by the CLEANUP flow.

---

### Immediate Solution

To prevent future data loss and retain historical records:

1. Navigate to your CoE environment at make.powerapps.com
2. Go to **Solutions** → **Center of Excellence - Core Components**
3. Click **Environment Variables**
4. Find **"Also Delete From CoE"** (`admin_DeleteFromCoE`)
5. Change **Current Value** from `"yes"` to `"no"`
6. Save

**Result**: Future deleted flows will be marked as deleted but not removed from the database, preserving your historical data for reporting.

---

### Understanding the Process

The CLEANUP flow follows this timeline:

```
Day 0: Flow deleted from environment
  ↓
Week 1: CLEANUP flow marks record as deleted
  • Sets admin_flowdeleted = true
  • Sets admin_flowdeletedon = [timestamp]
  ↓
Week 8-9: 2-month grace period expires
  ↓
Week 9+: CLEANUP flow permanently deletes record
  • Only if admin_DeleteFromCoE = "yes"
  • Record removed from admin_flows table
```

---

### Documentation Created

I've created three comprehensive guides to help you and others facing similar issues:

1. **[CLEANUP-FLOW-FAQ.md](../CLEANUP-FLOW-FAQ.md)** - Detailed FAQ covering:
   - How the CLEANUP flow works
   - Configuration options  
   - Data retention strategies
   - Best practices for different scenarios

2. **[TROUBLESHOOTING-MISSING-FLOWS.md](../TROUBLESHOOTING-MISSING-FLOWS.md)** - Step-by-step troubleshooting:
   - Verification steps to check your configuration
   - Multiple resolution options
   - Data recovery procedures (if applicable)
   - Prevention strategies for future

3. **[ISSUE-RESPONSE-CLEANUP-FLOW.md](../ISSUE-RESPONSE-CLEANUP-FLOW.md)** - Complete technical analysis:
   - Root cause explanation
   - Environment variable details
   - All available options with pros/cons

These documents are also linked in the main [README.md](../README.md) under "Common Issues and Troubleshooting" for easy discovery.

---

### Recommended Actions

**For Your Current Situation:**
1. ✅ Change `admin_DeleteFromCoE` to `"no"` immediately (5 minutes)
2. ✅ Review the FAQ to understand implications (10 minutes)
3. ✅ Adjust Power BI filters to exclude deleted items if needed (15 minutes)
4. ✅ Document your data retention policy (ongoing)

**For Long-Term:**
- Consider implementing scheduled exports for additional backup
- Monitor Dataverse database size quarterly
- Review retention policy annually

---

### Additional Notes

- **Affected Tables**: This behavior applies to all inventory tables (flows, apps, environments, solutions, connectors, etc.)
- **Grace Period**: The 2-month window gives time to recover from accidental deletions
- **No Data Recovery**: Unfortunately, once deleted by the cleanup flow, records cannot be recovered unless you have Dataverse backups
- **Dashboard Impact**: You may need to add filters to reports to exclude marked-deleted items

---

### Resources

- [CoE Starter Kit Official Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Environment Variables in Power Platform](https://docs.microsoft.com/power-platform/alm/environment-variables)
- [Dataverse Data Management Best Practices](https://docs.microsoft.com/power-platform/admin/data-retention-overview)

---

### Closing Note

This is **working as designed** with the default configuration. The CLEANUP flow is intentionally designed to remove old deleted items to keep your CoE environment database size manageable. However, I understand your need for historical data, which is why changing the environment variable to `"no"` is the recommended approach for most organizations that need compliance or audit trails.

Please let me know if you need any clarification or have additional questions after reviewing the documentation!

---

**Issue Classification:**
- **Type**: Documentation / Configuration
- **Severity**: Medium (No data loss if acted upon)
- **Status**: Resolved (with configuration change)
- **Version**: CoE Starter Kit v4.50.6+
