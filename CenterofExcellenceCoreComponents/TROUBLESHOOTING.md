# CoE Starter Kit Core Components - Troubleshooting Guide

## App Catalog UI Not Displaying Correctly

### Issue Description
When opening the App Catalog app from the CoE Starter Kit Core Components, the UI appears blank or incomplete with missing controls, buttons, and content. Only the header, navigation, and basic layout elements are visible.

![App Catalog UI Issue Example](https://github.com/user-attachments/assets/5a3a8f2f-e9b6-4c8d-8a22-19b9cc491b55)

### Root Cause
The App Catalog (and several other apps in the CoE Starter Kit) use **Power Platform Creator Kit** components (formerly PowerCAT). These are PCF (PowerApps Component Framework) controls that provide modern, Fluent UI-based components like:
- SearchBox
- Pivot
- Elevation
- Icon
- CommandBar
- FluentDetailsList

When the Creator Kit is not installed or is at an incompatible version, these PCF controls fail to render, resulting in a blank or incomplete UI.

### Prerequisites
The CoE Starter Kit Core Components solution has the following dependencies that must be installed **before** or **during** the CoE Starter Kit installation:

1. **Creator Kit Core** - Minimum version: 1.0.20241119.01
2. **PowerCAT Toolkit** - Minimum version: 1.0.20250205.2

### Solution

#### Option 1: Install Creator Kit from AppSource (Recommended)
The Creator Kit is available as a managed solution from Microsoft AppSource.

1. Navigate to [Microsoft Creator Kit on AppSource](https://aka.ms/creatorkitdownload)
2. Click "Get it now" to install the Creator Kit to your Power Platform environment
3. Select the environment where you have installed (or will install) the CoE Starter Kit
4. Accept the terms and conditions
5. Wait for the installation to complete (this may take several minutes)
6. After installation, refresh your App Catalog app (hard refresh: Ctrl+Shift+R or Cmd+Shift+R on Mac)

#### Option 2: Install Creator Kit via Power Platform Admin Center
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
2. Select **Environments** from the left navigation
3. Select your CoE environment
4. Click **Resources** > **Dynamics 365 apps**
5. Click **Install app**
6. Search for "Creator Kit"
7. Select **Creator Kit** and click **Next**
8. Accept the terms and click **Install**
9. Wait for installation to complete
10. Refresh your App Catalog app (hard refresh: Ctrl+Shift+R or Cmd+Shift+R on Mac)

#### Option 3: Reinstall CoE Starter Kit with Dependencies
If you're installing the CoE Starter Kit for the first time or upgrading:

1. When installing the CoE Starter Kit Core Components solution, ensure you select **"Install dependent solutions"** or **"Include dependencies"** option
2. The Power Platform will automatically install the required Creator Kit components
3. Wait for all installations to complete before opening any apps

### Verification Steps
After installing the Creator Kit, verify the installation:

1. Go to [Power Apps](https://make.powerapps.com)
2. Select your CoE environment
3. Go to **Solutions**
4. Verify the following solutions are present:
   - **Creator Kit Core** (or similar name with "Creator Kit")
   - **PowerCAT Toolkit** (or **Power CAT Component Library**)
   - **Center of Excellence - Core Components**

5. Open the App Catalog app
6. Perform a hard refresh (Ctrl+Shift+R or Cmd+Shift+R on Mac)
7. Verify that all UI elements are now visible:
   - Search box at the top
   - Category tabs (All, Analytics, etc.)
   - App tiles/cards with icons
   - Filters and sorting options

### Additional Troubleshooting Steps

#### If UI is still not displaying after installing Creator Kit:

1. **Clear browser cache completely**
   - Close all browser tabs
   - Clear browsing data (cache and cookies)
   - Reopen browser and navigate to the app

2. **Verify PCF Controls are enabled in your environment**
   - Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
   - Select your environment
   - Go to **Settings** > **Product** > **Features**
   - Ensure **Power Apps component framework for canvas apps** is **ON**
   - Save and wait a few minutes for the setting to propagate

3. **Check for solution layer conflicts**
   - Go to [Power Apps](https://make.powerapps.com)
   - Select **Solutions**
   - Find **Center of Excellence - Core Components**
   - Click on the solution
   - Select the App Catalog app
   - Click **Advanced** > **See solution layers**
   - If unmanaged layers exist, remove them to ensure you're using the latest managed version

4. **Verify user permissions and security roles**
   - Ensure your user has the appropriate security roles assigned
   - Minimum required: **Basic User** role
   - Recommended: **CoE Admin** or **Environment Admin** role for full functionality

5. **Check connection references**
   - Go to [Power Apps](https://make.powerapps.com)
   - Select **Solutions**
   - Open **Center of Excellence - Core Components**
   - Go to **Connection References**
   - Ensure all connections are configured and authenticated
   - Re-authenticate any connections showing errors

6. **Update Creator Kit to latest version**
   - The Creator Kit is regularly updated
   - Check AppSource for the latest version
   - Upgrade if a newer version is available

### Other Apps Affected
The following apps in the CoE Starter Kit also use Creator Kit components and may experience similar UI issues:
- Admin - Command Center
- DLP Editor
- Power BI Dashboard Manager
- Set App Permissions
- Template Catalog

### Related Issues
- [GitHub Issue #10178](https://github.com/microsoft/coe-starter-kit/issues/10178)

### Additional Resources
- [Power Platform Creator Kit Documentation](https://learn.microsoft.com/power-platform/guidance/creator-kit/overview)
- [CoE Starter Kit Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [PCF Controls Documentation](https://learn.microsoft.com/power-apps/developer/component-framework/overview)

### Need More Help?
If you continue to experience issues after following these steps:
1. Create a new issue on [GitHub](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
2. Use the "CoE Starter Kit - Bug" template
3. Include:
   - CoE Starter Kit version
   - Creator Kit version (if installed)
   - Environment details (region, type)
   - Screenshots of the issue
   - Steps you've already tried
   - Browser console errors (F12 > Console tab)
