# FAQ: Power Platform User Roles and Orphaned Users Cleanup

## Question: Are Power Platform User Roles Ever Removed?

### Overview
The Power Platform User Role table (`admin_PowerPlatformUserRole`) in the CoE Starter Kit tracks sharing permissions for apps and flows across your tenant. This table is populated when inventory sync flows run and identify who has access to apps and flows.

### Cleanup Flows
Yes, the CoE Starter Kit **does include cleanup flows** that handle orphaned users and outdated sharing information in the User Role table. The following flows are designed to maintain data hygiene:

#### 1. CLEANUP - Admin | Sync Template v3 (Orphaned Users)
**Flow Name:** `CLEANUP-AdminSyncTemplatev3OrphanedUsers`  
**Purpose:** This flow checks the status of all entries in the Power Platform Users table and updates them based on whether they are deleted or disabled.  
**Introduced:** Version 4.24.2  
**Description:** This flow identifies and marks users who are no longer active in Azure AD (deleted or disabled accounts).

#### 2. CLEANUP - Admin | Sync Template v3 (App Shared With)
**Flow Name:** `CLEANUP-AdminSyncTemplatev3AppSharedWith`  
**Purpose:** This is a long-running flow that walks the tenant and finds the current sharing state of apps.  
**Introduced:** Version 1.70.6  
**Description:** This flow syncs the actual sharing permissions for apps and can identify sharing entries that are no longer valid.

#### 3. CLEANUP - Admin | Sync Template v3 (Flow Shared With)
**Flow Name:** `CLEANUP-AdminSyncTemplatev3FlowSharedWith`  
**Purpose:** This is a long-running flow that walks the tenant and finds the current sharing state of flows.  
**Introduced:** Version 4.32.3  
**Description:** Similar to App Shared With, this flow syncs the actual sharing permissions for flows and can identify sharing entries that are no longer valid.

#### 4. CLEANUP - Admin | Sync Template v3 (Orphaned Makers)
**Flow Name:** `CLEANUP-AdminSyncTemplatev3OrphanedMakers`  
**Purpose:** This flow identifies and handles makers who are no longer active.  
**Description:** Focuses on app/flow creators who have become orphaned.

### How User Role Cleanup Works

The cleanup process works in stages:

1. **User Status Check**: The Orphaned Users flow checks each user in the Power Platform Users table against Azure AD to determine if they are deleted or disabled. When a user is not found in Azure AD, the flow:
   - Updates the user record with `admin_userisorphaned = true`
   - Sets `admin_userenabled = false` for disabled users

2. **Sharing State Sync**: The App Shared With and Flow Shared With cleanup flows walk through each environment and app/flow to verify current sharing permissions. These flows:
   - Create new User Role records for newly discovered sharing permissions
   - Update existing User Role records with current information
   - **Note**: These flows do NOT automatically delete outdated User Role records

3. **User Role Table Behavior**: 
   - User Role records for orphaned users remain in the table
   - However, they are linked to user records that are marked as orphaned (`admin_userisorphaned = true`)
   - This allows for historical tracking and audit purposes

### Important Notes About Flow Creators and User Role Cleanup

As you correctly noted in your question:
- **Flow and app creators cannot be removed** from the objects themselves (they remain as the owner in Power Platform)
- User Role table entries for orphaned users are **NOT automatically deleted**
- Instead, the associated user record is marked as orphaned (`admin_userisorphaned = true`)
- **The cleanup flows primarily MARK users as orphaned rather than DELETE user role entries**

This design choice allows organizations to:
- Maintain audit trails of who had access historically
- Investigate sharing patterns even after users leave
- Re-activate user records if accounts are restored

### Frequency and Scheduling

These cleanup flows are typically:
- **Manually triggered** by default
- Recommended to be scheduled to run **weekly or monthly** depending on your tenant size and change frequency
- Long-running flows that may take considerable time in large tenants

### Best Practice for Your Custom Solution

