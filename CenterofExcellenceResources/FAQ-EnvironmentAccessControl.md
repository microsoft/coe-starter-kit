# FAQ: CoE Environment Access Control and Visibility

## Overview

This document addresses common questions about controlling access to the CoE Starter Kit environment, managing environment visibility, and understanding how the CoE Kit interacts with security groups.

---

## Common Questions

### Q: Why is my dedicated CoE environment visible to everyone in the organization?

**A:** Power Platform environments have different visibility settings that are controlled at the platform level, not by the CoE Starter Kit itself.

#### Understanding Environment Visibility

By default, Power Platform environments can be discovered by users in your tenant even if they don't have access to create resources in them. The visibility depends on:

1. **Environment Type**
   - **Production/Sandbox environments**: Visible in the environment list to all users
   - **Developer environments**: Typically personal and not visible to others
   - **Dataverse for Teams environments**: Scoped to specific Teams

2. **Security Groups**
   - If you associate a security group with an environment, only members of that group can create apps and flows in that environment
   - However, the environment may still be **visible** in the environment picker even to non-members
   - Non-members won't have access to create or manage resources

3. **Access vs. Visibility**
   - **Visibility**: Users can see the environment name in lists
   - **Access**: Users can actually create apps, flows, or access data
   - Security groups control **access**, not necessarily **visibility**

#### Why This Matters for CoE Environments

The CoE environment should be restricted because:
- It contains admin-level connections and flows
- Makers should not build personal apps in the CoE environment
- It should be a dedicated, managed environment
- Mixing CoE components with maker apps creates governance challenges

---

### Q1: Can we implement an RBAC (Role-Based Access Control) model on this dedicated environment?

**A: Yes, absolutely.** Power Platform supports environment-level security controls.

#### Recommended RBAC Implementation for CoE Environment

**Step 1: Associate a Security Group**

