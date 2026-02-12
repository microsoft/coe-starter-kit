# Troubleshooting: Flow Action Details Array Limit

## Issue

The **Admin | Sync Template v3 (Flow action Details)** flow fails with errors related to the `ActualFlowActionDetails` array variable exceeding its maximum length. This typically occurs in environments with many flows, each containing numerous actions.

### Common Error Messages

- "Get flow as Admin" action failing frequently
- Array variable exceeds maximum size
- Expression evaluation errors when processing large arrays

## Root Cause

The flow collects action details from all flows in an environment into a single array variable (`ActualFlowActionDetails`). When an environment has:
- Many flows (e.g., 100+)
- Each flow with many actions (e.g., 50+ actions/triggers per flow)

The total number of items in the array can exceed Power Automate's limits for array operations, particularly when using operations like `union()`, `contains()`, or `parseJson()` on large arrays.

## Solution

Starting in version **4.50.7+**, the flow has been optimized to process flows in batches:

1. **Batch Processing**: The flow now processes a maximum of 100 flows per run
2. **Reduced Pagination**: The pagination limit has been reduced from 100,000 to 5,000 items
3. **Automatic Continuation**: The flow automatically processes remaining flows in subsequent runs using the `admin_inventorymyflowactiondetails` flag

### How It Works

1. The flow queries for flows where `admin_inventorymyflowactiondetails eq true`
2. It processes the first 100 flows (ordered by `admin_flowmodifiedon`)
3. After successful processing, the flag is reset for those flows
4. On the next run, it picks up the next batch of flows
5. This continues until all flows have been processed

## Manual Workaround (For Older Versions)

If you're using a version before 4.50.7, you can manually apply the fix:

1. Export the **Admin | Sync Template v3 (Flow action Details)** flow
2. Edit the flow JSON
3. Locate the `Flows_to_iterate` action
4. Add a `$top` parameter with value `100`:
   ```json
   "parameters": {
     "entityName": "admin_flows",
     "$select": "admin_flowid, _admin_flowenvironment_value, ...",
     "$filter": "admin_flowdeleted ne true and admin_inventorymyflowactiondetails eq true ...",
     "$orderby": "admin_flowmodifiedon",
     "$top": 100,
     "$expand": "admin_FlowEnvironment($select=admin_environmentname)"
   }
   ```
5. Reduce the `minimumItemCount` from `100000` to `5000`:
   ```json
   "runtimeConfiguration": {
     "paginationPolicy": {
       "minimumItemCount": 5000
     }
   }
   ```
6. Save and reimport the flow

## Best Practices

- **Regular Runs**: Allow the flow to run regularly to process flows incrementally
- **Monitoring**: Monitor the flow run history to ensure all flows are eventually processed
- **Environment Size**: Consider splitting very large environments if they consistently have issues
- **Cleanup**: Regularly clean up deleted or inactive flows to reduce inventory size

## Related Information

- **Environment Variable**: `admin_inventorymyflowactiondetails` - Controls which flows need action detail inventory
- **Flow Trigger**: The flow is triggered when an environment record is added or modified
- **Processing Time**: Larger environments may require multiple flow runs to complete full inventory

## When to Contact Support

If you experience this issue after upgrading to version 4.50.7+, or if the flow continues to fail even with batch processing:

1. Check the flow run history for specific error messages
2. Verify the flow is using the latest version with the batch processing fix
3. Check if any flows in your environment have an unusually high number of actions (500+)
4. Report the issue on [GitHub](https://github.com/microsoft/coe-starter-kit/issues) with:
   - CoE Starter Kit version
   - Number of flows in the affected environment
   - Average number of actions per flow (if known)
   - Specific error messages from flow run history

## See Also

- [CoE Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Power Automate Limits and Configuration](https://learn.microsoft.com/power-automate/limits-and-config)
- [Troubleshooting Upgrades](../TROUBLESHOOTING-UPGRADES.md)
