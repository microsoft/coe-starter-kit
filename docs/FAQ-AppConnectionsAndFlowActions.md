# FAQ: How the CoE Starter Kit Collects App Connection References and Flow Action Details

## Overview

This document explains how the CoE Starter Kit collects and updates:
- **App Connection References** (connectors used by Canvas Apps and Model-Driven Apps)
- **Flow Action Details** (operations/actions used in Cloud Flows, such as SendEmailV2, UserProfile_V2, etc.)

These details appear in the Power Platform Admin view apps and are stored in the CoE Dataverse environment for governance, compliance, and reporting purposes.

---

## Quick Answer

### App Connection References

**Primary Flow:** `Admin | Sync Template v4 (Apps)` → triggers → `SYNC HELPER | Apps`

**Data Source:** Power Apps for Admins Connector
- API call: `Get App as Admin` operation
- Extracts connection references from the app metadata returned by the admin API

**Entity:** `admin_ConnectionReference`

**Trigger Schedule:** When environment records are created or updated (triggered by the Driver flow)

### Flow Action Details

**Primary Flow:** `Admin | Sync Template v3 (Flow Action Details)`

**Data Source:** Power Automate Management Connector
- Parses the flow definition JSON
- Extracts action types (e.g., Office 365 Outlook, SharePoint operations)
- Identifies specific operations (e.g., SendEmailV2, UserProfile_V2)

**Entity:** `admin_FlowActionDetail`

**Trigger Schedule:** When environment records are created or updated (triggered by the Driver flow)

---

## Detailed Explanation

### 1. App Connection References Collection

#### Which Flows Are Responsible?

The collection of App Connection References involves multiple flows working together:

1. **Admin | Sync Template v4 (Driver)** [`AdminSyncTemplatev4Driver`]
   - Main orchestration flow that runs on a schedule (typically daily)
   - Updates environment records, which triggers downstream inventory flows

2. **Admin | Sync Template v4 (Apps)** [`AdminSyncTemplatev4Apps`]
   - Triggered when an environment record is created or updated
   - Retrieves the list of apps in each environment
   - For each app, calls the SYNC HELPER flow

3. **SYNC HELPER | Apps** [`SYNCHELPER-Apps`]
   - Child flow that performs detailed inventory for each individual app
   - **This is where connection references are extracted and stored**

#### How Are Connection References Extracted?

The extraction process works as follows:

```
1. SYNC HELPER | Apps receives an app GUID and environment ID
   ↓
2. Calls "Get App as Admin" (Power Apps for Admins Connector)
   ↓
3. API returns app metadata including:
   - App properties (display name, owner, etc.)
   - connectionReferences object containing all connectors used
   ↓
4. Flow parses the connectionReferences from the response
   ↓
5. For each connection reference:
   - Creates or updates record in admin_ConnectionReference entity
   - Stores: Connector name, Display name, Connection ID, App relationship
   ↓
6. Updates the PowerApp record with connection summary
```

**Key API Operation:**
- **Connector:** Power Apps for Admins (`shared_powerappsforadmins`)
- **Operation:** `Get-AdminPowerApp` / "Get App as Admin"
- **Returns:** Complete app metadata including all connection references

#### Data Stored

The `admin_ConnectionReference` entity stores:
- Connector ID (e.g., `shared_sharepointonline`)
- Connector display name (e.g., "SharePoint")
- Connection ID (specific connection instance)
- Relationship to the parent app (`admin_PowerApp`)
- Created/modified timestamps

---

### 2. Flow Action Details Collection

#### Which Flow Is Responsible?

**Primary Flow:** `Admin | Sync Template v3 (Flow Action Details)` [`AdminSyncTemplatev3FlowActionDetails`]

This flow is specifically dedicated to collecting action details from Cloud Flows.

#### How Are Flow Actions Extracted?

The extraction process:

```
1. Triggered when environment record is created/updated
   ↓
2. Retrieves list of Cloud Flows for the environment
   ↓
3. For each flow:
   a. Gets flow definition using Power Automate Management Connector
   b. Parses the flow definition JSON structure
   c. Iterates through all "actions" in the definition
   d. Extracts:
      - Action Type (connector name, e.g., "Office 365 Outlook")
      - Operation (specific action, e.g., "SendEmailV2")
      - Action metadata
   ↓
4. Stores each action in admin_FlowActionDetail entity
   ↓
5. Links action details to parent flow record
```

**Key API Operations:**
- **Connector:** Power Automate Management (`shared_flowmanagement`)
- **Operation:** Get flow definition
- **Parses:** JSON definition to extract `actions` node

#### Data Stored

