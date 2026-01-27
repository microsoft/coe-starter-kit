# Issue Response: App Usage Data Not Updating (App Last Launched On)

## Issue Summary
Users report that the "App Last Launched On" field in the Power Platform Admin View app stops updating after a certain date, even though apps are actively being used daily.

**Common symptoms:**
- ✅ App inventory is working correctly
- ✅ Apps show in the Admin View
- ❌ "App Last Launched On" field shows an old date (e.g., October 29, 2025)
- ❌ Usage data appears "frozen" despite daily app usage
- ❓ User answered "None" when asked about telemetry/inventory method

## Root Cause ✅

The "App Last Launched On" field is **NOT** populated by the standard inventory flows. It requires the **CoE Audit Log Components** to be installed and configured.

### How App Usage Data Works

```
┌─────────────────────────────────────────────────────────────────┐
│                   App Usage Data Collection Flow                 │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 1. Microsoft 365 Audit Logs                                      │
│    - Captures "LaunchPowerApp" events                            │
│    - Requires M365 E3/E5 license or audit log add-on            │
│    - Must be enabled at tenant level                             │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. CoE Audit Log Solution (CenterofExcellenceAuditLogs)        │
│    - Admin | Sync Audit Logs V2 flow                           │
│    - Pulls audit events from M365 Management API or Graph API   │
│    - Stores in admin_auditlog table                             │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. Admin | Audit Logs - Update Data V2 flow                    │
│    - Triggered when LaunchPowerApp event is recorded            │
│    - Updates admin_applastlaunchedon field in admin_apps table  │
│    - This populates "App Last Launched On" in Admin View app    │
└─────────────────────────────────────────────────────────────────┘
```

## Why Usage Data Stops After a Specific Date 🔍

If usage data stops on a specific date (e.g., October 29, 2025), it means:

1. **Audit Log collection stopped** on that date, OR
2. **Audit Log solution was never set up** (old data may be from initial testing/setup), OR
3. **M365 Audit Logs were disabled** at the tenant level, OR
4. **Required licenses expired or were removed**, OR
5. **Flows are turned off or failing**

## Solution 🎯

### Step 1: Verify Current Configuration

Check if you have the Audit Log solution installed:

1. Go to **Power Apps** → **Solutions**
2. Look for **"Center of Excellence - Audit Logs"** solution
3. Check the version number

**If you DON'T see this solution** → You need to install it (see Step 2)  
**If you DO see this solution** → Check if flows are running (see Step 3)

### Step 2: Install Audit Log Components (If Not Installed)

If you answered **"None"** to the telemetry method question, you need to install and configure the Audit Log components.

#### Prerequisites

Before installing the Audit Log solution, verify you have:

✅ **Microsoft 365 Licensing** (one of the following):
   - Microsoft 365 E3 or E5 license
   - Office 365 E3 or E5 license
   - Microsoft 365 Business Premium
   - **OR** Microsoft Purview Audit (Standard) add-on

