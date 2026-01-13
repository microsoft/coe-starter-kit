# Troubleshooting: Apps and Flows Not Appearing in Power BI Dashboards

## Issue Description
After setting up the CoE Starter Kit and creating test apps and flows, they are not appearing in the Power BI dashboards even after refreshing.

## Common Root Causes

This is a common issue during initial setup and typically occurs due to one or more of the following reasons:

### 1. Inventory Flows Not Running or Not Completed
The inventory flows are responsible for collecting data about apps, flows, and other resources in your tenant. If these flows haven't run successfully, no data will be available in the dashboards.

**Key Flows to Check:**
- **Admin | Sync Template v3** (or v4) - Main inventory collection flow
- **Admin | Sync Flows v3** - Collects flow inventory
- **Admin | Sync Apps v2** - Collects app inventory  
- **SETUP WIZARD | Admin | Sync Template v3 (Setup)** - Initial setup flow

### 2. Insufficient Wait Time After Setup
The initial inventory collection can take considerable time depending on the size of your tenant:
- **Small tenants** (< 100 resources): 30-60 minutes
- **Medium tenants** (100-1000 resources): 2-4 hours
- **Large tenants** (> 1000 resources): 4-24 hours

### 3. Flow Execution Permissions Not Configured
The service account running the flows must have appropriate permissions:
- Power Platform Administrator or Dynamics 365 Administrator role
- Proper connection authentication to all required connectors

### 4. Data Refresh Not Configured in Power BI
Even if data exists in Dataverse, the Power BI report needs to be configured to refresh from the data source.

### 5. Incorrect Environment or Data Source Configuration
The Power BI report might be pointing to the wrong environment or data source.

## Step-by-Step Troubleshooting Guide

### Step 1: Verify Flow Status

1. Navigate to the CoE environment where you installed the Core components
2. Go to **Solutions** > **Center of Excellence - Core Components**
3. Select **Cloud flows** from the left navigation
4. Check the status of these critical flows:

| Flow Name | Expected Status | What It Does |
|-----------|----------------|--------------|
| SETUP WIZARD \| Admin \| Sync Template v3 (Setup) | Should have run once successfully | Initial setup and first inventory collection |
| Admin \| Sync Template v3 | Should run daily | Scheduled inventory collection |
| Admin \| Sync Flows v3 | Triggered by Sync Template | Collects flow details |
| Admin \| Sync Apps v2 | Triggered by Sync Template | Collects app details |

5. For each flow, check:
   - **Is it turned ON?** (flows are OFF by default after import)
   - **Has it run successfully?** (check run history)
   - **Are there any errors?** (review error messages if present)

### Step 2: Run the Inventory Flows Manually

If the flows haven't run yet or failed:

1. First, ensure all flows are **turned ON**
2. Run the **SETUP WIZARD | Admin | Sync Template v3 (Setup)** flow manually:
   - Open the flow
   - Click **Run** 
   - Wait for completion (this can take several minutes to hours)
3. Check the run history for any errors
4. Common errors and solutions:
   - **Connection not configured**: Configure connections for all connectors used
   - **Insufficient permissions**: Verify service account has admin privileges
   - **Throttling errors**: Normal for large tenants, flows will retry automatically

### Step 3: Verify Data in Dataverse

Once flows have run successfully, verify data is in Dataverse:

1. Go to **Power Apps** > **Tables** (in your CoE environment)
2. Check these key tables for data:
   - **Power Apps App** table - should contain your apps
   - **Flow** table - should contain your flows
   - **Power Platform User** table - should contain makers
3. Open each table and verify:
   - Records exist
   - Created dates are recent
   - Data looks accurate

### Step 4: Verify Power BI Data Source Configuration

1. Open your Power BI report (.pbix file or online)
2. Go to **Transform data** > **Data source settings**
3. Verify:
   - The environment URL is correct
   - Credentials are properly configured
   - You have access to the environment

### Step 5: Refresh Power BI Data

