# CoE Starter Kit - Audit Events and Archive Score Summary

## Summary

This document provides information about:
1. **M365 Audit Events** synced into CoE inventory from Office 365 audit logs
2. **Archive Score** calculation methodology in Power BI reports

---

## 1. M365 Audit Events Synced into CoE Inventory

### Overview

The CoE Starter Kit collects audit events from **Office 365 Management API** (or optionally **Microsoft Graph API**) to track usage and lifecycle events for Power Platform resources.

### Key Files

#### Flow: Admin | Audit Logs - Sync Audit Logs V2
**Path**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminAuditLogsSyncAuditLogsV2-BCCF2957-AE51-EF11-A316-6045BD039C1F.json`

**Purpose**: Retrieves audit log events from Office 365 Management API or Microsoft Graph API and stores them in the `admin_auditlog` Dataverse table.

**Trigger**: Runs hourly (every 1 hour)

**Key Environment Variables**:
- `admin_AuditLogsUseGraphAPI` (Boolean, default: `false`) - If `true`, uses Graph API; if `false`, uses Office 365 Management API
- `admin_AuditLogsMinutestoLookBack` (Integer, default: `65`) - Number of minutes back to pull audit logs
- `admin_AuditLogsEndTimeMinutesAgo` (Integer, default: `0`) - How far back in time to start looking for audit logs

#### Flow: Admin | Audit Logs - Update Data V2
**Path**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminAuditLogsUpdateDataV2-1D8BF7B1-D787-EE11-8179-000D3A3411D9.json`

**Purpose**: Triggered when an audit log record with operation `LaunchPowerApp` is created/modified; updates app usage data.

**Trigger**: When a row is added or modified in `admin_auditlog` table with `admin_operation eq 'LaunchPowerApp'`

#### Entity: admin_AuditLog
**Path**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_AuditLog/Entity.xml`

**Key Fields**:
- `admin_operation` (String) - The audit event operation name
- `admin_workload` (String) - The workload (e.g., PowerPlatformApplication)
- `admin_creationtime` (DateTime) - When the event occurred
- `admin_userid` (String) - User ID who performed the action
- `admin_userupn` (String) - User principal name
- `admin_appid` (String) - Related app ID (for app events)

### Audit Events Currently Tracked

Based on flow analysis, the following **Office 365 audit log operations** are currently synced:

#### For Canvas Apps
| Operation | Description | RecordType | Source |
|-----------|-------------|------------|--------|
| **LaunchPowerApp** | When a user launches/opens a Power App | 256 | Office 365 Management API `Audit.General` |
| **DeletePowerApp** | When a Power App is deleted | 256 | Office 365 Management API `Audit.General` |

**RecordType 256** = Power Platform / Dynamics 365 events

#### Filter Logic (from flow JSON, lines 950-960):
```json
"where": "@and(equals(item()?['RecordType'], 256), or(equals(item()?['Operation'], 'LaunchPowerApp'), equals(item()?['Operation'], 'DeletePowerApp')))"
```

### Data Source

**Office 365 Management API** (default):
- **Content Type**: `Audit.General`
- **Subscription Flow**: `AdminAuditLogsOffice365ManagementAPISubscription`
- **Endpoint**: `https://manage.office.com/api/v1.0/{TenantID}/activity/feed/subscriptions/start?contentType=Audit.General`

**Microsoft Graph API** (optional, if `admin_AuditLogsUseGraphAPI = true`):
- **API**: AuditLogQuery API in Microsoft Graph
- **Note**: Preferred technique for backend filtering

### Important Notes

1. **Audit Log Delay**: Audit logs can take up to **48 hours** to fill in the product logs. The flow runs hourly but may not capture all events immediately.

2. **Data Retention**: See `/CenterofExcellenceResources/DataRetentionAndMaintenance.md` for recommended retention policies:
   - **Audit logs**: 90-180 days (or per compliance requirements)

3. **Incremental vs. Full**: The audit log sync runs incrementally by default, looking back 65 minutes each hour.

### Events NOT Currently Tracked

