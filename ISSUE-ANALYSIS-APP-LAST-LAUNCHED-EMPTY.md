# 🔧 Analysis: "App Last Launched On" Field Empty in Power Platform Admin View

## Issue Summary
User reports that the **"App Last Launched On"** field (`admin_applastlaunchedon`) is empty for all apps in the Power Platform Admin View, even though apps are being launched and used by end users.

## Root Cause ✅

The **"App Last Launched On"** field is **NOT** populated by the standard inventory flows. This field requires:

1. ✅ **Office 365 Audit Logs** to be enabled in Microsoft 365 Admin Center
2. ✅ **Audit Log solution** (`CenterofExcellenceAuditLogs` or Core Components v4.17.4+) to be installed
3. ✅ **Admin | Audit Logs | Sync Audit Logs V2** flow to be running and retrieving audit log data
4. ✅ **Admin | Audit Logs | Update Data (V2)** flow to be enabled and processing `LaunchPowerApp` events

**This is NOT a bug** - it's a **configuration/setup requirement** that users may not be aware of.

## Data Flow Architecture 🏗️

```
Office 365 Audit Logs (M365 Security & Compliance Center)
    ↓
Admin | Audit Logs | Sync Audit Logs V2 (Retrieves audit log events)
    ↓
admin_auditlog table (Dataverse - stores LaunchPowerApp events)
    ↓
Admin | Audit Logs | Update Data (V2) (Triggered when admin_auditlog row added/modified)
    ↓ (Filters for admin_operation eq 'LaunchPowerApp')
    ↓
admin_App.admin_applastlaunchedon (Updated with latest launch timestamp)
    ↓
Power Platform Admin View (Displays the date)
```

## What Populates This Field 📊