The `admin_FlowActionDetail` entity stores:
- Action Type (connector/service name)
- Operation (specific operation like "SendEmailV2")
- Relationship to parent flow (`admin_Flow`)
- Action metadata
- Created/modified timestamps

---

### 3. Connection Identities (Additional Context)

There's also a related flow for connection identities:

**Flow:** `Admin | Sync Template v4 (Connection Identities)` [`AdminSyncTemplatev4ConnectionIdentities`]

**Purpose:** Tracks who owns/uses specific connections (the identity behind the connection)

**Entity:** `admin_ConnectionReferenceIdentity`

This complements the connection reference data by tracking the user accounts associated with each connection.

---

## When and How Often Are These Details Refreshed?

### Incremental Mode (Default)

By default, the CoE Starter Kit runs in **incremental mode**:

- **Frequency:** Daily (when Driver flow runs on schedule)
- **Scope:** Only apps/flows modified within the last N days (default: 7 days)
- **Environment Variable:** `admin_InventoryFilter_DaysToLookBack` (default: 7)

**How it works:**
1. Driver flow runs daily (scheduled trigger)
2. Updates environment records with current modification timestamps
3. This triggers downstream flows (Apps, Flows, etc.)
4. Each flow checks: "Has this object changed in the last 7 days?"
5. If yes → full inventory for that object
6. If no → skip to save API calls

### Full Inventory Mode

To capture ALL apps and flows regardless of modification date:

1. Set environment variable `admin_FullInventory` to `Yes`
2. Run the Driver flow manually or wait for scheduled run
3. All apps, flows, and their connections/actions will be inventoried
4. **Remember to set back to `No`** after completion to avoid long-running flows

### On-Demand Refresh

You can trigger a manual refresh:

1. **Via Setup Wizard:** Use the "Run Inventory" function
2. **Manually:** Run `Admin | Sync Template v4 (Driver)` with `admin_FullInventory=Yes`
3. **For specific environment:** Update an environment record (modify any field) to trigger inventory

---

## How to Review or Customize the Logic

### Viewing the Flows

1. Navigate to your CoE environment in Power Automate
2. Go to **Solutions** → **Center of Excellence - Core Components**
3. Filter by "Cloud flows"
4. Search for:
   - `Admin | Sync Template v4 (Apps)` - App inventory orchestration
   - `SYNC HELPER | Apps` - Detailed app inventory including connections
   - `Admin | Sync Template v3 (Flow Action Details)` - Flow actions inventory
   - `Admin | Sync Template v4 (Connection Identities)` - Connection identity tracking

### Editing the Flows

⚠️ **Important Considerations:**

1. **Unmanaged Layers:** Editing managed flows creates an unmanaged layer
   - Unmanaged layers prevent automatic updates during CoE Kit upgrades
   - You'll need to remove customizations to receive updates

2. **Best Practice:** Instead of modifying core flows:
   - Create custom child flows for additional logic
   - Use Power Automate's "Run after" patterns
   - Store custom data in separate custom entities

3. **If You Must Customize:**
   - Document all changes
   - Export your customizations before upgrading
   - Be prepared to reapply customizations after upgrades

### Viewing the Data

**In the CoE Admin App:**
- Canvas Apps: Navigate to app details → **Connections** tab
- Cloud Flows: Navigate to flow details → **Connections and Actions** tab

**In Dataverse:**
- Table: `admin_ConnectionReference` - App connection references
- Table: `admin_FlowActionDetail` - Flow action details
- Table: `admin_ConnectionReferenceIdentity` - Connection identities

**In Power BI:**
- Connection data appears in governance and compliance reports
- Action details used for flow analytics dashboards

---

## Technical Architecture Summary

### Data Collection Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  Admin | Sync Template v4 (Driver)                                  │
│  • Runs: Daily (scheduled trigger)                                  │
│  • Purpose: Main orchestration - triggers all inventory flows       │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ├─────► Updates Environment records in Dataverse
                     │        (triggers downstream flows via Dataverse trigger)
                     │
     ┌───────────────┴──────────────┬─────────────────────────┐
     │                              │                         │
     ▼                              ▼                         ▼
┌────────────────────┐  ┌───────────────────────┐  ┌─────────────────┐
│ Apps Inventory     │  │ Flows Inventory       │  │ Other Inventory │
│ (v4 Apps)          │  │ (v4 Flows)            │  │ - Connectors    │
└──────┬─────────────┘  └───────────────────────┘  │ - Environments  │
       │                             │              │ - Solutions     │
       │                             │              └─────────────────┘
       │                             │
       ▼                             ▼
