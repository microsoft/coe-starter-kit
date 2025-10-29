# Issue Response Template: Environment Access with Security Groups

## Template Response for Issues About CoE App Access After Adding Security Groups

Use this template to respond to issues where users report that makers cannot access CoE apps after configuring a security group on the environment.

---

### Response Template

Thank you for reporting this issue! This is a common question when configuring environment security for the CoE Starter Kit.

#### Understanding the Problem

When you add a security group to your CoE environment (as recommended for production environments), it creates a two-tier security model:

1. **Environment-level access** (controlled by the security group)
2. **App-level access** (controlled by app sharing)

Both levels must be configured for makers to access CoE apps like the Maker Command Center.

#### Solution

To grant makers access to CoE apps while maintaining environment security, you need to:

**Step 1: Environment Access**
- Ensure makers are members of the security group assigned to your CoE environment
- OR create separate security groups for different access levels (admin vs. maker)

**Step 2: Share the Apps**
- Go to Power Apps (make.powerapps.com)
- Select your CoE environment
- Navigate to the Maker Command Center app (or other CoE apps)
- Click **Share**
- Add the makers or their security group with **User** role

**Step 3: Assign Security Roles**
- In Power Platform Admin Center, assign appropriate Dataverse security roles
- Minimum: **Basic User** role
- Recommended: Create a custom security role for CoE app users with read access to necessary tables

#### Detailed Guidance

For comprehensive step-by-step instructions, please see our FAQ document:
**[FAQ: Environment Access Configuration](../docs/FAQ-EnvironmentAccess.md)**

This document covers:
- Detailed configuration steps
- Best practices for security group management
- Alternative approaches (separate environments)
- Common errors and solutions
- Recommended security role configurations

#### Quick Reference

```
Required Configuration for Maker Access:
✓ Security Group Membership (Environment Access)
✓ App Sharing (App Permission)
✓ Dataverse Security Role (Data Access)
```

#### Additional Resources

- [Power Platform Environment Security](https://learn.microsoft.com/power-platform/admin/control-user-access)
- [Share Canvas Apps](https://learn.microsoft.com/power-apps/maker/canvas-apps/share-app)
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

---

Please let us know if you need additional assistance with this configuration!

---

## Related Issue Labels

When using this template, consider adding these labels:
- `coe-starter-kit`
- `question`
- `documentation`
- `environment-security`

## Additional Notes

- This is a security-by-design feature, not a bug
- Recommend creating documentation or internal wiki for your organization's specific configuration
- Consider creating automated provisioning if you have many makers requiring access
