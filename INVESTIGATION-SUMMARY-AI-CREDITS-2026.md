# Investigation Summary: AI Credits Usage Data Not Showing After December 2025

**Date**: February 16, 2025  
**Issue**: User reports AI Credits usage data only shows up to December 2025, with no data in 2026  
**Status**: ✅ Investigation Complete  
**Conclusion**: No CoE Starter Kit code issues found - Issue is external

---

## Key Finding

**✅ The CoE Starter Kit code is NOT the problem.**

After comprehensive analysis of the AI Credits collection mechanism:
- ✅ No hardcoded date limitations (2025, 2026, December, etc.)
- ✅ All date operations use dynamic functions
- ✅ No year-specific filters or validation rules
- ✅ Code will work indefinitely with any date

---

## What Was Analyzed

### 1. **Flow: Admin | Sync Template v4 (AI Usage)**
- **File**: `AdminSyncTemplatev4AIUsage-9BBE33D2-BCE6-EE11-904D-000D3A341FFF.json`
- **Finding**: Uses dynamic date functions only (`formatDateTime`, `startOfDay`, `addDays`)
- **Filter**: `LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1)` - relative, not absolute
- **Result**: ✅ No date limitations

### 2. **Entity: admin_AICreditsUsage**
- **File**: `admin_AICreditsUsage/Entity.xml`
- **Field**: `admin_processingdate` (Standard Dataverse Date type)
- **Result**: ✅ No min/max date constraints

### 3. **Source Table: msdyn_aievents**
- **Type**: Microsoft system table (not part of CoE Starter Kit)
- **Owner**: Microsoft platform (auto-populated)
- **Result**: ⚠️ If this table isn't populated, CoE can't collect data

### 4. **Power BI Reports**
- **Files**: `Production_CoEDashboard_July2024.pbit` and variants
- **Result**: ✅ Connect to admin_AICreditsUsage directly, no date filters in CoE code

### 5. **Git History & Issues**
- **Result**: ✅ No related issues, no recent changes to AI Credits logic

---

## Root Cause: External to CoE Starter Kit

The issue is most likely one of these:

### 🔴 **HIGH LIKELIHOOD**: Microsoft Platform Issue
- The `msdyn_aievents` table may not be populating data in 2026
- This is a Microsoft-managed table, not controlled by CoE Starter Kit
- User should verify source data exists and contact Microsoft Support if missing

### 🟡 **MEDIUM LIKELIHOOD**: Flow Not Running
- The sync flow may have stopped or be failing
- Connections may have expired
- User should check 28-day run history

### 🟢 **LOW LIKELIHOOD**: No AI Builder Usage
- AI models may not be running in 2026
- If no usage, no data is generated

---

## Documentation Created

| Document | Purpose | Size |
|----------|---------|------|
| **ANALYSIS-AI-CREDITS-2026-ISSUE.md** | Comprehensive technical analysis | 210 lines |
| **ISSUE-RESPONSE-AI-CREDITS-2026.md** | User-facing troubleshooting guide | 182 lines |
| **QUICKREF-AI-CREDITS-COLLECTION.md** | Quick reference for AI Credits collection | 247 lines |

---

## How AI Credits Collection Works

```
┌─────────────────────────────────────────────────────────┐
│ 1. Microsoft AI Builder runs models                     │
│    → Writes to msdyn_aievents table (per environment)  │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│ 2. CoE Flow: Admin | Sync Template v4 (AI Usage)       │
│    → Queries msdyn_aievents using LastXDays(1)         │
│    → Runs daily per environment                        │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│ 3. CoE Storage: admin_AICreditsUsage table             │
│    → Aggregates by user/date/environment               │
│    → Stored in CoE environment                         │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│ 4. Power BI Reports                                     │
│    → Connects to admin_AICreditsUsage                  │
│    → Displays trends and consumption                   │
└─────────────────────────────────────────────────────────┘
```

---

## Critical Code Snippets (No Date Limitations)

### OData Query Filter:
```javascript
"$filter": "msdyn_creditconsumed gt 0 and (Microsoft.Dynamics.CRM.LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1))"
```
- ✅ `LastXDays(1)` is relative (yesterday)
- ✅ No hardcoded dates

