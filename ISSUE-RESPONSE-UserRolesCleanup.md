# Issue Response: Power Platform User Roles and Orphaned Users

## Summary
Thank you for this excellent question! You've identified an important behavior in the CoE Starter Kit regarding how orphaned users are handled in the Power Platform User Role table.

## Direct Answer to Your Question

**Yes, the CoE Starter Kit does have cleanup flows for orphaned users, BUT they do NOT delete User Role records automatically.** Instead, they mark users as orphaned, which you can then filter in your queries.

### Key Cleanup Flows

The following flows are relevant to your scenario:

1. **CLEANUP - Admin | Sync Template v3 (Orphaned Users)** 
   - Checks each user in the Power Platform Users table against Azure AD
   - Marks users as orphaned when not found in Azure AD (`admin_userisorphaned = true`)
   - Sets `admin_userenabled = false` for disabled users

2. **CLEANUP - Admin | Sync Template v3 (App Shared With)**
   - Syncs the current sharing state of apps
   - Creates/updates User Role records but does NOT delete old ones

3. **CLEANUP - Admin | Sync Template v3 (Flow Shared With)**
   - Syncs the current sharing state of flows
   - Creates/updates User Role records but does NOT delete old ones

## The Root Cause of Your False Positives

The issue you're experiencing occurs because:
- User Role records for orphaned users remain in the table
- When you query User Roles directly without filtering orphaned users, you're counting users who may no longer exist
- This leads to false positives in your sharing limit violations

## Solution for Your Custom Monitoring

To fix your false positives, you need to **filter out orphaned users** when querying the User Role table:

### Query Pattern
```powerFx
Filter(
    'Power Platform User Roles',
    'App' = ThisItem.App &&
    Not(IsBlank('User')) &&
    'User'.'Is Orphaned User' <> true
)
```

### For Counting Non-Orphaned Shared Users
```powerFx
CountIf(
    'Power Platform User Roles',
    'App'.'App' = ThisItem.'Display Name' && 
    'Role Name' <> "Owner" &&
    'User'.'Is Orphaned User' <> true
)
```

## Recommended Actions

1. **Ensure Cleanup Flows are Running**: Verify that the "CLEANUP - Admin | Sync Template v3 (Orphaned Users)" flow is scheduled to run at least weekly

2. **Update Your Custom Queries**: Modify your queries to join with the Power Platform Users table and filter where `admin_userisorphaned = false`

3. **Test Your Logic**: After implementing the filter, verify that orphaned users are no longer causing false positives

## Why User Role Records Aren't Deleted

The CoE Starter Kit intentionally preserves User Role records for orphaned users to:
- Maintain audit trails of historical access
- Support compliance and security investigations
- Allow for user record restoration if accounts are re-enabled

## Optional: Custom Cleanup Flow

If you prefer to automatically delete User Role records for orphaned users after a retention period, you can create a custom flow that:
1. Queries User Role records where the linked user is orphaned
2. Filters records older than your retention period (e.g., 90 days)
3. Deletes the records
4. Logs deletions for audit purposes

## Documentation

I've created comprehensive documentation about this topic: [FAQ-UserRolesCleanup.md](./FAQ-UserRolesCleanup.md)

This FAQ includes:
- Detailed explanation of each cleanup flow
- Query patterns for filtering orphaned users
- Best practices for custom solutions
- Recommendations for handling your specific scenario

## Closing Thoughts

Your approach of querying the User Roles table directly is correct, but you just need to add the orphaned user filter to eliminate false positives. The CoE Starter Kit provides the tools (orphaned user marking) you need - you just need to leverage them in your custom solution.

As you noted, flow creators can't be removed from the flows themselves, and the same is true in the User Role table. However, by filtering on the orphaned flag, you'll get an accurate count of active users with access to your apps and flows.

Please let us know if you need help implementing the query filters or if you have any other questions!

---

## References
- [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Core Components Overview](https://learn.microsoft.com/en-us/power-platform/guidance/coe/core-components)
- FAQ: [FAQ-UserRolesCleanup.md](./FAQ-UserRolesCleanup.md)
