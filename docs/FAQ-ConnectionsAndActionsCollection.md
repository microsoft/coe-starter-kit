# FAQ: How CoE Starter Kit Collects App Connection References and Flow Action Details

## Question

How does the CoE Starter Kit collect and update:
- **App Connection References** (list of connectors used by a Canvas App)
- **Flow Action Details** (operations used such as SendEmailV2, UserProfile_V2, etc.)

This document explains which flows are responsible, how the data is extracted, and when/how often it is refreshed.

---

## App Connection References Collection

### Which Flow is Responsible?

**Primary Flow:** `SYNC HELPER - Apps`
- **Technical Name:** `SYNCHELPER-Apps-B677AA25-8DE4-ED11-A7C7-0022480813FF`
- **Called By:** `Admin | Sync Template v4 (Apps)`

### How Are App Connections Extracted?

App connections are extracted from the **Power Apps for Admins connector** using the following process:

1. **API Call:** The flow calls `Get-AdminApp` operation from the Power Apps for Admins connector
2. **Data Source:** The connection information comes from the app's metadata via `properties.connectionReferences` property
3. **Processing:**
   - The flow parses the `connectionReferences` object from the app metadata
   - Extracts connector display names and IDs
   - Creates a comma-separated list of connections
   - Stores this in the `admin_appconnections` field in Dataverse

### Example Flow Logic

```
Get App as Admin (Power Apps for Admins API)
  ↓
Extract properties.connectionReferences
  ↓
Parse connection references JSON
  ↓
Compose comma-separated list
  ↓
Update/Create App record with admin_appconnections field
```

### Data Stored

The following app connection-related fields are populated:
- `admin_appconnections` - Comma-separated list of connector names
- `admin_hasimplicitconnections` - Boolean indicating if app uses implicit (shared) connections
- `admin_hasinsecureimplicitconnections` - Boolean for insecure implicit connections
- `admin_appcontainsbrokenconnections` - Boolean for broken connection references

---

## Flow Action Details Collection

### Which Flow is Responsible?

**Primary Flow:** `Admin | Sync Template v3 (Flow Action Details)`
- **Technical Name:** `AdminSyncTemplatev3FlowActionDetails-7EBB10A6-5041-EB11-A813-000D3A8F4AD6`
- **Trigger:** Runs when an environment record is added or modified in Dataverse

### How Are Flow Actions Extracted?

Flow action details are extracted from the **Power Automate Management connector** using the following process:

1. **API Call:** The flow uses `AdminGetFlow` or `GetFlow` operations from the Power Automate Management connector
2. **Data Source:** The action information comes from:
   - `properties.definitionSummary.triggers` - Trigger information
   - `properties.definitionSummary.actions` - Action information
   - Flow definition metadata via the Power Automate APIs
3. **Processing:**
   - Retrieves flows from the environment
   - For each flow, calls the Flow Management API to get detailed definition
   - Parses the trigger and action arrays
   - Extracts action types and operation names (e.g., `SendEmailV2`, `UserProfile_V2`)
   - Creates records in the `admin_FlowActionDetail` table in Dataverse

### Example Flow Logic

```
Trigger: Environment record added/modified
  ↓
Get Flows in Environment
  ↓
For each Flow:
  → Get Flow Definition (AdminGetFlow)
  → Parse definitionSummary.triggers
  → Parse definitionSummary.actions
  → Extract action types and operations
  → Create/Update Flow Action Detail records
```

### Data Stored

Flow action details are stored in the `admin_FlowActionDetail` table with fields such as:
- Action Type (e.g., "Office 365 Outlook", "Office 365 Users")
- Operation Name (e.g., "SendEmailV2", "UserProfile_V2")
- Associated Flow ID
- Connector information

---

## When and How Often Data is Refreshed

### Refresh Schedule

The inventory sync follows this pattern:

1. **Driver Flow Schedule:** `Admin | Sync Template v4 (Driver)` runs on a schedule (typically daily)
   - This flow updates environment records in Dataverse
   
2. **Triggered by Environment Changes:** When an environment record is updated:
   - `Admin | Sync Template v4 (Apps)` → calls → `SYNC HELPER - Apps` (for app connections)
   - `Admin | Sync Template v3 (Flow Action Details)` (for flow actions)

3. **Incremental vs. Full Inventory:**
   - **Incremental (Default):** Only syncs resources modified in the last N days (default 7)
   - **Full Inventory:** Set environment variable `admin_FullInventory` to `Yes` to scan all resources

### Environment Variables That Control Refresh

