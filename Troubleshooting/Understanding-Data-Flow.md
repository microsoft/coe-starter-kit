# Understanding the CoE Starter Kit Data Flow

## Overview

This document explains how data flows from your Power Platform resources into the Power BI dashboards. Understanding this flow is essential for troubleshooting when dashboards don't show expected data.

## Complete Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     YOUR POWER PLATFORM TENANT                               │
│                                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Environment  │  │ Environment  │  │ Environment  │  │ Environment  │  │
│  │    Dev       │  │    Test      │  │    Prod      │  │   Other      │  │
│  │              │  │              │  │              │  │              │  │
│  │ • Apps       │  │ • Apps       │  │ • Apps       │  │ • Apps       │  │
│  │ • Flows      │  │ • Flows      │  │ • Flows      │  │ • Flows      │  │
│  │ • Connectors │  │ • Connectors │  │ • Connectors │  │ • Connectors │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Scanned by
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COE INVENTORY FLOWS (in CoE Environment)                  │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  SETUP WIZARD | Admin | Sync Template v3 (Setup)                       │ │
│  │  • Runs ONCE during initial setup                                       │ │
│  │  • Configures environment variables                                     │ │
│  │  • Triggers first inventory collection                                  │ │
│  │  • Can take several hours for large tenants                            │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                    │                                         │
│                                    │ Triggers                                │
│                                    ↓                                         │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  Admin | Sync Template v3 (Parent Flow)                                │ │
│  │  • Runs on SCHEDULE (typically daily)                                   │ │
│  │  • Orchestrates all child flows                                         │ │
│  │  • Collects environment and high-level information                      │ │
│  │  • Must be turned ON manually after import                              │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│            │                           │                          │          │
│            │ Triggers                  │ Triggers                 │ Triggers │
│            ↓                           ↓                          ↓          │
│  ┌──────────────────┐    ┌──────────────────┐      ┌──────────────────┐   │
│  │ Admin | Sync     │    │ Admin | Sync     │      │ Admin | Sync     │   │
│  │ Apps v2          │    │ Flows v3         │      │ Other Resources  │   │
│  │                  │    │                  │      │                  │   │
│  │ • Collects all   │    │ • Collects all   │      │ • Connectors     │   │
│  │   canvas apps    │    │   cloud flows    │      │ • Custom         │   │
│  │ • Model-driven   │    │ • Desktop flows  │      │   Connectors     │   │
│  │   apps           │    │ • Flow details   │      │ • Chatbots       │   │
│  │ • App details    │    │ • Connections    │      │ • Etc.           │   │
│  └──────────────────┘    └──────────────────┘      └──────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Stores data in
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DATAVERSE TABLES (in CoE Environment)                     │
│                                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐         │
│  │ Power Apps App   │  │ Flow             │  │ Power Platform   │         │
│  │                  │  │                  │  │ User             │         │
│  │ • App Name       │  │ • Flow Name      │  │                  │         │
│  │ • Owner          │  │ • Owner          │  │ • User Name      │         │
│  │ • Environment    │  │ • Environment    │  │ • Email          │         │
│  │ • Created Date   │  │ • Created Date   │  │ • Department     │         │
│  │ • Modified Date  │  │ • Modified Date  │  │ • Country        │         │
│  │ • Etc.           │  │ • Etc.           │  │ • Etc.           │         │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘         │
│                                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐         │
│  │ Environment      │  │ Connector        │  │ Connection       │         │
│  │                  │  │                  │  │ Reference        │         │
│  │ • Env Name       │  │ • Connector Name │  │                  │         │
│  │ • Type           │  │ • Type           │  │ • Connector Name │         │
│  │ • Region         │  │ • Publisher      │  │ • Created By     │         │
│  │ • Etc.           │  │ • Etc.           │  │ • Etc.           │         │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Connected via
                                    │ Dataverse connector
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                          POWER BI DATASET                                    │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  CoE Dashboard Dataset                                                  │ │
│  │                                                                          │ │
│  │  • Connects to Dataverse tables via Dataverse connector                │ │
│  │  • Transforms and models the data                                       │ │
│  │  • Calculates measures and metrics                                      │ │
│  │  • Must be configured with correct environment URL                      │ │
│  │  • Requires REFRESH to get latest data                                  │ │
│  │                                                                          │ │
│  │  Refresh Methods:                                                        │ │
│  │  • Manual: Click "Refresh" in Power BI Desktop                          │ │
│  │  • Manual: Click "Refresh now" in Power BI Service                      │ │
│  │  • Scheduled: Configure automatic refresh in Power BI Service           │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Displays data in
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                        POWER BI DASHBOARDS & REPORTS                         │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  CoE Power BI Dashboard                                                 │ │
│  │                                                                          │ │
│  │  📊 Overview Dashboard        📱 App Usage Dashboard                    │ │
│  │  • Total Apps                 • Most Used Apps                          │ │
│  │  • Total Flows                • Active Users                            │ │
│  │  • Total Makers               • Launch Statistics                       │ │
│  │  • Environments               • Trends                                  │ │
│  │                                                                          │ │
│  │  🔄 Flow Dashboard            👥 Maker Dashboard                        │ │
│  │  • Flow Runs                  • Top Makers                              │ │
│  │  • Success/Failure Rates      • Maker Activity                          │ │
│  │  • Error Analysis             • Department Breakdown                    │ │
│  │                                                                          │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Timeline: From Setup to Data in Dashboards

