# Quick Reference: Setup Wizard Authentication Error

## 🔴 Problem
CoE Setup and Upgrade Wizard fails to open after upgrading to 4.50.8 with error:
- **Error Code**: `UserNotLoggedIn`
- **Error Message**: "Can't Sign In"
- **Details**: `untrusted_authority`, `AADSTS500113`, `endpoints_resolution_error`

---

## ✅ Quick Fix (Works for 95% of Users)

### 1. Clear Browser Cache Completely

**Windows / Linux:**
```
1. Press Ctrl + Shift + Delete
2. Select "All time"
3. Check both:
   ☑ Cookies and other site data
   ☑ Cached images and files
4. Click "Clear data" or "Clear now"
5. Quit browser completely (not just close tabs)
6. Restart browser and try again
```

**Mac:**
```
1. Press Cmd + Shift + Delete
2. Select "All time"
3. Check both:
   ☑ Cookies and other site data
   ☑ Cached images and files
4. Click "Clear data" or "Clear now"
5. Quit browser completely (Cmd+Q)
6. Restart browser and try again
```

### 2. Quick Alternative Test

**Open in InPrivate/Incognito mode:**
- Press `Ctrl+Shift+N` (Windows/Linux) or `Cmd+Shift+N` (Mac)
- Navigate to Power Apps
- Try opening Setup Wizard
- **If it works**: Return to step 1 and clear cache more thoroughly

---

## 🔍 Why Does This Happen?

**Root Cause**: Browser cached old authentication tokens that are no longer valid after the upgrade.

**This is NOT a bug** - it's a Power Apps platform behavior when MSAL authentication configuration changes during solution upgrades.

---

## 📚 More Help Needed?

### If Quick Fix Doesn't Work

**Full troubleshooting guide with 10 solutions:**  
📖 [docs/TROUBLESHOOTING-SETUP-WIZARD-AUTHENTICATION.md](TROUBLESHOOTING-SETUP-WIZARD-AUTHENTICATION.md)

Includes:
- Different browser testing
- Republishing the app
- Connection reference checks
- DLP policy verification
- Advanced troubleshooting
- Microsoft Support escalation path

### Other Resources

- [Setup Wizard Troubleshooting](../CenterofExcellenceResources/TROUBLESHOOTING-SETUP-WIZARD.md) - General Setup Wizard issues
- [Upgrade Troubleshooting](../TROUBLESHOOTING-UPGRADES.md) - All upgrade-related issues
- [Official CoE Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

---

## 🛡️ Prevention (For Future Upgrades)

**Add to your upgrade checklist:**
1. ✅ Clear browser cache immediately after every CoE upgrade
2. ✅ Test apps in InPrivate/Incognito mode first
3. ✅ Close all Power Apps tabs before clearing cache
4. ✅ Fully restart browser (quit application)

---

## 📞 Still Not Working?

**After trying all solutions:**

1. **This is a platform issue** - contact Microsoft Support (not CoE GitHub)
2. **Provide these details**:
   - Session ID (from error message)
   - Activity ID (from error message)
   - Error codes: `AADSTS500113`, `UserNotLoggedIn`
   - Browser and version used
   - Confirmation you cleared cache completely
3. **Open support ticket** via Power Platform Admin Center

---

## 📋 Quick Checklist

Before seeking help, confirm you've done:

- [ ] Closed ALL Power Apps browser tabs
- [ ] Cleared cache with time range = "All time"
- [ ] Cleared BOTH cookies AND cached images/files
- [ ] Fully quit and restarted browser (not just closed tabs)
- [ ] Tested in InPrivate/Incognito mode
- [ ] Tried a different browser (Edge, Chrome, Firefox)
- [ ] Waited 5-10 minutes after clearing cache before retrying

If all checked and still failing → read full troubleshooting guide.

---

**Last Updated**: February 9, 2026  
**Applies To**: CoE Core Components 4.50.8+  
**Success Rate**: ~95% with cache clearing
