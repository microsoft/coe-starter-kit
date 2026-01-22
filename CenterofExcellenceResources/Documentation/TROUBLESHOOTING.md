# CoE Starter Kit - Troubleshooting Guide

This document provides quick solutions to common issues encountered when setting up, configuring, or upgrading the CoE Starter Kit.

## Table of Contents
- [Upgrade Issues](#upgrade-issues)
  - [Cannot find "Remove unmanaged layer" button](#cannot-find-remove-unmanaged-layer-button)
- [Additional Resources](#additional-resources)

---

## Upgrade Issues

### Cannot find "Remove unmanaged layer" button

**Symptom:** When following the [upgrade instructions](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup#installing-upgrades), you navigate to Solution Layers but cannot find a "Remove unmanaged layer" button.

**Solution:** The button is labeled **"Remove active customizations"** in the Power Platform interface. This is the correct button to click to remove unmanaged layers.

**Steps:**
1. Navigate to the Solution Layers view for the component
2. Select the row with "Unmanaged layer" in the Solution column (typically Order 2 or higher)
3. Click **"Remove active customizations"** 
4. Confirm the removal

**Visual Reference:**
- The button appears in the command bar after selecting an unmanaged layer row
- Unmanaged layers show "Active" in the Layer Status column
- The Solution column will show "Unmanaged layer"
- The Publisher column will show "Default Publisher for [your org]"

**More Information:** See the [Upgrade FAQ](FAQ-Upgrade.md#question-i-dont-see-remove-unmanaged-layer-option-when-trying-to-upgrade-what-should-i-do) for detailed explanation and additional context.

---

## Additional Resources

- [CoE Starter Kit Setup Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
- [After Setup and Upgrade Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [Upgrade FAQ](FAQ-Upgrade.md)
- [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

---

## Getting Help

If you can't find a solution to your issue in this troubleshooting guide:

1. **Check the [Upgrade FAQ](FAQ-Upgrade.md)** for more detailed explanations
2. **Search [existing issues](https://github.com/microsoft/coe-starter-kit/issues)** - your question may have already been answered
3. **Review the [official documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)**
4. **Ask a question** using the [question issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
5. **Join the discussion** in the [Power Platform Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