```
Time: 0 hours (Initial Setup Complete)
│
│ ┌─────────────────────────────────────────────────────────────────┐
│ │ You complete CoE Starter Kit installation                       │
│ │ • Solutions imported                                             │
│ │ • Connections created                                            │
│ │ • Environment variables configured                               │
│ └─────────────────────────────────────────────────────────────────┘
│
Time: +0 to 30 minutes (Manual Configuration)
│
│ ┌─────────────────────────────────────────────────────────────────┐
│ │ You turn ON flows and run SETUP WIZARD                          │
│ │ • Turn ON all inventory flows                                   │
│ │ • Run "SETUP WIZARD | Admin | Sync Template v3 (Setup)"         │
│ │ • Flow begins scanning your tenant                              │
│ └─────────────────────────────────────────────────────────────────┘
│
Time: +30 minutes to 24 hours (Inventory Collection)
│
│ ┌─────────────────────────────────────────────────────────────────┐
│ │ Inventory flows collect data                                    │
│ │ • Scanning all environments                                     │
│ │ • Collecting apps, flows, connectors, etc.                      │
│ │ • Writing data to Dataverse tables                              │
│ │ • Time depends on tenant size                                   │
│ └─────────────────────────────────────────────────────────────────┘
│
Time: +24 hours (First Inventory Complete)
│
│ ┌─────────────────────────────────────────────────────────────────┐
│ │ Data now exists in Dataverse                                    │
│ │ • Tables populated with resource information                    │
│ │ • Can verify by checking tables directly                        │
│ │ • Ready for Power BI to consume                                 │
│ └─────────────────────────────────────────────────────────────────┘
│
Time: +24 hours + 5 minutes (Power BI Refresh)
│
│ ┌─────────────────────────────────────────────────────────────────┐
│ │ You refresh Power BI                                            │
│ │ • Power BI Desktop: Click Refresh button                        │
│ │ • Power BI Service: Dataset → Refresh now                       │
│ │ • Data loads from Dataverse into Power BI                       │
│ └─────────────────────────────────────────────────────────────────┘
│
Time: +24 hours + 10 minutes (SUCCESS!)
│
│ ┌─────────────────────────────────────────────────────────────────┐
│ │ Dashboards show your data! ✅                                    │
│ │ • Apps visible in App dashboard                                 │
│ │ • Flows visible in Flow dashboard                               │
│ │ • Makers visible in Maker dashboard                             │
│ │ • Environment metrics visible                                   │
│ └─────────────────────────────────────────────────────────────────┘
│
Time: Ongoing (Daily Updates)
│
│ ┌─────────────────────────────────────────────────────────────────┐
│ │ Inventory flows run on schedule                                 │
│ │ • Typically runs daily (overnight)                              │
│ │ • Collects new and updated resources                            │
│ │ • Updates Dataverse tables                                      │
│ │ • Power BI shows latest data after refresh                      │
│ └─────────────────────────────────────────────────────────────────┘
```

