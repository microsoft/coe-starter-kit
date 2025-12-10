# Quick Reference: Resolving Missing Buttons in CoE Admin Environment Request App

## 🔍 Problem
You can't see "View" or "Approve Request" buttons in the CoE Admin Environment Request app.

## ⚡ Quick Fix (5 minutes)

### Step 1: Check Your Security Role
```
Power Platform Admin Center → Environments → [Your CoE Env] → 
Settings → Users + permissions → Users → [Your User] → Manage Roles

✅ Ensure "Power Platform Admin SR" is checked
❌ "Power Platform Maker SR" alone is NOT enough
```

### Step 2: Verify App Sharing
```
make.powerapps.com → Apps → CoE Admin - Environment Request → 
Share → Add yourself with "Power Platform Admin SR"
```

### Step 3: Clear Cache
```
1. Close ALL Power Apps browser tabs
2. Press Ctrl+Shift+Delete (or Cmd+Shift+Delete on Mac)
3. Clear browsing data → All time → Cached images and files
4. Restart browser
5. Reopen the app
```

## 📋 Verification Checklist

Before reporting an issue, verify:

- [ ] I have the **Power Platform Admin SR** security role assigned (not just Maker)
- [ ] The admin app is shared with me using the Admin SR role
- [ ] I've cleared my browser cache completely
- [ ] I've logged out and logged back in
- [ ] I'm accessing the correct CoE environment
- [ ] All my connections are active (no red X marks)
- [ ] I've waited 5-10 minutes after role assignment for changes to propagate

## 🔧 Detailed Troubleshooting

### Security Role Issues

| Symptom | Cause | Solution |
|---------|-------|----------|
| No buttons visible | Maker role only | Assign Admin SR role |
| Buttons for some records only | Business unit scoped | Change to Organization scope |
| "No permissions" error | Table privileges missing | Verify Global-level privileges |

### Permission Levels Explained

| Security Role | Privilege Level | Can Approve? | Can View All? |
|---------------|----------------|--------------|---------------|
| Power Platform Maker SR | Basic | ❌ No | ❌ No (own only) |
| Power Platform Admin SR | Global | ✅ Yes | ✅ Yes |

### Required Privileges (Admin SR Role)

Table: `coe_EnvironmentCreationRequest`

| Privilege | Level | Required |
|-----------|-------|----------|
| Read | Global | ✅ |
| Write | Global | ✅ |
| Create | Global | ✅ |
| Delete | Global | ✅ |
| Assign | Global | ✅ |
| Append | Global | ✅ |
| Append To | Global | ✅ |

## 🚨 Common Mistakes

1. ❌ **Only assigning Maker role** → Assign Admin SR
2. ❌ **Forgetting to share the app** → Share with Admin SR role
3. ❌ **Not clearing cache** → Clear completely and restart browser
4. ❌ **Using wrong environment** → Verify you're in the COE environment
5. ❌ **Business unit scoped** → Ensure Organization-level access

## 🎯 Still Not Working?

### Advanced Checks

1. **Verify Security Role Privileges**
   ```
   Settings → Security → Security Roles → Power Platform Admin SR → 
   Custom Entities → Environment Creation Request → 
   All circles should be filled (Global level)
   ```

2. **Check Business Unit Scope**
   ```
   If your role is scoped to a specific business unit:
   - You may only see records in that BU
   - Change to Organization level for full access
   ```

3. **DLP Policy Check**
   ```
   Power Platform Admin Center → Policies → Data policies →
   Verify required connectors are in the same group:
   - Dataverse
   - Office 365 Outlook
   - Power Platform for Admins
   ```

4. **Connection Status**
   ```
   make.powerapps.com → Data → Connections →
   Verify all connections show green checkmarks
   ```

## 📞 Getting Help

### Before Asking for Help

Gather this information:
1. CoE Starter Kit version (e.g., 4.50.6)
2. Screenshot showing missing buttons
3. Screenshot of your security role assignments
4. Confirmation you've cleared cache and restarted
5. Whether this is a fresh install or upgrade

### Where to Get Help

1. **Documentation**: [CoE Starter Kit Docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. **GitHub**: [Report Issue](https://github.com/microsoft/coe-starter-kit/issues)
3. **Community**: [Power Platform Forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

## 🔗 Related Resources

- [Full Troubleshooting Guide](../../.github/ISSUE_TEMPLATE/troubleshooting-environment-request-admin-app.md)
- [FAQ](./FAQ-Environment-Request-App.md)
- [Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

## 💡 Pro Tips

1. **After Installing CoE Kit**: Always assign roles and share apps explicitly
2. **After Upgrades**: Verify app sharing wasn't reset
3. **Testing**: Use a test user to verify permissions before rolling out
4. **Documentation**: Keep a list of who should have Admin SR vs Maker SR
5. **Monitoring**: Set up alerts for failed approval flows

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 2025 | Initial quick reference |

---

**Note**: This is a quick reference guide. For comprehensive documentation, see the [full troubleshooting guide](../../.github/ISSUE_TEMPLATE/troubleshooting-environment-request-admin-app.md).
