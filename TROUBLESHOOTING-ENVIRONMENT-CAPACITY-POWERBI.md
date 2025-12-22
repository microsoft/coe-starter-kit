# Troubleshooting: Environment Capacity Power BI Report Shows Incomplete Data

## Issue Description
After installing the CoE Starter Kit (November 2025 or later), the Power BI Environment Capacity report displays only a subset of environments (e.g., 10 out of 70 total environments).

## Root Cause Analysis

This issue typically occurs due to one or more of the following reasons:

### 1. **Pagination Limits / Licensing Constraints**
The most common cause is insufficient licensing for the service account running the sync flows. Trial licenses or basic Power Automate licenses have pagination limits that restrict API responses to approximately 50 records per call.

### 2. **Incomplete Inventory Sync**
The Admin Sync Template v4 (Driver) flow may not have completed successfully for all environments.

### 3. **Environment Exclusion Settings**
Some environments may be marked as "Excused from Inventory" which excludes them from sync.

### 4. **Flow Execution Failures**
The sync flows may have encountered errors or timeouts during execution.

### 5. **API Throttling or Capacity Expansion Issues**
The capacity API call (`$expand=properties.capacity,properties.addons`) may fail for certain environments.

## Troubleshooting Steps

### Step 1: Verify Service Account Licensing

**Required License**: The service account running the CoE Starter Kit flows MUST have one of the following:
- Power Automate Process license
- Power Apps Per User license (NOT trial)
- Power Automate Per User with RPA license

**How to Check**:
1. Go to Microsoft 365 admin center
2. Navigate to Users → Active Users
3. Find the service account used for CoE Starter Kit
4. Review assigned licenses under the "Licenses and Apps" tab

**If using a trial license**: Upgrade to a paid license immediately, as trial licenses have pagination limits.

**Test for Pagination Issues**:
Run the following test to verify if pagination is working correctly:
1. Navigate to the CoE environment
2. Open the "Admin | Sync Template v4 (Driver)" flow
3. Check the "Get Environments" action in the flow run history
4. Verify the number of environments returned matches your total environment count

If you see fewer environments than expected, this confirms a pagination/licensing issue.

### Step 2: Check Admin Sync Template v4 (Driver) Flow

1. **Navigate to Power Automate**:
   - Go to https://make.powerautomate.com
   - Select your CoE environment
   - Go to Solutions → Center of Excellence - Core Components

2. **Locate the Driver Flow**:
   - Find "Admin | Sync Template v4 (Driver)"
   - Check the flow status (should be "On")

3. **Review Run History**:
   - Click on the flow
   - Select "Run history"
   - Check the most recent runs for failures or warnings
   - Look for specific environments that failed to sync

4. **Check for Error Messages**:
   - Open failed runs
   - Look for error messages related to:
     - "Get Environments" action
     - Timeout errors
     - Permission errors
     - API throttling errors

### Step 3: Verify Environment Inventory Settings

1. **Check "Excuse from Inventory" Flag**:
   - Open the "CoE Admin Command Center" app
   - Navigate to Environments
   - Filter to show "Excused from Inventory = Yes"
   - Review if any environments are incorrectly excluded

2. **Verify "is All Environments Inventory" Setting**:
   - Check the environment variable: `admin_isFullTenantInventory`
   - This should be set to `true` to track all environments
   - If set to `false`, new environments are excluded by default

**To update**:
   - Go to Solutions → Center of Excellence - Core Components
   - Navigate to Environment Variables
   - Find "is All Environments Inventory (admin_isFullTenantInventory)"
   - Ensure the current value is set to `true`

### Step 4: Run Full Inventory Sync

1. **Trigger a Full Sync**:
   - Open "Admin | Sync Template v4 (Driver)" flow
   - Click "Run" manually
   - Monitor the flow execution for completion
   - Wait for all child flows to complete (this can take 30-60 minutes for large tenants)

2. **Verify Child Flow Executions**:
   The driver flow calls multiple child flows. Ensure all complete successfully:
   - Admin | Sync Template v4 (Apps)
   - Admin | Sync Template v4 (Flows)
   - Admin | Sync Template v4 (Custom Connectors)
   - CLEANUP HELPER - Environment Capacity
   - And others...

3. **Check Environment Capacity Helper**:
   - Find "CLEANUP HELPER - Environment Capacity" flow
   - This flow specifically processes capacity data
   - Verify it ran successfully for all environments
   - Check run history for any failures

