# CoE Starter Kit – Flow Action Consumption Optimization Guide

This guide provides actionable recommendations for reducing Power Automate action (request) consumption across CoE Starter Kit flows, particularly for large-scale tenants.

> **Related Guides:**
> - [Data Retention and Maintenance](DataRetentionAndMaintenance.md) – cleanup of growing Dataverse tables
> - [Quick Start: Data Cleanup](QuickStart-DataCleanup.md) – cleanup for the Security Role Permission table
> - [Reducing Azure Log Analytics Costs](../Documentation/ReducingAzureLogAnalyticsCosts.md)

## Understanding Action Consumption

Every Power Automate flow action (condition, loop iteration, HTTP call, Dataverse operation, etc.) counts as a **request** against your [Power Platform request limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations). In large tenants with hundreds of environments and thousands of resources, CoE inventory and governance flows can generate significant action volumes.

### How CoE Flows Work

The CoE Starter Kit uses a **driver + child flow** pattern:

1. **Driver flows** (scheduled) enumerate environments and trigger child flows per environment.
2. **Child flows** (event-triggered) iterate over resources in each environment and upsert records into Dataverse.
3. **Cleanup flows** (scheduled or event-triggered) remove stale data.
4. **Governance flows** (scheduled or event-triggered) send notifications, check compliance, etc.

Action consumption is proportional to:
- Number of **environments** in your tenant
- Number of **resources** (apps, flows, connectors, solutions, security roles) per environment
- Whether **full inventory** vs. **incremental inventory** is running
- **Frequency** of scheduled flows

## Quick Wins: Environment Variable Tuning

The most impactful optimizations require **no flow modifications** — only environment variable changes.

### 1. Ensure Incremental Inventory (High Impact)

| Variable | Recommended Value | Default | Impact |
|----------|------------------|---------|--------|
| `admin_FullInventory` | **No** | No | Full inventory scans every resource; incremental only processes recently modified resources. Set to `Yes` only for one-time catch-up runs, then set back to `No`. |

**Action:** Verify this is set to `No` in your CoE environment. If it was left on `Yes`, this alone could be causing 5–10× higher action consumption.

### 2. Reduce Lookback Window (Medium Impact)

| Variable | Recommended Value | Default | Impact |
|----------|------------------|---------|--------|
| `admin_InventoryFilter_DaysToLookBack` | **3–5** | 7 | Reduces the window of resources checked for changes. Shorter = fewer resources processed. |

**Action:** Reduce from 7 to 3–5 days. This is safe because the driver runs daily — a 3-day window still provides overlap for resources that may have been missed.

### 3. Scope Inventory to Relevant Environments (High Impact)

| Variable | Recommended Value | Default | Impact |
|----------|------------------|---------|--------|
| `admin_isFullTenantInventory` | **No** (for targeted inventory) | Yes | When `No`, new environments are excluded from inventory by default. You opt in environments individually. |

**Action:** If you only need to govern a subset of environments (e.g., production environments only), set this to `No` and opt in only relevant environments. This directly reduces the number of child flow runs.

**How to opt in/out environments:**
1. Open the **Power Platform Admin View** model-driven app
2. Navigate to **Environments**
3. Set **Excuse from Inventory** to `No` for environments you want to track, `Yes` for those to exclude

### 4. Manage Audit Log Collection Window (Medium Impact)

| Variable | Recommended Value | Default | Impact |
|----------|------------------|---------|--------|
| `admin_AuditLogsMinutestoLookBack` | **65** | 65 | Minutes of audit log data to collect per run. Increasing this value increases actions per run. |
| `admin_AuditLogsEndTimeMinutesAgo` | **2820** (48 hours) | 0 | Set to 2820 to collect more complete but less recent data, reducing duplicate processing. |

**Action:** Keep `admin_AuditLogsMinutestoLookBack` at 65 (default). If you set it higher, each run processes more data. Setting `admin_AuditLogsEndTimeMinutesAgo` to 2820 ensures more complete data collection, which can reduce the need to re-process missed records.

### 5. Enable Delays for Throttling Protection

| Variable | Recommended Value | Default | Impact |
|----------|------------------|---------|--------|
| `admin_DelayInventory` | **Yes** | Yes | Adds delays between environment processing to avoid Dataverse throttling. |
| `admin_DelayObjectInventory` | **No** (default) or **Yes** for large tenants | No | Adds delays between individual resource processing. Increases flow duration but reduces throttling errors and retries. |

