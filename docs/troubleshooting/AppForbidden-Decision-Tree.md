# CoE Setup Wizard - Permission Troubleshooting Decision Tree

Use this decision tree to troubleshoot permission issues when accessing the CoE Setup and Upgrade Wizard.

```
START: Cannot access CoE Setup and Upgrade Wizard
│
├─ Do you get an "AppForbidden" error?
│  │
│  YES ─> Continue to Step 1
│  │
│  NO ─> Check other issues:
│         - Solution not installed
│         - App not published
│         - Environment access issues
│
└─ STEP 1: Verify your user has a security role
   │
   ├─ Check your security roles:
   │  1. Go to Power Platform Admin Center
   │  2. Select your environment
   │  3. Settings > Users + permissions > Users
   │  4. Find your user account
   │  5. Check "Manage security roles"
   │
   ├─ Do you have ANY of these roles?
   │  - Power Platform Admin SR
   │  - System Administrator
   │  - System Customizer
   │
   ├─ YES ─> STEP 2: Clear cache and retry
   │         1. Sign out of Power Apps
   │         2. Clear browser cache
   │         3. Sign back in
   │         4. Wait 5-10 minutes for permissions to propagate
   │         5. Try accessing the wizard again
   │         │
   │         ├─ Still not working?
   │         │  └─> Check if Object ID in error matches your Azure AD Object ID
   │         │      - Different ID = Cached credentials or service principal issue
   │         │      - Clear all browser data and try in incognito mode
   │
   └─ NO ─> STEP 3: Assign required security role
            │
            Recommended: Assign "Power Platform Admin SR"
            1. Power Platform Admin Center
            2. Select environment
            3. Settings > Users + permissions > Users
            4. Select your user
            5. Manage security roles
            6. Check "Power Platform Admin SR"
            7. Save
            8. Sign out and sign back in
            9. Wait 5-10 minutes
            10. Access the wizard
            │
            └─> SUCCESS: You can now access the CoE Setup and Upgrade Wizard
```

## Quick Reference

### Required Security Roles (need at least one)

| Role Name | Type | Recommended | Notes |
|-----------|------|-------------|-------|
| Power Platform Admin SR | Custom | ✅ Yes | Designed specifically for CoE Starter Kit |
| System Administrator | System | ⚠️ Use with caution | Full admin access to Dataverse |
| System Customizer | System | ⚠️ Alternative | Customization access to Dataverse |

### Common Scenarios

**Scenario 1: First-time setup**
- Assign "Power Platform Admin SR" role to all CoE administrators
- This role has the minimal required permissions for CoE Starter Kit

**Scenario 2: Existing System Administrators**
- If users already have System Administrator role, no additional role assignment needed
- CoE Setup Wizard will work automatically

**Scenario 3: Multiple CoE team members**
- Create a dedicated security group in Azure AD
- Assign "Power Platform Admin SR" role to the group
- Add CoE team members to the security group

## Troubleshooting Checklist

Before opening a GitHub issue, verify:

- [ ] User account exists in the environment
- [ ] At least one required security role is assigned to the user
- [ ] User has signed out and back in after role assignment
- [ ] Browser cache has been cleared
- [ ] At least 5-10 minutes have passed since role assignment
- [ ] CoE Core Components solution is installed successfully
- [ ] Creator Kit dependency is installed
- [ ] Model-driven app is published and active

## Still Having Issues?

If you've completed all troubleshooting steps and still cannot access the wizard:

1. Check your Azure AD Object ID matches the one in the error message
2. Try accessing in an incognito/private browser window
3. Verify no conditional access policies are blocking access
4. Contact your Power Platform administrator to verify environment access
5. [Open a GitHub issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) with detailed information

## Related Documentation

- [Main Troubleshooting Guide](AppForbidden-Setup-Wizard.md)
- [Common GitHub Responses](../COE-Kit-Common-GitHub-Responses.md)
- [CoE Starter Kit Setup](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