1. **Navigate to Power Platform Admin Center**
   - Go to [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
   - Select your CoE environment
   - Click **Settings** → **Users + permissions** → **Security groups**

2. **Add a Security Group**
   - Click **+ Add security group**
   - Select an Entra ID (Azure AD) security group containing only:
     - CoE administrators
     - The service account running CoE flows
     - Any users who legitimately need to configure CoE components
   - Save the configuration

3. **Important**: Make sure your security group includes:
   - The user account(s) with Power Platform Administrator role who manage the CoE Kit
   - The service account (if you're using one) that owns the CoE flow connections
   - Any team members who configure dashboards, flows, or apps

**Step 2: Restrict Environment Access**

Once a security group is associated with an environment:
- ✅ Only members of that security group can create apps and flows
- ✅ Only members can see the environment in the maker portal (Power Apps/Power Automate)
- ✅ Non-members cannot create resources or view existing apps

**Step 3: Assign Appropriate Security Roles**

Within the environment, assign security roles based on responsibilities:

| Role | Who Needs It | What They Can Do |
|------|-------------|------------------|
| **System Administrator** | CoE administrators, service account | Full control over CoE apps, flows, and data |
| **System Customizer** | CoE team members who configure components | Customize apps and flows |
| **Basic User** | Report viewers only | View Power BI dashboards (with appropriate sharing) |
| **Environment Maker** | **Not recommended for most users** | Can create apps/flows - use sparingly |

**Step 4: Implement DLP Policies**

Apply a Data Loss Prevention (DLP) policy to your CoE environment:
- Restrict which connectors can be used
- Prevent makers from creating apps even if they somehow gain access
- Limit to connectors needed by CoE Kit (Dataverse, Office 365, admin connectors)

#### Best Practices for CoE Environment Security

1. **Use a Dedicated Security Group**
   - Create a security group specifically for CoE access (e.g., `SG-CoE-Admins`)
   - Keep membership small and controlled
   - Review membership quarterly

2. **Don't Use Dynamic Groups for Environment Access**
   - While Entra ID (Azure AD) supports dynamic groups, use **assigned (static) groups** for environment security
   - Dynamic groups can unexpectedly add users based on attributes
   - Static groups provide predictable, controlled access

3. **Separate Roles and Responsibilities**
   - **CoE Administrators**: Full access to configure and manage
   - **Dashboard Viewers**: Read-only access to Power BI reports (shared via Power BI, not environment access)
   - **Makers**: Should NOT have access to the CoE environment

4. **Monitor Access**
   - Regularly review environment security group membership
   - Use Azure AD access reviews for automated attestation
   - Monitor who is accessing the CoE environment

---

### Q2: Can we remove all the users from this group to revoke access? Will it impact CoE Toolkit functionality?

**A: It depends on which group you're referring to and how it's configured.**

#### Scenario 1: Environment Security Group (Controls Environment Access)

**Can you remove users?** Yes, but with critical caveats.

**Impact on CoE Functionality:**

❌ **DO NOT remove the service account or admin who runs CoE flows**
- If you remove the user account that owns the CoE flow connections, flows will fail
- The Power Platform Administrator account running the CoE Kit must remain in the security group
- The service account (if used) must have access to the environment

✅ **You CAN remove regular users/makers**
- If regular makers were accidentally added, you can and should remove them
- This will prevent them from creating apps in the CoE environment
- No impact on CoE functionality

**Required Members:**
1. **Power Platform Administrator account** (or service account) that owns CoE flow connections
2. **CoE administrators** who configure and manage the kit
3. **CoE team members** who work with dashboards and reports

**Do NOT include:**
- Regular makers
- General user population
- Any dynamic group that adds all users

#### Scenario 2: Power Platform Makers Microsoft 365 Group

The CoE Starter Kit uses a **Power Platform Makers Microsoft 365 group** for communication and app sharing purposes. This is configured via environment variable:
- **Environment Variable**: `Power Platform Maker Group ID (admin_PowerPlatformMakeSecurityGroup)`
- **Purpose**: Used to share CoE apps with makers, send communications, and identify the maker community

**Can you remove users from this group?** Not recommended.

**Impact on CoE Functionality:**

⚠️ **Moderate Impact** - Several CoE features depend on this group:

1. **App Sharing**
   - CoE apps (e.g., Developer Compliance Center, DLP Editor) are shared with this group
   - Removing users means they won't have access to maker-facing apps

2. **Communications**
   - Some CoE flows send emails or notifications to this group
   - Removing users means they won't receive maker communications

3. **Maker Identification**
   - The group helps identify who the "makers" are in your organization
   - Dashboards may reference this for maker counts

**What happens if you empty this group?**
- ✅ Core inventory flows continue to work
- ✅ Admin dashboards continue to work
- ❌ Makers won't receive CoE apps shared with them
- ❌ Maker-focused communications will fail
- ❌ Some nurture and governance features will be limited

**Recommended Approach:**
- Keep the Power Platform Makers M365 group
- Manage membership appropriately (see Q3 below)
- Use it for its intended purpose: identifying and communicating with your maker community

#### Summary Table

| Group Type | Can Remove Users? | Impact on CoE | Recommendation |
|------------|------------------|---------------|----------------|
| **Environment Security Group** | Yes (except admins/service account) | ❌ Critical if you remove CoE admins | Remove regular makers, keep CoE team |
| **Power Platform Makers M365 Group** | Yes, but not recommended | ⚠️ Moderate - affects app sharing and comms | Keep and manage properly |

---

### Q3: Does the CoE toolkit have any cloud flow which adds users to this maker group based on any resource already owned by these users?

**A: Yes!** The CoE Starter Kit includes a flow that automatically adds users to the Power Platform Makers Microsoft 365 group.

#### Flow Details

**Flow Name**: `Admin | Add Maker to Group`  
**Internal Name**: `AdminAddMakertoGroup`

**Purpose**: Automatically adds users to the Power Platform Makers Microsoft 365 group when they are identified as makers in your tenant.

**How It Works:**

1. **Trigger**: When a new maker is added to the `admin_Maker` table in Dataverse
2. **Logic**: 
   - Checks if the maker has created any apps, flows, or other Power Platform resources
   - Verifies the user is not a service principal or SYSTEM account
   - Adds the user to the Microsoft 365 group specified in the environment variable
3. **Group**: The group ID is configured via the `Power Platform Maker Group ID (admin_PowerPlatformMakeSecurityGroup)` environment variable

**When Does a User Become a "Maker"?**

The CoE inventory flows discover users as "makers" when they:
- Create a Power App (canvas or model-driven)
- Create a Power Automate flow
- Create a custom connector
- Own a Dataverse solution component
- Are identified through other Power Platform resources

**This Explains Your Unexpected Behavior!**

If you created an Entra ID (Azure AD) security group for your CoE **environment** and all users got added to it, you likely confused two different groups:

1. **Environment Security Group** (controls who can access the environment)
2. **Power Platform Makers M365 Group** (used by CoE for maker identification and communication)

The `Admin | Add Maker to Group` flow automatically adds makers to the **Makers M365 Group** (#2), not the **Environment Security Group** (#1).

#### How to Control This Behavior

**Option 1: Turn Off the Flow** (if you don't want automatic group additions)

1. Navigate to Power Automate in your CoE environment
2. Find the flow: **Admin | Add Maker to Group**
3. Turn off the flow
4. Manually manage the Power Platform Makers M365 group membership

**Consequences of turning off:**
- ❌ Won't automatically add new makers to the group
- ❌ Maker-facing apps won't be automatically shared with new makers
- ✅ You have full manual control over group membership

**Option 2: Keep the Flow On and Manage Group Separately**

1. Keep **Admin | Add Maker to Group** flow enabled
2. Let it manage the **Power Platform Makers M365 Group** automatically
3. Use a **different security group** for your CoE **environment** access control
4. Do NOT associate the Makers M365 group with your CoE environment security

**This is the recommended approach** because:
- ✅ Makers are automatically identified and added to the Makers group
- ✅ CoE apps are shared with makers automatically
- ✅ Your CoE environment remains secure (controlled by a separate security group)
- ✅ Clear separation between "who are the makers" vs. "who can access CoE environment"

#### Configuration Steps to Fix Your Issue

If you accidentally made your CoE environment accessible to everyone:

**Step 1: Create a Dedicated Environment Security Group**
- Create a new Entra ID security group: `SG-CoE-Environment-Access`
- Add only CoE administrators and the service account
- Do NOT make it dynamic
- Do NOT add all makers

**Step 2: Associate the Security Group with Your CoE Environment**
- Go to Power Platform Admin Center
- Select your CoE environment
- Settings → Users + permissions → Security groups
- Add your new `SG-CoE-Environment-Access` group
- This restricts who can create resources in the environment

**Step 3: Keep or Create the Power Platform Makers M365 Group**
- Keep your existing Power Platform Makers M365 group (or create a new one)
- This is a **different group** used for maker identification
- Let the `Admin | Add Maker to Group` flow manage this automatically
- Configure the environment variable `Power Platform Maker Group ID` with this group's ID

**Step 4: Verify Separation**
- **Environment Security Group**: Small, controlled, admin-only
- **Makers M365 Group**: Larger, automatically managed, for maker communication

**Step 5: Remove Incorrect Configuration**
- If you accidentally associated the Makers M365 group with your environment, remove it
- Replace it with the dedicated environment security group

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ CoE Starter Kit Environment                                      │
│                                                                   │
│  Access Controlled By:                                           │
│  ┌────────────────────────────────────┐                         │
│  │ Environment Security Group         │                         │
│  │ (SG-CoE-Environment-Access)        │                         │
│  │                                    │                         │
│  │ Members:                           │                         │
│  │  - CoE Administrators (3-5 people) │                         │
│  │  - Service Account                 │                         │
│  └────────────────────────────────────┘                         │
│                                                                   │
│  CoE Flows and Apps Run Here                                     │
│  ↓ Inventory flows discover makers                               │
└───────────────────────────────────────────────────────────────── ┘
                                ↓
                   ┌────────────────────────────┐
                   │ Admin | Add Maker to Group │
                   │ (flow)                     │
                   └────────────────────────────┘
                                ↓
            ┌───────────────────────────────────────────┐
            │ Power Platform Makers M365 Group          │
            │ (for maker communication)                 │
            │                                           │
            │ Members (automatically managed):          │
            │  - All users who create apps/flows        │
            │  - Used for sharing CoE maker apps        │
            │  - Used for maker communications          │
            └───────────────────────────────────────────┘
                                ↓
                    Makers receive shared apps
                    (DLP Editor, Compliance Center, etc.)
```

---

## Step-by-Step Resolution Guide

Based on your situation, follow these steps:

### Problem: CoE Environment is Visible/Accessible to Everyone

**Root Cause**: Likely the environment doesn't have a security group associated, or the wrong group was associated.

**Resolution Steps:**

#### Step 1: Identify Current Configuration

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Click **Settings** → **Users + permissions** → **Security groups**
4. Note if any security group is currently associated

#### Step 2: Create Proper Environment Security Group

```
Group Type: Entra ID (Azure AD) Security Group
Assignment Type: Assigned (NOT Dynamic)
Name: SG-CoE-Environment-Access
Members: 
  - CoE Admin 1 (you)
  - CoE Admin 2 (if applicable)
  - Service account (if using one)
Total Members: 2-5 people maximum
```

#### Step 3: Associate Security Group with Environment

1. In Power Platform Admin Center, your CoE environment
2. **Settings** → **Users + permissions** → **Security groups**
3. Click **+ Add security group**
4. Search for and select `SG-CoE-Environment-Access`
5. Click **Add**
6. **Important**: After adding, users must be added to the environment security roles

#### Step 4: Assign Security Roles to Group Members

1. In Power Platform Admin Center, your CoE environment
2. **Settings** → **Users + permissions** → **Users**
3. Click **+ Add user**
4. Select users from your security group
5. Assign **System Administrator** role
6. Repeat for all CoE admin users

#### Step 5: Verify Makers Group Configuration

1. In Power Apps, go to your CoE environment
2. Navigate to **Solutions** → **Center of Excellence - Core Components**
3. Open **Environment Variables**
4. Find `Power Platform Maker Group ID (admin_PowerPlatformMakeSecurityGroup)`
5. Verify it points to your **Makers M365 Group** (NOT the environment security group)
6. If it's pointing to the wrong group, update it:
   - Get the correct M365 group ID from Azure AD or M365 Admin Center
   - Update the environment variable with the correct ID

#### Step 6: Verify Flow Configuration

1. In Power Automate, go to your CoE environment
2. Find flow **Admin | Add Maker to Group**
3. Verify it's enabled (if you want automatic maker additions)
4. Check recent runs to see which users were added
5. If you don't want automatic additions, turn off the flow

#### Step 7: Clean Up Incorrect Group Membership

If users were incorrectly added to your environment:
1. Remove them from the environment security group in Azure AD
2. Within Power Platform Admin Center → your CoE environment → Users, they should automatically lose access
3. If they still appear, you can manually remove them from the environment

#### Step 8: Test Access Control

1. **Test with a CoE admin account**: Should have full access to the environment
2. **Test with a regular maker account**: Should NOT see the CoE environment in the environment picker
3. **Test with a non-maker account**: Should NOT see the CoE environment

---

## Security Best Practices

### 1. **Use Separate Groups for Separate Purposes**

| Purpose | Group Type | Membership | Management |
|---------|-----------|------------|------------|
| **Environment Access Control** | Entra ID Security Group (Assigned) | 2-5 CoE admins only | Manual, reviewed quarterly |
| **Maker Identification** | Microsoft 365 Group | All makers (100s-1000s) | Automatic via CoE flow |

### 2. **Apply Least Privilege**

- Only CoE administrators should access the CoE environment
- Regular makers should use the production/sandbox environments
- Service accounts should have only necessary permissions

### 3. **Implement DLP Policies**

Create a DLP policy for your CoE environment:
- **Business Group**: Admin connectors only
- **Blocked**: Social media, public connectors, unapproved connectors
- **Non-Business**: Minimal or none

Example connectors for CoE environment:
- ✅ Dataverse (required)
- ✅ Office 365 connectors (Outlook, Groups, Users)
- ✅ Power Platform for Admins (required)
- ✅ Azure AD (if used)
- ❌ Block everything else

### 4. **Monitor and Audit**

Set up monitoring for:
- Changes to environment security group membership
- New apps or flows created in CoE environment (should be minimal)
- Failed flow runs
- Changes to environment settings

### 5. **Document Your Configuration**

Maintain documentation that includes:
- Environment security group name and purpose
- Makers M365 group name and purpose
- List of CoE administrators
- Service account details (without credentials)
- Configuration decisions and rationale

### 6. **Regular Access Reviews**

Quarterly reviews should include:
- Verify environment security group membership
- Review CoE administrator list
- Check for unauthorized apps/flows in CoE environment
- Validate DLP policies are still applied
- Review flow run history for anomalies

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Using the Same Group for Environment Access and Maker Identification

**Problem**: If you use the Makers M365 group as your environment security group, all makers get access to the CoE environment.

**Solution**: Use separate groups as documented above.

### ❌ Mistake 2: Using Dynamic Groups for Environment Security

**Problem**: Dynamic groups can unexpectedly add users based on attributes, making access unpredictable.

**Solution**: Use assigned (static) security groups for environment access control.

### ❌ Mistake 3: Removing the Service Account from Access

**Problem**: If you remove the account that owns CoE flow connections, all flows will fail.

**Solution**: Ensure the service account (or admin account running flows) always has access.

### ❌ Mistake 4: Not Understanding Visibility vs. Access

**Problem**: Thinking that because users can see the environment in a list, they have access.

**Solution**: Security groups control access (creating apps/flows), not visibility in environment lists. Focus on access control.

### ❌ Mistake 5: Disabling Admin | Add Maker to Group Without a Plan

**Problem**: Disabling the flow without planning how to share apps with makers leads to broken maker experiences.

**Solution**: If you disable the flow, implement a manual process for sharing CoE apps with makers.

---

## Frequently Asked Questions

### Can users still see the CoE environment name even with security group restrictions?

**Yes**, users may see the environment name in some lists, but they cannot:
- Access the environment
- Create apps or flows in it
- See existing apps or data

This is expected Power Platform behavior.

### Will the CoE Kit create environments for makers?

Only if you enable and configure the **Environment Request** flows. By default:
- CoE Kit does NOT create environments automatically
- It only inventories existing environments
- Environment creation requires explicit configuration and approval workflows

### Should I use a service account or personal admin account for CoE?

**Best practice**: Use a dedicated service account (e.g., `svc-coe-admin@contoso.com`)

**Benefits**:
- No dependency on individual user accounts
- Easier to manage in case of staff changes
- Clearer audit trails
- Better security control with conditional access policies

### How do I find the ID of a Microsoft 365 group?

**Method 1: Azure AD Portal**
1. Go to [Azure AD Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** → **Groups**
3. Find your group and open it
4. The **Object ID** is your group ID

**Method 2: Microsoft 365 Admin Center**
1. Go to [Microsoft 365 Admin Center](https://admin.microsoft.com)
2. Navigate to **Groups** → **Active groups**
3. Select your group
4. The group ID is in the URL or details pane

**Method 3: PowerShell**
```powershell
Connect-AzureAD
Get-AzureADGroup -Filter "DisplayName eq 'Your Group Name'" | Select-Object ObjectId, DisplayName
```

---

## Troubleshooting

### Issue: Users still have access after removing them from security group

**Resolution**:
1. Verify the user is removed from the Entra ID security group
2. Wait 5-10 minutes for synchronization
3. Check if the user has a direct security role assignment in the environment
4. In Power Platform Admin Center → Environment → Users, manually remove if needed
5. User may need to sign out and sign back in

### Issue: CoE flows failing after implementing security group

**Resolution**:
1. Verify the service account is in the environment security group
2. Check that the service account has System Administrator role
3. Verify all connection references are owned by an account with access
4. Test connections in Power Automate → Data → Connections

### Issue: Admin | Add Maker to Group flow is failing

**Common causes**:
1. **Invalid group ID**: Check environment variable has correct M365 group ID
2. **Permissions**: The connection owner must have permissions to add members to the M365 group
3. **Group type**: Must be a Microsoft 365 group, not a security group
4. **Service principals**: Flow filters out service principals - this is expected

**Resolution**:
1. Check flow run history for specific error messages
2. Verify environment variable `Power Platform Maker Group ID` has correct group ID
3. Ensure the connection owner has permission to manage the M365 group membership
4. If you don't need automatic additions, turn off the flow

### Issue: Can't find the Admin | Add Maker to Group flow

**Resolution**:
1. Go to Power Automate → your CoE environment
2. Filter by solution: **Center of Excellence - Core Components**
3. Search for "Add Maker"
4. If not found, you may be on an older version - consider upgrading

---

## Additional Resources

### Official Documentation

- [Power Platform Admin Center - Environment Security Groups](https://learn.microsoft.com/power-platform/admin/control-user-access)
- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Environment Strategy](https://learn.microsoft.com/power-platform/guidance/adoption/environment-strategy)
- [Data Loss Prevention Policies](https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention)

### Related CoE Starter Kit Documentation

- [FAQ: Admin Role Requirements](FAQ-AdminRoleRequirements.md)
- [Data Retention and Maintenance](DataRetentionAndMaintenance.md)
- [Troubleshooting Setup Wizard](TROUBLESHOOTING-SETUP-WIZARD.md)

### Community Resources

- [CoE Starter Kit GitHub Repository](https://github.com/microsoft/coe-starter-kit)
- [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Governance Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

## Need Help?

If you have questions about environment access control:

1. **Check existing issues**: Search [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar questions
2. **Review documentation**: Consult [CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
3. **Ask the community**: Use the [question template](https://github.com/microsoft/coe-starter-kit/issues/new/choose) to ask questions
4. **Join office hours**: Participate in [CoE Starter Kit Office Hours](https://aka.ms/coeofficehours)

---

**Applies to:** CoE Starter Kit Core Components (All versions)  
**Last Updated:** January 2026  
**Version:** 1.0
