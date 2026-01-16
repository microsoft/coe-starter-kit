# Security Roles and App Access in CoE Starter Kit

## Overview

The CoE Starter Kit includes three predefined security roles that control access to the model-driven apps and data within the solution:

1. **Power Platform Admin SR** - Full administrative access
2. **Power Platform Maker SR** - Access for makers/contributors
3. **Power Platform User SR** - Read-only/view access

## Security Roles Explained

### Power Platform Admin SR
- **Purpose**: Full administrative access to all CoE apps and data
- **Use Case**: CoE administrators who manage the CoE environment, configure flows, and have full CRUD operations on all tables
- **Assigned to Apps**:
  - Power Platform Admin View
  - CoE Admin Command Center
  - CoE Maker Command Center
  - DLP Impact Analysis
  - Manage Permissions
  - Setup Wizard
  - Environment Request

### Power Platform Maker SR
- **Purpose**: Access for makers and contributors who need to interact with approval workflows and submission processes
- **Use Case**: Makers who submit requests for environments, custom connectors, or chatbots; can view CoE data but with limited modification rights
- **Assigned to Apps**:
  - CoE Admin Command Center
  - CoE Maker Command Center

### Power Platform User SR
- **Purpose**: Read-only access to view CoE data
- **Use Case**: Business users, leadership, or stakeholders who need to view Power Platform inventory and analytics without making changes
- **Permissions**: Global read access to CoE tables, limited write access only for notes and feedback
- **Assigned to Apps**:
  - Power Platform Admin View
  - CoE Admin Command Center  
  - CoE Maker Command Center

## How to Grant Access to CoE Apps

### Granting View-Only Access

To grant **view-only access** to users (e.g., for the Power Platform Admin View app):

1. Navigate to the CoE environment in Power Platform Admin Center
2. Go to **Settings** > **Users + permissions** > **Users**
3. Select the user you want to grant access to
4. Click **Manage roles** or **Manage security roles**
5. Assign the **Power Platform User SR** role
6. Navigate to the app (e.g., Power Platform Admin View)
7. Click **Share** on the app
8. Add the user and select the **Power Platform User SR** role
9. Click **Share**

### Granting Maker Access

To grant **maker/contributor access**:

1. Follow steps 1-3 above
2. Assign the **Power Platform Maker SR** role
3. Share the appropriate app with the **Power Platform Maker SR** role

### Granting Admin Access

To grant **full administrative access**:

1. Follow steps 1-3 above
2. Assign the **Power Platform Admin SR** role
3. Share the appropriate app with the **Power Platform Admin SR** role

## Why Can't I See Certain Security Roles When Sharing Apps?

When you share a model-driven app in Power Platform, **only security roles that are assigned to that app module** will appear in the sharing dialog.

If you don't see the Power Platform User SR or Power Platform Maker SR roles when trying to share an app:

1. The role is not assigned to the app module in the solution
2. The role doesn't exist in your environment (solution may not be fully installed)
3. You need to assign the role to the app module first

## App Module Security Role Assignments

The following table shows which security roles are assigned to each app by default:

| App Name | Admin SR | Maker SR | User SR | System Admin | System Customizer |
|----------|----------|----------|---------|--------------|-------------------|
| Power Platform Admin View | ✓ | ✓ | ✓ | ✓ | ✓ |
| CoE Admin Command Center | ✓ | ✓ | ✓ | ✓ | ✓ |
| CoE Maker Command Center | ✓ | ✓ | ✓ | ✓ | ✓ |
| DLP Impact Analysis | ✓ | | | ✓ | ✓ |
| Manage Permissions | ✓ | | | ✓ | ✓ |
| Setup Wizard | ✓ | | | ✓ | ✓ |
| App Catalog | | | | ✓ | ✓ |

## Custom Security Roles

If you create custom security roles in the CoE environment, they **will not automatically appear** in the app sharing dialog unless you:

1. Manually add them to the app module definition, OR
2. Share the app with users who have that role and manually configure the role assignment

For production use, it's recommended to use the predefined CoE security roles (Admin SR, Maker SR, User SR) rather than creating custom roles, as they are:
- Properly configured with the required privileges
- Maintained and updated with solution upgrades
- Designed to work with the CoE app security model

## Troubleshooting

### I assigned a user a security role but they can't see the app

**Solution**: Make sure you both:
1. Assigned the security role to the user in the environment
2. Shared the app with the user using that security role

Both steps are required for model-driven apps.

### The Power Platform User SR role doesn't appear when sharing

**Solution**: 
- Ensure the CoE Core Components solution is fully installed
- Check that the security role exists in your environment (Settings > Security > Security Roles)
- Verify the role is assigned to the app module (this should be automatic with the updated solution)

### Users see "You do not have permissions" errors

**Solution**: 
- Verify the user has the correct security role assigned
- Check that the role has the necessary table privileges
- Ensure the user has been shared the app with that security role
- Wait a few minutes for permission changes to propagate

## Best Practices

1. **Use the predefined roles**: Use Power Platform Admin SR, Maker SR, and User SR rather than creating custom roles
2. **Principle of least privilege**: Grant users the minimum access level they need (User SR for view-only, Maker SR for contributors, Admin SR only for administrators)
3. **Regular access reviews**: Periodically review who has access to CoE apps and their assigned roles
4. **Document custom changes**: If you modify security roles or create custom ones, document what was changed and why

## References

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Model-Driven App Security](https://learn.microsoft.com/power-apps/maker/model-driven-apps/app-visibility-access)
- [Security Roles and Privileges](https://learn.microsoft.com/power-platform/admin/security-roles-privileges)
