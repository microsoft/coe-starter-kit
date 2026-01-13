# CoE Starter Kit - Data Retention and Maintenance Guide

This guide provides information on data retention policies, storage management, and maintenance procedures for the CoE Starter Kit tables, helping you manage database growth and optimize storage usage.

## Overview

The CoE Starter Kit collects and stores various types of data to provide insights into your Power Platform environment. Over time, some tables can grow significantly as they accumulate historical data. This guide helps you understand which tables grow over time, why they grow, and how to manage their size.

## Tables with Continuous Growth

### admin_EnvironmentSecurityRolePermission

**Purpose**: This table stores full security role permission snapshots each time the Security Role sync runs. It tracks who has which security roles across all environments in your tenant.

**Growth Pattern**: 
- **Expected Behavior**: Yes, continuous growth is expected
- **Reason**: The table uses an insert-only pattern. Each time the security role sync flow runs, it creates new snapshot records
- **Growth Rate**: Depends on:
  - Number of environments in your tenant
  - Number of users with security roles
  - Frequency of security role sync execution
  - Number of tracked security roles

**Storage Impact**: This table can consume significant storage (10+ GB) in large tenants with many environments and users.

### Other Growing Tables

Other CoE Starter Kit tables that accumulate historical data include:
- **admin_SyncFlowErrors**: Stores error logs from sync flows
- **admin_FlowActionDetail**: Stores detailed flow action metadata
- **admin_Audit**: Stores audit log entries (if audit log collection is enabled)

## Recommended Retention Policies

### admin_EnvironmentSecurityRolePermission

**Recommended Retention**: 30–90 days

**Rationale**:
- CoE dashboards and Power BI reports use only the latest snapshots
- Historical data beyond 30-90 days is rarely needed for operational insights
- Retaining 30-90 days provides sufficient history for trend analysis and compliance reporting

**What to Keep**:
- Latest snapshot for each user/environment/security role combination
- Recent data (last 30-90 days) for trend analysis

**What Can Be Deleted**:
- Records older than your retention period (e.g., 90 days)
- Deleted based on the `createdon` field

### General Retention Guidelines

For other CoE tables, consider:
- **Audit logs**: 90-180 days (or per your compliance requirements)
- **Sync errors**: 30-60 days (after issues are resolved)
- **Flow action details**: 60-90 days (depending on analytical needs)

## Data Cleanup Procedures

### Option 1: Dataverse Bulk Delete Jobs (Recommended)

Bulk Delete jobs are the recommended approach for cleaning up historical data in Dataverse.

#### Creating a Bulk Delete Job for Security Role Permissions

