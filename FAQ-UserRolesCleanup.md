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
**Description:** This flow calls the CLEANUP HELPER flows which sync the actual sharing permissions for apps.  
**Child Flow:** `CLEANUPHELPER-PowerAppsUserSharedWith` (Introduced: Version 3.13)

#### 3. CLEANUP - Admin | Sync Template v3 (Flow Shared With)
**Flow Name:** `CLEANUP-AdminSyncTemplatev3FlowSharedWith`  
**Purpose:** This is a long-running flow that walks the tenant and finds the current sharing state of flows.  
**Introduced:** Version 4.32.3  
**Description:** This flow calls the CLEANUP HELPER flows which sync the actual sharing permissions for flows.  
**Child Flow:** `CLEANUPHELPER-CloudFlowUserSharedWith` (Introduced: Version 4.29.5)

#### 4. CLEANUP HELPER - Power Apps User Shared With
**Flow Name:** `CLEANUPHELPER-PowerAppsUserSharedWith`  
**Purpose:** Runs once per environment to check who the app is shared with.  
**Introduced:** Version 3.13  
**Important:** This helper flow **DOES delete User Role records** when sharing is removed.

#### 5. CLEANUP HELPER - Cloud Flow User Shared With
**Flow Name:** `CLEANUPHELPER-CloudFlowUserSharedWith`  
**Purpose:** Runs once per environment to check who the flow is shared with.  
**Introduced:** Version 4.29.5  
**Important:** This helper flow **DOES delete User Role records** when sharing is removed.

#### 6. CLEANUP - Admin | Sync Template v3 (Orphaned Makers)
**Flow Name:** `CLEANUP-AdminSyncTemplatev3OrphanedMakers`  
**Purpose:** This flow identifies and handles makers who are no longer active.  
**Description:** Focuses on app/flow creators who have become orphaned.

### How User Role Cleanup Works

The cleanup process works in stages:

1. **User Status Check**: The Orphaned Users flow checks each user in the Power Platform Users table against Azure AD to determine if they are deleted or disabled. When a user is not found in Azure AD, the flow:
   - Updates the user record with `admin_userisorphaned = true`
   - Sets `admin_userenabled = false` for disabled users

2. **Sharing State Sync and Cleanup**: The App Shared With and Flow Shared With cleanup flows (and their helper flows) walk through each environment and app/flow to verify current sharing permissions. These flows:
   - Create new User Role records for newly discovered sharing permissions
   - Update existing User Role records with current information
   - **Delete User Role records for sharing that has been removed**
   - Delete User Role records where the user lookup is null (bad data cleanup)

3. **Deletion Logic in Helper Flows**:
   The CLEANUP HELPER flows (PowerAppsUserSharedWith and CloudFlowUserSharedWith) perform the actual deletion operations:
   - **Compare actual vs. inventoried roles**: The flow compares the current sharing state from Power Platform with what's in the CoE inventory
   - **Find removed roles**: Identifies User Role records in the inventory that no longer exist in the actual sharing state
   - **Delete outdated records**: Removes User Role records for users who no longer have access
   - **Clean up bad data**: Removes User Role records where the user lookup is null

4. **User Role Table Behavior**: 
   - User Role records are deleted when sharing is removed AND the cleanup helper flows run
   - User Role records for orphaned users will be deleted if those users are no longer in the sharing list
   - Records remain until the cleanup flows compare actual vs. inventoried state
   - This design ensures the inventory reflects the current sharing state once cleanup flows complete

### Important Notes About Flow Creators and User Role Cleanup

As you correctly noted in your question:
- **Flow and app creators cannot be removed** from the objects themselves (they remain as the owner in Power Platform)
- User Role table entries **ARE deleted when sharing is removed**, but ONLY when the cleanup helper flows run
- The cleanup process happens in two stages:
  1. First, users are marked as orphaned in the Users table (`admin_userisorphaned = true`)
  2. Then, when the App/Flow Shared With cleanup flows run, they delete User Role records for users no longer in the actual sharing list

### Why Orphaned User Role Records May Still Exist

User Role records for orphaned users may remain in your table if:
1. The cleanup helper flows haven't run recently
2. The orphaned user is still in the actual sharing list in Power Platform (the account exists but is disabled/orphaned in Azure AD)
3. The cleanup flows encountered errors or haven't completed processing all environments

