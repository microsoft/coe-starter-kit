# GitHub Issue Response

## Issue: Missing Options in CoE Admin Environment Request App

Thank you for reporting this issue! Based on your screenshot and description, this appears to be a **security role permissions** issue rather than a bug in the solution.

### 🔍 Root Cause

The "View" and "Approve Request" buttons are only visible to users who have the **Power Platform Admin SR** security role with **Global-level** privileges on the Environment Creation Request table.

**Security Role Comparison:**

| Security Role | Privilege Level | Can See Approve/View Buttons? |
|---------------|----------------|------------------------------|
| Power Platform Maker SR | Basic (own records only) | ❌ No |
| Power Platform Admin SR | Global (all records) | ✅ Yes |

The app uses conditional visibility to hide these buttons from users without appropriate permissions, preventing unauthorized actions.

---

## ⚡ Quick Fix

Follow these three steps to resolve the issue:

### 1. Assign the Admin Security Role

**Steps:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Navigate to **Environments** → Select your **CoE environment**
3. Go to **Settings** → **Users + permissions** → **Users**
4. Find your user → Click **Manage Roles**
5. Ensure **"Power Platform Admin SR"** is checked
6. Click **Save**

### 2. Verify App Sharing

**Steps:**
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Select your **CoE environment**
3. Navigate to **Apps**
4. Find **"CoE Admin - Environment Request"**
5. Click **"..."** → **Share**
6. Add yourself with the **"Power Platform Admin SR"** role
7. Click **Share**

### 3. Clear Your Browser Cache

**Steps:**
1. Close **all** Power Apps browser tabs
2. Press **Ctrl+Shift+Delete** (or **Cmd+Shift+Delete** on Mac)
3. Select **"All time"** → Check **"Cached images and files"**
4. Click **Clear data**
5. Restart your browser
6. Navigate back to the app

---

## ✅ Verification

After completing the above steps, you should see the "View" and "Approve Request" buttons in the gallery. If you still don't see them, please verify:

- [ ] You have the **Power Platform Admin SR** role (not just Maker)
- [ ] The app is shared with you using the Admin SR role
- [ ] You've **completely** cleared your browser cache
- [ ] You've logged out and logged back in
- [ ] You're accessing the correct CoE environment

---

## 📚 Additional Resources

We've created comprehensive documentation to help with this and similar issues:

1. **[Quick Reference Guide](../docs/coe-knowledge/QUICK-REFERENCE-Missing-Buttons.md)** - 5-minute fix with checklist
2. **[Full Troubleshooting Guide](../.github/ISSUE_TEMPLATE/troubleshooting-environment-request-admin-app.md)** - Detailed step-by-step instructions
3. **[FAQ](../docs/coe-knowledge/FAQ-Environment-Request-App.md)** - 30+ common questions and answers
4. **[Security Roles Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#security-roles)** - Official Microsoft docs

---

## 💡 Why This Happens

This is **by design**, not a bug. Here's why:

1. **Security by Design**: The CoE Starter Kit uses Dataverse security roles to control access
2. **Role-Based Access**: Different roles have different privilege levels (Basic vs Global)
3. **Conditional Visibility**: The app shows/hides buttons based on what actions you're permitted to perform
4. **Separation of Duties**: Makers can create requests; admins can approve them

If every user could see the approve buttons, they could attempt actions they're not authorized to perform, resulting in permission errors.

---

## 🤝 Need More Help?

If this doesn't resolve your issue, please provide:

1. ✅ Screenshot of your assigned security roles
2. ✅ Confirmation that you've cleared cache and restarted browser
3. ✅ Whether this is a fresh install or an upgrade from an earlier version
4. ✅ Any error messages you're seeing

---

**Note:** The CoE Starter Kit is provided as a best-effort, unsupported solution. For general Power Platform support unrelated to the CoE Starter Kit, please use the [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1).

---

### Labels
- `question`
- `documentation`
- `core`
- `security-roles`

### Related
- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Dataverse Security Roles](https://learn.microsoft.com/power-platform/admin/security-roles-privileges)
