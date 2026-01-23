# Power BI Template Verification Guide

## Purpose
This guide is for CoE Starter Kit maintainers to verify that the Power BI dashboard templates are using the correct storage/capacity fields.

## Issue Background
The `admin_EnvironmentCapacity` entity contains two consumption fields:
- `admin_actualconsumption` - Should be used for comparing with PPAC
- `admin_ratedconsumption` - Different calculation method, should not be summed with actualconsumption

If Power BI measures incorrectly sum both fields or use the wrong field, users will see approximately double the actual storage size.

## Templates to Verify

The following Power BI templates should be checked:

1. **Production_CoEDashboard_July2024.pbit** - Main production dashboard
2. **PowerPlatformGovernance_CoEDashboard_July2024.pbit** - Governance dashboard
3. **BYODL_CoEDashboard_July2024.pbit** - BYODL variant
4. **Power Platform Administration Planning.pbit** - Admin planning dashboard

## Verification Steps

### 1. Open the Template in Power BI Desktop

1. Launch Power BI Desktop
2. Open the `.pbit` file
3. If prompted, enter connection parameters (or skip if just checking measures)

### 2. Check Capacity/Storage Measures

1. Go to **Model** view or **Report** view
2. Open the **Fields** pane
3. Look for measures related to storage, capacity, or database size
4. Common measure names to check:
   - Total Database Storage
   - Storage Used
   - Capacity Consumed
   - Database Size
   - Any measure using EnvironmentCapacity table

### 3. Inspect DAX Formulas

For each capacity/storage measure:

1. Right-click the measure → **Edit**
2. Review the DAX formula
3. Check for:
   - ✅ CORRECT: Uses only `admin_actualconsumption`
   - ❌ INCORRECT: Sums both `admin_actualconsumption` and `admin_ratedconsumption`
   - ❌ INCORRECT: Uses only `admin_ratedconsumption`

### 4. Check Visualizations

1. Navigate through each report page
2. For any storage/capacity visualizations:
   - Select the visual
   - Check the **Fields** pane to see which fields are used
   - Verify the **Values** section uses the correct field

### 5. Review Filters

1. Check filters on capacity-related visuals
2. Ensure `admin_capacitytype` is filtered correctly (e.g., "Database" only)
3. Verify `admin_environmentdeleted` is filtered to exclude deleted environments

## Expected Correct DAX Patterns

### Total Database Storage (in GB)
```dax
Total Database Storage (GB) = 
CALCULATE(
    SUM('admin_EnvironmentCapacity'[admin_actualconsumption]) / 1024,
    'admin_EnvironmentCapacity'[admin_capacitytype] = "Database",
    'admin_EnvironmentCapacity'[admin_environmentdeleted] = false()
)
```

### Storage by Environment
```dax
Storage by Environment = 
CALCULATE(
    SUM('admin_EnvironmentCapacity'[admin_actualconsumption]),
    'admin_EnvironmentCapacity'[admin_capacitytype] = "Database"
)
```

## Common Issues to Look For

### Issue 1: Summing Both Fields
```dax
❌ INCORRECT:
Total Storage = 
    SUM('admin_EnvironmentCapacity'[admin_actualconsumption]) + 
    SUM('admin_EnvironmentCapacity'[admin_ratedconsumption])
```

### Issue 2: Using Wrong Field
```dax
❌ INCORRECT:
Total Storage = 
    SUM('admin_EnvironmentCapacity'[admin_ratedconsumption])
```

### Issue 3: Missing Filters
```dax
❌ INCORRECT (no capacity type filter):
Total Storage = 
    SUM('admin_EnvironmentCapacity'[admin_actualconsumption])
    // This sums ALL capacity types, not just Database
```

## Testing

After making any corrections:

1. **Connect to test data**:
   - Use a test CoE environment with known storage values
   - Compare Power BI results with PPAC

2. **Spot check specific environments**:
   - Filter to a single environment
   - Verify the storage matches PPAC exactly (or very close)

3. **Check totals**:
   - Compare tenant-wide totals with PPAC
   - Values should match within ~1-2% (due to timing differences)

## Fixing Issues

If you find incorrect measures:

1. **Update the DAX formula** using the correct patterns above
2. **Test thoroughly** with real data
3. **Update all affected templates** (Production, Governance, BYODL, etc.)
4. **Document the change** in release notes
5. **Update version numbers** in template metadata

## Automated Verification (Future)

Consider creating a script to:
- Extract DataModelSchema from .pbit files
- Parse for capacity-related measures
- Flag measures using both consumption fields
- Generate a report of findings

## Related Documentation

- [Power BI Storage Double Reporting Troubleshooting Guide](./troubleshooting/power-bi-storage-double-reporting.md)
- [Issue Response Template](./ISSUE-RESPONSE-PowerBI-Storage-Double.md)

## Questions?

If you need help verifying or fixing templates, reach out to the CoE Starter Kit maintainer team.
