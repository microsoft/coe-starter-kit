# Issue Response Template: Power BI Dashboard Showing Stale or No Data

## When to Use This Template

Use this template when users report:
- Power BI Dashboard showing outdated data (e.g., "stuck in September")
- Power BI Dashboard showing no data after deployment
- Data not updating after running collector flows
- "None" selected for inventory/telemetry method

## Template Response

---

Thank you for reporting this issue with the Power BI Dashboard!

### Issue Analysis

Based on your description, it appears the Power BI dashboard is showing stale data (stuck in September) or no data. The key detail is that you indicated **"None"** as your inventory/telemetry method, which is the primary cause of this issue.

### Root Cause

The CoE Starter Kit Power BI Dashboard reads data from **Dataverse tables** in your CoE environment. These tables are populated by **inventory flows** (collectors). If no inventory method is active or if inventory hasn't run recently:

- ❌ Dataverse tables remain empty or stale
- ❌ Power BI dashboard has no fresh data to display
- ❌ Data appears "stuck" at the last successful inventory run

The data flow works like this:
```
Power Platform Environments
         ↓
Inventory Flows (Collectors) ← Must be running!
         ↓
Dataverse Tables (admin_app, admin_flow, etc.)
         ↓
Power BI Dashboard (.pbit file)
```

Simply deploying the .pbit file and entering your org URL **does not** trigger data collection—the inventory flows must run first.

### Solution: Run Full Inventory

After installing or upgrading the CoE Starter Kit, you **must** run a full inventory to populate historical data:

**Steps:**

