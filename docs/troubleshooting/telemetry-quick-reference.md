# Quick Reference: CoE Starter Kit Telemetry Data Availability

## Field Availability Matrix

| Data Point | Cloud Flows | BYODL/Data Export | Audit Logs | PowerShell |
|------------|------------|-------------------|------------|------------|
| **Flows** |
| Flow Name | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Flow Owner | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Flow State (On/Off) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Flow Created Date | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| Flow Modified Date | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| **Flow Last Run Date** | **❌ No** | **✅ Yes** | **✅ Yes** | **✅ Yes** |
| Flow Run History | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes* |
| Flow Actions/Triggers | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| Flow Connections | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| **Apps** |
| App Name | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| App Owner | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| App Created Date | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| App Modified Date | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| **App Last Launched** | **❌ No** | **✅ Yes** | **✅ Yes** | **❌ No** |
| App Launch Count | ❌ No | ✅ Yes | ✅ Yes | ❌ No |
| App Users/Shares | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| App Connections | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |

*PowerShell can retrieve run history per flow, but not scalable for large tenants

## Inventory Method Comparison

### Cloud Flows (Default - Recommended) ✅

**Pros:**
- ✅ No additional Azure infrastructure required
- ✅ No extra costs
- ✅ Simpler setup and maintenance
- ✅ Microsoft-recommended approach
- ✅ Comprehensive inventory data
- ✅ Connector and action details

**Cons:**
- ❌ No flow last run timestamps
- ❌ No app last launched timestamps
- ❌ No usage metrics (launch counts)

**Best For:**
- New CoE implementations
- Basic inventory and governance
- Organizations without Azure Data Lake

### BYODL/Data Export (Deprecated) ⚠️

**Pros:**
- ✅ Includes flow last run data
- ✅ Includes app last launched data
- ✅ Usage metrics available

**Cons:**
- ❌ Microsoft no longer recommends
- ❌ Being deprecated (Fabric is future)
- ❌ Complex setup (Azure Data Lake required)
- ❌ Additional Azure costs
- ❌ Requires data engineering expertise
- ❌ Maintenance overhead

**Best For:**
- Existing BYODL implementations only
- Do NOT implement new BYODL setups

### Audit Logs (Recommended for Telemetry) ✅

**Pros:**
- ✅ Flow run activity
- ✅ App launch activity
- ✅ User-level detail (who did what)
- ✅ Compliance and security insights
- ✅ Microsoft-recommended approach

**Cons:**
- ❌ Requires M365 E3/E5 licensing
- ❌ Retention limits (90 days default, up to 1 year)
- ❌ Higher data volume

**Best For:**
- Usage tracking and telemetry
- Compliance and auditing
- User activity monitoring

### PowerShell

**Pros:**
- ✅ Direct API access
- ✅ Ad-hoc queries
- ✅ Flow run history available
- ✅ No CoE setup required

**Cons:**
- ❌ Manual/scripting required
- ❌ Not scalable for large tenants
- ❌ API pagination limits
- ❌ Not integrated in dashboards

**Best For:**
- One-off investigations
- Specific flow debugging
- Administrative tasks

## Decision Tree

```
Do you need Flow Last Run or App Last Launched data?
│
├─ Yes → Use Audit Logs
│        ├─ Have M365 E3/E5? → Set up Audit Logs ✅
│        └─ Don't have license? → Request licensing or use PowerShell for flows only
│
└─ No → Use Cloud Flows (default)
         └─ Standard inventory is sufficient ✅
```

## Common Scenarios

### Scenario 1: "I need to know which apps haven't been used in 90 days"

**Solution:** Use Audit Logs
- Enable Audit Logs in CoE
- Query audit data for app launch events
- Filter by date range
- Cross-reference with inventory

### Scenario 2: "I need to know if a specific flow ran last night"

**Solution:** Use PowerShell or Power Automate Portal
- PowerShell: `Get-FlowRun -FlowName <id>`
- Or check in Power Automate portal: flow.microsoft.com
- Audit Logs will also show this

### Scenario 3: "I want a dashboard showing all inactive apps"

**Solution:** Use Audit Logs + CoE Dashboards
- Audit Logs provide launch activity
- CoE can correlate with inventory
- Create custom Power BI reports

### Scenario 4: "I need basic inventory without usage data"

**Solution:** Use Cloud Flows (default)
- Standard CoE setup
- No additional configuration needed
- Modified Date can proxy for activity

## Migration Paths

### From BYODL to Audit Logs

1. Keep BYODL running (don't break existing setup)
2. Enable Audit Logs in parallel
3. Update dashboards to use Audit data
4. Once validated, disable BYODL flows
5. Remove BYODL Azure resources

### From No Telemetry to Audit Logs

1. Verify licensing (M365 E3/E5)
2. Enable unified audit logs in M365 admin center
3. Configure `Admin | Audit Logs - Sync Audit Logs V2` flow
4. Wait for initial data collection (24-48 hours)
5. Use audit tables in reports

## Key Takeaways

1. **Cloud Flows** = No last run/launch data (by design)
2. **BYODL** = Deprecated, don't use for new setups
3. **Audit Logs** = Best practice for telemetry
4. **PowerShell** = Ad-hoc queries only

## References

- [Full Troubleshooting Guide](./flow-last-run-app-last-launched.md)
- [CoE Audit Logs Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [CoE Core Components](https://learn.microsoft.com/power-platform/guidance/coe/core-components)
- [Power Platform Admin PowerShell](https://learn.microsoft.com/power-platform/admin/powershell-getting-started)

---

*Last Updated: December 2024*
