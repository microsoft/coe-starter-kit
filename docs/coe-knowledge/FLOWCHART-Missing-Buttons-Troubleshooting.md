# Troubleshooting Flowchart: Missing Buttons in CoE Admin Environment Request App

## Visual Decision Tree

```
┌─────────────────────────────────────────────────────────────────┐
│  START: Can't see "View" or "Approve Request" buttons          │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
         ┌─────────────────────────────┐
         │ Can you see the app in      │
         │ your app list?              │
         └──────┬───────────────┬──────┘
                │               │
               Yes             No
                │               │
                │               ▼
                │    ┌─────────────────────────┐
                │    │ App not shared with you │
                │    │ Action: Have admin      │
                │    │ share the app           │
                │    └─────────────────────────┘
                │
                ▼
    ┌───────────────────────────┐
    │ Do you have "Power        │
    │ Platform Admin SR" role?  │
    └──────┬─────────────┬──────┘
           │             │
          Yes           No
           │             │
           │             ▼
           │  ┌─────────────────────────────┐
           │  │ You only have Maker SR      │
           │  │ Action:                     │
           │  │ 1. Go to Admin Center       │
           │  │ 2. Manage Roles for user    │
           │  │ 3. Assign Admin SR role     │
           │  └─────────────────────────────┘
           │
           ▼
┌──────────────────────────────┐
│ Can you see ANY requests     │
│ in the gallery?              │
└──────┬────────────────┬──────┘
       │                │
      Yes              No
       │                │
       │                ▼
       │     ┌─────────────────────────┐
       │     │ Connection or data      │
       │     │ issue                   │
       │     │ Action:                 │
       │     │ 1. Check connections    │
       │     │ 2. Run inventory flows  │
       │     │ 3. Verify table access  │
       │     └─────────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Have you cleared your        │
│ browser cache recently?      │
└──────┬────────────────┬──────┘
       │                │
      Yes              No
       │                │
       │                ▼
       │     ┌─────────────────────────┐
       │     │ Clear cache:            │
       │     │ 1. Ctrl+Shift+Delete    │
       │     │ 2. Select "All time"    │
       │     │ 3. Clear cache          │
       │     │ 4. Restart browser      │
       │     │ 5. Try again            │
       │     └─────────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Is the app shared with you   │
│ using Admin SR role?         │
└──────┬────────────────┬──────┘
       │                │
      Yes              No
       │                │
       │                ▼
       │     ┌─────────────────────────┐
       │     │ App shared incorrectly  │
       │     │ Action:                 │
       │     │ 1. Go to make.powerapps │
       │     │ 2. Find the app         │
       │     │ 3. Share → Add user     │
       │     │ 4. Select Admin SR role │
       │     └─────────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Check table permissions:     │
│ Settings → Security →        │
│ Security Roles →             │
│ Power Platform Admin SR      │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Does coe_Environment         │
│ CreationRequest table have   │
│ GLOBAL level privileges?     │
└──────┬────────────────┬──────┘
       │                │
      Yes              No
       │                │
       │                ▼
       │     ┌─────────────────────────┐
       │     │ Security role missing   │
       │     │ privileges              │
       │     │ Action:                 │
       │     │ 1. Verify solution      │
       │     │    imported correctly   │
       │     │ 2. Check for unmanaged  │
       │     │    customizations       │
       │     │ 3. Reimport solution    │
       │     └─────────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Have you waited 5-10 min     │
│ after role assignment?       │
└──────┬────────────────┬──────┘
       │                │
      Yes              No
       │                │
       │                ▼
       │     ┌─────────────────────────┐
       │     │ Permissions propagating │
       │     │ Action:                 │
       │     │ Wait a few minutes,     │
       │     │ then try again          │
       │     └─────────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Check DLP policies:          │
│ Are required connectors in   │
│ the same DLP group?          │
└──────┬────────────────┬──────┘
       │                │
      Yes              No
       │                │
       │                ▼
       │     ┌─────────────────────────┐
       │     │ DLP policy blocking     │
       │     │ Action:                 │
       │     │ 1. Admin Center         │
       │     │ 2. Data policies        │
       │     │ 3. Move connectors to   │
       │     │    same group           │
       │     └─────────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Advanced Troubleshooting:    │
│ 1. Check browser console     │
│    (F12) for errors          │
│ 2. Verify business unit      │
│    scope (Organization)      │
│ 3. Test with different user  │
│ 4. Check flow run history    │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Still not working?           │
│ Create GitHub issue with:    │
│ - Screenshots                │
│ - Security role details      │
│ - Steps attempted            │
│ - Error messages             │
└──────────────────────────────┘
```