### Date Formatting:
```javascript
"item/admin_processingdate": "@formatDateTime(items('Apply_to_each'),'yyyy-MM-dd')"
```
- ✅ Dynamic formatting
- ✅ No year validation

### Date Comparisons:
```javascript
"where": "@greaterOrEquals(item()?['ProcessingDate'], startOfDay(items('Apply_to_each')))"
"where": "@less(item()?['ProcessingDate'], addDays(formatDateTime(items('Apply_to_each'), 'yyyy-MM-dd'), 1))"
```
- ✅ Relative date operations
- ✅ No absolute date limits

---

## Diagnostic Steps for User

### ⭐ Priority 1: Check Flow Status
1. Navigate to CoE environment
2. Open flow: **Admin | Sync Template v4 (AI Usage)**
3. Check if it's **turned ON**
4. Review **28-day run history**:
   - Are there runs in January 2026?
   - Any errors or warnings?
   - Output of "List AI Events" action - how many records?

### ⭐ Priority 2: Verify Source Data
1. Go to an environment with AI Builder usage
2. Query the **msdyn_aievents** table:
   - Filter: `msdyn_processingdate >= 2026-01-01`
   - If NO records → **Microsoft platform issue**
   - If records exist → **Flow issue**

### ⭐ Priority 3: Check CoE Data
1. In CoE environment, query **admin_AICreditsUsage**
2. Sort by `admin_processingdate` descending
3. What's the last date? Is it stuck at Dec 31, 2025?

### ⭐ Priority 4: Confirm AI Activity
1. Verify AI Builder models are actively running in 2026
2. Check if models are consuming credits (not idle)
3. Verify proper licenses are assigned

---

## Response to User

### Immediate:
1. ✅ Provide **ISSUE-RESPONSE-AI-CREDITS-2026.md**
2. ✅ Request information from diagnostic steps above
3. ✅ Ask for screenshots of flow run history

### If Platform Issue Confirmed:
- User should contact **Microsoft Support**
- Reference the `msdyn_aievents` table not populating
- CoE Starter Kit cannot fix this (it's a Microsoft-managed table)

### If Flow Issue:
- Standard troubleshooting: connections, permissions, DLP policies
- Verify System Administrator privileges
- Check if flow is triggered for all environments

---

## For CoE Maintainers

### No Code Changes Required
- ✅ Code is correct and will work with any date
- ✅ No bugs found
- ✅ No hardcoded limitations

### If Pattern Emerges:
1. Add to **TROUBLESHOOTING.md**
2. Create FAQ entry
3. Consider enhanced error logging in flow
4. Engage with Microsoft product team

### Monitoring:
- Watch for additional reports of same issue
- Check Microsoft service advisories
- Review AI Builder release notes for breaking changes

---

## Conclusion

**Bottom Line**: The CoE Starter Kit AI Credits collection mechanism is functioning correctly and has no date limitations. The issue preventing 2026 data from appearing is external to the CoE Starter Kit, most likely:

1. ⚠️ Microsoft's `msdyn_aievents` table not populating (platform issue)
2. ⚠️ Flow not running or encountering errors (configuration issue)
3. ⚠️ No AI Builder activity generating data (usage issue)

**Action Required**: User needs to diagnose which of these is the actual cause using the diagnostic steps provided.

---

## Files & Locations

### Analysis Documents:
- `ANALYSIS-AI-CREDITS-2026-ISSUE.md` - Full technical analysis
- `ISSUE-RESPONSE-AI-CREDITS-2026.md` - User troubleshooting guide
- `QUICKREF-AI-CREDITS-COLLECTION.md` - Quick reference
- `INVESTIGATION-SUMMARY-AI-CREDITS-2026.md` - This summary

### Source Code:
- **Flow**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminSyncTemplatev4AIUsage-*.json`
- **Entity**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_AICreditsUsage/Entity.xml`
- **Power BI**: `CenterofExcellenceResources/Release/Collateral/CoEStarterKit/*.pbit`

---

## References

- **CoE Starter Kit Docs**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **AI Builder Credits**: https://learn.microsoft.com/ai-builder/credit-management
- **Dataverse API**: https://learn.microsoft.com/power-apps/developer/data-platform/webapi/overview

---

**Investigation Status**: ✅ **COMPLETE**  
**Code Status**: ✅ **NO ISSUES FOUND**  
**Next Action**: **User Diagnostics Required**