### Source Data
- **Office 365 Unified Audit Log** - `LaunchPowerApp` operation events
- Requires E3/E5 license or Microsoft 365 Business Premium
- Must be enabled in [Microsoft 365 Compliance Center](https://compliance.microsoft.com/auditlogsearch)

### Flow Responsible
**Flow Name:** `Admin | Audit Logs | Update Data (V2)`  
**File:** `AdminAuditLogsUpdateDataV2-1D8BF7B1-D787-EE11-8179-000D3A3411D9.json`  
**Introduced:** Core Components v4.17.4

**Trigger:**
```json
{
  "type": "OpenApiConnectionWebhook",
  "subscriptionRequest/message": 4,
  "subscriptionRequest/entityname": "admin_auditlog",
  "subscriptionRequest/filterexpression": "admin_operation eq 'LaunchPowerApp'"
}
```

**What it does:**
1. Monitors the `admin_auditlog` table for new rows with operation = `LaunchPowerApp`
2. Extracts `admin_creationtime` (when the app was launched)
3. Retrieves current `admin_applastlaunchedon` value from the app record
4. Updates `admin_applastlaunchedon` **only if**:
   - Current value is `null` (never launched before), OR
   - New launch timestamp is **more recent** than existing value

### Prerequisites ✔️
| Requirement | Status | How to Verify |
|------------|--------|---------------|
| Office 365 Audit Logs Enabled | ⚠️ Required | [M365 Compliance Center](https://compliance.microsoft.com/auditlogsearch) → Turn on auditing |
| Audit Log Solution Installed | ⚠️ Required | Check if `Admin \| Audit Logs` flows exist in CoE environment |
| Audit Log Subscription Active | ⚠️ Required | Run `Admin \| Audit Logs \| Office 365 Management API Subscription` flow |
| Sync Flow Running | ⚠️ Required | `Admin \| Audit Logs \| Sync Audit Logs V2` should run daily and succeed |
| Update Flow Enabled | ⚠️ Required | `Admin \| Audit Logs \| Update Data (V2)` must be ON |
| License Requirements | ⚠️ Required | E3/E5 or M365 Business Premium for audit logs |

## Solution 🎯

### Quick Diagnostic Steps

#### Step 1: Verify Office 365 Audit Logs Are Enabled
1. Go to [Microsoft 365 Compliance Center](https://compliance.microsoft.com/auditlogsearch)
2. Click **Start recording user and admin activity**
3. Wait 24 hours for data to start flowing

**Verify:**
```powershell
Connect-ExchangeOnline
Get-AdminAuditLogConfig | fl UnifiedAuditLogIngestionEnabled
# Should return: UnifiedAuditLogIngestionEnabled : True
```

#### Step 2: Check if Audit Log Solution is Installed
1. Go to Power Apps → CoE Environment → Solutions
2. Look for one of:
   - **Center of Excellence - Audit Logs** (older, standalone solution)
   - **Center of Excellence - Core Components v4.17.4+** (includes audit log flows)

**If NOT installed:**
- Install Core Components v4.17.4 or later (includes audit log capabilities), OR
- Install the standalone **CenterofExcellenceAuditLogs** solution

#### Step 3: Enable Audit Log Subscription
1. Find flow: `Admin | Audit Logs | Office 365 Management API Subscription`
2. Turn it ON
3. Click **Run** manually
4. Verify it succeeds

**What this does:** Creates a subscription to Office 365 Management Activity API to receive audit log events

#### Step 4: Verify Sync Flow is Running
1. Find flow: `Admin | Audit Logs | Sync Audit Logs V2`
2. Check if it's **ON**
3. Review **Run History**:
   - Should run daily (scheduled)
   - Should show successful runs
   - Should be retrieving audit log records

**Common Issue:** Flow may fail if:
- Office 365 audit logs are disabled
- Subscription hasn't been created
- Service account lacks permissions

#### Step 5: Enable Update Data Flow
1. Find flow: `Admin | Audit Logs | Update Data (V2)`
2. Turn it **ON**
3. This flow runs automatically when `LaunchPowerApp` events are added to `admin_auditlog` table

#### Step 6: Test End-to-End
1. Launch a Power App (Canvas or Model-Driven)
2. Wait 15-30 minutes (audit log ingestion delay)
3. Check if:
   - Event appears in `admin_auditlog` table with `admin_operation = 'LaunchPowerApp'`
   - Flow `Admin | Audit Logs | Update Data (V2)` triggered
   - `admin_applastlaunchedon` field populated on app record

### Verification Query (Power Apps / Advanced Find)

**Check if audit log events are being captured:**
```
Table: Audit Logs (admin_auditlog)
Filter: Operation equals "LaunchPowerApp"
Sort: Created On (newest first)
```

**Check if apps have last launched date:**
```
Table: PowerApps Apps (admin_app)
Filter: App Last Launched On is not null
```

## Common Scenarios 🔀

### Scenario 1: Field is Empty for ALL Apps
**Likely Cause:** Audit log solution not installed or flows not running  
**Solution:** Follow Steps 1-6 above

### Scenario 2: Field is Empty for SOME Apps
**Likely Cause:** Apps haven't been launched since audit log setup OR audit log retention period expired  
**Solution:** 
- Apps must be launched AFTER audit log setup is complete
- Office 365 audit logs have a retention period (90 days default for E3, 1 year for E5)
- Launch the app to generate a new event

### Scenario 3: Field Shows Old Dates Only
**Likely Cause:** Audit log sync stopped working OR audit log retention expired  
**Solution:**
- Check `Admin | Audit Logs | Sync Audit Logs V2` run history
- Verify no errors in flow runs
- Check Office 365 audit log retention settings

### Scenario 4: Just Installed CoE - When Will Data Appear?
**Timeline:**
- **0-24 hours:** Enable Office 365 audit logs
- **24-48 hours:** Initial audit log data available
- **48-72 hours:** Sync flows start retrieving data
- **After app launches:** `admin_applastlaunchedon` populated

**Important:** Historical app launches BEFORE audit log setup will NOT be captured

## Environment Variables 📋

The Audit Log solution uses these environment variables:

| Variable | Default | Purpose |
|----------|---------|---------|
| `AuditLog_TenantID` | (required) | Your Microsoft 365 Tenant ID |
| `AuditLog_Publisher` | (required) | Office 365 Management API Publisher GUID |
| `AuditLog_ContentType` | Audit.General | Content type to retrieve |
| `AuditLog_EnableLogging` | No | Debug logging |
| `AuditLog_RegionURL` | https://manage.office.com | Office 365 Management API endpoint |

## Known Limitations ⚠️

### Audit Log Limitations
- **Delay:** 15-30 minute lag between app launch and audit log availability
- **Retention:** 90 days (E3) or 1 year (E5) by default
- **Historical data:** Cannot retrieve app launches from BEFORE audit logs were enabled
- **Embedded apps:** May not generate audit log events in some scenarios
- **Anonymous access:** Public apps may not log user launches

### Licensing Requirements
- **E3/E5 License:** Required for Office 365 Audit Logs
- **M365 Business Premium:** Also supported
- **Trial/Developer:** May have limited audit log retention

### API Throttling
- Office 365 Management Activity API has throttling limits
- Large tenants with high activity may experience delays
- Sync flow includes retry logic (20 retries with exponential backoff)

## Alternative Approaches (If Audit Logs Not Available) 🔄

If you cannot enable Office 365 Audit Logs or don't have required licenses:

### Option 1: Use "Modified On" as Proxy
- The `modifiedon` field on the app record shows when the app definition was changed
- **Limitation:** Doesn't track app USAGE, only app EDITS

### Option 2: Use Analytics Connector (Canvas Apps Only)
- Power Apps Analytics connector provides usage data
- **Limitation:** 
  - Canvas apps only (not model-driven)
  - Limited data retention
  - Requires separate setup

### Option 3: Custom Telemetry
- Add custom telemetry to apps using Application Insights
- **Limitation:** Requires code changes to every app

### Option 4: Accept Empty Field
- Use other metrics for app usage tracking
- Focus on "Modified On" for inactivity detection

## Documentation References 📚

### Official Microsoft Documentation
- [Set up Audit Log Connector](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Office 365 Audit Log Search](https://learn.microsoft.com/microsoft-365/compliance/audit-log-search)
- [Turn Audit Log Search On or Off](https://learn.microsoft.com/microsoft-365/compliance/turn-audit-log-search-on-or-off)
- [CoE Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

### Related CoE Components
- **Inactivity Notifications** - Uses `admin_applastlaunchedon` OR `modifiedon` to determine inactivity
- **Admin View App** - Displays this field for governance purposes
- **Power BI Dashboard** - May include this metric in usage reports

## Troubleshooting Decision Tree 🌳

```
Is "App Last Launched On" empty?
│
├─ YES → Are Office 365 Audit Logs enabled?
│   │
│   ├─ NO → Enable in M365 Compliance Center (Step 1)
│   │       Wait 24-48 hours
│   │       Launch test app
│   │       Check again
│   │
│   └─ YES → Is Audit Log solution installed?
│       │
│       ├─ NO → Install Core Components v4.17.4+ or standalone Audit Logs solution
│       │
│       └─ YES → Are audit log flows running?
│           │
│           ├─ NO → Turn ON:
│           │       - Admin | Audit Logs | Office 365 Management API Subscription
│           │       - Admin | Audit Logs | Sync Audit Logs V2
│           │       - Admin | Audit Logs | Update Data (V2)
│           │
│           └─ YES → Check flow run history for errors
│                   - Verify service account permissions
│                   - Check connection authentication
│                   - Review error messages
│
└─ NO → Field is working correctly! ✅
```

## Recommendations for Users 💡

### For First-Time Setup:
1. ✅ Enable Office 365 Audit Logs immediately
2. ✅ Install Core Components v4.17.4+ (includes audit log capabilities)
3. ✅ Run subscription flow to activate Office 365 API connection
4. ✅ Wait 24-48 hours for initial data
5. ✅ Test by launching an app and verifying field populates

### For Existing Installations:
1. ✅ Verify audit log flows are enabled (may have been turned off)
2. ✅ Check flow run history for throttling or authentication errors
3. ✅ Ensure connections are still valid (may need re-authentication)
4. ✅ Review audit log retention settings in M365

### For Large Tenants:
1. ✅ Monitor API throttling in sync flow
2. ✅ Consider adjusting sync frequency to avoid limits
3. ✅ Use delay settings if experiencing throttling: `admin_DelayAuditLogSync = Yes`

## Related GitHub Issues 🔗

**Similar issues to reference:**
- Issues about inactivity notifications not working → Often related to empty `admin_applastlaunchedon`
- Audit log setup questions
- "Last Launched Date" not being tracked (mentioned in InactivityNotificationFlowsGuide.md)

## Communication Template 📝

**For responding to users reporting this issue:**

---

Thank you for reporting this issue. The **"App Last Launched On"** field being empty is typically a configuration requirement rather than a bug.

### Quick Answer

The `admin_applastlaunchedon` field requires the **Audit Log** component to be set up, which:
- Retrieves app launch events from **Office 365 Audit Logs**
- Requires E3/E5 or M365 Business Premium license
- Requires audit logging to be enabled in Microsoft 365 Compliance Center

### What You Need to Check

1. **Is Office 365 Audit Log enabled?**
   - Go to [M365 Compliance Center](https://compliance.microsoft.com/auditlogsearch)
   - Turn on "Start recording user and admin activity"
   - Wait 24 hours

2. **Is the Audit Log solution installed?**
   - Check if you have Core Components v4.17.4+ OR the standalone Audit Logs solution
   - Look for flows named `Admin | Audit Logs | ...`

3. **Are the audit log flows running?**
   - `Admin | Audit Logs | Office 365 Management API Subscription` - Run once to activate
   - `Admin | Audit Logs | Sync Audit Logs V2` - Should run daily
   - `Admin | Audit Logs | Update Data (V2)` - Should be enabled (runs automatically)

### Detailed Troubleshooting

I've created a comprehensive analysis document with:
- ✅ Step-by-step diagnostic instructions
- ✅ Architecture and data flow explanation
- ✅ Common scenarios and solutions
- ✅ Troubleshooting decision tree
- ✅ Alternative approaches if audit logs aren't available

**[Link to ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md]**

### Can't Use Audit Logs?

If you don't have the required licenses or can't enable audit logs, alternatives include:
- Use `modifiedon` field (tracks app edits, not usage)
- Use Power Apps Analytics connector (Canvas apps only)
- Implement custom telemetry with Application Insights

Let me know:
1. Are Office 365 Audit Logs enabled in your tenant?
2. Which version of Core Components are you running?
3. Do you see any flows with "Audit Logs" in the name?

I'm happy to help troubleshoot further based on your specific setup!

---

## Next Steps for CoE Starter Kit Team 🚀

### Documentation Improvements Needed:
1. 📖 Add prominent notice in Admin View documentation about audit log requirement
2. 📖 Update setup wizard to flag when audit logs aren't configured
3. 📖 Create quick-start guide specifically for "App Last Launched On" field
4. 📖 Add this requirement to FAQ

### Potential Product Enhancements:
1. 💡 Add in-app notification in Admin View when audit log flows aren't running
2. 💡 Create Setup Wizard step to verify audit log configuration
3. 💡 Add health check flow to detect missing audit log setup
4. 💡 Consider fallback to Analytics connector data if audit logs unavailable

### Testing Recommendations:
1. 🧪 Test audit log setup in different license scenarios (E3, E5, Business Premium)
2. 🧪 Validate flow behavior with high-volume audit log data
3. 🧪 Test throttling scenarios and retry logic
4. 🧪 Verify behavior across sovereign clouds

---

**Last updated:** February 2025  
**CoE Starter Kit Version:** 4.17.4+  
**Related Components:** Core Components, Audit Logs  
**Field:** `admin_applastlaunchedon` (App Last Launched On)
