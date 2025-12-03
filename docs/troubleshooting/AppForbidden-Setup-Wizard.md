# Troubleshooting AppForbidden Error with CoE Setup and Upgrade Wizard

## Issue Description

When attempting to access the **CoE Setup and Upgrade Wizard** model-driven app, users may encounter an `AppForbidden` error:

```
Error Code: AppForbidden
Session Id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Activity Id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

The user with object id 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' does not have permission to access this.
```

## Root Cause

This error occurs when the user attempting to access the CoE Setup and Upgrade Wizard does not have the required security role(s) assigned in the environment where the CoE Starter Kit is installed.

The CoE Setup and Upgrade Wizard app requires one of the following security roles:

1. **Power Platform Admin SR** (Custom security role included in the CoE Core Components solution)
2. **System Administrator** (Dataverse system role)
3. **System Customizer** (Dataverse system role)

## Resolution Steps

### Option 1: Assign Power Platform Admin SR Role (Recommended)

The Power Platform Admin SR security role is specifically designed for the CoE Starter Kit and provides the appropriate permissions.

1. Sign in to the [Power Platform admin center](https://admin.powerplatform.microsoft.com/)
2. Navigate to **Environments** and select the environment where the CoE Starter Kit is installed
3. Select **Settings** > **Users + permissions** > **Users**
4. Select the user who needs access to the Setup Wizard
5. Select **Manage security roles**
6. Check the **Power Platform Admin SR** role
7. Select **Save**

### Option 2: Assign System Administrator Role

If you prefer to use a Dataverse system role:

1. Follow steps 1-4 from Option 1
2. At step 5, check the **System Administrator** role instead
3. Select **Save**

### Option 3: Assign System Customizer Role

For users who don't need full System Administrator privileges:

1. Follow steps 1-4 from Option 1
2. At step 5, check the **System Customizer** role instead
3. Select **Save**

## Important Notes

### Object ID Mismatch

If the Object ID in the error message differs from your user's Azure AD Object ID, this may indicate:

- **Application User or Service Principal**: The app might be trying to access resources using an application identity rather than your user identity. This is typically not a normal scenario for accessing model-driven apps.
- **Impersonation**: Another application or service might be attempting to impersonate a different user.
- **Cached Credentials**: Clear your browser cache and try signing in again.

To verify your Azure AD Object ID:

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **Users**
3. Search for your user account
4. The Object ID is displayed in the user's profile

### Environment Variables

The error message indicates that environment variables were not configured. While missing environment variables won't cause the `AppForbidden` error, they are required for the CoE Starter Kit to function properly. After resolving the permission issue, complete the setup by configuring the required environment variables as described in the [setup documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components).

### Prerequisites

Before accessing the CoE Setup and Upgrade Wizard, ensure:

1. The **CenterofExcellenceCoreComponents** solution is installed and configured
2. The **Creator Kit** is installed (as it's a dependency)
3. Your user account has been assigned one of the required security roles
4. You have the appropriate Power Platform license (Power Apps Per User or Per App, or included in Microsoft 365)

## Additional Resources

- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
- [Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Assign security roles in Power Platform](https://learn.microsoft.com/en-us/power-platform/admin/assign-security-roles)
- [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

## Related Issues

If you continue to experience issues after assigning the appropriate security role, consider the following:

- Ensure the security role was properly assigned and wait a few minutes for the permission changes to propagate
- Sign out and sign back in to refresh your authentication tokens
- Clear your browser cache and cookies
- Try accessing the app in an incognito/private browser window
- Verify that the CoE Core Components solution was imported successfully without errors
- Check that the model-driven app is published and active

If the issue persists after trying these steps, please [open an issue on GitHub](https://github.com/microsoft/coe-starter-kit/issues/new/choose) with:

- The exact error message and IDs
- Your user's Azure AD Object ID
- The security roles currently assigned to your user
- The version of the CoE Starter Kit you're using
- Screenshots of the error (if possible)
