# Response to Issue: CoE Environment Access Configuration for Makers

## Issue Summary

User reports that after adding a security group to the CoE environment (as recommended by Microsoft support in ticket #10305), creators can no longer access the CoE Maker Command Center app. The security group "Ticorp_adm_COE" has been configured on the environment.

## Root Cause

When a security group is configured on a Power Platform environment, it implements a two-tier security model:

1. **Environment Access** - Controlled by security group membership
2. **App Access** - Controlled by app sharing permissions

The issue occurs because makers need BOTH:
- Membership in the environment's security group (to enter the environment)
- Explicit app sharing permissions (to run specific apps)

Simply being in the security group grants environment access but does NOT automatically grant permission to use apps in that environment.

## Recommended Solution

### Option 1: Add Makers to Security Group + Share Apps (Recommended)

This is the most straightforward approach for maintaining environment security while granting app access.

**Step 1: Add Makers to Security Group**
1. Go to Azure Portal (portal.azure.com)
2. Navigate to Azure Active Directory > Groups
3. Find the security group "Ticorp_adm_COE"
4. Add the makers as members

**Step 2: Share the Maker Command Center App**
1. Go to make.powerapps.com
2. Select your CoE environment
3. Navigate to Apps
4. Find "CoE Maker Command Center" or "Admin - Maker Command Center"
5. Click Share (or three dots menu > Share)
6. Add makers individually or add a security group with **User** role (not Co-owner)
7. Click Share

**Step 3: Assign Dataverse Security Role**
1. Go to Power Platform Admin Center (admin.powerplatform.microsoft.com)
2. Select Environments > Your CoE Environment
3. Settings > Users + permissions > Security roles
4. Assign makers the **Basic User** role (or a custom CoE Maker role)

### Option 2: Create Separate Security Groups (Better for Scale)

For better security and easier management:

**Step 1: Create Two Security Groups in Azure AD**
- **CoE-Admins**: For CoE administrators who manage solutions and flows
- **CoE-Makers**: For makers who only need to use CoE apps

**Step 2: Configure Environment Security**
1. In Power Platform Admin Center
2. Go to your CoE environment > Settings > Security groups
3. Add BOTH security groups to the environment

**Step 3: Add Users to Appropriate Groups**
- Add administrators to CoE-Admins
- Add makers to CoE-Makers

**Step 4: Share Apps with Groups**
- Share admin apps with CoE-Admins group (as Co-owner)
- Share maker apps (like Maker Command Center) with CoE-Makers group (as User)

**Step 5: Assign Security Roles**
- Create custom Dataverse security roles:
  - **CoE Administrator Role**: Full access to all CoE tables
  - **CoE Maker Role**: Read access to necessary tables only
- Assign these roles to the respective security groups

### Option 3: Separate Environments (Advanced)

For organizations requiring strict security separation:

1. **Core CoE Environment**: Keep highly restricted (current setup)
   - Only administrators in security group
   - All data collection happens here

2. **Maker Portal Environment**: More accessible
   - Broader or no security group
   - Deploy maker-focused apps here
   - Use Dataverse virtual tables or Power BI to expose read-only CoE data

## Step-by-Step Guide for Immediate Fix

If you need to quickly restore access for makers:

```
1. Add maker users to "Ticorp_adm_COE" security group in Azure AD
   (This grants environment access)

2. Share the Maker Command Center app with those users
   (This grants app usage permission)

3. Assign "Basic User" security role in Dataverse
   (This grants data access)
```

## Best Practices Going Forward

1. **Use Security Groups for Sharing**: Instead of sharing apps with individual users, share with security groups for easier management

2. **Principle of Least Privilege**: 
   - Makers should have User role on apps (not Co-owner)
   - Makers should have read-only access to most CoE data
   - Only admins should have write access

3. **Custom Security Roles**: Create Dataverse security roles specifically for:
   - CoE Administrators (full access)
   - CoE Makers (read access to necessary tables)
   - CoE Viewers (read-only access to reports)

4. **Documentation**: Document your environment's security configuration for future reference

5. **Regular Reviews**: Periodically review security group membership and app sharing to ensure proper access

## Common Errors and Solutions

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "The system did not accept your logon" | Not in environment security group | Add user to security group |
| "You don't have permission to view this app" | App not shared | Share app with user or their group |
| "Insufficient permissions" | Missing Dataverse role | Assign Basic User or custom role |

## Additional Resources

For comprehensive documentation on this topic, see:
- **[FAQ: Environment Access Configuration](FAQ-EnvironmentAccess.md)**
- [Power Platform Environment Security](https://learn.microsoft.com/power-platform/admin/control-user-access)
- [Share Canvas Apps](https://learn.microsoft.com/power-apps/maker/canvas-apps/share-app)
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

## Summary

The security group configuration is working as designed. To grant makers access to CoE apps:
1. ✓ Add them to the environment security group
2. ✓ Share the specific apps with them
3. ✓ Assign appropriate Dataverse security roles

This maintains environment security while providing necessary access to CoE tools.