## What Happens at Each Step

### Step 1: Inventory Flows Scan Your Tenant

**What happens:**
- Flows use Power Platform admin APIs to discover all environments
- For each environment, collect information about apps, flows, connectors, etc.
- Extract metadata: names, owners, created dates, modified dates, etc.
- Handle pagination for large result sets
- Respect throttling limits

**Potential issues:**
- ❌ Flows not turned ON → No scanning happens
- ❌ Insufficient permissions → Can't access environments
- ❌ Connection errors → Flows fail
- ❌ Throttling → Flows take longer

### Step 2: Data Stored in Dataverse

**What happens:**
- For each discovered resource, create or update a record in Dataverse
- Establish relationships between records (e.g., App → Owner → Environment)
- Store all metadata in structured tables
- Maintain historical data for trending

**Potential issues:**
- ❌ Table permission errors → Data not saved
- ❌ Flow errors → Incomplete data
- ❌ Large tenant → Takes many hours

### Step 3: Power BI Connects to Dataverse

**What happens:**
- Power BI uses Dataverse connector to read table data
- Data is transformed and modeled in Power BI
- Relationships established between tables
- Measures and calculations performed
- Visuals display the data

**Potential issues:**
- ❌ Wrong environment URL → Connects to wrong data source
- ❌ Not refreshed → Shows old/empty data
- ❌ Authentication errors → Can't read data
- ❌ Gateway issues (for scheduled refresh) → Refresh fails

## Key Points to Remember

### 🔄 It's a Pipeline, Not Real-Time
Data doesn't flow instantly. There are distinct steps, each taking time.

### ⏰ Schedule Matters
Inventory flows run on a schedule (typically daily). New resources won't appear until the next scheduled run.

### 🔍 Verify Each Step
When troubleshooting, check each step:
1. ✅ Did flows run?
2. ✅ Is data in Dataverse?
3. ✅ Is Power BI refreshed?

### 📊 Power BI Shows Historical Data
What you see in Power BI is a snapshot from the last time:
1. Inventory flows ran (collecting data)
2. AND Power BI was refreshed (loading data)

### 🚀 First Run Takes Longest
Initial inventory collection takes the most time because:
- Discovering all environments
- Collecting all historical data
- Establishing baselines
- Populating empty tables

Subsequent runs are incremental and faster.

## Troubleshooting Using This Flow Diagram

When dashboards show no data, ask:

1. **Did inventory flows run successfully?**
   - Check: Flow run history
   - Look for: Successful completion status
   - If No: Turn ON flows and run them

2. **Is data in Dataverse?**
   - Check: Dataverse tables directly
   - Look for: Recent records
   - If No: Review flow errors, check permissions

3. **Is Power BI connected to correct environment?**
   - Check: Power BI data source settings
   - Look for: Correct environment URL
   - If No: Update connection settings

4. **Has Power BI been refreshed?**
   - Check: Last refresh timestamp
   - Look for: Refresh after flows completed
   - If No: Refresh manually

## Related Resources

- **[Complete Troubleshooting Guide](PowerBI-Dashboard-No-Data.md)** - Detailed steps for each issue
- **[Quick Reference](Quick-Reference-Dashboard-No-Data.md)** - Fast troubleshooting checklist
- **[Issue Response](ISSUE-RESPONSE-Dashboard-No-Data.md)** - Template for responding to users

---

*Understanding this data flow is essential for successfully operating the CoE Starter Kit. Save this diagram for reference when troubleshooting!*
