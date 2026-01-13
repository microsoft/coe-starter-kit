# Troubleshooting Guide: Inventory Collection and Dashboard Data Issues

This guide provides detailed troubleshooting steps for the most common issues related to inventory collection and Power BI dashboard data in the CoE Starter Kit.

## Table of Contents

- [Quick Diagnostic Checklist](#quick-diagnostic-checklist)
- [Issue 1: Apps and Flows Not Appearing in Dashboards](#issue-1-apps-and-flows-not-appearing-in-dashboards)
- [Issue 2: Inventory Collection Not Starting](#issue-2-inventory-collection-not-starting)
- [Issue 3: Inventory Flows Failing](#issue-3-inventory-flows-failing)
- [Issue 4: Power BI Connection Issues](#issue-4-power-bi-connection-issues)
- [Issue 5: Partial or Incomplete Data](#issue-5-partial-or-incomplete-data)
- [Understanding Inventory Flow Architecture](#understanding-inventory-flow-architecture)
- [Monitoring and Validation](#monitoring-and-validation)

## Quick Diagnostic Checklist

Use this checklist to quickly identify the source of your issue:

- [ ] Are the inventory flows turned ON? (They are OFF by default after import)
- [ ] Has the Setup Wizard been run successfully?
- [ ] Have the inventory flows completed at least one successful run?
- [ ] Has sufficient time passed for initial inventory? (30 min - 24 hours depending on tenant size)
- [ ] Are there records in Dataverse tables (Power Apps App, Flow, Environment)?
- [ ] Has the Power BI dataset been refreshed?
- [ ] Is Power BI connected to the correct CoE environment?
- [ ] Are all connection references authenticated?
- [ ] Does the service account have proper licenses (not trial)?
- [ ] Are there any DLP policies blocking required connectors?

## Issue 1: Apps and Flows Not Appearing in Dashboards

### Symptoms
- Power BI dashboards show no data or empty charts
- Recently created apps and flows don't appear even after refresh
- Dashboard worked before but stopped showing new items

### Solution: Complete First-Time Setup

If this is your first time setting up the CoE Starter Kit:

#### Step 1: Verify Solution Import

1. Navigate to https://make.powerapps.com
2. Select your CoE environment
3. Go to **Solutions**
4. Verify "Center of Excellence - Core Components" solution is installed
5. Note the version number (e.g., 4.50.6)

#### Step 2: Enable Required Flows

1. In the Core Components solution, select **Cloud flows**
2. Find and turn **ON** the following flows:

   **Critical Setup Flows:**
   - `SETUP WIZARD | Admin | Sync Template v3 (Setup)` - *Must run first*
   
   **Daily Inventory Flows:**
   - `Admin | Sync Template v3` - *Main orchestrator*
   - `Admin | Sync Apps v2` - *Collects app inventory*
   - `Admin | Sync Flows v3` - *Collects flow inventory*

   **Optional but Recommended:**
   - `Admin | Add Environment Variables to Environment Variable Values` - *Environment variable tracking*
   - `Admin | Add Shared Connections to Connection Reference` - *Connection tracking*
   - `Admin | Sync Audit Logs` - *Activity tracking (requires Audit Log solution)*

3. Ensure each flow shows "On" status (not "Suspended" or "Off")

> **Important:** Flows are OFF by default for security reasons. You must manually enable them after import.

#### Step 3: Run Initial Inventory

1. Locate `SETUP WIZARD | Admin | Sync Template v3 (Setup)` in Cloud flows
2. Click on the flow name to open it
3. Click **Run** button in the top-right corner
4. If prompted, confirm you want to run the flow
5. The flow will start executing

**What this flow does:**
- Initializes environment variables
- Creates initial inventory of all environments
- Triggers the first run of dependent inventory flows
- May take 10-30 minutes to complete

#### Step 4: Monitor Flow Execution

1. While the Setup Wizard is running, click **28-day run history**
2. Wait for the run to show "Succeeded" status
3. If it shows "Failed", click on the failed run to see error details
4. Common setup errors and solutions:
   - **Connection not authenticated**: Edit the flow and re-authenticate all connections
   - **Permission denied**: Ensure service account has Environment Admin role
   - **DLP policy violation**: Adjust DLP policies or use DLP-compliant connector groups

#### Step 5: Wait for Full Inventory Collection

After the Setup Wizard completes successfully:

**Small Tenant** (< 50 environments, < 100 apps/flows):
- Initial collection: 30-60 minutes
- First results in Dataverse: Within 1 hour

**Medium Tenant** (50-200 environments, 100-1000 apps/flows):
- Initial collection: 2-4 hours
- First results in Dataverse: Within 2-3 hours

**Large Tenant** (> 200 environments, > 1000 apps/flows):
- Initial collection: 4-24 hours
- First results in Dataverse: Within 4-6 hours
- Full inventory may take multiple days if very large

**How to check progress:**
1. Navigate to `Admin | Sync Template v3` flow
2. Check the 28-day run history
3. Look for runs that completed after the Setup Wizard
4. A successful run indicates that batch has been processed

> **Pro Tip:** The inventory runs in batches. You may see multiple runs of each sync flow as it processes all environments.

#### Step 6: Verify Data in Dataverse

Before checking Power BI, confirm data is being collected:

1. Go to https://make.powerapps.com
2. Select your CoE environment
3. Click **Tables** in the left navigation (under Dataverse)
4. Search for and open the following tables:

   **Check these tables for data:**
   
   | Table Name | What to Look For |
   |------------|------------------|
   | **Environment** | All your Power Platform environments should be listed |
   | **Power Apps App** | Canvas and model-driven apps from your tenant |
   | **Flow** | All cloud flows from your environments |
   | **Power Apps Connector** | Connectors used in apps and flows |
   | **Connection Reference** | Connection references from solutions |

5. Click on each table name and verify it has records (not empty)
6. If tables are empty, inventory collection has not completed yet

#### Step 7: Refresh Power BI

Only after confirming Dataverse has data:

1. **In Power BI Service (app.powerbi.com):**
   - Navigate to your CoE Starter Kit workspace
   - Find the "Center of Excellence - Core Dataset" (or similar name)
   - Click the **Refresh** icon next to the dataset
   - Wait for refresh to complete (check refresh history)

2. **Open the Dashboard:**
   - Navigate to the Power BI report
   - Visuals should now show data from your tenant
   - If still empty, proceed to Power BI connection verification

3. **Force Full Refresh (if needed):**
   - In Power BI Service, go to dataset settings
   - Click "Refresh now" again
   - Check for any refresh errors in history

### Solution: Troubleshoot Existing Setup

If your CoE Kit was working but stopped showing new data:

#### Check 1: Recent Flow Runs

1. Go to `Admin | Sync Template v3` flow
2. Check 28-day run history
3. Verify recent runs (should run daily):
   - **Last successful run** - When did it last succeed?
   - **Failed runs** - Are there recent failures?
   - **No recent runs** - Has the flow been disabled?

4. If flows are failing, click on failed run to see:
   - Which action failed
   - Error message details
   - Common errors:
     - Authentication expired
     - Connector rate limits
     - Permission changes
     - DLP policy changes

#### Check 2: Connection Health

1. In the Core Components solution, go to **Connection References**
2. Check status of all connections:
   - Power Platform for Admins
   - Dataverse (multiple references)
   - Office 365 Users
   - Any custom connectors

3. For each connection:
   - Ensure status is "Connected" (not "Expired" or "Error")
   - If expired, edit connection reference and re-authenticate
   - Verify the account has proper permissions

#### Check 3: Flow Suspension

Flows may auto-suspend after repeated failures:

1. Go to **Cloud flows** in the solution
2. Filter by "Suspended" status
3. For any suspended flows:
   - Review error history to understand why
   - Fix the underlying issue
   - Turn the flow back on
   - Test by running manually

#### Check 4: License Changes

If flows suddenly start failing with pagination errors:

1. Verify service account still has proper license:
   - Not trial license
   - Power Apps or Power Automate premium license
   - License hasn't expired or been removed

2. Test license adequacy:
   - Create a simple flow
   - Use "List rows" action with Dataverse
   - Set row limit to 5000
   - If it fails with pagination errors, license is insufficient

## Issue 2: Inventory Collection Not Starting

### Symptoms
- Flows are turned on but never run
- No runs appear in 28-day history
- Setup Wizard never completes

### Common Causes and Solutions

#### Cause 1: Flow Trigger Not Configured

**Solution:**
1. Open `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
2. Check if the flow has a trigger (button trigger or schedule)
3. If using schedule trigger, verify it's enabled
4. Manually trigger the flow using the **Run** button

#### Cause 2: Environment Variables Not Set

**Solution:**
1. In the Core Components solution, click **Environment variables**
2. Verify all required variables have current values:
   
   **Critical Variables:**
   - `Power Automate Environment Variable` - Should be your CoE environment ID
   - `Admin eMail` - Email for notifications
   - `TenantID` - Your Azure AD tenant ID (GUID)
   
3. If values are missing:
   - Click on the variable name
   - Add a new current value
   - Save and publish

#### Cause 3: DLP Policy Blocking Connectors

**Solution:**
1. Go to Power Platform Admin Center (admin.powerplatform.microsoft.com)
2. Navigate to **Data policies**
3. Check policies applied to your CoE environment
4. Verify these connectors are in "Business" data group:
   - Power Platform for Admins
   - Dataverse (or Common Data Service)
   - Office 365 Users
   - Office 365 Outlook (for notifications)
5. If connectors are blocked or in different groups:
   - Option A: Update DLP policy to allow connectors
   - Option B: Create exception for CoE environment
   - Option C: Use [DLP-compliant configuration](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#option-1-set-up-using-the-setup-wizard) if available

#### Cause 4: Insufficient Permissions

**Solution:**
1. Verify the user account running flows has:
   - **Environment Admin** role on all environments being inventoried
   - **System Administrator** role in CoE environment
   - Global Admin or Power Platform Admin role (for full tenant inventory)

2. To check permissions:
   - Power Platform Admin Center → Select environment → Users
   - Azure AD for Global Admin role
   
3. If permissions are missing, assign appropriate roles and wait 15-30 minutes for propagation

## Issue 3: Inventory Flows Failing

### Symptoms
- Flows run but show "Failed" status
- Error messages in flow run history
- Incomplete data in Dataverse tables

### Diagnostic Steps

#### Step 1: Identify the Failing Action

1. Open the failed flow run
2. Expand each action to find the one with red "X"
3. Note the action name and error message
4. Common failing actions:
   - List rows/List records - Usually permission or pagination issues
   - Create a new record - Usually permission or field validation issues
   - HTTP actions - Usually authentication or endpoint issues

#### Step 2: Common Errors and Solutions

**Error: "The caller with object id does not have permission..."**

*Solution:*
- Service account needs Environment Admin role
- For cross-environment inventory, needs role on each environment
- Assign missing permissions in Power Platform Admin Center

**Error: "Rate limit exceeded" or "429 Too Many Requests"**

*Solution:*
- Reduce frequency of inventory runs
- Implement throttling in flows (add delay actions)
- Spread inventory across multiple time windows
- Consider increasing API limits (enterprise plans)

**Error: "Could not find row to patch" or "Record not found"**

*Solution:*
- Old inventory data referencing deleted resources
- Run the cleanup flows to remove stale records
- Allow a full inventory cycle to refresh all data

**Error: "Pagination not supported" or "The feature you are trying to use requires a plan..."**

*Solution:*
- Service account has trial or insufficient license
- Assign proper Power Apps or Power Automate premium license
- Wait 24-48 hours after license assignment
- Verify license is active in Microsoft 365 admin center

**Error: "Invalid schema" or "Column does not exist"**

*Solution:*
- Schema mismatch between solution version and environment
- Verify all solution dependencies are imported
- Check for customized/deleted columns in tables
- Consider reimporting the solution
- Ensure English language pack is enabled in environment

#### Step 3: Resolve and Retry

1. Fix the identified issue based on error message
2. Wait a few minutes for changes to propagate
3. Manually trigger the flow again using **Run**
4. Monitor to ensure it succeeds
5. If it succeeds, allow scheduled runs to continue

## Issue 4: Power BI Connection Issues

### Symptoms
- Power BI shows "Can't connect to data source"
- Dataset refresh fails
- Visuals show "Couldn't load the data for this visual"

### Solution: Verify and Update Connection

#### Step 1: Check Dataset Connection

1. In Power BI Service, go to your workspace
2. Find the CoE dataset (hover for options)
3. Click **Settings** (gear icon)
4. Expand **Data source credentials**
5. Check the Dataverse connection shows correct environment

#### Step 2: Update Connection if Wrong

If the connection URL is wrong:

1. Click **Edit credentials** under Data source credentials
2. Update the **Server** to your CoE environment URL:
   - Format: `https://[your-org-name].crm.dynamics.com`
   - Get this from Power Platform Admin Center → Environment details
3. Authentication method: **OAuth2**
4. **Sign in** with account that has access to CoE environment
5. **Save** changes

#### Step 3: Refresh Dataset

1. Back in the workspace, find the dataset
2. Click **Refresh now** icon
3. Wait for refresh to complete
4. Check **Refresh history** if it fails:
   - Click the three dots (…) next to dataset
   - Select **Refresh history**
   - Review any errors

#### Step 4: Verify Power BI Gateway (if on-premises)

If using on-premises data gateway:

1. Ensure gateway is online
2. Verify gateway has latest version installed
3. Check gateway can reach your Dataverse environment
4. Update gateway credentials if needed

### Solution: Permission Issues

**Error: "User does not have access to the data source"**

*Solution:*
1. The Power BI user needs security role in CoE environment
2. In Power Platform Admin Center:
   - Select CoE environment
   - Go to Users
   - Find the Power BI user
   - Assign appropriate security role (usually System Administrator or custom role)
3. Wait 15-30 minutes for permissions to propagate
4. Try dataset refresh again

## Issue 5: Partial or Incomplete Data

### Symptoms
- Some environments, apps, or flows are missing
- Data seems truncated (e.g., exactly 50, 100, or 5000 records)
- Inventory stopped collecting after certain point

### Diagnostic: License and Pagination

#### Test 1: Check Record Counts

1. In Dataverse, check total records in key tables:
   - Go to each table (Environment, Power Apps App, Flow)
   - Note total record count shown
   
2. Compare with known inventory:
   - Do you have more environments than shown?
   - Are recently created apps missing?
   - If counts are suspiciously round (50, 100, 500), likely pagination issue

#### Test 2: Verify License Adequacy

Create a test flow to check pagination:

1. Create new cloud flow in CoE environment
2. Use **Instant cloud flow** (button trigger)
3. Add action: **List rows** (Dataverse connector)
4. Select table: **Environments**
5. Set **Row count**: 5000
6. Save and run the flow
7. Check results:
   - **Success with all records**: License is adequate
   - **Fails with pagination error**: License is insufficient
   - **Returns exactly 100 records**: Trial license limitation

### Solution: Upgrade License

If pagination issues detected:

1. Service account needs one of:
   - Power Apps per user license
   - Power Automate per user license  
   - Office 365 E3/E5
   - Dynamics 365 license

2. Assign license in Microsoft 365 admin center
3. Wait 24-48 hours for full activation
4. Verify license is active
5. Re-run inventory flows

### Solution: Full Inventory Not Complete

If license is correct but data still incomplete:

1. Check if initial inventory has finished:
   - Large tenants can take 24+ hours
   - Each sync flow may run multiple times
   - Wait for all flows to show successful runs

2. Verify no flows are failing:
   - Check run history on all Admin | Sync flows
   - Address any failures
   - Re-run failed flows manually

3. Force a full refresh:
   - Turn off all inventory flows
   - Wait 5 minutes
   - Turn on `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
   - Run it manually
   - Wait for completion
   - Verify other flows trigger automatically

## Understanding Inventory Flow Architecture

### Flow Hierarchy

```
SETUP WIZARD | Admin | Sync Template v3 (Setup)
    ↓
Admin | Sync Template v3 (Main Orchestrator)
    ↓
    ├── Admin | Sync Apps v2
    ├── Admin | Sync Flows v3
    ├── Admin | Sync Connectors
    ├── Admin | Sync Connection References
    └── [Other child flows...]
```

### How Inventory Collection Works

1. **Setup Wizard** runs once to initialize everything
2. **Admin | Sync Template v3** runs daily (scheduled) to orchestrate inventory
3. **Child flows** (Sync Apps, Sync Flows, etc.) collect specific resource types
4. Each flow processes data in **batches** to respect API limits
5. Data is written to **Dataverse tables** in real-time
6. **Power BI** reads from Dataverse when dataset refreshes

### Expected Flow Run Patterns

**Initial Setup (Day 1):**
- Setup Wizard: 1 run (10-30 minutes)
- Sync Template v3: Multiple runs (batching through environments)
- Child flows: Multiple runs per parent run
- Total time: 30 minutes to 24+ hours depending on size

**Daily Ongoing (Day 2+):**
- Sync Template v3: 1 run per day (scheduled)
- Child flows: Triggered by parent as needed
- Runs should complete within 1-4 hours
- Failures should be rare once stable

## Monitoring and Validation

### Daily Health Check

Perform these checks weekly or after making changes:

1. **Flow Status Check:**
   ```
   ✓ All inventory flows are "On" (not Suspended or Off)
   ✓ No failed runs in last 7 days
   ✓ Flows are running on schedule
   ```

2. **Data Freshness Check:**
   ```
   ✓ Dataverse tables updated recently (check Modified On)
   ✓ New resources appear within 24 hours
   ✓ Deleted resources removed within 48 hours
   ```

3. **Power BI Check:**
   ```
   ✓ Dataset refreshing successfully
   ✓ Last refresh timestamp is recent
   ✓ Visuals showing expected data
   ```

### Key Performance Indicators

Monitor these metrics:

| Metric | Target | Warning | Action Needed |
|--------|--------|---------|---------------|
| Flow Success Rate | > 95% | < 90% | Investigate failures |
| Inventory Completion Time | < 4 hours | > 8 hours | Check for bottlenecks |
| Data Freshness | < 24 hours | > 48 hours | Check flow schedules |
| Missing Records | 0% | > 5% | Run full inventory |
| Power BI Refresh | Daily | > 3 days | Check connection |

### Troubleshooting Tools

**Built-in Flow Run History:**
- Shows detailed execution logs
- Identifies failing actions
- Displays error messages and codes

**Dataverse Table Views:**
- Verify actual data being collected
- Check for missing or incorrect data
- Review record timestamps

**Power BI Query Diagnostics:**
- In Power BI Desktop: Tools → Options → Diagnostics
- Helps identify query performance issues
- Shows data source connection details

## Getting Additional Help

If you've followed all troubleshooting steps and still have issues:

1. **Gather diagnostic information:**
   - CoE Starter Kit version
   - Screenshots of error messages
   - Flow run history (successful and failed runs)
   - Dataverse table record counts
   - License types for service account

2. **Search existing issues:**
   - GitHub: https://github.com/microsoft/coe-starter-kit/issues
   - Look for similar symptoms and solutions

3. **Create a new issue:**
   - Use the bug report template
   - Include all diagnostic information
   - Specify exact steps taken
   - Note what you've already tried

4. **Consult documentation:**
   - Official docs: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
   - Setup guide: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components
   - Troubleshooting: https://learn.microsoft.com/power-platform/guidance/coe/faq

---

*Last Updated: 2026-01-07*
*For additional resources, see [COE-Kit-Common-GitHub-Responses.md](./COE-Kit-Common-GitHub-Responses.md)*
