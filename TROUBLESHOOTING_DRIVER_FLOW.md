# Troubleshooting: Admin Sync Template v4 (Driver) Flow Not Completing

## Issue Description

When setting up the CoE Starter Kit Core Components, the **Admin Sync Template v4 (Driver)** flow may appear to run indefinitely without completing, even though child flows appear to be running successfully. This can prevent the Power BI dashboard from displaying data and cause the overall inventory sync process to appear stuck.

## Root Cause

The Driver flow orchestrates multiple child flows that inventory different types of resources (Apps, Flows, Desktop flows, Model-driven apps, Business Process Flows, PVA bots, etc.). When a child flow encounters an environment with:
- IP restrictions or firewall rules
- Network connectivity issues
- Insufficient permissions
- Blocked API endpoints

The child flow may terminate with a **Failed** status. The Driver flow waits for all child flows to complete, and if any child flow fails, the Driver flow will not complete properly.

## Affected Child Flows

The following child flows had error handling that would cause them to fail (now fixed):
- ✅ **Admin | Sync Template v4 (Desktop flows)** - FIXED
- ✅ **Admin | Sync Template v4 (Business Process Flows)** - FIXED
- ✅ **Admin | Sync Template v4 (Model-driven apps)** - FIXED
- ✅ **Admin | Sync Template v4 (PVA)** - FIXED

Already had correct error handling:
- ✅ **Admin | Sync Template v4 (AI Models)**
- ✅ **Admin | Sync Template v4 (Portals)**
- ✅ **Admin | Sync Template v4 (Solutions)**

## Solution

### Version 4.50.7 and Later

Starting with version 4.50.7, the child flows have been updated to handle access denied errors gracefully. When a child flow encounters an environment it cannot access due to network restrictions or permissions issues, it will:
1. Terminate with **Succeeded** status instead of **Failed**
2. Allow the Driver flow to continue processing other environments
3. Skip the inaccessible environment without blocking the entire sync process

### For Users on Version 4.50.6 or Earlier

If you are experiencing this issue on an earlier version:

1. **Upgrade to version 4.50.7 or later** (Recommended)
   - Download the latest release from [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
   - Follow the [upgrade instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#update-the-coe-starter-kit)

2. **Temporary Workaround** (If upgrade is not immediately possible)
   - Identify environments causing access issues
   - In the CoE environment, navigate to the **admin_environments** table
   - Set the `admin_excusefrominventory` field to **Yes** for problematic environments
   - This will exclude these environments from inventory sync
   - Re-run the Driver flow

## How to Identify the Problem

1. **Check Driver Flow Run History**
   - Open **Admin | Sync Template v4 (Driver)** flow
   - Check the run history
   - If runs show "Running" for an extended period (>8 hours), this indicates an issue

2. **Check Child Flow Run History**
   - Open each child flow (Desktop flows, Business Process Flows, Model-driven apps, PVA)
   - Look for runs with **Failed** status
   - Check the error message - if it mentions "Unauthorized", "IP blocked", or network errors, this confirms the issue

3. **Review Flow Run Details**
   - In the failed child flow run, locate the "List_Envt_*" action (e.g., "List_Envt_Desktop_Flows")
   - The error details will show which environment caused the failure
   - Common errors:
     - `404 Unauthorized`
     - `IP address blocked`
     - `Connection timeout`
     - `Access denied`

## Prevention

To avoid this issue in future deployments:

1. **Network Configuration**
   - Ensure the service account running the flows has network access to all environments
   - Configure firewall rules to allow Power Automate service IPs
   - Review environment-level IP restrictions

2. **Permissions**
   - Ensure the service account has **Power Platform Administrator** or **Global Administrator** role
   - Verify permissions across all environments in your tenant

3. **Environment Management**
   - Use the `admin_excusefrominventory` field to exclude test/development environments
   - Exclude environments in different geographies if cross-region access is restricted
   - Document environments with special network requirements

## Related Resources

- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Power BI Dashboard Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-powerbi)
- [Troubleshooting Inventory Flows](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#troubleshooting)

## Technical Details

### What Changed

In the affected child flows, the error handling for the `List_Envt_*` actions was updated:

**Before:**
```json
"Terminate_if_no_access": {
  "type": "Terminate",
  "inputs": {
    "runStatus": "Failed",
    "runError": {
      "code": "404",
      "message": "Unauthorized"
    }
  }
}
```

**After:**
```json
"Terminate_if_no_access": {
  "type": "Terminate",
  "inputs": {
    "runStatus": "Succeeded"
  }
}
```

This change allows the child flow to complete successfully even when it cannot access a specific environment, preventing the Driver flow from waiting indefinitely.

## FAQs

**Q: Will I lose inventory data for environments that can't be accessed?**  
A: Yes, environments that cannot be accessed due to network restrictions will not have their resources inventoried. However, this is preferable to having the entire sync process blocked.

**Q: How do I know which environments were skipped?**  
A: Check the child flow run history. Any flow that terminated early (within seconds) likely skipped an environment due to access issues.

**Q: Can I still inventory these environments later?**  
A: Yes, once network access is restored, the next scheduled run of the Driver flow will attempt to inventory these environments again.

**Q: Does this affect the Power BI dashboard?**  
A: Environments that cannot be accessed will not appear in the dashboard data. However, successfully inventoried environments will display correctly.

**Q: How long does the first inventory typically take?**  
A: The first inventory run typically takes 4-8 hours for medium-sized tenants. Larger tenants may take longer. If the Driver flow is still running after 24 hours, investigate for child flow failures.
