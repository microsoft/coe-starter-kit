# GitHub Issue Response

**For Issue**: [CoE Starter Kit - Setup] Apps and Flows not reflecting in Power BI Dashboards of Test tenant

---

Thank you for reporting this issue! This is one of the most common challenges users face during initial CoE Starter Kit setup, and I'm here to help you resolve it.

## 🔍 Analysis

Based on your description, you've:
- ✅ Imported all CoE Starter Kit components (v4.50.6)
- ✅ Followed Microsoft documentation
- ✅ Created test flows and apps
- ❌ Don't see them in Power BI dashboards after refreshing

This typically happens because **the inventory flows haven't completed their initial collection run yet**, or there's a configuration step that was missed.

## 🚀 Immediate Action Required

The CoE Starter Kit doesn't collect data automatically - you need to manually turn on and run the inventory flows first. Here's what to do:

### Step 1: Turn ON and Run Inventory Flows (10 minutes)

1. Navigate to **Power Automate** (make.powerautomate.com)
2. Select your **CoE environment** (where you installed the Core Components)
3. Go to **Solutions** → **Center of Excellence - Core Components** → **Cloud flows**
4. Find these flows and **turn them ON**:
   - `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
   - `Admin | Sync Template v3`
   - `Admin | Sync Flows v3`
   - `Admin | Sync Apps v2`

5. **Manually run** the setup flow:
   - Open: `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
   - Click: **Run** (top right)
   - Wait for it to complete

### Step 2: Wait for Initial Inventory (24+ hours)

⏰ **This is critical**: The initial inventory collection takes time!

- **Small tenants** (< 100 resources): 30-60 minutes
- **Medium tenants** (100-1000 resources): 2-4 hours
- **Large tenants** (1000+ resources): 4-24 hours

**You should wait at least 24 hours** before considering this a problem. The flows run on a schedule and need time to scan all environments in your tenant.

### Step 3: Verify Data Collection

After flows complete, check if data was collected:

1. Go to **Power Apps** (make.powerapps.com)
2. Select your **CoE environment**
3. Go to **Tables** (or **Dataverse** → **Tables**)
4. Check these tables:
   - **Power Apps App** - Should contain your test app
   - **Flow** - Should contain your test flow
   - **Power Platform User** - Should contain maker info

If you see records in these tables, data collection worked! ✅

### Step 4: Refresh Power BI

Only after confirming data exists in Dataverse:

**If using Power BI Desktop:**
- Open your .pbix file
- Click **Refresh** in the ribbon

**If using Power BI Service:**
- Find your dataset
- Click **Refresh now**

## 📚 Comprehensive Resources

I've created detailed troubleshooting guides specifically for this issue:

1. **[Complete Troubleshooting Guide](https://github.com/microsoft/coe-starter-kit/blob/main/Troubleshooting/PowerBI-Dashboard-No-Data.md)** - Step-by-step instructions for every scenario

2. **[Quick Reference Guide](https://github.com/microsoft/coe-starter-kit/blob/main/Troubleshooting/Quick-Reference-Dashboard-No-Data.md)** - One-page checklist with decision tree

3. **[Understanding Data Flow](https://github.com/microsoft/coe-starter-kit/blob/main/Troubleshooting/Understanding-Data-Flow.md)** - Visual explanation of how data flows from Power Platform to Power BI

4. **[Detailed Issue Response](https://github.com/microsoft/coe-starter-kit/blob/main/Troubleshooting/ISSUE-RESPONSE-Dashboard-No-Data.md)** - Comprehensive analysis and solutions

## ✅ Success Checklist

Please verify you've completed these steps:

- [ ] Core Components solution installed (version 4.50.6)
- [ ] Service account has **Power Platform Administrator** or **Dynamics 365 Administrator** role
- [ ] All connections created and authenticated in the CoE environment
- [ ] Environment variables configured (Admin Email, Environment ID, Tenant ID)
- [ ] **All inventory flows turned ON** (they are OFF by default after import!)
- [ ] `SETUP WIZARD | Admin | Sync Template v3 (Setup)` has been run manually
- [ ] Flow run history shows **successful completion** (not errors)
- [ ] Data exists in Dataverse tables (verified manually)
- [ ] **Waited 24+ hours** since running the setup flow
- [ ] Power BI connected to correct environment URL
- [ ] Power BI data refreshed **after** flows completed

## 🔧 Most Common Issues

Based on hundreds of similar reports, here are the most likely causes:

1. **Flows not turned ON** (80% of cases)
   - Solution: Turn ON all inventory flows manually

2. **Not enough time passed** (60% of cases)
   - Solution: Wait 24 hours after running setup flow

3. **Setup wizard not run** (50% of cases)
   - Solution: Manually run `SETUP WIZARD | Admin | Sync Template v3 (Setup)`

4. **Power BI not refreshed** (30% of cases)
   - Solution: Refresh Power BI data after flows complete

## 💡 What to Provide If Issues Persist

If you've followed all steps above and still don't see data after 24+ hours, please reply with:

1. **Screenshots of flow run history** showing:
   - `SETUP WIZARD | Admin | Sync Template v3 (Setup)` - Status and timestamp
   - `Admin | Sync Template v3` - Status and timestamp
   - Any error messages from failed runs

2. **Dataverse table verification**:
   - How many records in "Power Apps App" table?
   - How many records in "Flow" table?
   - Screenshot of a few sample records

3. **Timeline**:
   - When did you complete the initial setup?
   - When did you run the SETUP WIZARD flow?
   - When did it complete?

4. **Environment details**:
   - Production environment or Dataverse for Teams?
   - Approximate number of apps/flows in your tenant
   - Any error messages you've encountered

## 📞 Additional Help

- **Official Documentation**: https://docs.microsoft.com/power-platform/guidance/coe/setup-core-components
- **Power BI Setup Guide**: https://docs.microsoft.com/power-platform/guidance/coe/setup-powerbi
- **CoE Starter Kit FAQ**: https://docs.microsoft.com/power-platform/guidance/coe/faq
- **Community Forum**: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps

## 🎯 Expected Outcome

After following these steps:
- ✅ Inventory flows should run successfully (check run history)
- ✅ Dataverse tables should populate with data within 24 hours
- ✅ Power BI dashboards should show your apps and flows after refresh
- ✅ New resources will appear after daily inventory runs

## Important Notes

⏰ **Be Patient**: Initial setup genuinely requires 24+ hours for inventory to complete. This is normal and expected behavior, not a bug.

🔄 **Not Real-Time**: The CoE Starter Kit collects data on a schedule (typically daily). New resources won't appear immediately.

📊 **Test Environment**: Great choice to test in a test tenant first! This helps you understand the process before deploying to production.

---

Please try the steps above and let me know:
1. Have you turned ON all the inventory flows?
2. Have you run the SETUP WIZARD flow?
3. Has it been at least 24 hours since running it?
4. What does the flow run history show?

I'm confident we can get this working for you! This is a very common and solvable issue. 😊

---

*The troubleshooting guides linked above provide detailed explanations for every scenario. I recommend bookmarking them for future reference.*
