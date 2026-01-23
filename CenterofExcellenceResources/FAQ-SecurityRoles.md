# FAQ: CoE Starter Kit Security Roles

## Overview

This document explains the security roles included with the CoE Starter Kit Core Components and how to grant users access to CoE apps.

---

## Security Roles in Core Components

The CoE Starter Kit Core Components solution includes **three security roles** that control access to CoE apps and data:

### 1. Power Platform Admin SR
**Purpose**: Full administrative access to all CoE Starter Kit features and data.

**Who should have this role**:
- CoE administrators who manage the CoE Starter Kit
- Users who need to configure settings and manage governance policies
- Users who run the CoE Admin Command Center app

**What this role provides**:
- Full CRUD (Create, Read, Update, Delete) access to all CoE data tables
- Access to all CoE admin apps and dashboards
- Ability to configure environment variables and settings
- Access to manage DLP policies, environment requests, and governance features

### 2. Power Platform Maker SR
**Purpose**: Access for Power Platform makers to view their own resources and submit requests.

**Who should have this role**:
- Power Platform makers who want to see their apps, flows, and bots in the CoE
- Users who need to submit environment or DLP policy change requests
- Users who run the CoE Maker Command Center app

**What this role provides**:
- Read access to CoE inventory data (apps, flows, environments, connectors)
- Create/Read/Update access for submission forms (environment requests, DLP requests)
- Access to Maker Command Center and App Catalog
- Ability to provide feedback and submit approvals

### 3. Power Platform User SR
**Purpose**: Read-only access to view published apps in the App Catalog.

**Who should have this role**:
- End users who need to discover and consume apps from the App Catalog
- Users who only need read access to view available resources
- General organization members who want to explore the App Catalog

**What this role provides**:
- Read access to published apps in the App Catalog
- Ability to provide feedback on apps
- Read access to environment and connector information
- No access to administrative or governance features

---

## Common Questions

### Q: Where are the "CoE Viewer" and "CoE Maker Viewer" roles?

**A:** These role names do not exist in the CoE Starter Kit Core Components solution.

If you've seen references to "CoE Viewer" or "CoE Maker Viewer" roles, they may be:
- **Outdated documentation** from very old versions or third-party sources
- **Custom roles** created in specific tenant implementations
- **Misnamed references** to the actual roles listed above

The official security roles shipped with Core Components have been named **"Power Platform Admin SR"**, **"Power Platform Maker SR"**, and **"Power Platform User SR"** since at least April 2023.

### Q: How do I grant users access to CoE apps?

**A:** Follow these steps to share CoE apps with users:

#### Step 1: Assign the appropriate Dataverse security role

