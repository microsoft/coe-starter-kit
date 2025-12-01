# Troubleshooting: Setup Wizard Not Loading

## Issue Description

When opening the CoE Setup and Upgrade Wizard, the "Confirm pre-requisites" page (or other wizard pages) displays a blank white area where the content should appear. The page header and navigation buttons are visible, but the main content area is empty.

![Setup Wizard Blank Page](https://github.com/user-attachments/assets/9065125c-bf82-4af8-9dc9-640f4730a290)

## Root Cause

The Setup Wizard uses custom PCF (PowerApps Component Framework) controls from the **Power Platform Creator Kit (PowerCAT)**. When these components fail to load or initialize properly, Power Apps displays blank space where the controls should be rendered.

### Common Causes:

1. **Missing PowerCAT Component Library**: The PowerCAT component library (`cat_powercatcomponentlibrary_0be3a`) was not imported or is not available in the environment
2. **Component Library Version Mismatch**: An incompatible or outdated version of the PowerCAT components is installed
3. **Browser Compatibility Issues**: Older browsers or browsers with strict security settings blocking the PCF controls
4. **Network/Firewall Restrictions**: Corporate firewalls or network policies blocking required CDN resources for PCF components
5. **Cache Issues**: Browser cache containing corrupted or outdated component definitions
6. **Missing Dependencies**: Required Dataverse components or custom controls not properly installed

## Solutions

### Solution 1: Verify PowerCAT Component Library Installation

The Setup Wizard requires the **Power Platform Creator Kit** components to be installed in the same environment.

**Steps:**
1. Navigate to [Power Platform Creator Kit on GitHub](https://github.com/microsoft/powercat-creator-kit)
2. Download the latest version of the Creator Kit solution
3. Import the Creator Kit solution into the same environment where the CoE Starter Kit is installed
4. After import completes, refresh the Setup Wizard app

**Verification:**
- Go to **Solutions** in your Power Platform environment
- Look for a solution named similar to "Creator Kit" or "PowerCAT"
- Verify the solution is imported and not showing any errors

### Solution 2: Check Solution Dependencies

Ensure the CoE Core Components solution properly references the PowerCAT library:

**Steps:**
1. In Power Platform Admin Center, navigate to **Solutions**
2. Select **Center of Excellence - Core Components** solution
3. Click **Show dependencies** 
4. Verify that PowerCAT/Creator Kit components are listed
5. If missing, re-import the CoE solution and ensure all dependencies are satisfied during import

### Solution 3: Clear Browser Cache and Retry

PCF components are cached by the browser and corrupted cache can cause loading issues:

**Steps:**
1. Clear your browser cache completely (Ctrl+Shift+Del in most browsers)
   - Ensure "Cached images and files" is selected
   - Select "All time" for time range
2. Close all browser tabs
3. Open a new browser window
4. Navigate to the Setup Wizard app again

**Alternative:** Try opening the app in an InPrivate/Incognito browser window

### Solution 4: Try a Different Browser

Some browsers have better support for PCF components than others:

**Recommended Browsers:**
- Microsoft Edge (Chromium-based) - **Recommended**
- Google Chrome (latest version)

**Steps:**
1. If using a different browser, try Microsoft Edge or Chrome
2. Ensure the browser is updated to the latest version
3. Navigate to the Setup Wizard in the new browser

### Solution 5: Check Network/Firewall Restrictions

PCF components may load resources from external CDNs:

**Steps:**
1. Open browser developer tools (F12)
2. Go to the **Console** tab
3. Look for any errors related to:
   - Failed to load resources
   - CORS errors
   - Network errors
   - Blocked content

4. If you see blocked resources:
   - Work with your IT team to whitelist required Microsoft CDN domains
   - Common domains needed:
     - `*.azureedge.net`
     - `*.powerapps.com`
     - `*.dynamics.com`
     - `*.microsoft.com`

### Solution 6: Verify Component Control Registration

The custom controls must be properly registered in Dataverse:

**Steps:**
1. Go to **Power Platform Admin Center**
2. Navigate to your environment → **Settings** → **Customizations**
3. Check that PCF controls are enabled
4. Go to **Solutions** → **Center of Excellence - Core Components** → **Controls**
5. Verify the PowerCAT controls are listed and active

### Solution 7: Re-import the CoE Core Components Solution

If all else fails, a fresh import may resolve the issue:

**Steps:**
1. **Backup your configuration:**
   - Export your Environment Variables settings
   - Document any customizations

2. **Remove the solution:**
   - Go to **Solutions**
   - Select **Center of Excellence - Core Components**
   - Click **Delete** (this will remove the solution but preserve your data)

3. **Re-import:**
   - Download the latest version of CoE Core Components
   - Ensure PowerCAT Creator Kit is already installed
   - Import the Core Components solution
   - Select all dependencies during import
   - Wait for import to complete

4. **Reconfigure:**
   - Re-enter your Environment Variables
   - Reapply any customizations

## Diagnostic Steps

### Check Browser Console for Errors

1. Open the Setup Wizard app
2. Press **F12** to open Developer Tools
3. Go to the **Console** tab
4. Look for red error messages, particularly:
   - "Failed to load resource"
   - "PCF control initialization failed"
   - "Component not found"
   - JavaScript errors related to "PowerCAT" or "cat_PowerCAT"

### Check Network Tab

1. In Developer Tools, go to **Network** tab
2. Refresh the page
3. Look for:
   - Failed requests (shown in red)
   - 404 errors (resources not found)
   - Blocked resources

### Verify Component Library Version

1. Go to **Solutions** in Power Platform
2. Find the **PowerCAT Component Library** solution
3. Note the version number
4. Compare with the CoE Starter Kit requirements in the documentation
5. If versions don't match, update the appropriate solution

## Prevention

To avoid this issue in the future:

1. **Always install required components first:**
   - Power Platform Creator Kit (PowerCAT)
   - All dependencies listed in the CoE Starter Kit installation guide

2. **Keep solutions updated together:**
   - When updating CoE Starter Kit, check if Creator Kit also needs updating
   - Review release notes for dependency changes

3. **Test in a non-production environment first:**
   - Import and test new versions in DEV/TEST environments
   - Verify all components load correctly before deploying to production

4. **Document your environment:**
   - Keep a list of all installed solutions and their versions
   - Note any customizations or configurations
   - Maintain an installation checklist

## Additional Resources

- [CoE Starter Kit Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Power Platform Creator Kit](https://github.com/microsoft/powercat-creator-kit)
- [PCF Controls Documentation](https://learn.microsoft.com/power-apps/developer/component-framework/overview)
- [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

## Still Having Issues?

If the above solutions don't resolve your issue:

1. **Gather diagnostic information:**
   - Browser version and name
   - CoE Starter Kit version
   - Creator Kit version (if installed)
   - Console error messages
   - Network tab errors
   - Screenshot of the issue

2. **Report the issue:**
   - Go to [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
   - Check if a similar issue already exists
   - Create a new issue with all diagnostic information
   - Use the bug report template

3. **Community Support:**
   - Post in [Power Platform Community Forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
   - Tag your post with "CoE Starter Kit" and "Setup Wizard"