1. **In Power BI Desktop:**
   - Click **Refresh** in the ribbon
   - Wait for all tables to refresh
   - Check for any refresh errors

2. **In Power BI Service (online):**
   - Go to the dataset settings
   - Configure the gateway connection if needed
   - Click **Refresh now**
   - Set up scheduled refresh if desired

### Step 6: Wait and Monitor

If you've just set up the CoE Starter Kit:

1. **Wait at least 24 hours** for the initial inventory to complete
2. **Monitor flow run history** to ensure flows complete successfully
3. The inventory flows run on a schedule (typically daily), so new resources may not appear immediately

## Verification Checklist

Use this checklist to ensure proper setup:

- [ ] Core Components solution is installed and all components imported successfully
- [ ] Service account has Power Platform Administrator or Dynamics 365 Administrator role
- [ ] All required connections are created and authenticated
- [ ] Environment variables are configured correctly (especially the Environment ID)
- [ ] SETUP WIZARD flows have been run and completed successfully
- [ ] All inventory flows (Sync Template, Sync Apps, Sync Flows) are turned ON
- [ ] At least one successful run of the Admin | Sync Template v3 flow
- [ ] Data exists in Dataverse tables (Power Apps App, Flow, Power Platform User)
- [ ] Power BI report is connected to the correct environment
- [ ] Power BI data has been refreshed after flows completed
- [ ] Waited sufficient time (24+ hours for initial setup)

## Advanced Troubleshooting

### Check Pagination Limits and Licensing

The CoE Starter Kit uses Microsoft Dataverse APIs which may have pagination limits with trial or insufficient licenses:

1. **Verify your license**: You need appropriate Power Platform licenses
2. **Check for pagination warnings**: Review flow run history for warnings
3. **See**: [Power Platform Licensing](https://docs.microsoft.com/power-platform/admin/pricing-billing-skus)

### Verify English Language Pack

The CoE Starter Kit requires English language pack to be enabled in your environment:

1. Go to **Power Platform Admin Center**
2. Select your CoE environment
3. Go to **Settings** > **Product** > **Languages**
4. Ensure **English** is enabled

### Review Environment Variables

Incorrect environment variable values can cause inventory failures:

1. Go to **Solutions** > **Center of Excellence - Core Components**
2. Select **Environment variables**
3. Verify these critical variables:
   - **Admin eMail** - set to your admin email
   - **EnvironmentID** - set to your CoE environment GUID
   - **TenantID** - set to your tenant GUID

### Check for Unmanaged Customizations

Unmanaged layers can prevent updates and cause issues:

1. Go to your solution
2. Check for components with unmanaged layers
3. Remove unmanaged customizations if present

## Additional Resources

- **Official Setup Documentation**: https://docs.microsoft.com/power-platform/guidance/coe/setup
- **Core Components Documentation**: https://docs.microsoft.com/power-platform/guidance/coe/core-components
- **Power BI Dashboard Setup**: https://docs.microsoft.com/power-platform/guidance/coe/setup-powerbi
- **Troubleshooting Guide**: https://docs.microsoft.com/power-platform/guidance/coe/faq
- **Report Issues**: https://aka.ms/coe-starter-kit-issues

## Still Having Issues?

If you've followed all the steps above and still don't see data in your dashboards:

1. **Check for specific error messages** in flow run history and include them when asking for help
2. **Document what you've tried** using the checklist above
3. **Create an issue** at https://aka.ms/coe-starter-kit-issues with:
   - CoE Starter Kit version
   - Specific flows or apps affected
   - Screenshots of flow run history
   - Any error messages
   - Steps you've already tried

## Important Notes

- The CoE Starter Kit is a **community-supported** solution, not an official Microsoft product
- Initial inventory collection takes time - **patience is key**
- Flows run on a schedule - new resources may not appear immediately
- For large tenants, expect longer processing times and potential throttling
- The kit requires active maintenance and monitoring to function properly
