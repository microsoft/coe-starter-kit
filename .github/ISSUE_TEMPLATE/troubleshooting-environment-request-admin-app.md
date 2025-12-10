# Troubleshooting: Missing Options in CoE Admin Environment Request App

## Issue Description
Users report that options like "View" and "Approve Request" are not visible in the CoE Admin Environment Request app, even though they can see the environment creation requests in the gallery.

## Common Root Causes

### 1. Security Role Not Assigned
**Symptom**: The buttons are hidden or the app shows limited functionality.

**Solution**:
- Ensure the user has the **Power Platform Admin SR** security role assigned in the CoE environment
- The Maker role (**Power Platform Maker SR**) only has Basic-level privileges, while Admin role has Global-level privileges
- To assign the role:
  1. Navigate to the CoE environment in Power Platform Admin Center
  2. Go to Settings > Users + permissions > Security roles
  3. Find the user and ensure they have "Power Platform Admin SR" assigned

### 2. App Not Shared with User
**Symptom**: User can access the app but sees limited functionality.

**Solution**:
- Verify the app is shared with the user with the correct security role
- Share the "CoE Admin - Environment Request" app:
  1. In Power Apps (make.powerapps.com), find the app
  2. Click Share
  3. Add the user with the "Power Platform Admin SR" security role
  4. Ensure "Data permissions" includes the coe_EnvironmentCreationRequest table

### 3. Missing Table Permissions
**Symptom**: Gallery loads but buttons don't appear.

**Solution**:
- Verify the user has Global-level Read, Write, and Assign privileges on the `coe_EnvironmentCreationRequest` table
- Check in Settings > Security > Security Roles > Power Platform Admin SR
- Required privileges:
  - Read: Global
  - Write: Global
  - Create: Global
  - Delete: Global
  - Assign: Global

### 4. App Not Updated After Solution Import
**Symptom**: After upgrading to version 4.50.6, some features are missing.

**Solution**:
- Clear the Power Apps cache:
  1. Close all Power Apps browser tabs
  2. Clear browser cache (Ctrl+Shift+Delete)
  3. Reopen the app
- If using Power Apps Mobile, uninstall and reinstall the app

### 5. Dataverse Row-Level Security
**Symptom**: Some requests show buttons, others don't.

**Solution**:
- Check if row-level security is preventing access to specific records
- Verify the user is in the correct business unit
- Ensure the security role has organization-level access, not just business unit level

## Verification Steps

1. **Verify Security Role Assignment**:
   ```
   1. Go to Power Platform Admin Center > Environments
   2. Select your CoE environment
   3. Go to Settings > Users + permissions > Users
   4. Find your user and click on their name
   5. Click "Manage Roles" 
   6. Verify "Power Platform Admin SR" is checked
   ```

2. **Verify App Sharing**:
   ```
   1. Go to make.powerapps.com
   2. Select your CoE environment
   3. Go to Apps
   4. Find "CoE Admin - Environment Request"
   5. Click "..." > Share
   6. Verify your user is listed with the correct role
   ```

3. **Verify Table Permissions**:
   ```
   1. Go to make.powerapps.com
   2. Select your CoE environment
   3. Go to Settings > Security > Security Roles
   4. Open "Power Platform Admin SR"
   5. Go to Custom Entities tab
   6. Find "Environment Creation Request" (coe_EnvironmentCreationRequest)
   7. Verify all circles are filled (Global level access)
   ```

## Known Issues

### Version 4.50.6 Specific Issues
- If you upgraded from an earlier version, you may need to:
  1. Reassign security roles to users
  2. Re-share the apps
  3. Clear the canvas app cache

## Additional Resources

- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [CoE Starter Kit Security Roles](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#security-roles)
- [Troubleshooting CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/faq)

## Still Having Issues?

If you've verified all the above and still experience issues:

1. Check that the CoE environment has the English language pack enabled (CoE Starter Kit only supports English)
2. Verify you're using a supported license (not a Trial license)
3. Review the [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
4. Create a new issue with:
   - Exact steps to reproduce
   - Screenshots showing the issue
   - Your CoE Starter Kit version
   - Whether this is a fresh install or an upgrade
   - Security roles assigned to the user
