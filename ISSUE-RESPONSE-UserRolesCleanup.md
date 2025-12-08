# Issue Response: Power Platform User Roles and Orphaned Users

## Summary
Thank you for this excellent question! You've identified an important behavior in the CoE Starter Kit regarding how orphaned users are handled in the Power Platform User Role table.

## Direct Answer to Your Question

**Yes, the CoE Starter Kit DOES delete User Role records through its cleanup flows**, but this happens in a two-stage process:
1. First, users are marked as orphaned in the Users table
2. Then, the App/Flow Shared With cleanup helper flows delete User Role records when sharing is removed

However, there's a **time lag** between these stages, which is likely causing your false positives.

### Key Cleanup Flows

The following flows work together to clean up User Role records:

1. **CLEANUP - Admin | Sync Template v3 (Orphaned Users)** 
   - Checks each user in the Power Platform Users table against Azure AD
   - Marks users as orphaned when not found in Azure AD (`admin_userisorphaned = true`)
   - Sets `admin_userenabled = false` for disabled users

2. **CLEANUP - Admin | Sync Template v3 (App Shared With)** + **CLEANUPHELPER - Power Apps User Shared With**
   - Parent flow walks through all environments
   - Helper flow (Version 3.13+) syncs the current sharing state of apps PER environment
   - **DELETES User Role records** when:
     - Sharing is removed from the app in Power Platform
     - Users no longer appear in the actual sharing list
     - User lookup fields are null (bad data cleanup)

3. **CLEANUP - Admin | Sync Template v3 (Flow Shared With)** + **CLEANUPHELPER - Cloud Flow User Shared With**
   - Parent flow walks through all environments
   - Helper flow (Version 4.29.5+) syncs the current sharing state of flows PER environment
   - **DELETES User Role records** when sharing is removed (same logic as apps)

## The Root Cause of Your False Positives

The issue you're experiencing occurs because of the **two-stage cleanup process and timing lag**:

1. **Stage 1 - User Marked as Orphaned**: When a user leaves the organization, the Orphaned Users flow marks them as `admin_userisorphaned = true`
2. **Stage 2 - User Role Deletion**: The App/Flow Shared With cleanup flows will delete the User Role records, but ONLY when they run and compare actual vs. inventoried sharing

**Your false positives happen because:**
- User Role records remain in the table until the App/Flow Shared With cleanup flows run
- The "List Owners as Admin" Power Platform API still returns orphaned users if sharing wasn't explicitly removed
- There's a time lag (potentially weeks/months) between marking users as orphaned and deletion of their User Role records
- Orphaned users can still be "shared with" in Power Platform even though their accounts are disabled

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

1. **Ensure Cleanup Flows are Running Regularly**: 
   - **CLEANUP - Orphaned Users**: Schedule to run weekly
   - **CLEANUP - App Shared With**: Schedule to run monthly (long-running, resource-intensive)
   - **CLEANUP - Flow Shared With**: Schedule to run monthly (long-running, resource-intensive)

2. **Update Your Custom Queries to Filter Orphaned Users**: 
   Modify your queries to join with the Power Platform Users table and exclude orphaned users:
   ```powerFx
   Filter(
       'Power Platform User Roles',
       'App' = ThisItem.App &&
       Not(IsBlank('User')) &&
       'User'.'Is Orphaned User' <> true
   )
   ```

3. **Verify Your CoE Version**: 
   Check that you're running at least:
   - Version 3.13 for App cleanup with deletion
   - Version 4.29.5 for Flow cleanup with deletion

4. **Test Your Logic**: 
   After implementing the filter, verify that orphaned users are no longer causing false positives in your sharing limit violations

## How the Deletion Process Works

The cleanup helper flows use this logic:

1. **Get Current Sharing State**: Call Power Platform admin APIs to get actual sharing for each app/flow
2. **Get Inventoried State**: Query User Role records in CoE for that app/flow
3. **Compare**: Identify roles that exist in the inventory but not in actual sharing
4. **Delete Removed Roles**: Delete User Role records for sharing that no longer exists
5. **Create New Roles**: Add User Role records for newly discovered sharing
6. **Clean Bad Data**: Delete User Role records where user lookup is null

## Important: Verify Your CoE Version

The deletion functionality was introduced in:
- **CLEANUPHELPER - Power Apps User Shared With**: Version 3.13
- **CLEANUPHELPER - Cloud Flow User Shared With**: Version 4.29.5

If you're on an older version, you may not have the automatic deletion capability. Check your CoE Starter Kit version and consider upgrading if needed.

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
