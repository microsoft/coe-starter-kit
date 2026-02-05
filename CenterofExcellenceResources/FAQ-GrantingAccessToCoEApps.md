# FAQ: Granting View-Only Access to CoE Starter Kit Model-Driven Apps

## Overview

This document explains how to grant view-only (read-only) access to the CoE Starter Kit model-driven apps, such as the **Power Platform Admin View** app.

---

## Common Questions

### Q: Why don't I see view-only security roles when I try to share a model-driven app?

**A:** This is expected behavior by design in Dataverse.

When you click **Share** on a model-driven app, the dialog **only displays security roles that have "Customize" or "Admin-level" privileges**. This is a platform limitation, not a CoE Starter Kit issue.

**What you'll see in the Share dialog:**
- ✅ Power Platform Admin SR
- ✅ System Administrator
- ✅ System Customizer
- ❌ Power Platform User SR (won't appear)
- ❌ Power Platform Maker SR (won't appear)
- ❌ Custom read-only roles (won't appear)

This behavior has been confirmed in Microsoft's official guidance and is consistent across all Dataverse model-driven apps.

---

### Q: How do I grant view-only access to CoE Starter Kit apps?

**A:** You must grant access at the **security role level**, not through the app Share dialog.

#### ✅ Correct Approach: Direct Security Role Assignment

Follow these steps to grant view-only access:

1. **Identify or Create a Read-Only Security Role**
   - Use the existing **Power Platform User SR** role (included in the Core Components solution)
   - OR create a custom security role with Organization-level **Read** access to the required tables

2. **Assign the Security Role to Users**
   - Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
   - Navigate to your CoE environment
   - Go to **Settings** → **Users + permissions** → **Users**
   - Select the user(s) you want to grant access to
   - Click **Manage security roles**
   - Check the **Power Platform User SR** role (or your custom read-only role)
   - Click **Save**

3. **Grant App Access (if needed)**
   - In some environments, you may also need to ensure users have access to the app itself
   - Go to [Power Apps](https://make.powerapps.com)
   - Navigate to your CoE environment
   - Open the app (e.g., **Power Platform Admin View**)
   - Click **Share**
   - Add the users with the **Power Platform User SR** role

**Important:** Do NOT try to assign read-only roles through the Share dialog—they won't appear there. Use the Admin Center to assign security roles directly to users.

---

### Q: What security roles are included in the CoE Starter Kit?

**A:** The CoE Starter Kit includes three primary security roles in the Core Components solution:

| Security Role | Purpose | Access Level |
|--------------|---------|--------------|
| **Power Platform Admin SR** | Full admin access | Full control over all CoE data and functionality |
| **Power Platform Maker SR** | Maker-level access | Read access to most data, create/edit some records |
| **Power Platform User SR** | View-only access | Read-only access to dashboards and reports |

**For view-only access, use Power Platform User SR.**

---

### Q: What permissions does the Power Platform User SR role have?

**A:** The **Power Platform User SR** role provides:

✅ **Read access** to CoE tables (Organization level)  
✅ **View dashboards** and model-driven apps  
✅ **Run reports** and view Power BI analytics  
❌ **Cannot create** new records  
❌ **Cannot edit** existing records  
❌ **Cannot delete** records  
❌ **Cannot manage** flows or other CoE functionality  

This role is designed for stakeholders who need to **view** CoE data and reports but should not modify configurations or governance settings.

---

### Q: Can I create a custom read-only security role?

**A:** Yes, you can create your own custom security role with read-only access.

#### Steps to Create a Custom Read-Only Role:

1. **Navigate to Your CoE Environment**
   - Go to [Power Apps](https://make.powerapps.com)
   - Select your CoE environment

2. **Open Security Roles**
   - Go to **Settings** (gear icon) → **Advanced settings**
   - Navigate to **Settings** → **Security** → **Security Roles**
   - OR use the Power Platform Admin Center: **Settings** → **Users + permissions** → **Security roles**

3. **Create a New Role**
   - Click **New**
   - Name it descriptively (e.g., "CoE Read-Only User")

4. **Configure Permissions**
   - For each CoE table (tables starting with `admin_`):
     - Set **Read** to **Organization** level (green circle)
     - Set all other permissions (Create, Write, Delete, Append, Assign, Share) to **None**
   - Save the security role

5. **Assign to Users**
   - Follow the same steps as described above to assign this custom role to users

**Note:** The included **Power Platform User SR** role is already configured with appropriate read-only permissions, so creating a custom role is usually not necessary.

---

### Q: I assigned the security role, but users still can't see the app. Why?

**A:** There are a few common reasons:

#### Possible Causes and Solutions:

1. **Users Haven't Been Added to the Environment**
   - **Solution:** Ensure users are added to the CoE environment in the Power Platform Admin Center

2. **Security Role Assignment Hasn't Propagated**
   - **Solution:** Wait 5-10 minutes for changes to propagate, or ask users to log out and log back in

3. **App Access Not Granted (in some cases)**
   - **Solution:** While not always required, try explicitly sharing the app with the users (even though the role won't show in the dropdown)

4. **Users Don't Have Licenses**
   - **Solution:** Ensure users have appropriate Power Apps licenses (per-app, per-user, or included in Microsoft 365)

5. **Environment Security Group Restrictions**
   - **Solution:** Check if the environment has a security group restriction and ensure users are members

---

### Q: Can users with view-only access see sensitive data?

**A:** Yes, users with the **Power Platform User SR** role can see most data in the CoE apps.

#### What Read-Only Users Can See:

- List of all environments in the tenant
- List of all apps, flows, and connectors
- Maker information
- Usage statistics
- Compliance and governance data

#### Security Considerations:

If you need to restrict access to specific data:

1. **Use Field-Level Security**
   - Configure field-level security to hide sensitive columns

2. **Use Record-Level Security**
   - Modify the security role to use "User" or "Business Unit" level instead of "Organization" level for specific tables

3. **Create a More Restrictive Custom Role**
   - Build a custom security role with access to only specific tables or fields

4. **Consider Using Power BI Instead**
   - Share Power BI reports with filtered data instead of granting direct app access

---

### Q: How do I remove access from a user?

**A:** Remove the security role assignment from the user.

#### Steps to Remove Access:

1. **Go to Power Platform Admin Center**
   - Navigate to [admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)

2. **Open Your CoE Environment**
   - Select your CoE environment
   - Go to **Settings** → **Users + permissions** → **Users**

3. **Find the User**
   - Search for and select the user

4. **Remove Security Role**
   - Click **Manage security roles**
   - Uncheck **Power Platform User SR** (or your custom role)
   - Click **Save**

The user will immediately lose access to the CoE apps.

---

### Q: Can I use security groups to manage access?

**A:** Yes, you can use Azure AD security groups with environment security group restrictions, but this is separate from security role assignment.

#### Using Security Groups:

1. **Environment-Level Access Control**
   - Environment security groups control who can access the environment at all
   - Configure in Power Platform Admin Center → Environment → Settings → Security → Security groups

2. **Security Role Assignment**
   - After users can access the environment (via security group), they still need security roles
   - Security roles must be assigned individually or via team-based security

**Best Practice:** Use environment security groups for broad access control, then use security roles for granular permissions.

---

### Q: What's the difference between sharing a canvas app vs. a model-driven app?

**A:** Canvas apps and model-driven apps use different sharing mechanisms.

| Aspect | Canvas App | Model-Driven App |
|--------|-----------|------------------|
| **Sharing Method** | Share dialog grants direct access | Share dialog only configures app visibility |
| **Permission Model** | App-level permissions | Security role-based permissions |
| **Who Can Access** | Explicitly shared users/groups | Anyone with appropriate security role |
| **Data Access** | Determined by connection ownership | Determined by security role on tables |

**For CoE Model-Driven Apps:**
- Sharing via the dialog is insufficient
- Users MUST have an appropriate security role
- The Power Platform User SR role provides read-only access

---

## Recommended Patterns

### For Small Teams (< 20 Users)

1. **Use the Power Platform User SR role**
2. **Assign directly to individual users** in the Power Platform Admin Center
3. **Document who has access** in a shared location

### For Medium Teams (20-100 Users)

1. **Use the Power Platform User SR role**
2. **Create a Dataverse team** mapped to an Azure AD security group
3. **Assign the security role to the team**
4. **Manage membership** via the Azure AD group

### For Large Organizations (100+ Users)

1. **Create multiple custom security roles** based on different stakeholder needs
   - CoE Leadership View (high-level dashboards only)
   - CoE Analyst View (detailed data access)
   - CoE Auditor View (compliance-focused data)
2. **Use Dataverse teams** mapped to Azure AD security groups
3. **Implement field-level and record-level security** to restrict sensitive data
4. **Consider Power BI embedded reports** for read-only analytics instead of full app access

---

## Troubleshooting

### Issue: "You do not have permission to view this app"

**Cause:** User doesn't have an appropriate security role

**Solution:**
1. Verify the user has been assigned the Power Platform User SR role
2. Check that the role assignment has propagated (wait 5-10 minutes)
3. Ask the user to log out and log back in

### Issue: "Insufficient permissions to access data"

**Cause:** Security role doesn't have read access to required tables

**Solution:**
1. Verify the security role has Organization-level Read access to CoE tables (tables starting with `admin_`)
2. Check for field-level security restrictions
3. Ensure the user's license supports Dataverse access

### Issue: Users see "No data available" in dashboards

**Cause:** Either no data has been collected yet, or record-level security is restricting access

**Solution:**
1. Verify the CoE inventory flows have run successfully
2. Check if the user's security role uses "Organization" level (not "User" or "Business Unit" level)
3. Run the initial sync if this is a new installation

---

## Best Practices

### Security

✅ **Use dedicated security roles** - Don't grant users System Administrator just to view CoE data  
✅ **Follow least privilege** - Grant only the minimum access needed  
✅ **Regular access reviews** - Quarterly review who has access and remove inactive users  
✅ **Audit access changes** - Monitor security role assignments in the audit log  

### User Experience

✅ **Provide training** - Help users understand how to navigate the CoE apps  
✅ **Create user guides** - Document which reports and dashboards are available  
✅ **Set expectations** - Explain that data is read-only and when it refreshes  
✅ **Gather feedback** - Regularly ask users what data they need  

### Governance

✅ **Document your access model** - Maintain a record of who should have access and why  
✅ **Automate onboarding/offboarding** - Use Azure AD groups for team-based access  
✅ **Monitor usage** - Track who is using the apps and which features they access  
✅ **Plan for growth** - Design your access model to scale as adoption increases  

---

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Security Roles in Dataverse](https://learn.microsoft.com/power-platform/admin/security-roles-privileges)
- [Share a Model-Driven App](https://learn.microsoft.com/power-apps/maker/model-driven-apps/share-model-driven-app)
- [Dataverse Security Concepts](https://learn.microsoft.com/power-platform/admin/wp-security-cds)
- [Field-Level Security](https://learn.microsoft.com/power-platform/admin/field-level-security)

---

## Need Help?

If you have questions about granting access to CoE apps:

1. Review the official [CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. Ask questions in [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) using the Question template
3. Engage with the community in [Power Apps Community forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
4. Join [CoE Starter Kit Office Hours](https://aka.ms/coeofficehours)

---

**Applies to:** CoE Starter Kit Core Components (All versions)  
**Last Updated:** 2026-01-30