1. **Navigate to Power Platform Admin Center**
   - Go to [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
   - Select your CoE environment

2. **Access Bulk Delete**
   - In the environment, go to **Settings** > **Data management** > **Bulk deletion**
   - Click **New** to create a new bulk delete job

3. **Define Deletion Criteria**
   - **Look for**: Environment Security Role Permissions
   - **Use Saved View**: (None) – Custom view
   - Add condition: **Created On** older than **90 days** (adjust based on your retention policy)
   - Example query:
     ```
     Created On older than 90 days
     ```

4. **Configure Schedule**
   - **Name**: "Cleanup Security Role Permissions - 90 days retention"
   - **Run this job after every**: Select frequency (e.g., weekly, monthly)
   - **Starting**: Select start date and time
   - Recommended: Run during off-peak hours (e.g., weekends, nights)

5. **Notification Options**
   - Check **Send an email to [admin email] when this job completes**
   - Add administrators who should be notified

6. **Review and Submit**
   - Review the criteria
   - Click **Submit**

#### Bulk Delete Job Considerations

- **Performance**: Bulk delete jobs run asynchronously and may take hours for large datasets
- **API Limits**: Jobs are subject to Dataverse API limits
- **Monitoring**: Check the bulk delete job history in Settings > Data management > Bulk deletion
- **Testing**: Test with a small dataset first (e.g., records older than 180 days) before implementing shorter retention periods

### Option 2: Power Automate Flow

For more control or custom logic, create a scheduled Power Automate flow.

#### Example Flow Steps

1. **Trigger**: Scheduled (e.g., runs weekly on Sunday at 2 AM)

2. **List Records**: Use "List rows" action
   - **Table**: Environment Security Role Permissions
   - **Filter rows**: `createdon lt @{addDays(utcNow(), -90)}`
   - **Top count**: 5000 (process in batches to avoid timeouts)

3. **Delete Records**: Apply to each record
   - **Delete a row** action for each record
   - Consider adding error handling

4. **Notification**: Send email with deletion summary
   - Number of records deleted
   - Any errors encountered

#### Flow Considerations

- **Limitations**: Power Automate has execution time limits (consider using child flows for large datasets)
- **Throttling**: Implement delays or batch processing to avoid API throttling
- **Monitoring**: Add error handling and logging

### Option 3: PowerShell Script

For one-time cleanup or advanced scenarios, use PowerShell with the Dataverse API.

#### Example PowerShell Script

```powershell
# Install required module if not already installed
# Install-Module Microsoft.Xrm.Data.PowerShell -Scope CurrentUser

# Connect to your Dataverse environment
$conn = Get-CrmConnection -InteractiveMode

# Calculate retention date (90 days ago)
$retentionDate = (Get-Date).AddDays(-90).ToString("yyyy-MM-dd")

# Build FetchXML query
$fetchXml = @"
<fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='false'>
  <entity name='admin_environmentsecurityrolepermission'>
    <attribute name='admin_environmentsecurityrolepermissionid' />
    <filter type='and'>
      <condition attribute='createdon' operator='lt' value='$retentionDate' />
    </filter>
  </entity>
</fetch>
"@

# Execute query
$results = Get-CrmRecordsByFetch -conn $conn -Fetch $fetchXml

Write-Host "Found $($results.CrmRecords.Count) records to delete"

# Delete records (uncomment to execute)
# foreach ($record in $results.CrmRecords) {
#     Remove-CrmRecord -conn $conn -EntityLogicalName "admin_environmentsecurityrolepermission" `
#                      -Id $record.admin_environmentsecurityrolepermissionid
#     Write-Host "Deleted record $($record.admin_environmentsecurityrolepermissionid)"
# }

Write-Host "Cleanup complete"
```

#### PowerShell Considerations

- **Authentication**: Requires appropriate permissions
- **Performance**: Can process records faster than Power Automate for large datasets
- **Testing**: Always test with a small dataset first (uncomment delete section only after verification)

## Data Archival Strategies

If you need to retain historical data for compliance or long-term analysis, consider archiving before deletion.

### Option 1: Export to Azure Data Lake

1. **Enable Dataverse Data Export**
   - Go to Power Platform Admin Center > your environment
   - Navigate to **Settings** > **Integration** > **Data export**
   - Configure export to Azure Data Lake Storage Gen2

2. **Configure Tables for Export**
   - Select `admin_EnvironmentSecurityRolePermission` and other tables
   - Data will be automatically synced to Data Lake

3. **Implement Retention in Dataverse**
   - After data is exported, implement bulk delete jobs to remove old records from Dataverse
   - Archived data remains in Data Lake for long-term storage and analysis

### Option 2: Export to Azure SQL Database

1. **Create Azure SQL Database**
   - Set up Azure SQL Database for archived data

2. **Create Data Export Flow**
   - Use Power Automate or Azure Data Factory
   - Export records older than retention period
   - Store in Azure SQL with appropriate indexes

3. **Delete After Archival**
   - After successful export, delete records from Dataverse

### Option 3: Manual Export for Compliance

For smaller datasets or periodic archival:

1. **Export to Excel**
   - Navigate to the table in Power Apps or Power Platform Admin Center
   - Use Advanced Find or Power BI to query historical data
   - Export results to Excel or CSV

2. **Store in SharePoint or OneDrive**
   - Save exported files to SharePoint document library
   - Apply retention policies in SharePoint

## Monitoring Storage Usage

### Check Table Storage Size

1. **Power Platform Admin Center**
   - Go to [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
   - Select your CoE environment
   - Navigate to **Settings** > **Resources** > **Storage**
   - View storage consumption by table

2. **Power BI Report**
   - Use the CoE Starter Kit Power BI dashboard
   - Review table size metrics (if available in your version)

### Set Up Alerts

Consider setting up alerts when storage usage exceeds thresholds:
- Use Power Automate to monitor storage metrics
- Send notifications when tables exceed expected size
- Proactively schedule cleanup jobs

## Best Practices

1. **Establish Retention Policies**
   - Define retention periods for each table type
   - Document retention policies for compliance
   - Review and update policies annually

2. **Schedule Regular Cleanup**
   - Implement automated bulk delete jobs
   - Run during off-peak hours to minimize impact
   - Monitor job execution and success rates

3. **Archive Before Deletion**
   - If compliance or analysis requires historical data, archive first
   - Use Azure Data Lake or Azure SQL for long-term storage
   - Test restore procedures to ensure archived data is accessible

4. **Test Thoroughly**
   - Always test cleanup jobs with small datasets first
   - Verify dashboards and reports still function after cleanup
   - Monitor for any issues after implementing cleanup

5. **Document Your Approach**
   - Document retention policies and procedures
   - Share with your CoE team and stakeholders
   - Include cleanup schedules and contact information

6. **Monitor Impact**
   - Track storage savings after cleanup
   - Monitor performance improvements
   - Adjust retention periods based on actual needs

## Impact Assessment

### What Won't Be Impacted

- **Current insights**: Dashboards use latest snapshots, not historical data
- **Functionality**: CoE apps and flows work with current data
- **Security**: Deleting old snapshots doesn't affect current security role assignments

### What Might Be Impacted

- **Historical trend analysis**: If you need long-term security role trends, archive before deletion
- **Compliance reporting**: If regulations require longer retention, adjust policies accordingly
- **Forensic investigations**: If investigating historical security issues, archive before deletion

## Automatic Cleanup Jobs Status

**Current Status**: The CoE Starter Kit does **not** include automatic cleanup jobs for the `admin_EnvironmentSecurityRolePermission` table or other historical data tables.

**Recommendation**: Implement bulk delete jobs or custom flows as described in this guide.

**Future Considerations**: The CoE team may add optional cleanup flows in future releases. Check [release notes](https://github.com/microsoft/coe-starter-kit/releases) for updates.

## Partitioning and Compression

### Dataverse Capabilities

**Partitioning**: Dataverse does not support custom table partitioning. This is managed automatically by the platform.

**Compression**: Dataverse handles data compression at the platform level. You cannot configure custom compression for individual tables.

**Indexing**: Dataverse automatically indexes key fields. No custom index configuration is available for this table.

### Recommended Approach

Since partitioning and compression are not configurable, the only supported approach is:
1. **Delete old records** using bulk delete jobs or flows
2. **Archive data** externally (Azure Data Lake, Azure SQL) if needed for long-term storage

## Related Resources

### Official Documentation

- [Dataverse Bulk Delete](https://learn.microsoft.com/power-platform/admin/delete-bulk-records)
- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Dataverse Storage Capacity](https://learn.microsoft.com/power-platform/admin/capacity-storage)
- [Azure Data Lake Integration](https://learn.microsoft.com/power-apps/maker/data-platform/azure-synapse-link-select-fno-data)

### Community Resources

- [CoE Starter Kit GitHub Repository](https://github.com/microsoft/coe-starter-kit)
- [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

## Support and Questions

For questions about data retention and maintenance:

1. **Check existing issues**: Search [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar questions
2. **Ask the community**: Use the [question template](https://github.com/microsoft/coe-starter-kit/issues/new/choose) to ask questions
3. **Consult official docs**: Review [CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

## Revision History

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-13 | 1.0 | Initial documentation created based on community feedback and common questions about admin_EnvironmentSecurityRolePermission table storage growth |

---

**Note**: This guide is part of the CoE Starter Kit, which is provided as-is with best-effort support through the GitHub community. Always test data retention procedures in a non-production environment first and ensure compliance with your organization's data retention policies.
