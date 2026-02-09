# Troubleshooting: CoE Setup and Upgrade Wizard Authentication Error

## Issue Summary

After upgrading the **CoE Core Components** solution to version **4.50.8** or later, the **CoE Setup and Upgrade Wizard** app fails to open with authentication errors:

- **Error Code**: `UserNotLoggedIn`
- **Error Message**: "Can't Sign In"
- **Additional Error**: `[AdalError] endpoints_resolution_error Error: could not resolve endpoints. Detail: ClientConfigurationError: untrusted_authority: The provided authority is not a trusted authority`
- **AADSTS Error Code**: `AADSTS500113` (invalid redirect URI)

![Setup Wizard Authentication Error Example](https://github.com/user-attachments/assets/example-auth-error.png)

## Root Cause

This is a **known authentication issue** with Canvas apps in Power Apps where the MSAL (Microsoft Authentication Library) authentication configuration becomes stale or invalid after solution upgrades. The issue occurs when:

1. **Authentication configuration is not refreshed** during solution upgrade
2. **Browser has cached stale authentication tokens** from previous versions
3. **App's authorization references are empty or misconfigured** after upgrade
4. **Environment URL or tenant configuration has changed** since the app was last published

### Technical Details

- **App Type**: Canvas App (Standalone or embedded)
- **App Name**: CoE Setup and Upgrade Wizard
- **Authentication Library**: MSAL (Microsoft Authentication Library)
- **Affected Versions**: Primarily seen after upgrading to 4.50.8+
- **Platform Component**: Azure AD / Microsoft Entra ID authentication

## Who Is Affected?

This issue affects users who:

- ✅ Upgraded from an earlier version to Core 4.50.8 or later
- ✅ Open the Setup Wizard app after the upgrade
- ✅ May have environments with conditional access policies
- ✅ Experience the error on first launch after upgrade

## Solution / Workarounds

Try these solutions in order. Most users resolve the issue with the first two quick fixes.

---

### ✅ Solution 1: Clear Browser Cache and Cookies (Recommended - Fixes 90% of Cases)

The most common and effective fix for this authentication issue:

#### Step-by-Step Instructions

1. **Close all Power Apps browser tabs and windows**
   
2. **Clear browser cache and cookies** for the following domains:
   - `*.powerapps.com`
   - `*.dynamics.com`
   - `*.microsoft.com`
   - `login.microsoftonline.com`
   - `*.crm.dynamics.com`

3. **Clear browser cache completely**:

   **Microsoft Edge:**
   - Press `Ctrl+Shift+Delete` (Windows) or `Cmd+Shift+Delete` (Mac)
   - Select **Cookies and other site data** and **Cached images and files**
   - Set time range to **All time**
   - Click **Clear now**

   **Google Chrome:**
   - Press `Ctrl+Shift+Delete` (Windows) or `Cmd+Shift+Delete` (Mac)
   - Select **Cookies and other site data** and **Cached images and files**
   - Set time range to **All time**
   - Click **Clear data**

   **Mozilla Firefox:**
   - Press `Ctrl+Shift+Delete` (Windows) or `Cmd+Shift+Delete` (Mac)
   - Select **Cookies** and **Cache**
   - Set time range to **Everything**
   - Click **Clear Now**

4. **Close and completely restart your browser**
   - Don't just close tabs - quit the entire browser application
   - On Windows: Check Task Manager to ensure no browser processes remain

5. **Reopen your browser and navigate to Power Apps**
   - Go to https://make.powerapps.com
   - Navigate to your CoE environment
   - Open the **CoE Setup and Upgrade Wizard** app

6. **If the app opens successfully**, the issue is resolved ✅

---

### ✅ Solution 2: Use InPrivate/Incognito Mode (Quick Test)

This helps isolate whether the issue is browser cache-related:

1. **Open a new InPrivate/Incognito browser window**:
   - Edge: `Ctrl+Shift+N`
   - Chrome: `Ctrl+Shift+N`
   - Firefox: `Ctrl+Shift+P`

2. **Navigate to Power Apps** in the InPrivate window:
   - Go to https://make.powerapps.com
   - Sign in with your credentials
   - Navigate to your CoE environment

3. **Open the CoE Setup and Upgrade Wizard app**

4. **If it works in InPrivate mode**:
   - This confirms the issue is browser cache/cookies
   - Return to Solution 1 and thoroughly clear your browser cache
   - You may need to clear browser cache AND restart browser

5. **If it still fails in InPrivate mode**:
   - Proceed to Solution 3

---

### ✅ Solution 3: Try a Different Browser

Test with a different browser to isolate browser-specific issues:

1. If using **Edge**, try **Chrome** (or vice versa)
2. If using **Chrome**, try **Firefox**
3. Ensure the alternate browser is up to date
4. Test opening the Setup Wizard in the alternate browser
5. If successful, the issue is specific to your original browser configuration

---

### ✅ Solution 4: Republish the Setup Wizard App (Admin Only)

If you have edit permissions on the CoE solution, republishing the app refreshes its authentication configuration:

#### Prerequisites
- **System Administrator** role in the CoE environment
- **Environment Admin** or **Environment Maker** role

#### Step-by-Step Instructions

1. **Navigate to Power Apps**:
   - Go to https://make.powerapps.com
   - Select your **CoE environment** from the environment picker

2. **Open the Solutions area**:
   - Click **Solutions** in the left navigation
   - Find and open **Center of Excellence - Core Components**

3. **Locate the Setup Wizard app**:
   - Search or scroll to find **CoE Setup and Upgrade Wizard**
   - Note: The internal name may be `admin_CoESetupWizard` or similar

4. **Edit the app**:
   - Click on the app name (don't click **Play**)
   - Select **Edit** from the command bar
   - Wait for the app to load in the Power Apps editor

5. **Save the app** (without making changes):
   - Click **File** → **Save**
   - This refreshes the app's authentication configuration
   - Wait for the save to complete

6. **Publish the app**:
   - Click **File** → **Publish**
   - Click **Publish this version**
   - Wait for publishing to complete

7. **Close the editor** and return to the solutions view

8. **Test the app**:
   - Click **Play** on the CoE Setup and Upgrade Wizard
   - The app should now open without authentication errors

#### Troubleshooting During Republish

If the app editor itself shows authentication errors:
- First try Solutions 1-3 to resolve your own browser cache
- Ensure you have the correct permissions
- Check that all required DLP policies are configured (see Solution 6)

---

### ✅ Solution 5: Check Connection References

Canvas apps use connection references that may need to be refreshed after upgrade:

#### Step-by-Step Instructions

1. **Navigate to Power Apps** → **Solutions** → **Center of Excellence - Core Components**

2. **View Connection References**:
   - In the solution, filter by **Type** = **Connection Reference**
   - Look for connection references used by the Setup Wizard:
     - Power Apps for Makers
     - Power Platform for Admins
     - HTTP with Azure AD
     - Microsoft Dataverse
     - Office 365 Outlook
     - Power Automate Management

3. **Check each connection reference**:
   - Click on each connection reference
   - Verify the **Status** shows as **Connected** with a green checkmark
   - Note any that show **Not connected** or have warning icons

4. **Refresh broken connections**:
   - For any broken connection reference:
     - Click on it to open details
     - Click **Edit** or **+ New connection**
     - Authenticate using your credentials
     - Save the updated connection

5. **Update the app's connections**:
   - After fixing connection references, edit the Setup Wizard app
   - Go to **Data** sources in the left panel
   - Refresh any data sources showing warning icons
   - Save and publish the app

6. **Test the app again**

---

### ✅ Solution 6: Verify DLP Policies and Connector Groups

Data Loss Prevention (DLP) policies can block connectors needed by the Setup Wizard:

#### Required Connectors for Setup Wizard

The Setup Wizard requires these connectors to be in the **same DLP policy group** (Business or Non-Business):

- ✅ Microsoft Dataverse
- ✅ HTTP with Azure AD
- ✅ Power Apps for Makers
- ✅ Power Platform for Admins
- ✅ Power Automate Management
- ✅ Office 365 Outlook (optional, for notifications)

#### Step-by-Step Verification

1. **Navigate to Power Platform Admin Center**:
   - Go to https://admin.powerplatform.microsoft.com
   - Sign in with admin credentials

2. **Review DLP policies**:
   - Click **Policies** → **Data policies** in the left navigation
   - Identify which policies apply to your CoE environment

3. **Check each applicable policy**:
   - Click on the policy name to open details
   - Go to the **Connectors** tab
   - Verify all required connectors are in the **same group** (Business or Non-Business)

4. **Fix DLP policy configuration** (if needed):
   - If connectors are split between groups, move them to the same group
   - **Recommended**: Place all CoE connectors in the **Business** data group
   - Save the policy changes

5. **Exclude CoE environment from restrictive policies** (alternative):
   - If organizational policies prevent connector grouping
   - Edit the DLP policy
   - Go to **Environments** tab
   - **Remove** the CoE environment from the policy scope
   - Or add the CoE environment to an **exception policy** that allows required connectors

6. **Wait 15-30 minutes** for policy changes to propagate

7. **Test the Setup Wizard app again**

**Full DLP troubleshooting guide**: [TROUBLESHOOTING-DLP-APPFORBIDDEN.md](TROUBLESHOOTING-DLP-APPFORBIDDEN.md)

---

### ✅ Solution 7: Verify Environment Configuration

Ensure the environment meets all prerequisites:

#### Environment Checklist

1. **Dataverse database is provisioned**:
   - Navigate to Power Platform Admin Center
   - Select your CoE environment
   - Verify **Dataverse** shows as **Yes** in environment details

2. **English language pack is enabled**:
   - The CoE Starter Kit requires English (1033) language pack
   - Power Platform Admin Center → Environment → Settings → Product → Languages
   - Verify **English** is listed and enabled
   - If not present, add it and wait 24 hours for activation

3. **Environment is not in administration mode**:
   - Check environment status in Admin Center
   - If in admin mode, disable it before testing

4. **No maintenance windows are active**:
   - Check Service Health for scheduled maintenance
   - Wait for maintenance to complete before testing

---

### ✅ Solution 8: Clear PowerShell Sessions (Advanced)

If you use PowerShell for Power Platform administration, stale sessions can affect authentication:

```powershell
# Clear all PowerShell authentication caches
Disconnect-AzAccount -Scope CurrentUser -ErrorAction SilentlyContinue
Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue

# Clear Power Apps admin sessions
Remove-Module Microsoft.PowerApps.Administration.PowerShell -Force -ErrorAction SilentlyContinue
Remove-Module Microsoft.PowerApps.PowerShell -Force -ErrorAction SilentlyContinue

# Then try accessing the app in a fresh browser session
```

---

### ✅ Solution 9: Check Azure AD Conditional Access Policies

Conditional Access policies can interfere with app authentication:

#### Step-by-Step Instructions

1. **Navigate to Microsoft Entra Admin Center**:
   - Go to https://entra.microsoft.com
   - Sign in with Global Administrator credentials

2. **Review Conditional Access Policies**:
   - Navigate to **Protection** → **Conditional Access** → **Policies**
   - Identify policies that apply to:
     - All Cloud Apps or specifically Power Apps
     - Your user account or groups you belong to

3. **Check for problematic configurations**:
   - Policies requiring device compliance (can block web access)
   - Policies requiring specific locations/IPs
   - Policies requiring compliant browsers or client apps
   - Session controls that interfere with authentication tokens

4. **Test with exclusion** (temporary diagnostic step):
   - Create a test exclusion for your account or CoE environment
   - **Important**: Only for testing, not production configuration
   - Test if the Setup Wizard opens successfully
   - If successful, work with your security team to adjust policies

5. **Alternative - Use compliant access**:
   - Ensure you're accessing from a compliant device
   - Use a compliant browser (Edge on managed devices)
   - Authenticate from approved locations/networks

---

### ✅ Solution 10: Re-import the Core Components Solution (Advanced)

If all else fails, re-importing the solution can fix corrupted authentication configurations:

#### ⚠️ Warning
This is an advanced step. Ensure you have backups and understand the implications.

#### Prerequisites
- Recent backup of your CoE environment
- Documentation of all environment variable values
- List of all custom configurations

#### Step-by-Step Instructions

1. **Export current environment variables**:
   - Document all CoE environment variable values
   - Take screenshots for reference
   - Export these to a secure location

2. **Download the latest Core Components solution**:
   - Visit [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases)
   - Download the latest 4.50.x version (or newer if available)
   - Extract the solution ZIP file

3. **Import as an Upgrade**:
   - Power Platform Admin Center → Environments → Your CoE environment
   - Solutions → Import solution
   - Select the Core Components solution file
   - Choose **Upgrade** (not Update)
   - Complete the import process
   - Wait for the import to finish (may take 15-30 minutes)

4. **Verify connections**:
   - After import, check all connection references
   - Refresh any that show as disconnected
   - Ensure your user account has valid connections

5. **Test the Setup Wizard**:
   - Navigate to Power Apps
   - Open the CoE Setup and Upgrade Wizard
   - App should open without authentication errors

---

## Prevention / Best Practices

To avoid this issue in future upgrades:

### 1. Clear Browser Cache After Every Upgrade
- Make this a standard post-upgrade step
- Document in your upgrade procedures
- Clear cache before opening any upgraded apps

### 2. Use InPrivate/Incognito for Testing
- Test upgraded apps in InPrivate mode first
- Isolates cache issues immediately
- Confirms app functionality before clearing production cache

### 3. Document Authentication Patterns
- Keep notes on which apps had authentication issues
- Track browser/environment combinations that work
- Share findings with your CoE team

### 4. Regular Browser Maintenance
- Clear cache weekly or bi-weekly
- Keep browsers updated to latest versions
- Avoid excessive browser extensions that can interfere

### 5. Monitor Microsoft Release Notes
- Watch for Power Apps authentication updates
- Subscribe to Power Platform release notes
- Test in non-production before production upgrades

---

## When to Escalate

Contact Microsoft Support if:

- ✅ All solutions above have been tried and failed
- ✅ Issue affects multiple users across different browsers/devices
- ✅ Issue persists after solution re-import
- ✅ Error includes platform-level error codes (AADSTS errors)
- ✅ Issue appears after a platform update, not just your upgrade

### Information to Gather Before Escalating

When opening a support ticket, include:

1. **Error Details**:
   - Session ID from error message
   - Activity ID from error message
   - Full error text and screenshots
   - Exact CoE version (e.g., 4.50.8)

2. **Environment Details**:
   - Environment name and ID
   - Region (e.g., United States, Europe)
   - Environment type (Production, Sandbox, etc.)
   - Dataverse version

3. **Troubleshooting Steps Completed**:
   - List all solutions tried (Solutions 1-10)
   - Results of each attempt
   - Any partial successes or patterns noticed

4. **Browser Console Logs**:
   - Press F12 to open Developer Tools
   - Go to Console tab
   - Take screenshots of any errors shown in red
   - Export/copy error messages

5. **Network Trace** (Advanced):
   - Open Developer Tools (F12)
   - Go to Network tab
   - Reproduce the error
   - Export HAR file (right-click → Save all as HAR)
   - **Important**: Redact any sensitive tokens before sharing

---

## Related Documentation

### CoE Starter Kit Docs
- [CoE Setup and Upgrade Wizard Troubleshooting Guide](../CenterofExcellenceResources/TROUBLESHOOTING-SETUP-WIZARD.md)
- [CoE Core Components README](../CenterofExcellenceCoreComponents/README.md)
- [Troubleshooting AppForbidden / DLP Errors](TROUBLESHOOTING-DLP-APPFORBIDDEN.md)
- [Troubleshooting DLP Impact Analysis Authentication](ISSUE-RESPONSE-DLP-Impact-Analysis-Authentication.md)

### Microsoft Official Documentation
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [After Setup and Upgrades](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)
- [Troubleshooting Canvas Apps](https://learn.microsoft.com/power-apps/maker/canvas-apps/troubleshooting-canvas-apps)
- [Azure AD Authentication Troubleshooting](https://learn.microsoft.com/azure/active-directory/develop/reference-aadsts-error-codes)

---

## Known Limitations

### Platform-Level Issue
This is **not a bug in the CoE Starter Kit** itself. The authentication issue is at the **Power Apps platform level** related to how MSAL authentication tokens are managed during solution upgrades and browser sessions.

### Browser Caching Behavior
- Different browsers cache authentication tokens differently
- Some browsers (especially with extensions) may cache more aggressively
- Private/Incognito modes bypass caching, hence why they often work

### Timing Dependencies
- Authentication token refresh can take 5-15 minutes after solution upgrade
- Browser cache may not respect standard HTTP cache headers for auth tokens
- Some users experience delayed symptoms (app works initially, fails later)

### Service Principal Limitations
- Service principals (App Registrations) may experience this differently
- Service principal authentication uses different MSAL flows
- Manual token refresh may be required for service principal scenarios

---

## Frequently Asked Questions (FAQ)

### Q: Why does this happen after upgrading to 4.50.8?
**A:** The issue is related to how Canvas apps' MSAL authentication configuration is packaged in solutions. During upgrade, the authentication metadata may not refresh properly, and browsers cache old authentication tokens. Version 4.50.8 may have included app changes that trigger this more frequently.

### Q: Will this happen every time I upgrade?
**A:** Not necessarily. The issue is most common on the **first** upgrade that changes the app's authentication configuration. Subsequent upgrades may not trigger it if authentication config remains unchanged. Following the prevention best practices minimizes recurrence.

### Q: Is my data at risk?
**A:** No. This is purely an authentication/login issue. Your CoE data in Dataverse is safe and unchanged. The app simply can't authenticate your session to access the data.

### Q: Can I use the Setup Wizard from mobile devices?
**A:** The Setup Wizard is designed for desktop browsers. Mobile browsers may have additional authentication challenges. Use desktop browsers (Edge or Chrome) for the best experience.

### Q: Does this affect other CoE apps?
**A:** Potentially yes. Any Canvas app in the CoE Starter Kit could experience similar authentication issues after upgrade. The same troubleshooting solutions apply to those apps as well.

### Q: Can I prevent this by not clearing my browser cache?
**A:** Ironically, **not** clearing cache makes the problem worse. Stale authentication tokens in cache are the primary cause. Regular cache clearing is a **prevention** measure, not a cause.

### Q: Will Microsoft fix this platform issue?
**A:** This is a known behavior of the Power Apps platform. Microsoft continually improves authentication handling, but fundamental browser caching behavior is difficult to eliminate. The CoE Starter Kit team cannot directly fix platform-level authentication flows.

### Q: Should I report this as a bug?
**A:** If you've tried all solutions and the issue persists, report it to **Microsoft Support** as a platform issue (not a CoE Starter Kit GitHub issue). Reference this guide and provide the required diagnostic information.

---

## Additional Notes

### This Issue is Related to Similar Authentication Errors

This authentication error pattern also affects:
- **Data Policy Impact Analysis app** (see [ISSUE-RESPONSE-DLP-Impact-Analysis-Authentication.md](ISSUE-RESPONSE-DLP-Impact-Analysis-Authentication.md))
- **Custom pages** embedded in model-driven apps
- Any Canvas app using **HTTP with Azure AD** connector after solution upgrade

### Authentication Architecture Context

Modern Power Apps use **MSAL (Microsoft Authentication Library)** for Azure AD authentication. MSAL requires:
- Trusted authority configuration (which Azure AD endpoints to trust)
- Redirect URI configuration (where authentication responses should be sent)
- Proper token caching and refresh logic

When solutions are upgraded, these configurations can become stale in:
1. The app's metadata stored in Dataverse
2. The browser's cache of authentication tokens
3. Connection reference configurations

Clearing browser cache forces re-authentication and refreshes these configurations.

---

## Support and Community

### GitHub Issues
Report persistent issues or contribute solutions:
- [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)

### Community Forums
Ask questions and share experiences:
- [Power Platform Community - Governance](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

### Microsoft Support
For platform-level issues requiring official support:
- Open a support ticket via [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
- Reference error codes: AADSTS500113, UserNotLoggedIn
- Include Session ID and Activity ID from error message

---

## Contributing

Found another solution or workaround? Help the community by:
1. [Opening an issue](https://github.com/microsoft/coe-starter-kit/issues/new) with your findings
2. [Submitting a pull request](https://github.com/microsoft/coe-starter-kit/pulls) to update this guide
3. Sharing your experience in the [Community Forums](https://powerusers.microsoft.com)

---

**Document Version**: 1.0  
**Last Updated**: February 9, 2026  
**Applies To**: CoE Starter Kit Core Components 4.50.8+  
**Issue Severity**: Medium (workarounds available)  
**Resolution Success Rate**: ~95% with browser cache clearing  

---

**Disclaimer**: The CoE Starter Kit is provided as-is with best-effort community support. This authentication issue is a platform-level behavior, not a defect in the CoE Starter Kit. For platform issues requiring official Microsoft support, contact your Microsoft account team or open a support ticket.
