# CoE Starter Kit - Troubleshooting Guide

This guide provides solutions to common issues encountered when setting up and using the CoE Starter Kit.

## Table of Contents

- [Solution Import Issues](#solution-import-issues)
  - [Connection Timeout During Solution Import](#connection-timeout-during-solution-import)

---

## Solution Import Issues

### Connection Timeout During Solution Import

**Issue**: When importing the CoE Core Components or other solutions, you may encounter a timeout error while loading connections. The error message typically states: "A timeout occurred while loading the connections. Widget ID: [ID]"

![Connection Timeout Error](https://github.com/user-attachments/assets/1a712671-6bec-45ce-9d31-6fd7d7d8a20e)

**Affected Versions**: All versions

**Root Causes**:
1. Power Platform service experiencing temporary issues or high load
2. Browser session timeout or cache issues
3. Network connectivity problems
4. Large number of connections in the solution causing extended load times
5. Environment health or performance issues

**Solutions**:

#### Solution 1: Retry the Import
The most common resolution is to simply retry the import:

1. Click the **"Try again"** button in the error dialog
2. If the button doesn't appear, close the dialog and restart the import process
3. Wait a few minutes before retrying if the issue persists

#### Solution 2: Clear Browser Cache and Cookies
Browser cache issues can cause timeout problems:

1. Clear your browser cache and cookies for `make.powerapps.com` and `*.dynamics.com`
2. Close all browser tabs
3. Open a new browser window in **Incognito/Private mode**
4. Navigate to [make.powerapps.com](https://make.powerapps.com)
5. Attempt the import again

#### Solution 3: Use a Different Browser
Try using a different browser or ensure you're using a supported browser:

- Microsoft Edge (Chromium-based) - **Recommended**
- Google Chrome
- Mozilla Firefox

Ensure your browser is up to date.

#### Solution 4: Check Network Connectivity
1. Ensure you have a stable internet connection
2. Disable VPN if you're using one (unless required by your organization)
3. Try from a different network if possible
4. Check if there are any firewall or proxy restrictions blocking connections to Power Platform services

#### Solution 5: Import During Off-Peak Hours
If you're importing during peak business hours:

1. Try importing during off-peak hours (early morning or late evening in your region)
2. This can help avoid service load issues

#### Solution 6: Break Down the Import (Advanced)
If the solution has many dependencies and connections:

1. Review the [setup documentation](https://docs.microsoft.com/power-platform/guidance/coe/setup) for the recommended import order
2. Ensure all prerequisite solutions are installed first
3. Import solutions in smaller chunks if possible

#### Solution 7: Check Power Platform Service Health
Verify that Power Platform services are operating normally:

1. Check the [Microsoft 365 Service Health Dashboard](https://admin.microsoft.com/Adminportal/Home#/servicehealth)
2. Check the [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/) for any health alerts
3. If there's a service incident, wait for Microsoft to resolve it before retrying

#### Solution 8: Contact Support
If none of the above solutions work:

1. **For CoE Starter Kit specific questions**: Create an issue at [aka.ms/coe-starter-kit-issues](https://aka.ms/coe-starter-kit-issues)
2. **For Power Platform service issues**: Contact Microsoft Support through your standard support channel
3. Provide the following information:
   - Solution name and version being imported
   - Environment details (region, type)
   - Full error message and Widget ID
   - Screenshot of the error
   - Steps you've already tried

**Prevention Tips**:
- Ensure you have admin permissions in the target environment
- Review all [prerequisites](https://docs.microsoft.com/power-platform/guidance/coe/setup#prerequisites) before starting
- Ensure the environment has sufficient storage capacity
- Keep your environment updated with the latest Power Platform updates

---

## Additional Resources

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Starter Kit Setup Guide](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [Report an Issue](https://aka.ms/coe-starter-kit-issues)
- [Power Platform Community](https://powerusers.microsoft.com/)

---

## Need More Help?

If you encounter an issue not covered in this guide:

1. Search the [existing issues](https://github.com/microsoft/coe-starter-kit/issues) to see if it's already reported
2. Check the [Microsoft documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
3. Create a new issue using the appropriate [issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
4. Join the [Power Platform Community discussions](https://github.com/microsoft/coe-starter-kit/discussions)
