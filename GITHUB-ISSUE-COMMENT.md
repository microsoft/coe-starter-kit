# Response to Issue: Are Power Platform User Roles Ever Removed?

## Short Answer

**Yes!** The CoE Starter Kit DOES clean up and delete User Role records through its cleanup flows, but this happens in a **two-stage process** with a time lag.

## How It Works

### Stage 1: Mark Orphaned Users
The **CLEANUP - Admin | Sync Template v3 (Orphaned Users)** flow:
- Checks each user against Azure AD
- Marks deleted/disabled users as `admin_userisorphaned = true`
- Runs: Weekly (recommended)

### Stage 2: Delete User Role Records
The **CLEANUP - Admin | Sync Template v3 (App/Flow Shared With)** flows and their helper flows:
- Compare actual Power Platform sharing with CoE inventory
- **Delete User Role records** when sharing is removed
- Delete records where user lookup is null
- Introduced in: Version 3.13 (Apps), Version 4.29.5 (Flows)
- Runs: Monthly (recommended)

## Why You're Seeing False Positives

Your issue occurs because:
1. **Time lag**: User Role records remain until the App/Flow Shared With cleanup runs (could be weeks/months)
2. **Still in sharing list**: Orphaned users may still be in Power Platform's sharing list even though their accounts are disabled
3. **List Owners as Admin returns all users**: Including orphaned ones - this is Power Platform behavior

## The Solution for Your Custom Monitoring

**Filter orphaned users in your queries:**

```powerFx
CountIf(
    'Power Platform User Roles',
    'App'.'App' = ThisItem.'Display Name' && 
    'Role Name' <> "Owner" &&
    Not(IsBlank('User')) &&
    'User'.'Is Orphaned User' <> true
)
```

This gives you **accurate counts immediately** without waiting for cleanup flows to delete records.

## Action Items

1. ✅ **Verify cleanup flows are scheduled**:
   - Orphaned Users: Weekly
   - App/Flow Shared With: Monthly

2. ✅ **Check your CoE version**: Make sure you have at least Version 3.13 (for app cleanup) or 4.29.5 (for flow cleanup)

3. ✅ **Update your custom queries**: Add the filter for `'User'.'Is Orphaned User' <> true`

4. ✅ **Test**: Verify orphaned users no longer cause false positives

## Why Filter Instead of Relying on Deletion

While the CoE kit DOES delete User Role records eventually:
- Deletion only happens when cleanup flows run (not real-time)
- Users can be orphaned but still in Power Platform sharing
- Your monitoring needs accurate counts NOW, not after cleanup completes

Filtering orphaned users gives you the best of both worlds: accurate real-time counts AND proper cleanup over time.

## Documentation

I've created comprehensive documentation for this topic:
- [FAQ: User Roles and Orphaned Users Cleanup](./FAQ-UserRolesCleanup.md)
- [Detailed Issue Response](./ISSUE-RESPONSE-UserRolesCleanup.md)

## References
- [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/core-components)

---

Hope this helps! Let us know if you need any clarification or help implementing the filters. 👍
