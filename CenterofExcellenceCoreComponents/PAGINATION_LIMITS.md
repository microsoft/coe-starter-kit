# Power Automate Pagination Limits in CoE Starter Kit Flows

## Overview

Power Automate has a **hard limit of 1,000 pages** for pagination operations. This limit applies to all flows and cannot be increased. When a flow attempts to paginate beyond 1,000 pages, it will fail with an error like:

```
The action 'Get_Connections_as_Admin' has an aggregated page count of more than '1000'. 
This exceeded the maximum page count '1000' allowed.
```

## Affected Flows

This limitation can affect any CoE Starter Kit flow that retrieves large datasets, particularly:

- **Admin | Sync Template v4 (Connection Identities)** - Fixed in v4.50.4+
- Other inventory flows processing environments with extremely high volumes

## Root Cause

The pagination limit is calculated as:
```
Maximum Records = $top × 1000 pages
```

For example:
- `$top: 1000` → Maximum 1,000,000 records (1000 × 1000 pages)
- `$top: 250` → Maximum 250,000 records (250 × 1000 pages)

When using `paginationPolicy.minimumItemCount`, Power Automate will continue paginating until:
1. The minimum item count is reached, OR
2. The 1,000-page limit is hit (whichever comes first)

## Solution Applied

### Connection Identities Flow Fix (v4.50.4+)

**Before:**
```json
{
  "parameters": {
    "$top": 1000
  },
  "runtimeConfiguration": {
    "paginationPolicy": {
      "minimumItemCount": 100000
    }
  }
}
```

**After:**
```json
{
  "parameters": {
    "$top": 250
  }
}
```

**Changes:**
1. Removed `paginationPolicy.minimumItemCount: 100000` to prevent aggressive pagination
2. Reduced `$top` from 1000 to 250 to align with Apps flow pattern
3. Flow now processes up to 250,000 connections per run (250 × 1000 pages max)

## Recommendations for Environments with High Connection Counts

If your environment has more connections than can be processed in a single run:

1. **Run the flow multiple times**: Each run will process up to 250,000 connections
2. **Schedule regular runs**: The flow will incrementally catch up with all connections
3. **Clean up unused connections**: Use the HELPER-GetConnectionstoClean flow to identify and remove unused connections
4. **Monitor flow runs**: Check the flow run history to ensure successful completion

## Related Documentation

- [Power Automate Pagination Limits](https://learn.microsoft.com/en-us/power-automate/limits-and-config#pagination-limits)
- [CoE Starter Kit - Inventory](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Manage Connectors](https://learn.microsoft.com/en-us/power-platform/guidance/coe/core-components#connection-reference-identities)

## Troubleshooting

### Error: "Exceeded the maximum page count '1000' allowed"

**Cause**: The environment has too many connections to process in a single flow run.

**Solution**: 
1. Upgrade to CoE Starter Kit v4.50.4 or later (includes the pagination fix)
2. Run the flow multiple times to incrementally process all connections
3. Consider cleaning up unused connections

### Flow processes fewer connections than expected

**Behavior**: This is expected if you have > 250,000 connections.

**Solution**: 
- The flow will process up to 250,000 connections per run
- Schedule the flow to run multiple times to catch up
- Each subsequent run will process the next batch

## Technical Details

### Default Pagination Behavior

When `paginationPolicy` is not specified:
- Power Automate automatically paginates using the `@odata.nextLink` from API responses
- Pagination continues until no more pages are available OR the 1,000-page limit is reached
- This is the recommended approach for most scenarios

### When to Use paginationPolicy

The `paginationPolicy.minimumItemCount` should only be used when:
- You need to ensure a specific minimum number of items is retrieved
- The total dataset is known to be well below 1,000 pages
- You are willing to accept flow failure if the limit is exceeded

For most inventory scenarios in large tenants, **removing paginationPolicy** is the better approach.

## Version History

- **v4.50.4**: Fixed Connection Identities pagination limit issue
- **v4.50.3**: Issue identified with environments having > 1,000,000 connections

## See Also

- [GitHub Issue: Connection Identities Pagination](https://github.com/microsoft/coe-starter-kit/issues/)
- [CoE Starter Kit Release Notes](https://github.com/microsoft/coe-starter-kit/releases)
