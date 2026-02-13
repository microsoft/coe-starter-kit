# GitHub Issue Response Template - Desktop Flows Missing from Inventory

This template should be used when responding to issues where desktop flows are not appearing in the CoE inventory, even though they exist in the Power Automate maker portal.

---

## Template Response

Thank you for reporting this issue! This is a common scenario that occurs when the CoE Starter Kit is running in **incremental inventory mode** (the default).

### What's Happening

By default, the **"Admin | Sync Template v4 (Desktop flows)"** flow runs in **incremental mode**, which means it only syncs:

✅ **New desktop flows** that aren't yet in the inventory  
✅ **Desktop flows manually flagged** for inventory (`admin_inventoryme = true`)  
❌ **Existing desktop flows** already in the inventory (unless flagged)

The flows you're seeing in the Power Automate maker portal were likely created **before** the CoE Starter Kit was set up, or during a time when the sync wasn't running. As a result, they're not in the inventory yet.

### Quick Solution: Run Full Inventory

The fastest way to get all your desktop flows into the inventory is to run a **full inventory**:

1. Go to [Power Apps](https://make.powerapps.com) → Your CoE environment
2. Navigate to **Solutions** → **Center of Excellence - Core Components** → **Environment Variables**
3. Find `FullInventory` (`admin_FullInventory`)
4. Set **Current Value** = `Yes`
5. Save and wait for the next sync to complete
6. **⚠️ IMPORTANT:** Set `FullInventory` back to `No` after completion

### Detailed Troubleshooting Guide

For comprehensive troubleshooting steps, multiple solution options, and advanced diagnostics, please see:

📖 **[Troubleshooting Desktop Flows Sync Issues](../CenterofExcellenceCoreComponents/TROUBLESHOOTING-DESKTOP-FLOW-SYNC.md)**

This guide includes:
- ✅ Multiple solution approaches
- ✅ Step-by-step instructions with screenshots
- ✅ Environment variables reference
- ✅ Advanced troubleshooting (permissions, filters, configuration)
- ✅ FAQ and common scenarios

### Why This Happens

The incremental inventory mode is designed for **efficiency** in large tenants:
- Reduces API calls to Power Platform
- Avoids throttling
- Suitable for ongoing operations

However, it requires running a **full inventory** at least once:
- ✅ After initial CoE Starter Kit setup
- ✅ After upgrades
- ✅ When troubleshooting missing resources

### Related Issues

This is similar to:
- **PVA bots not appearing** → See [TROUBLESHOOTING-PVA-SYNC.md](../CenterofExcellenceCoreComponents/TROUBLESHOOTING-PVA-SYNC.md)
- **Cloud flows not appearing** → Similar incremental inventory behavior

### Next Steps

1. Try the full inventory solution above
2. Review the [troubleshooting guide](../CenterofExcellenceCoreComponents/TROUBLESHOOTING-DESKTOP-FLOW-SYNC.md)
3. If desktop flows still don't appear after running full inventory, please provide:
   - Screenshots of flow run history showing the "List_Envt_Desktop_Flows" action output
   - Environment configuration (from `admin_environments` table)
   - Whether the desktop flows are standard or a special type

Please let us know if the full inventory resolves the issue!

---

## When to Use This Template

Use this template when:
- User reports desktop flows missing from inventory
- Flow runs successfully but doesn't show all desktop flows
- Some environments show "[]" while others show data
- User can see desktop flows in Power Automate maker portal but not in CoE Dashboard

## Variations

### If User Already Tried Full Inventory

If the user mentions they already ran full inventory but flows are still missing:

1. Ask for screenshots of the flow run history, specifically:
   - "List_Envt_Desktop_Flows" action output
   - "Check_if_Desktop_Flows_can_be_retrieved_for_this_environment" condition
2. Check for permission issues (CoE System User role)
3. Check for environment configuration issues (deleted, no Dataverse, excluded, etc.)
4. Review the desktop flow type filter (`uiflowtype ne 101`)

### If User Has Many Environments

If the user has many environments and only some are affected:

1. Focus on the specific environments showing "[]"
2. Compare environment configurations (Dataverse, runtime state, excluded flag)
3. Check if CoE System User has permissions in those environments
4. Verify the environments aren't marked as deleted or excluded

---

**Template Version:** 1.0  
**Last Updated:** February 2026  
**Related Templates:**
- [PVA Sync Issues](./ISSUE-RESPONSE-PowerPages-Sessions.md)
- [Sovereign Cloud Support](./issue-response-templates.md)
