# Issue Response Template: Flow Last Run and App Last Launched Data Not Visible

Use this template when responding to issues about missing Flow Last Run and App Last Launched telemetry data.

---

## Response Template

Thank you for raising this issue! I can help clarify why you're not seeing Flow Last Run and App Last Launched data in your CoE environment.

### Root Cause

The **Flow Last Run** (`admin_flowlastrunon`) and **App Last Launched** (`admin_applastlaunchedon`) fields are **only populated when using the Data Export (BYODL - Bring Your Own Data Lake) architecture**, not with Cloud Flows.

Based on your description, you're using **Cloud Flows** for inventory (the default and recommended method), which explains why these fields are empty. This is a **platform limitation**, not a bug in the CoE Starter Kit.

### Why This Happens

When using Cloud Flows, the CoE Starter Kit collects data through Power Platform admin connectors. While these APIs provide comprehensive information about apps and flows, they do **not** include:

- Flow last run timestamps
- App last launched timestamps  
- Usage metrics like "launches in the past 30 days"

The entity definitions confirm this behavior:

**For Flows (`admin_Flow` entity):**
- The `admin_flowlastrunon` field description states: _"Data Export Architecture Only - note that this field is not filled if you are using the cloud flow architecture."_

**For Apps (`admin_App` entity):**
- The "Launches in the past 30 days" field description states: _"Filled only for BYODL installs. Else empty"_

### Recommended Solutions

#### ✅ Option 1: Use Audit Logs (Recommended)

The CoE Starter Kit includes Audit Log functionality that provides usage insights:

1. **Enable Audit Logs** in your CoE environment
   - Configure the `Admin | Audit Logs - Sync Audit Logs V2` flow
   - This captures user actions including app launches and flow runs

2. **Benefits:**
   - See who launched apps and when
   - Track flow execution activity
   - User activity patterns

3. **Requirements:**
   - Microsoft 365 E3/E5 or equivalent licensing
   - Audit logs have retention limits (typically 90 days)

📖 **Setup Guide:** [CoE Audit Logs Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)

#### 🔧 Option 2: PowerShell for Ad-hoc Queries

For specific flow run information, you can use PowerShell:

```powershell
# Get run history for a specific flow
Get-FlowRun -EnvironmentName "env-id" -FlowName "flow-id" | 
    Select-Object StartTime, Status | 
    Sort-Object StartTime -Descending | 
    Select-Object -First 1
```

**Note:** This must be done individually per flow and is not scalable for large tenants.

#### 🔮 Option 3: Microsoft Fabric (Future)

Microsoft is developing Fabric integration for Power Platform analytics, which will provide comprehensive telemetry. Monitor Microsoft announcements for availability.

### Important: BYODL Status

**Microsoft no longer recommends implementing BYODL (Data Export) for new CoE installations** because:
- BYODL is being deprecated in favor of Microsoft Fabric
- Complex setup and maintenance requirements
- Additional Azure infrastructure costs

If you don't already have BYODL configured, please use Audit Logs instead.

### What Data IS Available

Even without last run/launch timestamps, the CoE Starter Kit provides extensive inventory data:

**For Apps:**
- ✅ Name, owner, created/modified dates
- ✅ Environment, sharing details
- ✅ Connections used
- ✅ App type

**For Flows:**
- ✅ Name, owner, created/modified dates  
- ✅ State (on/off/suspended)
- ✅ Trigger type, connections
- ✅ Flow actions (via Sync Flow Action Details)

### Additional Resources

I've created a comprehensive troubleshooting guide with more details:

📖 **[Flow Last Run and App Last Launched Troubleshooting Guide](https://github.com/microsoft/coe-starter-kit/blob/main/docs/troubleshooting/flow-last-run-app-last-launched.md)**

This guide includes:
- Detailed root cause analysis
- All available solutions and workarounds
- Field-by-field comparison
- FAQs

### Summary

- ❌ Flow Last Run and App Last Launched are **not available with Cloud Flows**
- ✅ Use **Audit Logs** for usage telemetry (recommended approach)
- ⚠️ **Do not** implement BYODL for new installations
- 🔮 **Microsoft Fabric** is the future direction for Power Platform analytics

Does this clarify the situation? Let me know if you have any other questions!

---

## When to Use This Template

- User reports missing Flow Last Run data
- User reports missing App Last Launched data  
- User asks about usage metrics or telemetry
- User sees empty columns in CoE dashboards for run/launch data
- User compares their environment to screenshots showing populated data

## Key Points to Emphasize

1. **Not a bug** - This is expected behavior with Cloud Flows
2. **Platform limitation** - The admin APIs don't provide this data
3. **BYODL deprecated** - Don't recommend implementing it
4. **Audit Logs work** - Viable alternative for usage tracking
5. **Point to docs** - Reference the comprehensive troubleshooting guide

## Related Issues

Link to related issues when appropriate:
- Search for issues with tags: `inventory`, `telemetry`, `BYODL`, `data-export`
