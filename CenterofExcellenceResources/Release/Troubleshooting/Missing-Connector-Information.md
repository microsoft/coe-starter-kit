# Troubleshooting: Missing Connector Information in Power Apps Reports

## Issue Description
After installing the November 2025 version of the CoE Starter Kit, some Power Apps reports may show missing connector information for specific apps or environments. The "Connectors used in apps" visual may appear blank even though the connector flow is running successfully.

## Symptoms
- The "Connectors used in apps" report section is blank for certain apps/environments
- Other reports display information correctly
- The **Admin | Sync Template v3 - Connectors** flow shows successful runs
- The **Admin | Sync Template v4 - Driver** flow completes without errors

## Root Causes
This issue can occur due to several reasons:

### 1. **Incomplete Initial Inventory**
The sync template flows may not have completed a full initial inventory run, particularly for connector data related to specific apps.

### 2. **Pagination Limits with Insufficient Licensing**
Trial licenses or insufficient licensing may cause the connector sync flow to hit pagination limits before retrieving all connector data.

### 3. **Environment-Specific Sync Issues**
Individual environments may have been excluded from inventory or experienced sync failures during the connector data collection phase.

### 4. **App-Connector Relationship Data Missing**
The relationship between apps and their connectors may not have been synced properly, even though both app and connector data exist independently.

### 5. **Data Refresh Timing**
Power BI reports may be showing cached data that predates the connector sync completion.

## Troubleshooting Steps

### Step 1: Verify Connector Flow Run History
1. Navigate to the CoE Admin environment in Power Automate
2. Locate the flow: **Admin | Sync Template v3 - Connectors**
3. Check the 28-day run history
4. Look for:
   - Failed runs (indicated by red X icons)
   - Runs that completed but with warnings
   - The timestamp of the last successful run

**Expected Behavior**: The flow should complete successfully with green checkmarks and process all environments.

### Step 2: Check License Adequacy for Pagination
Insufficient licensing can cause pagination limits that prevent full data retrieval.

