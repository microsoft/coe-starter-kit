# Center of Excellence - Core Components

This solution contains the core components for the CoE Starter Kit, including inventory flows, environment management, and telemetry collection.

## ⚠️ Critical: DLP Policy Operations Warning

**IMPORTANT**: When working with DLP (Data Loss Prevention) policies using the CoE Starter Kit tools, be aware of potential risks:

- The **DLP Impact Analysis** tool is designed for **analysis and impact assessment only**
- For **production DLP policy operations** (create, copy, modify, delete), use the **[Power Platform Admin Center](https://admin.powerplatform.microsoft.com)** directly
- Copying or rapidly modifying DLP policies through automation can cause **unintended tenant-wide enforcement**
- DLP policy evaluations are cached for 2-4 hours and may persist even after policy deletion

📖 **See**: [Troubleshooting DLP Policy Scope Issues](../Documentation/TROUBLESHOOTING-DLP-POLICY-SCOPE.md) for detailed guidance and prevention strategies.

## Troubleshooting Guides

### DLP and Policy Issues

- **[DLP Policy Scope Issues](../Documentation/TROUBLESHOOTING-DLP-POLICY-SCOPE.md)** - Critical guidance for preventing and resolving tenant-wide DLP enforcement issues

### Inventory and Sync Issues

- **[PVA/Copilot Studio Sync Issues](./TROUBLESHOOTING-PVA-SYNC.md)** - Guide for resolving issues where not all bots appear in the inventory

### Common Questions

**Q: Why aren't all my resources showing up in the inventory?**

A: The inventory flows run in incremental mode by default, which only syncs new or recently modified resources. To capture all resources, you need to run a full inventory by setting the `admin_FullInventory` environment variable to `Yes`. Remember to set it back to `No` after the full inventory completes.

**Q: How often do the inventory flows run?**

A: The inventory flows are triggered when environment records are created or updated in the CoE Dataverse environment. The Admin | Sync Template v4 (Driver) flow typically runs on a schedule to update environment records, which then triggers the individual sync flows.

**Q: What does "skipped" mean in the flow run history?**

A: "Skipped" branches are normal and indicate that a conditional branch was not executed because the condition was not met. For example, if you're running in incremental mode, the "full inventory" branch will be skipped. This is expected behavior.

## Environment Variables

Key environment variables that control inventory behavior:

- `admin_FullInventory` - Run full inventory (Yes/No, default: No)
- `admin_InventoryFilter_DaysToLookBack` - Days to look back for modified resources (default: 7)
- `admin_DelayObjectInventory` - Add random delay to avoid throttling (Yes/No, default: No)

## Additional Documentation

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
