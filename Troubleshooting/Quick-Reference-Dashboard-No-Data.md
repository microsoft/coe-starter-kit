# Quick Reference: Power BI Dashboard Shows No Data

## 🚨 Most Common Cause
**Inventory flows haven't run or completed yet**

## ✅ Quick Fix (5 Minutes)

1. **Check Flow Status**
   ```
   Power Automate → Your CoE Environment → Cloud Flows
   → Find: "Admin | Sync Template v3"
   → Check: Is it ON? Has it run? Any errors?
   ```

2. **Turn On Required Flows**
   - SETUP WIZARD | Admin | Sync Template v3 (Setup)
   - Admin | Sync Template v3
   - Admin | Sync Flows v3
   - Admin | Sync Apps v2

3. **Run Setup Flow**
   ```
   Open: "SETUP WIZARD | Admin | Sync Template v3 (Setup)"
   → Click: Run
   → Wait: Until complete (can take minutes to hours)
   ```

4. **Verify Data in Dataverse**
   ```
   make.powerapps.com → Your CoE Environment
   → Tables → "Power Apps App" and "Flow" tables
   → Check: Do records exist?
   ```

5. **Refresh Power BI**
   ```
   Power BI Desktop: Click Refresh button
   Power BI Service: Dataset → Refresh now
   ```

6. **Wait 24 Hours**
   ```
   Initial inventory takes time
   Check again tomorrow morning
   ```

## ⏰ Expected Timeline

| Tenant Size | Initial Inventory Time |
|------------|----------------------|
| Small (<100 resources) | 30-60 minutes |
| Medium (100-1000 resources) | 2-4 hours |
| Large (1000+ resources) | 4-24 hours |

## 🔍 Troubleshooting Decision Tree

```
No data in Power BI dashboard?
│
├─ Are inventory flows turned ON?
│  ├─ No → Turn them ON and run SETUP WIZARD flow
│  └─ Yes → Continue
│
├─ Have flows run successfully?
│  ├─ No → Check flow run history for errors
│  ├─ Running → Wait for completion
│  └─ Yes → Continue
│
├─ Is data in Dataverse tables?
│  ├─ No → Review flow errors, check permissions
│  └─ Yes → Continue
│
├─ Is Power BI connected to correct environment?
│  ├─ No → Update data source settings
│  └─ Yes → Continue
│
└─ Has Power BI been refreshed after flows completed?
   ├─ No → Refresh Power BI data
   └─ Yes → Check advanced troubleshooting
```

## 🔑 Critical Checks

### Must Be Configured
- ✅ Service account = Power Platform Admin
- ✅ All connections authenticated
- ✅ Environment variables set correctly
- ✅ English language pack enabled

### Must Be Turned ON
- ✅ Admin | Sync Template v3
- ✅ Admin | Sync Flows v3
- ✅ Admin | Sync Apps v2

### Must Have Run Successfully
- ✅ SETUP WIZARD | Admin | Sync Template v3 (Setup) - at least once
- ✅ Admin | Sync Template v3 - at least once

## 📊 Data Flow Pipeline

```
Power Platform Resources (Apps, Flows)
          ↓
Inventory Flows (Admin | Sync Template v3, etc.)
          ↓
Dataverse Tables (Power Apps App, Flow, etc.)
          ↓
Power BI Dataset (requires refresh)
          ↓
Power BI Dashboard (displays data)
```

## 🆘 Getting Help

**Full Troubleshooting Guide**: [PowerBI-Dashboard-No-Data.md](PowerBI-Dashboard-No-Data.md)

**Direct Issue Response**: [ISSUE-RESPONSE-Dashboard-No-Data.md](ISSUE-RESPONSE-Dashboard-No-Data.md)

**Create Issue**: https://aka.ms/coe-starter-kit-issues

**Documentation**: https://docs.microsoft.com/power-platform/guidance/coe/setup

## 💡 Pro Tips

1. **Be Patient** - Initial setup takes 24+ hours
2. **Check Flow History** - First place to look for problems
3. **Verify Dataverse First** - Confirms data collection worked
4. **Refresh Power BI Last** - Only after data exists
5. **Schedule Awareness** - Flows run daily, not real-time

## ⚠️ Common Mistakes

❌ Not turning flows ON after import
❌ Not waiting 24 hours for initial run
❌ Not checking flow run history for errors
❌ Refreshing Power BI before flows complete
❌ Wrong environment URL in Power BI
❌ Insufficient permissions for service account

## ✨ Success Criteria

You'll know it's working when:
- ✅ Flows show successful runs with timestamps
- ✅ Dataverse tables contain records
- ✅ Power BI shows resource counts > 0
- ✅ Your test apps/flows appear in dashboard visuals

---

*This quick reference provides immediate action items. For detailed explanations and advanced troubleshooting, see the [complete guide](PowerBI-Dashboard-No-Data.md).*
