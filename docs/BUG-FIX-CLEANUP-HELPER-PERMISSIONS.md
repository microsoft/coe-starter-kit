# Bug Fix: CLEANUP HELPER - Power Apps User Shared With - Run-Only Permissions

## Issue Summary

The flow **CLEANUP HELPER - Power Apps User Shared With** had incorrect run-only permissions that caused the parent flow **CLEANUP - Admin | Sync Template v3 (App Shared With)** to fail.

## Root Cause

Two connection references in the CLEANUP HELPER flow were incorrectly configured with `runtimeSource: "invoker"` (provided by run-only user) instead of `runtimeSource: "embedded"` (use this connection):

1. **Office 365 Groups** (`shared_office365groups_1`)
2. **HTTP with Microsoft Entra ID (Preauthorized)** (`shared_webcontents_1`)

When set to "invoker", the flow expects the calling flow to provide these connections, which it cannot do properly. This caused runtime failures.

## Solution

Changed the `runtimeSource` property from `"invoker"` to `"embedded"` for both connection references in the file:
- `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/CLEANUPHELPER-PowerAppsUserSharedWith-1F3F24FF-C717-EC11-B6E6-000D3A1C26F9.json`

### Technical Details

**Before (incorrect):**
```json
"shared_office365groups_1": {
  "runtimeSource": "invoker",
  "connection": {
    "connectionReferenceLogicalName": "admin_CoECoreO365Groups"
  },
  "api": {
    "name": "shared_office365groups"
  }
}
```

**After (correct):**
```json
"shared_office365groups_1": {
  "runtimeSource": "embedded",
  "connection": {
    "connectionReferenceLogicalName": "admin_CoECoreO365Groups"
  },
  "api": {
    "name": "shared_office365groups"
  }
}
```

The same change was applied to `shared_webcontents_1`.

## Impact

- ✅ **CLEANUP HELPER - Power Apps User Shared With** flow will now run successfully using its configured connections
- ✅ **CLEANUP - Admin | Sync Template v3 (App Shared With)** flow will no longer fail when calling the helper flow
- ✅ App sharing data will be properly synchronized in the CoE inventory
- ✅ No user action required after upgrading to this version

## User Action Required

After upgrading to this version:
1. Re-import the CoE Core Components solution
2. Ensure the Office 365 Groups and HTTP with Microsoft Entra ID connections are configured in the CoE environment
3. Turn on the affected flows if they were disabled

## Related Files

- `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/CLEANUPHELPER-PowerAppsUserSharedWith-1F3F24FF-C717-EC11-B6E6-000D3A1C26F9.json`
- Connection references:
  - `admin_CoECoreO365Groups`
  - `admin_CoECoreHTTPWithAzureAD`

## Version

Fixed in: CoE Core Components v4.50.8+
