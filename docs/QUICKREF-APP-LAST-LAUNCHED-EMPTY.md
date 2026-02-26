# Quick Fix: "App Last Launched On" Field Empty

## 🎯 Problem
The **"App Last Launched On"** column shows empty dates for all apps in the Power Platform Admin View.

## ✅ Quick Answer
This field requires **Office 365 Audit Logs** to be enabled and configured. It's not populated by default inventory flows.

---

## 🚀 5-Minute Setup Check

### Step 1: Check Office 365 Audit Logs (2 minutes)
1. Go to: [Microsoft 365 Compliance Center](https://compliance.microsoft.com/auditlogsearch)
2. Look for: **"Start recording user and admin activity"** button
   - **If you see the button** → Click it, wait 24 hours, then continue
   - **If you don't see it** → Already enabled ✅ Continue to Step 2

**Requirements:**
- Microsoft 365 E3/E5 or Business Premium license
- Global Admin or Compliance Admin role to enable

---

### Step 2: Check Audit Log Flows (2 minutes)
1. Go to: **Power Automate** → Your CoE environment
2. Search for: `Admin | Audit Logs`
3. Look for these three flows:
   - ✅ `Admin | Audit Logs | Office 365 Management API Subscription`
   - ✅ `Admin | Audit Logs | Sync Audit Logs V2`
   - ✅ `Admin | Audit Logs | Update Data (V2)`

**If you DON'T see these flows:**
- You need Core Components **v4.17.4 or later**, OR
- You need to install the standalone **Audit Logs** solution
- See [Installation Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)

**If flows exist but are OFF:**
- Turn them ON
- Continue to Step 3

---

### Step 3: Activate Subscription (1 minute)
1. Find flow: `Admin | Audit Logs | Office 365 Management API Subscription`
2. Click **Run** (manual trigger)
3. Wait for completion (should succeed)

**What this does:** Creates subscription to receive app launch events from Microsoft 365

---

### Step 4: Wait and Test (Next day)
1. **Wait:** 24-48 hours for initial data flow
2. **Test:** Launch a Power App
3. **Wait:** 30 minutes
4. **Check:** Open Power Platform Admin View → Check "App Last Launched On" column

**Expected result:** The app you launched should show today's date in "App Last Launched On"

---

## ⚡ Troubleshooting Quick Checks

### ❌ Still Empty After 48 Hours?

**Check 1: Is sync flow running?**
```
Flow: Admin | Audit Logs | Sync Audit Logs V2
Expected: Runs daily, shows successful runs
If failing: Check run history for error messages
```

**Check 2: Are events being captured?**
```
In Power Apps:
1. Go to Advanced Find
2. Table: "Audit Logs" (admin_auditlog)
3. Filter: admin_operation = "LaunchPowerApp"
4. Expected: You should see events
```

**Check 3: Is update flow enabled?**
```
Flow: Admin | Audit Logs | Update Data (V2)
Status: Should be ON (not off)
Trigger: Automatic (don't manually run)
```

---

## 🔄 Alternative: If You Can't Use Audit Logs

**Option 1: Use "Modified On" instead**
- The `modifiedon` field tracks when app was last edited
- ⚠️ Limitation: Doesn't track app USAGE, only app changes
- Use for basic inactivity detection

**Option 2: Don't rely on this field**
- Use other governance metrics:
  - App ownership
  - Environment compliance
  - Connection types used
  - Sharing settings

---

## 📊 How It Works (Technical Overview)

```
User launches app
    ↓
Microsoft 365 Audit Logs capture "LaunchPowerApp" event
    ↓
Sync flow retrieves events daily
    ↓
Events stored in "admin_auditlog" table
    ↓
Update flow watches for new "LaunchPowerApp" events
    ↓
"App Last Launched On" field updated on app record
    ↓
Admin View displays the date
```

**Key points:**
- Historical launches (before setup) are NOT captured
- 15-30 minute delay between launch and field update
- Audit logs retained 90 days (E3) or 1 year (E5)
- Embedded apps may not generate events

---

## 📋 Requirements Checklist

Before this field can populate, verify ALL of these:

- [ ] Microsoft 365 E3/E5 or Business Premium license
- [ ] Office 365 Audit Logs enabled (M365 Compliance Center)
- [ ] CoE Core Components v4.17.4+ installed (or standalone Audit Logs solution)
- [ ] `Admin | Audit Logs | Office 365 Management API Subscription` flow exists and ran once
- [ ] `Admin | Audit Logs | Sync Audit Logs V2` flow is ON and running daily
- [ ] `Admin | Audit Logs | Update Data (V2)` flow is ON
- [ ] Service account has Power Platform Admin role
- [ ] Connections are authenticated and working
- [ ] No DLP policies blocking HTTP with Azure AD connector

---

## 🆘 Still Stuck?

### Get Help
1. **Review full guide:** [ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md](../ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md)
2. **Check official docs:** [Setup Audit Log](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
3. **Ask on GitHub:** [Open an issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

### When Asking for Help, Provide:
- CoE Core Components version (e.g., v4.20)
- Office 365 Audit Logs status (enabled/disabled)
- Whether audit log flows exist in your environment
- Flow run history screenshots (if flows are failing)
- License type (E3, E5, Business Premium)

---

## 💡 Pro Tips

**Tip 1: Enable audit logs early**
- Turn on Office 365 Audit Logs BEFORE installing CoE
- Gives you historical data when you later set up audit log flows

**Tip 2: Monitor flow health**
- Set up alerts for audit log flow failures
- Review run history monthly to catch authentication issues

**Tip 3: Large tenant optimization**
- Enable `admin_DelayAuditLogSync = Yes` if experiencing throttling
- Adjust sync schedule if hitting API limits

**Tip 4: Combine with other metrics**
- Use alongside "Modified On" for better inactivity detection
- Cross-reference with app sharing and permissions data
- Track both usage AND governance compliance

---

## ⏱️ Expected Timeline

**Initial Setup (starting from nothing):**

| Day | Action |
|-----|--------|
| 0 | Enable Office 365 Audit Logs |
| 1 | Install/upgrade CoE Core Components v4.17.4+ |
| 1 | Run subscription flow |
| 1-2 | Wait for audit log activation |
| 2 | Test app launch |
| 2 | Verify field populated (30 min after test) |
| 3+ | Normal operation - daily sync |

**Quick Fix (if already set up but flows disabled):**

| Time | Action |
|------|--------|
| Now | Turn on all three audit log flows |
| Now | Run subscription flow manually |
| 30 min | Test app launch |
| 1 hour | Check field populated |

---

## 🎓 Learn More

**Related Documentation:**
- [Inactivity Notification Flows Guide](../Documentation/InactivityNotificationFlowsGuide.md) - How this field is used
- [CoE Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components) - Complete setup
- [Office 365 Audit Logs](https://learn.microsoft.com/microsoft-365/compliance/audit-log-search) - Microsoft 365 side

**Use Cases:**
- **Inactivity notifications** - Identify unused apps for archival
- **License optimization** - Find apps not being used to reclaim licenses
- **Adoption tracking** - Measure actual app usage vs creation
- **Compliance reporting** - Demonstrate app utilization for audits

---

**Last updated:** February 2025  
**Version:** CoE Starter Kit v4.17.4+  
**Related Field:** `admin_applastlaunchedon`  
**Display Name:** "App Last Launched On"

---

## 📱 Print This!

**One-Page Quick Check:**
```
□ M365 Audit Logs ON? → compliance.microsoft.com/auditlogsearch
□ Flows exist? → Search "Admin | Audit Logs"
□ Flows ON? → Check status in Power Automate
□ Subscription flow run? → Run manually once
□ Wait 24-48 hours
□ Test: Launch app → Wait 30 min → Check field
```

If all ✅ → Field should populate  
If ❌ → See full troubleshooting guide
