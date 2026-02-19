# Error 0x80040217: Entity 'admin_PowerPlatformUser' Does Not Exist

## Issue Description

When running the **CLEANUP HELPER - Cloud Flow User Shared With** or **CLEANUP HELPER - PowerApps User Shared With** flows, you may encounter the following error:

```json
{
  "error": {
    "code": "0x80040217",
    "message": "Entity 'admin_PowerPlatformUser' With Id = [GUID] Does Not Exist",
    "@Microsoft.PowerApps.CDS.ErrorDetails.ApiExceptionSourceKey": "Plugin/Microsoft.Crm.ObjectModel.CustomBusinessEntityService"
  }
}
```

## Root Cause

This error occurs when the flows attempt to create a new `admin_PowerPlatformUserRole` record with a lookup/binding to an `admin_PowerPlatformUser` record that doesn't exist in the Dataverse table.

### Why does this happen?

1. **Missing User Records**: The `admin_PowerPlatformUser` table stores information about users, groups, and service principals that have access to Power Platform resources. If a user/group/service principal was previously deleted from this table (perhaps through cleanup processes, data loss, or manual deletion), but they still have roles assigned to resources, the flows will fail when trying to create the role binding.

2. **Stale References**: When the flow detects a new role assignment (e.g., a flow is shared with a user), it tries to:
   - Check if the user exists in `admin_PowerPlatformUsers`
   - If they do, update their record
   - Create the `admin_PowerPlatformUserRole` record with a binding to that user

3. **UpdateRecord Limitation**: The original implementation used the `UpdateRecord` operation to "upsert" users. However, `UpdateRecord` requires that the record already exists. If the record was deleted or never created, `UpdateRecord` fails silently (or with a different error), and the user record is not created. When the flow then tries to create the role with a binding to that non-existent user, it fails with error 0x80040217.

## Resolution

This issue has been fixed in the latest version of the CoE Starter Kit (version > 4.50.7). The fix modifies the "Ensure_all_Users_exist" logic in both flows to:

1. **Try to Get the User**: Before updating, the flow now attempts to retrieve the user record using the `GetItem` operation
2. **Update if Exists**: If the record exists, the flow updates it using `UpdateRecord`
3. **Create if Missing**: If the record doesn't exist (GetItem fails), the flow creates it using `CreateRecord`

### Technical Details

The fix adds the following pattern for each user type (User, Group, ServicePrincipal):

- **Try_Get_User_as_Orphan**: Attempts to retrieve the user record
- **Upsert_User_as_Orphan**: Updates the record (runs only if Try_Get succeeds)
- **Create_User_as_Orphan**: Creates the record (runs only if Try_Get fails)

This ensures that user records always exist before attempting to create role bindings, preventing the 0x80040217 error.

## Upgrading to the Fix

If you're experiencing this error:

1. **Upgrade to the latest version** of the CoE Starter Kit Core Components solution
2. **Follow the standard upgrade process** as documented in the [upgrade guidance](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
3. **No configuration changes are required** - the fix is automatic

## Workaround (for older versions)

If you cannot upgrade immediately, you can work around this issue by:

1. **Running the Sync flows** to ensure all users are properly populated in the `admin_PowerPlatformUsers` table
2. **Manually creating missing user records** in the `admin_PowerPlatformUsers` table for any users that are causing the error
3. **Running the cleanup flows again** after ensuring all user records exist

However, upgrading to the fixed version is strongly recommended for a permanent solution.

## Related Flows

This fix applies to both:
- **CLEANUP HELPER - Cloud Flow User Shared With** (for Cloud Flows)
- **CLEANUP HELPER - PowerApps User Shared With** (for Canvas Apps and Model-Driven Apps)

## See Also

- [CoE Starter Kit Upgrade Guidance](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [Troubleshooting Guide](../TROUBLESHOOTING-UPGRADES.md)
- [Power Platform Dataverse Error Codes](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/error)