### Step 5: Verify Power BI Report Data Refresh

1. **Refresh the Power BI Dashboard**:
   - Open the Power BI workspace containing CoE reports
   - Find the "Environment Capacity" report
   - Click "Refresh Now" to pull latest data from Dataverse

2. **Check Last Refresh Time**:
   - Verify the dataset was refreshed after the sync flows completed
   - If auto-refresh is configured, ensure it's scheduled after sync flows run

3. **Validate Data Source Connection**:
   - Ensure the Power BI dataset is connected to the correct CoE environment
   - Verify credentials are up to date

### Step 6: Review Dataverse Tables

1. **Check admin_environment Table**:
   - Open the CoE environment
   - Navigate to Tables
   - Open "Environments" (admin_environment)
   - Verify the total count of records matches your environment count
   - Check for recent "Modified On" dates

2. **Verify Capacity Data**:
   - Look for capacity-related fields in environment records:
     - Database Consumption
     - File Consumption
     - Log Consumption
     - Capacity Type

### Step 7: Check for Known Issues

**API Changes**: Microsoft occasionally updates Power Platform Admin APIs. Check:
- [CoE Starter Kit Release Notes](https://github.com/microsoft/coe-starter-kit/releases)
- [Known Issues](https://learn.microsoft.com/en-us/power-platform/guidance/coe/limitations)
- Recent GitHub issues in the coe-starter-kit repository

## Resolution Procedures

### Fix 1: Upgrade Service Account License
1. Assign a Power Automate Process license or Power Apps Per User license
2. Wait 24 hours for license propagation
3. Re-run the Admin Sync Template v4 (Driver) flow
4. Refresh Power BI reports

### Fix 2: Reset and Re-sync Inventory
1. Turn off all sync flows temporarily
2. (Optional) Clear the admin_environment table if instructed by support
3. Turn on "Admin | Sync Template v4 (Driver)" flow
4. Run manually and monitor completion
5. Turn on dependent flows
6. Refresh Power BI dashboard

### Fix 3: Update Environment Variable
1. Set `admin_isFullTenantInventory` to `true`
2. Update any excluded environments to `Excuse from Inventory = No`
3. Re-run sync flows

### Fix 4: Increase Flow Timeout Settings
For large tenants with 70+ environments:
1. Consider splitting inventory sync into batches
2. Adjust flow timeout settings if supported
3. Run sync during off-peak hours to avoid throttling

## Prevention / Best Practices

1. **Use Dedicated Service Account**: Create a dedicated service account with proper licensing for CoE Starter Kit
2. **Schedule Regular Syncs**: Run inventory sync daily or weekly based on tenant size
3. **Monitor Flow Health**: Set up alerts for sync flow failures
4. **Keep Kit Updated**: Regularly update to the latest CoE Starter Kit version
5. **Document Customizations**: Track any customizations to sync flows for troubleshooting

## Additional Resources

- **Official Documentation**: [CoE Starter Kit Overview](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- **Setup Guide**: [CoE Starter Kit Setup](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
- **Inventory & Telemetry**: [Set up inventory components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- **Limitations**: [CoE Starter Kit Limitations](https://learn.microsoft.com/en-us/power-platform/guidance/coe/limitations)
- **GitHub Issues**: [Report or search issues](https://github.com/microsoft/coe-starter-kit/issues)

## Validation

After applying fixes:

1. ✅ Verify all 70 environments appear in the Dataverse "Environments" table
2. ✅ Confirm "Admin | Sync Template v4 (Driver)" flow completes successfully
3. ✅ Check "CLEANUP HELPER - Environment Capacity" flow runs without errors
4. ✅ Refresh Power BI report and verify environment count is correct
5. ✅ Spot-check 3-5 environments to ensure capacity data is populated

## Summary

The most common cause for incomplete environment data in Power BI reports is **licensing constraints** on the service account running the sync flows. Ensure the service account has a proper Power Automate or Power Apps license (not trial), verify inventory sync flows are completing successfully, and check that environments are not excluded from inventory.

For persistent issues after following these steps, please open a GitHub issue with:
- CoE Starter Kit version
- Service account license type
- Flow run history screenshots
- Error messages from failed flow runs
- Environment count in Dataverse vs. actual count
