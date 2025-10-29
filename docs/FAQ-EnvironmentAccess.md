# FAQ: CoE Environment Access Configuration

## Environment Security Groups and Maker Access

### Question: How can I grant makers access to CoE apps when a security group is configured on the environment?

#### Background

When you configure a security group on a Power Platform environment, it restricts who can access that environment and its resources. This is a recommended security practice for production CoE environments, but it can create access challenges for makers who need to use CoE applications like the **Maker Command Center**.

#### The Problem

After adding a security group to your CoE environment (as recommended by Microsoft support), you may encounter the following situation:

1. **Makers can create cloud flows** in the CoE environment (if they're in the security group)
2. **Makers cannot access CoE apps** like the Maker Command Center
3. Error message appears: "The system did not accept your logon. Perhaps the specified user (ID = Try this action again..." (Access Error)

#### Root Cause

The issue occurs because of how Power Platform security works with environments that have security groups:

- **Environment Access**: Controlled by the security group membership
- **App Access**: Requires both environment access AND explicit app permissions (sharing)

When a security group is configured, users must be:
1. **Members of the security group** (to access the environment)
2. **Explicitly granted app permissions** (to run specific apps)

#### Solution

To grant makers access to CoE apps when using security groups, you need to configure **two levels of access**:

##### Step 1: Environment Access (Security Group)

Ensure makers are members of the security group associated with the CoE environment:

1. Go to **Azure Active Directory** (now Microsoft Entra ID)
2. Navigate to **Groups**
3. Find the security group assigned to your CoE environment (e.g., "Ticorp_adm_COE")
4. Add the makers who need access to CoE apps as members

**OR**

Create a tiered security approach:
- **Admin Security Group**: For CoE administrators who can modify solutions and flows
- **Maker Security Group**: For makers who only need to access CoE apps (read-only or limited access)
- Add both groups to the environment security configuration

##### Step 2: App Sharing and Permissions

After ensuring environment access, you must **share the CoE apps** with makers:

1. Go to **Power Apps** (make.powerapps.com)
2. Select your **CoE environment**
3. Navigate to **Apps**
4. Find the **Maker Command Center** app (or other CoE apps)
5. Select **Share** (or the three dots menu > Share)
6. Add individual users or security groups:
   - Enter user emails or security group name
   - Assign appropriate role:
     - **User**: Can run the app and view their own data
     - **Co-owner**: Can run the app, view all data, and modify the app (not recommended for general makers)
7. Click **Share**

##### Step 3: Dataverse Security Roles

Ensure makers have appropriate Dataverse security roles to access CoE data:

1. Go to **Power Platform Admin Center** (admin.powerplatform.microsoft.com)
2. Select **Environments** > Your CoE Environment
3. Go to **Settings** > **Users + permissions** > **Security roles**
4. Assign makers one of the following roles:
   - **Basic User**: Minimum access to use apps
   - **CoE Maker Security Role**: Custom role for makers (if created)
   - **Environment Maker**: Allows creating resources (flows, apps) in the environment

**Recommended Approach**: Create a custom security role specifically for CoE app users that provides:
- Read access to necessary CoE tables (Admin tables, environment data, etc.)
- Execute access to cloud flows they need to trigger
- Limited or no write access to protect CoE data integrity

#### Best Practices

1. **Separate Security Groups**:
   - Create one security group for CoE administrators
   - Create another for makers who only need app access
   - Add both to the environment security configuration

2. **Share Apps with Security Groups**:
   - Instead of sharing apps with individual users
   - Share with the "CoE Makers" security group
   - Easier to manage as your user base grows

3. **Use Custom Security Roles**:
   - Create a custom Dataverse security role for makers
   - Grant only the minimum required permissions
   - Assign this role to the makers security group

4. **Document Your Configuration**:
   - Keep a record of which security groups have access
   - Document which apps are shared and with whom
   - Maintain a list of security roles and their purposes

5. **Regular Access Reviews**:
   - Periodically review security group membership
   - Remove users who no longer need access
   - Audit app sharing to ensure principle of least privilege

#### Alternative Approach: Separate Environments

If you want to keep your CoE environment highly restricted while still providing maker tools, consider:

1. **Core CoE Environment**: Restricted with tight security group (admins only)
   - Contains all data collection flows
   - Has admin-only apps
   - Syncs data to Dataverse

2. **Maker Experience Environment**: More open access
   - Create a separate environment for makers
   - Share read-only views of CoE data (via virtual tables or dataflows)
   - Deploy maker-focused apps here
   - No security group restriction, or a broader security group

This approach maintains security on your core CoE data while providing makers with the tools they need.

#### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "The system did not accept your logon" | User not in environment security group | Add user to the security group associated with the environment |
| "You don't have permission to view this app" | App not shared with user | Share the app with the user or their security group |
| "Insufficient permissions" when using app | Missing Dataverse security role | Assign appropriate security role (Basic User, Environment Maker, or custom role) |
| "Access denied" to specific data | Security role doesn't grant table access | Update security role to include read access to required tables |

#### Additional Resources

- [Power Platform Environments Overview](https://learn.microsoft.com/power-platform/admin/environments-overview)
- [Security groups and licensing](https://learn.microsoft.com/power-platform/admin/control-user-access)
- [Share a canvas app](https://learn.microsoft.com/power-apps/maker/canvas-apps/share-app)
- [Security roles and privileges](https://learn.microsoft.com/power-platform/admin/security-roles-privileges)
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

#### Related Questions

- **Q: Should I use a security group for my CoE environment?**
  - A: Yes, for production CoE environments, using a security group is a recommended security practice to control who can access sensitive governance data.

- **Q: Can I have different access levels for different makers?**
  - A: Yes, use multiple security groups combined with custom security roles to create tiered access levels.

- **Q: How do I know which security roles to assign?**
  - A: Start with "Basic User" for makers who only need to use apps. Add "Environment Maker" if they need to create resources. Create custom roles for specific CoE data access needs.

- **Q: What if I want some makers to only view data, not modify it?**
  - A: Share apps with "User" role (not "Co-owner") and assign a custom security role in Dataverse with only read permissions to CoE tables.

---

**Last Updated**: October 2025  
**Applies To**: CoE Starter Kit v4.49.2 and later
