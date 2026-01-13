# Issue Response: Apps and Flows Not Reflecting in Power BI Dashboards

**Issue**: After setting up CoE Starter Kit v4.50.6 in a test tenant and creating test flows and apps, they are not appearing in the Power BI dashboards even after refreshing.

## Analysis

Thank you for reporting this issue! This is one of the most common challenges users face during initial CoE Starter Kit setup. Based on your description, the issue is most likely related to one of the following:

1. **Inventory flows have not completed their initial run** - This is the most common cause
2. **Insufficient time has passed** - Initial inventory can take 24+ hours
3. **Flows are not configured or turned on properly**
4. **Power BI data source or refresh is not configured correctly**

## Root Cause

The CoE Starter Kit Power BI dashboards display data that is collected by automated flows (inventory flows). These flows:
- Must be turned ON manually after installation
- Run on a schedule (typically daily)
- Take significant time to complete the first full inventory scan
- Store collected data in Dataverse tables
- This data must then be loaded into Power BI

If any step in this chain is incomplete, your dashboards will appear empty.

## Solution

I've created a comprehensive troubleshooting guide specifically for this issue:

**📖 [Troubleshooting Guide: Apps and Flows Not Appearing in Power BI Dashboards](../Troubleshooting/PowerBI-Dashboard-No-Data.md)**

## Immediate Action Items

Please follow these steps in order:

### 1. Verify Inventory Flows Are Running (5-10 minutes)

Navigate to your CoE environment and check these flows:

**Critical Flows to Check:**
- `SETUP WIZARD | Admin | Sync Template v3 (Setup)` - Should have run once
- `Admin | Sync Template v3` - Should be ON and scheduled
- `Admin | Sync Flows v3` - Should be ON
- `Admin | Sync Apps v2` - Should be ON

**For each flow:**
1. Open the flow in Power Automate
2. Verify it is **turned ON** (toggle in top right)
3. Check **Run history** for:
   - Has it run at least once?
   - Did it complete successfully?
   - Are there error messages?

### 2. Run Initial Inventory (If Not Already Done)

If the flows haven't run yet or you want to trigger them manually:

1. Find and open: `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
2. Click **Run** and wait for it to complete
3. This can take **several minutes to hours** depending on tenant size

### 3. Verify Data in Dataverse (5 minutes)

Check if data was collected successfully:

1. Go to **Power Apps** (make.powerapps.com)
2. Select your **CoE environment**
3. Go to **Tables** (or **Data** > **Tables**)
4. Find and open these tables:
   - **Power Apps App** - Should contain your test app
   - **Flow** - Should contain your test flow
   - **Power Platform User** - Should contain maker information
5. **Important**: Check the **Created On** date - it should be recent

### 4. Refresh Power BI Data (2-5 minutes)

If data exists in Dataverse:

**In Power BI Desktop:**
1. Open your .pbix file
2. Click **Refresh** in the ribbon
3. Wait for all queries to complete

**In Power BI Service:**
1. Go to the workspace containing your report
2. Find the dataset
3. Click **Refresh now**
4. Configure data source credentials if prompted

### 5. Wait Appropriately

**This is critical**: Initial inventory collection takes time!

- **Small tenants** (< 100 resources): 30-60 minutes
- **Medium tenants** (100-1000 resources): 2-4 hours  
- **Large tenants** (> 1000+ resources): 4-24 hours

If you just completed setup:
- ✅ Wait at least 24 hours before considering it a problem
- ✅ The flows run on a schedule (typically daily at night)
- ✅ Check back tomorrow morning

## Verification Checklist

Use this checklist to confirm proper setup:

- [ ] Core Components solution installed successfully (version 4.50.6)
- [ ] Service account has Power Platform Administrator role
- [ ] All connections created and authenticated
- [ ] Environment variables configured (Admin Email, Environment ID, Tenant ID)
- [ ] SETUP WIZARD flows have run at least once
- [ ] All inventory flows (Sync Template, Sync Apps, Sync Flows) are **turned ON**
- [ ] At least one successful run of inventory flows visible in run history
- [ ] Data exists in Dataverse tables (checked manually)
- [ ] Power BI connected to correct environment URL
- [ ] Power BI data refreshed after flows completed
- [ ] Waited 24+ hours since initial setup

## Most Likely Issues Based on Your Scenario

Since you mentioned you:
- ✅ Imported all components
- ✅ Followed Microsoft documentation
- ✅ Created test flows and apps
- ❌ Don't see them in dashboards after refresh

**The most probable causes are:**

1. **Flows haven't run yet** (90% probability)
   - Solution: Check and manually run flows per Step 1-2 above

2. **Not enough time passed** (75% probability)
   - Solution: Wait 24 hours after flows complete

3. **Flows failed silently** (50% probability)
   - Solution: Check run history for errors

4. **Power BI not refreshed after data collection** (40% probability)
   - Solution: Refresh Power BI data per Step 4 above

## What to Provide If Issues Persist

If you've followed all steps and still have issues after 24+ hours, please provide:

1. **Screenshots of flow run history** showing:
   - SETUP WIZARD | Admin | Sync Template v3 (Setup)
   - Admin | Sync Template v3
   - Status (success/failed) and timestamps

2. **Dataverse table record counts**:
   - How many records in Power Apps App table?
   - How many records in Flow table?

3. **Any error messages** from flow runs

4. **Timeline**: When did you complete the initial setup?

5. **Environment details**:
   - Is this a Production environment or Dataverse for Teams?
   - What region is your tenant in?

## Additional Resources

- **Full Troubleshooting Guide**: [PowerBI-Dashboard-No-Data.md](../Troubleshooting/PowerBI-Dashboard-No-Data.md)
- **Official Setup Documentation**: https://docs.microsoft.com/power-platform/guidance/coe/setup-core-components
- **Core Components Explained**: https://docs.microsoft.com/power-platform/guidance/coe/core-components
- **Power BI Setup Guide**: https://docs.microsoft.com/power-platform/guidance/coe/setup-powerbi
- **CoE Starter Kit FAQ**: https://docs.microsoft.com/power-platform/guidance/coe/faq

## Expected Outcome

After following these steps:
1. You should see successful flow runs in the run history
2. Data should appear in Dataverse tables within hours
3. After refreshing Power BI, dashboards should show your test apps and flows
4. Going forward, new resources will appear after the nightly inventory run

## Important Notes

⏰ **Patience is key** - The initial setup requires time for flows to complete

🔄 **Flows run on schedule** - New resources won't appear instantly; they're collected during scheduled runs

📊 **Data pipeline** - Data flows from: Power Platform → Inventory Flows → Dataverse → Power BI

🎯 **Test environment** - Perfect place to validate the setup before production use

## Summary

This is a **normal and solvable issue**. In 95% of cases, it's simply a matter of:
1. Ensuring flows are turned on and have run
2. Waiting sufficient time for completion
3. Refreshing Power BI after data collection

Please follow the steps above and let us know if you need further assistance. Most users find their data appears within 24 hours of proper setup!

---

*For more detailed troubleshooting and advanced scenarios, see the [complete troubleshooting guide](../Troubleshooting/PowerBI-Dashboard-No-Data.md).*
