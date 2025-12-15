# CoE Starter Kit - Quick Reference Guide for Environment Inventory Issues

This is a quick reference for diagnosing and fixing environment inventory issues in the CoE Starter Kit.

## 🔍 Quick Diagnostic Checklist

Use this checklist to quickly identify the root cause:

- [ ] **Sync flow running?** Check "Admin | Sync Template v4 (Driver)" flow history
- [ ] **Environments excluded?** Check "Excuse From Inventory" field on environment records
- [ ] **Track all enabled?** Verify "Track All Environments" environment variable is True
- [ ] **Proper license?** Service account has full Power Apps Premium license (not trial)
- [ ] **Admin permissions?** Service account has Power Platform Administrator role
- [ ] **Recent errors?** Check "Sync Flow Errors" table in Dataverse

## ⚡ Quick Fixes

### Fix 1: Include Excluded Environments (Most Common)
**Problem**: Environments are marked as "Excuse From Inventory"

**Quick Fix**:
1. Open Power Platform Admin View app
2. Go to Environments → Search for missing environment
3. Set "Excuse From Inventory" to **No**
4. Save
5. Run "Admin | Sync Template v4 (Driver)" flow manually

**Time to fix**: 2-5 minutes

---

### Fix 2: Enable Automatic Tracking
**Problem**: New environments not automatically included

**Quick Fix**:
1. Go to Power Apps → Solutions
2. Open "Center of Excellence - Core Components"
3. Find Environment Variable: "Track All Environments"
4. Set Current Value to **True**
5. Save

**Time to fix**: 1-2 minutes

---

### Fix 3: Trigger Manual Sync
**Problem**: Sync flow hasn't run or hasn't run recently

**Quick Fix**:
1. Go to Power Automate (CoE environment)
2. Find "Admin | Sync Template v4 (Driver)"
3. Click **Run** → **Run flow**
4. Wait for completion (may take 10-60 minutes depending on tenant size)

**Time to fix**: Wait time varies

---

### Fix 4: License Issue
**Problem**: Pagination limit hit due to trial/insufficient license

**Quick Fix**:
1. Assign Power Apps Premium license to service account
2. Remove any trial licenses
3. Wait 30 minutes for license to propagate
4. Run sync flow manually

**Time to fix**: 30-60 minutes (including propagation)

---

### Fix 5: Permission Issue
**Problem**: Service account can't list all environments

**Quick Fix**:
1. Go to Microsoft 365 Admin Center
2. Assign **Power Platform Administrator** role to service account
3. Wait 15 minutes for permissions to propagate
4. Run sync flow manually

**Time to fix**: 15-30 minutes (including propagation)

---

## 🎯 Decision Tree

```
Environment not appearing?
│
├─ Can you find it in Environments table?
│  │
│  ├─ YES → Check "Excuse From Inventory"
│  │        │
│  │        ├─ Set to "Yes" → Change to "No" → Run sync → ✅ FIXED
│  │        └─ Set to "No" → Check sync flow errors → See detailed guide
│  │
│  └─ NO → Has sync flow run recently?
│           │
│           ├─ NO → Run sync manually → Wait → Check again → ✅ FIXED
│           │
│           └─ YES → Check flow run output
│                    │
│                    ├─ Exactly 100 environments? → License issue → Fix 4
│                    ├─ Permission errors? → Permission issue → Fix 5
│                    └─ Other errors? → See detailed troubleshooting guide
```

## 📊 Common Scenarios

### Scenario 1: All environments missing
**Likely cause**: Sync flow never ran or failed
**Fix**: Fix 3 (Manual sync)

### Scenario 2: Only some environments missing
**Likely cause**: "Excuse From Inventory" set to Yes
**Fix**: Fix 1 (Include environments)

### Scenario 3: New environments not appearing
**Likely cause**: "Track All Environments" is False
**Fix**: Fix 2 (Enable automatic tracking)

### Scenario 4: Exactly 100 environments showing (when you have more)
**Likely cause**: Pagination limit / license issue
**Fix**: Fix 4 (License upgrade)

### Scenario 5: No environments showing, permission errors in flow
**Likely cause**: Insufficient permissions
**Fix**: Fix 5 (Add admin role)

## 🔗 Need More Help?

If quick fixes don't work:
1. See detailed guide: [Troubleshooting: Environments Not Listed](./environments-not-listed.md)
2. Check flow run history for specific error messages
3. Review Sync Flow Errors table in Dataverse
4. File an issue: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

## ⏱️ Expected Wait Times

After making changes, expect these wait times:

| Action | Wait Time | Can Be Accelerated? |
|--------|-----------|---------------------|
| Change "Excuse From Inventory" | Immediate | Run sync manually |
| Enable "Track All Environments" | Next sync (24h) | Run sync manually |
| Assign license | 30-60 min | No |
| Assign permissions | 15-30 min | No |
| Manual sync (small tenant) | 10-30 min | No |
| Manual sync (large tenant) | 30-120 min | No |

## 📝 Information to Gather Before Asking for Help

If you need to file an issue, have this ready:
- [ ] CoE Starter Kit version
- [ ] Inventory method (Cloud flows / Data Export)
- [ ] Number of environments in tenant
- [ ] Number of environments showing in app
- [ ] Screenshot of sync flow run history (last 5 runs)
- [ ] Screenshot of one missing environment record (if it exists in table)
- [ ] Any error messages from flows
- [ ] Service account license type
- [ ] Service account roles/permissions
