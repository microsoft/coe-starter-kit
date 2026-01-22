# Flow Action Details Batch Size Configuration

## Overview

This document describes the batch processing implementation for the **Admin | Sync Template v3 (Flow Action Details)** flow to address scalability issues in large environments.

## Problem Statement

In environments with a large number of flows (~90,000+), the `Admin | Sync Template v3 (Flow Action Details)` flow could fail with the following error:

```
The aggregated results size exceeds the maximum allowed size (>225MB)
```

This occurred because the flow attempted to retrieve all flows matching the criteria in a single operation, resulting in a payload that exceeded Power Automate's result size limit.

### Related Issue
- GitHub Issue: [#10256](https://github.com/microsoft/coe-starter-kit/issues/10256)

## Solution

The flow has been updated to implement batch processing with a configurable batch size. This allows the flow to process flows in smaller, manageable batches that stay well under the 225MB limit.

### Changes Made

1. **New Environment Variable**: `admin_FlowActionDetailsBatchSize`
   - **Default Value**: 5000
   - **Type**: Integer (Decimal Number)
   - **Recommended Range**: 1000-10000
   - **Description**: Controls the maximum number of flows processed in each flow run

2. **Flow Updates**:
   - Added `$top` parameter to `Flows_to_iterate` action
   - Added `$top` parameter to `Flows_to_iterate_with_specialty_flags` action
   - Updated pagination policies to use the batch size parameter

### How It Works

#### Before the Fix
```
Environment has 90,000 flows
↓
Flow attempts to retrieve all 90,000 flows at once
↓
Result payload exceeds 225MB
↓
Flow fails with aggregated results size error
```

#### After the Fix
```
Environment has 90,000 flows flagged for processing
↓
Flow Run 1: Processes first 5,000 flows, clears their flags
↓
Flow Run 2: Processes next 5,000 flows, clears their flags
↓
...continues until all flows are processed
↓
Each run stays well under the 225MB limit
```

The flow processes flows in batches based on the `admin_inventorymyflowactiondetails` flag:
- Flows that need action details inventoried have this flag set to `true` (by another flow)
- This flow queries up to `FlowActionDetailsBatchSize` flows where the flag is `true`
- After successfully processing a batch, it sets the flag back to `false`
- Subsequent runs pick up the next batch of flagged flows
- This continues until all flagged flows are processed

## Configuration

### Setting the Batch Size

1. Navigate to **Power Platform Admin Center**
2. Open the CoE environment
3. Go to **Settings** > **Environment variables**
4. Find **FlowActionDetailsBatchSize**
5. Set the value based on your needs:

   | Environment Size | Recommended Batch Size | Processing Time per Run |
   |-----------------|------------------------|------------------------|
   | < 10,000 flows  | 5000 (default)        | ~10-20 minutes        |
   | 10,000-50,000   | 3000                  | ~8-15 minutes         |
   | 50,000-100,000+ | 2000                  | ~5-12 minutes         |

### Considerations

**Lower Batch Size (e.g., 2000)**
- ✅ Reduces memory usage
- ✅ Lower risk of timeouts or throttling
- ✅ More predictable run times
- ❌ Requires more flow runs to complete
- ❌ Takes longer to process all flows

**Higher Batch Size (e.g., 8000)**
- ✅ Fewer flow runs needed
- ✅ Faster overall completion
- ❌ Higher memory usage
- ❌ Increased risk of approaching limits
- ❌ Longer individual run times

**Recommendation**: Start with the default value (5000) and adjust based on your environment's performance and characteristics.

## Monitoring

### How to Check Progress

1. **View Flow Run History**
   - Open **Admin | Sync Template v3 (Flow Action Details)** in Power Automate
   - Check the run history to see how many flows were processed in each run

2. **Query Remaining Flows**
   - Use the following Power Apps formula or Dataverse query to check how many flows still need processing:
   ```
   Filter(admin_flows, admin_inventorymyflowactiondetails = true)
   ```

3. **Expected Behavior**
   - Multiple successful runs processing batches of flows
   - Each run processes up to the configured batch size
   - Runs continue until all flagged flows are processed

### Troubleshooting

#### Flow still fails with memory error

**Possible causes**:
- Batch size is still too large for your environment
- Flows have unusually large action details

**Solution**:
- Reduce the `FlowActionDetailsBatchSize` to 2000 or 1000
- Monitor subsequent runs

#### Flow seems stuck or not progressing

**Possible causes**:
- Flow is not being triggered
- Upstream flows are not setting the `admin_inventorymyflowactiondetails` flag

**Solution**:
- Check that the parent sync flows are running successfully
- Verify that flows have the `admin_inventorymyflowactiondetails` flag set to `true`
- Manually trigger the flow if needed

#### Processing is too slow

**Possible causes**:
- Batch size is too small
- Throttling or delays are occurring

**Solution**:
- Increase the `FlowActionDetailsBatchSize` to 8000 (not exceeding 10000)
- Check for Dataverse throttling in flow run history
- Consider the `DelayObjectInventory` environment variable if throttling is severe

## Technical Details

### Modified Actions

1. **Flows_to_iterate** (`Get_flows_to_update` scope)
   - **Location**: `Update_flow_action_details > Get_flows_to_update > Flows_to_iterate`
   - **Change**: Added `$top` parameter referencing the batch size environment variable
   - **Impact**: Limits the number of flows retrieved in each query

2. **Flows_to_iterate_with_specialty_flags** (`Clear_Specialty_Flags` scope)
   - **Location**: `Update_flow_action_details > GetCurrentActual > Clear_Specialty_Flags > Flows_to_iterate_with_specialty_flags`
   - **Change**: Added `$top` parameter referencing the batch size environment variable
   - **Impact**: Limits the number of flows with specialty flags processed

### Query Filter

The flow uses this filter to select flows for processing:
```
admin_flowdeleted ne true 
and admin_inventorymyflowactiondetails eq true 
and _admin_flowenvironment_value eq [current_environment_id]
and admin_flowispublished ne false
```

With the batch size limit, only the first N flows (ordered by `admin_flowmodifiedon`) are retrieved, where N = `FlowActionDetailsBatchSize`.

## Migration Guide

### Upgrading from Previous Versions

1. **Import the updated solution**
   - The new environment variable will be automatically created with the default value (5000)
   - Existing flows will use the new batch processing logic

2. **No manual configuration required**
   - The default batch size (5000) works for most environments
   - Only customize if you experience issues or have specific requirements

3. **Verify the change**
   - After upgrade, check the flow run history
   - Confirm that flows are processing in batches
   - Each run should show processing of approximately `FlowActionDetailsBatchSize` flows

### For Environments with 90,000+ Flows

If you're upgrading specifically to address the 225MB limit issue:

1. **Set batch size to 3000 initially**
   - This provides a good balance between safety and performance
   - Update the `FlowActionDetailsBatchSize` environment variable to `3000`

2. **Trigger the sync process**
   - Ensure the parent inventory flows run to flag flows for processing
   - The Flow Action Details sync will automatically run in batches

3. **Monitor progress**
   - Check flow run history regularly
   - Expect multiple successful runs, each processing ~3000 flows
   - Total time to complete all 90,000 flows: approximately 30 runs

4. **Adjust if needed**
   - If runs are successful and fast, consider increasing to 5000
   - If runs still fail, decrease to 2000

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.0.0   | January 2026 | Implemented batch processing with configurable batch size |

## Support

For issues or questions:
- Search existing issues: [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)
- Create a new issue: Use the issue template and provide:
  - Number of flows in your environment
  - Current batch size setting
  - Flow run history screenshots
  - Error messages (if any)

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Power Automate Limits and Configuration](https://learn.microsoft.com/power-automate/limits-and-config)
- [Dataverse API Limits](https://learn.microsoft.com/power-apps/developer/data-platform/api-limits)
