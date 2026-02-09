# Troubleshooting: Power BI Dashboard Showing Stale or No Data

## Issue Description

The Power BI Dashboard for CoE View displays outdated data (e.g., data stuck in September) or shows no data at all, even after updating flow collectors and deploying the .pbit template with the correct organization URL.

## Quick Diagnosis

Before diving into detailed troubleshooting, answer these questions to quickly identify your issue:

**Q1: What inventory method are you using?**
- **None / Not sure**: 🚨 **This is the problem!** → Go to [Root Cause: No Inventory Method Selected](#root-cause-no-inventory-method-selected)
- **Standard Dataverse inventory**: Continue to Q2
- **BYODL (Bring Your Own Data Lake)**: See [BYODL-Specific Issues](#byodl-specific-issues)

**Q2: Have you run a full inventory since initial setup?**
- **No / Not sure**: Go to [Solution 1: Run Full Inventory](#solution-1-run-full-inventory-critical)
- **Yes, but data is still stale**: Continue to Q3

**Q3: Are the inventory flows running successfully?**
- **No / Seeing errors**: Go to [Check Inventory Flow Status](#check-inventory-flow-status)
- **Yes, all running successfully**: Continue to Q4

**Q4: When was the last time the inventory flows ran?**
- **More than 7 days ago**: Go to [Verify Flow Schedules](#verify-flow-schedules)
- **Within the last 7 days**: Continue to [Advanced Troubleshooting](#advanced-troubleshooting)

## Root Cause: No Inventory Method Selected

If you answered **"None"** when asked about your inventory/telemetry method, this is the primary cause of your issue.

### What This Means

The CoE Starter Kit **requires** an active inventory collection method to populate data in Dataverse tables. The Power BI dashboard reads from these Dataverse tables. If no inventory method is active:

- ❌ No data flows into Dataverse tables
- ❌ Power BI dashboard has nothing to display
- ❌ Dashboard shows stale data from the last time inventory ran (e.g., September)

### How Inventory Works

```
Power Platform Environments
         ↓
Inventory Flows (Collectors)
         ↓
Dataverse Tables (admin_app, admin_flow, etc.)
         ↓
Power BI Dashboard (.pbit connects to Dataverse)
```

**The inventory flows are the bridge between your Power Platform environments and the dashboard.**

## Solution 1: Run Full Inventory (Critical)

After installing or upgrading the CoE Starter Kit, you **must** run a full inventory to populate all historical data.

### Steps to Enable Full Inventory

1. Navigate to [Power Apps](https://make.powerapps.com/) and select your **CoE environment**
2. Go to **Solutions** → **Center of Excellence - Core Components**
3. Select **Environment Variables** from the left navigation
4. Find: **FullInventory** (`admin_FullInventory`)
5. Click **Edit** and set **Current Value** = `Yes`
6. Click **Save**
7. Wait 6-24 hours for the full inventory to complete (time varies based on tenant size)
8. ⚠️ **IMPORTANT**: After completion, set **FullInventory** back to `No`

### What Full Inventory Does

- Scans **ALL** Power Platform environments in your tenant
- Inventories **ALL** apps, flows, connectors, etc. regardless of modification date
- Populates Dataverse tables with historical data
- Runs only when explicitly enabled (does not run on schedule)

### Expected Timeline

| Tenant Size | Expected Duration |
|-------------|------------------|
| Small (< 10 environments) | 1-2 hours |
| Medium (10-50 environments) | 4-8 hours |
| Large (50-200 environments) | 12-24 hours |
| Very Large (200+ environments) | 24-48 hours |

## Solution 2: Verify Inventory Flows Are Running

The inventory flows must run regularly to keep data fresh.

### Check Flow Status

1. Navigate to [Power Apps](https://make.powerapps.com/) and select your **CoE environment**
2. Go to **Solutions** → **Center of Excellence - Core Components** → **Cloud flows**
3. Check the following critical flows:

| Flow Name | Expected Status | Expected Run Frequency |
|-----------|----------------|----------------------|
| **Admin \| Sync Template v4** | On | Daily |
| **Admin \| Sync Template v4 (Apps)** | On | Triggered by Sync Template v4 |
| **Admin \| Sync Template v4 (Power Automate)** | On | Triggered by Sync Template v4 |
| **Admin \| Sync Template v4 (Connectors)** | On | Triggered by Sync Template v4 |
| **Admin \| Sync Template v4 (Custom Connectors)** | On | Triggered by Sync Template v4 |
| **Admin \| Sync Template v4 (Model Driven Apps)** | On | Triggered by Sync Template v4 |
| **Admin \| Sync Template v4 (Chatbots)** | On | Triggered by Sync Template v4 |
| **Admin \| Sync Template v4 (PVA)** | On | Triggered by environment updates |

### Enable Flows If They Are Off

If any flows are turned **Off**:

1. Click on the flow name
2. Click **Turn on** in the command bar
3. Monitor the flow run history to ensure successful execution

### Review Flow Run History

1. Open each flow
2. Click **28 day run history**
3. Look for:
   - ✅ **Succeeded** status - Good
   - ⚠️ **Failed** or **Cancelled** - Investigate errors
   - 🔵 **Running** - Wait for completion

## Solution 3: Verify Power BI Connection to Correct Environment

Even with good inventory data, the Power BI dashboard must connect to the correct Dataverse environment.

### Verify Connection String

1. Open the .pbit file in **Power BI Desktop**
2. When prompted, enter your **Organization URL**
   - Format: `https://[your-org].crm.dynamics.com/`
   - **NOT** `https://[your-org].crm.dynamics.com` (missing trailing slash can cause issues)
   - **NOT** `https://org[guid].crm.dynamics.com` (environment URL - use organization URL instead)

3. Click **Load**
4. Sign in with your **organizational account** (must have read access to CoE environment)

### Common Connection Mistakes

| ❌ Wrong | ✅ Correct |
|---------|-----------|
| `orgf8c3a2b1.crm.dynamics.com` | `contoso.crm.dynamics.com` |
| `make.powerapps.com` | `contoso.crm.dynamics.com` |
| Missing trailing `/` | `contoso.crm.dynamics.com/` |

### How to Find Your Organization URL

**Method 1: Power Platform Admin Center**
1. Go to [admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
2. Select **Environments** → Select your CoE environment
3. Copy the **Environment URL**
4. Extract the organization portion: `https://[org].crm.dynamics.com/`

**Method 2: Power Apps**
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Select your CoE environment
3. Look at the URL bar: `https://make.powerapps.com/environments/[guid]/home?utm_source...`
4. Click **Settings** (gear icon) → **Session details**
5. Copy **Instance url** and use it in Power BI

## Solution 4: Refresh Data in Power BI

After verifying inventory is running, you must refresh the Power BI data.

### Refresh in Power BI Desktop

1. Open your CoE Dashboard report in Power BI Desktop
2. Click **Home** → **Refresh**
3. Wait for the refresh to complete (may take 5-15 minutes)
4. Check if data is now current

### Refresh in Power BI Service

1. Publish the report to Power BI Service
2. Go to the workspace containing the report
3. Find the **dataset** (not the report)
4. Click **... (More options)** → **Refresh now**
5. Configure **Scheduled refresh** for daily updates:
   - Click **... (More options)** → **Settings**
   - Expand **Scheduled refresh**
   - Set refresh frequency to **Daily**

## Solution 5: Verify Data in Dataverse Tables

Before troubleshooting Power BI, confirm data exists in Dataverse.

### Check Key Tables

1. Navigate to [Power Apps](https://make.powerapps.com/) and select your **CoE environment**
2. Go to **Tables** and search for these key tables:

| Table Display Name | Table Name | What to Check |
|-------------------|------------|--------------|
| **Environment** | `admin_environment` | Should have all your environments |
| **PowerApps App** | `admin_app` | Should have all canvas and model-driven apps |
| **Flow** | `admin_flow` | Should have all cloud flows |
| **Flow Action Detail** | `admin_flowactiondetail` | Should have flow action metadata |
| **Connector** | `admin_connector` | Should have all connectors used |
| **Maker** | `admin_maker` | Should have all app/flow makers |

3. Click on each table → **Edit** → **Edit in new tab**
4. Check **Modified On** dates - should be recent (within 7 days)
5. Check **Created On** dates - should span your organization's history

### If Tables Are Empty or Stale

- Return to [Solution 1: Run Full Inventory](#solution-1-run-full-inventory-critical)
- Verify flows are enabled (Solution 2)

## Verify Flow Schedules

Inventory flows should run automatically on a schedule.

### Check Schedule for Main Sync Flow

1. Navigate to [Power Apps](https://make.powerapps.com/) → CoE environment
2. Go to **Solutions** → **Center of Excellence - Core Components** → **Cloud flows**
3. Open **Admin | Sync Template v4**
4. Check for triggers:
   - **Recurrence** trigger should be set to run **Daily**
   - Default time: Early morning (e.g., 1:00 AM)

### Manually Trigger a Flow

If you don't want to wait for the schedule:

1. Open the flow
2. Click **Run** in the command bar
3. Click **Run flow**
4. Monitor the run history

## BYODL-Specific Issues

If you're using **Bring Your Own Data Lake (BYODL)** for inventory:

⚠️ **Important Note**: BYODL is **no longer recommended** by the CoE Starter Kit team. The recommended approach is standard Dataverse inventory.

### BYODL Requirements

- Must use **BYODL_CoEDashboard_July2024.pbit** (not Production_CoEDashboard)
- Must have Azure Synapse Link configured
- Must have data export enabled
- Tables must be exported to the Data Lake

### Common BYODL Issues

1. **Data Lake export not configured**
   - Go to Power Platform Admin Center → Environment → Settings → Azure Synapse Link
   - Verify tables are selected for export

2. **Using wrong .pbit file**
   - Production environments: Use `Production_CoEDashboard_July2024.pbit`
   - BYODL environments: Use `BYODL_CoEDashboard_July2024.pbit`

3. **Export lag**
   - Data Lake exports can lag behind Dataverse by several hours
   - Check Azure Synapse Link status for last export time

## Advanced Troubleshooting

### Check Environment Variables

Critical environment variables that affect inventory:

1. Navigate to **Solutions** → **Center of Excellence - Core Components** → **Environment Variables**
2. Verify these settings:

| Variable Name | Expected Value | Purpose |
|--------------|----------------|---------|
| `admin_FullInventory` | `No` (after initial run) | Controls full vs. incremental inventory |
| `admin_InventoryFilter_DaysToLookBack` | `7` (default) | Days to look back for modified objects |
| `admin_SyncFlowErrors` | `Yes` | Enables error logging |
| `Power Platform Admin` | Service account email | Service account running flows |

### Check Service Account License

The service account running inventory flows must have:

- ✅ **Power Apps Per User** or **Premium** license
- ✅ **System Administrator** role in the CoE environment
- ✅ **Power Platform Administrator** or **Global Administrator** tenant role (for cross-environment access)

### Check for API Throttling

Large tenants may experience API throttling:

1. Review flow run history for **429 TooManyRequests** errors
2. If throttling occurs:
   - Enable **DelayObjectInventory** environment variable (adds delays between API calls)
   - Run inventory during off-peak hours
   - Consider splitting large environments

### Verify English Language Pack

The CoE Starter Kit requires the **English (1033) language pack**:

1. Go to Power Platform Admin Center
2. Select your CoE environment
3. Navigate to **Settings** → **Product** → **Languages**
4. Ensure **English** is installed and available

## Prevention and Best Practices

### After Initial Setup

1. ✅ **Run full inventory** (set `admin_FullInventory = Yes`)
2. ✅ **Wait for completion** (6-24 hours)
3. ✅ **Set full inventory back to No**
4. ✅ **Verify data** in Dataverse tables
5. ✅ **Connect Power BI** with correct URL
6. ✅ **Publish to Power BI Service** and configure scheduled refresh

### Ongoing Maintenance

1. ✅ **Monitor flow runs** weekly
2. ✅ **Check for flow errors** in Power Automate
3. ✅ **Refresh Power BI daily** (automatic with scheduled refresh)
4. ✅ **Run full inventory** quarterly or after major changes
5. ✅ **Keep solutions updated** to latest version

### When to Run Full Inventory

Run full inventory:
- ✅ After initial installation
- ✅ After upgrading CoE Starter Kit
- ✅ When data appears incomplete or stale
- ✅ After major organizational changes (mergers, acquisitions)
- ✅ Quarterly for data validation

## Common Error Messages

### "Unable to connect to the data source"

**Cause**: Power BI cannot connect to Dataverse

**Solution**:
- Verify organization URL is correct
- Check network/firewall allows connections to `*.dynamics.com`
- Re-authenticate in Power BI Desktop (File → Options → Data source settings)

### "The query returned no results"

**Cause**: Dataverse tables are empty

**Solution**:
- Run full inventory (Solution 1)
- Verify flows are enabled and running (Solution 2)

### "Authentication failed"

**Cause**: User lacks permissions

**Solution**:
- Ensure you have read access to the CoE environment
- Sign in with the correct organizational account
- Verify you're not using a personal Microsoft account

## Understanding Incremental vs. Full Inventory

### Incremental Inventory (Default Mode)

**When it runs**: Daily (scheduled)

**What it syncs**:
- ✅ New objects (apps, flows) created in the last 7 days
- ✅ Modified objects (updated in the last 7 days)
- ✅ Manually flagged objects (`admin_inventoryme = true`)

**What it skips**:
- ❌ Objects older than 7 days (unless manually flagged)

**Benefits**:
- Fast execution
- Lower API consumption
- Suitable for daily updates

### Full Inventory

**When it runs**: Only when explicitly enabled

**What it syncs**:
- ✅ **ALL** objects across **ALL** environments
- ✅ Regardless of age or modification date

**Benefits**:
- Complete historical data
- Catches anything missed by incremental
- Ensures data completeness

**Drawbacks**:
- Long execution time (hours to days)
- High API consumption
- Should not run frequently

## Related Resources

- [CoE Starter Kit Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Power BI Dashboard Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-powerbi)
- [Understanding CoE Inventory](https://learn.microsoft.com/power-platform/guidance/coe/core-components#inventory)
- [Service Protection Limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)

## Still Having Issues?

If you've tried all the above steps and still experiencing issues:

### 1. Gather Diagnostic Information

Collect the following before reporting:
- CoE Starter Kit version (e.g., 1.70)
- Inventory method (Standard Dataverse / BYODL / None)
- Flow run history screenshots (last 7 days)
- Dataverse table row counts (admin_app, admin_flow, admin_environment)
- Power BI error messages (screenshots)
- Environment variables configuration

### 2. Search Existing Issues

- [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)
- Search for similar problems and solutions

### 3. Report a New Issue

- Use the [bug report template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
- Include all diagnostic information from step 1
- Specify what troubleshooting steps you've already tried

### 4. Community Support

- [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- [CoE Starter Kit Office Hours](../../CenterofExcellenceResources/OfficeHours/OFFICEHOURS.md)

## Disclaimer

The CoE Starter Kit is a **community-driven project** and is **not officially supported** by Microsoft Support. However, the underlying platform features (Power BI, Dataverse, Power Platform) are fully supported through standard Microsoft support channels.

For issues with:
- **The CoE Starter Kit itself**: Use GitHub issues and community support
- **Power Platform features**: Contact Microsoft Support through your standard channel
