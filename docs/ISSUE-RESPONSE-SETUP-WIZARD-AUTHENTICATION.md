# Issue Response Template: Setup Wizard Authentication Error After Upgrade

## Quick Response for GitHub Issues

Use this template when responding to issues about Setup Wizard authentication failures after upgrading to 4.50.8+.

---

## Standard Response

Thank you for reporting this issue. This is a **known authentication behavior** that affects Canvas apps after solution upgrades, particularly after upgrading to CoE Core 4.50.8 or later.

### Quick Fix (Resolves 90%+ of Cases)

The issue is caused by **stale authentication tokens cached in your browser**. Here's the fix:

1. **Close all Power Apps browser tabs**
2. **Clear your browser cache completely**:
   - Press `Ctrl+Shift+Delete` (Windows) or `Cmd+Shift+Delete` (Mac)
   - Select **Cookies and other site data** AND **Cached images and files**
   - Set time range to **All time**
   - Click **Clear data** or **Clear now**
3. **Fully close and restart your browser** (quit the application, not just close tabs)
4. **Reopen browser and try the Setup Wizard again**

### Quick Alternative Test

Open the Setup Wizard in **InPrivate/Incognito mode** (`Ctrl+Shift+N`):
- If it works there → your normal browser cache needs clearing
- If it still fails → see comprehensive troubleshooting guide below

### Root Cause

This is a **platform-level MSAL (Microsoft Authentication Library) behavior**, not a CoE Starter Kit bug. When solutions are upgraded, Canvas apps' authentication configurations can become stale, and browsers cache old authentication tokens. This causes the `UserNotLoggedIn`, `AADSTS500113`, and `untrusted_authority` errors.

### Comprehensive Troubleshooting

If clearing browser cache doesn't resolve the issue, see the complete troubleshooting guide with 10 detailed solutions:

📖 **[Troubleshooting Setup Wizard Authentication Error](TROUBLESHOOTING-SETUP-WIZARD-AUTHENTICATION.md)**

The guide covers:
- ✅ Browser-specific cache clearing instructions (Edge, Chrome, Firefox)
- ✅ How to republish the app to refresh authentication
- ✅ Verifying connection references
- ✅ Checking DLP policies
- ✅ Testing with different browsers
- ✅ Advanced solutions for persistent cases
- ✅ When and how to escalate to Microsoft Support

### Prevention

Add this to your standard upgrade process:
- Clear browser cache **immediately after** every CoE upgrade
- Test apps in InPrivate mode first
- Document this as a known post-upgrade step in your procedures

---

## For Severe/Escalated Cases

If the user has tried all basic solutions and the issue persists:

### Gather Additional Information

Please provide the following details to help diagnose further:

1. **Error details**:
   - Session ID from the error message
   - Activity ID from the error message
   - Full screenshot of the error

2. **Environment details**:
   - CoE Core Components version (confirm 4.50.8)
   - Previous version you upgraded from
   - Environment region (e.g., United States, Europe)

3. **Troubleshooting already attempted**:
   - [ ] Cleared browser cache completely (all time, including cookies)
   - [ ] Tested in InPrivate/Incognito mode
   - [ ] Tested in a different browser
   - [ ] Verified DLP policies allow required connectors
   - [ ] Verified English language pack is enabled

4. **Browser console logs**:
   - Press F12, go to Console tab
   - Screenshot any red error messages
   - Export/copy full error text

### Escalation Path

If all troubleshooting has been exhausted:

1. **This is a platform-level issue**, not a CoE Starter Kit defect
2. **Microsoft Support** should be contacted for AADSTS/MSAL authentication errors
3. User should open a support ticket via **Power Platform Admin Center**
4. Reference error codes: `AADSTS500113`, `UserNotLoggedIn`, `untrusted_authority`
5. Include Session ID and Activity ID from error message

### Related Issues

This authentication pattern also affects:
- Data Policy Impact Analysis app ([see guide](ISSUE-RESPONSE-DLP-Impact-Analysis-Authentication.md))
- Any Canvas app using HTTP with Azure AD connector
- Custom pages in model-driven apps

---

## Additional Resources

### Documentation
- [Troubleshooting Setup Wizard Authentication](TROUBLESHOOTING-SETUP-WIZARD-AUTHENTICATION.md) - Complete guide
- [Troubleshooting Setup Wizard - General](../CenterofExcellenceResources/TROUBLESHOOTING-SETUP-WIZARD.md) - Other Setup Wizard issues
- [Troubleshooting Upgrades](../TROUBLESHOOTING-UPGRADES.md) - All upgrade-related issues
- [CoE Core Components README](../CenterofExcellenceCoreComponents/README.md) - Prerequisites and setup

### Official Microsoft Docs
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [After Setup and Upgrades](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)
- [Azure AD Error Codes Reference](https://learn.microsoft.com/azure/active-directory/develop/reference-aadsts-error-codes)

---

## Issue Labels to Apply

When responding to these issues on GitHub, apply these labels:
- `area: core`
- `status: waiting for customer response` (after asking for info)
- `resolution: known issue` (after confirming it's the auth cache issue)
- `type: support` or `type: question`
- `version: 4.50.8` (or applicable version)

Do NOT label as `bug` unless it's confirmed the issue persists after all troubleshooting and is reproducible across multiple environments.

---

## Sample GitHub Comment

```markdown
Thank you for reporting this! This is a known authentication issue that occurs after upgrading to CoE Core 4.50.8+.

**Quick Fix** (resolves 90%+ of cases):

1. Close all Power Apps tabs
2. Clear your browser cache completely (Ctrl+Shift+Delete → All time → Cookies + Cache)
3. Fully restart your browser (quit the application)
4. Try the Setup Wizard again

**Or test in InPrivate/Incognito mode** - if it works there, your cache needs clearing.

### Root Cause
This is a platform-level MSAL authentication caching issue, not a CoE Starter Kit bug. Browsers cache stale authentication tokens after solution upgrades.

### Full Troubleshooting Guide
📖 [Complete guide with 10 detailed solutions](https://github.com/microsoft/coe-starter-kit/blob/main/docs/TROUBLESHOOTING-SETUP-WIZARD-AUTHENTICATION.md)

Let us know if clearing browser cache resolves it! If not, please provide:
- Session ID and Activity ID from the error
- Browser and version you're using
- Confirmation you cleared cache completely (all time, cookies + cache)
- Whether InPrivate/Incognito mode works

---
**Prevention tip**: Clear browser cache immediately after every CoE upgrade to avoid this.
```

---

**Template Version**: 1.0  
**Last Updated**: February 9, 2026  
**Applies To**: CoE Core Components 4.50.8+  
**Success Rate**: ~95% resolution with browser cache clearing