✅ **Microsoft 365 Audit Logging Enabled**:
   1. Go to [Microsoft Purview Compliance Portal](https://compliance.microsoft.com)
   2. Navigate to **Audit** → **Search**
   3. If prompted, click **Start recording user and admin activity**
   4. Wait 24 hours for audit logs to become available

✅ **Required Admin Roles**:
   - Power Platform Administrator
   - Global Administrator or Compliance Administrator (for audit log access)

#### Installation Steps

1. **Download the Audit Log Solution**:
   - Go to [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases)
   - Download `CenterofExcellenceAuditLogs_x.xx_managed.zip`
   - Version should match your Core Components version (e.g., 4.50.7)

2. **Import the Solution**:
   - Go to **Power Apps** → **Solutions**
   - Click **Import solution**
   - Browse and select the downloaded zip file
   - Click **Next**

3. **Configure Connections**:
   During import, you'll be prompted to configure connections:
   - **Dataverse**: Use the same connection as Core Components
   - **HTTP with Azure AD**: Create new connection
     - **Base Resource URL**: `https://manage.office.com`
     - **Azure AD Resource URI**: `https://manage.office.com`

4. **Complete Import**:
   - Click **Import** and wait for the process to complete
   - This may take 10-20 minutes

5. **Run the Setup Wizard** (Recommended):
   - Open the **CoE Setup and Upgrade Wizard** app
   - Navigate to the **Audit Logs** section
   - Follow the guided setup process
   - The wizard will:
     - Configure environment variables
     - Set up the M365 Management API subscription
     - Enable required flows
     - Trigger initial audit log collection

   **Environment Variables to Configure**:
   
   | Variable | Default | Description |
   |----------|---------|-------------|
   | `admin_AuditLogsAudience` | `https://manage.office.com` | Audience for M365 Management API |
   | `admin_AuditLogsAuthority` | `https://login.windows.net` | Authority URL for authentication |
   | `admin_AuditLogsMinutestoLookBack` | 65 | Minutes to look back when fetching logs |
   | `admin_AuditLogsUseGraphAPI` | false | Use Graph API instead of Management API |
   | `admin_TenantID` | (your tenant ID) | Your Azure AD Tenant ID |

6. **Start the Subscription Flow**:
   - Go to **Power Automate** → **Solutions** → **Center of Excellence - Audit Logs**
   - Find **Admin | Audit Logs - Office 365 Management API Subscription**
   - Turn on the flow
   - Click **Run** to start the subscription
   - This subscribes to M365 audit log events

7. **Enable Audit Log Sync Flows**:
   Enable these flows in the following order:
   1. **Admin | Audit Logs - Office 365 Management API Subscription** (already done in step 6)
   2. **Admin | Audit Logs - Sync Audit Logs V2** (scheduled flow, runs hourly)
   3. **Admin | Audit Logs - Update Data V2** (automated, triggers on LaunchPowerApp events)

8. **Wait for Initial Data Collection**:
   - The **Sync Audit Logs V2** flow runs every hour by default
   - It may take 2-3 hours before you see usage data
   - Check flow run history to verify it's working

### Step 3: Troubleshoot Existing Installation

If you have the Audit Log solution installed but usage data stopped updating:

#### Check Flow Status

1. Go to **Power Automate** → **Solutions** → **Center of Excellence - Audit Logs**
2. Check these flows:

   | Flow Name | Expected State | Purpose |
   |-----------|---------------|---------|
   | **Admin \| Audit Logs - Office 365 Management API Subscription** | On | Creates M365 audit log subscription |
   | **Admin \| Audit Logs - Sync Audit Logs V2** | On | Pulls audit events hourly |
   | **Admin \| Audit Logs - Update Data V2** | On | Updates app last launched date |

3. If any flows are **Off**, turn them on
4. Check the **Run History** for each flow:
   - Look for failures (red X icons)
   - Review error messages
   - Common errors below

#### Common Errors and Solutions

**Error: "Unauthorized" or "401" when calling M365 Management API**
- **Cause**: HTTP with Azure AD connection not configured correctly
- **Solution**: 
  1. Go to **Data** → **Connections**
  2. Find **HTTP with Azure AD** connection
  3. Delete and recreate with correct settings:
     - **Base Resource URL**: `https://manage.office.com`
     - **Azure AD Resource URI**: `https://manage.office.com`
  4. Update the connection reference in the solution

**Error: "Forbidden" or "403"**
- **Cause**: User lacks Global Admin or Compliance Admin role
- **Solution**: Assign the user one of these roles in Azure AD

**Error: "Subscription not found" or "Subscription disabled"**
- **Cause**: M365 Management API subscription expired or was disabled
- **Solution**: 
  1. Run the **Office 365 Management API Subscription** flow manually
  2. This will recreate the subscription
  3. Check the flow run history to confirm success

**Error: "Audit logs not available"**
- **Cause**: M365 audit logging not enabled at tenant level
- **Solution**: 
  1. Go to [Microsoft Purview Compliance Portal](https://compliance.microsoft.com)
  2. Navigate to **Audit** → **Search**
  3. Click **Start recording user and admin activity**
  4. Wait 24 hours for logs to become available

**Error: Flow runs but no data appears**
- **Cause**: No LaunchPowerApp events in the time window
- **Solution**: 
  1. Launch a few apps to generate events
  2. Wait 1-2 hours for audit logs to be processed by Microsoft
  3. Wait for the sync flow to run (runs hourly)
  4. Check the admin_auditlog table for LaunchPowerApp events

#### Verify Microsoft 365 Audit Logging

1. Go to [Microsoft Purview Compliance Portal](https://compliance.microsoft.com)
2. Navigate to **Audit** → **Search**
3. Set date range to include today
4. Add filter: **Activities** → **Launched Power Apps**
5. Click **Search**

**Expected results:**
- ✅ You should see recent app launch events
- ❌ If you see "No results found" → Audit logging may not be enabled or functional

**If audit logging is not working:**
1. Verify licensing (M365 E3/E5 or audit add-on)
2. Verify audit logging is enabled (may take 24 hours to activate)
3. Contact Microsoft Support if issues persist

#### Check Environment Variables

1. Go to **Power Apps** → **Solutions** → **Center of Excellence - Audit Logs**
2. Open **Environment Variables**
3. Verify these are set correctly:

   | Variable | Check |
   |----------|-------|
   | `admin_TenantID` | Has your actual Azure AD Tenant ID (GUID) |
   | `admin_AuditLogsAudience` | `https://manage.office.com` (commercial) |
   | `admin_AuditLogsAuthority` | `https://login.windows.net` (commercial) |
   | `admin_AuditLogsMinutestoLookBack` | 65 (or higher) |

   **For GCC/GCC High**, these values are different - see [Sovereign Cloud Support](sovereign-cloud-support.md)

#### Check Audit Log Data

1. Go to **Power Apps** → **Tables**
2. Open **admin_auditlog** table
3. View data:
   - Filter by **admin_operation** = "LaunchPowerApp"
   - Sort by **admin_creationtime** (newest first)

**What to look for:**
- ✅ **Recent records (within last hour)** → Audit sync is working
- ⚠️ **Old records only (e.g., from October)** → Audit sync stopped working
- ❌ **No records** → Audit log collection never started or was deleted

#### Re-subscribe to M365 Management API

If the subscription expired (after 7 days of inactivity):

1. Go to **Power Automate**
2. Find **Admin | Audit Logs - Office 365 Management API Subscription** flow
3. Click **Run** to manually execute
4. Check run history to verify success
5. The flow should show "Subscription created" or "Subscription already exists"

### Step 4: Alternative Solutions

If you cannot use M365 Audit Logs (licensing, compliance, or technical issues), you have limited alternatives:

#### Option A: Use Power BI Usage Analytics (Partial)
- **What it provides**: 
  - App launch counts and trends
  - User engagement metrics
  - NOT the "Last Launched" timestamp in CoE tables
- **How to access**:
  - Power BI Admin Portal → Usage Metrics
  - Limited to Power BI workspace analysis
- **Limitation**: Does NOT populate the CoE Starter Kit "App Last Launched On" field

#### Option B: Export Audit Logs Manually
- **What it provides**: 
  - Periodic audit log data
  - Can import to CoE using CSV import flow
- **How to do it**:
  1. Export audit logs from M365 Compliance Portal
  2. Filter for "Launched Power Apps" activity
  3. Use **Admin | Audit Logs - Load events from exported Audit Log CSV file** flow
  4. Import the CSV data
- **Limitation**: Manual process, not automated, labor-intensive

#### Option C: Custom Solution with PowerShell
- **What it provides**: 
  - Programmatic access to audit logs
  - Can automate data collection
- **How to do it**:
  1. Use `Search-UnifiedAuditLog` PowerShell cmdlet
  2. Query for "LaunchedPowerApp" operations
  3. Parse and insert into Dataverse
- **Limitation**: Requires custom development, maintenance burden

#### Option D: Disable Usage Tracking
- **What it provides**: 
  - Simplified CoE deployment
  - Removes dependency on audit logs
- **How to do it**:
  1. Accept that "App Last Launched On" will not be populated
  2. Focus on other governance metrics (app count, environments, makers, etc.)
  3. Use other inventory data for governance decisions
- **Limitation**: Loss of usage insights and adoption metrics

**Recommendation**: Option A (M365 Audit Logs via Audit Components) is the supported and recommended approach. The alternatives are workarounds with significant limitations.

## Verification Steps 🔍

After completing the setup or troubleshooting:

1. **Launch a test app** (any app in your tenant)
2. **Wait 1-2 hours** (for audit logs to be processed by Microsoft)
3. **Wait for the Sync flow to run** (runs hourly, or run manually)
4. **Check the admin_auditlog table**:
   - Go to Power Apps → Tables → admin_auditlog
   - Filter by admin_operation = "LaunchPowerApp"
   - You should see a record for your test app launch
5. **Check the admin_apps table**:
   - Find your test app
   - The admin_applastlaunchedon field should be updated
6. **Check the Admin View app**:
   - Open the Power Platform Admin View app
   - Find your test app
   - "App Last Launched On" should show the recent timestamp

## Timeline Expectations ⏱️

**After initial setup:**
- ⏳ **0-24 hours**: M365 audit logging activation (if newly enabled)
- ⏳ **1-2 hours**: Audit events appear in M365 (after app launch)
- ⏳ **1 hour**: Sync flow runs and pulls audit events
- ⏳ **Real-time**: Update Data V2 flow updates app record
- ✅ **Total**: 2-26 hours for first usage data to appear

**During normal operation:**
- User launches app → M365 audit log created within 1-2 hours
- Sync flow runs hourly → Audit log pulled into CoE
- Update Data V2 flow triggers immediately → App record updated
- **Typical lag**: 1-3 hours from app launch to "Last Launched On" update

## Licensing Requirements 💰

To collect app usage data via audit logs, you need:

| License Type | Audit Log Availability | Notes |
|-------------|----------------------|-------|
| **Microsoft 365 E3/E5** | ✅ Included | Recommended |
| **Office 365 E3/E5** | ✅ Included | Recommended |
| **Microsoft 365 Business Premium** | ✅ Included | Limited to 300 users |
| **Microsoft Purview Audit (Standard)** | ✅ Add-on | Available for other license types |
| **Microsoft 365 F3** | ❌ Not included | Cannot use audit logs |
| **Power Apps per app/per user** | ❌ Not included | Cannot use audit logs (use E3/E5 or add-on) |

**Important**: The CoE Starter Kit service account (connection owner) does NOT need an E3/E5 license. However, the **tenant** must have the required licenses to enable M365 audit logging.

## Summary Checklist ✅

Use this checklist to diagnose and resolve app usage data issues:

- [ ] **Verify CoE Core Components are installed and working**
- [ ] **Verify Microsoft 365 audit logging is enabled at tenant level**
- [ ] **Verify required licensing (M365 E3/E5 or audit add-on)**
- [ ] **Install CoE Audit Log Components solution** (if not already installed)
- [ ] **Configure HTTP with Azure AD connection** (Base Resource URL: `https://manage.office.com`)
- [ ] **Configure environment variables** (tenant ID, audience, authority)
- [ ] **Run the Office 365 Management API Subscription flow** (creates subscription)
- [ ] **Enable the Sync Audit Logs V2 flow** (scheduled hourly)
- [ ] **Enable the Update Data V2 flow** (automated trigger)
- [ ] **Launch a test app and wait 2-3 hours**
- [ ] **Check admin_auditlog table** for LaunchPowerApp events
- [ ] **Check admin_apps table** for updated admin_applastlaunchedon
- [ ] **Verify "App Last Launched On" in Admin View app**

## Additional Resources 📚

- [CoE Starter Kit Setup - Audit Logs](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Microsoft Purview Audit Overview](https://learn.microsoft.com/purview/audit-solutions-overview)
- [Office 365 Management Activity API](https://learn.microsoft.com/office/office-365-management-api/office-365-management-activity-api-reference)
- [Search-UnifiedAuditLog PowerShell](https://learn.microsoft.com/powershell/module/exchange/search-unifiedauditlog)
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

## FAQ ❓

**Q: Why did usage data stop after a specific date?**  
A: The most common reasons are:
1. Audit Log flows were turned off
2. M365 audit logging was disabled at tenant
3. HTTP connection expired or broke
4. M365 Management API subscription expired (7 days of inactivity)

**Q: Can I backfill historical usage data?**  
A: Partially. M365 audit logs are retained for 90 days (E3) or 1 year (E5). You can:
1. Export historical audit logs from M365 Compliance Portal
2. Import using the CSV import flow
3. This will backfill the admin_auditlog table
4. The Update Data V2 flow will process the imported records

**Q: Do I need audit logs for the CoE Starter Kit to work?**  
A: No, the Core Components work without audit logs. However, you will NOT get:
- App Last Launched On dates
- User-level usage analytics
- App launch frequency metrics
- Usage trends in Power BI reports

**Q: Why is there a 1-3 hour delay in usage data?**  
A: This is normal and expected:
1. Microsoft processes audit logs in batches (1-2 hour delay)
2. The Sync flow runs hourly (up to 1 hour wait)
3. Total lag: 1-3 hours from app launch to data appearing in CoE

**Q: Can I make the sync faster than hourly?**  
A: Yes, but not recommended:
1. Edit the Sync Audit Logs V2 flow schedule
2. Change from hourly to every 15 minutes
3. **Risk**: May hit API throttling limits with high-frequency polling

**Q: Does this work in GCC/GCC High/DoD?**  
A: Yes, but requires different environment variable values:
- GCC: Use commercial endpoints
- GCC High: Use government endpoints (see [Sovereign Cloud Support](sovereign-cloud-support.md))
- DoD: Use DoD-specific endpoints (see [Sovereign Cloud Support](sovereign-cloud-support.md))

**Q: What if I don't have E3/E5 licenses?**  
A: You have two options:
1. Purchase Microsoft Purview Audit (Standard) add-on
2. Accept that usage data will not be available (disable/ignore Audit Log components)

---

**Issue Type**: Configuration / Missing Component  
**Applies To**: CoE Starter Kit Core Components (All versions)  
**Last Updated**: January 2026
