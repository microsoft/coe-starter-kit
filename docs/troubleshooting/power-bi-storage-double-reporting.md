# Power BI Dashboard - Database/Storage Size Showing Incorrect Values

## Issue Description

The Power BI CoE Dashboard may show database storage sizes that are approximately double the values displayed in the Power Platform Admin Center (PPAC). For example:
- PPAC shows ~260 GB
- Power BI report shows ~520 GB (roughly double)

## Root Cause

The issue occurs because the CoE Starter Kit stores **two different storage consumption metrics** from the Power Platform Admin API:

1. **Actual Consumption** (`admin_actualconsumption`) - The actual storage consumed
2. **Rated Consumption** (`admin_ratedconsumption`) - The rated or normalized storage value

Both metrics are synced from the Power Platform Admin API and stored in the `admin_EnvironmentCapacity` table. If the Power BI report is configured to sum both fields or use the wrong field for calculations, it will display approximately double the actual storage size.

## Understanding the Two Metrics

According to Microsoft's Power Platform capacity documentation:

- **Actual Consumption**: The raw storage amount used by the environment
- **Rated Consumption**: A normalized or "rated" value that may include additional factors for capacity calculations

For accurate comparison with PPAC, you should use the **Actual Consumption** field.

## Solution

### Option 1: Verify and Fix Power BI Report Measures

1. Open your Power BI report (`.pbit` or `.pbix` file)
2. Navigate to the report page showing storage/capacity metrics
3. Check the DAX measures or visuals that display database size
4. Ensure they are using **only** the `admin_actualconsumption` field, not:
   - Both `admin_actualconsumption` AND `admin_ratedconsumption` (summed together)
   - Only `admin_ratedconsumption`
   - A calculated field that combines both

### Option 2: Filter by Capacity Type

The `admin_EnvironmentCapacity` table stores multiple capacity types. Ensure your Power BI report filters correctly:

1. Check for the `admin_capacitytype` field in your queries
2. Filter to show only database storage types (typically "Database")
3. Avoid accidentally duplicating records by joining without proper filtering

### Recommended DAX Measure

Create or update your storage measure to use only actual consumption:

```dax
Total Database Storage (GB) = 
CALCULATE(
    SUM('admin_EnvironmentCapacity'[admin_actualconsumption]) / 1024,
    'admin_EnvironmentCapacity'[admin_capacitytype] = "Database",
    'admin_EnvironmentCapacity'[admin_environmentdeleted] = false()
)
```

## Verification Steps

After making changes to your Power BI report:

1. **Compare with PPAC**: 
   - Go to Power Platform Admin Center
   - Navigate to Resources > Capacity
   - Compare the total database storage shown with your Power BI report
   - Values should match within a small variance (due to timing differences)

2. **Check the Data Source**:
   - Open Power Query Editor in Power BI Desktop
   - Review the `admin_EnvironmentCapacity` query
   - Verify you're selecting the correct field: `admin_actualconsumption`

3. **Test with Known Values**:
   - Pick a specific environment where you know the exact storage size from PPAC
   - Filter your Power BI report to that environment
   - Verify the values match

## Additional Resources

- [Power Platform Capacity Documentation](https://learn.microsoft.com/power-platform/admin/capacity-storage)
- [CoE Starter Kit Power BI Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-powerbi)
- [Understanding Dataverse Storage Capacity](https://learn.microsoft.com/power-platform/admin/capacity-storage)

## Related Entities and Fields

The following fields are available in the `admin_EnvironmentCapacity` entity:

| Field Name | Description | Use in Reports |
|------------|-------------|----------------|
| `admin_actualconsumption` | Actual storage consumed | ✅ Use this for comparing with PPAC |
| `admin_ratedconsumption` | Rated/normalized consumption | ⚠️ Different calculation method |
| `admin_approvedcapacity` | Approved capacity limit | Use for capacity planning |
| `admin_capacitytype` | Type of capacity (Database, File, Log) | Use for filtering |
| `admin_capacityunit` | Unit of measurement (typically MB) | Use for conversions |

## Need Help?

If you continue to experience discrepancies after following these steps:

1. Verify your CoE Starter Kit is up to date with the latest version
2. Run a full inventory sync to refresh capacity data
3. Check the CoE Starter Kit GitHub repository for related issues: [aka.ms/coe-starter-kit-issues](https://aka.ms/coe-starter-kit-issues)
4. Review the [Power BI Connection Timeout troubleshooting guide](./power-bi-connection-timeout.md) for connection issues
