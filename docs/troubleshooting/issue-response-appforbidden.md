# Issue Response: AppForbidden Error with CoE Setup and Upgrade Wizard

Thank you for reporting this issue! This is a common permission-related error that occurs when the user attempting to access the CoE Setup and Upgrade Wizard doesn't have the required security role assigned.

## Root Cause

The `AppForbidden` error indicates that your user account does not have one of the required security roles to access the CoE Setup and Upgrade Wizard model-driven app.

## Solution

To resolve this issue, assign one of the following security roles to your user account in the environment where the CoE Starter Kit is installed:

1. **Power Platform Admin SR** (recommended - this role is included in the CoE Core Components solution)
2. **System Administrator** 
3. **System Customizer**

### Steps to Assign the Security Role:

1. Sign in to the [Power Platform admin center](https://admin.powerplatform.microsoft.com/)
2. Navigate to **Environments** and select the environment where the CoE Starter Kit is installed
3. Select **Settings** > **Users + permissions** > **Users**
4. Find and select your user account
5. Select **Manage security roles**
6. Check the **Power Platform Admin SR** role (or System Administrator if preferred)
7. Select **Save**
8. Sign out and sign back in to Power Apps
9. Clear your browser cache if needed
10. Try accessing the CoE Setup and Upgrade Wizard again

## Additional Notes

### Object ID Mismatch

You mentioned that the Object ID in the error (`97559079-a1d1-4882-8c3d-0d5f54b25c68`) is different from your user's GUID (`28ca6c8c-92c6-f011-8543-7c1e528714fd`). This could indicate:

- **Cached credentials** - Try clearing your browser cache and signing in again
- **Service principal or application user** - Less likely for model-driven apps accessed directly by users
- **Different user account** - Verify you're signed in with the correct account

To verify your Azure AD Object ID:
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **Users**
3. Search for your account and check the Object ID

### Environment Variables

While missing environment variables won't cause the `AppForbidden` error, you're correct that they need to be configured for the CoE Starter Kit to function properly. After resolving the permission issue, you'll need to complete the setup by configuring the required environment variables as described in the [setup documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#open-the-setup-wizard).

## More Information

For detailed troubleshooting steps and additional information, please see:
- [Troubleshooting Guide: AppForbidden Error](../troubleshooting/AppForbidden-Setup-Wizard.md)
- [CoE Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)

Please let us know if assigning the security role resolves your issue!
