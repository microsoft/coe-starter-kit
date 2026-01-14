# Troubleshooting: Mass deletion of cloud flows in an environment

Use this playbook when many flows suddenly show up in the **Deleted Flows** view in the CoE data (for example the default environment showing hundreds or thousands of deleted cloud flows).

> The CoE Starter Kit is provided as samples on a best-effort basis. Cleanup and deletion features are optional and must be configured carefully. See the [official documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit) for the latest architecture and setup guidance.

## Triage template
- **Summary:** 1,696 cloud flows flagged as deleted in the default environment (Core solution inventory).
- **Closest prior issues:** Similar incidents typically occur when cleanup flows are enabled with delete actions. Search the backlog for related items: <https://github.com/microsoft/coe-starter-kit/issues?q=deleted+flows+cleanup>.
- **Root-cause hypotheses (evidence to gather):**
  - Cleanup flows such as **Admin \| Inactivity notifications v2 (Clean Up and Delete)** or **Admin \| Archive and Clean Up (Flows)** ran with delete enabled and processed the default environment.
  - The service principal or account used by the CoE inventory/cleanup flows has Environment Admin rights to default and was recently updated or re-enabled.
  - Inventory mismatch (inventory flow unable to read the environment) marked flows as deleted even though they still exist; confirm in the Power Platform admin center.
  - DLP/licensing changes blocked connectors, causing cleanup logic to treat flows as abandoned.
- **Repro/validation steps:**
  1. In the Power Platform admin center, open the default environment, choose **Flows**, and filter on **Deleted** to confirm whether flows are actually deleted or only flagged in inventory.
  2. In the CoE environment, review run history for:
     - **Admin \| Inactivity notifications v2 (Clean Up and Delete)**
     - **Admin \| Archive and Clean Up (Flows)**
     - **Admin \| Sync Template v3 (Flows)**
  3. Check recent connection reference changes or credential updates for the CoE service principal/account.
  4. If audit logs are enabled, export recent Power Automate delete events to confirm actor and timestamp.
- **Fix plan:**
  - *Short-term mitigation:* Immediately **turn off** the cleanup flows above and pause any scheduled runs for the default environment. Revoke the cleanup connection reference if it is mis-scoped.
  - *Restore deleted flows:* From the admin center (Flows → Deleted) restore items, or use PowerShell:
    ```powershell
    Get-AdminFlow -EnvironmentName "<env-guid>" -IncludeDeleted `
      | Where-Object { $_.Properties.state -eq "Deleted" } `
      | ForEach-Object { Restore-AdminFlow -EnvironmentName $_.EnvironmentName -FlowName $_.FlowName }
    ```
    Restoration is only possible while the platform recycle window is still active.
  - *Durable fix:* Keep cleanup flows in **notify-only** mode until thresholds and approvals are confirmed. If cleanup is required, scope it to non-production environments and confirm DLP/approvals. Re-run **Admin \| Sync Template v3 (Flows)** after restoration to refresh inventory.
  - *DLP/licensing caveats:* Admin PowerShell/connector actions require appropriate admin/Power Automate licenses. Default environments often sit under strict DLP; verify policies before rerunning inventory or cleanup.
- **Next actions:** Confirm which cleanup flow ran, restore affected flows, and decide whether cleanup should stay off or be reconfigured with approvals.
- **If details are missing:** Request the following before proceeding:
  - Describe the issue (number of flows, environments affected, timestamps).
  - Expected behavior.
  - Solution name and version (e.g., Core 4.50.6), and which app/flow is involved.
  - Inventory/telemetry method (CoE inventory flows, Data Lake, etc.).
  - Steps to reproduce or recent changes (credentials, DLP, service principals).
  - Any additional context or screenshots.

## Notes for responders
- Default environments are high-risk for cleanup actions; consider excluding them until explicit approvals are in place.
- BYODL (Data Lake) is deprecated; prefer the current telemetry approach described in docs.
- Keep environments on the English language pack for supported CoE components.
- The kit is best-effort; platform-level restore requests may require opening a Microsoft support ticket if the recycle window has passed.
