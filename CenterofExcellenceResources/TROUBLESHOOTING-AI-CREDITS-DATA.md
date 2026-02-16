# Troubleshooting: AI Credits Usage Data Not Displaying

## Issue Description
AI Credits usage data is not displaying in Power BI reports or appears to stop at a certain date (e.g., December 2025).

## Common Symptoms
- Power BI "AI Usage Trend" chart shows no recent data
- "AI Credits Usage" table in Power Apps stops at a certain date
- Data appears complete up to a point but nothing beyond

---

## Root Cause Analysis

After comprehensive code analysis, **the CoE Starter Kit does NOT have any hardcoded date limitations**. The issue is external to the CoE Starter Kit and typically relates to:

1. ⚠️ **Microsoft's `msdyn_aievents` table** not being populated (platform issue)
2. ⚠️ **Flow execution failures** (configuration or permission issue)
3. ⚠️ **No AI Builder activity** in the time period in question

---

## Troubleshooting Steps

### Step 1: Check Flow Status ⭐ START HERE

1. Navigate to your **CoE environment**
2. Go to **Power Automate** → **Cloud flows**
3. Find the flow: **Admin | Sync Template v4 (AI Usage)**
4. Check:
   - ✅ Is the flow **turned ON**?
   - ✅ Has it **run recently**?
   - ✅ Are there **errors** in the 28-day run history?
   - ✅ In a successful run, check the "List AI Events from the Environment" action - how many records were retrieved?

**If the flow hasn't run**: Turn it on and wait for the next scheduled run (typically daily)

**If the flow is failing**: Note the error message and proceed to Step 4 (Common Flow Errors)

**If the flow returns 0 AI Events**: Proceed to Step 2 to verify source data exists

---

### Step 2: Verify Source Data Exists

The flow collects data from the **`msdyn_aievents`** table (a Microsoft system table) in each environment.

**Option A: Using Advanced Find (Manual)**
1. Navigate to an environment where AI Builder is actively used
2. Open **Settings** → **Advanced Find**
3. Query:
   - **Look for**: AI Events (msdyn_aievents)
   - **Use Saved View**: (none, create new)
   - **Filter**: Processing Date (msdyn_processingdate) → Last X Days → 7
   - **Columns**: Credit Consumed, Processing Date, Event Name
4. Run the query

**Expected Result**: Records should appear if AI Builder models have been running

**If No Records**:
- ⚠️ This indicates Microsoft's AI Builder platform is not writing usage data to this table
- 🔴 **Contact Microsoft Support** - this is a platform-level issue beyond the CoE Starter Kit
- Reference: "The `msdyn_aievents` table is not being populated with AI usage data"

**Option B: Using Power Automate (Automated Check)**
1. Create a temporary instant flow
2. Add action: **Microsoft Dataverse** → **List rows**
3. Configure:
   - **Table name**: AI Events (msdyn_aievents)
   - **Fetch Xml query**: 
     ```xml
     <fetch top="10">
       <entity name="msdyn_aievent">
         <attribute name="msdyn_processingdate" />
         <attribute name="msdyn_creditconsumed" />
         <attribute name="msdyn_eventname" />
         <filter>
           <condition attribute="msdyn_processingdate" operator="last-x-days" value="7" />
           <condition attribute="msdyn_creditconsumed" operator="gt" value="0" />
         </filter>
         <order attribute="msdyn_processingdate" descending="true" />
       </entity>
     </fetch>
     ```
4. Run the flow and check output

---

### Step 3: Verify CoE Data Collection

Check if data made it to the CoE environment:

1. In your **CoE environment**, open **Settings** → **Advanced Find**
2. Query:
   - **Look for**: AI Credits Usage (admin_AICreditsUsage)
   - **Use Saved View**: (none, create new)
   - **Order By**: Processing Date → Descending
3. Note the **most recent date** shown

**If last date matches your "data stops at" date**: Confirms the flow isn't collecting new data → Return to Step 1

---

### Step 4: Common Flow Errors

#### Error: "The operation failed because the requested record couldn't be found"
**Cause**: The target environment doesn't have the `msdyn_aievents` table
**Solution**: 
- Ensure AI Builder is enabled in the environment
- Check if the environment has proper licenses (AI Builder capacity)
- Some environment types (e.g., trial) may not have this table