---

## Quick Checklist Format

Use this checklist to systematically troubleshoot the issue:

### ☑️ Pre-Flight Check
- [ ] I can access the CoE Admin Environment Request app
- [ ] I can see environment requests in the gallery
- [ ] I'm logged in with the correct account
- [ ] I'm in the correct CoE environment

### ☑️ Security Role Verification
- [ ] I have "Power Platform Admin SR" role assigned
- [ ] I can see the role in Admin Center → Users → Manage Roles
- [ ] The role was assigned more than 10 minutes ago
- [ ] I've logged out and back in since role assignment

### ☑️ App Sharing Verification
- [ ] The app appears in my app list
- [ ] The app is shared with me
- [ ] The app is shared with "Power Platform Admin SR" role
- [ ] I can launch the app without errors

### ☑️ Table Permissions Verification
- [ ] Security role has Global privileges on coe_EnvironmentCreationRequest
- [ ] All privilege circles are filled (not just some)
- [ ] No unmanaged customizations on the security role
- [ ] Business unit scope is "Organization" (not "Business Unit")

### ☑️ Cache and Browser
- [ ] I've cleared browser cache completely
- [ ] I've cleared "All time" (not just "Last hour")
- [ ] I've restarted my browser
- [ ] I'm using a supported browser (Edge or Chrome)
- [ ] Browser extensions are disabled or not interfering

### ☑️ Connection and DLP
- [ ] All connections show green checkmarks
- [ ] No DLP policies blocking required connectors
- [ ] Dataverse connector is accessible
- [ ] Power Platform for Admins connector is accessible

### ☑️ Advanced Checks
- [ ] No JavaScript errors in browser console (F12)
- [ ] Flows related to environment requests are enabled
- [ ] No recent solution import issues
- [ ] Environment variables are configured correctly

---

## Decision Matrix

| Symptom | Most Likely Cause | Quick Fix |
|---------|------------------|-----------|
| No buttons at all | Missing Admin SR role | Assign Admin SR role |
| Buttons for some records only | Business Unit scoped role | Change to Organization scope |
| App not visible | Not shared | Share app with user |
| "No permissions" error | Missing table privileges | Verify Global privileges |
| Buttons appear but don't work | Connection issues | Check connections |
| Works on desktop, not mobile | Cache issue | Clear mobile app cache |
| Worked before, not now | Solution upgrade reset sharing | Re-share the app |
| Works for others, not for me | User-specific role issue | Verify role assignment |

---

## Time-Based Troubleshooting

### If you just installed CoE Starter Kit:
1. Assign security roles (most common issue)
2. Share apps with users
3. Configure environment variables
4. Clear cache

### If you just upgraded:
1. Verify app sharing wasn't reset
2. Check if roles were customized
3. Update connection references
4. Clear cache for all users

### If it suddenly stopped working:
1. Check if role was removed
2. Verify no DLP policy changes
3. Check for expired connections
4. Review recent admin changes

---

## Color-Coded Severity

🟢 **Easy Fix** (< 5 minutes)
- Clearing cache
- Logging out/in
- Verifying role assignment

🟡 **Moderate Fix** (5-15 minutes)
- Assigning security role
- Sharing the app
- Updating connections

🔴 **Complex Fix** (> 15 minutes)
- Modifying DLP policies
- Fixing security role privileges
- Reimporting solutions
- Troubleshooting custom modifications

---

## Support Escalation Path

```
Level 1: Self-Service
├─ Quick Reference Guide
├─ Troubleshooting Guide
└─ FAQ Document
    │
    ▼
Level 2: Community Support
├─ GitHub Issues
├─ Community Forums
└─ Documentation
    │
    ▼
Level 3: Escalation
├─ Product Issues → Microsoft Support
├─ Security Issues → MSRC
└─ CoE Kit Limitations → Feature Request
```

---

**Related Documents:**
- [Quick Reference](./QUICK-REFERENCE-Missing-Buttons.md)
- [FAQ](./FAQ-Environment-Request-App.md)
- [Full Troubleshooting Guide](../../.github/ISSUE_TEMPLATE/troubleshooting-environment-request-admin-app.md)
