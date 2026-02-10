# Flow Analysis: Admin | Audit Logs | Load events from exported Audit Log CSV file

## Summary
This document provides a comprehensive analysis of the "Admin | Audit Logs | Load events from exported Audit Log CSV file" flow in the CoE Starter Kit repository.

---

## 1. Flow Location

### Primary Flow Definition
- **File Path**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminAuditLogsLoadeventsfromexportedAuditLogCSVfil-A6875DF5-55E8-ED11-A7C6-002248081470.json`
- **Metadata File**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminAuditLogsLoadeventsfromexportedAuditLogCSVfil-A6875DF5-55E8-ED11-A7C6-002248081470.json.data.xml`
- **Solution**: CenterofExcellenceCoreComponents
- **Solution Version**: 4.50.9
- **Flow ID**: `{a6875df5-55e8-ed11-a7c6-002248081470}`
- **Introduced Version**: 4.4.12

### Official Flow Name
```
Admin | Audit Logs | Load events from exported Audit Log CSV file
```

---

## 2. Flow Description

**Official Description** (from metadata):
> Export historic canvas app launch operations from the office audit logs and import here to get a backlog of usage. **Use only for sync flow architecture, not for BYODL**

### Purpose
This flow enables administrators to:
1. Import **historic** Canvas App launch data from Office 365 Audit Logs
2. Build a **backlog** of app usage data for apps launched before CoE was installed
3. Populate the `admin_auditlogs` Dataverse table with historical launch events
4. Update the `admin_applastlaunchedon` field for Canvas Apps based on imported data

### Key Characteristics
- **Manual Trigger**: Button-triggered flow that accepts a CSV file as input
- **One-Time Import**: Designed for importing historical data, not continuous sync
- **Sync Flow Only**: Works only with the sync flow architecture (not BYODL/Data Lake)
- **App Launch Focus**: Specifically processes "LaunchPowerApp" operations

---

## 3. Flow Structure and Logic

### Input Parameters
The flow accepts a **file input** via manual button trigger:
```json
{
  "file": {
    "title": "Audit Log CSV",
    "type": "object",
    "description": "Please select file or image",
    "properties": {
      "name": { "type": "string" },
      "contentBytes": { "type": "string", "format": "byte" }
    }
  }
}
```

### Connection References
1. **admin_CoECoreDataverse** - Primary Dataverse connection
2. **admin_sharedcommondataserviceforapps_98924** - Secondary Dataverse connection

### Main Processing Steps

#### 1. CSV Parsing (`Load_csv_data` scope)
```
NewLine → Data → Select → LoopFileRows
```

- **NewLine**: Defines line separator (`\n`)
- **Data**: Splits CSV into rows using `split(base64ToString(triggerBody()?['file']?['contentBytes']), outputs('NewLine'))`
- **Select**: Skips header row with `skip(outputs('Data'), 1)`
- **LoopFileRows**: Iterates through each CSV row

#### 2. Row Processing (per audit entry)
For each non-empty audit entry:

a. **Clean and Parse**
   - Remove escape characters: `replace(item()['AuditEntry'], '\\', '')`
   - Detect new vs. old audit log format by checking for `powerplatform.analytics.resource.power_app.id`

b. **Extract Fields**
   ```
   - AuditLogID: split(removeslash, ',')[0]
   - CreatedOn: substring(split(removeslash, ',')[1], 1, 19)
   - Operation: split(removeslash, ',')[3]
   - UPN: split(removeslash, ',')[4]
   - Workload: split from "Workload" JSON property
   - AppID: substring from powerplatform.analytics.resource.power_app.id (first 36 chars)
   ```

c. **Conditional Processing (New Format Only)**
   - Check if `Operation == "LaunchPowerApp"`
   - Query Dataverse for existing app: `admin_apps` where `admin_appid eq {AppID}`
   - If app exists in inventory:
     - **Upsert Audit Log Event** to `admin_auditlogs` table
     - **Update Last Launch Date** if newer than existing `admin_applastlaunchedon`

#### 3. Error Handling (`Error_Handling` scope)
- Creates record in `admin_syncflowerrorses` table
- Updates `admin_coesolutionmetadatas` with failure status
- Terminates flow with error details

#### 4. Success Handling (`Update_last_run_as_pass` scope)
- Updates `admin_coesolutionmetadatas` with success status
- Sets `admin_lastrun` timestamp and `admin_lastrunpassed = true`

---

## 4. Related Audit Log Flows

The CSV import flow is part of a broader audit log collection system:

### Flow Family Overview

| Flow Name | Purpose | Architecture |
|-----------|---------|--------------|
| **Admin \| Audit Logs \| Office 365 Management API Subscription** | Set up HTTP app registration for audit log access | Sync only |
| **Admin \| Audit Logs \| Sync Audit Logs (V2)** | Continuous sync of audit logs via HTTP/O365 Management API | Sync only |
| **Admin \| Audit Logs \| Update Data V2** | Process and update audit log data | Sync only |
| **Admin \| Audit Logs \| Load events from exported CSV** | **One-time import of historic data** | Sync only |

