# Issue Response: Missing Options in CoE Admin Environment Request App

## Issue Summary
User reports that the "View" and "Approve Request" buttons are not visible in the CoE Admin Environment Request app (version 4.50.6), even though environment creation requests are displayed in the gallery.

## Root Cause Analysis
Based on the screenshot and issue description, this is a **security role and permissions** issue. The missing buttons indicate that:

1. The user likely has the **Power Platform Maker SR** role instead of the **Power Platform Admin SR** role
2. The Maker role only has **Basic-level** privileges on the `coe_EnvironmentCreationRequest` table
3. The buttons in the app have conditional visibility based on user permissions
4. Without Global-level privileges, the approve/view buttons don't render

## Solution

### Step 1: Verify and Assign Correct Security Role

The user must have the **Power Platform Admin SR** security role (not just Maker SR).

**To assign the role:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Navigate to **Environments** and select your CoE environment
3. Go to **Settings** > **Users + permissions** > **Users**
4. Find the user and click on their name
5. Click **Manage Roles**
6. Ensure **"Power Platform Admin SR"** is checked
7. Click **Save**

### Step 2: Verify App Sharing

The app must be shared with the user with the correct security role.

**To verify/share the app:**
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Select your CoE environment
3. Navigate to **Apps**
4. Find **"CoE Admin - Environment Request"**
5. Click **"..."** > **Share**
6. Add the user (if not listed) with the **"Power Platform Admin SR"** role
7. Ensure **Data permissions** includes access to the `coe_EnvironmentCreationRequest` table

### Step 3: Verify Table Permissions

The Admin SR role should have Global-level access to the Environment Creation Request table.

**To verify:**
1. In make.powerapps.com, select your CoE environment
2. Go to **Settings** > **Security** > **Security Roles**
3. Open **"Power Platform Admin SR"**
4. Navigate to the **Custom Entities** tab
5. Find **"Environment Creation Request"** (`coe_EnvironmentCreationRequest`)
6. Verify all privilege circles are filled (indicating Global-level access):
   - Read: Global
   - Write: Global
   - Create: Global
   - Delete: Global
   - Assign: Global
   - Append: Global
   - Append To: Global

### Step 4: Clear App Cache

After making permission changes, clear the cache to ensure the app loads with updated permissions.

**To clear cache:**
1. Close all Power Apps browser tabs
2. Clear browser cache (Ctrl+Shift+Delete or Cmd+Shift+Delete)
3. Close and reopen your browser
4. Navigate back to the CoE Admin Environment Request app

## Why This Happens

The CoE Starter Kit uses Dataverse security roles with different privilege levels:

| Security Role | Privilege Level | Purpose | Can Approve Requests? |
|---------------|----------------|---------|---------------------|
| Power Platform Maker SR | Basic | Makers can create requests for their own environments | ❌ No |
| Power Platform Admin SR | Global | Admins can view and approve all requests | ✅ Yes |

The conditional visibility logic in the canvas app checks the user's permissions before rendering action buttons. If you only have Basic-level access (Maker role), the app correctly hides the approve/view buttons because you don't have permission to perform those actions on other users' records.

## Verification Steps

After completing the above steps, verify the fix:

1. Log out of Power Apps
2. Log back in
3. Open the **CoE Admin - Environment Request** app
4. You should now see the **View** and **Approve Request** buttons for environment creation requests

## Common Mistakes

❌ **Assigning only the Maker role** - This provides Basic-level access, which is insufficient for admin functions

❌ **Not clearing the cache** - The app may cache permissions, showing old behavior even after role assignment

❌ **Forgetting to share the app** - Role assignment alone isn't enough; the app must also be shared

❌ **Using a Trial license** - Some admin functions require full licenses

## Additional Resources

- [CoE Starter Kit Setup - Security Roles](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#security-roles)
- [CoE Admin Command Center](https://learn.microsoft.com/power-platform/guidance/coe/core-components#coe-admin-command-center)
- [Security Roles in Dataverse](https://learn.microsoft.com/power-platform/admin/security-roles-privileges)

## Related Issues

- Check for similar issues: [Search "environment request" issues](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+environment+request)

## Response Template for Issue

```markdown
Thank you for reporting this issue! 

This appears to be a **security role permissions** issue. The "View" and "Approve Request" buttons are only visible to users with the **Power Platform Admin SR** security role, which has Global-level privileges on the Environment Creation Request table.

**Quick Fix:**

1. **Verify Security Role Assignment:**
   - Go to Power Platform Admin Center > Environments > [Your CoE Environment]
   - Settings > Users + permissions > Users
   - Find your user > Manage Roles
   - Ensure **"Power Platform Admin SR"** is checked (not just Maker SR)

2. **Verify App Sharing:**
   - In make.powerapps.com, find the "CoE Admin - Environment Request" app
   - Share it with yourself using the "Power Platform Admin SR" role

3. **Clear Cache:**
   - Close all Power Apps tabs
   - Clear browser cache (Ctrl+Shift+Delete)
   - Reopen the app

**Why this happens:**
The Maker role only has Basic-level privileges, which limits users to viewing their own requests. The Admin role has Global-level privileges, enabling the approve/view functionality for all requests.

**Detailed Instructions:**
See our [troubleshooting guide](../troubleshooting-environment-request-admin-app.md) for complete step-by-step instructions.

Please let us know if this resolves your issue! If you continue to experience problems after verifying these settings, please provide:
- A screenshot of the security roles assigned to your user
- Confirmation that you've cleared the cache
- Whether this is a fresh install or an upgrade

---

**Note:** The CoE Starter Kit is provided as a best-effort, unsupported solution. For general Power Platform support, please use the [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1).
```

## Next Steps

1. Post the response template to the issue
2. Label the issue as `question` and `documentation`
3. Monitor for user response
4. If confirmed fixed, close the issue with the `fixed` label
5. If the issue persists, request additional diagnostic information

---

*This response is based on CoE Starter Kit version 4.50.6 and may need updates for future versions.*