**Action:** Keep `admin_DelayInventory` at `Yes`. For very large tenants experiencing throttling errors, consider setting `admin_DelayObjectInventory` to `Yes` — this increases flow run time but reduces failed actions that trigger retries (which consume additional actions).

### 6. Clean Up Sync Errors Promptly

| Variable | Recommended Value | Default | Impact |
|----------|------------------|---------|--------|
| `admin_SyncFlowErrorsDeleteAfterXDays` | **7** | 7 | Sync error records older than this are deleted. Keeping this low reduces data volume and cleanup actions. |

## Flow-by-Flow Optimization Recommendations

Below are specific recommendations for the highest-consuming flows identified in the issue.

### Admin | Sync Template v4 (Security Roles) — ~290K actions/day

**Why it's high:** This flow processes security role assignments for every user in every environment. In large tenants with many environments and users, this is the single largest action consumer.

**Optimizations:**
1. **Exclude non-essential environments** — Use `admin_isFullTenantInventory = No` and opt out developer/sandbox environments that don't need security role tracking.
2. **Implement bulk delete for old data** — The `admin_EnvironmentSecurityRolePermission` table uses an insert-only snapshot pattern. Create a Dataverse bulk delete job to remove records older than 30–90 days. See [Quick Start: Data Cleanup](QuickStart-DataCleanup.md).
3. **Consider disabling if not needed** — If you don't require security role tracking for governance, you can turn off this flow entirely via the CoE Setup Wizard or by disabling it in Power Automate.

### Admin | Sync Template v3 (PVA) — ~90K actions/day

**Why it's high:** Processes all Copilot Studio bots and components across all environments.

**Optimizations:**
1. **Exclude environments** without Copilot Studio bots from inventory.
2. If you don't use Copilot Studio governance features, consider disabling this flow.

### Admin | Sync Template v3 (Solutions) — ~90K actions/day

**Why it's high:** Enumerates all solutions and their components in every environment.

**Optimizations:**
1. **Reduce environment scope** — Exclude sandbox/developer environments.
2. **Ensure incremental mode** — Verify `admin_FullInventory = No`.

### CLEANUP HELPER – Solution Objects — ~70K actions/day

**Why it's high:** Iterates over solution component records to clean up stale data.

**Optimizations:**
1. This flow is triggered by the parent CLEANUP flow. Reducing the number of tracked environments reduces the data volume and cleanup actions.
2. Keep `admin_SyncFlowErrorsDeleteAfterXDays` low to reduce error record volume.

### Admin | Audit Logs | Sync Audit Logs (V2) — ~210K actions/day

**Why it's high:** Runs every hour and processes audit log entries from the unified audit log.

**Optimizations:**
1. **Keep default window** — Don't increase `admin_AuditLogsMinutestoLookBack` beyond 65.
2. **Set end time offset** — Set `admin_AuditLogsEndTimeMinutesAgo` to `2820` for more complete but less frequent data.
3. **Review if hourly is needed** — The flow runs every hour by default. If your governance needs allow, you can modify the recurrence in Power Automate to run every 2–4 hours (note: this creates an unmanaged layer, so re-apply after upgrades).

### Admin | Audit Logs | Update Data (V2) — ~80K actions/day

**Why it's high:** Triggered by audit log records and updates inventory data with usage information.

**Optimizations:**
1. Reducing audit log collection window (see Sync Audit Logs above) directly reduces the volume processed by this flow.
2. Reducing the number of tracked environments reduces the matching records.

### Admin | Sync Template v4 (Driver) — ~30K actions/day

**Why it's high:** The main driver flow that enumerates all environments and triggers child flows.

**Optimizations:**
1. **Reduce environment count** — This is the single most effective optimization. Use `admin_isFullTenantInventory = No`.
2. Ensure the driver runs once per day (default). Do not set it to run more frequently.

### Admin | Sync Template v3 (Flow Action Details) — ~20K actions/day

**Why it's high:** Collects detailed action information for every flow.

**Optimizations:**
1. Reduce the number of tracked environments.
2. If you don't need flow action detail data for governance, consider disabling this flow.

### Admin | Email Managers Ignored Inactivity Notifications Approvals — ~23K actions/day

**Why it's high:** Iterates over all pending inactivity notifications and sends escalation emails.

**Optimizations:**
1. Review and resolve pending inactivity notifications to reduce the backlog.
2. This flow runs on a weekly schedule. Verify it hasn't been modified to run daily.

### HELPER – Maker Check — ~15K actions/day

**Why it's high:** Called by multiple flows to validate maker information.

