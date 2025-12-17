# Flow Orphan Status - Frequently Asked Questions

## Overview

This document clarifies how the "Flow is Orphaned" status works in the CoE Starter Kit and addresses common questions about orphaned flows, apps, and other resources.

## Key Questions

### 1. What exactly drives the "Flow is Orphaned" status?

The **"Flow is Orphaned" status is based on the maker (original creator)**, not the current owner or co-owners.

When the CoE Starter Kit's orphan detection flow runs, it:
1. Checks each **maker** (original creator) in the Maker table
2. Queries Microsoft Graph API to verify the user's status in Azure Active Directory
3. Marks the maker as orphaned if:
   - The user account is not found (404 - user has been deleted/left the company), OR
   - The user account is disabled (accountEnabled = false) AND the environment variable `admin_DisabledUsersareOrphaned` is set to "Yes"
4. Automatically marks **all resources created by that maker** as orphaned (flows, apps, custom connectors, etc.)

### 2. Why doesn't having co-owners prevent a flow from being marked as orphaned?

**Co-owners are not considered in orphan status determination.** This is by design.

The orphan flag tracks whether the **original creator** (maker) has left the organization, regardless of who currently has access to or can manage the resource. This helps organizations:
- Identify resources created by departed employees for governance and audit purposes
- Trigger review and reassignment workflows
- Maintain a complete audit trail of resource creators

### 3. I set the owner field in the solution - why is the flow still orphaned?

Changing the owner field (whether in a solution or otherwise) does not immediately update the orphan status because:

1. **The CoE Starter Kit tracks a "Derived Owner" field** that references the original maker record
2. **Orphan status is only updated when** the cleanup flow runs (typically scheduled to run periodically)
3. **The flow checks the maker's status**, not the current owner value

**To resolve**: Wait for the next scheduled run of `CLEANUP - Admin | Sync Template v3 (Orphaned Makers)` or trigger it manually.

### 4. What's the difference between Maker, Owner, Co-Owner, and Derived Owner?

| Term | Definition | Used for Orphan Status? |
|------|------------|------------------------|
| **Maker** | The original creator of the resource (tracked in CoE Maker table) | ✅ Yes - This is what determines orphan status |
| **Owner** | The current primary owner shown in Power Platform admin center | ❌ No - Not used for orphan detection |
| **Co-Owner** | Additional users with edit/manage permissions | ❌ No - Not considered in orphan logic |
| **Derived Owner** | CoE Starter Kit field that links the resource back to the maker record for tracking | ✅ Yes - Used to identify which maker created the resource |

## Configuration

### admin_DisabledUsersareOrphaned Environment Variable

This environment variable controls whether disabled (but not deleted) user accounts are treated as orphaned.

- **Type**: Boolean (Yes/No)
- **Default**: No (false)
- **Location**: Environment Variables in the CoE Core Components solution
- **Purpose**: Some organizations want to track resources from disabled accounts (e.g., employees on extended leave), while others only care about fully deleted accounts

**Setting to "Yes"** means:
- Users with `accountEnabled = false` in Azure AD will be marked as orphaned
- All their resources will be flagged as orphaned

**Setting to "No"** (default) means:
- Only users who are completely deleted from Azure AD (404 response) are marked as orphaned
- Disabled accounts are not considered orphaned

## How to Handle Orphaned Flows

### Option 1: Wait for Automatic Sync

If the maker account still exists and is not disabled:
1. The next run of the orphan cleanup flow will detect that the maker is valid
2. The orphan status will be automatically cleared

### Option 2: Reassignment Workflow

Use the CoE Starter Kit's built-in reassignment flows:
- **Audit Components**: `Request Orphaned Objects Reassigned (Parent)` and `(Child)` flows
- These flows help systematically reassign orphaned resources to active users

### Option 3: Manual Intervention

For immediate fixes:
1. Update the resource's maker/owner in Power Platform
2. Manually run the `CLEANUP - Admin | Sync Template v3 (Orphaned Makers)` flow
3. Or wait for the next scheduled run (typically daily)

## Related Flows and Components

### Cleanup and Detection Flows
- **`CLEANUP - Admin | Sync Template v3 (Orphaned Makers)`**: Main flow that identifies orphaned makers and marks their resources
- **`HELPER - Maker Check`**: Child flow that validates each maker's status via Microsoft Graph API
- **`CLEANUP - Admin | Sync Template v3 (Orphaned Users)`**: Updates the Power Platform Users table with orphan status

### Inventory Flows
- **`Admin Sync Template v4 (Flows)`**: Syncs flow inventory and sets the Derived Owner field
- Flow sync flows collect the `_admin_derivedowner_value` which links flows to their makers

### Reassignment Flows (Audit Components)
- **`Request Orphaned Objects Reassigned (Parent)`**: Orchestrates the reassignment process
- **`Request Orphaned Objects Reassigned (Child)`**: Processes individual reassignment requests

## Known Issues and Clarifications

### Tooltip Text Discrepancy

**Issue**: The tooltip in the Power Platform Admin View app states:
> "Flow is Orphaned - If the **owner** (not maker) of the flow has left the company."

**Actual Behavior**: The orphan status is determined by the **maker** (original creator), not the owner.

**Status**: This tooltip text is misleading and should say "maker" instead of "owner". This discrepancy is a known issue that will be addressed in a future update. The flow name `CLEANUP - Admin | Sync Template v3 (Orphaned Makers)` correctly indicates it's based on maker status.

### Reference Issue
This FAQ addresses questions originally raised in [Issue #729](https://github.com/microsoft/coe-starter-kit/issues/729), which has been consolidated into [Issue #10319](https://github.com/microsoft/coe-starter-kit/issues/10319) for comprehensive orphaned object management improvements.

## Additional Resources

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Core Components Overview](https://docs.microsoft.com/power-platform/guidance/coe/core-components)
- [CoE Cleanup and Orphan Detection](https://docs.microsoft.com/power-platform/guidance/coe/setup-cleanup)
