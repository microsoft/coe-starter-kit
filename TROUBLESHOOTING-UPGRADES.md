# CoE Starter Kit - Upgrade Troubleshooting Guide

This document provides troubleshooting guidance for common issues encountered when upgrading the Center of Excellence (CoE) Starter Kit solutions.

## Quick Fixes

### Network Error (ERR_NETWORK) or Timeout During Import

If you're experiencing **network errors**, **timeout errors**, or **certificate/SSL errors** during import:

1. ✅ **Use a wired (Ethernet) connection** instead of WiFi
2. ✅ **Disable VPN** during import (if permitted)
3. ✅ **Import via Power Platform Admin Center** (not Maker Portal)
4. ✅ **Use PAC CLI** with timeout: `pac solution import --async --max-async-wait-time 20`
5. ✅ **Import during off-peak hours** (2 AM - 6 AM or late evening)

📖 See [detailed resolution steps below](#network-errors-and-timeout-issues-during-import) for complete guidance.

### TooManyRequests Error During Upgrade

If you're experiencing a **"TooManyRequests"** error during upgrade:

1. ✅ **Remove all unmanaged layers** (use CoE Admin Command Center)
2. ✅ **Use incremental upgrades** (e.g., 4.43 → 4.45 → 4.47 → 4.49 → 4.50.6)
3. ✅ **Wait 60-90 minutes** before retrying after an error
4. ✅ **Import during off-peak hours** (early morning or late evening)
5. ✅ **Import one solution at a time** with 30-60 minute gaps between each

📖 See [detailed resolution steps below](#resolution-steps) for complete guidance.

## Table of Contents
- [Network Errors and Timeout Issues During Import](#network-errors-and-timeout-issues-during-import)
  - [Quick Fix](#quick-fix-network-errors)
  - [Issue Description](#network-issue-description)
  - [Root Cause](#network-root-cause)
  - [Resolution Steps](#network-resolution-steps)
- [TooManyRequests Error During Upgrade](#toomanyreqs-error-during-upgrade)
  - [Quick Fix](#quick-fix-toomanyrequest-error)
  - [Issue Description](#issue-description)
  - [Root Cause](#root-cause)
  - [Resolution Steps](#resolution-steps)
  - [Advanced Troubleshooting](#advanced-troubleshooting)
- [Unexpected Azure DevOps Email Notifications](#unexpected-azure-devops-email-notifications)
- [AppForbidden DLP Errors](#appforbidden-dlp-errors)
- [General Upgrade Best Practices](#general-upgrade-best-practices)
- [Version-Specific Upgrade Paths](#version-specific-upgrade-paths)

---

## Network Errors and Timeout Issues During Import

### Quick Fix: Network Errors

If you're experiencing **network errors (ERR_NETWORK)**, **timeout errors**, or **certificate/SSL errors** during import:

1. ✅ **Use a stable, wired network connection** (not WiFi or VPN)
2. ✅ **Import via Power Platform Admin Center** (not Maker Portal)
3. ✅ **Use PAC CLI with increased timeout** (see below)
4. ✅ **Check your network/firewall** isn't blocking *.crm.dynamics.com
5. ✅ **Try during off-peak hours** when network load is lower
6. ✅ **Use incremental upgrades** (smaller version jumps = smaller imports)

📖 See [detailed resolution steps below](#network-resolution-steps) for complete guidance.

### Network Issue Description

When importing large CoE Starter Kit solutions (particularly Core Components v4.50+), the import process may fail with one or more of the following errors:

**Browser Import Errors:**
```
Network Error (ERR_NETWORK)
ERR_CONNECTION_RESET
ERR_CONNECTION_TIMED_OUT
The connection was reset
```

**PAC CLI Errors:**
```
Error: An error occurred while making the HTTP request to https://org[guid].crm[X].dynamics.com/XRMServices/2011/Organization.svc/web
This could be due to the fact that the server certificate is not configured properly with HTTP.SYS in the HTTPS case.
This could also be caused by a mismatch of the security binding between the client and the server.
The underlying connection was closed: An unexpected error occurred on a send.
Unable to write data to the transport connection: An existing connection was forcibly closed by the remote host.
An existing connection was forcibly closed by the remote host
```

**Power Platform Admin Center:**
- Import shows no error but hangs indefinitely
- Import fails silently with no history entry
- Progress bar freezes at various percentages

### Network Root Cause

These errors occur due to **network timeouts and transfer interruptions** when:

1. **Large solution size**: CoE Core Components v4.50+ contains:
   - 269 Canvas Apps (~29MB unpacked)
   - 240 Cloud Flows (~6MB)
   - Total solution package can exceed 35-50MB
   - Browser and network timeouts occur during large file transfers

2. **Network instability**: 
   - Unstable WiFi connections
   - VPN disconnections or latency
   - Corporate firewalls blocking or throttling *.dynamics.com traffic
   - ISP throttling of large uploads
   - Intermittent network interruptions

3. **Client-side timeouts**:
   - Browser default timeout (typically 2-5 minutes)
   - PAC CLI default timeout (60 seconds)
   - Network keep-alive settings too aggressive

4. **SSL/TLS handshake failures**:
   - Corporate SSL inspection/MITM proxies
   - Outdated TLS versions on client
   - Certificate trust chain issues

### Network Resolution Steps

#### Step 1: Use a Stable Network Connection (Critical)

1. **Switch to wired (Ethernet) connection** if possible
   - WiFi can have intermittent packet loss
   - Wired connections are more stable for large transfers

2. **Disable VPN temporarily** during import
   - VPNs can add latency and cause disconnections
   - Only disable if permitted by your organization's policies
   - Ensure you can still reach *.crm.dynamics.com without VPN

3. **Check firewall/proxy settings**:
   - Verify *.dynamics.com and *.crm.dynamics.com are allowed
   - Disable SSL inspection for *.dynamics.com if possible
   - Whitelist Power Platform endpoints in your firewall

4. **Close bandwidth-heavy applications**:
   - Stop video conferencing, streaming, or large downloads
   - Ensure sufficient bandwidth for the import

#### Step 2: Use Power Platform Admin Center (Recommended Method)

The **modern Power Platform Admin Center** has better timeout handling than the Maker Portal:

1. Navigate to [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
2. Select **Environments** → Your CoE environment
3. Go to **Solutions**
4. Click **Import solution**
5. Upload the .zip file
6. Select **Upgrade** option (default)
7. **Do NOT close the browser window** until import completes
8. **Do NOT navigate away** or switch tabs during import

**Important**: Keep your computer active during import:
- Disable sleep/hibernation temporarily
- Keep the browser tab active and visible
- Don't lock your screen during import

#### Step 3: Use PAC CLI with Increased Timeout (For Advanced Users)

The PAC CLI can be configured with longer timeouts for large imports:

```powershell
# Install/Update PAC CLI
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
# or
dotnet tool update --global Microsoft.PowerApps.CLI.Tool

# Authenticate to your environment
pac auth create --environment https://yourorg.crm.dynamics.com

# Import with increased timeout (20 minutes)
pac solution import --path "CenterofExcellenceCoreComponents_managed.zip" --async --max-async-wait-time 20

# Monitor import status
pac solution list
```

**Alternative: Use PowerShell with Custom Timeout**

```powershell
# Install required modules
Install-Module -Name Microsoft.Xrm.Data.PowerShell -Force

# Connect with extended timeout (30 minutes = 1800 seconds)
$conn = Get-CrmConnection -ServerUrl "https://yourorg.crm.dynamics.com" -InteractiveMode -Timeout 1800

# Import solution
Import-CrmSolution -conn $conn -SolutionFilePath "CenterofExcellenceCoreComponents_managed.zip" -ActivateWorkflows -OverwriteUnmanagedCustomizations -PublishWorkflows
```

#### Step 4: Try During Off-Peak Hours

Network congestion and server load can affect import success:

1. **Best times to import** (your local timezone):
   - Early morning: 2 AM - 6 AM
   - Late evening: 10 PM - 12 AM
   - Weekends (Saturday early morning)

2. **Avoid these times**:
   - Business hours (9 AM - 5 PM)
   - Monday mornings
   - End of month/quarter (high tenant activity)

#### Step 5: Use Incremental Upgrades (Smaller Imports)

Instead of jumping from 4.50.2 to 4.50.8 (if this is a large gap in terms of changes), consider:

**Check release notes to see if there are intermediate patch versions:**
1. Visit [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases)
2. Check if versions between 4.50.2 and 4.50.8 exist
3. If significant changes occurred, upgrade incrementally:
   - 4.50.2 → 4.50.4 → 4.50.6 → 4.50.8 (if these versions exist)

**Benefits**:
- Smaller differential imports
- Lower file transfer sizes
- Less chance of network timeout

#### Step 6: Verify Environment Health

Before attempting import:

1. **Check environment status**:
   - Navigate to Power Platform Admin Center
   - Verify environment shows as **Ready** (not in admin mode or maintenance)
   - Check **Capacity** is sufficient (>1GB storage available)

2. **Check for platform issues**:
   - Visit [Microsoft Service Health Dashboard](https://admin.microsoft.com/AdminPortal/Home#/servicehealth)
   - Check for Power Platform service disruptions
   - Check [Power Platform Status](https://status.powerplatform.microsoft.com/)

3. **Verify your permissions**:
   - Ensure you have **System Administrator** role in the target environment
   - Confirm you're not being blocked by conditional access policies

#### Step 7: Alternative Import Methods

If standard import continues to fail:

**Option A: Request Import via Support (Enterprise Customers)**

If you have Premier/Unified support:
1. Open a support ticket with Microsoft
2. Provide the solution .zip file
3. Request server-side import assistance
4. Reference the network timeout errors

**Option B: Import to a Copy Environment First**

1. Create a **copy of your CoE environment**
2. Import the upgrade to the copy environment
3. Test functionality in the copy
4. Delete original environment and rename copy (only if desperate - not recommended)

**Option C: Manual Component Import (Last Resort - Not Recommended)**

⚠️ **Warning**: This approach is complex and error-prone. Only use if all other methods fail.

1. Export your current solution as backup
2. Import Creator Kit dependency separately
3. Try importing just the Core Components
4. If that fails, the issue may be platform-level requiring support

### Advanced Troubleshooting for Network Errors

#### Collect Diagnostic Information

Before contacting support, gather:

1. **Error details**:
   - Exact error message
   - Screenshot of error
   - Time of failure (UTC timezone)
   - Import method used (UI, PAC CLI, PowerShell)

2. **Network diagnostics**:
   ```powershell
   # Test connectivity to Dynamics endpoint
   Test-NetConnection -ComputerName yourorg.crm.dynamics.com -Port 443
   
   # Check for packet loss
   ping yourorg.crm.dynamics.com -n 50
   
   # Trace route
   tracert yourorg.crm.dynamics.com
   ```

3. **Browser console logs** (if using browser import):
   - Press F12 to open Developer Tools
   - Go to **Console** tab
   - Reproduce the error
   - Copy all red error messages
   - Take screenshot

4. **PAC CLI verbose output**:
   ```powershell
   pac solution import --path "solution.zip" --log-to-file --verbose
   ```

#### Check SSL/Certificate Issues

If you see certificate or SSL errors:

1. **Update Windows/OS certificates**:
   - Windows: Run Windows Update
   - Ensure latest root certificates are installed

2. **Check TLS version**:
   ```powershell
   # Enable TLS 1.2 (PowerShell)
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   ```

3. **Verify corporate proxy isn't breaking SSL**:
   - Temporarily bypass proxy (if permitted)
   - Check with IT if SSL inspection is enabled for *.dynamics.com

4. **Test from different network**:
   - Try from home network (no corporate firewall)
   - Try from mobile hotspot
   - This helps isolate if issue is network-specific

### Prevention for Future Imports

1. **Upgrade more frequently**:
   - Don't skip multiple versions
   - Smaller version gaps = smaller imports
   - Upgrade every 1-2 months when new versions release

2. **Maintain stable network environment**:
   - Use wired connections for admin operations
   - Document successful import locations/networks

3. **Keep tools updated**:
   - Update PAC CLI regularly: `dotnet tool update --global Microsoft.PowerApps.CLI.Tool`
   - Keep browsers updated
   - Update PowerShell modules

4. **Monitor environment health**:
   - Check storage capacity monthly
   - Remove unmanaged layers regularly
   - Review and clean up unused components

---

## TooManyRequests Error During Upgrade

### Issue Description

When upgrading CoE Starter Kit solutions (particularly Core Components) from older versions (e.g., 4.43) to newer versions (e.g., 4.47+, 4.50+), the import process may fail with the following error:

```
Solution "Center of Excellence - Core Components" failed to import: ImportAsHolding failed with exception: 
CanvasApp import: FAILURE: Code: TooManyRequests 
Message: Too many requests sent to a service.
Client Request Id: [GUID]
```

### Root Cause

This is a **known rate-limiting issue** that occurs when:

1. **Multiple Canvas Apps are imported simultaneously**: CoE Starter Kit solutions contain multiple Canvas Apps. During the upgrade process, the Power Platform import service sends multiple concurrent requests to the Canvas App service.

2. **Service protection limits are exceeded**: Microsoft Power Platform enforces service protection limits to ensure fair resource usage and system stability. When upgrading solutions with many Canvas Apps, especially after skipping multiple versions, the number of API calls can exceed these limits.

3. **Large version gaps exacerbate the issue**: Upgrading from significantly older versions (e.g., 4.43 → 4.50.6, spanning 13+ months) includes more Canvas App changes, increasing the likelihood of hitting rate limits.

### Official Documentation

For more information about service protection limits, see:
- [Service protection API limits](https://learn.microsoft.com/en-us/power-platform/admin/api-request-limits-allocations)
- [CoE Starter Kit upgrade guidance](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)

### Resolution Steps

#### Step 1: Remove Unmanaged Layers (Critical - Must Do First)

Unmanaged customizations block solution updates and must be removed before upgrading.

1. Open the **CoE Admin Command Center** app in your CoE environment
2. Navigate to the **CoE flows** section
3. Identify any flows or components with unmanaged layers (indicated by a layer icon)
4. For each component with an unmanaged layer:
   - Click **See solution layers**
   - Select the unmanaged layer
   - Click **Remove unmanaged layer**
5. Repeat for all CoE solutions (Core, Governance, Nurture, etc.)

**Reference**: [Removing unmanaged layers](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup#installing-upgrades)

#### Step 2: Use Version-by-Version Upgrade Strategy (Recommended)

Instead of jumping directly from 4.43 to 4.50.6, upgrade incrementally:

**Recommended upgrade path from 4.43:**
1. 4.43 → 4.45
2. 4.45 → 4.47
3. 4.47 → 4.49
4. 4.49 → 4.50.6 (or latest)

**Benefits of incremental upgrades:**
- Fewer Canvas Apps to import in each step
- Lower chance of hitting rate limits
- Easier to identify which version introduces issues (if any)
- Allows for testing between major version jumps

**Where to find older versions:**
- Visit the [CoE Starter Kit Releases page](https://github.com/microsoft/coe-starter-kit/releases)
- Download the specific version you need for each upgrade step

#### Step 3: Implement Retry Strategy with Proper Timing

If you encounter the TooManyRequests error:

1. **Wait at least 60-90 minutes** before retrying
   - Service protection limits reset over time
   - Waiting longer (2-4 hours) is even better for a clean retry

2. **Avoid concurrent operations during retry**
   - Do not run other solution imports
   - Pause or disable heavy flows temporarily
   - Avoid large data sync operations
   - Do not run bulk API operations

3. **Import during off-peak hours**
   - Early morning (2 AM - 6 AM local time)
   - Late evening (10 PM - 12 AM local time)
   - Weekends when tenant activity is lower

#### Step 4: Import Solutions One at a Time

Instead of importing all CoE solutions together:

1. Import **Core Components** first and verify success
2. Wait 30-60 minutes
3. Import **Governance Components** (if used)
4. Wait 30-60 minutes
5. Import **Nurture Components** (if used)
6. Continue with other solutions as needed

**Important**: Core Components must be imported before other solutions due to dependencies.

#### Step 5: Use the Modern Power Platform Admin Center

While the issue mentions trying the "classic" console, the **modern Power Platform Admin Center is recommended**:

1. Navigate to [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Go to **Solutions**
4. Import the solution using the **Upgrade** option (default)

The modern admin center provides:
- Better error reporting
- Progress indicators
- Improved retry handling

#### Step 6: Verify Solution Prerequisites

Before upgrading, ensure:

1. **Environment requirements are met:**
   - Database capacity is sufficient
   - Environment is not in admin mode
   - No ongoing maintenance operations

2. **Flows are in a healthy state:**
   - Open Power Automate in the CoE environment
   - Check for failed or suspended flows
   - Turn off flows that are in a failed state, then turn them back on
   - Address any authentication or connection issues

3. **Dependencies are current:**
   - All dependent solutions are at compatible versions
   - Required connectors are available and not blocked by DLP policies

#### Step 7: Force Version Refresh (If Upgrade Options Don't Appear)

If the system doesn't recognize an upgrade is available:

1. Navigate to **Power Platform Admin Center**
2. Go to your **Environment → Solutions**
3. Open the **CoE Core Components** solution
4. Select **Versions** from the top menu
5. Click **Refresh**
6. Wait a few minutes and check if the upgrade option appears

### Advanced Troubleshooting

#### If Issues Persist After All Steps

1. **Export and review logs:**
   - Check the detailed error message in the import history
   - Note the Client Request Id for reference
   - Check if specific Canvas Apps are mentioned in errors

2. **Temporarily disable non-critical flows:**
   - Turn off inventory sync flows
   - Disable cleanup flows
   - Stop any custom flows that interact with CoE data

3. **Consider a staged environment approach:**
   - Test the upgrade in a copy/sandbox environment first
   - Validate the upgrade works before applying to production
   - This helps identify environment-specific issues

4. **Contact support if needed:**
   - While the CoE Starter Kit itself is unsupported, Microsoft Support can help with platform-level rate limiting issues
   - Open a support ticket for the Power Platform service
   - Reference the "TooManyRequests" error and provide the Client Request Id
   - Report your issue on GitHub: [CoE Starter Kit Issues](https://aka.ms/coe-starter-kit-issues)

### Prevention for Future Upgrades

1. **Upgrade regularly (every 1-3 months):**
   - Smaller version gaps = fewer changes per upgrade
   - Reduces risk of rate limiting
   - Easier to troubleshoot issues

2. **Monitor for unmanaged customizations:**
   - Regularly check for unmanaged layers
   - Use source control for custom modifications
   - Document all customizations

3. **Subscribe to CoE Starter Kit releases:**
   - Watch the GitHub repository
   - Enable notifications for new releases
   - Review release notes before upgrading

---

## Unexpected Azure DevOps Email Notifications

### Issue Description

After reimporting or upgrading Core Components (January 2026 or later), you may receive unexpected email notifications about:
- "Sync Issues to Azure DevOps..."
- Flow failures related to Azure DevOps
- Innovation Backlog features

Even when Azure DevOps, ALM Accelerator, Pipeline Accelerator, or Innovation Backlog are not installed or actively used.

### Quick Fix

**This is normal behavior and can be safely resolved.**

1. **Identify the flow** sending notifications (check email details)
2. **Turn off the flow** if you don't use that feature
3. **Or remove unused CoE solutions** (Innovation Backlog, ALM Accelerator, Pipeline Accelerator)

### Detailed Resolution

For comprehensive troubleshooting steps, causes, and multiple resolution options, see:

📖 **[Troubleshooting Azure DevOps Email Notifications](docs/TROUBLESHOOTING-AZURE-DEVOPS-EMAILS.md)**

This guide covers:
- Why these notifications occur after upgrades
- Step-by-step resolution options
- How to prevent this in future upgrades
- When to seek further help

---

## AppForbidden DLP Errors

### Issue Description

After upgrading or when opening certain sections of the **CoE Admin Command Center** (particularly the **Flows** section), you may encounter an "AppForbidden" error:

```
Error Code: AppForbidden
It looks like this app isn't compliant with the latest data loss prevention policies.
```

### Quick Fix

**This is a Data Loss Prevention (DLP) policy configuration issue.**

1. **Identify required connectors**: Power Automate Management, Logic flows, Microsoft Dataverse
2. **Verify DLP policies** in Power Platform Admin Center
3. **Ensure all required connectors are in the same DLP group** (Business or Non-Business)
4. **Update DLP policy** or exclude CoE environment from restrictive policies

### Detailed Resolution

For comprehensive troubleshooting steps, connector requirements, and DLP policy configuration guidance, see:

📖 **[Troubleshooting AppForbidden / DLP Errors](docs/TROUBLESHOOTING-DLP-APPFORBIDDEN.md)**

This guide covers:
- Complete list of connectors required by CoE apps
- Step-by-step DLP policy configuration
- Best practices for CoE environment DLP setup
- How to work with your security team on exemptions

---

## General Upgrade Best Practices

### Before Starting Any Upgrade

1. **Backup your environment:**
   - Export existing solutions as backup
   - Document current configuration
   - Note all environment variables and connection references

2. **Review release notes:**
   - Check [CoE Starter Kit Release Notes](https://github.com/microsoft/coe-starter-kit/releases)
   - Identify breaking changes or new requirements
   - Review upgrade-specific instructions

3. **Plan for downtime:**
   - Schedule upgrades during maintenance windows
   - Inform users of potential disruptions
   - Plan for rollback if needed

4. **Test in non-production first:**
   - Use a development or test environment
   - Validate the upgrade process
   - Test critical functionality after upgrade

### During the Upgrade

1. **Use the Upgrade option (not Update):**
   - Upgrade maintains customizations and data
   - Update can overwrite customizations
   - Default behavior is Upgrade (recommended)

2. **Monitor progress:**
   - Watch for warning messages
   - Note any skipped components
   - Review import logs

3. **Don't interrupt the process:**
   - Allow the import to complete
   - Don't close the browser window
   - Don't perform other admin operations

### After the Upgrade

1. **Verify functionality:**
   - Test key flows and apps
   - Check data in CoE tables
   - Verify dashboards and reports

2. **Update connections:**
   - Check connection references
   - Refresh authentication if needed
   - Test connector functionality

3. **Re-enable flows:**
   - Turn on flows that were disabled
   - Monitor initial flow runs
   - Address any errors

4. **Communicate with users:**
   - Announce upgrade completion
   - Note any new features or changes
   - Provide updated documentation

---

## Version-Specific Upgrade Paths

### Upgrading from 4.43 or Earlier

**Challenge**: Significant changes accumulated over multiple releases.

**Recommended path:**
- 4.43 → 4.45 → 4.47 → 4.49 → latest

**Key considerations:**
- More Canvas Apps to update
- Higher chance of rate limiting
- Plan for 2-4 hours between version upgrades

### Upgrading from 4.44 - 4.48

**Recommended path:**
- Current version → 4.49 → latest

**Key considerations:**
- Moderate changes
- Still recommend incremental approach
- Allow 1-2 hours between upgrades

### Upgrading from 4.49 or Later

**Recommended path:**
- Direct upgrade to latest is usually safe

**Key considerations:**
- Fewer changes
- Lower rate limiting risk
- Still remove unmanaged layers first

---

## Frequently Asked Questions (FAQ)

### Q: I'm getting ERR_NETWORK or "connection forcibly closed" errors. What should I do?
**A:** These are **network timeout errors** caused by the large size of CoE Core Components solution. See the [Network Errors and Timeout Issues](#network-errors-and-timeout-issues-during-import) section above for complete resolution steps. Quick fixes:
1. Use a wired (Ethernet) connection instead of WiFi
2. Disable VPN during import if possible
3. Use PAC CLI with increased timeout: `pac solution import --async --max-async-wait-time 20`
4. Import during off-peak hours (early morning or late evening)
5. Ensure your firewall/proxy isn't blocking *.crm.dynamics.com

### Q: PAC CLI shows certificate or SSL errors. How do I fix this?
**A:** This is typically caused by corporate SSL inspection, proxy configuration, or outdated certificates:
1. Enable TLS 1.2 in PowerShell: `[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12`
2. Update Windows certificates via Windows Update
3. Temporarily disable VPN/proxy (if permitted by your organization)
4. Try importing from a different network (home network, mobile hotspot)
5. Contact your IT department to whitelist *.dynamics.com from SSL inspection

### Q: The import hangs with no error message. What's wrong?
**A:** This is a network timeout occurring silently:
1. Check the Power Platform Admin Center **Solution History** for actual status
2. Wait at least 30-60 minutes before concluding it has failed
3. Use PAC CLI instead of browser import for better visibility
4. Check network stability (wired connection, no VPN)
5. Import during off-peak hours when server load is lower

### Q: How long should I wait between retry attempts?
**A:** Wait at least 60-90 minutes. For best results, wait 2-4 hours or perform the retry during off-peak hours.

### Q: Can I skip intermediate versions when upgrading?
**A:** While technically possible, it's **not recommended** for large version gaps (e.g., 4.43 to 4.50.6). Incremental upgrades reduce the number of Canvas App changes per import, lowering the risk of hitting rate limits.

### Q: Will I lose data if I upgrade incrementally?
**A:** No. Using the **Upgrade** option (default) preserves all data and customizations. Each intermediate upgrade builds on the previous version.

### Q: What if I already have unmanaged customizations?
**A:** Document your customizations first, then remove unmanaged layers before upgrading. After the upgrade, re-apply your customizations in a way that doesn't create unmanaged layers (e.g., use separate solutions or properly managed customizations).

### Q: Can I import multiple CoE solutions at the same time?
**A:** No, import them **one at a time** with 30-60 minute gaps between each. Import Core Components first (it's required for others), then Governance, then Nurture, etc.

### Q: What if the error persists after following all steps?
**A:** 
1. Check if there are ongoing platform issues at [Microsoft Service Health Dashboard](https://admin.microsoft.com/AdminPortal/Home#/servicehealth)
2. Try importing in a different time window (middle of the night, weekend)
3. Contact Microsoft Support for platform-level rate limiting investigation
4. Report the issue on [GitHub Issues](https://aka.ms/coe-starter-kit-issues) with full details

### Q: Is this a bug in the CoE Starter Kit?
**A:** No, this is a **platform service protection limit**, not a bug. It's a safeguard to ensure system stability. The CoE Starter Kit contains many Canvas Apps, which can trigger these limits during bulk imports, especially for large version jumps.

### Q: How often should I upgrade the CoE Starter Kit?
**A:** Upgrade every **1-3 months** to avoid large version gaps. This makes upgrades smoother and reduces the risk of rate limiting issues.

---

## Additional Resources

### Official Documentation
- [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [CoE Starter Kit Setup](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
- [After Setup and Upgrades](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [Service Protection Limits](https://learn.microsoft.com/en-us/power-platform/admin/api-request-limits-allocations)

### GitHub Resources
- [CoE Starter Kit Repository](https://github.com/microsoft/coe-starter-kit)
- [Report Issues](https://aka.ms/coe-starter-kit-issues)
- [Release Downloads](https://github.com/microsoft/coe-starter-kit/releases)
- [Closed Milestones (What's New)](https://github.com/microsoft/coe-starter-kit/milestones?state=closed)

### Community Support
- [Power Apps Community Forum - Governance](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- [CoE Starter Kit Questions on GitHub](https://github.com/microsoft/coe-starter-kit/issues)

---

## Disclaimer

The CoE Starter Kit represents sample implementations of Power Platform features. While the underlying platform features are fully supported by Microsoft, the kit itself is provided as-is without official Microsoft Support. For issues with the kit, please use the GitHub issues page. For issues with the Power Platform service itself (such as service protection limit errors), contact Microsoft Support through your standard support channel.

---

**Last Updated**: January 2026  
**Applies to**: CoE Starter Kit versions 4.43 and later
