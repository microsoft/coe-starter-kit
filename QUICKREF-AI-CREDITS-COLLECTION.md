# Quick Reference: AI Credits Collection in CoE Starter Kit

## Overview
This document provides a quick reference for understanding how AI Credits data flows through the CoE Starter Kit.

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ Step 1: Microsoft AI Builder Records Credit Usage               │
│ Source: msdyn_aievents table (in each environment)              │
│ - Created automatically by Microsoft when AI models run         │
│ - Fields: msdyn_creditconsumed, msdyn_processingdate           │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│ Step 2: CoE Flow Collects Data Daily                           │
│ Flow: "Admin | Sync Template v4 (AI Usage)"                    │
│ - Runs daily (manually or scheduled)                           │
│ - Queries: LastXDays(PropertyName='msdyn_processingdate',      │
│            PropertyValue=1)                                     │
│ - Retrieves yesterday's AI credit consumption                  │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│ Step 3: Data Aggregated and Stored                             │
│ Table: admin_AICreditsUsage (in CoE environment)               │
│ - Aggregates credits per user per day per environment          │
│ - Fields: admin_creditsconsumption, admin_processingdate       │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│ Step 4: Power BI Reports Display Data                          │
│ Reports: Production_CoEDashboard_July2024.pbit                 │
│ - Connects to admin_AICreditsUsage table                       │
│ - Shows trends, consumption by user, by environment            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Key Components

### 1. Source Table: `msdyn_aievents`
- **Type**: Microsoft system table (Dataverse)
- **Location**: Each environment where AI Builder is used
- **Owner**: Microsoft (populated automatically)
- **Access**: Requires System Administrator privileges
- **Key Fields**:
  - `msdyn_aieventid` - Unique identifier
  - `msdyn_creditconsumed` - Number of credits used
  - `msdyn_processingdate` - Date when credits were consumed
  - `createdby` - User who triggered the AI model

### 2. Collection Flow: `Admin | Sync Template v4 (AI Usage)`
- **File**: `AdminSyncTemplatev4AIUsage-9BBE33D2-BCE6-EE11-904D-000D3A341FFF.json`
- **Type**: Cloud Flow (Power Automate)
- **Trigger**: Manual or scheduled (daily recommended)
- **Scope**: Runs per environment (not tenant-wide)
- **Permissions**: Requires System Admin in target environment
- **Introduced**: Version 4.24.5

**Flow Actions**:
1. List AI Events from Environment (queries `msdyn_aievents`)
2. Parse and group events by date and user
3. Calculate total credits per user per day
4. Upsert records to `admin_AICreditsUsage`

**Important Settings**:
- **Pagination**: 100,000 items minimum
- **Concurrency**: 50 parallel iterations
- **Filter**: `LastXDays(1)` - Only collects yesterday's data

### 3. Storage Table: `admin_AICreditsUsage`
- **Type**: Custom Dataverse table
- **Location**: CoE environment
- **Owner**: CoE Starter Kit
- **Purpose**: Centralized storage of AI credit usage across all environments

**Key Fields**:
| Field | Type | Description |
|-------|------|-------------|
| `admin_aicreditsusageid` | GUID | Primary key |
| `admin_creditsconsumption` | Integer | Total credits consumed |
| `admin_processingdate` | Date | Date of consumption |
| `admin_creditsuser` | Lookup | User (admin_PowerPlatformUser) |
| `admin_Environment` | Lookup | Environment (admin_Environment) |
| `admin_name` | String | Composite key: `-UserID-EnvID-Date` |

### 4. Power BI Reports
**Files**:
- `Production_CoEDashboard_July2024.pbit`
- `BYODL_CoEDashboard_July2024.pbit`
- `PowerPlatformGovernance_CoEDashboard_July2024.pbit`

**Data Source**: Connects directly to `admin_AICreditsUsage` table via Dataverse connector

---

## Date Handling (No Hardcoded Limitations)

### In the Flow:
```javascript
// All date operations are dynamic
"$filter": "Microsoft.Dynamics.CRM.LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1)"

"item/admin_processingdate": "@formatDateTime(items('Apply_to_each'),'yyyy-MM-dd')"

"where": "@greaterOrEquals(item()?['ProcessingDate'], startOfDay(items('Apply_to_each')))"
```

