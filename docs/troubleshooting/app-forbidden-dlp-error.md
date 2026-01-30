# AppForbidden Error in CoE Admin Command Center

## Issue Description

When opening the **CoE Flows** section (or other custom pages) in the CoE Admin Command Center app, users may encounter an "App forbidden" error with the following message:

```
Error Code: AppForbidden
Something went wrong

It looks like this app isn't compliant with the latest data loss prevention policies.
UriError: It looks like this app isn't compliant with the latest data loss prevention policies. 
at s (http://[your-org].crm[X].dynamics.com/uclient/scripts/app.js?v=1.4.11378-2512.4:38:2323)
```

### Affected Components

This error typically affects:
- CoE Admin Command Center - CoE Flows page
- CoE Admin Command Center - Other custom pages
- Any Canvas Apps that use custom pages with external script loading

## Root Cause

This error occurs when:

1. **Data Loss Prevention (DLP) policies are configured** in your Power Platform environment
2. **The DLP policy blocks external domains** that the custom page needs to load scripts from
3. **Custom pages load scripts dynamically** from your Dataverse environment URL (e.g., `*.crm.dynamics.com`, `*.crm11.dynamics.com`, etc.)

### Technical Details

Custom pages in Power Apps (formerly called "Canvas Pages" in Model-Driven Apps) load client-side scripts from the Dataverse environment URL. When a DLP policy is configured to block external domains or has strict content security policy settings, these script loads are blocked, causing the AppForbidden error.

## Resolution

### Option 1: Configure DLP Policy to Allow Dataverse Domains (Recommended)

The recommended solution is to configure your DLP policy to allow the necessary Dataverse domains:

1. **Navigate to Power Platform Admin Center**
   - Go to https://admin.powerplatform.microsoft.com
   - Sign in with an account that has Power Platform Administrator or Global Administrator role

2. **Open Data Policies**
   - In the left navigation, select **Policies** → **Data policies**
   - Find and select the DLP policy that applies to your CoE environment

3. **Review Connector Configuration**
   - Ensure the following connectors are in the **Business** data group (or the same group):
     - Microsoft Dataverse
     - HTTP with Azure AD
     - Office 365 Outlook (if using email features)
     - Power Automate Management
   
4. **Configure Content Security Policy Settings**
   
   If your tenant has advanced DLP settings enabled, you may need to allow the Dataverse domain:
   
   - In the DLP policy settings, look for **Connector endpoint filtering** or **Content security policy** settings
   - Add the following domains to the allowlist:
     - `*.dynamics.com`
     - `*.crm.dynamics.com`
     - `*.crm[X].dynamics.com` (where X is your region number, e.g., crm11.dynamics.com)
     - `*.powerapps.com`
   
   **Note**: The exact location of these settings may vary depending on your tenant configuration and whether you have preview features enabled.

5. **Save and Wait for Propagation**
   - Save the DLP policy changes
   - Wait 5-10 minutes for the policy to propagate across the environment
   - Clear your browser cache
   - Try accessing the CoE Admin Command Center again

### Option 2: Exempt the CoE Environment from DLP Policy

If the CoE environment is used exclusively for administrative purposes and doesn't contain business data:

1. **Navigate to Power Platform Admin Center**
   - Go to https://admin.powerplatform.microsoft.com
   - Select **Policies** → **Data policies**

2. **Edit the DLP Policy Scope**
   - Open the DLP policy that's causing the issue
   - Go to the **Scope** section
   - Under **Environment scope**, change from "All environments" to "Add environments" or "Exclude environments"
   - Exclude your CoE environment from this policy

3. **Apply a Less Restrictive DLP Policy** (Optional)
   - Create a separate DLP policy specifically for the CoE environment with the necessary connectors allowed
   - Ensure connectors like Dataverse, HTTP with Azure AD, and Office 365 Outlook are in the same data group

### Option 3: Use Alternative Tools for CoE Flow Management

If modifying DLP policies is not feasible:

1. **Use the CoE Setup and Upgrade Wizard** instead
   - Navigate directly to the CoE Setup and Upgrade Wizard app
   - This app may have different DLP requirements

2. **Use Power Automate Portal Directly**
   - Access flows directly through https://make.powerautomate.com
   - Navigate to your CoE environment
   - Filter flows by solution: "Center of Excellence - Core Components"

3. **Use PowerShell for Flow Management**
   - Use the Power Platform PowerShell cmdlets to manage CoE flows
   - Example commands:
     ```powershell
     # Install the Power Platform module
     Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
     
     # Connect to your tenant
     Add-PowerAppsAccount
     
     # Get flows in the CoE environment
     Get-AdminFlow -EnvironmentName [YourCoEEnvironmentId]
     ```

## Verification Steps

After applying the resolution:

1. **Clear Browser Cache**
   - Press Ctrl+Shift+Delete (or Cmd+Shift+Delete on Mac)
   - Select "All time" or "Everything"
   - Clear cached images and files
   - Restart your browser

2. **Test in InPrivate/Incognito Mode**
   - Open a new InPrivate/Incognito browser window
   - Navigate to https://make.powerapps.com
   - Open the CoE Admin Command Center app
   - Click on **CoE Flows** section

3. **Verify No Error Appears**
   - The page should load without the "AppForbidden" error
   - You should see the list of CoE flows

## Prevention

To prevent this issue in the future:

1. **Document DLP Policy Requirements**
   - Maintain documentation of connector and domain requirements for the CoE Starter Kit
   - Include these requirements in your DLP policy design

2. **Test DLP Changes in a Non-Production Environment First**
   - Before applying DLP policies to production, test in a development environment
   - Verify all CoE apps and flows function correctly

3. **Coordinate with Security Team**
   - Work with your security and compliance teams when configuring DLP policies
   - Explain the business need for the CoE Starter Kit to have specific connector access

4. **Review Release Notes**
   - When upgrading the CoE Starter Kit, review release notes for new connector or domain requirements
   - Update DLP policies before or immediately after upgrade

## Related Documentation

- **CoE Starter Kit Setup Prerequisites**: https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites
- **DLP Policies Documentation**: https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention
- **Connector Classification**: https://learn.microsoft.com/power-platform/admin/dlp-connector-classification
- **CoE Starter Kit FAQ**: https://learn.microsoft.com/power-platform/guidance/coe/faq

## Getting Help

If the above solutions don't resolve your issue:

1. **Check the GitHub Issues**
   - Search for similar issues: https://github.com/microsoft/coe-starter-kit/issues
   - Look for issues tagged with `dlp` or `AppForbidden`

2. **Report a New Issue**
   - Use the bug report template: https://github.com/microsoft/coe-starter-kit/issues/new/choose
   - Include:
     - CoE Starter Kit version
     - DLP policy configuration (without sensitive details)
     - Screenshot of the error
     - Browser console errors (F12 → Console tab)

3. **Contact Microsoft Support**
   - For DLP policy configuration questions
   - For platform-level issues with custom pages
   - Open a support ticket via the Power Platform Admin Center

---

**Issue Type**: Configuration / DLP Policy  
**Affected Versions**: 4.50.x and later (custom pages introduced)  
**Resolution Complexity**: Moderate (requires DLP policy access)  
**Last Updated**: January 2026
