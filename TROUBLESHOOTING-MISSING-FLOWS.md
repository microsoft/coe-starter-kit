# Troubleshooting: Missing Flow Records in CoE Inventory

## Issue Description

Flows that were previously visible in the CoE Starter Kit inventory (Dataverse `admin_flows` table and CoE Dashboard) are no longer present, and the **CLEANUP - Admin | Sync Template v4 (Check Deleted)** flow is enabled.

## Root Cause Analysis

When the CLEANUP flow is enabled with the default configuration (`admin_DeleteFromCoE = "yes"`), it performs the following actions:

1. **Detection Phase**: Identifies flows that have been deleted from Power Platform environments
2. **Marking Phase**: Sets `admin_flowdeleted = true` and records `admin_flowdeletedon` timestamp
3. **Cleanup Phase**: After 2 months, permanently deletes records from the `admin_flows` table

## Verification Steps

### Step 1: Check if Records Were Deleted vs. Marked

Run this query in Power Apps or via API to check for marked-deleted flows:

```
Filter: admin_flowdeleted eq true
Sort: admin_flowdeletedon descending
```

If you find records with `admin_flowdeleted = true`, they have been marked but not yet deleted.

### Step 2: Check the Environment Variable Setting

1. Navigate to your CoE environment
2. Go to **Solutions** > **Center of Excellence - Core Components**
3. Select **Environment Variables**
4. Find **"Also Delete From CoE"** (`admin_DeleteFromCoE`)
5. Check the **Current Value**:
   - If "yes": Records are being permanently deleted after 2 months
   - If "no": Records are only marked as deleted, not removed

### Step 3: Review CLEANUP Flow Run History

1. Navigate to the CoE environment
2. Open **Solutions** > **Center of Excellence - Core Components**
3. Find the flow **"CLEANUP - Admin | Sync Template v4 (Check Deleted)"**
4. Review the **Run History**:
   - Check recent successful runs
   - Look for "Delete_Each_Flow" actions
   - Review the number of records processed

### Step 4: Determine Timeline

Calculate when flows were deleted:
- If a flow was deleted from the environment more than 2 months ago
- AND the CLEANUP flow has run since then
- AND `admin_DeleteFromCoE = "yes"`
- THEN the flow record has been permanently deleted from CoE inventory

## Resolution Options

### Quick Fix: Prevent Future Deletions

To stop the CLEANUP flow from deleting historical records:

1. Navigate to the CoE environment
2. Go to **Solutions** > **Center of Excellence - Core Components**  
3. Select **Environment Variables**
4. Find **"Also Delete From CoE"** (`admin_DeleteFromCoE`)
5. Click **Edit**
6. Change **Current Value** to: `no`
7. Click **Save**

**Effect**: Future deleted flows will be marked as deleted but retained in the database for historical reporting.

### Data Recovery: Re-run Inventory Sync

If flows still exist in the environments but were incorrectly marked as deleted:

1. Verify flows still exist in Power Platform environments
2. Run the **Admin | Sync Template v4 (Flows)** flow manually
3. The flow will update the inventory and clear the deleted flag

**Note**: This only works if the flows still exist in the actual environments.

### Data Recovery: Restore from Backup (if available)

If you have Dataverse backups:

1. Contact your Dataverse administrator
2. Request a restore of the `admin_flows` table to a point before deletion
3. Change the `admin_DeleteFromCoE` setting to "no" to prevent future deletions

### Historical Reporting: Query Archive Data

If you had exported data before deletion:

1. Use your exported data for historical reports
2. Join current inventory with historical exports for complete view
3. Implement automated export process going forward

## Prevention Strategies

### Strategy 1: Implement Scheduled Exports

Create a Power Automate flow to export CoE inventory data:

**Schedule**: Run before the CLEANUP flow (e.g., Saturday night)

**Actions**:
1. Query `admin_flows`, `admin_apps`, and other inventory tables
2. Export to:
   - Azure Data Lake
   - SharePoint List
   - Azure SQL Database
   - CSV files in SharePoint/OneDrive

