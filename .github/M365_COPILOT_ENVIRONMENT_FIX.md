# Microsoft 365 Copilot Environment Handling

## Issue Description

The Admin | Sync Template v4 (Custom Connectors) flow was failing with the following error when processing Microsoft 365 Copilot environments:

```
The user with object id 'xxx' in tenant 'xxx' does not have access to permission 'ManageAnyCustomApi' 
in environment 'xxx'. Error Code: 'PermissionBlockedByOfficeAI'
```

## Root Cause

Microsoft 365 Copilot environments are special-purpose environments created by Microsoft specifically for M365 Copilot features. These environments have restricted permissions by design, and the `Get-AdminConnectors` API operation requires the `ManageAnyCustomApi` permission which is blocked in these environments with the error code `PermissionBlockedByOfficeAI`.

## Solution

The fix adds error handling logic to both the Custom Connector sync flow and its cleanup helper flow to gracefully handle this scenario:

1. **Detection**: When the `Get_Custom_Connectors_as_Admin` action fails, the error handling checks if the error message contains "PermissionBlockedByOfficeAI"
2. **Graceful Exit**: If this specific error is detected, the flow terminates with a **Succeeded** status instead of **Failed**
3. **Normal Error Handling**: For any other type of error, the flow continues with the standard error handling logic

## Affected Flows

- **Admin | Sync Template v4 (Custom Connectors)** - `AdminSyncTemplatev4CustomConnectors-AE1EF367-1B3E-EB11-A813-000D3A8F4AD6.json`
- **CLEANUP HELPER - Check Deleted v4 (Custom Connectors)** - `CLEANUPHELPER-CheckDeletedv4CustomConnectors-2B878801-21AC-EE11-BE37-000D3A3411D9.json`

## Expected Behavior

After applying this fix:
- The sync flows will successfully complete when encountering Microsoft 365 Copilot environments
- These environments will be skipped during custom connector inventory
- No error records will be created for PermissionBlockedByOfficeAI scenarios
- The flow will continue processing other environments normally

## Additional Notes

Microsoft 365 Copilot environments are identified by their environment settings showing: "This environment was, by design, created by Microsoft for M365 Copilot features"

These environments do not need custom connector inventory as they are managed entirely by Microsoft for specific Copilot functionality.
