# Issue Response: Dashboard shows incorrect “Last run / execution” dates

## How the CoE populates these fields
- **Power Automate flows**: The `admin_flowlastrunon` field is only populated when the optional **CoE BYODL Flows Last Run Date** dataflow is configured. It reads Power Platform Data Export files from `.../powerautomate/usage`, groups runs per flow, and writes the latest timestamp into Dataverse (`admin_flowlastrunon`). The dataflow currently only pulls the last **3 days** of usage files, so if the export or dataflow refresh isn’t running, dates will go stale. (CenterofExcellenceCoreComponents/SolutionPackage/src/Other/Customizations.xml:876-893)
- **Power Apps**: The `admin_applastlaunchedon` field is updated by the `Admin | Audit Logs Update Data v2` flow when it ingests `LaunchPowerApp` audit events. It only overwrites the value when the new event is newer than the stored one, so older events will be skipped. (CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminAuditLogsUpdateDataV2-1D8BF7B1-D787-EE11-8179-000D3A3411D9.json:320-349)

## Why dates can look wrong (by design)
- **Flows**: If the Power Platform Export to Data Lake (BYODL) isn’t set up, if the “CoE BYODL Flows Last Run Date” dataflow hasn’t refreshed recently, or if runs fall outside the 3-day window it reads, `admin_flowlastrunon` will be blank or outdated. Core inventory flows do **not** set this field.
- **Apps**: Office 365 audit events can arrive with delay (usually 15–60 minutes). If audit logging is disabled, permissions are missing, or the app hasn’t been launched since the feature was enabled, the date will stay old or null.

## Power BI and Copilot data
- The Starter Kit focuses on **Power Apps and Power Automate**; it does not inventory Power BI assets, so Power BI visuals in custom dashboards will be empty by design. (README.md:1-2)
- Copilot coverage is limited to classic Copilot Studio/PVA bots. New declarative or autonomous Copilot agent types are not fully supported yet, so dashboards will not show that usage. (CenterofExcellenceCoreComponents/FAQ-COPILOT-AGENTS-SUPPORT.md:14-19)

## What to check
1. Confirm Power Platform Data Export to Data Lake is enabled and contains recent `/powerautomate/usage` files; refresh the **CoE BYODL Flows Last Run Date** dataflow if flow dates are stale.
2. Verify `Admin | Audit Logs Update Data v2` is running successfully and that Audit Logs are enabled; check that new `LaunchPowerApp` events are landing.
3. Refresh the Power BI report after the above steps; expect timestamps to reflect the latest export/audit data, not real-time execution.

## Field cheat sheet
| Table | Field | What it means | Source |
| --- | --- | --- | --- |
| `admin_flow` | `admin_flowlastrunon` | Last captured flow execution time (when BYODL dataflow runs) | Data Export → `CoE BYODL Flows Last Run Date` dataflow |
| `admin_app` | `admin_applastlaunchedon` | Last app launch time | Office 365 audit events → `Admin | Audit Logs Update Data v2` |
| `admin_auditlog` | `admin_creationtime` | Timestamp from each audit event | Office 365 audit logs |

