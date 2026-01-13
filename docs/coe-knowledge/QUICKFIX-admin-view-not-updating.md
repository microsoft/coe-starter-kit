# Quick Fix: Power Platform Admin View Not Updating

> **Issue**: Admin View showing old data or missing environments

## 5-Minute Diagnostic

### 1. Check Flow Status ⏱️ 2 min

Navigate to: **Power Apps** → **CoE Environment** → **Solutions** → **Core Components** → **Cloud flows**

Check if these flows are **"On"**:
- ✅ Admin | Sync Template v4 (Driver)
- ✅ Admin | Sync Template v4 (Apps)  
- ✅ Admin | Sync Template v4 (Environments)

**If any are "Suspended" or "Off"** → Proceed to Step 3

### 2. Check Last Run ⏱️ 1 min

Open **Driver flow** → **28-day run history**

**Last successful run** should be within the last 24 hours.

**If last run is old or failed** → Proceed to Step 3

### 3. Fix Connections ⏱️ 2 min

Go to: **Power Apps** → **CoE Environment** → **Connections**

Look for warning icons on:
- Power Platform for Admins
- Microsoft Dataverse
- Office 365 Users

**If warnings exist:**
1. Click connection → **Edit**
2. Re-enter admin credentials
3. Save

## 10-Minute Fix

### 4. Turn On Flows ⏱️ 1 min

For any suspended flows:
1. Open the flow
2. Click **Turn on**
3. Wait for confirmation

### 5. Trigger Manual Sync ⏱️ 2 min + 15-30 min wait

1. Open **Admin | Sync Template v4 (Driver)** flow
2. Click **Test** → **Manually** → **Run**
3. Monitor progress (should complete in 15-30 minutes)

### 6. Verify Results ⏱️ 5 min

After sync completes (30 min later):

**Check Dataverse:**
1. Go to **Tables** → **Environment**
2. Search for missing environment name
3. Verify **Modified On** date is recent

**Check Admin View:**
1. Open **Power Platform Admin View** app
2. Go to **PowerApps Apps**
3. Verify recent apps appear
4. Check environment filter includes missing environment

## Still Not Working?

### Check Environment Variables

**Solutions** → **Core Components** → **Environment variables**

Verify:
- **Is All Environments Inventory** = "Yes"
- **Admin eMail** = configured

### Force Full Resync

1. Go to **Tables** → **Environment**
2. For each environment (or specific missing one):
   - Set **Environment Is Not Visible in Apps** = "Yes"
   - Save
   - Set back to "No"
   - Save
3. Wait 30-60 minutes

### Review Flow Errors

**Driver flow** → **Run history** → Select failed run

Common errors:
- **401/403**: Connection/permission issue → Fix connections (Step 3)
- **Invalid connection**: Re-authenticate → Fix connections (Step 3)
- **429 Throttling**: Wait and retry, consider service principal
- **Timeout**: Large tenant, this is normal, check if partial sync succeeded

## Prevention Checklist

- [ ] Review Driver flow run history weekly
- [ ] Set up flow failure email notifications (use Admin eMail variable)
- [ ] Re-authenticate connections quarterly
- [ ] Document which admin account is used for connections
- [ ] After any CoE update, trigger manual sync to verify

## Full Documentation

For detailed troubleshooting: [Complete Troubleshooting Guide](troubleshooting-admin-view-data-refresh.md)

## Need More Help?

1. Check [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. Search for similar closed issues
3. Create new issue with [bug template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

Include in your issue:
- Driver flow last run date and status
- Error messages from flow run history
- Connection status screenshots
- Whether manual sync completed successfully

---

**Estimated Resolution Time**: 10-60 minutes (including wait time for sync)  
**Success Rate**: ~90% of cases resolved by connection re-authentication and manual sync