### In the Entity:
- `admin_processingdate` is a standard Dataverse **Date** field (not DateTime)
- Format: `date` (Behavior: 1 = User Local)
- No minimum or maximum date restrictions

**Conclusion**: The flow will work indefinitely - there are no year-specific limitations.

---

## Troubleshooting Checklist

### ❌ AI Credits data stops at a certain date

**Check**:
1. ✅ Is the flow turned ON?
2. ✅ Flow run history - any errors?
3. ✅ Does `msdyn_aievents` have recent data in source environments?
4. ✅ Are AI Builder models actively running?
5. ✅ Does the flow connection have System Admin privileges?
6. ✅ Is the flow triggered for all environments?

**Common Issues**:
- Flow not running (turned off or failed)
- No AI Builder activity (models not running)
- Permission issues (connection doesn't have System Admin)
- Platform issue (Microsoft's `msdyn_aievents` not populating)

### ❌ Flow fails with "Table Inaccessible"

**Cause**: The flow doesn't have access to `msdyn_aievents` in the target environment

**Solution**:
- Verify System Administrator privileges
- Check DLP policies aren't blocking Dataverse connector
- Ensure environment is not a Teams environment (different permissions)

### ❌ Data appears but is incomplete

**Check**:
1. Filter in Power BI - any date range limitations?
2. Row limits in Power BI data source settings
3. Flow pagination settings (should be 100,000 minimum)

---

## Setup Requirements

### To Enable AI Credits Collection:

1. **Turn on the flow**: Admin | Sync Template v4 (AI Usage)
2. **Configure connections**: Use an account with System Admin in all environments
3. **Set schedule**: Recommended to run daily
4. **Monitor first run**: Check for errors in environments

### Environments Covered:
- The flow must be triggered **per environment**
- Typically called by the "Admin | Sync Template v4" driver flow
- Each environment is processed independently

### License Requirements:
- **Flow owner**: Power Automate Premium or higher
- **API calls**: Requires sufficient API limits for Dataverse queries
- **AI Builder**: Requires AI Builder license/credits in use

---

## API Query Details

### Query to `msdyn_aievents`:
```odata
GET {environment-url}/api/data/v9.2/msdyn_aievents?
  $select=msdyn_creditconsumed,msdyn_processingdate,msdyn_aieventid
  &$filter=msdyn_creditconsumed gt 0 and (Microsoft.Dynamics.CRM.LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1))
  &$expand=createdby($select=azureactivedirectoryobjectid)
```

**Explanation**:
- `msdyn_creditconsumed gt 0` - Only events that consumed credits
- `LastXDays(...,PropertyValue=1)` - Yesterday's data only
- `createdby` expansion - Get user's Azure AD Object ID

**Why Only 1 Day?**
- Reduces API load
- Prevents duplicate processing
- Daily incremental sync pattern
- If flow runs daily, all data is captured

---

## File Locations

```
coe-starter-kit/
├── CenterofExcellenceCoreComponents/
│   └── SolutionPackage/src/
│       ├── Entities/
│       │   └── admin_AICreditsUsage/
│       │       ├── Entity.xml          ← Table definition
│       │       └── SavedQueries/        ← Views
│       └── Workflows/
│           ├── AdminSyncTemplatev4AIUsage-*.json  ← Collection flow
│           └── AdminSyncTemplatev4AIUsage-*.json.data.xml
│
└── CenterofExcellenceResources/
    └── Release/Collateral/CoEStarterKit/
        ├── Production_CoEDashboard_July2024.pbit  ← Main Power BI report
        ├── BYODL_CoEDashboard_July2024.pbit
        └── PowerPlatformGovernance_CoEDashboard_July2024.pbit
```

---

## Related Documentation

- **Microsoft Learn - CoE Starter Kit**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **AI Builder Credits**: https://learn.microsoft.com/ai-builder/credit-management
- **Dataverse API**: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/overview
- **LastXDays Function**: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/query-data-web-api#date-functions

---

## Version History

| Version | Change |
|---------|--------|
| 4.24.5  | AI Credits Usage flow introduced |
| 4.29.2  | Updated `admin_creditsuser` field (replaces deprecated `admin_creditsusedby`) |

---

*This document is a quick reference guide. For the full analysis of the 2026 date issue, see `ANALYSIS-AI-CREDITS-2026-ISSUE.md`*