#### Error: "Forbidden" or "Unauthorized"
**Cause**: Flow connection doesn't have proper permissions
**Solution**:
1. Edit the flow
2. Go to each Dataverse action
3. Click the three dots → **Reconnect**
4. Sign in with an account that has:
   - **System Administrator** role in the target environment
   - **Power Platform Administrator** role in Entra ID
   - **AI Builder** license

#### Error: "The API operation 'ListRows' requires a license"
**Cause**: Missing licenses
**Solution**: Ensure the flow owner has:
- Power Apps Per User or Premium license
- AI Builder add-on (if AI Builder usage reporting is required)

---

### Step 5: Verify AI Builder Is Active

Confirm that AI Builder models are actually running and consuming credits:

1. Navigate to **Power Platform Admin Center**
2. Go to **Analytics** → **AI Builder** (if available)
3. OR: Check individual environments for AI Builder models:
   - Go to an environment
   - Open **AI Builder** → **Models**
   - Check **Last Run** date for models
   - Verify models are **Published** and **Enabled**

**If no models are running**: This explains why there's no data - AI Builder must be actively used to generate credit usage data

---

## Technical Background

### How AI Credits Collection Works

```
Microsoft AI Builder Platform
      ↓ (automatic)
msdyn_aievents table (per environment)
      ↓ (daily sync via flow)
Admin | Sync Template v4 (AI Usage) flow
      ↓ (aggregation)
admin_AICreditsUsage table (CoE environment)
      ↓ (visualization)
Power BI Reports
```

### Flow Details
- **Name**: Admin | Sync Template v4 (AI Usage)
- **File**: `AdminSyncTemplatev4AIUsage-9BBE33D2-BCE6-EE11-904D-000D3A341FFF.json`
- **Schedule**: Daily (default)
- **Data Query**: Uses `LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1)` - a **relative** date filter with no hardcoded years
- **Source**: Queries `msdyn_aievents` table using OData filter:
  ```
  $filter: "msdyn_creditconsumed gt 0 and (Microsoft.Dynamics.CRM.LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1))"
  ```
- **Target**: Stores aggregated data in `admin_AICreditsUsage` table

### Code Verification
✅ **No hardcoded date limitations** exist in:
- Flow logic (uses dynamic date functions)
- Entity definitions (standard Dataverse Date fields)
- OData queries (relative date filters only)

---

## Resolution Summary

| Scenario | Root Cause | Resolution |
|----------|------------|------------|
| Flow returns 0 AI Events | No data in `msdyn_aievents` | Check Step 2 - likely platform issue or no AI activity |
| Flow has errors | Configuration or permissions | Check Step 4 - fix connections and permissions |
| Flow not running | Disabled or connection expired | Check Step 1 - enable flow and refresh connections |
| Data exists but not in Power BI | Power BI refresh issue | Refresh Power BI dataset or check last refresh timestamp |

---

## Escalation

**When to Contact Microsoft Support**:
- If `msdyn_aievents` table is confirmed empty despite active AI Builder usage
- If table doesn't exist in environments where AI Builder is enabled
- If platform-level permissions prevent access to system tables

**Information to Provide**:
- Environment ID where issue occurs
- AI Builder models in use (types and frequency)
- Confirmation that Step 1-3 were completed
- Screenshot of Advanced Find results for `msdyn_aievents`
- Error messages from flow run history (if any)

---

## Related Documentation

- **CoE Starter Kit Setup**: [Microsoft Learn - CoE Starter Kit](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- **AI Builder Credits**: [AI Builder Credit Management](https://learn.microsoft.com/en-us/ai-builder/credit-management)
- **Admin Role Requirements**: See `FAQ-AdminRoleRequirements.md` in this directory
- **Detailed Analysis**: See repository root `ANALYSIS-AI-CREDITS-2026-ISSUE.md` for complete technical analysis

---

## Additional Resources

For a deep technical dive into the AI Credits collection mechanism, see:
- **ANALYSIS-AI-CREDITS-2026-ISSUE.md** - Comprehensive code analysis
- **QUICKREF-AI-CREDITS-COLLECTION.md** - Quick reference guide
- **ISSUE-RESPONSE-AI-CREDITS-2026.md** - Template for responding to users

---

*Last Updated: February 2026*  
*Status: Verified - No code limitations exist in CoE Starter Kit*
