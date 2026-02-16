# Analysis: AI Credits Usage Data Not Showing After December 2025

## Issue Summary
User reports that AI Credits usage data is only displaying up to December 2025, with no data appearing in 2026. This analysis examines the CoE Starter Kit's AI Credits data collection mechanism to identify the root cause.

---

## How AI Credits Data is Collected

### 1. **Flow: Admin | Sync Template v4 (AI Usage)**
- **File**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminSyncTemplatev4AIUsage-9BBE33D2-BCE6-EE11-904D-000D3A341FFF.json`
- **Purpose**: Retrieves AI Builder Credit Consumption information on a daily basis
- **Introduced**: Version 4.24.5
- **Description**: This flow retrieves AI Builder Credit Consumption information from underlying Dataverse tables. Requires system administrator privileges in the environment.

### 2. **Data Source: msdyn_aievents Table**
The flow queries the **`msdyn_aievents`** table in each environment using the Dataverse connector with the following filter:

```odata
$filter: "msdyn_creditconsumed gt 0 and (Microsoft.Dynamics.CRM.LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1))"
```

**Key Filter Components**:
- `msdyn_creditconsumed gt 0` - Only events with credit consumption
- `Microsoft.Dynamics.CRM.LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1)` - **Only retrieves data from the last 1 day**

### 3. **Dataverse Table: admin_AICreditsUsage**
- **Entity Location**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_AICreditsUsage/`
- **Primary Fields**:
  - `admin_aicreditsusageid` (Primary Key)
  - `admin_creditsconsumption` (Credits Consumed)
  - `admin_processingdate` (Processing Date - Date format)
  - `admin_creditsuser` (User who consumed credits - lookup to admin_PowerPlatformUser)
  - `admin_Environment` (Environment lookup)

---

## Root Cause Analysis

### **Finding: No Hardcoded Date Limitations in the Flow**

After thorough examination of the flow definition, I found:

1. ✅ **No hardcoded years (2025, 2026) in the flow logic**
2. ✅ **No December or year-specific filters**
3. ✅ **Date processing uses dynamic functions**:
   - `formatDateTime(items('Apply_to_each'), 'yyyy-MM-dd')`
   - `startOfDay()`, `addDays()`
   - All date operations are relative, not absolute

### **The Issue is NOT in the CoE Starter Kit Code**

The flow correctly:
- Uses `LastXDays` with `PropertyValue=1` to query yesterday's data
- Processes dates dynamically using Power Automate date functions
- Stores data with `admin_processingdate` using `formatDateTime()` which has no year limitations

---

## Potential Root Causes (External to CoE Kit)

### 1. **Microsoft's msdyn_aievents Table Issue**
The most likely cause is that Microsoft's **`msdyn_aievents`** table (which is a system table in Dataverse environments) may have:
- A data retention policy that stops at 2025
- A bug preventing data from populating in 2026
- An API limitation in the Dataverse connector

### 2. **Flow Not Running**
Check if the flow is:
- Still running daily (check Flow run history)
- Completing successfully
- Being triggered for all environments

### 3. **Dataverse API Changes**
Microsoft may have made changes to:
- The `msdyn_aievents` table structure
- The `Microsoft.Dynamics.CRM.LastXDays` function behavior
- API permissions or access patterns

### 4. **Environment-Level Issue**
The `msdyn_aievents` table exists in **each environment** (not centrally). If data isn't appearing:
- Check if AI Builder is being actively used in 2026
- Verify the table exists and is accessible in the target environments
- Confirm system administrator privileges are still valid

---

## Diagnostic Steps

### Step 1: Verify Flow Execution
1. Open the **Admin | Sync Template v4 (AI Usage)** flow
2. Check the **28-day run history**
3. Look for:
   - Successful runs in January 2026
   - Any error messages or warnings
   - Whether the flow is retrieving 0 events

### Step 2: Check Source Data
Manually query the `msdyn_aievents` table in an environment:
1. Navigate to an environment where AI Builder is actively used
2. Open **Advanced Find** or use the **Dataverse REST API**
3. Query:
   ```odata
   /api/data/v9.2/msdyn_aievents?$filter=msdyn_creditconsumed gt 0 and msdyn_processingdate ge 2026-01-01&$select=msdyn_creditconsumed,msdyn_processingdate,msdyn_aieventid
   ```
