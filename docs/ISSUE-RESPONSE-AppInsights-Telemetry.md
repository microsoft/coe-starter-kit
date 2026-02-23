# GitHub Issue Response Template - Application Insights telemetry status (Power Apps)

This template can be used when users ask whether the CoE Starter Kit provides a report or dataset that shows if Application Insights telemetry is enabled for their Power Apps.

---

## Template: Application Insights telemetry enablement for apps

**Use when:** Users want a way to see which apps have Application Insights enabled without opening each app individually.

**Response:**

Thank you for asking about Application Insights telemetry visibility!

### Quick answer

- The CoE Starter Kit **does not inventory or store the Application Insights instrumentation key / telemetry toggle for apps**, so there is **no out-of-the-box report** (including the CoE Power BI dashboards) that can show which apps have telemetry enabled.
- The app inventory sync flow (`Admin | Sync Template v4 (Apps)` and its `SYNCHELPER-Apps` child) upserts fields such as display name, plan classification, connections, DLP status, complexity metrics, etc., but it **does not read or write any Application Insights fields** in `admin_apps`. [CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/SYNCHELPER-Apps-B677AA25-8DE4-ED11-A7C7-0022480813FF.json#L395-L520](../CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/SYNCHELPER-Apps-B677AA25-8DE4-ED11-A7C7-0022480813FF.json#L395-L520)

### How to proceed

1. **Confirm current limitation**: Because the sync flow does not capture instrumentation keys, the CoE datasets cannot expose telemetry-on/off status.
2. **Use your Application Insights resource to discover active apps** (if you already have telemetry flowing):
   - Query your Application Insights workspace for events and group by the app identifiers emitted in telemetry (for example, app name or app ID included in your telemetry payloads).
   - Cross-reference that list with the CoE `admin_apps` table to identify which inventoried apps are sending telemetry.
3. **If you need an inventory flag going forward**, consider a lightweight customization:
   - Add a custom column in `admin_apps` (e.g., `AppInsightsEnabled`) and extend the `SYNCHELPER-Apps` flow to populate it from your own metadata source (for example, a deployment pipeline variable or a maintained list).
   - Then extend your Power BI report to surface that column.
4. **Until a customization is in place**, the only supported verification method is to open each app (or its deployment pipeline metadata) to confirm whether telemetry was enabled.

If you’d like guidance on implementing the customization in your environment, let us know what metadata source you want to use (e.g., ALM pipeline variable, separate Dataverse table, or Application Insights query), and we can outline concrete steps.
