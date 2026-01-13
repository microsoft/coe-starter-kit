# CoE Starter Kit Troubleshooting Guide

This guide provides solutions to common issues encountered when setting up and upgrading the CoE Starter Kit.

## Table of Contents

- [Upgrade and Update Issues](#upgrade-and-update-issues)
  - [Cannot Remove Unmanaged Layer](#cannot-remove-unmanaged-layer)

---

## Upgrade and Update Issues

### Cannot Remove Unmanaged Layer

**Issue**: When following the [upgrade documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup) to update the CoE Starter Kit, you navigate to solution layers but do not see a "Remove unmanaged layer" option. Instead, you only see "Remove active customizations".

**Solution**: The option **"Remove active customizations"** is the correct option to use. Microsoft has renamed this functionality in the Power Platform interface. This button serves the same purpose as the previously named "Remove unmanaged layer" option.

#### Steps to Remove Unmanaged Customizations:

1. Navigate to the **Power Platform admin center** or **Power Apps** portal
2. Go to **Solutions** and open the CoE Starter Kit solution (e.g., "Center of Excellence - Core Components")
3. Navigate to the component with the unmanaged layer (e.g., **Cloud flows** > **Command Center App** > **Get M365 Service Messages**)
4. Click on the component to view its details
5. Click on **Solution Layers** in the command bar
6. Select the **Unmanaged layer** row (if present)
7. Click **"Remove active customizations"** in the command bar
8. Confirm the removal

#### Why This Is Necessary:

Unmanaged customizations can prevent managed solutions from updating properly. When you customize a component in a managed solution without using an unmanaged solution, it creates an "unmanaged layer" on top of the managed layer. Removing this layer ensures that:

- The managed solution can update components properly
- You receive all updates and fixes from new versions
- Your environment stays in sync with the official CoE Starter Kit releases

#### Additional Resources:

- [Solution layers documentation](https://learn.microsoft.com/en-us/power-platform/alm/solution-layers-alm)
- [CoE Starter Kit upgrade guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [Understanding solution concepts](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/solutions-overview)

---

## Additional Help

If you encounter issues not covered in this guide:

- **Report an issue**: [GitHub Issues](https://aka.ms/coe-starter-kit-issues)
- **Ask questions**: Use the [question issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
- **Community support**: [Power Apps Community forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

**Note**: The CoE Starter Kit is provided as sample implementations and is not officially supported through Microsoft Support channels. For issues with core Power Platform features, contact Microsoft Support through your standard support channel.
