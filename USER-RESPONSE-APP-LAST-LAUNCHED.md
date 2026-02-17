# Response to Issue: "App Last Launched On" Field Empty

## Hi Caddy! 👋

Thank you for reporting this issue. I've completed a comprehensive analysis, and I have good news: **This is NOT a bug** - it's a **configuration requirement** that you can set up to populate the field.

---

## 🎯 Quick Answer

The **"App Last Launched On"** field requires **Office 365 Audit Logs** to be enabled and the **Audit Log flows** to be configured. Without these components, the field will remain empty for all apps.

---

## 📋 What You Need to Do

### Step 1: Enable Office 365 Audit Logs ⚡
1. Go to [Microsoft 365 Compliance Center](https://compliance.microsoft.com/auditlogsearch)
2. If you see **"Start recording user and admin activity"**, click it
3. Wait 24-48 hours for activation

**Requirements:**
- Microsoft 365 E3/E5 or Business Premium license
- Global Admin or Compliance Admin role

---

### Step 2: Install/Configure Audit Log Flows 🔧

**Check if you have Core Components v4.17.4 or later:**
- Go to **Power Apps** → Your CoE environment → **Solutions**
- Look for "Center of Excellence - Core Components"
- Check the version number

**If v4.17.4+** (Audit log flows included):
1. Go to **Power Automate** → Your CoE environment
2. Search for: `Admin | Audit Logs`
3. Turn ON these three flows:
   - ✅ `Admin | Audit Logs | Office 365 Management API Subscription` → Run once manually
   - ✅ `Admin | Audit Logs | Sync Audit Logs V2` → Turn ON (runs daily)
   - ✅ `Admin | Audit Logs | Update Data (V2)` → Turn ON (automatic)

**If earlier version:**
- Upgrade to Core Components v4.17.4 or later, OR
- Install the standalone **CenterofExcellenceAuditLogs** solution

---

### Step 3: Test It 🧪
1. Wait 24-48 hours after enabling audit logs
2. Launch a Power App
3. Wait 30 minutes
4. Check the **Power Platform Admin View** → "App Last Launched On" should show today's date

---

## 📚 Complete Documentation Created

I've created comprehensive documentation to help you and others with this issue:

### For You (Quick Setup):
- **[Quick Reference Guide](docs/QUICKREF-APP-LAST-LAUNCHED-EMPTY.md)** - 5-minute setup checklist with troubleshooting

### For Technical Team:
- **[Technical Analysis](ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md)** - Detailed architecture, data flow, and diagnostics
- **[GitHub Response Template](docs/ISSUE-RESPONSE-APP-LAST-LAUNCHED-EMPTY.md)** - For support team use

### Related:
- **[Inactivity Notification Guide](Documentation/InactivityNotificationFlowsGuide.md)** - Now includes App Last Launched references

---

## 🔄 How It Works (Behind the Scenes)

```
User launches app
    ↓
Microsoft 365 Audit Logs capture "LaunchPowerApp" event
    ↓
Admin | Audit Logs | Sync Audit Logs V2 retrieves events daily
    ↓
Events stored in admin_auditlog table
    ↓
Admin | Audit Logs | Update Data (V2) processes events
    ↓
Updates admin_applastlaunchedon field on app record
    ↓
Power Platform Admin View displays the date ✅
```

**Important Notes:**
- Historical launches (before setup) are NOT captured
- 15-30 minute delay between app launch and field update
- Audit logs retained for 90 days (E3) or 1 year (E5)

---

## ❓ What If I Can't Use Audit Logs?

If Office 365 Audit Logs aren't available in your environment (licensing, compliance restrictions, etc.):

### Alternative Options:

**Option 1: Use "App Modified On" instead**
- Tracks when app was last edited (not usage)
- ⚠️ Limitation: Doesn't track actual app launches
- Good for: Basic inactivity detection

**Option 2: Use Power Apps Analytics**
- Canvas apps only
- Limited retention period
- Separate connector required

**Option 3: Accept empty field**
- Use other governance metrics:
  - App ownership
  - Connection types
  - Sharing settings
  - Environment compliance

---

## 📊 Expected Timeline

| Day | What Happens |
|-----|--------------|
| **Day 0** | Enable Office 365 Audit Logs |
| **Day 1** | Install/configure audit log flows |
| **Day 1-2** | Wait for audit log infrastructure activation |
| **Day 2** | Test by launching an app |
| **Day 2** | Check field populated (30 min after launch) |
| **Day 3+** | Normal operation - daily sync |

---

## 🆘 Need Help?

### Common Issues:

**Q: Flows are running but field still empty?**
- Check flow run history for errors
- Verify connections are authenticated
- Check if DLP policies are blocking HTTP with Azure AD connector

**Q: Don't see the audit log flows?**
- Check Core Components version (needs v4.17.4+)
- Or install standalone CenterofExcellenceAuditLogs solution

**Q: Audit logs not capturing events?**
- Verify in [M365 Compliance Center](https://compliance.microsoft.com/auditlogsearch)
- Search for LaunchPowerApp operations
- May take 24-48 hours after enabling

### Get More Help:
- **Quick Reference**: [docs/QUICKREF-APP-LAST-LAUNCHED-EMPTY.md](docs/QUICKREF-APP-LAST-LAUNCHED-EMPTY.md)
- **Detailed Guide**: [ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md](ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md)
- **Official Docs**: [Setup Audit Log](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)

---

## ✅ Summary

**What you need to do:**
1. ✅ Enable Office 365 Audit Logs
2. ✅ Install/configure audit log flows (Core v4.17.4+)
3. ✅ Run subscription flow once
4. ✅ Wait 24-48 hours
5. ✅ Test and verify

**Result:** The "App Last Launched On" field will populate with actual app launch dates going forward.

---

**Note:** This field is used by the Inactivity Notification flows to identify unused apps. Even if empty, those flows will fall back to using the "Modified On" date, so your governance workflows will still work (though less accurately).

---

Feel free to reach out if you have any questions or need help with the setup!

**Resources at a glance:**
- 📖 [Quick Setup Guide](docs/QUICKREF-APP-LAST-LAUNCHED-EMPTY.md)
- 🔧 [Technical Analysis](ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md)
- 💬 [GitHub Issue Template](docs/ISSUE-RESPONSE-APP-LAST-LAUNCHED-EMPTY.md)

---

*Last updated: February 2026*  
*Issue Reference: microsoft/coe-starter-kit - App Last Launched empty*