┌────────────────────┐  ┌───────────────────────────────────┐
│ SYNC HELPER        │  │ Admin | Sync Template v3          │
│ | Apps             │  │ (Flow Action Details)             │
│                    │  │                                   │
│ 🔍 Extracts:       │  │ 🔍 Extracts:                      │
│ • App properties   │  │ • Parses flow definition JSON     │
│ • Connection Refs  │  │ • Extracts all actions            │
│   (via Get App     │  │ • Identifies connectors used      │
│    as Admin API)   │  │ • Captures operation names        │
│                    │  │   (e.g., SendEmailV2)             │
│ 💾 Stores in:      │  │                                   │
│ • admin_PowerApp   │  │ 💾 Stores in:                     │
│ • admin_           │  │ • admin_FlowActionDetail          │
│   ConnectionRef    │  │   (linked to admin_Flow)          │
└────────────────────┘  └───────────────────────────────────┘

                    ┌───────────────────────────────────┐
                    │ Admin | Sync Template v4          │
                    │ (Connection Identities)           │
                    │                                   │
                    │ 🔍 Extracts:                      │
                    │ • Connection owner identities     │
                    │ • User accounts using connections │
                    │ • Permission details              │
                    │                                   │
                    │ 💾 Stores in:                     │
                    │ • admin_ConnectionReferenceId     │
                    └───────────────────────────────────┘
```

### Detailed Flow: App Connection References

```
┌──────────────────────────────────────────────────────────────────┐
│ SYNC HELPER | Apps Flow                                          │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Input: App GUID, Environment ID                                │
│    │                                                             │
│    ▼                                                             │
│  ┌────────────────────────────────────────────┐                 │
│  │ 1. Call Power Apps for Admins API         │                 │
│  │    Operation: Get App as Admin            │                 │
│  │    Returns: Complete app metadata         │                 │
│  └───────────────┬────────────────────────────┘                 │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────┐                 │
│  │ 2. Parse API Response                     │                 │
│  │    Extract: properties.connectionReferences│                 │
│  │    Example structure:                     │                 │
│  │    {                                       │                 │
│  │      "shared_sharepointonline": {         │                 │
│  │        "id": "/providers/.../sharepoint", │                 │
│  │        "displayName": "SharePoint"        │                 │
│  │      },                                    │                 │
│  │      "shared_office365users": { ... }     │                 │
│  │    }                                       │                 │
│  └───────────────┬────────────────────────────┘                 │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────┐                 │
│  │ 3. For Each Connection Reference          │                 │
│  │    • Extract connector ID                 │                 │
│  │    • Extract display name                 │                 │
│  │    • Check if record exists in Dataverse  │                 │
│  │    • Create or Update record              │                 │
│  └───────────────┬────────────────────────────┘                 │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────┐                 │
│  │ 4. Store in admin_ConnectionReference     │                 │
│  │    Fields populated:                      │                 │
│  │    • admin_connectorid (e.g., "shared_sp")│                 │
│  │    • admin_connectorname ("SharePoint")   │                 │
│  │    • admin_connectionid (connection GUID) │                 │
│  │    • admin_powerapp (FK to app record)    │                 │
│  └───────────────┬────────────────────────────┘                 │
│                  │                                               │
│                  ▼                                               │
│  ✅ Connection references visible in CoE Admin App              │
│     under app → Connections tab                                 │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Detailed Flow: Flow Action Details

