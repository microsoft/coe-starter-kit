# Quick Start: Cleanup Security Role Permission Data

This is a quick reference guide for cleaning up the `admin_EnvironmentSecurityRolePermission` table. For comprehensive information, see the [Data Retention and Maintenance Guide](DataRetentionAndMaintenance.md).

## Problem

The `admin_EnvironmentSecurityRolePermission` table is consuming significant storage and growing continuously.

## Quick Answer

**Is this expected?** Yes, this is expected behavior. The table stores security role snapshots and grows over time.

**What should I do?** Implement a bulk delete job to remove old records. Follow the steps below.

## Quick Fix: Create a Bulk Delete Job (5 minutes)

### Step 1: Access Bulk Delete

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your **CoE environment**
3. Go to **Settings** > **Data management** > **Bulk deletion**
4. Click **New**

### Step 2: Configure Deletion

**Look for:** Environment Security Role Permissions

**Condition:** Created On older than **90 days**

### Step 3: Schedule

**Name:** `Cleanup Security Role Permissions - 90 days`

**Frequency:** Weekly (recommended) or Monthly

**Start time:** Choose off-peak hours (e.g., Sunday 2:00 AM)

### Step 4: Notifications

Check: **Send email when complete**

Add: Your admin email address

### Step 5: Submit

Review and click **Submit**

## What This Does

- ✅ Removes security role permission records older than 90 days
- ✅ Runs automatically on your schedule
- ✅ Keeps recent data for dashboards and reports
- ✅ Reduces storage usage
- ✅ Does NOT impact current functionality

## What Data Gets Deleted

- Historical snapshots older than 90 days
- Data that's no longer needed by CoE dashboards
- Safe to delete without impacting CoE Starter Kit functionality

## What If I Need Historical Data?

If you need to keep historical data for compliance or analysis:

1. **Archive first** using Azure Data Lake or Azure SQL
2. **Then delete** from Dataverse to save storage

See the [Data Retention and Maintenance Guide](DataRetentionAndMaintenance.md) for archival instructions.

## Adjusting Retention Period

**30 days**: For minimal storage, if you only need recent data
**90 days**: Recommended balance (default in this guide)
**180 days**: For extended trend analysis

To change: Adjust the "older than X days" condition in Step 2

## Monitoring Results

After creating the bulk delete job:

1. Go to **Settings** > **Data management** > **Bulk deletion**
2. Click on your job name to see history
3. Check **Status**, **Records Deleted**, and **Completion Time**
4. Monitor storage in **Settings** > **Resources** > **Storage**

## Troubleshooting

**Job takes too long?**
- This is normal for large datasets (millions of records)
- Jobs run asynchronously and may take several hours
- Check job status in bulk deletion history

**Want faster cleanup?**
- Use PowerShell script (see full guide)
- Process in smaller batches first (e.g., records older than 180 days)

**Need help?**
- See [Data Retention and Maintenance Guide](DataRetentionAndMaintenance.md) for detailed information
- Ask questions in [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

## Other Tables That Grow

These tables also accumulate data and may benefit from cleanup:

- `admin_SyncFlowErrors` - Sync error logs
- `admin_FlowActionDetail` - Flow action metadata
- `admin_Audit` - Audit log entries

Apply the same bulk delete process with appropriate retention periods.

## Next Steps

1. **Create the bulk delete job** (follow steps above)
2. **Monitor first run** to confirm it works as expected
3. **Review storage savings** after first execution
4. **Adjust retention** if needed based on your requirements
5. **Read full guide** for other tables and advanced scenarios

## Full Documentation

For comprehensive information including:
- Archival strategies
- PowerShell scripts
- Power Automate flows
- Monitoring and best practices

See: **[Data Retention and Maintenance Guide](DataRetentionAndMaintenance.md)**

---

**Quick Reference Card**

| Task | Where to Go |
|------|-------------|
| Create bulk delete job | Power Platform Admin Center > Settings > Data management > Bulk deletion |
| Check storage usage | Power Platform Admin Center > Settings > Resources > Storage |
| Monitor bulk delete jobs | Power Platform Admin Center > Settings > Data management > Bulk deletion |
| Get detailed help | [Data Retention and Maintenance Guide](DataRetentionAndMaintenance.md) |
| Ask questions | [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) |

