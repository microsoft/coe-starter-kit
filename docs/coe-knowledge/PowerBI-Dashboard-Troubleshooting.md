# Power BI Dashboard Troubleshooting Guide

This document provides detailed troubleshooting steps for common issues with the CoE Starter Kit Power BI Dashboard.

## Table of Contents

1. [Dashboard Overview](#dashboard-overview)
2. [Blank Dashboard - No Data Showing](#blank-dashboard---no-data-showing)
3. [Partial Data Missing](#partial-data-missing)
4. [Connection Errors](#connection-errors)
5. [Refresh Failures](#refresh-failures)
6. [Permission Issues](#permission-issues)

---

## Dashboard Overview

The CoE Starter Kit Power BI Dashboard provides:
- Environment overview and trends
- App and Flow inventory analytics
- Maker activity and engagement metrics
- Compliance and governance insights
- Connector usage analysis

### Dashboard Types

1. **Power BI Dashboard (Desktop)**
   - Template file: `Production_CoEDashboard_MMMYYYY.pbit`
   - Requires Power BI Desktop
   - Connects directly to Dataverse
   - User must have appropriate permissions

2. **Power BI Service Dashboard**
   - Published from Desktop
   - Can be shared with broader audience
   - Requires Power BI Pro/Premium licenses
   - Supports scheduled refresh

---

## Blank Dashboard - No Data Showing

### Symptom

When opening the Power BI dashboard, one or more of the following occurs:
- All charts show "blank" or no data
- Message: "There are no Environments in this view to create a Environments chart"
- All visualizations are empty
- Tables show no records

![Example of blank dashboard](https://github.com/user-attachments/assets/910d8877-9d2c-401d-a932-52d0196c81a2)

### Root Causes (In Order of Likelihood)

1. **Inventory hasn't completed** - Most common cause
2. **Wrong environment URL** - Dashboard connected to different environment
3. **Data source not configured** - First-time setup not complete
4. **Insufficient permissions** - User can't read CoE tables
5. **Data refresh needed** - Stale data cached

---

### Cause 1: Inventory Collection Not Complete

**Most common cause** - Initial inventory collection takes several hours.

#### How to Verify

1. **Check when setup was completed:**
   - If setup was just finished: Wait 4-8 hours
   - If setup was days/weeks ago: Proceed to other checks

2. **Verify inventory flows are running:**
   - Navigate to Cloud flows in CoE environment
   - Find "Admin | Sync Template v3" flow
   - Check 28-day run history
   - Look for:
     - ✅ Successful runs (green checkmarks)
     - ❌ Failed runs (red X)
     - ⏱️ In-progress runs

3. **Check data in Dataverse tables:**
   - Open CoE environment in Power Apps
   - Navigate to **Tables** (under Dataverse)
   - Check key tables:

   | Table Name | What to Check |
   |------------|---------------|
   | Environment | Should have entries for your tenant's environments |
   | Power Apps App | Should contain app inventory |
   | Flow | Should contain flow inventory |
   | Power Apps Connector | Should list connectors |
   | Maker | Should show maker information |

4. **Verify record counts:**
   - If tables are empty → Inventory flows haven't run successfully
   - If tables have data but dashboard is blank → Connection/permission issue

#### Expected Timeline

- **First-time inventory**: 4-8 hours minimum
- **Large tenants** (1000+ environments): Up to 24 hours
- **Incremental updates**: 1-2 hours

#### Resolution

If inventory hasn't completed:

1. **Wait for completion:**
   - Check flow run history every 2-3 hours
   - Don't interrupt running flows

2. **If flows failed:**
   - Review error messages in flow run history
   - Common issues:
     - DLP policy violations
     - Connection authentication failures
     - License/permission issues
   - Fix underlying issue and re-run

3. **If flows aren't running at all:**
   - See [Setup Wizard Troubleshooting - Inventory Flows Not Running](./Setup-Wizard-Troubleshooting.md#inventory-flows-not-running)

---

### Cause 2: Wrong Environment URL

Dashboard is connected to a different environment than where CoE is installed.

#### How to Verify

1. In Power BI Desktop, go to **Transform Data** > **Data source settings**
2. Check the Dataverse URL configured
3. Compare with your CoE environment URL

#### Finding Your CoE Environment URL

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select **Environments**
3. Find your CoE environment
4. Note the **Environment URL** field
5. Format should be: `https://[orgname].crm[region].dynamics.com/`

Example URLs:
- North America: `https://contoso.crm.dynamics.com/`
- Europe: `https://contoso.crm4.dynamics.com/`
- Asia: `https://contoso.crm5.dynamics.com/`

#### Resolution

1. Open Power BI file (.pbit template)
2. When prompted for parameters:
   - Enter correct CoE environment URL
   - Don't include trailing slash if not required
3. Sign in with appropriate credentials
4. Wait for data to load
5. Save as .pbix file

---

### Cause 3: Data Source Not Configured (First Time Setup)

First-time opening of .pbit template requires configuration.

#### Proper Setup Steps

1. **Download the correct template:**
   - Get latest .pbit file from CoE Starter Kit release
   - File name: `Production_CoEDashboard_[version].pbit`
   - Don't use old/outdated templates

2. **Open template in Power BI Desktop:**
   - Requires Power BI Desktop (latest version recommended)
   - Don't try to open .pbit in Power BI Service

3. **Enter parameters when prompted:**
   ```
   Parameter: CDS Environment Instance URL
   Value: https://[your-org].crm[region].dynamics.com/
   ```

4. **Sign in:**
   - Use your organizational account
   - Account must have access to CoE environment
   - May need to authenticate multiple times

5. **Load data:**
   - Click "Load" (not "Transform Data" for first time)
   - Wait for all data to load (may take several minutes)
   - Progress bar shows loading status

6. **Verify data:**
   - Check that visualizations show data
   - Navigate through all report pages
   - Verify counts seem reasonable

7. **Save as .pbix:**
   - File > Save As
   - Save to local location or OneDrive
   - Can now publish to Power BI Service if desired

---

### Cause 4: Insufficient Permissions

User doesn't have read access to CoE Dataverse tables.

#### Required Permissions

User viewing dashboard needs:
- Read access to CoE environment
- Access to CoE Dataverse tables
- Appropriate security role assignment

#### How to Verify

1. **Check environment access:**
   - Can you open the CoE environment in Power Apps?
   - Can you see the environment in your environment list?

2. **Check table access:**
   - In CoE environment, try to open "Environments" table
   - Can you view records?
   - If "Access Denied" → Permission issue

3. **Check security roles:**
   - In CoE environment, go to Settings > Security > Users
   - Find your user
   - Check assigned security roles
   - Should have role with read access to CoE tables

#### Resolution

Have an admin grant appropriate permissions:

1. **Option A: Add to CoE security role**
   - Assign "CoE Dashboard Reader" role (if exists)
   - Or create custom role with read access

2. **Option B: Share environment**
   - Share environment with user
   - Assign appropriate role

3. **Verify:**
   - Sign out of Power BI Desktop
   - Close and reopen
   - Re-authenticate
   - Try loading data again

---

### Cause 5: Data Refresh Needed

Cached data is stale or corrupted.

#### Resolution

In Power BI Desktop:

1. Click **Refresh** button in ribbon
2. Wait for refresh to complete
3. Check if data now appears

If refresh fails:
- Check error message
- May indicate connection or permission issue
- See [Connection Errors](#connection-errors) section

---

## Partial Data Missing

### Symptom

Dashboard shows some data but specific sections are empty:
- Some charts show data, others don't
- Specific pages are blank while others work
- Specific time periods missing

### Common Causes

1. **Filters applied** - Report/page filters hiding data
2. **Selective inventory** - Some object types not collected yet
3. **Query failures** - Specific queries timing out or failing

### Resolution

1. **Check filters:**
   - Click "Filter pane" in Power BI
   - Check page-level and report-level filters
   - Clear filters and refresh

2. **Verify inventory scope:**
   - Check which inventory flows have run successfully
   - Some flows collect different object types
   - May need to wait for specific flows to complete

3. **Check query diagnostics:**
   - In Power BI Desktop: Transform Data > View > Query Diagnostics
   - Enable diagnostics and refresh
   - Check for failed queries
   - May indicate timeout or permission issues

---

## Connection Errors

### Symptom

Error messages when trying to connect or refresh:
- "Unable to connect"
- "Access denied"  
- "Invalid connection credentials"
- "Datasource.Error"

### Common Connection Errors and Resolutions

#### Error: "Unable to connect to the datasource"

**Cause:** Network connectivity or URL issues

**Resolution:**
1. Verify internet connectivity
2. Check environment URL is correct
3. Ensure environment is accessible (not deleted/disabled)
4. Try accessing environment via Power Apps to confirm it's available

#### Error: "Access is denied"

**Cause:** Permission issues

**Resolution:**
1. Verify user has environment access
2. Check security role assignments
3. Ensure user is not disabled in Azure AD
4. Try signing out and back in

#### Error: "Invalid credentials"

**Cause:** Authentication issues

**Resolution:**
1. In Power BI Desktop: File > Options > Data source settings
2. Find the Dataverse connection
3. Click "Edit Permissions"
4. Click "Edit" under Credentials
5. Sign in again with valid credentials
6. Ensure using organizational account (not personal)

#### Error: "Gateway is required"

**Cause:** On-premises data gateway configuration issue

**Resolution:**
1. CoE Dataverse connection should NOT require gateway
2. Check data source settings
3. Ensure connection is set to "Cloud" not "On-premises"
4. May need to delete and recreate connection

---

## Refresh Failures

### Symptom

When clicking refresh in Power BI Desktop or scheduled refresh in Power BI Service fails.

### Common Causes and Resolutions

#### Timeout Errors

**Symptom:** Query timeout, operation cancelled

**Causes:**
- Large data volume
- Slow network
- Complex queries

**Resolution:**
1. Reduce query complexity if custom queries added
2. Limit data to recent time periods
3. Check network connection quality
4. Try refreshing during off-peak hours

#### Authentication Failures

**Symptom:** Refresh fails with credential errors

**Resolution:**
1. Re-authenticate data sources
2. Ensure credentials haven't expired
3. Check if MFA is required
4. Verify service account (if used) is still valid

#### Power BI Service Refresh Failures

**Symptom:** Scheduled refresh in Power BI Service fails

**Resolution:**
1. Check if using personal/local data sources (not supported)
2. Verify gateway configuration if required
3. For Dataverse: Should use cloud connection (no gateway)
4. Check dataset credentials in Power BI Service
5. Review refresh history for specific error messages

---

## Permission Issues

### Granting Dashboard Access to Others

#### Scenario 1: Share Power BI Report (Service)

1. Publish .pbix to Power BI Service
2. Users need:
   - Power BI Pro license (or workspace in Premium)
   - Access to CoE Dataverse environment
   - Appropriate security role

3. In Power BI Service:
   - Click **Share** on report
   - Add users/groups
   - Grant "Read" permission
   - Users will also need environment access

#### Scenario 2: Share Power BI Desktop File

1. Share .pbix file with users
2. Users need:
   - Power BI Desktop installed
   - Access to CoE Dataverse environment
   - Appropriate security role
   - Network access to environment

3. Users open file and authenticate

#### Scenario 3: Create "Reader" Role

Best practice for dashboard-only access:

1. Create custom security role "CoE Dashboard Reader"
2. Grant read access to CoE tables:
   - Environment
   - Power Apps App
   - Flow
   - Power Apps Connector
   - Maker
   - etc.
3. Assign role to dashboard users
4. Users can now refresh data

---

## Diagnostic Checklist

Use this checklist to systematically troubleshoot blank dashboard:

- [ ] Setup wizard completed successfully
- [ ] At least 4-8 hours elapsed since setup completion
- [ ] Inventory flows show successful run history
- [ ] Dataverse tables contain records (Environment, Apps, Flows)
- [ ] Power BI template (.pbit) is latest version
- [ ] Correct environment URL used in Power BI connection
- [ ] User has access to CoE environment
- [ ] User has read permissions on CoE tables
- [ ] Authentication successful in Power BI
- [ ] No DLP policies blocking connection
- [ ] Data refresh completes without errors
- [ ] No filters hiding data
- [ ] Using supported browser/Power BI Desktop version

---

## Quick Resolution Steps

For the most common scenario (blank dashboard after setup):

1. ✅ **Confirm inventory completion**
   - Check: Cloud flows > "Admin | Sync Template v3" > Run history
   - Check: Dataverse tables have records
   
2. ✅ **Verify Power BI configuration**
   - Open .pbit template (not .pbix)
   - Enter correct environment URL: `https://[org].crm[region].dynamics.com/`
   - Sign in with admin account
   
3. ✅ **Wait for data load**
   - Initial load may take 5-10 minutes
   - Don't close during loading
   
4. ✅ **Verify visualizations**
   - Check all report pages
   - Clear any filters
   - Save as .pbix when confirmed working

---

## Additional Resources

### Documentation
- [Setup Power BI Dashboard](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi)
- [Power BI Dashboard Explained](https://learn.microsoft.com/en-us/power-platform/guidance/coe/power-bi)
- [Troubleshooting Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#troubleshooting)

### Video Tutorials
- [Power BI Dashboard Walkthrough](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi#watch-a-walk-through)

### Community Support  
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power BI Community](https://community.powerbi.com/)

---

*Last updated: 2025-12-10*
