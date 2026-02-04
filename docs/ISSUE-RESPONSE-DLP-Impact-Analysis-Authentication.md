# Issue Response: Data Policy Impact Analysis App Authentication Error

## Issue Summary
The **Data Policy Impact Analysis** app in CoE Core 1.7 fails to open with authentication errors:
- Error Code: `UserNotLoggedIn`
- Error Message: `The provided authority is not a trusted authority. Please include this authority in the knownAuthorities config parameter.`
- Additional Error: `ClientConfigurationError: untrusted_authority`

## Root Cause
This is a known issue with **custom pages** (canvas pages embedded in model-driven apps) where the MSAL (Microsoft Authentication Library) authentication configuration fails. The Data Policy Impact Analysis app is a custom page (`CanvasAppType: 2`, `DocumentType: Page`) within a model-driven app.

The error occurs when:
1. The app's `AuthorizationReferences` is empty or not properly configured
2. The browser session has stale authentication tokens
3. The environment has conditional access policies or security restrictions
4. The app needs to be republished to refresh authentication settings

## Technical Details
- **App Type**: Custom Page (Canvas page within model-driven app)
- **App Name**: `admin_dlpimpactanalysis_4dfb8`
- **App Module**: `admin_DLPImpactAnalysis`
- **Creation Source**: `AppFromConvergedAppDesigner`
- **Client Type**: 4 (Unified Interface)

## Solution / Workarounds

### Quick Fixes (Try in Order)

#### 1. Clear Browser Cache and Cookies
The most common fix for this authentication issue:

1. Close all Power Apps browser tabs
2. Clear your browser cache and cookies for:
   - `powerapps.com`
   - `dynamics.com`
   - `microsoft.com`
   - `login.microsoftonline.com`
3. Close and restart your browser
4. Log back in to Power Apps and try opening the app again

**PowerShell Alternative** (clear all sessions):
```powershell
# Clear all PowerShell sessions
Disconnect-AzAccount -Scope CurrentUser
Clear-AzContext -Scope CurrentUser

# Then try accessing the app in a fresh browser session
```

#### 2. Use InPrivate/Incognito Mode
1. Open a new InPrivate/Incognito browser window
2. Navigate to your Power Platform environment
3. Open the Data Policy Impact Analysis app
4. If it works, this confirms a browser cache/session issue

#### 3. Try a Different Browser
Test with a different browser (Edge, Chrome, Firefox) to isolate browser-specific issues.

### Advanced Fixes

#### 4. Refresh the App (Admin)
If you have admin access to the solution:

1. Open **Power Apps** (https://make.powerapps.com)
2. Navigate to your CoE environment
3. Go to **Solutions** → **Center of Excellence - Core Components**
4. Find the **Data Policy Impact Analysis** app module
5. **Edit** the app
6. **Save** without making changes (this refreshes the app configuration)
7. **Publish** the app
8. Test the app again

#### 5. Recreate App Connections
Custom pages use several connections that may need to be refreshed:

1. Open **Power Apps** → **Solutions** → **Center of Excellence - Core Components**
2. Find the canvas app: `admin_dlpimpactanalysis_4dfb8`
3. **Edit** the app
4. Review **Data** sources and ensure all connections are active:
   - Power Apps for Makers
   - Power Platform for Admins
   - Power Apps for Admins
   - Office 365 Outlook
   - Microsoft Dataverse
5. If any connection shows as "Not connected", refresh it
6. **Save** and **Publish**

#### 6. Check Environment Security Settings
Verify that your environment doesn't have overly restrictive security settings:

1. Check **Conditional Access Policies** in Azure AD
2. Verify **Power Platform DLP policies** don't block required connectors
3. Ensure the user has appropriate **security roles**:
   - CoE Admin role
   - Environment Admin or System Administrator

#### 7. Upgrade to Latest Version
If you're using CoE Core 1.7, consider upgrading to the latest version which may include fixes for this issue:

1. Review the [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases)
2. Follow the [Upgrade Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
3. Test the app after upgrade

### Alternative: Use Direct URL
If the app still won't open from the app module, try accessing it directly:

1. Get the app's direct URL from the solution
2. Navigate to: `https://[your-org].crm.dynamics.com/main.aspx?pagetype=custom&name=admin_dlpimpactanalysis_4dfb8`
3. Replace `[your-org]` with your organization's URL

## Prevention
To prevent this issue in the future:

1. **Regular Browser Maintenance**: Clear cache periodically
2. **Keep Solutions Updated**: Apply updates to CoE Starter Kit regularly
3. **Monitor Authentication**: Watch for authentication errors in app checker
4. **Test After Upgrades**: Always test custom pages after environment/solution upgrades

## Related Documentation
- [CoE Starter Kit - Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Troubleshooting Model-Driven Apps](https://learn.microsoft.com/en-us/power-apps/maker/model-driven-apps/troubleshooting)
- [Custom Pages Overview](https://learn.microsoft.com/en-us/power-apps/maker/model-driven-apps/model-app-page-overview)

## Known Limitations
- Custom pages are relatively new and may have authentication edge cases
- Some browser extensions can interfere with MSAL authentication
- VPN/proxy configurations may cause authentication issues
- Multi-factor authentication (MFA) policies can sometimes conflict with app authentication

## When to Escalate
If none of the above solutions work, this may indicate:
- A deeper Azure AD configuration issue
- Environment corruption requiring Microsoft support
- A bug in the Power Platform requiring a support ticket

In these cases, gather:
- Session ID from error details
- Activity ID from error details
- Screenshots of the error
- Browser console logs (F12 → Console tab)
- Time and date of the error

Then file a support ticket with Microsoft Power Platform Support.

## Additional Notes
This issue is **not specific to the CoE Starter Kit** but is a general issue with custom pages in model-driven apps. The CoE Starter Kit is working as designed; the authentication issue is at the platform level.

---

*Last Updated: January 30, 2026*
*Solution Versions: CoE Core 1.7+*
*Status: Known Issue - Platform Level*
