# Issue Response: CoE Environment Visible to Everyone

## Summary

This is a common question about Power Platform environment visibility and access control. The user created a dedicated CoE environment that is visible to everyone in the organization, and users are creating apps in it. They associated an Entra ID (Azure AD) security group but all users were added to it.

## Root Cause

Based on the issue description, there are likely two separate issues happening:

1. **Confusion between two different groups**:
   - **Environment Security Group**: Controls who can access/create resources in the environment
   - **Power Platform Makers M365 Group**: Used by CoE Kit for maker identification and app sharing

2. **Auto-adding flow**: The CoE Starter Kit includes a flow called **Admin | Add Maker to Group** that automatically adds users to the Power Platform Makers M365 group when they are identified as makers (creators of apps/flows)

## Answer to User's Questions

### Q1: Can we implement a RBAC model on this dedicated environment?

✅ **Yes, absolutely.** Power Platform supports environment-level access control via security groups.

**Solution**:
1. Create an Entra ID (Azure AD) **assigned** security group (NOT dynamic) with only CoE administrators
2. Associate this security group with your CoE environment in Power Platform Admin Center
3. This restricts who can create apps/flows in that environment

### Q2: Can we remove all the users from this group to revoke access? Will it impact CoE Toolkit functionality?

⚠️ **It depends on which group you're referring to.**

