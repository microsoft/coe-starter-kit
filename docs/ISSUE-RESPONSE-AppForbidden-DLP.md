# GitHub Issue Response Template - AppForbidden Error with DLP Policies

This template can be used when responding to issues related to "App forbidden" errors in the CoE Admin Command Center or other Canvas Apps with custom pages.

---

## Template: AppForbidden Error in CoE Admin Command Center

**Use when:** Users report "App forbidden" or "AppForbidden" errors when opening CoE Admin Command Center sections, particularly the CoE Flows page or other custom pages.

**Response:**

Thank you for reporting this issue! The "App forbidden" error you're experiencing is typically caused by Data Loss Prevention (DLP) policies blocking the scripts that custom pages need to load from your Dataverse environment.

### What's Happening

The CoE Admin Command Center uses **custom pages** (Canvas Pages) for sections like "CoE Flows", "Environment Variables", etc. These custom pages need to load JavaScript files from your Dataverse environment URL (e.g., `*.crm.dynamics.com` or `*.crm11.dynamics.com`). 

When a DLP policy is configured to block external domains or has strict content security settings, these script loads are prevented, resulting in the "AppForbidden" error you're seeing.

### Resolution Steps

We've created a comprehensive troubleshooting guide for this issue:

📖 **[AppForbidden Error with DLP Policies - Troubleshooting Guide](../docs/troubleshooting/app-forbidden-dlp-error.md)**

**Quick Summary:**

1. **Configure DLP Policy to Allow Dataverse Domains** (Recommended):
   - Navigate to Power Platform Admin Center → Policies → Data policies
   - Edit the DLP policy that applies to your CoE environment
   - Ensure these connectors are in the **same data group**:
     - Microsoft Dataverse
     - HTTP with Azure AD
     - Office 365 Outlook
     - Power Automate Management
   - If your policy has advanced settings, add these domains to the allowlist:
     - `*.dynamics.com`
     - `*.crm.dynamics.com`
     - `*.powerapps.com`

2. **Alternative: Exempt CoE Environment from DLP Policy**:
   - If the CoE environment is used exclusively for administration
   - Edit the DLP policy scope to exclude your CoE environment
   - Create a separate, less restrictive policy for the CoE environment

3. **Workaround: Use Alternative Tools**:
   - Access flows directly via https://make.powerautomate.com
   - Use PowerShell cmdlets for flow management
   - Use the CoE Setup and Upgrade Wizard app instead

### After Making Changes

1. Clear your browser cache completely
2. Wait 5-10 minutes for DLP policy changes to propagate
3. Try accessing the CoE Admin Command Center again in an InPrivate/Incognito window

### Need More Help?

If the above solutions don't resolve your issue, please provide:
- Your CoE Starter Kit version (e.g., 4.50.8)
- Whether you have DLP policies configured in your tenant
- Whether you have permissions to modify DLP policies
- Browser console errors (Press F12 → Console tab, take a screenshot)

The detailed troubleshooting guide above includes additional options and technical details.

---

## Template: Closing Issue - AppForbidden Resolved

**Use when:** Closing an issue after confirming the DLP resolution worked

**Response:**

I'm glad to hear the DLP policy configuration resolved the issue! 

### Summary

The "App forbidden" error was caused by DLP policies blocking the Dataverse domain scripts needed by custom pages. By configuring the DLP policy to allow `*.dynamics.com` domains and ensuring the required connectors were in the same data group, the CoE Admin Command Center custom pages can now load successfully.

### For Future Reference

- **Troubleshooting Guide**: [AppForbidden Error with DLP Policies](../docs/troubleshooting/app-forbidden-dlp-error.md)
- **DLP Best Practices**: Consider documenting DLP requirements for the CoE Starter Kit in your organization's setup documentation
- **Before Upgrades**: Review release notes for new connector or domain requirements

### If You Encounter Issues Again

1. Check if DLP policies have been updated
2. Verify all required connectors are still in the same data group
3. Clear browser cache after any policy changes
4. Review the troubleshooting guide for additional solutions

Thank you for using the CoE Starter Kit! 🎉

---

## Template: Request for More Information

**Use when:** User reports AppForbidden error but doesn't provide enough details

**Response:**

Thank you for reporting this issue. To help us diagnose the "App forbidden" error, could you please provide the following information:

### Required Information

1. **CoE Starter Kit Version**
   - What version of the Core Components are you using? (e.g., 4.50.8)
   - Can you confirm this by going to Power Apps → Solutions → "Center of Excellence - Core Components" → Version

2. **Error Details**
   - Can you provide a screenshot of the full error message?
   - If possible, press F12 in your browser → Console tab → take a screenshot of any errors shown

3. **DLP Policy Information**
   - Do you have Data Loss Prevention (DLP) policies configured in your tenant?
   - Do you have permissions to view/modify DLP policies?
   - Have any DLP policies been recently updated or created?

4. **Environment Details**
   - Which section of the CoE Admin Command Center are you trying to access? (e.g., CoE Flows, Environment Variables, etc.)
   - Have other users reported the same issue?
   - Can you access other sections of the CoE Admin Command Center successfully?

### Temporary Workaround

While we investigate, you can try accessing the flows directly:
1. Go to https://make.powerautomate.com
2. Select your CoE environment from the environment picker
3. Navigate to Solutions → "Center of Excellence - Core Components"
4. Click on the "Flows" tab to manage CoE flows

### Background

The error you're experiencing is commonly related to DLP policies blocking custom page scripts. We have a detailed troubleshooting guide that may help:

📖 [AppForbidden Error with DLP Policies - Troubleshooting Guide](../docs/troubleshooting/app-forbidden-dlp-error.md)

Please review the guide and let us know if it resolves your issue or if you need additional assistance.

---

## Notes for Responders

### Key Indicators of AppForbidden/DLP Issue

- Error message contains "AppForbidden" or "App forbidden"
- Error mentions "data loss prevention policies"
- Error references script URLs from `*.dynamics.com` or `*.crm.dynamics.com`
- Issue occurs specifically with custom pages in Model-Driven Apps
- Issue started after DLP policy changes

### Common Causes

1. **DLP Policy Blocking External Domains**: Most common cause
2. **Connectors in Different DLP Groups**: Dataverse, HTTP with Azure AD, etc. not in same group
3. **Content Security Policy Settings**: Advanced DLP settings blocking specific domains
4. **Endpoint Filtering**: DLP policy has connector endpoint filtering enabled

### Quick Diagnostic Questions

- "Do you have DLP policies configured in your tenant?"
- "Have any DLP policies been updated recently?"
- "Can you access other sections of the CoE Admin Command Center?"
- "Does the error occur for all users or just specific ones?"

### Escalation Criteria

Escalate or request Microsoft Support when:
- User has confirmed DLP policies are correctly configured but issue persists
- Issue appears to be a platform-level regression
- Error occurs even without DLP policies configured
- Custom pages fail to load in multiple different environments with different DLP configurations

---

**Template Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