```
┌──────────────────────────────────────────────────────────────────┐
│ Admin | Sync Template v3 (Flow Action Details)                  │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Input: Environment record created/updated                      │
│    │                                                             │
│    ▼                                                             │
│  ┌────────────────────────────────────────────┐                 │
│  │ 1. Get List of Flows in Environment       │                 │
│  │    Source: admin_Flow Dataverse entity    │                 │
│  └───────────────┬────────────────────────────┘                 │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────┐                 │
│  │ 2. For Each Flow                          │                 │
│  │    Call Power Automate Management API     │                 │
│  │    Operation: Get flow definition         │                 │
│  │    Returns: Flow definition JSON          │                 │
│  └───────────────┬────────────────────────────┘                 │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────┐                 │
│  │ 3. Parse Flow Definition                  │                 │
│  │    Navigate to: definition.actions node   │                 │
│  │    Example structure:                     │                 │
│  │    "actions": {                            │                 │
│  │      "Send_an_email_(V2)": {              │                 │
│  │        "type": "OpenApiConnection",       │                 │
│  │        "inputs": {                         │                 │
│  │          "host": {                         │                 │
│  │            "apiId": ".../office365"       │                 │
│  │            "operationId": "SendEmailV2"   │                 │
│  │          }                                 │                 │
│  │        }                                   │                 │
│  │      }                                     │                 │
│  │    }                                       │                 │
│  └───────────────┬────────────────────────────┘                 │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────┐                 │
│  │ 4. Extract Action Details                 │                 │
│  │    For each action:                       │                 │
│  │    • Action type/connector                │                 │
│  │      (e.g., "Office 365 Outlook")         │                 │
│  │    • Operation                             │                 │
│  │      (e.g., "SendEmailV2")                │                 │
│  │    • Action metadata                       │                 │
│  └───────────────┬────────────────────────────┘                 │
│                  │                                               │
│                  ▼                                               │
│  ┌────────────────────────────────────────────┐                 │
│  │ 5. Store in admin_FlowActionDetail        │                 │
│  │    Fields populated:                      │                 │
│  │    • admin_actiontype (connector name)    │                 │
│  │    • admin_operation ("SendEmailV2")      │                 │
│  │    • admin_flow (FK to flow record)       │                 │
│  │    • Created/modified timestamps          │                 │
│  └───────────────┬────────────────────────────┘                 │
│                  │                                               │
│                  ▼                                               │
│  ✅ Flow actions visible in CoE Admin App                       │
│     under flow → Connections and Actions tab                    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### API Sources

| Data Type | Primary API | Connector | Key Operation |
|-----------|------------|-----------|---------------|
| App Connection References | Power Apps Admin API | `shared_powerappsforadmins` | Get-AdminPowerApp |
| Flow Action Details | Power Automate Management API | `shared_flowmanagement` | Get flow definition |
| Connection Identities | Power Apps Admin API | `shared_powerappsforadmins` | Get-AdminConnection |

---

## Troubleshooting

### Connection References Not Appearing

**Symptoms:** App shows in inventory but "Connections" tab is empty

**Common Causes:**
1. App hasn't been inventoried yet (incremental mode, not modified recently)
   - **Solution:** Run full inventory or update the app to trigger sync

2. SYNC HELPER | Apps flow is failing
   - **Solution:** Check flow run history for errors
   - Verify Power Apps for Admins connection is valid

3. App doesn't use any connections
   - **Expected:** Some apps only use built-in functions

**Verification Steps:**
```
1. Check admin_ConnectionReference table in Dataverse
   - Filter by App GUID
   - Verify records exist

2. Check SYNC HELPER | Apps flow run history
   - Find run for your specific app
   - Look for "Initialize_ActualConnectionsArray" action
   - Verify connectionReferences were parsed
```

### Flow Action Details Not Appearing

**Symptoms:** Flow shows in inventory but "Connections and Actions" tab is empty

**Common Causes:**
1. Flow hasn't been inventoried yet (incremental mode)
   - **Solution:** Run full inventory or modify the flow

2. Flow Action Details sync flow is turned off
   - **Solution:** Verify `Admin | Sync Template v3 (Flow Action Details)` is turned on

3. Flow definition couldn't be parsed
   - **Solution:** Check flow run history for errors

**Verification Steps:**
```
1. Check admin_FlowActionDetail table
   - Filter by Flow GUID
   - Verify action records exist

2. Check Admin | Sync Template v3 (Flow Action Details) run history
   - Look for successful runs for your environment
```

### Stale Data

**Symptoms:** Changes to connections/actions not reflected in CoE

**Common Causes:**
1. Incremental mode not detecting change
   - **Solution:** Manually trigger inventory for that environment

2. Long time since last Driver run
   - **Solution:** Verify Driver flow is running on schedule

**Force Refresh:**
```
1. Option A: Set admin_FullInventory = Yes and run Driver
2. Option B: Update the environment record to trigger inventory
3. Option C: Manually run the specific sync flow for that environment
```

---

## Related Documentation

- **Official CoE Starter Kit Documentation:** https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Core Components Setup:** https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components
- **Inventory and Telemetry:** https://learn.microsoft.com/power-platform/guidance/coe/core-components

---

## Summary

### App Connection References

- **Flow:** SYNC HELPER | Apps (triggered by Admin | Sync Template v4 Apps)
- **Source:** Power Apps for Admins API - Get App as Admin
- **Storage:** admin_ConnectionReference entity
- **Refresh:** Incremental daily, or full inventory on demand

### Flow Action Details

- **Flow:** Admin | Sync Template v3 (Flow Action Details)
- **Source:** Power Automate Management API - Flow definition parsing
- **Storage:** admin_FlowActionDetail entity
- **Refresh:** Incremental daily, or full inventory on demand

### Key Environment Variables

- `admin_FullInventory` - Run full inventory (Yes/No)
- `admin_InventoryFilter_DaysToLookBack` - Days to look back for changes (default: 7)
- `admin_DelayObjectInventory` - Add delays to avoid throttling (Yes/No)

---

**Last Updated:** 2026-01-30  
**Applies to:** CoE Starter Kit Core Components v1.x and later
