# GitHub Issue Response Template - Entity 'admin_flow' Does Not Exist Error

## Use Case
Use this template when responding to issues related to the "Entity 'admin_flow' With Id = [GUID] Does Not Exist" error in SYNC HELPER - Cloud Flows.

---

## Response Template

Thank you for reporting this issue! This error occurs when the SYNC HELPER - Cloud Flows tries to process a flow record that no longer exists in the Dataverse `admin_flows` table.

### Root Cause

This is typically a timing or data consistency issue where:
1. A flow was deleted from the environment between when the parent sync flow queried for it and when the child flow tried to process it
2. A flow is flagged for manual inventory (`admin_inventoryme = true`) but the record doesn't exist
3. Stale references remain in the admin_flows table after flows have been removed

### Quick Resolution

**Option 1: Run Cleanup Flow** (Recommended)

1. Run the **CLEANUP HELPER - Check Deleted v4 (Cloud Flows)** flow in your CoE environment
2. This flow will identify and mark flows that have been deleted from the tenant
3. Wait for it to complete, then re-run your sync flow

**Option 2: Manual Cleanup**

If the error persists for a specific flow ID:

1. Open **Power Apps** maker portal
2. Navigate to **Dataverse** > **Tables** > **admin_flows**  
3. Find the record with the GUID mentioned in your error message
4. Either:
   - Delete the record if the flow no longer exists in your environment
   - Set `admin_inventoryme` to **false** if you're using manual inventory mode
   - Set `admin_flowdeleted` to **true** to prevent re-processing

**Option 3: Full Re-Inventory**

Run the **Admin | Sync Template v4 (Flows)** flow to perform a full inventory refresh of all flows in the environment.

### Detailed Troubleshooting Guide

For comprehensive resolution steps, preventive measures, and technical details, please see:
📖 **[Troubleshooting Guide: Entity Does Not Exist Error](troubleshooting-sync-helper-cloud-flows-entity-not-exist.md)**

### Prevention

To prevent this error in the future:
- Schedule regular runs of the **CLEANUP HELPER** flows (weekly or bi-weekly)
- Avoid setting `admin_inventoryme = true` on flows that have been deleted
- Monitor the `admin_SyncFlowErrors` table for recurring issues

### Expected Behavior

This is typically a transient error that doesn't cause data loss. The affected flow will be retried in the next sync cycle. If it occurs occasionally (less than 1-2% of flow processing runs), it's expected behavior in large, dynamic environments.

### When to Re-Open

Please re-open this issue if:
- The error persists after running the cleanup flows
- Multiple flows are systematically affected (not just one-off occurrences)
- The error prevents all sync flows from completing successfully

---

## Additional Context for Responders

### Related Components
- **Parent Flow**: Admin | Sync Template v4 (Flows)
- **Child Flow**: SYNC HELPER - Cloud Flows
- **Affected Table**: admin_flows (Dataverse)

### Common Scenarios

**Scenario 1: Recently Deleted Flow**
- User deleted a flow from the environment
- Sync flow tries to process it before cleanup runs
- **Resolution**: Run cleanup flow

**Scenario 2: Manual Inventory Flag**
- Flow was marked for manual inventory (`admin_inventoryme = true`)
- Flow was later deleted but flag wasn't cleared
- **Resolution**: Clear the flag or delete the record

**Scenario 3: Concurrent Modifications**
- High-concurrency environment with many flow changes
- Timing window causes record to be deleted between queries
- **Resolution**: Re-run sync flow, error should be transient

### Error Handling in Flow

The SYNC HELPER flow includes error handling:
```
Get_Flow_from_Inventory
├─ Success → Process existing record
└─ Failure → Catch_-_new_to_inventory → Treat as new flow
```

However, certain conditions can cause the error to propagate despite this handling.

### Quick Diagnostic Questions

When gathering more information, ask:
1. Is this error occurring repeatedly for the same flow GUID?
2. Has the flow with this GUID been recently deleted?
3. Are you using manual inventory mode (`admin_inventoryme` flag)?
4. How frequently does this error occur (percentage of flow runs)?
5. What version of the CoE Starter Kit are you using?

### Related GitHub Issues

Search for similar issues:
- Keywords: "admin_flow", "Does Not Exist", "SYNC HELPER", "Entity"
- Common variations: "Entity does not exist", "GetItem failed", "Flow not found"

### Microsoft Learn References

- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Starter Kit Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Dataverse API Limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)

---

## Closing Statement

I'm closing this issue as this is expected behavior in certain scenarios (deleted flows, stale references). The resolution steps provided should resolve the error. Please follow the troubleshooting guide and feel free to re-open if the issue persists after trying the recommended solutions.

For questions about the CoE Starter Kit or to report new issues, please use the [issue templates](https://github.com/microsoft/coe-starter-kit/issues/new/choose).

---

## Template Version
- **Version**: 1.0
- **Created**: 2026-01-22
- **Last Updated**: 2026-01-22
- **Related Documentation**: troubleshooting-sync-helper-cloud-flows-entity-not-exist.md