### Related Files
```
CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/
├── AdminAuditLogsOffice365ManagementAPISubscription-CCCA4A5C-21E8-ED11-A7C6-0022480813FF.json (41K)
├── AdminAuditLogsSyncAuditLogsV2-BCCF2957-AE51-EF11-A316-6045BD039C1F.json (125K)
├── AdminAuditLogsUpdateDataV2-1D8BF7B1-D787-EE11-8179-000D3A3411D9.json (23K)
└── AdminAuditLogsLoadeventsfromexportedAuditLogCSVfil-A6875DF5-55E8-ED11-A7C6-002248081470.json (27K)
```

---

## 5. Dataverse Tables Used

### Tables Modified
1. **admin_auditlogs** - Audit log events storage
   - Fields: `admin_creationtime`, `admin_appid`, `admin_AppLookup`, `admin_operation`, `admin_title`, `admin_userupn`, `admin_workload`
   
2. **admin_apps** - Canvas app inventory
   - Fields: `admin_applastlaunchedon` (updated with latest launch date)

3. **admin_syncflowerrorses** - Sync flow error tracking

4. **admin_coesolutionmetadatas** - Flow execution metadata
   - Fields: `admin_lastrun`, `admin_lastrunpassed`

---

## 6. CoE Starter Kit Repository Structure

### Solution Organization
The CoE Starter Kit uses a **multi-solution architecture**:

```
coe-starter-kit/
├── CenterofExcellenceCoreComponents/        ← THIS FLOW IS HERE
│   ├── SolutionPackage/
│   │   ├── src/
│   │   │   ├── Workflows/                    ← Flow JSON definitions
│   │   │   ├── CanvasApps/                   ← Canvas app packages
│   │   │   ├── Entities/                     ← Dataverse table definitions
│   │   │   ├── OptionSets/
│   │   │   ├── Roles/
│   │   │   └── Other/
│   │   │       └── Solution.xml              ← Solution metadata
│   │   └── CenterofExcellenceCoreComponents.cdsproj
│   └── README.md
├── CenterofExcellenceAuditComponents/        ← Governance/compliance flows
├── CenterofExcellenceAuditLogs/              ← DEPRECATED audit solution
├── CenterofExcellenceNurtureComponents/      ← Maker engagement
├── ALMAcceleratorForMakers/                  ← ALM tooling
└── docs/                                      ← Documentation
```

### Workflow Naming Convention
Power Automate flows are stored as JSON files with naming pattern:
```
[FlowDisplayName]-[GUID].json
[FlowDisplayName]-[GUID].json.data.xml  (metadata)
```

Example:
```
AdminAuditLogsLoadeventsfromexportedAuditLogCSVfil-A6875DF5-55E8-ED11-A7C6-002248081470.json
└─ Display name is truncated in filename
   Full name: "Admin | Audit Logs | Load events from exported Audit Log CSV file"
```

---

## 7. Configuration and Setup

### Prerequisites
1. **Core Components solution installed** (version 4.4.12+)
2. **Sync flow architecture** configured (not BYODL)
3. **Connection References** configured:
   - `admin_CoECoreDataverse` (Dataverse connector)
   - `admin_sharedcommondataserviceforapps_98924` (Dataverse connector)
4. **Environment Variable**: `admin_PowerAutomateEnvironmentVariable` set to flow management URL

### How to Obtain CSV Export
To use this flow, you must first export audit logs from Microsoft 365:

1. **Via Microsoft Purview Compliance Portal**:
   - Navigate to: https://compliance.microsoft.com/auditlogsearch
   - Filter for: Workload = "PowerApps", Activity = "LaunchPowerApp"
   - Export results to CSV
   
2. **Via PowerShell** (Office 365 Management API):
   - Use `Search-UnifiedAuditLog` cmdlet
   - Filter for canvas app launch events
   - Export to CSV format

### Expected CSV Format
The flow expects CSV with fields:
- AuditLogID (position 0)
- CreatedOn (position 1)
- Operation (position 3)
- UPN (position 4)
- Workload (JSON field)
- AppID (extracted from JSON if new format)

---

## 8. Usage Recommendations

### When to Use This Flow
✅ **Do use** for:
- Importing **historical** app launch data before CoE installation
- One-time backfill of usage analytics
- Analyzing pre-CoE launch patterns

❌ **Don't use** for:
- Ongoing/continuous audit log collection (use Sync Audit Logs V2 instead)
- BYODL/Data Lake architectures
- Non-LaunchPowerApp operations (flow filters these out)

