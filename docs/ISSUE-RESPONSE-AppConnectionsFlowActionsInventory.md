# Issue Response Template: How CoE Collects App Connections and Flow Actions

## Standard Response for Questions About App Connection References and Flow Action Details Collection

---

Thank you for your question about how the CoE Starter Kit collects App Connection References and Flow Action Details!

## Quick Answer

### 📱 App Connection References (Connectors used by Apps)

**Responsible Flows:**
1. `Admin | Sync Template v4 (Apps)` - Orchestrates app inventory
2. `SYNC HELPER | Apps` - **This is the flow that extracts connection references**

**How it works:**
- Uses the **Power Apps for Admins Connector**
- Calls `Get App as Admin` API operation
- Parses the `connectionReferences` object from app metadata
- Stores in the `admin_ConnectionReference` Dataverse entity

**Data Source:** Power Apps Admin API

### 🔄 Flow Action Details (Operations like SendEmailV2, UserProfile_V2)

**Responsible Flow:**
- `Admin | Sync Template v3 (Flow Action Details)` - Dedicated flow for flow actions

**How it works:**
- Uses the **Power Automate Management Connector**
- Retrieves flow definition JSON
- Parses the `actions` node from the definition
- Extracts action type (connector) and operation name
- Stores in the `admin_FlowActionDetail` Dataverse entity

**Data Source:** Power Automate Management API (flow definition parsing)

---

## When and How Often Are These Refreshed?

### Incremental Mode (Default - Nightly)
- **Frequency:** Daily when `Admin | Sync Template v4 (Driver)` runs
- **Scope:** Only apps/flows modified in last 7 days (controlled by `admin_InventoryFilter_DaysToLookBack`)
- **Trigger:** Driver flow updates environment records → triggers downstream inventory flows

### Full Inventory (On-Demand)
To capture ALL apps and flows regardless of modification date:
1. Set environment variable `admin_FullInventory` = `Yes`
2. Run the Driver flow
3. **Remember to set back to `No`** after completion

---

## Detailed Architecture

### For App Connections:

```
Admin | Sync Template v4 (Driver)
    ↓ (daily schedule)
    ↓ Updates environment records
    ↓
Admin | Sync Template v4 (Apps)
    ↓ (triggered by environment update)
    ↓ Gets list of apps per environment
    ↓ For each app, calls...
    ↓
SYNC HELPER | Apps  ← THIS IS WHERE CONNECTIONS ARE EXTRACTED
    ↓
    ├─ Calls: Get App as Admin (Power Apps for Admins API)
    ├─ Returns: App metadata including connectionReferences
    ├─ Parses: Each connection reference
    └─ Stores: admin_ConnectionReference entity
```

### For Flow Actions:

```
Admin | Sync Template v4 (Driver)
    ↓ (daily schedule)
    ↓ Updates environment records
    ↓
Admin | Sync Template v3 (Flow Action Details)
    ↓ (triggered by environment update)
    ├─ Gets list of flows for environment
    ├─ For each flow:
    │   ├─ Get flow definition (Power Automate Management API)
    │   ├─ Parse JSON definition → extract "actions" node
    │   └─ For each action:
    │       ├─ Extract action type (connector name)
    │       ├─ Extract operation (e.g., SendEmailV2)
    │       └─ Store in admin_FlowActionDetail entity
    └─ Links actions to parent flow record
```

---

## How to Review or Customize

### View the Flows in Your Environment

1. Navigate to your CoE environment in **Power Automate**
2. Go to **Solutions** → **Center of Excellence - Core Components**
3. Filter by **Cloud flows**
4. Look for:
   - `Admin | Sync Template v4 (Apps)`
   - `SYNC HELPER | Apps` ← **App connections logic is here**
   - `Admin | Sync Template v3 (Flow Action Details)` ← **Flow actions logic is here**
   - `Admin | Sync Template v4 (Connection Identities)` - Tracks connection owners/identities

### View the Data

**In the CoE Admin App:**
- Canvas Apps → Navigate to app → **Connections** tab
- Cloud Flows → Navigate to flow → **Connections and Actions** tab

**In Dataverse (Advanced):**
- `admin_ConnectionReference` table - App connections
- `admin_FlowActionDetail` table - Flow actions
- `admin_ConnectionReferenceIdentity` table - Connection identities

---

## Customization Considerations

⚠️ **Important:** Editing managed flows creates unmanaged layers that prevent automatic updates during CoE Kit upgrades.

**Best practices if you need custom logic:**
1. Create separate child flows for custom processing
2. Store custom data in new custom entities (not modifying existing ones)
3. Use Power Automate's "Run after" to trigger custom flows
4. Document all customizations

**If you modify core flows:**
- You won't receive automatic updates for those flows
- You'll need to remove customizations before upgrading
- Then reapply your changes after upgrade

---

## Troubleshooting

### Connections Not Appearing for Apps

**Check:**
1. Has the app been inventoried recently? (incremental mode only syncs changed apps)
2. Is `SYNC HELPER | Apps` flow running successfully?
3. Is the Power Apps for Admins connection valid?

**Solution:** Run full inventory or manually trigger app sync

### Flow Actions Not Appearing

**Check:**
1. Is `Admin | Sync Template v3 (Flow Action Details)` turned on?
2. Has the flow been inventoried recently?
3. Check flow run history for errors

**Solution:** Run full inventory or manually trigger flow action details sync

---

## Additional Resources

**New Comprehensive FAQ Created:**
We've created a detailed FAQ document that covers this topic in depth:
- **[FAQ: App Connections and Flow Actions Collection](./FAQ-AppConnectionsAndFlowActions.md)**

**Official Documentation:**
- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Inventory and Telemetry](https://learn.microsoft.com/power-platform/guidance/coe/core-components)

**Power Platform APIs:**
- [Power Apps for Admins Connector](https://learn.microsoft.com/connectors/powerappsforadmins/)
- [Power Automate Management Connector](https://learn.microsoft.com/connectors/flowmanagement/)

---

## Summary Table

| What | Which Flow(s) | Data Source | Storage Table | Refresh Frequency |
|------|--------------|-------------|---------------|------------------|
| **App Connection References** | SYNC HELPER \| Apps | Power Apps Admin API | admin_ConnectionReference | Daily (incremental) or on-demand (full) |
| **Flow Action Details** | Admin \| Sync Template v3 (Flow Action Details) | Power Automate Management API | admin_FlowActionDetail | Daily (incremental) or on-demand (full) |
| **Connection Identities** | Admin \| Sync Template v4 (Connection Identities) | Power Apps Admin API | admin_ConnectionReferenceIdentity | Daily (incremental) or on-demand (full) |

---

Hope this helps! Let us know if you have any follow-up questions. 🚀

---

**Template Version:** 1.0  
**Last Updated:** 2026-01-30  
**Related FAQ:** [FAQ-AppConnectionsAndFlowActions.md](./FAQ-AppConnectionsAndFlowActions.md)
