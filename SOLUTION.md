# Solution for Issue: Flow Last Run and App Last Launched Data Not Visible

## Post this as a comment on the GitHub issue

---

Thank you for raising this issue! I can help clarify why you're not seeing Flow Last Run and App Last Launched data in your CoE environment.

## Root Cause

The **Flow Last Run** (`admin_flowlastrunon`) and **App Last Launched** (`admin_applastlaunchedon`) fields are **only populated when using the Data Export (BYODL - Bring Your Own Data Lake) architecture**, not with Cloud Flows.

Based on your description, you're using **Cloud Flows** for inventory (the default and recommended method), which explains why these fields are empty. This is a **platform limitation**, not a bug in the CoE Starter Kit.

### Why This Happens

When using Cloud Flows, the CoE Starter Kit collects data through Power Platform admin connectors. While these APIs provide comprehensive information about apps and flows, they do **not** include:

- Flow last run timestamps
- App last launched timestamps  
- Usage metrics like "launches in the past 30 days"

The entity definitions in the solution confirm this behavior:

**For Flows (`admin_Flow` entity):**
- The `admin_flowlastrunon` field description states: _"Data Export Architecture Only - note that this field is not filled if you are using the cloud flow architecture."_

**For Apps (`admin_App` entity):**
- The "Launches in the past 30 days" field description states: _"Filled only for BYODL installs. Else empty"_

## How to Verify Your Setup

You can check which inventory method you're using:

1. Navigate to your CoE environment
2. Go to **Solutions** > **Center of Excellence - Core Components**
3. Check the environment variable: **Inventory and Telemetry in Azure Data Storage account** (`admin_InventoryandTelemetryinAzureDataStorageaccount`)
   - If set to **No** (default): You are using **Cloud Flows** → these telemetry fields will be empty ❌
   - If set to **Yes**: You are using **Data Export/BYODL** → these fields should populate ✅

## Recommended Solutions

### ✅ Option 1: Use Audit Logs (Recommended)

The CoE Starter Kit includes Audit Log functionality that provides usage insights:

1. **Enable Audit Logs** in your CoE environment
   - Configure the `Admin | Audit Logs - Sync Audit Logs V2` flow
   - This captures user actions including app launches and flow runs

2. **Benefits:**
   - See who launched apps and when
   - Track flow execution activity
   - Identify usage patterns

3. **Requirements:**
   - Microsoft 365 E3/E5 or equivalent licensing for unified audit logs
   - Audit logs have retention limits (typically 90 days, configurable up to 1 year)

**📖 Setup Guide:** https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog

### 🔧 Option 2: PowerShell for Ad-hoc Queries

For specific flow run information, you can use PowerShell:

```powershell
# Install required module
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser

# Connect
Add-PowerAppsAccount

# Get flows in an environment
$environmentName = "YOUR-ENVIRONMENT-ID"
$flows = Get-AdminFlow -EnvironmentName $environmentName

# Get run history for a specific flow
$flowName = "YOUR-FLOW-ID"
$runs = Get-FlowRun -EnvironmentName $environmentName -FlowName $flowName

# Display last run information
$runs | Select-Object FlowId, StartTime, Status | Sort-Object StartTime -Descending | Select-Object -First 1
```

**Limitations:**
- Must query each flow individually
- API pagination limits for large tenants
- Not integrated into CoE dashboards

### 🔮 Option 3: Microsoft Fabric (Future Direction)

Microsoft is developing Fabric integration for Power Platform analytics, which will provide comprehensive telemetry. Monitor Microsoft announcements for availability.

**Reference:** https://learn.microsoft.com/power-platform/admin/managed-environment-usage-insights

## Important: BYODL Status

**⚠️ Microsoft no longer recommends implementing BYODL (Data Export to Azure Data Lake) for new CoE installations** because:
- BYODL is being deprecated in favor of Microsoft Fabric
- Complex setup and maintenance requirements
- Additional Azure infrastructure and storage costs
- Requires specialized Azure and data engineering expertise

**If you don't already have BYODL configured, please use Audit Logs instead.**

## What Data IS Available with Cloud Flows

Even without last run/launch timestamps, the CoE Starter Kit provides extensive inventory data:

### For Apps:
- ✅ App name, owner, created date, modified date
- ✅ Environment location
- ✅ Shared users count
- ✅ Connections used
- ✅ Business justification (if collected)
- ✅ App type (Canvas, Model-driven, Portal)

### For Flows:
- ✅ Flow name, owner, created date, modified date
- ✅ Environment location
- ✅ Flow state (On/Off/Suspended)
- ✅ Trigger type
- ✅ Connections and connectors used
- ✅ Flow actions (via Flow Action Details sync)

## Comprehensive Documentation

I've created detailed troubleshooting documentation to help with this and similar issues:

📖 **[Flow Last Run and App Last Launched Troubleshooting Guide](./docs/troubleshooting/flow-last-run-app-last-launched.md)**

This guide includes:
- Detailed root cause analysis
- All available solutions and workarounds
- Field-by-field comparison table
- Frequently Asked Questions
- Links to official documentation

## Summary

- ❌ **Flow Last Run** and **App Last Launched** are **not available with Cloud Flows** (this is the recommended and default inventory method)
- ✅ Use **Audit Logs** for usage telemetry and activity tracking (recommended approach)
- ⚠️ **Do not** implement BYODL for new installations (deprecated)
- 🔮 **Microsoft Fabric** is the future direction for Power Platform analytics

## Next Steps

Based on your requirements for tracking app and flow usage:

1. **Enable Audit Logs** in your CoE environment (follow the setup guide linked above)
2. Configure the `Admin | Audit Logs - Sync Audit Logs V2` flow
3. Use the audit data for usage reporting and compliance

This will give you the usage visibility you need without requiring the deprecated BYODL architecture.

Does this clarify the situation? Let me know if you have any questions or need help setting up Audit Logs!

---

## Additional Context for Maintainers

This issue represents a common source of confusion for CoE Starter Kit users. The troubleshooting documentation has been added to help prevent similar issues in the future and provide a clear explanation of the architectural limitations.

**Documentation added:**
- `docs/troubleshooting/flow-last-run-app-last-launched.md` - Comprehensive troubleshooting guide
- `docs/troubleshooting/README.md` - Troubleshooting directory index  
- `docs/README.md` - Documentation structure overview
- `docs/troubleshooting/issue-response-template.md` - Template for responding to similar issues
- Updated main `README.md` with link to troubleshooting guides

**Related entity fields:**
- `admin_Flow.admin_flowlastrunon` - Only populated with BYODL
- `admin_App.admin_applastlaunchedon` - Only populated with BYODL
- `admin_App` launches field - Only populated with BYODL

**References:**
- Entity definition: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_Flow/Entity.xml`
- Entity definition: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_App/Entity.xml`