Based on flow analysis, the following events are **NOT** currently synced (but may exist in Office 365 audit logs):

- **Canvas Apps**: CreatePowerApp, ModifyPowerApp, SharePowerApp, UnshareApp
- **Model-Driven Apps**: Launch, Create, Delete, Modify, Share events
- **Cloud Flows**: LaunchedCloudFlow, CreateCloudFlow, DeleteCloudFlow, ModifyCloudFlow
- **Connectors**: CreateConnector, DeleteConnector events
- **Bots**: LaunchedBot, CreateBot, DeleteBot events
- **Desktop Flows**: LaunchedDesktopFlow, CreateDesktopFlow, DeleteDesktopFlow events
- **Solutions**: ImportSolution, ExportSolution, DeleteSolution events
- **Environments**: CreateEnvironment, DeleteEnvironment, ModifyEnvironment events

**Recommendation**: To track additional events, modify the filter logic in `AdminAuditLogsSyncAuditLogsV2` flow to include additional operations and add corresponding case branches.

### CSV Import Alternative

**Flow**: Admin | Audit Logs - Load events from exported Audit Log CSV file
**Path**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminAuditLogsLoadeventsfromexportedAuditLogCSVfil-A6875DF5-55E8-ED11-A7C6-002248081470.json`

**Purpose**: Allows manual import of audit log data from CSV files exported from Office 365 Security & Compliance Center.

**Trigger**: Manual button trigger

**Supported Events**: Same as sync flow (`LaunchPowerApp`, `DeletePowerApp`)

---

## 2. Archive Score Calculation in Power BI

### Overview

The CoE Starter Kit Power BI reports **do not include a calculated "Archive Score" measure**. Instead, the inactivity notification and archival process uses a **binary decision model** based on:

1. **Last Modified Date** (when the resource definition was last changed)
2. **Last Launched Date** (when the resource was last used)
3. **Inactivity Threshold** (default: 6 months, configurable)

### How Inactivity/Archive Decisions Work

#### Source Documentation
**Path**: `/Documentation/InactivityNotificationFlowsGuide.md`

#### Key Flows

1. **Admin | Inactivity notifications v2 - Start Approval for Apps**
   - Identifies apps not launched or modified in the past 6 months (configurable)
   - Sends approval requests to app owners
   - Creates records in `admin_archiveapproval` table

2. **Admin | Inactivity notifications v2 - Start Approval for Flows**
   - Same as above, for Power Automate flows

3. **Admin | Inactivity notifications v2 - Check Approval**
   - Processes approval responses (Approve/Reject)
   - Clears `admin_apparchiverequestignoredsince` field when response received

4. **Admin | Inactivity notifications v2 - Clean Up and Delete**
   - Deletes apps/flows marked for deletion after 21-day grace period

#### Archive Approval Entity
**Path**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_ArchiveApproval/`

**Key Fields**:
- `admin_approvalresponse` (String) - "Approve" or "Reject"
- `admin_apparchiverequestignoredsince` (DateTime) - When request was ignored
- Related app/flow lookup fields

#### App Entity Fields (Archive-Related)
**Path**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_App/Entity.xml`

**Field**: `admin_AppArchiveRequestIgnoredSince` (DateTime)
- Set when an approval request is created
- Cleared when user responds to the approval
- Used to trigger manager notifications

### Configuration

**Environment Variable**: `InactivityNotifications-PastTime-Interval` (default: 6)
**Environment Variable**: `InactivityNotifications-PastTime-Unit` (default: "Month")

**Calculation Logic** (conceptual):
```
IF (LastModifiedDate < (Today - 6 months)) AND (LastLaunchedDate < (Today - 6 months)) THEN
    Inactive = TRUE
    CreateArchiveApproval()
ELSE
    Inactive = FALSE
