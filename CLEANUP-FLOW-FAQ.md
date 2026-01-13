# CLEANUP Flow - Frequently Asked Questions

## Overview

The **CLEANUP - Admin | Sync Template v4 (Check Deleted)** flow is a critical component of the CoE Starter Kit that manages the lifecycle of inventory data in the Dataverse tables. This document addresses common questions about its behavior and provides guidance on historical data retention.

## Common Questions

### Does the CLEANUP flow delete rows from backend Dataverse tables?

**Yes**, the CLEANUP flow can delete rows from backend Dataverse tables (such as `admin_flows`, `admin_apps`, `admin_environments`, etc.), but this behavior is **configurable**.

The flow's behavior is controlled by the **`admin_DeleteFromCoE`** environment variable with two modes:

1. **"yes" (Default)** - The flow will **permanently delete** records from CoE inventory tables after they have been marked as deleted for 2 months
2. **"no"** - The flow will only **mark records as deleted** (sets `admin_flowdeleted = true` and `admin_flowdeletedon = [timestamp]`) but **will not physically delete them**

### How does the cleanup process work?

The CLEANUP flow operates in two phases:

#### Phase 1: Mark Deleted Items
The flow queries the Power Platform APIs to identify resources (flows, apps, environments, etc.) that no longer exist in the actual environments and marks them as deleted in the CoE inventory by:
- Setting the `admin_[resourcetype]deleted` field to `true`
- Setting the `admin_[resourcetype]deletedon` field to the current timestamp

#### Phase 2: Remove Old Deleted Items (Conditional)
If `admin_DeleteFromCoE` is set to "yes", the flow will:
- Query for records where `admin_[resourcetype]deleted = true` AND `admin_[resourcetype]deletedon < [2 months ago]`
- **Permanently delete** these records from the Dataverse tables

This 2-month grace period ensures that temporarily unavailable resources or false positives are not immediately removed from historical records.

### How frequently are flows removed from inventory?

The CLEANUP flow runs on the following schedule:
- **Frequency**: Weekly
- **Day**: Sunday
- **Time**: 12:00 (noon)

The timeline for a deleted flow:
1. **Day 0**: Flow is deleted from the environment
2. **First Sunday after deletion**: Flow is marked as deleted (`admin_flowdeleted = true`)
3. **~8 weeks later**: If `admin_DeleteFromCoE = "yes"`, the flow record is permanently deleted from CoE inventory

### Why are previously listed flows now missing?

If flows that were present in your CoE inventory are now missing, this could be due to:

1. **The CLEANUP flow is enabled with default settings** (`admin_DeleteFromCoE = "yes"`)
2. **The flows were deleted from the environment more than 2 months ago**
3. **The cleanup grace period has expired**, causing permanent deletion from the CoE inventory

This is the expected behavior when the CLEANUP flow is configured to delete old records.

## Recommended Approach for Historical Data Retention

If you need to retain historical records for reporting, auditing, or compliance purposes, consider the following approaches:

### Option 1: Change the Environment Variable (Recommended for Most Scenarios)

Change the `admin_DeleteFromCoE` environment variable to **"no"**:

1. Navigate to your CoE environment in Power Apps
2. Go to **Solutions** > **Center of Excellence - Core Components**
3. Select **Environment Variables**
4. Find **"Also Delete From CoE"** (`admin_DeleteFromCoE`)
5. Change the **Current Value** from "yes" to **"no"**
6. Save the change

**Benefits:**
- Records are marked as deleted but retained in the database
- You can query historical data by including records where `admin_flowdeleted = true`
- Maintains full audit trail

**Considerations:**
- Database will grow over time as deleted records accumulate
- You may need to implement your own archival strategy for very old records
- Dashboard filters may need adjustment to exclude deleted items

### Option 2: Export Data Before Cleanup

Implement a separate flow or Power BI export process that:
1. Runs before the CLEANUP flow
2. Exports CoE inventory data to a data warehouse, Azure SQL, or other long-term storage
3. Allows the CLEANUP flow to remove old records while preserving historical data externally

**Benefits:**
- Keeps CoE environment database size manageable
- Provides long-term historical data in optimized storage
- Can implement custom retention policies

### Option 3: Adjust the Cleanup Time Window

If 2 months is too short for your needs, you can modify the flow:

1. Export the solution
2. Unpack the solution
3. Edit the flow definition JSON
4. Find the `Get_old_deletes_time` action
5. Change the `interval` from `2` to a longer period (e.g., `6` for 6 months, `12` for 1 year)
6. Repack and import the solution as an unmanaged solution

**Note**: This approach requires maintaining a customized version of the solution and may complicate future upgrades.

### Option 4: Implement a Separate Historical Archive Flow

Create a custom flow that:
1. Runs on a schedule (e.g., monthly)
2. Queries records where `admin_flowdeleted = true` and `admin_flowdeletedon < [your retention period]`
3. Copies these records to a separate archive table or external storage
4. Allows the CLEANUP flow to proceed with its default behavior

## Best Practices

1. **Document Your Decision**: Clearly document which approach you've chosen and why
2. **Monitor Database Size**: If retaining deleted records, monitor your Dataverse database size
3. **Test in Non-Production**: Test your retention strategy in a test environment first
4. **Review Regularly**: Periodically review your data retention needs and adjust accordingly
5. **Consider Compliance**: Ensure your approach meets your organization's compliance and audit requirements

## Related Resources

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Core Components Overview](https://docs.microsoft.com/power-platform/guidance/coe/core-components)
- [Environment Variables in Solutions](https://docs.microsoft.com/power-platform/alm/environment-variables)

## Additional Notes

- The CLEANUP flow affects multiple resource types: Flows, Apps, Environments, Solutions, Connectors, Business Process Flows, Power Virtual Agents, and AI Models
- All resource types follow the same 2-month grace period before deletion
- The flow uses pagination to handle large datasets (100,000 records minimum)
- The flow includes retry logic with exponential backoff for resilience

## Support

For additional questions or issues:
1. Check the [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. Review the [CoE Starter Kit Community Forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
3. Submit a new issue using the appropriate template

---

**Last Updated**: December 2024  
**Applies To**: CoE Starter Kit v4.50.6 and later