**Optimizations:**
1. This is a child flow — reducing the number of parent flow invocations reduces its consumption.
2. Reducing environment scope reduces the number of makers to check.

### CLEANUP HELPER – Cloud Flow User Shared With — ~40K actions/day

**Why it's high:** Processes sharing information for all cloud flows.

**Optimizations:**
1. Reduce the number of tracked environments.
2. This cleanup flow runs as needed; its volume is proportional to the data in your CoE tables.

### Agent Inventory | Agents Data Load (Child) — ~20K actions/day

**Why it's high:** Collects agent/bot data for each environment.

**Optimizations:**
1. If you don't need agent inventory, consider disabling the parent Agent Inventory flow.
2. Reduce environment scope.

## Scheduling Recommendations

### Flows That Can Safely Run Less Frequently

Some flows can be changed from their default schedule without significant impact on governance capabilities. **Note:** Changing flow schedules creates an **unmanaged layer** that must be re-applied after CoE Starter Kit upgrades.

| Flow | Default Schedule | Recommended for Large Tenants | Notes |
|------|-----------------|------------------------------|-------|
| Admin \| Sync Template v4 (Driver) | Daily | Daily (keep default) | Core inventory driver — needed daily |
| Admin \| Audit Logs \| Sync Audit Logs (V2) | Hourly | Every 2–4 hours | Reduces audit log actions by 50–75% |
| CLEANUP – Delete Bad Data | Daily | Weekly | Stale data cleanup doesn't need daily runs |
| CLEANUP – Check Deleted | Weekly | Bi-weekly | Detecting deleted resources can run less often |
| Admin \| Sync Template v3 (Sync Flow Errors) | Daily | Every 2–3 days | Error log sync is informational |
| Admin \| Sync Template v4 (Desktop Flow) | Daily | Weekly | Only if desktop flow inventory is a lower priority |
| Admin \| Sync Template v4 (PVA Usage) | Daily | Weekly | Only if Copilot Studio usage data freshness is not critical |

### Flows That Should Keep Default Schedule

| Flow | Default Schedule | Reason |
|------|-----------------|--------|
| Admin \| Sync Template v4 (Driver) | Daily | Core inventory — gaps affect all downstream data |
| Admin \| Gather Tenant SRs | Monthly | Already low frequency |
| Admin \| Add | Monthly | Environment setup — already low frequency |
| Admin \| Compliance detail request v3 | Weekly | Governance cadence |
| CLEANUP – App Shared With | Bi-weekly | Already low frequency |
| CLEANUP – Flow Shared With | Bi-weekly | Already low frequency |

### How to Change Flow Schedules

