# GitHub Issue Response: AI Credits Data Not Showing After December 2025

---

## 👋 Hi @[username],

Thank you for reporting this issue about AI Credits usage data not displaying beyond December 2025 in your CoE Power BI reports.

## 🔍 Investigation Results

I've conducted a comprehensive analysis of the CoE Starter Kit codebase, and here's what I found:

### ✅ Good News: No Code Issues

**The CoE Starter Kit does NOT have any hardcoded date limitations.** After analyzing:
- ✅ The AI Credits collection flow (`Admin | Sync Template v4 (AI Usage)`)
- ✅ The Dataverse entity definitions (`admin_AICreditsUsage`)
- ✅ All date-related logic and filters

I can confirm:
- **No hardcoded years** (2025, 2026, or any year)
- **No month-specific filters** (December or any month)
- **All date operations use dynamic functions** (`LastXDays`, `formatDateTime`, etc.)

The flow uses `LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1)` which is a **relative date filter** that will work indefinitely.

---

## 🎯 Root Cause

Since there are no limitations in the CoE Starter Kit code, the issue is **external** to the kit. Most likely:

1. **🔴 Microsoft's `msdyn_aievents` table not being populated** (platform-level issue)
2. **🟡 The data collection flow isn't running** (configuration issue)
3. **🟢 No AI Builder activity in your tenant** (no data to collect)

---

## 📋 Next Steps: Troubleshooting

I've created comprehensive documentation to help you diagnose the root cause. Please follow these steps:

### Step 1: Check the Flow ⭐ START HERE

1. Navigate to your **CoE environment**
2. Go to **Power Automate** → **Cloud flows**
3. Find: **Admin | Sync Template v4 (AI Usage)**
4. Check the **28-day run history**:
   - Is the flow **turned ON**?
   - Has it **run in January/February 2026**?
   - Are there **errors** in the run history?
   - In a successful run, check the "List AI Events" action output - how many records did it retrieve?

**If the flow returned 0 AI Events** → Proceed to Step 2

### Step 2: Verify Source Data Exists

The flow collects data from Microsoft's **`msdyn_aievents`** table (a system table in each environment).

**Quick Check via Advanced Find**:
1. Navigate to an environment where AI Builder is actively used
2. Open **Settings** → **Advanced Find**
3. Query:
   - Look for: **AI Events** (msdyn_aievents)
   - Filter: **Processing Date** → Last 7 Days
   - Filter: **Credit Consumed** → Greater than 0
4. Run the query

**Expected Result**: You should see records if AI Builder has been running

**If NO records found**:
- ⚠️ This indicates Microsoft's AI Builder platform isn't writing usage data to this table
- 🔴 **This is a platform-level issue** - you'll need to contact Microsoft Support
- Reference: "The `msdyn_aievents` table is not being populated with AI Builder usage data"

### Step 3: Verify AI Builder Is Active

Confirm that AI Builder models are actually running:
1. Go to **Power Platform Admin Center** → **Analytics** → **AI Builder**
2. OR: Check individual environments → **AI Builder** → **Models**
3. Verify:
   - Models are **Published** and **Enabled**
   - Models have **recent "Last Run"** dates in 2026
   - Models are consuming credits

---

## 📚 Documentation Created

I've created several documents to help you and future users:

### 1. **Troubleshooting Guide** ⭐ RECOMMENDED
**File**: [`CenterofExcellenceResources/TROUBLESHOOTING-AI-CREDITS-DATA.md`](../CenterofExcellenceResources/TROUBLESHOOTING-AI-CREDITS-DATA.md)

This document provides:
- Step-by-step diagnostic instructions
- Common flow errors and solutions
- How to verify data at each stage
- When to escalate to Microsoft Support

### 2. **Comprehensive FAQ**
**File**: [`CenterofExcellenceResources/FAQ-AI-CREDITS-USAGE.md`](../CenterofExcellenceResources/FAQ-AI-CREDITS-USAGE.md)

Answers 15+ common questions including:
- Why data stops at a certain date
- How to collect historical data
- Permission requirements
- Retention policies

### 3. **Technical Analysis** (For Maintainers)
**File**: [`ANALYSIS-AI-CREDITS-2026-ISSUE.md`](../ANALYSIS-AI-CREDITS-2026-ISSUE.md)

Deep dive into:
- Code structure and date handling
- Flow logic verification
- Entity definitions
- Power BI report structure

### 4. **Quick Reference Guide**
**File**: [`QUICKREF-AI-CREDITS-COLLECTION.md`](../QUICKREF-AI-CREDITS-COLLECTION.md)

Quick reference for:
- Data flow diagram
- Component details
- File locations
- API queries

---

## ℹ️ Information Needed

To help diagnose this further, please provide:

1. **Flow Run History**:
   - Screenshot of recent runs of "Admin | Sync Template v4 (AI Usage)"
   - Any error messages
   - Output from the "List AI Events" action (how many records?)

2. **AI Builder Activity**:
   - Are AI Builder models actively running in your tenant in 2026?
   - What types of models? (document processing, prediction, etc.)

3. **Source Data Check**:
   - Results from the Advanced Find query in Step 2 above
   - Does the `msdyn_aievents` table have data for January/February 2026?

4. **Environment Details**:
   - CoE Starter Kit version
   - Geographic region (US, EU, etc.)
   - Number of environments being scanned

---

## 🎯 Most Likely Resolution

Based on patterns from similar issues:

| If... | Then... |
|-------|---------|
| Flow is running but returns 0 AI Events | Microsoft's `msdyn_aievents` table isn't being populated → **Contact Microsoft Support** |
| Flow has errors | Fix connections/permissions → See troubleshooting guide |
| Flow isn't running | Enable flow and refresh connections |
| No AI Builder activity in 2026 | No data to collect (expected behavior) |

---

## 🔄 How AI Credits Collection Works

For your reference:

```
Microsoft AI Builder Platform
      ↓ (automatic)
msdyn_aievents table (per environment)
      ↓ (daily sync)
Admin | Sync Template v4 (AI Usage) flow
      ↓ (aggregation)
admin_AICreditsUsage table (CoE environment)
      ↓ (visualization)
Power BI Reports
```

**Key Points**:
- The CoE Starter Kit **only reads** from `msdyn_aievents` (doesn't create AI usage data)
- If Microsoft's table isn't populated, the CoE kit cannot collect data
- This is why verifying the source table (Step 2) is critical

---

## 📞 Support Path

1. **First**: Complete diagnostic steps above
2. **If flow issues**: Use the [troubleshooting guide](../CenterofExcellenceResources/TROUBLESHOOTING-AI-CREDITS-DATA.md)
3. **If source table is empty**: Contact Microsoft Support with:
   - Confirmation that `msdyn_aievents` table is empty or missing data
   - Evidence that AI Builder models are actively running
   - Environment ID and region
   - Time period of missing data (January 2026 onwards)

---

## 🙏 Next Actions

Please:
1. ✅ Follow the troubleshooting steps above
2. ✅ Report back with your findings (especially Step 2 results)
3. ✅ Share any error messages from flow run history

Once we know the results, we can provide more specific guidance!

---

## 📖 Related Links

- **Microsoft Learn**: [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- **AI Builder Credits**: [Credit Management Overview](https://learn.microsoft.com/en-us/ai-builder/credit-management)
- **Dataverse API**: [Web API Overview](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/overview)

---

*This issue has been analyzed and documented. Waiting for diagnostic results from user to determine specific root cause.*

**Status**: ⏳ Awaiting user response  
**Classification**: External to CoE Starter Kit (platform or configuration issue)  
**Documentation**: ✅ Complete

---

