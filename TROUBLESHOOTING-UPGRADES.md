# CoE Starter Kit - Upgrade Troubleshooting Guide

This document provides troubleshooting guidance for common issues encountered when upgrading the Center of Excellence (CoE) Starter Kit solutions.

## Quick Error Reference

| Error | Quick Fix |
|-------|-----------|
| **TooManyRequests** | Remove unmanaged layers, use incremental upgrades (4.43 → 4.45 → 4.47...), wait 60-90 minutes between retries |
| **80040216 (Resumable Index Rebuild)** | Wait 1-4 hours and retry, or import during off-peak hours. Contact Microsoft Support if persists after 24 hours |

## Quick Fix: TooManyRequests Error

If you're experiencing a **"TooManyRequests"** error during upgrade:

1. ✅ **Remove all unmanaged layers** (use CoE Admin Command Center)
2. ✅ **Use incremental upgrades** (e.g., 4.43 → 4.45 → 4.47 → 4.49 → 4.50.6)
3. ✅ **Wait 60-90 minutes** before retrying after an error
4. ✅ **Import during off-peak hours** (early morning or late evening)
5. ✅ **Import one solution at a time** with 30-60 minute gaps between each

📖 See [detailed resolution steps below](#resolution-steps) for complete guidance.

## Table of Contents
- [TooManyRequests Error During Upgrade](#toomanyreqs-error-during-upgrade)
  - [Quick Fix](#quick-fix-toomanyrequest-error)
  - [Issue Description](#issue-description)
  - [Root Cause](#root-cause)
  - [Resolution Steps](#resolution-steps)
  - [Advanced Troubleshooting](#advanced-troubleshooting)
- [Error 80040216 - Resumable Index Rebuild State](#error-80040216---resumable-index-rebuild-state)
  - [Issue Description](#issue-description-1)
  - [Root Cause](#root-cause-1)
  - [Resolution Steps](#resolution-steps-1)
- [General Upgrade Best Practices](#general-upgrade-best-practices)
- [Version-Specific Upgrade Paths](#version-specific-upgrade-paths)

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

## Error 80040216 - Resumable Index Rebuild State

### Issue Description

When importing or upgrading CoE Starter Kit solutions (particularly Core Components), the import process may fail with error code **80040216** and a message similar to:

```
Error occurred while updating the ImportJob table at the end of import.
Solution import originally failed with Message: Cannot perform this operation on 'object' 
with ID 1577629259 as one or more indexes are currently in resumable index rebuild state.
Please refer to sys.index_resumable_operations for more details.

System.Data.SqlClient.SqlException: Cannot perform this operation on 'object' with 
ID 1577629259 as one or more indexes are currently in resumable index rebuild state.
Please refer to sys.index_resumable_operations for more details.
```

This error typically appears:
- During solution import operations
- When upgrading between versions
- In the final stages of import (updating ImportJob table)
- After database maintenance or backup operations

### Root Cause

This is a **Dataverse platform/database-level issue**, not a bug in the CoE Starter Kit itself. The error indicates that:

1. **Database indexes are in maintenance state**: The underlying SQL Server database for Dataverse has one or more indexes that are currently in a "resumable index rebuild" state.

2. **Incomplete index operations**: This typically occurs when:
   - Database maintenance operations are in progress or were interrupted
   - A previous solution import failed and left indexes in an incomplete state
   - Background database optimization tasks are running
   - The database is recovering from a backup or restore operation

3. **Platform limitation**: The Dataverse platform cannot perform certain operations (like updating the ImportJob system table) while indexes are being rebuilt.

**Important**: This is a **platform service issue**, not a problem with the CoE Starter Kit solution. The error occurs at the SQL Server/Dataverse infrastructure level.

### Resolution Steps

#### Option 1: Wait and Retry (Recommended First Step)

The simplest solution is to wait for the index rebuild operation to complete naturally:

1. **Wait 1-4 hours** before retrying
   - Index rebuild operations typically complete within this timeframe
   - Longer waits (overnight) may be needed for large databases

2. **Check for ongoing maintenance**
   - Verify no database maintenance windows are scheduled
   - Check the [Microsoft Service Health Dashboard](https://admin.microsoft.com/AdminPortal/Home#/servicehealth) for any ongoing platform maintenance

3. **Retry the import**
   - Navigate to Power Platform Admin Center → Solutions
   - Attempt the solution import/upgrade again
   - The error should resolve if the index rebuild has completed

#### Option 2: Import During Off-Peak Hours

Database maintenance operations are often scheduled during specific times:

1. **Schedule import during low-activity periods:**
   - Early morning (2 AM - 6 AM local time)
   - Late evening (10 PM - 12 AM local time)  
   - Weekends when tenant activity is minimal

2. **Avoid known maintenance windows:**
   - Check your organization's database maintenance schedule
   - Coordinate with your database administrators
   - Verify Microsoft doesn't have scheduled maintenance for your region

#### Option 3: Contact Microsoft Support (If Issue Persists)

If the error continues after 24 hours or multiple retry attempts:

1. **Open a support ticket with Microsoft**
   - This is a **platform-level issue** that requires Microsoft intervention
   - Even though the CoE Starter Kit is unsupported, the underlying Dataverse platform issue can be investigated by Microsoft Support
   - Title: "Dataverse database index in resumable rebuild state blocking solution import"

2. **Provide the following information:**
   - Environment ID where the import is failing
   - Full error message including the object ID (e.g., "1577629259")
   - Solution name and version being imported
   - Timestamp of when the error occurred
   - Client Request ID from the error details
   - Screenshot of the error

3. **What Microsoft Support can do:**
   - Check the database index status
   - Complete or abort stuck index rebuild operations
   - Verify database health and integrity
   - Clear any locks or incomplete transactions
   - Provide guidance on database-specific issues

4. **Support ticket details:**
   - **Product**: Power Platform / Dataverse
   - **Issue type**: Solution import failure
   - **Error code**: 80040216
   - **Severity**: Business impact (choose based on your needs)

#### Option 4: Try in a Different Environment (Testing/Validation)

If you need to validate the solution works and this is not a solution-specific issue:

1. **Create a trial or sandbox environment**
   - This helps determine if the issue is environment-specific
   - Use a fresh environment without ongoing maintenance

2. **Attempt the import in the new environment**
   - If successful, confirms the issue is with the original environment's database
   - If it fails, may indicate a broader platform issue

3. **Use the working environment temporarily**
   - For testing or validation purposes only
   - Plan to resolve the original environment issue with Microsoft Support
   - Do not use as a permanent workaround

### Prevention and Best Practices

1. **Coordinate with database teams:**
   - Be aware of scheduled database maintenance windows
   - Avoid solution imports during these times
   - Schedule imports during known stable periods

2. **Monitor environment health:**
   - Regularly check environment status in Power Platform Admin Center
   - Review any notifications about ongoing maintenance
   - Subscribe to Microsoft Service Health notifications

3. **Plan imports appropriately:**
   - Don't rush imports; plan for adequate time
   - Have a rollback strategy in case of failures
   - Test in non-production environments first

### Additional Information

**This error is NOT:**
- ❌ A bug in the CoE Starter Kit
- ❌ Caused by the solution file being corrupted
- ❌ Related to permissions or licensing
- ❌ Something that can be fixed by modifying the solution

**This error IS:**
- ✅ A Dataverse platform/database infrastructure issue
- ✅ Temporary and typically resolves itself
- ✅ Resolvable by Microsoft Support if it persists
- ✅ Unrelated to the specific solution being imported

### Related Resources

- [Microsoft Service Health Dashboard](https://admin.microsoft.com/AdminPortal/Home#/servicehealth)
- [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
- [Contact Microsoft Support](https://learn.microsoft.com/en-us/power-platform/admin/get-help-support)
- [Dataverse system tables documentation](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/about-entity-reference)

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

### Q: What does error 80040216 mean, and how do I fix it?
**A:** Error 80040216 ("resumable index rebuild state") is a Dataverse platform/database issue, not a CoE Starter Kit bug. The underlying SQL Server database has indexes in maintenance mode. **Resolution**: Wait 1-4 hours and retry the import, or schedule the import during off-peak hours (early morning/late evening). If the error persists after 24 hours, contact Microsoft Support with the error details—this is a platform-level issue they can investigate and resolve.

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
