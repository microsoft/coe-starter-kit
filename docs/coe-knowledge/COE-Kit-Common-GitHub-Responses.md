# CoE Starter Kit - Common GitHub Responses

This document contains ready-to-use explanations, limits, and workarounds for common issues reported in the CoE Starter Kit GitHub repository.

## Table of Contents

- [Dashboard and Inventory Issues](#dashboard-and-inventory-issues)
- [Setup and Configuration](#setup-and-configuration)
- [Known Limitations](#known-limitations)
- [Licensing and Pagination](#licensing-and-pagination)
- [Data Lake (BYODL) Guidance](#data-lake-byodl-guidance)
- [Language and Localization](#language-and-localization)

## Dashboard and Inventory Issues

### Apps and Flows Not Appearing in Power BI Dashboards

**Problem:** After setting up the CoE Starter Kit, apps and flows created in the tenant are not appearing in the Power BI dashboards.

**Root Causes:**
1. Inventory flows are not turned on (they are OFF by default after solution import)
2. Initial inventory collection has not completed
3. Power BI dataset has not been refreshed
4. Connection between Power BI and Dataverse environment is misconfigured

**Resolution Steps:**

**Step 1: Turn ON Required Inventory Flows**

Navigate to: `Solutions → Center of Excellence – Core Components → Cloud flows`

Ensure the following flows are turned **ON**:
- `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
- `Admin | Sync Template v3`
- `Admin | Sync Apps v2`
- `Admin | Sync Flows v3`

> **Note:** These flows are OFF by default after solution import for security and performance reasons. You must manually enable them.

**Step 2: Run the Initial Inventory Manually**

1. Open `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
2. Click **Run**
3. Wait for the flow to complete successfully
4. This may take considerable time depending on your tenant size

**Step 3: Wait for Inventory Collection to Complete**

Initial inventory collection is **not immediate**. Expected timeframes:
- **Small tenants** (< 100 apps/flows): 30–60 minutes
- **Medium tenants** (100-1000 apps/flows): 2–4 hours
- **Large tenants** (> 1000 apps/flows): up to 24 hours or more

> **Important:** Wait until `Admin | Sync Template v3` shows a successful run in the run history before proceeding.

**Step 4: Verify Data in Dataverse**

1. Navigate to https://make.powerapps.com
2. Select your CoE environment
3. Open **Tables**
4. Verify records exist in:
   - `Power Apps App` table
   - `Flow` table
   - `Environment` table

If records exist, inventory data is being collected correctly.

**Step 5: Refresh Power BI Dataset**

After confirming data exists in Dataverse:
1. Open your Power BI workspace
2. Locate the CoE Starter Kit dataset
3. Click **Refresh now**
4. Ensure the Power BI report is connected to the correct CoE environment

**Additional Troubleshooting:**

- Check flow run history for errors in the Admin sync flows
- Verify that the service account running the flows has appropriate permissions
- Ensure all connections are authenticated and not expired
- Review [official documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components) for setup details

### Power BI Shows "No Data" or Empty Visuals

**Problem:** Power BI reports are showing empty visuals or "no data" messages even after inventory collection.

**Common Causes:**
1. Power BI dataset connection is pointing to wrong environment
2. Data source credentials need to be updated
3. Dataverse tables are empty or not synchronized
4. Filters are too restrictive

**Resolution:**
1. Open Power BI Service, go to the dataset settings
2. Verify the Dataverse connection URL points to your CoE environment
3. Update credentials if needed (OAuth2 recommended)
4. Check for any filter restrictions in the report that might be excluding all data
5. Verify table relationships are properly configured

## Setup and Configuration

### Flows Turn Off Automatically After Import

**Problem:** Flows turn themselves off after import or periodically stop running.

**Common Causes:**
1. Connection references are not properly configured
2. Missing or expired authentication
3. Flow errors causing automatic suspension
4. Environment variable values not set

**Resolution:**
1. Check all connection references have valid connections
2. Ensure environment variables are configured with correct values
3. Review flow run history for error patterns
4. Re-authenticate connections if they've expired
5. Check for suspended flows under "My flows" → "Cloud flows" → Filter by "Suspended"

### Setup Wizard Does Not Complete Successfully

**Problem:** The Setup Wizard flow fails or does not complete all configuration steps.

**Troubleshooting:**
1. Review the flow run history for specific error messages
2. Ensure all prerequisites are met (proper licenses, permissions)
3. Verify environment has sufficient storage capacity
4. Check that required connectors are not blocked by DLP policies
5. Run the Setup Wizard again after addressing errors

## Known Limitations

### CoE Starter Kit Support Model

> **Important:** The CoE Starter Kit is provided as an **unsupported, best-effort solution**. 
> - Investigation and support are provided through GitHub issues only
> - There is no SLA or guaranteed response time
> - The community and Microsoft product team provide assistance on a best-effort basis
> - For production-critical issues, consider commercial support options

For questions and issues:
- Review the [official documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- Search [existing GitHub issues](https://github.com/microsoft/coe-starter-kit/issues)
- Create a new issue using the appropriate template

### Full Inventory Requirement

**Important:** The CoE Starter Kit requires a **full inventory** of your tenant to function properly.

- You cannot filter or limit inventory collection to specific environments or resources
- All environments, apps, flows, and other resources must be inventoried
- Partial inventories will result in incomplete or inaccurate reporting
- If you need to exclude certain data from reports, use Power BI filters, not inventory exclusions

### Unmanaged Customizations

**Problem:** Solution updates fail or skip components due to unmanaged layers.

**Guidance:**
- Remove unmanaged layers before applying updates
- Use managed solutions for all customizations
- Export customizations before major upgrades
- Follow the [upgrade documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-upgrade) carefully

## Licensing and Pagination

### Pagination Limits with Trial or Insufficient Licenses

**Problem:** Inventory collection stops after 50-100 records, or flows show pagination errors.

**Root Cause:** The account running the flows does not have adequate licensing for Power Platform API pagination.

**License Requirements:**
- Premium Power Apps license (per app or per user) OR
- Power Automate per user/per flow license OR
- Office 365 E3/E5 OR
- Dynamics 365 license

**Test for License Adequacy:**

Run this Power Automate flow action to test pagination:
```
Action: List rows (Dataverse connector)
Table: Environments
Row limit: 5000
```

If the flow fails or returns fewer than expected results with pagination errors, the license is insufficient.

**Resolution:**
1. Ensure the service account has a proper license assigned (not trial)
2. Wait 24-48 hours after license assignment for full propagation
3. Verify license in Microsoft 365 admin center
4. Re-run inventory flows after license is confirmed active

### Trial License Limitations

**Important:** Trial licenses have significant limitations:
- Cannot access pagination for API calls
- Limited to 50-100 records in many scenarios
- Not suitable for production CoE Starter Kit deployments
- Can cause inventory collection to appear "complete" when it's actually truncated

**Recommendation:** Always use fully licensed accounts for CoE Starter Kit service accounts.

## Data Lake (BYODL) Guidance

### BYODL (Bring Your Own Data Lake) Status

> **Important Update:** BYODL is **no longer recommended** for new implementations.

**Current Status:**
- BYODL functionality is in maintenance mode only
- No new features or enhancements are planned for BYODL
- Existing implementations will continue to function
- Microsoft is investing in Fabric integration instead

**Recommended Path:**
- **New implementations:** Use Cloud Flows for inventory collection
- **Existing BYODL users:** Plan migration to Cloud Flows or await Fabric integration
- **Future direction:** Monitor announcements for Power Platform + Fabric integration

**Why This Change:**
- Fabric provides enterprise-scale data lake capabilities
- Better integration with Microsoft's data platform strategy
- Reduced maintenance burden for CoE Starter Kit team
- Cloud Flows provide adequate performance for most scenarios

**If You Must Use BYODL:**
- Carefully follow existing documentation (noting it may become outdated)
- Understand that troubleshooting support will be limited
- Plan for eventual migration to Cloud Flows or Fabric

## Language and Localization

### English Language Pack Requirement

**Problem:** Flows fail with schema errors, or apps display incorrectly.

**Root Cause:** The CoE Starter Kit is designed for **English-only localization**.

**Requirements:**
- The environment where CoE Starter Kit is installed **must** have the English language pack enabled
- The base language of Dataverse tables and columns must be English
- Even in multi-language environments, English must be the primary or enabled language

**Resolution:**
1. Navigate to Power Platform Admin Center
2. Select your CoE environment
3. Go to Settings → Languages
4. Ensure **English** is enabled (and preferably set as base language)
5. If English is not available, create a new environment with English as base language
6. Migrate CoE Starter Kit to the English-enabled environment

**Multi-Language Support:**
- While the environment must support English, end-user apps may support localization
- Reports and dashboards will be in English
- Flow run histories and error messages will be in English
- Canvas apps can be localized using standard Power Apps localization techniques (but core tables must remain English)

## Cleanup and Maintenance

### Inventory Cleanup Flow

The CoE Starter Kit includes cleanup flows to remove stale or deleted resources from inventory.

**Key Flows:**
- `Admin | Sync Template v3 (Check Deleted)` - Identifies deleted resources
- Cleanup flows run on a schedule to remove orphaned records

**Best Practices:**
- Do not manually delete records from inventory tables
- Allow cleanup flows to handle removal of stale data
- Review cleanup flow run history periodically
- Understand that cleanup may take 24-48 hours after resource deletion

### Performance Optimization

For large tenants (> 5000 apps/flows):

**Considerations:**
1. Inventory collection may take several hours daily
2. Consider running inventory flows during off-peak hours
3. Monitor Dataverse storage consumption
4. Review and archive old audit logs periodically
5. Use Power BI incremental refresh for large datasets

## Getting Help

### Before Creating an Issue

1. **Search existing issues**: Your question may already be answered
2. **Check official documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
3. **Review release notes**: Check if your issue is resolved in newer versions
4. **Verify prerequisites**: Ensure your environment meets all requirements

### Creating a Quality Issue Report

When reporting issues, include:

1. **CoE Starter Kit version** (e.g., 4.50.6)
2. **Affected component** (Core, Governance, Nurture, etc.)
3. **Specific app or flow** having the issue
4. **Inventory method** (Cloud Flows or Data Export)
5. **Steps to reproduce** the issue
6. **Error messages** (full text or screenshots)
7. **Environment details** (tenant size, license types)
8. **What you've already tried** to resolve the issue

### Standard Questionnaire

If an issue lacks detail, ask for:

- **Describe the issue**: What specific problem are you experiencing?
- **Expected Behavior**: What should happen instead?
- **Solution affected**: Which CoE component (Core, Governance, Nurture, etc.)?
- **Solution version**: What version of the CoE Starter Kit are you using?
- **App or flow**: Which specific app or flow is affected?
- **Inventory method**: Cloud flows or Data Export?
- **Steps to reproduce**: Detailed steps to recreate the issue
- **Additional context**: Screenshots, error messages, or other relevant information

## Additional Resources

- **Official Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **GitHub Repository**: https://github.com/microsoft/coe-starter-kit
- **GitHub Discussions**: https://github.com/microsoft/coe-starter-kit/discussions
- **Release Notes**: Check the Releases section for version-specific information
- **Community Forums**: Power Platform Community for general governance questions

---

*Last Updated: 2026-01-07*
*This is a living document. Contributions via pull requests are welcome.*