Given your scenario where you're monitoring sharing in a default environment that cannot be managed, here are recommendations:

1. **Filter Orphaned Users**: When querying the Power Platform User Role table, you MUST join with the Power Platform Users table and filter out orphaned users:
   - Join on `admin_User` (lookup field in User Role table)
   - Filter where `admin_userisorphaned = false` (or `admin_userisorphaned <> true`)
   - Optionally also check `admin_userenabled = true` for active users only

2. **Run Cleanup Flows Regularly**: Ensure these cleanup flows are scheduled to run:
   - **CLEANUP - Admin | Sync Template v3 (Orphaned Users)**: Run weekly to mark orphaned users
   - **CLEANUP - Admin | Sync Template v3 (App Shared With)**: Run monthly or as needed to sync app sharing
   - **CLEANUP - Admin | Sync Template v3 (Flow Shared With)**: Run monthly or as needed to sync flow sharing

3. **Query Pattern for Accurate Counts**: Use a filter that excludes orphaned users:
   ```
   Filter(
       'Power Platform User Roles',
       'User'.'Is Orphaned User' = false && 
       'User'.'User Enabled' = true &&
       'App' = ThisItem.App
   )
   ```

4. **Exclude Creators When Counting Sharing Violations**: 
   ```
   CountIf(
       'Power Platform User Roles',
       'App'.'App' = ThisItem.'Display Name' && 
       'Role Name' <> "Owner" &&
       'User'.'Is Orphaned User' <> true
   )
   ```

5. **Handle Cases Where User Lookup is Null**: In some edge cases, the user lookup might be null:
   ```
   Filter(
       'Power Platform User Roles',
       'App' = ThisItem.App &&
       Not(IsBlank('User')) &&
       'User'.'Is Orphaned User' <> true
   )
   ```

6. **Consider Manual Cleanup**: If your CoE instance has accumulated many historical User Role records, you may want to:
   - Create a custom flow to delete User Role records where the linked user is orphaned
   - Archive old User Role records to a separate table before deletion
   - Coordinate with your CoE admin team before performing bulk deletions

### Related Documentation

For more information about the CoE Starter Kit inventory and cleanup processes, refer to:
- [Official CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Core Components Overview](https://learn.microsoft.com/en-us/power-platform/guidance/coe/core-components)
- [Setup and Configuration](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)

### Current Behavior and Workaround

**Important Clarification**: The CoE Starter Kit cleanup flows **DO NOT automatically delete** User Role records for orphaned users. Instead:

1. The **CLEANUP - Admin | Sync Template v3 (Orphaned Users)** flow marks user records as orphaned
2. User Role records remain in the table but are linked to users marked as orphaned
3. This is by design for audit trail and historical tracking purposes

**To solve your false positive issue**, you MUST:
1. **Filter orphaned users in your queries** - Join User Role table with Users table and exclude where `admin_userisorphaned = true`
2. **Run cleanup flows regularly** - Ensure the Orphaned Users cleanup flow runs weekly to keep status current
3. **Consider implementing custom cleanup** - If needed, create a custom flow to delete User Role records for orphaned users after a retention period

### Potential Enhancement Request

If automatic deletion of User Role records for orphaned users would benefit your use case, consider:
1. Opening a feature request issue in this repository
2. Creating a custom cleanup flow that:
   - Identifies User Role records linked to orphaned users
   - Deletes records after a defined retention period (e.g., 90 days)
   - Logs deletions for audit purposes

### Summary

**Orphaned users are MARKED but not automatically removed** from the User Role table by the CoE Starter Kit. To get accurate sharing counts:
1. Ensure the cleanup flows are scheduled and running regularly
2. **In your custom queries, you MUST filter out orphaned/disabled users** when counting sharing violations
3. Join the User Role table with the Users table to check `admin_userisorphaned` field

This will give you accurate counts and prevent false positives from orphaned accounts in your sharing limit monitoring solution.