### Important Notes
⚠️ **Architecture Limitation**:
> "Use only for sync flow architecture, not for BYODL"

This is explicitly stated in the flow description and means:
- The flow writes to Dataverse tables, not Data Lake
- Not compatible with Bring Your Own Data Lake (BYODL) setups
- For BYODL users, use alternative data ingestion methods

⚠️ **New Format Detection**:
The flow handles two audit log formats:
- **Old format**: Direct CSV fields
- **New format**: JSON structure with `powerplatform.analytics.resource.power_app.id`

Only the new format is processed for app launch updates.

---

## 9. Documentation References

### Official Microsoft Documentation
- **CoE Starter Kit Overview**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Setup Core Components**: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components
- **Audit Log Collection**: https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog

### Repository Documentation
- **Core Components README**: `/CenterofExcellenceCoreComponents/README.md`
- **Setup Wizard Troubleshooting**: `/CenterofExcellenceResources/TROUBLESHOOTING-SETUP-WIZARD.md`
- **Quick Setup Checklist**: `/CenterofExcellenceResources/QUICK-SETUP-CHECKLIST.md`

### Related GitHub Issues
Search for issues related to:
- Audit log import
- CSV processing
- App launch data
- BYODL limitations

Query: `is:issue label:core-components audit OR csv OR "app launch"`

---

## 10. Technical Details

### File Statistics
- **JSON Size**: 27 KB
- **XML Metadata Size**: 1.8 KB
- **Total Lines**: 635 (JSON file)

### Power Automate Metadata
```xml
<Workflow WorkflowId="{a6875df5-55e8-ed11-a7c6-002248081470}" 
          Name="Admin | Audit Logs | Load events from exported Audit Log CSV file"
          Type="1"         <!-- Cloud Flow -->
          Category="5"     <!-- Modern Flow -->
          Mode="0"         <!-- Background -->
          Scope="4"        <!-- Organization -->
          RunAs="1">       <!-- Owner -->
```

### Connection Details
Uses **embedded runtime source** for both Dataverse connections:
```json
"connectionReferences": {
  "shared_commondataserviceforapps_2": {
    "runtimeSource": "embedded",
    "connection": { "connectionReferenceLogicalName": "admin_CoECoreDataverse" }
  }
}
```

---

## 11. Troubleshooting

### Common Issues

#### Issue: Flow fails to parse CSV
**Possible Causes**:
- Incorrect CSV format (missing expected columns)
- Special characters not properly escaped
- Wrong encoding (expected UTF-8)

**Solution**:
- Verify CSV export contains required fields
- Check for escape characters in data
- Re-export from Microsoft Purview with default settings

#### Issue: App last launch date not updating
**Possible Causes**:
- App not in CoE inventory yet
- Old audit log format (not new JSON format)
- Operation is not "LaunchPowerApp"

**Solution**:
- Run inventory sync first: `Admin | Sync Template v4 (Apps)`
- Verify CSV contains new format with `powerplatform.analytics.resource.power_app.id`
- Check operation field in CSV

#### Issue: Flow execution times out
**Possible Causes**:
- CSV file too large (>5000 rows)
- Throttling from Dataverse

**Solution**:
- Split CSV into smaller batches
- Add delays between operations
- Run during off-peak hours

### Error Handling
The flow includes comprehensive error handling:
1. Errors logged to `admin_syncflowerrorses`
2. Metadata updated in `admin_coesolutionmetadatas`
3. Flow URL captured for debugging: `{PowerAutomateEnvUrl}/{envName}/flows/{flowId}/runs/{runId}`

---

## 12. Future Considerations

### Deprecation Status
⚠️ **Note**: The flow is marked for sync flow architecture only. As CoE evolves toward cloud-scale architectures:
- BYODL is no longer recommended (per repo documentation)
- Consider **Microsoft Fabric** integration for audit data
- This flow may be deprecated in future versions

### Alternatives
For continuous audit log collection:
1. **Admin | Audit Logs | Sync Audit Logs (V2)** - Ongoing sync via O365 Management API
2. **Microsoft Fabric** - Direct audit log streaming (future direction)
3. **Azure Log Analytics** - For advanced analytics scenarios

---

## Summary

The "Admin | Audit Logs | Load events from exported Audit Log CSV file" flow is a **utility flow** for one-time historical data import. It bridges the gap between Office 365 Audit Logs and CoE Dataverse inventory by:

✅ Importing historic Canvas App launch events  
✅ Updating app last-launched dates  
✅ Supporting both old and new audit log formats  
✅ Providing comprehensive error handling  

⚠️ It is **not** intended for continuous sync and **only works with sync flow architecture**.

---

**Last Updated**: Based on CoE Starter Kit version 4.50.9  
**Flow Introduced**: Version 4.4.12  
**Architecture**: Sync Flow Only (not BYODL)
