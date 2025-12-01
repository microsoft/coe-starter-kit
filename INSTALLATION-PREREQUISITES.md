# CoE Starter Kit - Installation Prerequisites

## Required Components

Before installing the CoE Starter Kit Core Components (version 4.50.6 and later), you **must** install the following prerequisite components in your Power Platform environment:

### 1. Power Platform Creator Kit (PowerCAT)

**Required:** Yes  
**Component:** `cat_powercatcomponentlibrary_0be3a`  
**Minimum Version:** 1.0.20250205.2 or later

The CoE Starter Kit Setup Wizard and other canvas apps use custom PCF (PowerApps Component Framework) controls from the Power Platform Creator Kit. Without this component library, the apps will display blank pages or missing content.

#### Installation Steps:

1. **Download the Creator Kit**
   - Visit: [Power Platform Creator Kit Releases](https://github.com/microsoft/powercat-creator-kit/releases)
   - Download the latest **Creator Kit** managed solution (`.zip` file)
   - Look for files named: `CreatorKitCore_X.X.XXXXXXXX.X_managed.zip`

2. **Import into Your Environment**
   - Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
   - Select your target environment
   - Navigate to **Solutions**
   - Click **Import solution**
   - Upload the Creator Kit `.zip` file
   - Wait for import to complete (may take several minutes)

3. **Verify Installation**
   - In **Solutions**, look for:
     - **Creator Kit Core** (or similar name)
     - **Power CAT Component Library**
   - Both should show as "Installed" with no warnings
   - Note the version number for troubleshooting

#### Components Included:

The Creator Kit provides the following PCF controls used by the CoE Starter Kit:

- **SubwayNav** - Navigation wizard control (used in Setup Wizard)
- **FluentDetailsList** - Data grid controls
- **Icon** - Icon components
- **Elevation** - Card elevation effects
- **Shimmer** - Loading placeholders
- **Spinner** - Loading indicators
- **ProgressIndicator** - Progress bars

### 2. Power Virtual Agents (Optional)

**Required:** No (for core functionality)  
**Component:** `bot`, `botcomponent`  
**Solution:** PowerVirtualAgents

Some optional components use Power Virtual Agents (PVA). If you don't plan to use PVA-related features, you can ignore warnings about missing PVA dependencies during import.

## Installation Order

**Important:** Install components in this order to avoid dependency errors:

1. ✅ **Power Platform Creator Kit** (PowerCAT)
2. ✅ **CoE Starter Kit - Core Components**
3. Optional: CoE Starter Kit - Governance Components
4. Optional: CoE Starter Kit - Nurture Components
5. Optional: Other CoE Starter Kit solutions

## Verifying Prerequisites

Before importing the CoE Starter Kit Core Components, verify prerequisites are installed:

### Method 1: Power Platform Admin Center

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
2. Navigate to **Environments** → Select your environment
3. Go to **Solutions**
4. Check for:
   - ✅ **Creator Kit Core** or **PowerCAT** solution
   - Version: 1.0.20250205.2 or newer

### Method 2: PowerShell

```powershell
# Install the Power Platform CLI if not already installed
# Visit: https://aka.ms/PowerAppsCLI

# Login to your environment
pac auth create --environment [YOUR-ENVIRONMENT-URL]

# List solutions
pac solution list

# Look for "CreatorKitCore" or "cat_powercatcomponentlibrary"
```

### Method 3: During CoE Import

When importing the CoE Core Components solution:

1. Click **Import solution**
2. Upload the CoE solution file
3. On the **Connection References** page, Power Platform will show any missing dependencies
4. If Creator Kit is missing, you'll see an error like:
   ```
   Missing Dependency: 
   Power CAT Component Library (cat_powercatcomponentlibrary_0be3a)
   Required by: Initial Setup page
   ```

5. **Do not proceed** if this dependency is missing - cancel the import, install Creator Kit first, then retry

## Troubleshooting Missing Components

### Symptom: "Required Solution Missing" Error

**Error message during import:**
```
The import has failed because a solution containing an application with the  
following name already exists in this organization: Power CAT Component Library
```

**Solution:**
- The Creator Kit is already installed but may be an older version
- Check the version and update if needed
- Go to Solutions → Creator Kit → Update (if available)

### Symptom: Blank Pages in Setup Wizard

**See:** [TROUBLESHOOTING-SETUP-WIZARD.md](TROUBLESHOOTING-SETUP-WIZARD.md) for detailed solutions

**Quick check:**
1. Press F12 in browser to open Developer Tools
2. Go to Console tab
3. Look for errors containing "PowerCAT" or "cat_PowerCAT"
4. If you see "Component not found" or "Failed to load", Creator Kit is missing or outdated

### Symptom: Import Succeeds but Apps Don't Work

**Possible causes:**
1. Creator Kit was installed **after** CoE Core Components
2. Creator Kit is an incompatible version
3. Browser cache contains old component definitions

**Solutions:**
1. Clear browser cache completely
2. Close all browser tabs and reopen
3. If still not working, consider re-importing CoE Core Components

## Version Compatibility

| CoE Starter Kit Version | Required Creator Kit Version | Notes |
|------------------------|------------------------------|-------|
| 4.50.6 (Latest) | 1.0.20250205.2 or later | Current recommended version |
| 4.50.x | 1.0.20241112.x or later | Check release notes for specifics |
| Older versions | See release documentation | May work with older Creator Kit versions |

**Recommendation:** Always use the latest stable version of both solutions for best compatibility and latest features.

## Environment Requirements

### Licensing

- **Creator Kit:** Free (no additional license required)
- **CoE Starter Kit:** Requires Power Apps per-user or per-app licenses

### Environment Type

- **Production:** Recommended for production deployments
- **Sandbox:** Suitable for testing
- **Trial:** Can be used for evaluation (30-day limit)
- **Default:** Not recommended for CoE deployment

### Capacity

Ensure your environment has sufficient:
- **Database capacity:** At least 1 GB available
- **File capacity:** At least 1 GB available
- **API request limits:** Power Automate flows will consume API calls

## Additional Resources

- **Creator Kit Documentation:** https://learn.microsoft.com/power-platform/guidance/creator-kit/overview
- **Creator Kit GitHub:** https://github.com/microsoft/powercat-creator-kit
- **CoE Starter Kit Setup Guide:** https://learn.microsoft.com/power-platform/guidance/coe/setup
- **Power Platform CLI:** https://aka.ms/PowerAppsCLI

## Getting Help

If you encounter issues with prerequisites:

1. **Review troubleshooting guide:** [TROUBLESHOOTING-SETUP-WIZARD.md](TROUBLESHOOTING-SETUP-WIZARD.md)
2. **Check GitHub Issues:** [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)
3. **Community Forums:** [Power Platform Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
4. **Report a bug:** Use the [Setup Wizard Diagnostic Checklist](.github/ISSUE_TEMPLATE/setup-wizard-diagnostic-checklist.md)

## Quick Reference Card

Print or bookmark this checklist for installations:

```
☐ 1. Downloaded Creator Kit (1.0.20250205.2+)
☐ 2. Imported Creator Kit to target environment
☐ 3. Verified Creator Kit shows as "Installed"
☐ 4. Downloaded CoE Core Components
☐ 5. Imported CoE Core Components
☐ 6. No dependency errors during import
☐ 7. Tested Setup Wizard - pages load correctly
☐ 8. Cleared browser cache if pages blank
☐ 9. Documented installed versions for future reference
```

---

**Last Updated:** November 2025  
**Applies to:** CoE Starter Kit v4.50.6 and later
