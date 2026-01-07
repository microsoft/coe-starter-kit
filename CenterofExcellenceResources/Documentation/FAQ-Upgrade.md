# CoE Starter Kit - Upgrade FAQ

This document addresses frequently asked questions about upgrading the CoE Starter Kit.

## Table of Contents
- [Removing Unmanaged Layers](#removing-unmanaged-layers)

---

## Removing Unmanaged Layers

### Question: I don't see "Remove unmanaged layer" option when trying to upgrade. What should I do?

**Answer:** This is expected behavior. The button you need to click is **"Remove active customizations"**, not "Remove unmanaged layer".

When you navigate to the Solution Layers view in Power Platform, you will see a button labeled **"Remove active customizations"**. This is the correct button to click to remove unmanaged layers from your solution.

#### Background
In Power Platform, the terminology has evolved over time. While the official Microsoft documentation may refer to "unmanaged layers", the actual button in the Power Platform admin center is labeled "Remove active customizations". Both terms refer to the same action.

#### Steps to Remove Unmanaged Layers

1. Navigate to [Power Apps](https://make.powerapps.com)
2. Select your environment
3. Go to **Solutions**
4. Select the solution you want to upgrade (e.g., "Center of Excellence - Core Components")
5. Select the component with unmanaged layers (e.g., a cloud flow like "Get M365 Service Messages")
6. Click **Advanced** > **See solution layers**
7. Select the unmanaged layer (Order 2 or higher with "Unmanaged layer" as the Solution name)
8. Click **"Remove active customizations"** (this removes the unmanaged layer)
9. Confirm the removal

#### Important Notes

- **When to remove unmanaged layers:** You should remove unmanaged layers before upgrading the CoE Starter Kit to ensure you receive all updates from the latest version.
- **Active layer status:** Unmanaged layers will show "Layer Status" as "Active" in the solution layers view.
- **Cannot remove managed layers:** You can only remove unmanaged (active) customizations. Managed layers from the solution cannot be removed this way.
- **Backup customizations:** If you have made intentional customizations that you want to keep, document or export them before removing the unmanaged layer.

#### Reference

For more information about upgrading the CoE Starter Kit, see:
- [Installing Upgrades - CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup#installing-upgrades)
- [Update a solution - Power Platform Documentation](https://learn.microsoft.com/en-us/power-platform/alm/update-solutions-alm)

---

### Question: Why do I have unmanaged layers?

**Answer:** Unmanaged layers are created when you make customizations to components that are part of a managed solution. This can happen when:

1. You edit a cloud flow that's part of the CoE Starter Kit managed solution
2. You modify connection references or environment variables in the solution
3. You customize apps or other components included in the managed solution

These customizations create an "unmanaged layer" on top of the managed solution. During upgrades, these unmanaged layers can prevent you from receiving updates to those specific components.

#### Best Practices

To avoid unmanaged layers:
- **Don't edit managed solution components directly** - Instead, export the component to a separate unmanaged solution, make your changes there, and export as a new managed solution
- **Use the Setup Wizard** - The CoE Starter Kit includes a Setup Wizard to help configure environment variables and connection references properly
- **Document customizations** - Keep track of any customizations you make so you can reapply them after upgrades

For more information about customizing the CoE Starter Kit properly, see:
- [Modifying CoE Starter Kit components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/modify-components)

---

### Question: What happens if I don't remove unmanaged layers before upgrading?

**Answer:** If you don't remove unmanaged layers before upgrading:

1. **Component won't be updated** - The specific component with the unmanaged layer will not receive updates from the new version
2. **Bug fixes may be missed** - Any bug fixes or improvements to that component in the new release won't be applied
3. **Breaking changes possible** - Your customized version may become incompatible with other updated components
4. **Errors may occur** - The solution may function incorrectly if some components are updated and others are not

#### Recommendation

Always follow the official upgrade instructions and remove unmanaged layers before upgrading to ensure a smooth upgrade process and to receive all improvements and bug fixes.

---

## Additional Resources

- [CoE Starter Kit Setup Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
- [After Setup and Upgrade Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
