# Flow Last Run and App Last Launched Data Not Visible

## Issue Summary

Users may notice that the CoE Starter Kit does not display:
- **Flow Last Run** information for flows
- **App Last Launched** information for apps

This occurs even when:
- The sync flows (`Admin | Sync Template v4 (Flows)` and `Admin | Sync Template v4 (Apps)`) are running successfully
- The user has Power Platform admin access
- The flows appear to be collecting data

## Root Cause

The **Flow Last Run** (`admin_flowlastrunon`) and **App Last Launched** (`admin_applastlaunchedon`) fields, along with usage metrics like "Launches in the past 30 days", are **only populated when using the Data Export (BYODL - Bring Your Own Data Lake) architecture**.

### Why This Happens

When using the **Cloud Flows inventory method** (the default and recommended approach), the CoE Starter Kit collects data using Power Platform admin connectors. These connectors provide comprehensive information about apps and flows, but they do **not** include:

1. **For Flows:**
   - Last run timestamp
   - Run history details

2. **For Apps:**
   - Last launched timestamp
   - Launch count in the past 30 days
   - User access telemetry

This is a **platform limitation**, not a bug in the CoE Starter Kit. The Power Platform admin APIs do not expose this telemetry data through the connectors used by Cloud Flows.

### Data Export (BYODL) Architecture

The Data Export architecture (previously called BYODL or self-serve analytics) exports telemetry data from Power Platform to Azure Data Lake Storage. When CoE Starter Kit is configured to read from this data lake, it can access the additional telemetry fields.

**However, Microsoft no longer recommends BYODL for new implementations.** The future direction is Microsoft Fabric integration.

## Understanding Your Setup

### How to Check Your Inventory Method

1. Navigate to your CoE environment
2. Go to **Solutions** > **Center of Excellence - Core Components**
3. Check the environment variable: **Inventory and Telemetry in Azure Data Storage account** (`admin_InventoryandTelemetryinAzureDataStorageaccount`)
   - If set to **No** (default): You are using **Cloud Flows** - these telemetry fields will be empty
   - If set to **Yes**: You are using **Data Export/BYODL** - these fields should populate

### Fields Affected by This Limitation

| Entity | Field Name | Logical Name | Available in Cloud Flows | Available in BYODL |
|--------|-----------|--------------|-------------------------|-------------------|
| Flow | Flow Last Run ON | `admin_flowlastrunon` | ❌ No | ✅ Yes |
| App | App Last Launched On | `admin_applastlaunchedon` | ❌ No | ✅ Yes |
| App | Launches in the past 30 days | (field name) | ❌ No | ✅ Yes |

## Solutions and Workarounds

### Option 1: Use Audit Logs (Recommended)

The CoE Starter Kit includes Audit Log functionality that can provide usage insights:

1. **Enable Audit Logs** in your CoE environment
   - Set up the `Admin | Audit Logs - Sync Audit Logs V2` flow
   - This captures user actions including app launches and flow runs
   
2. **Review Audit Data**
   - Audit logs will show:
     - When apps were launched and by whom
     - When flows were run
     - User activity patterns

3. **Limitations:**
   - Audit logs have retention limits (typically 90 days)
   - Requires Microsoft 365 E3/E5 or equivalent licensing
   - Higher volume of data storage

**Reference:** [CoE Starter Kit Audit Logs](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)

### Option 2: PowerShell for Flow Run History

For flow run information, you can use PowerShell to query individual flow runs:

```powershell
# Install required module if not already installed
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser

# Connect to Power Platform
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

### Option 3: Power Platform Admin Center

For ad-hoc investigations:

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Navigate to **Environments** > Select environment > **Resources**
3. View **Cloud flows** or **Apps**
4. Check individual flow run history or app details

**Limitations:**
- Manual process
- Not scalable for large tenants
- No centralized reporting

### Option 4: Microsoft Fabric (Future Direction)

Microsoft is investing in Fabric as the analytics platform for Power Platform:

- **Status:** In preview/development
- **Benefit:** Will provide comprehensive telemetry and usage data
- **Timeline:** Check Microsoft announcements for availability

**Reference:** [Microsoft Fabric for Power Platform](https://learn.microsoft.com/power-platform/admin/managed-environment-usage-insights)

## What Data IS Available with Cloud Flows?

Even without last run/launch data, the CoE Starter Kit provides extensive information:

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

## Important Note: BYODL Status

**Microsoft no longer recommends implementing BYODL (Data Export to Azure Data Lake) for new CoE Starter Kit installations.**

### Why?
- BYODL is being deprecated in favor of Microsoft Fabric
- Complex setup and maintenance
- Additional Azure costs
- Requires specialized Azure and data engineering skills

### If You Already Have BYODL:
- Continue using it until Fabric integration is ready
- Plan migration to Fabric when available
- Monitor Microsoft announcements

## Frequently Asked Questions

### Q: Why don't I see last run data even though my flows are running?
**A:** Last run data is only available with BYODL architecture. If you're using Cloud Flows (recommended), this data is not available through the admin APIs.

### Q: Can I enable BYODL just to get this data?
**A:** While technically possible, Microsoft does **not recommend** new BYODL implementations. Use Audit Logs or wait for Fabric integration instead.

### Q: Will this data ever be available in Cloud Flows?
**A:** This depends on Microsoft adding these fields to the Power Platform admin APIs. Monitor the [Power Platform Ideas forum](https://powerusers.microsoft.com/t5/Power-Apps-Ideas/idb-p/PowerAppsIdeas) and product roadmaps.

### Q: How do I report flows/apps that haven't been used recently?
**A:** Use the Audit Logs feature if you need usage-based reporting. Alternatively, consider implementing inactivity detection based on "Modified Date" as a proxy.

### Q: The images in my issue show "Flow Last Run ON" column with values, why is mine empty?
**A:** The screenshots likely show a BYODL-enabled environment or test data. In Cloud Flows environments, these columns will be empty by design.

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Inventory and Telemetry Configuration](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Audit Log Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)

## Summary

- **Flow Last Run** and **App Last Launched** fields are **not populated when using Cloud Flows** (the recommended method)
- This is a **platform limitation**, not a CoE Starter Kit bug
- **BYODL is deprecated** and not recommended for new implementations
- **Use Audit Logs** for usage telemetry and activity tracking
- **Microsoft Fabric** is the future direction for Power Platform analytics

---

*Last Updated: December 2024*