**If you mean the Environment Security Group**:
- ✅ You CAN remove regular users/makers (they shouldn't be there anyway)
- ❌ DO NOT remove the Power Platform Administrator account or service account that runs CoE flows
- Removing the admin/service account will break all CoE flows

**If you mean the Power Platform Makers M365 Group**:
- ⚠️ You can, but it has moderate impact
- CoE apps shared with makers will no longer be accessible to them
- Maker communications will fail
- Core inventory still works, but nurture/governance features will be limited

### Q3: Does the CoE toolkit have any cloud flow which adds users to this maker group based on resources already owned?

✅ **Yes!** This is exactly what's happening.

**Flow Name**: `Admin | Add Maker to Group`

**How it works**:
- Trigger: When a new maker is discovered by CoE inventory flows
- Action: Automatically adds the user to the Microsoft 365 group configured in the `Power Platform Maker Group ID` environment variable
- This is intended behavior for identifying and communicating with makers

**This likely explains why "all users got added"** - if those users created any Power Platform resources (apps, flows, etc.), they were automatically identified as makers and added to the group.

## Resolution Steps

### Step 1: Separate Your Security Groups

You need **two different groups**:

| Group | Purpose | Type | Membership |
|-------|---------|------|------------|
| **CoE Environment Security Group** | Controls who can access CoE environment | Entra ID Security Group (Assigned) | 2-5 CoE admins only |
| **Power Platform Makers M365 Group** | Maker identification & communication | Microsoft 365 Group | All makers (auto-managed by flow) |

### Step 2: Configure Environment Security

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Navigate to **Settings** → **Users + permissions** → **Security groups**
4. Add your **CoE Environment Security Group** (the small, admin-only group)
5. Remove any other groups that were incorrectly associated

### Step 3: Configure Makers Group Correctly

1. In Power Apps, go to your CoE environment
2. Navigate to **Solutions** → **Center of Excellence - Core Components**
3. Find environment variable: `Power Platform Maker Group ID`
4. Ensure it points to your **Power Platform Makers M365 Group** (NOT the environment security group)

### Step 4: Control Auto-Add Behavior

**Option A: Keep automatic additions (recommended)**
- Leave the **Admin | Add Maker to Group** flow enabled
- Makers will automatically be added to the Makers M365 group
- CoE apps will be automatically shared with them

**Option B: Manual control**
- Turn off the **Admin | Add Maker to Group** flow in Power Automate
- Manually manage the Makers M365 group membership
- Note: You'll need to manually share CoE apps with makers

### Step 5: Clean Up Incorrect Access

1. Review and clean up membership in your environment security group
2. Ensure only CoE administrators are members
3. Regular makers should be removed from the environment security group
4. Test with a maker account to verify they cannot access the CoE environment

## Architecture Diagram

```
CoE Environment (Access: Restricted)
├── Security Group: SG-CoE-Environment-Access
│   ├── CoE Admin 1
│   ├── CoE Admin 2
│   └── Service Account
│
└── Contains: CoE Flows and Apps
    │
    └── Admin | Add Maker to Group (flow)
        ├── Discovers: Users who create apps/flows
        └── Adds them to: Power Platform Makers M365 Group
            ├── Maker 1 (auto-added)
            ├── Maker 2 (auto-added)
            ├── Maker 3 (auto-added)
            └── ... (100s-1000s of makers)
```

## Detailed Documentation

A comprehensive FAQ has been created to address this and related questions:

📖 **[FAQ: CoE Environment Access Control and Visibility](../CenterofExcellenceResources/FAQ-EnvironmentAccessControl.md)**

This document includes:
- ✅ Detailed explanations of environment visibility vs. access
- ✅ Step-by-step RBAC implementation guide
- ✅ Impact analysis of removing users from groups
- ✅ Complete documentation of the Admin | Add Maker to Group flow
- ✅ Troubleshooting guide
- ✅ Security best practices
- ✅ Common mistakes to avoid

## Key Takeaways

1. **Separate Groups**: Use different groups for environment access control vs. maker identification
2. **Understand the Flow**: The CoE Kit automatically adds makers to a M365 group for communication
3. **Secure Your Environment**: Associate a small, admin-only security group with your CoE environment
4. **Don't Break CoE**: Keep the admin/service account in the environment security group
5. **This is Normal**: Auto-adding makers to the Makers M365 group is intended behavior

## Response Template for GitHub Issue

```markdown
Thank you for your question! This is a common scenario when setting up the CoE Starter Kit.

### Summary

You're experiencing this because of two separate groups that are often confused:

1. **Environment Security Group** - Controls who can access your CoE environment (should be 2-5 admins)
2. **Power Platform Makers M365 Group** - Used by CoE Kit for maker identification (can be 100s-1000s of users)

### Answers to Your Questions

**Q1: Can we implement a RBAC model on this dedicated environment?**

✅ Yes! You can and should associate a small, admin-only Entra ID security group with your CoE environment. This restricts who can create resources in it.

**Q2: Can we remove all the users from this group to revoke access? Will it impact CoE Toolkit functionality?**

⚠️ It depends:
- If removing from **Environment Security Group**: Remove makers, but keep CoE admins and service account
- If removing from **Makers M365 Group**: This will impact app sharing and communications

**Q3: Does the CoE toolkit have any cloud flow which adds users to this maker group?**

✅ Yes! The **Admin | Add Maker to Group** flow automatically adds users to the Makers M365 group when they are discovered as makers (creators of apps/flows). This is intended behavior.

### Resolution

Please see the comprehensive FAQ documentation that addresses your questions in detail:

📖 **[FAQ: CoE Environment Access Control and Visibility](../CenterofExcellenceResources/FAQ-EnvironmentAccessControl.md)**

This guide includes:
- Step-by-step instructions to properly secure your CoE environment
- How to separate the two groups correctly
- How to control the auto-add behavior
- Troubleshooting and best practices

### Key Steps

1. Create a dedicated **CoE Environment Security Group** (small, admin-only)
2. Associate it with your CoE environment in Power Platform Admin Center
3. Keep the **Power Platform Makers M365 Group** separate for maker identification
4. Decide whether to keep or disable the **Admin | Add Maker to Group** flow

Let us know if you have any specific questions after reviewing the FAQ!
```

## Follow-up Actions

When responding to the issue:
1. Post the response template above
2. Link to the new FAQ document
3. Offer to answer specific questions if they have any after reviewing the documentation
4. Consider labeling the issue as "question" and "documentation"
5. After the user confirms the issue is resolved, close the issue

## Related Issues

Search for similar issues:
- Environment access control questions
- Security group configuration
- Makers group auto-add behavior
- Environment visibility concerns

## Future Enhancements

Potential improvements to prevent this confusion:
1. Add setup wizard guidance about the two different groups
2. Include warnings in environment variable descriptions
3. Add documentation links in flow descriptions
4. Consider renaming environment variables to make the distinction clearer

---

**Created**: January 2026  
**Issue Type**: Question / Documentation  
**CoE Component**: Core Components  
**Related Flows**: Admin | Add Maker to Group
