# Issue Response Template: Power BI Shows Double Database Storage

## Summary
This template provides a standardized response for issues where the Power BI CoE Dashboard reports approximately double the database storage size compared to the Power Platform Admin Center (PPAC).

## When to Use This Template
- User reports database/storage size discrepancies between PPAC and Power BI
- Power BI report shows ~2x the actual storage
- Capacity reporting appears inflated in dashboards

## Root Cause
The CoE Starter Kit syncs two separate storage metrics from the Power Platform Admin API:
1. **Actual Consumption** (`admin_actualconsumption`) - Raw storage amount
2. **Rated Consumption** (`admin_ratedconsumption`) - Normalized/rated value

If the Power BI report incorrectly sums both fields or uses the wrong field, it will display approximately double the actual storage.

---

## Response Template

Thank you for reporting this issue. The discrepancy you're seeing between the Power Platform Admin Center and the Power BI dashboard is typically caused by how the storage metrics are calculated in the Power BI report.

### Root Cause

The CoE Starter Kit's `admin_EnvironmentCapacity` entity stores two different storage consumption values from the Power Platform Admin API:

1. **`admin_actualconsumption`** - The actual storage consumed (this should match PPAC)
2. **`admin_ratedconsumption`** - A rated/normalized consumption value

If your Power BI report is summing both fields together or using the wrong field, it will show approximately double the actual storage size.

### Solution Steps

1. **Open your Power BI report** (Production_CoEDashboard_July2024.pbit or similar)

2. **Check the storage/capacity measures**:
   - Navigate to the page showing database storage
   - Review the DAX measures or visualizations
   - Ensure they use **only** the `admin_actualconsumption` field

3. **Recommended DAX measure**:
   ```dax
   Total Database Storage (GB) = 
   CALCULATE(
       SUM('admin_EnvironmentCapacity'[admin_actualconsumption]) / 1024,
       'admin_EnvironmentCapacity'[admin_capacitytype] = "Database",
       'admin_EnvironmentCapacity'[admin_environmentdeleted] = false()
   )
   ```

4. **Verify the fix**:
   - Refresh your Power BI report
   - Compare the values with PPAC
   - Values should now match within a small variance

### Additional Resources

We've created a comprehensive troubleshooting guide for this issue:
- [Power BI Storage Double Reporting Guide](./troubleshooting/power-bi-storage-double-reporting.md)

This guide includes:
- Detailed explanation of the two metrics
- Step-by-step fix instructions
- Verification steps
- Related fields reference

### Next Steps

1. Review the troubleshooting guide linked above
2. Apply the recommended fixes to your Power BI report
3. If the issue persists after making these changes, please provide:
   - Your CoE Starter Kit version
   - A screenshot of the DAX measure currently being used
   - An example of the discrepancy (e.g., PPAC shows 260 GB, Power BI shows 520 GB)

### Prevention

When updating or creating custom Power BI reports based on the CoE Starter Kit templates:
- Always use `admin_actualconsumption` for storage comparisons with PPAC
- Add filters for `admin_capacitytype` to avoid mixing different capacity types
- Document any custom measures that use capacity fields

---

## Related Issues
- Reference similar closed issues here when they occur

## Documentation Updates
- [x] Created troubleshooting guide: `docs/troubleshooting/power-bi-storage-double-reporting.md`
- [x] Updated troubleshooting README to reference new guide

## Follow-up Actions
If the user confirms this resolves their issue:
1. Close the issue with reference to the documentation
2. Consider if Power BI templates need updates (if using incorrect measures)
3. Update this template if new patterns emerge
