# CoE Starter Kit Blank Screen - Quick Reference Card

## 🚨 FIRST STEPS: Essential Prerequisites Checklist

Before troubleshooting, verify ALL of these are in place:

### ✅ Licensing (Most Common Issue)
- [ ] **Power Apps Premium** OR **Power Apps Per User** license assigned
- [ ] **NOT** using Trial, Per-App, or Office 365 included licenses
- [ ] License is active and not expired

### ✅ Permissions
- [ ] **Tenant-level**: Global Admin OR Power Platform Admin role
- [ ] **Environment-level**: System Administrator role in CoE Dataverse environment
- [ ] Verified role assignment in Power Platform Admin Center > Settings > Users

### ✅ Environment Configuration
- [ ] Dataverse database provisioned in CoE environment
- [ ] English language pack enabled
- [ ] Canvas PCF components enabled (Settings > Features > Power Apps component framework for canvas apps = ON)
- [ ] Waited 10-15 minutes after enabling PCF

### ✅ DLP Policies
- [ ] Following connectors in **Business** group OR environment excluded:
  - Microsoft Dataverse
  - Power Apps for Admins
  - Power Automate Management
  - Office 365 Users
  - Office 365 Groups

### ✅ Environment Variables
- [ ] Core Components solution environment variables configured
- [ ] Organization URL / CoE Base URL set correctly
- [ ] Admin email set

### ✅ Data Synchronization
- [ ] Inventory flows have run successfully (check flow run history)
- [ ] Admin | Sync Template v3 completed without errors
- [ ] Tables contain data (check Power Apps App, Flows, Power Platform User tables)

---

## 🔍 QUICK DIAGNOSTIC STEPS

### Step 1: Browser Test
```
1. Open InPrivate/Incognito window
2. Go to make.powerapps.com
3. Open affected app
   - Works? → Clear cache in normal browser
   - Still blank? → Continue to Step 2
```

### Step 2: Check for Errors
```
1. Open app in play mode
2. Press: Ctrl+Alt+Shift+M (Windows) or Cmd+Option+Shift+M (Mac)
3. Monitor panel opens - look for red error entries
4. Common errors:
   - 401 Unauthorized → Missing permissions
   - 403 Forbidden → DLP policy blocking
   - 500 Internal Server Error → Environment variables or backend issue
   - Connector timeout → License/pagination issue
```

### Step 3: Verify Flows
```
1. Go to make.powerapps.com > Solutions > Core Components
2. Select Cloud flows
3. Check "Admin | Sync Template v3" run history
4. Look for failures or warnings
5. If never run → Run manually and wait
```

---

## 🎯 SPECIFIC APP ISSUES

### CoE Setup Wizard Blank
1. Check all prerequisites above
2. Verify environment variables set
3. Confirm System Administrator role
4. Enable Canvas PCF components
5. Try different browser

### Admin - Flow Permission Center Blank
1. Verify Flow inventory synchronized
2. Check "Admin | Sync Template v3 (Flows)" ran successfully
3. Ensure Power Automate Management connector not blocked
4. Confirm user can view flows in tenant

### Data Policy Impact Analysis Blank
1. Confirm DLP policies exist in tenant
2. Check Power Apps for Admins connector not blocked
3. Verify inventory populated apps/flows tables
4. Ensure user has policy viewing permissions

---

## ⚡ MOST COMMON SOLUTIONS

### 90% of blank screen issues are caused by ONE of these:

1. **TRIAL OR INSUFFICIENT LICENSE**
   - Solution: Assign Power Apps Premium or Per User license
   - DO NOT use Trial, Per-App, or O365 licenses

2. **MISSING SYSTEM ADMINISTRATOR ROLE**
   - Solution: Assign System Administrator in CoE environment
   - Power Platform Admin at tenant level is NOT enough

3. **PCF COMPONENTS NOT ENABLED**
   - Solution: Enable "Power Apps component framework for canvas apps"
   - Wait 10-15 minutes after enabling
   - Clear browser cache

4. **DLP POLICY BLOCKING CONNECTORS**
   - Solution: Move required connectors to Business group
   - Or exclude CoE environment from policy

5. **FLOWS HAVEN'T RUN YET**
   - Solution: Wait for initial data sync to complete
   - Can take 30 min to 24 hours depending on tenant size
   - Run inventory flows manually to speed up

---

## 📞 GET HELP

If still experiencing issues after checking ALL items above:

1. **Search existing issues**: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. **Read detailed guide**: [Troubleshooting Blank Screens](TROUBLESHOOTING-BLANK-SCREENS.md)
3. **Check FAQ**: [FAQ - Common Issues](FAQ-COMMON-ISSUES.md)
4. **File bug report**: [Bug Report Template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

### When filing a bug, include:
- [ ] Screenshot of blank screen
- [ ] This checklist with results
- [ ] Monitor errors (Ctrl+Alt+Shift+M output)
- [ ] Solution version
- [ ] Browser and version
- [ ] All troubleshooting steps tried

---

## 🔗 QUICK LINKS

- [Official CoE Docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Prerequisites](https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites)
- [Setup Troubleshooting](https://learn.microsoft.com/power-platform/guidance/coe/setup-troubleshooting)
- [Microsoft 365 Admin Center](https://admin.microsoft.com)
- [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
- [Power Apps Maker Portal](https://make.powerapps.com)

---

**Print this card and keep it handy when troubleshooting CoE Starter Kit blank screen issues.**

*Last Updated: 2024-12-16 | CoE Starter Kit v1.0+*
