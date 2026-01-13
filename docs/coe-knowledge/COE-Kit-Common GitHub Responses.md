# CoE Starter Kit - Common GitHub Responses Playbook

This document contains ready-to-use explanations, limits, workarounds, and standard responses for common issues in the CoE Starter Kit.

## Table of Contents

1. [General Support Policy](#general-support-policy)
2. [Inventory and Sync Issues](#inventory-and-sync-issues)
3. [BYODL (Data Lake) Status](#byodl-data-lake-status)
4. [Pagination and Licensing](#pagination-and-licensing)
5. [Cleanup Flows](#cleanup-flows)
6. [Unsupported Features](#unsupported-features)
7. [Setup Wizard Guidance](#setup-wizard-guidance)
8. [Language and Localization](#language-and-localization)
9. [Connection Issues](#connection-issues)
10. [Performance and Throttling](#performance-and-throttling)

---

## General Support Policy

### Response Template: Unsupported/Best-Effort Nature

```markdown
Thank you for using the CoE Starter Kit. Please note that the CoE Starter Kit is provided as-is and is not officially supported by Microsoft. 

**Support channels:**
- **GitHub Issues**: Primary channel for bug reports, feature requests, and questions
- **No SLA**: We provide best-effort support through the community
- **Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit

For product-level support on Power Platform capabilities, please contact Microsoft Support directly.
```

### Response Template: Investigation Required

```markdown
To help us investigate this issue, please provide the following information:

1. **Solution name and version**: Which CoE solution component? (Core, Governance, Nurture, etc.)
2. **Specific flow or app**: Name of the flow/app experiencing the issue
3. **Inventory method**: Are you using audit logs, or "None"?
4. **Error messages**: Full error text or screenshots
5. **Steps to reproduce**: Detailed steps to replicate the issue
6. **Environment details**: 
   - Number of environments in tenant
   - Number of apps/flows/connectors
   - Admin privileges confirmed
7. **Recent changes**: Any recent updates or configuration changes

This will help us provide a more targeted solution.
```

---

## Inventory and Sync Issues

### Response Template: Data Not Updating / Missing Inventory

```markdown
If the Power Platform Admin View or other apps are showing outdated data or missing items, this typically indicates that inventory sync flows are not running properly.

**Immediate troubleshooting steps:**

1. **Check sync flow status**: Verify that the **Admin | Sync Template v4 (Driver)** flow is running successfully
2. **Review flow run history**: Look for errors in the last 28 days
3. **Verify connections**: Ensure all connections (Power Platform for Admins, Dataverse, Office 365 Users) are authenticated and not showing errors
4. **Manual trigger**: Try manually running the Driver flow and monitor for errors

**Common causes:**
- Connections expired or lacking admin permissions
- Flows suspended or turned off
- API throttling or licensing limits
- Environment variables misconfigured

**Detailed guide:**
See [Troubleshooting Admin View Data Refresh](../docs/coe-knowledge/troubleshooting-admin-view-data-refresh.md) for a complete step-by-step resolution guide.

**Full inventory refresh:**
If data is still stale, you may need to force a full inventory sync by toggling the **Environment Is Not Visible in Apps** flag in the Environment table.
```

### Response Template: Missing Environments

```markdown
If specific environments are not appearing in the Admin View:

**Check these points:**

1. **Environment table in Dataverse**: 
   - Navigate to Tables → Environment
   - Search for the missing environment name
   - Check if it exists and review these fields:
     - **Environment Is Visible to Admin Mode**: Should be "Yes"
     - **Environment Is Not Visible in Apps**: Should be "No"
     - **Modified On**: Should be recent

2. **Admin permissions**: The account running the sync flows must have admin access to the environment

3. **Environment variable**: Verify **Is All Environments Inventory** is set to "Yes" in environment variables

4. **Trigger full sync**: 
   - In the Environment table, set **Environment Is Not Visible in Apps** to "Yes", save
   - Then set it back to "No", save
   - This will trigger dependent flows to sync that environment

5. **Wait time**: Allow 30-60 minutes for sync flows to complete after triggering
```

### Response Template: Old Data Persists

```markdown
If you're seeing apps or resources from months ago but not recent ones:

**This indicates sync flows have stopped running or are failing.**

**Resolution:**
1. Check the last successful run date of **Admin | Sync Template v4 (Driver)** flow
2. Review the 28-day run history for errors
3. Check if flows are scheduled to run (recurrence trigger should be enabled)
4. Manually trigger the Driver flow and wait for completion
5. Verify dependent flows (Apps, Environments, Flows, etc.) also ran successfully

**If sync runs but data doesn't update:**
- Check Dataverse table records directly to confirm data is being written
- Review flow outputs to see if pagination is limiting results
- Verify license level (trial licenses have limitations)
```

---

## BYODL (Data Lake) Status

### Response Template: BYODL No Longer Recommended

```markdown
**Important: BYODL (Bring Your Own Data Lake) is no longer the recommended approach.**

The CoE Starter Kit team is transitioning to Microsoft Fabric for data export scenarios. 

**Current recommendation:**
- **For new setups**: Do NOT configure BYODL
- **For existing BYODL users**: Continue using it but plan for future migration
- **Future direction**: Microsoft Fabric integration is coming

**Alternative approaches:**
1. Use the standard Dataverse tables for reporting (Power BI connects directly)
2. For data export needs, consider Dataverse Data Export to Azure SQL (supported product feature)
3. Wait for Fabric integration guidance (coming in future releases)

**If you must use BYODL:**
- Ensure you have proper Azure Data Lake Gen2 storage configured
- Follow the setup documentation carefully
- Be aware this is not actively enhanced going forward
```

---

## Pagination and Licensing

### Response Template: Trial License Limitations

```markdown
Trial licenses and insufficient license profiles can hit pagination limits, causing incomplete data collection.

**Symptoms:**
- Only partial list of apps/flows/environments
- Sync appears successful but data is incomplete
- Pagination warnings in flow run history

**Resolution:**
1. **Verify license level**: The admin account running sync flows needs appropriate Power Platform licensing
2. **Test pagination limits**: 
   ```
   - Try manually listing environments using Power Platform for Admins connector
   - Check if pagination controls appear
   - If limited to 5000 records, you're hitting trial limits
   ```

3. **License upgrade**: Consider upgrading to:
   - Power Apps Per User or Per App license
   - Power Automate Per User license
   - Microsoft 365 E3/E5 (includes Power Platform capabilities)

4. **Service Principal**: For large tenants, consider using Service Principal authentication which has higher limits

**Testing pagination:**
You can test if your account has adequate licensing by creating a simple flow that lists all environments and checking if it returns complete results.
```

### Response Template: Throttling / API Limits

```markdown
If you're encountering throttling errors (429) or timeout issues:

**This is common in large tenants with thousands of resources.**

**Mitigation strategies:**

1. **Stagger sync schedule**: Spread different sync flows across different times of day
2. **Increase timeouts**: Some flows have configurable timeout settings
3. **Service Principal**: Use app-based authentication which has different throttling limits
4. **Pagination handling**: Ensure flows properly handle pagination (recent versions have improvements)
5. **Reduce frequency**: Run full syncs daily instead of hourly

**For very large tenants (10,000+ apps):**
- Consider filtering environments to sync only production/critical environments
- Use incremental syncs where possible
- Monitor API quota consumption in Power Platform Admin Center

**API Request Limits:**
- Check: Power Platform Admin Center → Environment → Resources → Capacity
- Review: API request limits and Flow runs per day
```

---

## Cleanup Flows

### Response Template: Cleanup Flows Guidance

```markdown
The CoE Starter Kit includes cleanup flows to handle deleted resources:

**Key cleanup flows:**
- **CLEANUP - Admin | Sync Template v4 (Check Deleted)**: Identifies deleted resources
- **CLEANUPHELPER - Check Deleted v4 (Desktopflows)**: Desktop flow cleanup
- **CLEANUP - Admin | Sync Template v4 (Other Objects)**: General resource cleanup

**How cleanup works:**
1. Sync flows mark resources as potentially deleted if they're not found in API responses
2. Cleanup flows run periodically to verify deletion status
3. Records are marked as deleted (not physically removed) for historical tracking

**Common issues:**

**"Resources marked as deleted but they still exist"**
- This can happen due to API throttling or pagination issues
- Solution: Run the Driver flow again to refresh the inventory

**"Deleted resources not being marked"**
- Ensure cleanup flows are turned on and running
- Check cleanup flow run history for errors
- Verify the flows have proper Dataverse permissions

**"Should I delete records manually?"**
- No, let the cleanup flows handle this automatically
- Manual deletion can cause data inconsistencies
- If needed, use the "Deleted" flag rather than physical deletion
```

---

## Unsupported Features

### Response Template: Feature Not Currently Supported

```markdown
Thank you for the feature request. However, [specific feature] is not currently supported in the CoE Starter Kit.

**Reasons:**
- [Technical limitation / API not available / Performance concerns / etc.]

**Alternatives:**
1. [Alternative approach 1]
2. [Alternative approach 2]
3. [Workaround using PowerShell or direct API calls]

**For product-level features:**
If this requires new Power Platform APIs or capabilities, please submit feedback through:
- Power Apps Ideas: https://ideas.powerapps.com/
- Power Automate Ideas: https://ideas.powerautomate.com/

**Future consideration:**
We track feature requests in our backlog: https://github.com/microsoft/coe-starter-kit/issues
Please upvote or comment on existing requests for this feature.
```

### Response Template: Desktop Flow Limitations

```markdown
Desktop flows (RPA) have specific limitations in the CoE Starter Kit:

**Known limitations:**
- Desktop flow run history requires separate API calls (performance impact)
- Some desktop flow properties not available via API
- Parent flow relationships may not be fully captured

**Current support:**
- Basic inventory of desktop flows ✓
- Desktop flow properties (name, description, state) ✓
- Desktop flow run history (limited) ⚠️
- Detailed action-level analysis ✗

**Recommendations:**
For detailed desktop flow analytics, consider:
1. Power Platform Center of Excellence (product feature)
2. Process Advisor for process mining
3. Custom PowerShell scripts for specific reporting needs
```

---

## Setup Wizard Guidance

### Response Template: Setup Wizard General

```markdown
The CoE Starter Kit includes a Setup Wizard to help with configuration:

**Setup Wizard location:**
After importing the solution, run the **CoE Setup and Upgrade Wizard** canvas app.

**Key configuration steps:**
1. **Environment variables**: Configure tenant-specific settings
2. **Connections**: Establish connections for all flows
3. **Turn on flows**: Activate inventory and core flows
4. **Run initial sync**: Trigger the Driver flow for first-time inventory

**Common setup issues:**

**"Setup Wizard not appearing"**
- Check app visibility settings
- Ensure you have permissions to the CoE environment
- Look under Solutions → Core Components → Apps

**"Environment variables not saving"**
- Use the Setup Wizard rather than editing directly
- Verify you have System Administrator role in the CoE environment
- Check for validation errors in the wizard

**"Flows not turning on"**
- Connections must be established first
- Check for connection consent prompts
- Verify admin permissions on all connections
```

### Response Template: First-Time Setup

```markdown
For first-time CoE Starter Kit setup:

**Pre-requisites:**
1. ✅ Dedicated Dataverse environment for CoE
2. ✅ Global Admin or Power Platform Admin role
3. ✅ Appropriate licensing (not trial)
4. ✅ English language pack enabled in environment

**Setup order:**
1. **Import Core solution** (required baseline)
2. **Run Setup Wizard** → Configure environment variables
3. **Establish connections** → Use admin account with full permissions
4. **Turn on flows** → Start with Driver flow
5. **Initial sync** → Manually trigger Driver flow
6. **Wait for completion** → Allow 30-60 minutes for first sync
7. **Verify data** → Check Dataverse tables for records
8. **Open Admin View** → Verify apps and environments appear

**First sync takes longer:**
- Initial inventory of large tenants can take 1-2 hours
- Subsequent syncs are faster (only deltas)
- Monitor flow run history for progress

**Documentation:**
Complete setup guide: https://learn.microsoft.com/power-platform/guidance/coe/setup
```

---

## Language and Localization

### Response Template: English-Only Requirement

```markdown
**Important: The CoE Starter Kit supports English only.**

**Requirements:**
- The environment where CoE is installed must have the English language pack enabled
- User running the setup must have English language preference
- Apps and flows are built with English language resources

**If you need multi-language support:**
1. Install CoE in an English environment (required)
2. For user-facing apps, you can:
   - Fork the canvas apps and add translations
   - Use custom labels for your language
   - Create language-specific views

**Known issues with non-English environments:**
- Flow errors due to locale-specific date/number formatting
- Missing labels or broken UI elements
- Connection configuration failures

**Workaround:**
- Ensure the base environment has English enabled (even if other languages are also enabled)
- Set the installing user's language preference to English during setup
- After setup, can switch back to preferred language for daily use
```

---

## Connection Issues

### Response Template: Connection Authentication

```markdown
Connection issues are common and usually resolve with re-authentication:

**Symptoms:**
- "Invalid connection" errors
- "401 Unauthorized" or "403 Forbidden"
- Flows suspended automatically
- "Please re-authenticate" messages

**Resolution:**

1. **Navigate to Connections**:
   - Power Apps portal → Environment → Connections
   
2. **Identify problematic connections**:
   - Look for warning icons
   - Check "Fix connection" prompts
   
3. **Re-authenticate**:
   - Click connection name
   - Select Edit
   - Re-enter credentials
   - **Critical**: Use the same admin account that has:
     - Power Platform Admin or Global Admin role
     - Access to all environments
     - Appropriate licensing

4. **Test connection**:
   - After re-authentication, test the connection
   - Try a simple action (e.g., list environments)

5. **Update flows**:
   - Flows should automatically use the updated connection
   - If not, edit the flow and re-select the connection

**Best practices:**
- Document which admin account is used for CoE connections
- Set up alerts before credentials expire
- Consider using Service Principal for production (doesn't expire)
- Review connections quarterly
```

### Response Template: Service Principal Setup

```markdown
For production environments, consider using Service Principal (app-based) authentication:

**Benefits:**
- No credential expiration
- Higher API limits
- Better for automation
- Follows least-privilege principle

**Setup requirements:**
1. Azure App Registration
2. Power Platform API permissions
3. Environment variables configuration
4. Application user in Dataverse

**Setup steps** (high-level):
1. Create Azure AD App Registration
2. Grant API permissions: Dynamics CRM API, PowerApps Service API
3. Create client secret
4. Add application user to CoE environment with System Administrator role
5. Configure environment variables:
   - Power Platform Admin Service Principal Azure App ID
   - Store client secret in Azure Key Vault (don't hardcode)
6. Update connection references to use app-based auth

**Documentation:**
See: https://learn.microsoft.com/power-platform/guidance/coe/setup#service-principal

**Note:** Service Principal setup is more complex but recommended for enterprise production use.
```

---

## Performance and Throttling

### Response Template: Large Tenant Performance

```markdown
For large tenants (1000+ apps, 100+ environments), performance optimization is important:

**Expected behavior:**
- Initial sync: 1-2 hours or more
- Subsequent syncs: 30-60 minutes
- Some API calls may be throttled (429 errors)

**Optimization strategies:**

1. **Sync schedule**:
   - Run Driver flow daily (default)
   - Avoid peak business hours
   - Stagger dependent flows if needed

2. **Pagination handling**:
   - Recent versions have improved pagination
   - Ensure you're on latest CoE Starter Kit version
   - Check for pagination-related updates in release notes

3. **Selective sync**:
   - Filter environments if needed (advanced configuration)
   - Exclude test/development environments from some syncs
   - Use environment groups for targeted inventory

4. **Service Principal**:
   - Higher API throttling limits
   - Better for large-scale automation
   - Recommended for tenants with 5000+ resources

5. **Monitor quotas**:
   - Power Platform Admin Center → Capacity
   - Track API request consumption
   - Plan for license upgrades if hitting limits

**Troubleshooting slow syncs:**
- Check flow run history for step-by-step timing
- Identify bottleneck actions (usually "List" operations)
- Review for retry logic on throttled requests
- Consider splitting large operations across multiple flows
```

### Response Template: Flow Suspended Automatically

```markdown
If flows are being automatically suspended:

**Common causes:**

1. **Connection issues**: Most common reason
   - Solution: Re-authenticate connections

2. **Repeated failures**: Flow fails multiple times in short period
   - Solution: Fix underlying issue, then turn flow back on

3. **Throttling**: Hitting API limits repeatedly
   - Solution: Adjust schedule, implement retry logic

4. **Permission changes**: Admin privileges removed
   - Solution: Verify account permissions

**Resolution:**

1. **Check flow run history**: Identify failure pattern
2. **Fix root cause**: Address the specific error
3. **Turn flow back on**: 
   - Go to flow details
   - Click "Turn on"
   - Monitor next run for success

4. **Monitor**: Watch for re-suspension
   - If it happens again, deeper investigation needed

**Prevention:**
- Regular connection maintenance
- Monitor flow health weekly
- Set up flow failure notifications
- Use robust error handling in custom flows
```

---

## Additional Standard Responses

### Response Template: Unmanaged Layers Blocking Update

```markdown
If you're unable to update the CoE Starter Kit solution:

**Error**: "Unmanaged layers exist" or similar

**Cause**: Custom changes were made directly to CoE components rather than extending them

**Resolution:**

1. **Identify unmanaged layers**:
   - Solutions → Core Components → Select component
   - View → Show dependencies or layers

2. **Remove unmanaged layers**:
   - For minor changes: Remove customizations
   - For extensive changes: Document them for reapplication

3. **Best practice for customizations**:
   - Don't modify CoE components directly
   - Create new components that extend CoE functionality
   - Use solution layering properly

4. **After removing layers**:
   - Retry solution update
   - Re-apply customizations as extensions

**Prevention:**
Always extend rather than modify CoE components to ensure smooth upgrades.
```

### Response Template: Upgrade from v3 to v4

```markdown
If upgrading from Sync Template v3 to v4:

**Key changes:**
- New flow architecture
- Improved performance
- Better error handling
- Updated connection requirements

**Upgrade process:**
1. **Backup**: Export current solution and data
2. **Review changelog**: Check breaking changes
3. **Import new version**: Use setup wizard for upgrade path
4. **Run configuration**: Update environment variables
5. **Test connections**: Verify all connections work
6. **Initial sync**: Trigger Driver flow
7. **Validation**: Confirm data is syncing correctly

**Common upgrade issues:**
- Old connections may need recreation
- Environment variables need reconfiguration
- Some custom flows may need updating

**Documentation:**
Upgrade guide: https://learn.microsoft.com/power-platform/guidance/coe/setup-upgrade
```

---

## Using This Playbook

**For CoE maintainers and support agents:**

1. Copy relevant sections as starting points for responses
2. Customize with specific details from the issue
3. Add links to related GitHub issues or documentation
4. Keep responses helpful, professional, and solution-oriented

**Contributing to this playbook:**

- Add new common patterns as they emerge
- Update responses based on solution evolution
- Include links to authoritative documentation
- Keep responses concise but complete

---

**Last Updated**: January 2026
**CoE Starter Kit Version**: 4.50.6+