1. Go to [Power Automate](https://make.powerautomate.com)
2. Navigate to your CoE environment
3. Open the flow you want to modify
4. Click **Edit**
5. Click the trigger (e.g., **Recurrence**)
6. Change the frequency/interval
7. **Save**

> ⚠️ **Important:** Changing a managed flow's trigger creates an **unmanaged layer**. After upgrading the CoE Starter Kit, verify your custom schedules are still in effect, or re-apply them.

## Large Tenant Best Practices

For tenants with **100+ environments** and/or **10,000+ resources**:

### 1. Scope First, Then Optimize

Start by reducing the number of tracked environments (`admin_isFullTenantInventory = No`). This has the highest impact on action consumption.

### 2. Stagger Flow Execution

If multiple driver flows run at the same time, they compete for API quota and increase throttling retries. In the CoE Setup Wizard or Power Automate, stagger start times:
- **Driver flow**: 12:00 AM
- **Desktop Flow inventory**: 3:00 AM
- **Audit Log Sync**: Start of each hour (default)
- **Cleanup flows**: Weekends only

### 3. Monitor Action Consumption

Use the [Power Platform Admin Center](https://admin.powerplatform.microsoft.com) > **Analytics** > **Power Automate** to monitor action consumption by flow. Track trends after making optimizations.

### 4. Use Power Automate Process Mining (Optional)

For advanced analysis, export flow run data and use [Process Mining](https://learn.microsoft.com/power-automate/process-mining-overview) to identify which specific actions consume the most requests.

### 5. Plan for Licensing

Review the [Power Platform request limits and allocations](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations) documentation. Consider:
- **Power Automate per-flow plans** for high-volume flows
- **Power Automate Process plan** for additional capacity
- The CoE service account's license type affects request limits

### 6. Consider Dataflow-Based Inventory

The CoE Starter Kit supports Dataflow-based inventory as an alternative to cloud flows. Dataflows use different compute and do not consume Power Automate requests. See the [CoE Setup documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup) for Dataflow configuration.

## Security Roles Table Cleanup (40 GB Growth)

The `admin_EnvironmentSecurityRolePermission` table growing to 40 GB is a known pattern in large tenants. This table uses an **insert-only snapshot** model — each sync run creates new records.

### Creating a Bulk Delete Job

If the **User Saved View** option (`(None) – Custom View`) does not appear in the Dataverse bulk delete wizard:

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Go to **Settings** > **Data management** > **Bulk deletion**
4. Click **New**
5. In the **Look for** dropdown, search for `Environment Security Role Permissions`
6. If you don't see a saved view option, select the table directly and add a filter condition:
   - **Field:** `Created On`
   - **Operator:** `Older Than X Days`
   - **Value:** `90` (or your desired retention period)
7. Name the job (e.g., `Cleanup Security Role Permissions - 90 days`)
8. Set it to run **Weekly** during off-peak hours
9. Submit

### Alternative: Advanced Find

If the bulk delete wizard doesn't show the expected options:

1. Open the CoE environment in [Power Apps](https://make.powerapps.com)
2. Go to **Tables** > **Environment Security Role Permissions**
3. Use **Edit filters** or **Advanced Find** to create a view with `Created On older than 90 days`
4. Save the view
5. Return to the bulk delete wizard — your saved view should now appear

### Alternative: PowerShell Cleanup

For immediate large-scale cleanup, use the PowerShell approach documented in the [Data Retention and Maintenance Guide](DataRetentionAndMaintenance.md#option-3-powershell-script).

## Flows Running for Extended Periods (20+ Hours)

Flows running for 19–20+ hours (as shown in the issue screenshots) typically indicate:

### Root Causes

1. **Full inventory mode** — `admin_FullInventory = Yes` causes flows to process every resource, not just changed ones
2. **Very large tenant** — Hundreds of environments with thousands of resources
3. **Dataverse throttling** — API limits cause retries with exponential backoff, extending run times
4. **Concurrent execution** — Multiple flow instances running simultaneously compete for API quota

### Mitigations

1. **Set `admin_FullInventory` to `No`** — This is the most common cause of extended flow runs
2. **Reduce environment scope** — Fewer environments = shorter flow runs
3. **Enable `admin_DelayObjectInventory = Yes`** — Adds delays to reduce throttling, which paradoxically can reduce total run time by avoiding retry storms
4. **Stagger flow start times** — Don't run multiple inventory flows simultaneously
5. **Check for stuck runs** — If a flow has been running for 24+ hours, it may be stuck. Cancel it and let the next scheduled run pick up

### When to Cancel Long-Running Flows

It is safe to cancel flows that have been running for 24+ hours. The next scheduled run will process any resources that were missed. The CoE inventory is designed to be **eventually consistent** — each run processes changes since the last successful run.

## Summary: Optimization Priority

| Priority | Action | Expected Impact |
|----------|--------|----------------|
| 🔴 High | Set `admin_FullInventory` to `No` | 5–10× reduction if currently `Yes` |
| 🔴 High | Set `admin_isFullTenantInventory` to `No` and exclude non-essential environments | 30–70% reduction depending on exclusions |
| 🟡 Medium | Reduce `admin_InventoryFilter_DaysToLookBack` to 3–5 | 10–30% reduction |
| 🟡 Medium | Set `admin_AuditLogsEndTimeMinutesAgo` to `2820` | Reduces duplicate processing |
| 🟡 Medium | Reduce audit log sync frequency to every 2–4 hours | 50–75% reduction in audit log actions |
| 🟢 Low | Disable flows for features not used (Security Roles, PVA, Desktop Flows) | Eliminates those flow actions entirely |
| 🟢 Low | Implement bulk delete for Security Roles table | Reduces cleanup flow processing time |
| 🟢 Low | Set `admin_DelayObjectInventory` to `Yes` | Reduces throttling retries |

## Additional Resources

- [Power Platform Request Limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Setup and Configuration](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Dataverse Bulk Delete](https://learn.microsoft.com/power-platform/admin/delete-bulk-records)
- [Data Retention and Maintenance Guide](DataRetentionAndMaintenance.md)
- [Quick Start: Data Cleanup](QuickStart-DataCleanup.md)

---

**Document Version**: 1.0
**Last Updated**: February 2026
**Applies to**: CoE Starter Kit Core Components v4.50.x and later