4. Check if any records exist with `msdyn_processingdate` in 2026

### Step 3: Check admin_AICreditsUsage Table
In the CoE environment:
1. Navigate to **Advanced Find**
2. Query `admin_AICreditsUsage` records
3. Sort by `admin_processingdate` descending
4. Verify the last processing date - is it stuck at December 2025?

### Step 4: Check Power BI Report
1. Open the **Production_CoEDashboard_July2024.pbit** or equivalent
2. Verify the data model and any date filters
3. Check if there are any explicit date range filters limiting to 2025

---

## Power BI Reports Affected

The following Power BI reports display AI Credits usage:
- **Location**: `CenterofExcellenceResources/Release/Collateral/CoEStarterKit/`
  - `Production_CoEDashboard_July2024.pbit`
  - `BYODL_CoEDashboard_July2024.pbit`
  - `PowerPlatformGovernance_CoEDashboard_July2024.pbit`

These reports connect to the `admin_AICreditsUsage` table and should automatically display new data if it exists.

---

## Known Issues Search Results

After searching the repository:
- ✅ No existing GitHub issues specifically about AI Credits and 2025/2026 date issues
- ✅ No recent code changes to the AI Usage flow
- ✅ No troubleshooting guides for AI Credits date issues

---

## Recommended Actions

### For the User:
1. **Verify AI Builder Usage**: Confirm AI Builder models are actually being used in 2026
2. **Check Flow Status**: Verify the "Admin | Sync Template v4 (AI Usage)" flow is turned on and running successfully
3. **Review Flow Runs**: Look at the flow run history for any errors or warnings
4. **Check Permissions**: Ensure the flow connection still has system administrator privileges
5. **Manual Test**: Try running the flow manually and check for errors

### For Investigation:
1. **Contact Microsoft Support**: This may be a platform-level issue with the `msdyn_aievents` table
2. **Check for Service Advisories**: Look for any Microsoft announcements about AI Builder or Dataverse changes
3. **Test in Different Environments**: Check if the issue is consistent across all environments

### For CoE Starter Kit Maintainers:
1. **Monitor for Similar Reports**: Watch for additional users reporting the same issue
2. **Consider Enhanced Logging**: Add additional error handling in the AI Usage flow to capture specific issues with the `msdyn_aievents` table
3. **Document Workaround**: If this is a known platform limitation, document it in the troubleshooting guides

---

## Technical Details

### Flow Logic Overview:
1. **Trigger**: Scheduled/Manual trigger (runs per environment)
2. **List AI Events**: Queries `msdyn_aievents` using `LastXDays(1)`
3. **Process Events**: 
   - Groups events by `ProcessingDate`
   - Aggregates credits per user per day
   - Filters unique dates and users
4. **Upsert Records**: Creates/updates `admin_AICreditsUsage` records
5. **Concurrency**: Processes 50 iterations in parallel

### No Date Limitations Found:
```javascript
// Example of date processing (no hardcoded years)
"item/admin_processingdate": "@formatDateTime(items('Apply_to_each'),'yyyy-MM-dd')"
```

### Filter Query (Dynamic, No Year Limit):
```odata
$filter: "msdyn_creditconsumed gt 0 and (Microsoft.Dynamics.CRM.LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1))"
```

---

## Conclusion

**The CoE Starter Kit code does NOT contain any hardcoded date limitations** that would cause AI Credits data to stop at December 2025. The issue is most likely:

1. **Platform-level**: Microsoft's `msdyn_aievents` table may have a bug or limitation
2. **Data availability**: No AI Builder usage in 2026, or data not being written to `msdyn_aievents`
3. **Flow execution**: The sync flow may not be running or encountering errors

**Next Steps**: 
- User should check flow run history and verify AI Builder is actively being used
- If confirmed as a platform issue, escalate to Microsoft Support
- Monitor for similar reports from other CoE Starter Kit users

---

## References

- **Official Documentation**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit
- **Flow Name**: Admin | Sync Template v4 (AI Usage)
- **Entity**: admin_AICreditsUsage
- **Source Table**: msdyn_aievents (Microsoft system table)
- **Introduced Version**: 4.24.5