END IF
```

### Power BI Reports

**Power BI Templates**:
- `/CenterofExcellenceResources/Release/Collateral/CoEStarterKit/Production_CoEDashboard_July2024.pbit`
- `/CenterofExcellenceResources/Release/Collateral/CoEStarterKit/PowerPlatformGovernance_CoEDashboard_July2024.pbit`

**Archive-Related Visuals**:
- Apps/flows with pending archive approvals
- Apps/flows marked for deletion
- Inactive resources (based on last modified/launched dates)

**Note**: There is no "Archive Score" as a numeric weighted calculation. The system uses:
- **Binary decision**: Active vs. Inactive (based on threshold)
- **Approval status**: Pending, Approved (Keep), Rejected (Delete)
- **Ignored duration**: How long user has ignored the request

### Related App

**App**: App and Flow Archive and Clean Up View
**Purpose**: UI for makers to view and respond to archive approval requests

**Configuration**: Set `CleanUpAppURL` environment variable to link from emails

---

## Summary Table

### Audit Events Tracked

| Resource Type | Events Tracked | Events NOT Tracked | Entity |
|---------------|----------------|-------------------|--------|
| Canvas Apps | LaunchPowerApp, DeletePowerApp | CreatePowerApp, ModifyPowerApp, SharePowerApp | admin_App |
| Model-Driven Apps | ❌ None | All events | admin_App |
| Cloud Flows | ❌ None | LaunchedCloudFlow, CreateCloudFlow, etc. | admin_Flow |
| Desktop Flows | ❌ None | LaunchedDesktopFlow, CreateDesktopFlow, etc. | admin_FlowSession |
| Connectors | ❌ None | All events | admin_Connector |
| Bots | ❌ None | LaunchedBot, CreateBot, etc. | admin_Chatbot |
| Solutions | ❌ None | ImportSolution, ExportSolution, etc. | admin_Solution |
| Environments | ❌ None | CreateEnvironment, DeleteEnvironment, etc. | admin_Environment |

### Archive Score

| Feature | Status | Notes |
|---------|--------|-------|
| Archive Score (numeric) | ❌ Not Implemented | No weighted calculation exists |
| Inactivity Detection | ✅ Implemented | Based on last modified/launched dates |
| Approval Workflow | ✅ Implemented | Binary decision: Keep or Delete |
| Configurable Threshold | ✅ Implemented | Default: 6 months |
| Power BI Reporting | ✅ Implemented | Shows inactive resources and approvals |

---

## Recommendations

### To Track More Audit Events

1. **Identify the operations** you want to track from Office 365 Management API schema
2. **Update the filter logic** in `AdminAuditLogsSyncAuditLogsV2` flow:
   ```json
   "where": "@and(equals(item()?['RecordType'], 256), or(...))"
   ```
3. **Add case branches** for each new operation in the Switch action
4. **Test incrementally** with a small time window

### To Implement an Archive Score

If you want a weighted archive score (e.g., 0-100):

1. **Create custom fields** in `admin_App` entity:
   - `admin_ArchiveScore` (Integer)
   - `admin_ArchiveScoreCalculatedOn` (DateTime)

2. **Create a scheduled flow** to calculate the score based on:
   - Days since last modified (weight: 30%)
   - Days since last launched (weight: 40%)
   - Number of users who launched (weight: 20%)
   - Number of connections used (weight: 10%)

3. **Update Power BI reports** to include the new field

4. **Estimated effort**: 2-3 days

---

## References

### Official Microsoft Documentation
- [Office 365 Management Activity API schema](https://learn.microsoft.com/en-us/office/office-365-management-api/office-365-management-activity-api-schema)
- [Power Platform Audit Logs](https://learn.microsoft.com/en-us/power-platform/admin/logging-powerapps)
- [CoE Starter Kit - Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [CoE Starter Kit - Governance Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/governance-components)

### Repository Files
- Core Components: `/CenterofExcellenceCoreComponents/SolutionPackage/src/`
- Documentation: `/Documentation/InactivityNotificationFlowsGuide.md`
- Data Retention Guide: `/CenterofExcellenceResources/DataRetentionAndMaintenance.md`
- Troubleshooting: `/TROUBLESHOOTING-UPGRADES.md`

---

**Document Prepared**: January 2026  
**CoE Starter Kit Version**: Latest (check [releases](https://github.com/microsoft/coe-starter-kit/releases))