**Retention**: Keep exports for your required compliance period

### Strategy 2: Set Up Power BI Historical Dataset

Configure Power BI to capture snapshots:

1. Create a Power BI dataflow that imports CoE data
2. Configure incremental refresh with historical data retention
3. Use Power BI dataset as historical archive
4. Update existing reports to use historical dataset

### Strategy 3: Create Custom Archive Table

Create a companion archive solution:

1. Create custom Dataverse tables (e.g., `admin_flows_archive`)
2. Build a flow that copies marked-deleted records before cleanup
3. Maintain separate reporting for current vs. archived data
4. Control retention policy independently

### Strategy 4: Extend Cleanup Grace Period

Modify the CLEANUP flow to extend beyond 2 months:

**Warning**: This requires maintaining a customized solution and may complicate upgrades.

1. Export the **Center of Excellence - Core Components** solution
2. Unpack using the Power Platform CLI
3. Edit the flow JSON file: `CLEANUP-AdminSyncTemplatev4CheckDeleted-*.json`
4. Find the `Get_old_deletes_time` action
5. Change:
   ```json
   "inputs": {
     "interval": 2,
     "timeUnit": "Month"
   }
   ```
   To (e.g., for 6 months):
   ```json
   "inputs": {
     "interval": 6,
     "timeUnit": "Month"
   }
   ```
6. Repack and import as unmanaged solution

## Dashboard Impact

After changing `admin_DeleteFromCoE` to "no", you may need to adjust dashboards:

### Filter Deleted Items in Reports

Add filters to exclude deleted items:

**Power BI**:
```
Table[admin_flowdeleted] <> true
```

**Model-Driven Apps**:
1. Edit views
2. Add filter: "Flow Deleted" equals "No"
3. Save and publish

### Create Historical Reports

To include deleted items in historical analysis:

**Power BI**:
```
// Include all flows with deletion date
Table[admin_flowdeleted] = true OR Table[admin_flowdeleted] = false
```

Add a visual indicator for deleted status in reports.

## Monitoring and Maintenance

### Set Up Alerts

Monitor the size of your CoE environment:

1. Create a Power BI report showing record counts over time
2. Set up alerts if database size exceeds thresholds
3. Review quarterly to ensure data retention policy is sustainable

### Regular Review Schedule

Establish a quarterly review:

- [ ] Review `admin_DeleteFromCoE` setting
- [ ] Check database size and growth rate
- [ ] Verify backup and export processes are working
- [ ] Update retention policy based on business needs
- [ ] Test data recovery procedures

## Related Issues

Similar behavior affects these inventory tables:
- `admin_apps` (Canvas and Model-Driven Apps)
- `admin_environments` (Environments)
- `admin_solutions` (Solutions)
- `admin_customconnectors` (Custom Connectors)
- `admin_businessprocessflowses` (Business Process Flows)
- `admin_chatbots` (Power Virtual Agents)
- `admin_aimodels` (AI Models)
- `admin_flowactiondetails` (Flow Action Details)

All follow the same cleanup logic and 2-month grace period.

## Additional Resources

- [CLEANUP Flow FAQ](./CLEANUP-FLOW-FAQ.md) - Detailed FAQ about the CLEANUP flow behavior
- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Dataverse Data Retention](https://docs.microsoft.com/power-platform/admin/data-retention-overview)

## Contact Support

If you continue to experience issues:

1. Verify the CLEANUP flow is not in an error state
2. Check the CoE solution health in the environment
3. Review Dataverse capacity and limits
4. Submit an issue on [GitHub](https://github.com/microsoft/coe-starter-kit/issues) with:
   - Solution version
   - `admin_DeleteFromCoE` setting
   - CLEANUP flow run history
   - Number of affected records
   - Timeline of when flows went missing

---

**Issue Type**: Data Retention / Inventory Management  
**Affected Versions**: CoE Starter Kit v4.50.6 and later  
**Severity**: Medium (Data Loss Prevention)  
**Last Updated**: December 2024
