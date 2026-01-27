# Center of Excellence - Core Components

This solution contains the core components for the CoE Starter Kit, including inventory flows, environment management, and telemetry collection.

## Troubleshooting Guides

### Inventory and Sync Issues

- **[PVA/Copilot Studio Sync Issues](./TROUBLESHOOTING-PVA-SYNC.md)** - Guide for resolving issues where not all bots appear in the inventory
- **[Long-Running Sync Template Flows](./TROUBLESHOOTING-SYNC-PERFORMANCE.md)** - Guide for resolving performance issues with Admin | Sync Template flows that run for extended periods or appear stuck

### Common Questions

**Q: Why aren't all my resources showing up in the inventory?**

A: The inventory flows run in incremental mode by default, which only syncs new or recently modified resources. To capture all resources, you need to run a full inventory by setting the `admin_FullInventory` environment variable to `Yes`. Remember to set it back to `No` after the full inventory completes.

**Q: How often do the inventory flows run?**

A: The inventory flows are triggered when environment records are created or updated in the CoE Dataverse environment. The Admin | Sync Template v4 (Driver) flow typically runs on a schedule to update environment records, which then triggers the individual sync flows.

**Q: What does "skipped" mean in the flow run history?**

A: "Skipped" branches are normal and indicate that a conditional branch was not executed because the condition was not met. For example, if you're running in incremental mode, the "full inventory" branch will be skipped. This is expected behavior.

**Q: Why are my sync flows running for hours or appearing stuck?**

A: Long-running sync flows (>1 hour) are typically caused by API throttling when multiple flows run concurrently without delays enabled. To fix this, set `admin_DelayObjectInventory` and `admin_DelayInventory` environment variables to `Yes`. See the [Long-Running Sync Template Flows guide](./TROUBLESHOOTING-SYNC-PERFORMANCE.md) for detailed troubleshooting steps.

## Environment Variables

Key environment variables that control inventory behavior:

- `admin_FullInventory` - Run full inventory (Yes/No, default: No)
- `admin_InventoryFilter_DaysToLookBack` - Days to look back for modified resources (default: 7)
- `admin_DelayObjectInventory` - Add random delay to avoid throttling (Yes/No, default: No, **recommended: Yes**)
- `admin_DelayInventory` - Add delay in Driver flow to space out environment processing (Yes/No, default: No, **recommended: Yes**)

**⚠️ Important**: For optimal performance and to prevent throttling issues, set both delay variables to **Yes**, especially in medium to large tenants.

## Additional Documentation

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