**To test your license adequacy**:
1. Review the Microsoft documentation on CoE Starter Kit licensing requirements: [CoE Starter Kit Setup Prerequisites](https://learn.microsoft.com/power-platform/guidance/coe/setup)
2. Ensure the service account running the flows has one of the following:
   - Power Apps per user license
   - Power Automate per user license
   - Microsoft 365 license with Power Platform access
   - **NOT** a trial license

**Trial licenses will hit pagination limits.**

### Step 3: Run a Manual Full Inventory
Force a complete re-sync of connector data:

1. Navigate to **Admin | Sync Template v4 - Driver** flow
2. Click **Run** to trigger a manual execution
3. Wait for the flow to complete (this may take several hours for large tenants)
4. After completion, check the **Admin | Sync Template v3 - Connectors** child flow runs

The Driver flow orchestrates all sync template flows and should trigger a comprehensive data collection across all environments.

### Step 4: Verify Environment Inventory Settings
Check if the affected environment is excluded from inventory:

1. Open the **Power Platform Admin View** app in the CoE environment
2. Navigate to **Environments**
3. Find the environment where apps are missing connector data
4. Check the **Excuse from Inventory** field
   - If set to **Yes**, the environment is excluded from inventory
   - Change to **No** to include it
5. Save the record
6. Re-run the **Admin | Sync Template v4 - Driver** flow

### Step 5: Check App-Connector Relationship Data
The connector data may exist, but the relationship to apps may be missing:

1. Open the **Power Platform Admin View** app
2. Navigate to **Apps**
3. Find the affected app
4. Click on the app record to view details
5. Check the **Related** tab for **Connectors**
6. If no connectors are listed but you know the app uses connectors, this indicates a sync issue

**Resolution**: Run the **Admin | Sync Template v4 - Apps** flow manually for the specific environment.

### Step 6: Validate Data in Dataverse Tables
Directly check if connector data exists in the underlying tables:

1. Navigate to **Power Apps** > **Tables** in your CoE environment
2. Open the **admin_Connector** table
3. Use **Advanced Find** or filters to search for:
   - Connectors by name
   - Connectors modified recently
4. Verify records exist for the connectors you expect to see

If connector records exist but aren't showing in reports, the issue is likely with the Power BI report refresh.

### Step 7: Refresh Power BI Reports
1. Open the Power BI workspace containing your CoE reports
2. Locate the dataset for the report (e.g., "Production CoE Dashboard")
3. Click **Refresh Now** or configure scheduled refresh
4. Wait for refresh to complete (check refresh history)
5. Re-open the Power Apps report

**Note**: Power BI reports may cache data for up to 24 hours depending on your refresh schedule.

### Step 8: Check for Dataverse API Throttling
High volumes of API calls can trigger throttling, causing incomplete syncs:

1. Check the flow run history for the **Admin | Sync Template v3 - Connectors** flow
2. Expand failed or slow-running actions
3. Look for error messages containing:
   - "429 Too Many Requests"
   - "Rate limit exceeded"
   - Retry messages

**Resolution**: 
- Enable the **DelayInventory** environment variable (set to Yes)
- This adds delays between API calls to prevent throttling
- Re-run the sync flows

### Step 9: Verify Environment Variable Configuration
Ensure all required environment variables are properly configured:

1. Navigate to **Solutions** > **Center of Excellence - Core Components**
2. Go to **Environment Variables**
3. Verify the following variables have values:
   - **Power Automate Environment Variable**: Should match your region (e.g., `https://flow.microsoft.com/manage/environments/`)
   - **is All Environments Inventory**: Should be set to **Yes** for full tenant inventory
4. If any variables are missing values, update them
5. Re-run the sync flows

### Step 10: Check for Unmanaged Layers
Unmanaged customizations can prevent solution updates from applying correctly:

1. Navigate to **Solutions** > **Center of Excellence - Core Components**
2. Select the solution
3. Click **See solution layers** for the **Admin | Sync Template v3 - Connectors** flow
4. Check if there are **Unmanaged** layers above the **Managed** layer

**If unmanaged layers exist**:
1. Document any customizations
2. Remove the unmanaged layer
3. Reapply customizations if needed
4. This ensures you receive updates properly

### Step 11: Review Connector Flow Logic
Inspect the connector flow for potential issues:

1. Open the **Admin | Sync Template v3 - Connectors** flow in edit mode
2. Review the flow logic, particularly:
   - The **Get Connectors** action (should have pagination enabled)
   - The **Apply to each Standard Connector** loop
   - Any filter conditions that might exclude certain connectors
3. Check for custom modifications that might affect sync behavior

## Prevention and Best Practices

### 1. **Use Adequate Licensing**
- Ensure the service account has appropriate licensing (not trial)
- This prevents pagination limits and ensures complete data retrieval

### 2. **Schedule Regular Full Inventories**
- The Driver flow runs daily by default
- Consider running it more frequently during initial setup
- Monitor the run history for consistent success

### 3. **Enable Delay for Inventory**
- Set the **DelayInventory** environment variable to **Yes**
- This helps prevent API throttling in large tenants

### 4. **Monitor Flow Run History**
- Regularly check sync flow run histories
- Address failures promptly
- Set up alerts for flow failures

### 5. **Keep Solutions Updated**
- Install updates promptly when new versions are released
- Follow the upgrade guide: [CoE Starter Kit After Setup](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)

### 6. **Avoid Unmanaged Customizations**
- Customizations should be made in separate solutions
- This ensures you can receive updates cleanly

### 7. **Validate After Upgrades**
- After installing updates, manually run the Driver flow
- Verify reports show expected data
- Check for any new environment variables that need configuration

## Additional Resources

- **CoE Starter Kit Documentation**: [https://learn.microsoft.com/power-platform/guidance/coe/starter-kit](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- **Setup Instructions**: [https://learn.microsoft.com/power-platform/guidance/coe/setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- **Upgrade Guide**: [https://learn.microsoft.com/power-platform/guidance/coe/after-setup](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)
- **Known Limitations**: [https://learn.microsoft.com/power-platform/guidance/coe/limitations](https://learn.microsoft.com/power-platform/guidance/coe/limitations)

## Related Flows

- **Admin | Sync Template v4 - Driver**: Orchestrates all sync operations
- **Admin | Sync Template v3 - Connectors**: Syncs connector information
- **Admin | Sync Template v4 - Apps**: Syncs app information and app-connector relationships
- **Admin | Sync Template v4 - Model Driven Apps**: Syncs model-driven apps
- **CLEANUP - Admin | Sync Template v4 - Check Deleted**: Removes deleted items from inventory

## Still Need Help?

If you've followed all troubleshooting steps and the issue persists:

1. **Search GitHub Issues**: [https://github.com/microsoft/coe-starter-kit/issues](https://github.com/microsoft/coe-starter-kit/issues)
2. **Open a New Issue**: Use the question template and provide:
   - Solution version (November 2025)
   - Specific app or environment affected
   - Screenshots of the issue
   - Flow run history details
   - Steps you've already tried
3. **Community Support**: Post in the [Power Platform Governance Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

## Important Notes

- The CoE Starter Kit is provided as-is with **no official support SLA**
- Issues are addressed on a best-effort basis via GitHub
- For production tenant issues requiring immediate support, consider engaging Microsoft Support for Power Platform licensing and API questions
- The CoE Starter Kit is a community-driven template and should be customized to fit your organization's needs
