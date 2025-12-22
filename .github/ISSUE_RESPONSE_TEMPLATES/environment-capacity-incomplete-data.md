# Issue Response Template: Environment Capacity Report Shows Only Few Environments

## For Issue Type: [CoE Starter Kit - QUESTION] Environment capacity in Power BI reports shows only few environments

---

Thank you for reporting this issue. This is a common problem when setting up the CoE Starter Kit, and typically relates to one of several root causes.

## Summary
You're experiencing an issue where the **Environment Capacity** report in Power BI shows only a subset of environments instead of all environments in your tenant. This is most commonly caused by **licensing limitations** on the service account running the sync flows.

## Most Likely Root Cause: Licensing and Pagination Limits

The service account executing the CoE Starter Kit flows needs a **proper license** (not trial) to retrieve all records from the Power Platform Admin APIs. Trial or basic licenses have pagination limits that restrict API responses to approximately 50 records.

**Required License** (one of the following):
- ✅ Power Automate Process license
- ✅ Power Apps Per User license (full, NOT trial)
- ✅ Power Automate Per User with RPA license

## Immediate Troubleshooting Steps

### Step 1: Verify Service Account License
1. Go to **Microsoft 365 Admin Center** → Users → Active Users
2. Find the service account used for CoE Starter Kit
3. Check "Licenses and Apps" tab
4. **If using a trial license**: Upgrade immediately to a paid license

### Step 2: Check Admin Sync Template Flow Execution
1. Navigate to **https://make.powerautomate.com**
2. Select your **CoE environment**
3. Go to **Solutions** → **Center of Excellence - Core Components**
4. Open **"Admin | Sync Template v4 (Driver)"** flow
5. Review **Run History**:
   - Verify it completed successfully
   - Check if "Get Environments" action returned all environments
   - Look for any error messages or warnings

### Step 3: Verify Environment Inventory Settings
1. Open the **CoE Admin Command Center** app
2. Navigate to **Environments**
3. Count total records - should match your total environment count
4. Filter by "Excused from Inventory = Yes" to check if any are excluded
5. Verify the environment variable `admin_isFullTenantInventory` is set to **`true`**

### Step 4: Run Full Inventory Sync
1. Open **"Admin | Sync Template v4 (Driver)"** flow
2. Click **"Run"** to trigger a manual execution
3. Monitor the flow execution (can take 30-60 minutes)
4. Verify the **"CLEANUP HELPER - Environment Capacity"** child flow also runs successfully

### Step 5: Refresh Power BI Report
1. Go to your **Power BI workspace** containing CoE reports
2. Find the **Environment Capacity** dataset
3. Click **"Refresh Now"**
4. After refresh completes, verify data updates in the report

## Detailed Troubleshooting Guides

For comprehensive troubleshooting, please refer to:
- **[Troubleshooting: Environment Capacity Power BI Report](../../TROUBLESHOOTING-ENVIRONMENT-CAPACITY-POWERBI.md)** - Specific guide for this exact issue
- **[Troubleshooting: Power BI Reports Showing Incomplete Data](../../TROUBLESHOOTING-POWERBI-INCOMPLETE-DATA.md)** - General troubleshooting for Power BI data issues

## Common Causes Checklist

- [ ] **Licensing Issue**: Service account has trial or insufficient license
- [ ] **Sync Flow Not Completed**: Driver flow failed or didn't run for all environments
- [ ] **Environments Excluded**: Some environments marked as "Excused from Inventory"
- [ ] **API Throttling**: Capacity API expansion failed for some environments
- [ ] **Power BI Not Refreshed**: Dataset needs manual refresh after sync

## Expected Resolution

After verifying/fixing the service account license and re-running the sync flows:
1. All environments should appear in the Dataverse **admin_environment** table
2. **"Admin | Sync Template v4 (Driver)"** flow should complete without errors
3. **"CLEANUP HELPER - Environment Capacity"** should process all environments
4. Power BI **Environment Capacity** report should show all environments with capacity data

## Additional Information Needed

To further assist you, please provide:
1. **Service account license type**: What license is assigned to the account running sync flows?
2. **Flow run status**: Screenshot of "Admin | Sync Template v4 (Driver)" latest run history
3. **Dataverse record count**: How many records are in the **admin_environment** table?
4. **Error messages**: Any specific errors from the flow runs?
5. **Environment variable values**: Is `admin_isFullTenantInventory` set to `true`?

## Official Resources

- [CoE Starter Kit Overview](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Set up inventory components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [CoE Starter Kit Limitations](https://learn.microsoft.com/en-us/power-platform/guidance/coe/limitations)
- [GitHub Issues Search](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+environment+capacity)

## Note on Support

The CoE Starter Kit is provided as-is and is **unsupported by Microsoft**. Support is best-effort through the community via GitHub issues and community calls. For mission-critical scenarios, please consult with your Microsoft account team about supported governance solutions.

---

**Please let us know the results of the troubleshooting steps above, and we'll be happy to assist further!**