1. Navigate to the [Power Platform admin center](https://admin.powerplatform.microsoft.com/)
2. Select **Environments** and choose your CoE environment
3. Select **Settings** > **Users + permissions** > **Users**
4. Select the user you want to grant access to
5. Select **Manage security roles**
6. Assign one of the following roles based on their needs:
   - **Power Platform Admin SR** - For CoE administrators
   - **Power Platform Maker SR** - For makers who need to view and submit requests
   - **Power Platform User SR** - For users who only need App Catalog access

#### Step 2: Share the specific Canvas app

After assigning the security role, you also need to share the specific Canvas app(s):

1. Go to [Power Apps](https://make.powerapps.com/) and select your CoE environment
2. Select **Apps** from the left navigation
3. Find the app you want to share (e.g., "CoE Admin Command Center" or "CoE Maker Command Center")
4. Select the app, then select **Share**
5. Add the users or security groups
6. The security role you assigned in Step 1 will determine what data they can access

**Important**: Both steps are required. The security role controls data access in Dataverse, while app sharing controls access to the Canvas app itself.

### Q: What's the difference between the security roles and app sharing?

**A:** These are two separate but related access controls:

| Access Control | What it controls | How to configure |
|---|---|---|
| **Dataverse Security Role** | Access to data tables in Dataverse (what data users can read/write) | Power Platform admin center > Users > Manage security roles |
| **Canvas App Sharing** | Access to open and run the Canvas app | Power Apps > Apps > Share |

Users need **BOTH**:
- The appropriate security role for data access
- App sharing permission to open the app

If users only have app sharing but no security role, the app will open but show no data or encounter permission errors.

### Q: Can I customize these security roles?

**A:** Yes, but use caution:

✅ **Recommended**:
- Create **custom copies** of these roles with different names
- Modify the copies to match your organization's needs
- Keep the original roles intact for reference and future upgrades

❌ **Not Recommended**:
- Modifying the original "Power Platform Admin SR", "Power Platform Maker SR", or "Power Platform User SR" roles directly
- Deleting these roles from the solution
- Removing these roles can cause upgrade issues when new versions are imported

**Best Practice**: If you need different permission levels, create new custom roles rather than modifying the solution roles.

### Q: I imported the Core Components but don't see these roles

**A:** Try these troubleshooting steps:

1. **Verify the solution imported successfully**:
   - Go to Power Platform admin center > Environments > [Your CoE Environment]
   - Select **Solutions**
   - Confirm "Center of Excellence - Core Components" appears and shows as "Installed"

2. **Check for security roles**:
   - In Power Platform admin center, go to your CoE environment
   - Select **Settings** > **Users + permissions** > **Security roles**
   - Look for roles starting with "Power Platform" (Admin SR, Maker SR, User SR)

3. **Import issues**:
   - If roles are missing, there may have been an import error
   - Check the solution import log for errors
   - Try re-importing the Core Components solution
   - Ensure you have the latest version from [Releases](https://github.com/microsoft/coe-starter-kit/releases)

4. **Environment language**:
   - Ensure your environment has English language pack enabled
   - CoE Starter Kit requires English localization

### Q: Which role should I assign to different user types?

**A:** Use this guide:

| User Type | Recommended Role | Can Access |
|---|---|---|
| **CoE Team/Administrators** | Power Platform Admin SR | All CoE apps, full governance features, admin dashboards |
| **Power Platform Makers** | Power Platform Maker SR | Maker Command Center, App Catalog, ability to submit requests |
| **Business Users/End Users** | Power Platform User SR | App Catalog (read-only), app feedback |
| **Executive/Leadership** | Power Platform Maker SR or custom role | Dashboard access, reports (may need custom role with specific read permissions) |

### Q: Do these roles give users Power Platform Admin permissions?

**A:** No, these are **Dataverse security roles** that only control access to CoE data and apps.

- These roles do **NOT** grant Power Platform Admin or Environment Admin permissions
- They only control access to CoE Starter Kit tables, apps, and flows
- They do not affect access to environments, admin connectors, or tenant settings
- To perform admin operations (like the CoE inventory flows), users still need proper Power Platform Administrator role assigned at the tenant level

See [FAQ-AdminRoleRequirements.md](FAQ-AdminRoleRequirements.md) for more information about Power Platform Administrator requirements.

### Q: Can I use Azure AD groups to assign these roles?

**A:** Yes, this is the recommended approach for enterprise deployments:

1. Create Azure AD security groups for different user types:
   - Example: "CoE-Administrators"
   - Example: "CoE-Makers"
   - Example: "CoE-Users"

2. Add these groups to your CoE environment as group teams:
   - Power Platform admin center > Environments > [CoE Environment]
   - Settings > Users + permissions > Teams
   - Select **Create team** > Team type: **Azure Active Directory Security Group**

3. Assign security roles to the group teams:
   - Select the team
   - Select **Manage security roles**
   - Assign the appropriate CoE security role

4. Add users to Azure AD groups to grant access:
   - Users automatically inherit the assigned security roles
   - Easier to manage at scale
   - Better audit trail

### Q: Why are the role names "SR" instead of full names?

**A:** "SR" stands for **Security Role**. This naming convention:
- Helps distinguish security roles from other Dataverse objects
- Keeps role names concise in the UI
- Is a common practice in Power Platform solution development
- Makes it clear these are role definitions, not users or teams

---

## Role Permissions Summary

For detailed permissions, you can review the role definitions in the solution:

- **File location in repo**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Roles/`
- **Files**:
  - `Power Platform Admin SR.xml` - Full admin permissions
  - `Power Platform Maker SR.xml` - Maker-level permissions
  - `Power Platform User SR.xml` - Read-only user permissions

Each XML file contains the specific table privileges and permission levels (Create, Read, Write, Delete, Append, AppendTo, Share, Assign) for that role.

---

## Upgrading from Previous Versions

If you're upgrading from an older CoE Starter Kit version:

1. **These role names have been stable since April 2023**
   - No role name changes are expected during normal upgrades
   - The solution manages role updates automatically

2. **Existing role assignments are preserved**
   - Users who already have these roles will retain them after upgrade
   - You don't need to reassign roles after upgrading

3. **If you customized the original roles**
   - Your customizations may be overwritten during upgrade
   - Consider using custom role copies instead (see "Can I customize these security roles?" above)

---

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Security roles and privileges](https://learn.microsoft.com/power-platform/admin/security-roles-privileges)
- [Share a canvas app with your organization](https://learn.microsoft.com/power-apps/maker/canvas-apps/share-app)
- [Power Platform Admin Role Requirements](FAQ-AdminRoleRequirements.md)

---

## Need Help?

If you have questions or encounter issues with security roles:

1. Review the official [CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. Check for similar issues in [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
3. Ask questions using the [Question issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
4. Join [CoE Starter Kit Office Hours](https://aka.ms/coeofficehours)

---

**Last Updated**: January 2026  
**Applies to**: CoE Starter Kit Core Components (April 2023 and later)