Once both conditions are met (user is marked orphaned AND removed from actual sharing), the User Role record will be deleted on the next cleanup run.

### Frequency and Scheduling

These cleanup flows are typically:
- **Manually triggered** by default
- Recommended to be scheduled:
  - **Orphaned Users**: Weekly (to mark users who have left the organization)
  - **App/Flow Shared With**: Monthly or as needed (long-running flows that delete obsolete sharing records)
- **Important**: User Role records for orphaned users will only be deleted AFTER both:
  1. The Orphaned Users flow marks them as orphaned
  2. The App/Flow Shared With cleanup flows run and confirm they're not in the actual sharing list

### Parent-Child Flow Relationship

The cleanup process follows this execution pattern:
1. **CLEANUP - Admin | Sync Template v3 (App Shared With)** - Parent flow that iterates through environments
2. **CLEANUPHELPER - Power Apps User Shared With** - Child flow called for each environment that performs the actual deletion
3. Same pattern for flows: **CLEANUP - Admin | Sync Template v3 (Flow Shared With)** → **CLEANUPHELPER - Cloud Flow User Shared With**

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

**Important Clarification**: The CoE Starter Kit cleanup flows **DO delete** User Role records for removed sharing, but this happens in two stages:

1. The **CLEANUP - Admin | Sync Template v3 (Orphaned Users)** flow marks user records as orphaned (`admin_userisorphaned = true`)
2. The **App/Flow Shared With cleanup flows and their helpers** delete User Role records when:
   - Sharing is removed from the app/flow in Power Platform
   - Users are no longer in the actual sharing list (even if they were previously shared)
   - User lookup fields are null (bad data cleanup)

**Why you're seeing orphaned users in your counts**:

Your false positives occur because:
1. Orphaned users may still be in the actual sharing list in Power Platform (account disabled but sharing not removed)
2. The cleanup helper flows haven't run recently to sync and delete removed sharing
3. There's a time lag between when a user is marked orphaned and when the sharing cleanup runs

**To solve your false positive issue**, you should:
1. **Filter orphaned users in your queries** - Join User Role table with Users table and exclude where `admin_userisorphaned = true`
2. **Run cleanup flows regularly** - Ensure both cleanup flow sets run:
   - Orphaned Users flow: Weekly
   - App/Flow Shared With flows: Monthly (these will delete the User Role records)
3. **Wait for cleanup to complete** - After marking users as orphaned, the User Role records will be deleted on the next App/Flow Shared With cleanup run (if those users are also removed from actual sharing)

### Key Insight for Your Scenario

In your specific case with the default environment:
- **The "List Owners as Admin" API returns all sharing, including orphaned users** - this is Power Platform behavior, not CoE behavior
- **The CoE User Role table reflects this same behavior** until cleanup runs
- **The cleanup flows will eventually delete User Role records for removed sharing**, but there's a delay

The most reliable approach for accurate counts is to **filter orphaned users in your custom queries** rather than relying on deletion, because:
1. Deletion only happens when cleanup flows run (not real-time)
2. Users can be orphaned in Azure AD but still listed in Power Platform sharing
3. Your custom solution needs accurate counts immediately, not after cleanup completes

### Summary

**Yes, the CoE Starter Kit DOES delete User Role records for removed sharing**, but this happens through a two-stage process:
1. Users are marked as orphaned by the Orphaned Users cleanup flow
2. User Role records are deleted by the App/Flow Shared With cleanup helper flows when sharing is removed

**However, there's a time lag** between when users become orphaned and when their User Role records are deleted. To get accurate sharing counts in your custom solution:
1. **Ensure cleanup flows are scheduled and running regularly**:
   - Orphaned Users: Weekly
   - App/Flow Shared With: Monthly
2. **In your custom queries, filter out orphaned users** when counting sharing violations:
   ```powerFx
   Filter('Power Platform User Roles', 
          'User'.'Is Orphaned User' <> true)
   ```
3. **Join the User Role table with the Users table** to check `admin_userisorphaned` field

This approach will give you accurate counts immediately and prevent false positives from orphaned accounts, without waiting for cleanup flows to complete their deletion process.
