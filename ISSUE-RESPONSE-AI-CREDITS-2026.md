# Issue Response Template: AI Credits Data Not Showing After December 2025

## Summary
The user reports AI Credits usage data only displays up to December 2025, with no data in 2026. After thorough analysis of the CoE Starter Kit code, **no hardcoded date limitations exist in the AI Credits collection flow**. The issue is likely external to the CoE Starter Kit.

---

## Response to User

Thank you for reporting this issue. I've conducted a comprehensive analysis of the AI Credits collection mechanism in the CoE Starter Kit.

### What I Found

**Good News**: There are **no hardcoded date limitations** (2025, 2026, or December) in the CoE Starter Kit code. The AI Credits collection flow uses dynamic date functions and should work indefinitely.

**The Issue**: This appears to be related to one of the following:

1. **Microsoft's `msdyn_aievents` table** (the source of AI Credits data) may have a platform-level issue
2. **No AI Builder activity** in your environments in 2026
3. **Flow execution issues** preventing data collection

---

## Troubleshooting Steps

### Step 1: Check Flow Execution ⭐ **Start Here**

1. Navigate to your CoE environment
2. Open **Power Automate** → **Cloud flows**
3. Find the flow named: **Admin | Sync Template v4 (AI Usage)**
4. Check the **28-day run history**:
   - Is the flow turned **ON**?
   - Has it run in January 2026?
   - Are there any **errors or warnings**?
   - Look at a successful run - how many AI Events does it retrieve? (If 0, that's your problem)

**Screenshot of what to look for**: Look at the "List AI Events from the Environment" action output.

---

### Step 2: Verify Source Data Exists

The flow collects data from the **`msdyn_aievents`** table in each environment. Let's verify this data exists:

1. **Navigate to an environment** where AI Builder is actively used
2. Open **Advanced Find** (or use Dataverse API)
3. Query the table:
   - **Entity**: msdyn_aievents
   - **Filter**: msdyn_processingdate is after December 31, 2025
   - **Select**: msdyn_creditconsumed, msdyn_processingdate

**Expected Result**: You should see records if AI Builder models ran in 2026

**If No Records**: The issue is that Microsoft's platform isn't writing AI usage data to this table in 2026 → **Contact Microsoft Support**

---

### Step 3: Check CoE Data Table

1. In your **CoE environment**, open **Advanced Find**
2. Query the **AI Credits Usage** table (admin_AICreditsUsage)
3. Sort by **Processing Date** (admin_processingdate) descending
4. What's the most recent date shown?

**If last date is December 2025**: Confirms the flow isn't collecting new data

---

### Step 4: Verify AI Builder Is Being Used

Confirm that:
- AI Builder models exist and are **actively running** in your tenant in 2026
- Models are consuming credits (not just existing but idle)
- Users have proper licenses for AI Builder

---

## Root Cause: Where the Issue Likely Is

Based on the code analysis:

| Component | Status | Details |
|-----------|--------|---------|
| **CoE Flow Logic** | ✅ No Issues | Uses dynamic dates, no hardcoded years |
| **CoE Data Table** | ✅ No Issues | Date field has no year limitations |
| **Microsoft `msdyn_aievents` Table** | ⚠️ Likely Issue | Platform-level table may have a bug/limitation |
| **Flow Execution** | ⚠️ Check Required | May not be running or encountering errors |

---

## Technical Details

### How AI Credits Collection Works:

1. **Flow Name**: Admin | Sync Template v4 (AI Usage)
2. **Runs**: Daily (per environment)
3. **Source**: Queries `msdyn_aievents` table using:
   ```odata
   $filter: "msdyn_creditconsumed gt 0 and (Microsoft.Dynamics.CRM.LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1))"
   ```
4. **Storage**: Saves aggregated data to `admin_AICreditsUsage` table
5. **Display**: Power BI reports read from `admin_AICreditsUsage`

### What I Verified:
✅ No hardcoded year values (2025, 2026) anywhere in the flow  
✅ No "December" or month-specific filters  
✅ Date operations use `formatDateTime()`, `startOfDay()`, `addDays()` - all relative functions  
✅ No year limitations in the `admin_processingdate` field (standard Dataverse Date field)  

---

## Next Actions

### Immediate:
1. ✅ **Check the flow run history** (Step 1 above)
2. ✅ **Verify AI Builder is actively used** in 2026
3. ✅ **Check if `msdyn_aievents` has 2026 data** (Step 2 above)

### If Data Doesn't Exist in msdyn_aievents:
- **Escalate to Microsoft Support**: This is a platform-level issue with AI Builder's data logging
- **Reference**: The `msdyn_aievents` table is a Microsoft system table, not part of the CoE Starter Kit

### If Flow Is Failing:
- Share the **error message** from the flow run history
- Check **connection permissions** (requires System Administrator role)
- Verify the flow is enabled for **all environments** where AI Builder is used

---

## Information Needed from You

To help diagnose this further, please provide:

1. **Flow Run History**: 
   - Screenshot of recent runs of "Admin | Sync Template v4 (AI Usage)"
   - Any error messages from failed runs
   - Output from the "List AI Events" action (how many records retrieved?)

2. **AI Builder Usage**:
   - Are AI Builder models actively running in your tenant in 2026?
   - What types of AI models (document processing, prediction, etc.)?

3. **Last Known Data**:
   - What's the exact last date showing in your Power BI report?
   - Which environments were included in that data?

4. **Environment Details**:
   - CoE Starter Kit version
   - Number of environments being scanned
   - Geographic region (US, EU, etc.)

---

## Related Resources

- **CoE Starter Kit Documentation**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit
- **AI Builder Credits Overview**: https://learn.microsoft.com/en-us/ai-builder/credit-management
- **Dataverse API Documentation**: https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/overview

---

## For CoE Maintainers

**Classification**: 
- ⚠️ **Not a CoE Starter Kit bug** - No code issues found
- 🔍 **Requires Investigation** - May be Microsoft platform issue
- 📋 **Document if Confirmed** - Add to troubleshooting guide if this is a known limitation

**Action Items**:
- Monitor for similar reports from other users
- Consider adding enhanced error logging to the AI Usage flow
- Create troubleshooting doc if pattern emerges

**Related Components**:
- Flow: `AdminSyncTemplatev4AIUsage-9BBE33D2-BCE6-EE11-904D-000D3A341FFF.json`
- Entity: `admin_AICreditsUsage`
- Power BI: `Production_CoEDashboard_July2024.pbit`

---

*Last Updated: 2024*  
*Analysis Document: ANALYSIS-AI-CREDITS-2026-ISSUE.md*
