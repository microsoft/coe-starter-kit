# Issue Response: Different "Last run" values between Admin Inventory and CoE Starter Kit

## Why the values differ
- **Different data sources**: The Admin Inventory export comes from platform usage analytics. The CoE “App Last Used/Last run” field (`admin_applastlaunchedon`) is populated only from Office 365/Unified Audit Log events.
- **Audit log scope & retention**: The CoE flows ingest only `LaunchPowerApp` audit events (RecordType 256); older runs that fall outside audit log retention (30/90/180 days) or periods when auditing was disabled never get written to `admin_applastlaunchedon` ([AdminAuditLogsSyncAuditLogsV2](../CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminAuditLogsSyncAuditLogsV2-BCCF2957-AE51-EF11-A316-6045BD039C1F.json#L1923-L1975)).
- **Flow run health**: If the audit log flows are off, suspended, or backlogged, CoE data can lag even though Admin Inventory continues to refresh.
- **Full inventory doesn’t update “Last run”**: Running `Admin | Sync Template v4` (full or incremental) does not change `admin_applastlaunchedon`; only the audit log pipeline (or optional CSV import) does.

## Which flow updates the App Last Used field
- **Primary path**: `Admin | Audit Logs - Sync Audit Logs v2` ingests `LaunchPowerApp` events and writes them to `admin_auditlogs`, then `Admin | Audit Logs - Update Data v2` updates `admin_apps.admin_applastlaunchedon` when the new event is newer than the stored value ([AdminAuditLogsUpdateDataV2](../CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminAuditLogsUpdateDataV2-1D8BF7B1-D787-EE11-8179-000D3A3411D9.json#L283-L350)).
- **Optional path**: If you use the “Audit Log CSV Import” helper, it also writes `admin_applastlaunchedon` from the imported CSV.

## Validation checklist for tenants seeing mismatches
- Confirm **Unified Audit Log search is enabled** and retention covers the dates you are comparing.
- Ensure the audit log flows are **turned on and succeeding**: `Admin | Audit Logs - Sync Audit Logs v2` and `Admin | Audit Logs - Update Data v2`.
- If auditing was recently enabled or retention is short, run a **full audit sync/CSV import** that covers the gap period.
- Compare dates only within your audit log retention window; Admin Inventory may show older usage that CoE cannot ingest from expired logs.

## Answers to the user’s questions
1. The two “Last run” values can differ because CoE relies on audit log events (subject to retention, availability, and flow health), while Admin Inventory uses platform analytics that may retain usage longer and refresh on a different schedule.
2. The `admin_applastlaunchedon` (“Last run/App Last Used”) field is updated by the audit log pipeline: **Admin | Audit Logs - Sync Audit Logs v2** → **Admin | Audit Logs - Update Data v2** (or the optional audit log CSV import helper).