- `admin_FullInventory` - Run full inventory (Yes/No, default: No)
- `admin_InventoryFilter_DaysToLookBack` - Days to look back for modified resources (default: 7)
- `admin_DelayObjectInventory` - Add random delay to avoid throttling (Yes/No, default: No)

### On-Demand Refresh

You can manually trigger a refresh by:

1. **For App Connections:**
   - Run `Admin | Sync Template v4 (Apps)` flow manually for a specific environment
   
2. **For Flow Actions:**
   - Run `Admin | Sync Template v3 (Flow Action Details)` flow manually
   - Or update the environment record to trigger the automated flow

---

## Data Sources Summary

| What | API/Connector | Specific Operation | Property Path |
|------|--------------|-------------------|---------------|
| **App Connections** | Power Apps for Admins | `Get-AdminApp` | `properties.connectionReferences` |
| **Flow Actions** | Power Automate Management | `AdminGetFlow` or `GetFlow` | `properties.definitionSummary.actions`<br>`properties.definitionSummary.triggers` |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│  Admin | Sync Template v4 (Driver)                      │
│  (Runs on schedule - typically daily)                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ├─► Updates Environment Records in Dataverse
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌───────────────────┐   ┌─────────────────────────────┐
│ App Sync Triggers │   │ Flow Action Sync Triggers    │
└────────┬──────────┘   └──────────┬──────────────────┘
         │                         │
         ▼                         ▼
┌──────────────────────────┐  ┌───────────────────────────────┐
│ Admin | Sync v4 (Apps)   │  │ Admin | Sync v3 (Flow Action  │
│         ↓                 │  │        Details)                │
│ SYNC HELPER - Apps       │  │                                │
│         ↓                 │  │                                │
│ Calls Power Apps Admin   │  │ Calls Flow Management API      │
│         ↓                 │  │         ↓                      │
│ Gets connectionReferences│  │ Gets definitionSummary.actions │
│         ↓                 │  │         ↓                      │
│ Stores in admin_app...   │  │ Stores in admin_FlowAction...  │
│   connections field      │  │   Detail table                 │
└──────────────────────────┘  └───────────────────────────────┘
```

---

## Customizing the Logic

If you want to review or customize how connections and actions are collected:

### For App Connections:
1. Open **SYNC HELPER - Apps** flow in the CoE environment
2. Find the action **"Parse Connection References"**
3. Review the **"Compose comma-separated list of connection references"** action
4. Modify the logic to capture additional connection metadata if needed

### For Flow Actions:
1. Open **Admin | Sync Template v3 (Flow Action Details)** flow
2. Find the actions **"Parse trigger"** and **"Parse actions"**
3. Review how action types and operations are extracted
4. Modify the **admin_FlowActionDetail** record creation logic to capture additional fields

### Important Considerations:
- **Unmanaged Layers:** If you customize these flows, you will create an unmanaged layer that may prevent future updates from the CoE Starter Kit team
- **Best Practice:** Consider creating a separate custom flow that reads from the existing tables rather than modifying the sync flows directly
- **Testing:** Always test customizations in a non-production environment first

---

## Troubleshooting

### App Connections Not Showing

1. **Check the sync flow runs:**
   - Review `Admin | Sync Template v4 (Apps)` run history
   - Check for errors in `SYNC HELPER - Apps`

2. **Verify API permissions:**
   - Ensure the service account has Power Platform Admin role
   - Confirm Power Apps for Admins connector is properly configured

3. **Check environment variable:**
   - If only recent apps show connections, run a full inventory by setting `admin_FullInventory` to `Yes`

### Flow Actions Not Appearing

1. **Check the sync flow runs:**
   - Review `Admin | Sync Template v3 (Flow Action Details)` run history
   - Look for `admin_SyncFlowErrors` records for any errors

2. **Verify the flow trigger:**
   - Ensure environment records are being created/updated
   - Manually update an environment record to trigger the flow

3. **Check pagination:**
   - If you have many flows, ensure pagination is working correctly
   - Review the flow run to confirm all flows are being processed

---

## Related Documentation

- [CoE Starter Kit - Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [CoE Starter Kit - Inventory Overview](https://learn.microsoft.com/power-platform/guidance/coe/core-components)
- [CoE Starter Kit - FAQ](https://learn.microsoft.com/power-platform/guidance/coe/faq)
- [Data Retention and Maintenance](../CenterofExcellenceResources/DataRetentionAndMaintenance.md)

---

## Need More Help?

- **GitHub Issues:** [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)
- **Community:** [Power Apps Governance Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- **Official Documentation:** [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
