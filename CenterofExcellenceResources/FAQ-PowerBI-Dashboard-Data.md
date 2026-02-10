# FAQ: Power BI Dashboard Data Collection and Inventory Methods

## Overview

This document addresses common questions about how the CoE Starter Kit Power BI Dashboard collects data, inventory methods, and troubleshooting data refresh issues.

---

## Common Questions

### Q: Why is my Power BI Dashboard showing no data or stale data?

**A:** The most common cause is that **inventory flows are not running** or **no inventory method is selected**.

#### Understanding the Data Flow

The Power BI Dashboard doesn't directly collect data from your Power Platform environments. Instead:

```
Power Platform Environments
         ↓
Inventory Flows (Collectors) ← Must be running!
         ↓
Dataverse Tables (admin_app, admin_flow, etc.)
         ↓
Power BI Dashboard (.pbit file)
```

**Key Point**: Simply deploying the .pbit file and entering your org URL **does not** trigger data collection. The inventory flows must run first to populate Dataverse tables.

#### Quick Fix

1. Navigate to [Power Apps](https://make.powerapps.com/) → Your **CoE environment**
2. Go to **Solutions** → **Center of Excellence - Core Components** → **Environment Variables**
3. Find: **FullInventory** (`admin_FullInventory`)
4. Set **Current Value** = `Yes`
5. Wait 6-24 hours for completion (varies by tenant size)
6. ⚠️ **Set back to** `No` after completion
7. Refresh your Power BI Dashboard

📖 **For detailed troubleshooting**, see: [Power BI Dashboard Stale Data Guide](../docs/troubleshooting/power-bi-dashboard-stale-data.md)

---

### Q: What does "inventory method" mean and which one should I select?

**A:** The inventory method determines **how data is collected** from your Power Platform environments.

#### Available Inventory Methods

| Method | Description | When to Use | Status |
|--------|-------------|-------------|--------|
| **Standard Dataverse** | Inventory flows write directly to Dataverse tables | **Recommended for all scenarios** | ✅ Supported |
| **BYODL (Bring Your Own Data Lake)** | Data exported to Azure Data Lake, Power BI reads from there | Legacy scenarios only | ⚠️ No longer recommended |
| **None** | No automatic data collection | ❌ **Will cause data issues** | Not valid |

#### Standard Dataverse (Recommended)

- ✅ No additional Azure resources required
- ✅ Real-time data updates
- ✅ Easier to set up and maintain
- ✅ Better performance
- ✅ Lower cost

**How it works:**
1. Inventory flows run on schedule (daily)
2. Flows query Power Platform APIs
3. Data written to Dataverse tables in CoE environment
4. Power BI connects to Dataverse tables
5. Dashboard displays data

#### BYODL (Not Recommended)

- ⚠️ Requires Azure Synapse Link
- ⚠️ Requires Azure Data Lake Storage Gen2
- ⚠️ Additional Azure costs
- ⚠️ Data export lag (hours)
- ⚠️ More complex setup

**Note**: BYODL was designed for scenarios where historical data retention exceeded Dataverse limits. With modern Dataverse capacity and data retention features, this is rarely necessary.

**If you're using BYODL, consider migrating to Standard Dataverse.**

---

### Q: What's the difference between "updating flows" and "running inventory"?

**A:** These are two completely different actions:

#### Updating Flows (Solution Upgrade)

- **What it does**: Imports new solution versions with code changes
- **When to do it**: When upgrading CoE Starter Kit (e.g., 1.60 → 1.70)
- **Effect**: Updates flow definitions, adds new features, fixes bugs
- **Does NOT**: Automatically trigger data collection

#### Running Inventory (Data Collection)

- **What it does**: Executes flows to collect data from Power Platform
- **When to do it**: After setup, upgrades, and on regular schedule
- **Effect**: Populates/updates Dataverse tables with current environment data
- **Result**: Fresh data visible in Power BI

**Both are required!** Updating the solution provides the tools (flows), but you must run inventory to collect data.

---

### Q: How often should I run full inventory vs. incremental inventory?

**A:** Understanding the difference is key:

#### Incremental Inventory (Default - Daily)

**Runs:** Automatically on schedule (daily)

**Syncs:**
- ✅ New objects (created in last 7 days)
- ✅ Modified objects (updated in last 7 days)
- ✅ Manually flagged objects (`admin_inventoryme = true`)

**Skips:**
- ❌ Objects older than 7 days (unless manually flagged)

**Benefits:**
- Fast execution (minutes to hours)
- Lower API consumption
- Suitable for ongoing monitoring

#### Full Inventory (Manual - On Demand)

**Runs:** Only when explicitly enabled (`admin_FullInventory = Yes`)

**Syncs:**
- ✅ **ALL** objects across **ALL** environments
- ✅ Regardless of age or modification date

**Benefits:**
- Complete historical data
- Catches anything missed by incremental
- Ensures data completeness

**Drawbacks:**
- Long execution time (6-48 hours)
- High API consumption
- Resource-intensive

#### When to Run Full Inventory

Run full inventory:
- ✅ After initial CoE Starter Kit installation (required!)
- ✅ After upgrading to new version
- ✅ When data appears incomplete or stale
- ✅ After major organizational changes (mergers, acquisitions)
- ✅ Quarterly for data validation

**Never** leave full inventory enabled permanently—it's resource-intensive and unnecessary.

---

### Q: I deployed the .pbit file with my org URL. Why is there still no data?

**A:** This is the most common misconception about the Power BI Dashboard.

#### What Deploying the .pbit Does

When you open the .pbit file and enter your org URL, you are:
- ✅ Creating a Power BI report definition
- ✅ Establishing a connection to Dataverse
- ✅ Defining queries to read from Dataverse tables

#### What Deploying the .pbit Does NOT Do

- ❌ Does **not** trigger data collection
- ❌ Does **not** run inventory flows
- ❌ Does **not** populate Dataverse tables
- ❌ Does **not** automatically refresh data

#### The Missing Step: Run Inventory!

After deploying the .pbit, you must:

1. **Enable and run inventory flows** to populate Dataverse
2. **Wait** for inventory to complete (hours to days)
3. **Verify** data exists in Dataverse tables
4. **Refresh** Power BI to pull the new data

Without step 1, Dataverse tables are empty, so Power BI has nothing to display.

📖 **See**: [Power BI Dashboard Stale Data Guide](../docs/troubleshooting/power-bi-dashboard-stale-data.md#solution-1-run-full-inventory-critical)

---

### Q: How can I verify that inventory flows are actually running?

**A:** Follow these steps to check inventory flow status:

#### Step 1: Verify Flows Are Enabled

1. Navigate to [Power Apps](https://make.powerapps.com/) → Your **CoE environment**
2. Go to **Solutions** → **Center of Excellence - Core Components** → **Cloud flows**
3. Check these flows are **On**:
   - **Admin | Sync Template v4**
   - **Admin | Sync Template v4 (Apps)**
   - **Admin | Sync Template v4 (Power Automate)**
   - **Admin | Sync Template v4 (Connectors)**
   - **Admin | Sync Template v4 (Custom Connectors)**
   - **Admin | Sync Template v4 (Model Driven Apps)**
   - **Admin | Sync Template v4 (Chatbots)**
   - **Admin | Sync Template v4 (PVA)**

4. If any are **Off**, click the flow name and select **Turn on**

#### Step 2: Check Run History

1. Open **Admin | Sync Template v4** (the main orchestrator flow)
2. Click **28-day run history**
3. Look for:
   - ✅ **Succeeded** - Good! Flow is running successfully
   - ⚠️ **Failed** - Investigate the error message
   - ⚠️ **Cancelled** - Flow was manually stopped or timed out
   - 🔵 **Running** - Currently executing (may take hours)

#### Step 3: Verify Last Run Date

- Check the **Start time** of the most recent run
- Should be recent (within 7 days for incremental mode)
- If last run was weeks/months ago:
  - Flow may be turned off
  - Flow schedule may be misconfigured
  - Service account license may have expired

#### Step 4: Check for Errors

If you see failed runs:

1. Click on the failed run
2. Expand the action that failed
3. Note the error message
4. Common errors:
   - **401 Unauthorized**: Service account permissions issue
   - **429 TooManyRequests**: API throttling (enable delay settings)
   - **403 Forbidden**: DLP policy blocking connector
   - **Connection not configured**: Missing or broken connection

📖 **For error resolution**, see: [Troubleshooting Guide](../docs/troubleshooting/power-bi-dashboard-stale-data.md#check-inventory-flow-status)

---

### Q: What Dataverse tables should have data if inventory is working?

**A:** Verify these key tables have recent data:

#### Core Tables to Check

1. Navigate to [Power Apps](https://make.powerapps.com/) → CoE environment
2. Go to **Tables** (or **Dataverse** → **Tables**)
3. Check these tables:

| Table Display Name | Table Name | What It Contains | Expected Row Count |
|-------------------|------------|-----------------|-------------------|
| **Environment** | `admin_environment` | All Power Platform environments | All environments in tenant |
| **PowerApps App** | `admin_app` | Canvas and model-driven apps | All apps across environments |
| **Flow** | `admin_flow` | Cloud flows | All flows across environments |
| **Flow Action Detail** | `admin_flowactiondetail` | Flow actions and triggers | Thousands to millions |
| **Connector** | `admin_connector` | Standard and custom connectors | All connectors used |
| **Maker** | `admin_maker` | App and flow makers | All users who created apps/flows |
| **Connection Reference** | `admin_connectionreference` | App/flow connections | All connection references |

#### How to Check a Table

1. Click on the table name (e.g., **Environment**)
2. Click **Edit** → **Edit in new tab** (or **Edit data**)
3. Look at the records:
   - **Created On**: When record was first added
   - **Modified On**: When record was last updated
   - **Modified On** should be recent (within 7 days) if incremental inventory is running

#### If Tables Are Empty or Stale

- ❌ Inventory is **not** running correctly
- Go back to [Q: How can I verify that inventory flows are actually running?](#q-how-can-i-verify-that-inventory-flows-are-actually-running)
- Run full inventory: [Q: Why is my Power BI Dashboard showing no data or stale data?](#q-why-is-my-power-bi-dashboard-showing-no-data-or-stale-data)

---

### Q: I'm using BYODL. Should I switch to Standard Dataverse?

**A: Yes, we recommend migrating to Standard Dataverse inventory** unless you have a specific reason to use BYODL.

#### Why BYODL Is No Longer Recommended

1. **Additional Complexity**
   - Requires Azure Synapse Link setup
   - Requires Azure Data Lake Storage Gen2
   - More configuration steps
   - More potential points of failure

2. **Additional Costs**
   - Azure Data Lake storage costs
   - Azure Synapse compute costs
   - Data egress charges

3. **Data Lag**
   - Export to Data Lake can lag by hours
   - Dashboard data is less current
   - Troubleshooting is harder

4. **Maintenance Overhead**
   - Must maintain Azure resources
   - Must monitor export status
   - Must troubleshoot export failures

#### Benefits of Migrating to Standard Dataverse

- ✅ No Azure resources required (lower cost)
- ✅ Real-time data (no export lag)
- ✅ Simpler architecture (easier to support)
- ✅ Fewer failure points (more reliable)
- ✅ Recommended by CoE Starter Kit team

#### Migration Path

**High-Level Steps:**

1. **Backup current configuration**
   - Document BYODL settings
   - Export Power BI reports

2. **Verify Dataverse capacity**
   - Ensure sufficient storage for inventory data
   - Check with Power Platform admin

3. **Disable BYODL export**
   - Turn off Azure Synapse Link
   - Stop data export

4. **Run full inventory to Dataverse**
   - Set `admin_FullInventory = Yes`
   - Wait for completion

5. **Deploy Standard Dataverse .pbit**
   - Use `Production_CoEDashboard_July2024.pbit`
   - Connect to Dataverse (not Data Lake)

6. **Verify data and retire BYODL**
   - Compare data completeness
   - Once verified, delete Azure resources

📖 **Need detailed migration steps?** Open a GitHub issue requesting migration guidance.

---

### Q: Can I reduce how much data the inventory collects?

**A:** Yes, there are several ways to control inventory scope:

#### Option 1: Exclude Specific Environments

Prevent inventory from scanning certain environments:

1. Go to **Tables** → **Environment** (`admin_environment`)
2. Find the environment to exclude
3. Set **Excuse from Inventory** (`admin_excusefrominventory`) = `Yes`
4. Save

**Use cases:**
- Test/dev environments you don't need to monitor
- Personal developer environments
- Sandboxes with no business apps

#### Option 2: Reduce Lookback Window

Change how far back incremental inventory looks:

1. Go to **Environment Variables**
2. Find **InventoryFilter_DaysToLookBack** (`admin_InventoryFilter_DaysToLookBack`)
3. Reduce from default `7` to `3` or `5`
4. Save

**Effect:**
- Only objects modified in last N days are re-synced
- Reduces API calls
- May miss some changes

#### Option 3: Selective Component Inventory

Turn off inventory for components you don't need:

1. Disable specific flows:
   - Don't need bot inventory? Turn off **Admin | Sync Template v4 (Chatbots)**
   - Don't need PVA? Turn off **Admin | Sync Template v4 (PVA)**

**Caution**: This may leave gaps in reporting. Only disable if you truly don't need that component.

#### Option 4: Implement Data Retention Policies

Archive or delete old inventory data:

1. Use **CLEANUP - Admin | Delete Orphaned Rows** flow (included in Core Components)
2. Set retention periods for historical data
3. Archive to external storage if needed for compliance

📖 **See**: [Data Retention and Maintenance](../DataRetentionAndMaintenance.md)

---

## Related Resources

- [Power BI Dashboard Stale Data Troubleshooting](../docs/troubleshooting/power-bi-dashboard-stale-data.md)
- [Issue Response Template: Power BI Dashboard Stale Data](../docs/ISSUE-RESPONSE-powerbi-dashboard-stale-data.md)
- [CoE Starter Kit Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Power BI Dashboard Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-powerbi)

---

## Still Have Questions?

### Community Support

- [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [CoE Starter Kit Office Hours](OfficeHours/OFFICEHOURS.md)

### Report an Issue

If you've encountered a bug or have a feature request:
- [Create a new issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
- Include diagnostic information (flow run history, error messages, versions)
- Specify what troubleshooting steps you've already tried

---

**Last Updated**: February 2026  
**Maintained by**: CoE Starter Kit Community