1. Navigate to [Power Apps](https://make.powerapps.com/) and select your **CoE environment**
2. Go to **Solutions** → **Center of Excellence - Core Components** → **Environment Variables**
3. Find: **FullInventory** (`admin_FullInventory`)
4. Set **Current Value** = `Yes`
5. Click **Save**
6. **Wait 6-24 hours** for completion (varies by tenant size)
7. ⚠️ **CRITICAL**: Set **FullInventory** back to `No` after completion

### Verify Inventory Flows Are Running

After enabling full inventory, check that flows are running:

1. Go to **Solutions** → **Center of Excellence - Core Components** → **Cloud flows**
2. Verify these flows are **On** and running successfully:
   - **Admin | Sync Template v4**
   - **Admin | Sync Template v4 (Apps)**
   - **Admin | Sync Template v4 (Power Automate)**
   - **Admin | Sync Template v4 (Connectors)**
   - And other inventory flows...

3. Check the **28-day run history** for each flow
4. Look for **Succeeded** status (not Failed or Cancelled)

### Verify Data in Dataverse

Before troubleshooting Power BI further, confirm data exists in Dataverse:

1. Go to **Tables** in your CoE environment
2. Check these key tables have recent data:
   - **Environment** (`admin_environment`)
   - **PowerApps App** (`admin_app`)
   - **Flow** (`admin_flow`)
   - **Connector** (`admin_connector`)

3. Look at **Modified On** dates—should be recent (within 7 days)

### Refresh Power BI

After inventory completes:

1. Open your CoE Dashboard in **Power BI Desktop**
2. Click **Home** → **Refresh**
3. Wait for the refresh to complete (5-15 minutes)
4. Verify data is now current

### Comprehensive Troubleshooting Guide

For detailed troubleshooting steps, error resolution, and best practices, see:

📖 **[Troubleshooting: Power BI Dashboard Showing Stale or No Data](troubleshooting/power-bi-dashboard-stale-data.md)**

This comprehensive guide includes:
- Quick diagnostic flowchart
- Step-by-step solutions for all common scenarios
- How to verify inventory is running correctly
- Understanding incremental vs. full inventory
- BYODL-specific issues
- Advanced troubleshooting
- Prevention and best practices

### Key Takeaways

✅ **The Power BI dashboard relies on inventory flows**—deploying the .pbit alone is not enough  
✅ **Run full inventory after initial setup**—incremental mode only syncs recent changes  
✅ **Verify flows are enabled and running**—check the 28-day run history  
✅ **Check Dataverse tables first**—if tables are empty, Power BI will be empty  
✅ **Refresh Power BI after data loads**—it doesn't auto-refresh from Dataverse  

### Next Steps

Please follow the steps above to:
1. Enable full inventory (`admin_FullInventory = Yes`)
2. Wait for completion (6-24 hours depending on tenant size)
3. Verify data in Dataverse tables
4. Refresh Power BI Dashboard
5. Set full inventory back to `No`

**Let us know if you encounter any specific errors or if the issue persists after running full inventory!**

---

## Additional Context for Similar Issues

### If User Mentions Different Symptoms

**"Power BI shows connection error"**
- Check organization URL format: `https://[org].crm.dynamics.com/`
- Verify user has read access to CoE environment
- See: [Power BI Connection Timeout](troubleshooting/power-bi-connection-timeout.md)

**"Some data is missing but not all"**
- This is expected with incremental inventory mode
- Only objects created/modified in last 7 days are synced
- Solution: Run full inventory

**"Data was working before but stopped updating"**
- Check if flows are still enabled
- Check for flow errors in run history
- Verify service account license is still active

**"Using BYODL and data is stale"**
- BYODL is no longer recommended
- Must use `BYODL_CoEDashboard_July2024.pbit`
- Check Azure Synapse Link export status
- Consider migrating to standard Dataverse inventory

### Common Follow-Up Questions

**Q: How long does full inventory take?**
A: Depends on tenant size:
- Small (< 10 environments): 1-2 hours
- Medium (10-50 environments): 4-8 hours
- Large (50-200 environments): 12-24 hours
- Very Large (200+ environments): 24-48 hours

**Q: Should I keep full inventory enabled?**
A: **No!** Set it back to `No` after the initial run completes. Full inventory is resource-intensive and should only run:
- After initial installation
- After upgrades
- Quarterly for validation
- When troubleshooting missing data

**Q: Why does my dashboard show data from September?**
A: This indicates inventory ran in September but hasn't run since. The flows are likely:
- Turned off
- Failing with errors
- Service account license expired
- Environment variables misconfigured

**Q: What's the difference between "updating flows" and "running inventory"?**
A: 
- **Updating flows** = Importing new solution versions (code changes)
- **Running inventory** = Actually executing the flows to collect data
- You must do both! Updating the solution doesn't automatically trigger data collection.

## Template Variations

### For Users Who Already Ran Full Inventory

If the user confirms they already ran full inventory:

---

Thank you for confirming you've already run full inventory. Let's investigate further:

### Check Flow Run History

1. Navigate to **Solutions** → **Center of Excellence - Core Components** → **Cloud flows**
2. Open **Admin | Sync Template v4**
3. Check the **28-day run history**
4. Look for:
   - Failed runs (red X)
   - Cancelled runs (grey circle)
   - Succeeded but with warnings

**Please share:**
- Screenshot of run history
- Any error messages from failed runs
- When the last successful run occurred

### Verify Environment Variables

Check these critical variables:

1. `admin_FullInventory` - Should be `No` (after full inventory completes)
2. `admin_SyncFlowErrors` - Should be `Yes`
3. `Power Platform Admin` - Should have the service account email

### Check Service Account

The service account running inventory flows must have:
- ✅ **Power Apps Premium** or **Per User** license (active and not expired)
- ✅ **System Administrator** role in CoE environment
- ✅ **Power Platform Administrator** or **Global Admin** tenant role

Please verify the service account and share any findings!

---

### For Users Using BYODL

If the user confirms they're using BYODL:

---

I see you're using **Bring Your Own Data Lake (BYODL)** for inventory.

### Important Note

⚠️ BYODL is **no longer recommended** by the CoE Starter Kit team. We recommend using standard Dataverse inventory for better performance and reliability.

### BYODL-Specific Checks

1. **Verify you're using the correct .pbit file**
   - ❌ Production_CoEDashboard_July2024.pbit (for standard Dataverse)
   - ✅ BYODL_CoEDashboard_July2024.pbit (for BYODL)

2. **Check Azure Synapse Link status**
   - Go to Power Platform Admin Center → Environment → Azure Synapse Link
   - Verify tables are exported
   - Check last export timestamp

3. **Consider migrating to standard inventory**
   - Standard Dataverse inventory is more reliable
   - No dependency on Azure resources
   - Real-time data updates

Would you like guidance on migrating from BYODL to standard Dataverse inventory?

---

## Related Templates

- [Inventory Flow Not Running](ISSUE-RESPONSE-entity-admin-flow-not-exist.md)
- [DLP AppForbidden Errors](TROUBLESHOOTING-DLP-APPFORBIDDEN.md)
- [Power BI Connection Timeout](troubleshooting/power-bi-connection-timeout.md)
- [Upgrade Troubleshooting](../TROUBLESHOOTING-UPGRADES.md)

---

**Template Version**: 1.0  
**Last Updated**: February 2026  
**Maintained by**: CoE Starter Kit Community
