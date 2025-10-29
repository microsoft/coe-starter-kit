# Quick Reference: CoE Environment Access Configuration

## Problem

After adding a security group to the CoE environment, makers cannot access CoE apps (like Maker Command Center).

## Why This Happens

Security groups provide **environment access** but apps require **explicit sharing**. You need BOTH.

## Quick Fix (3 Steps)

### ✓ Step 1: Add to Security Group
- Go to Azure Portal → Azure AD → Groups
- Find your CoE environment security group
- Add maker users as members

### ✓ Step 2: Share the App
- Go to make.powerapps.com
- Select CoE environment → Apps
- Find the app (e.g., "Maker Command Center")
- Click Share → Add users with "User" role

### ✓ Step 3: Assign Security Role
- Go to Power Platform Admin Center
- CoE Environment → Settings → Users + permissions
- Assign "Basic User" role to makers

## Access Requirements Checklist

```
Required for Maker to Access CoE Apps:
□ Member of environment security group
□ App shared with user (User role)
□ Dataverse security role assigned (Basic User minimum)
```

## Better Long-term Solution

### Create Two Security Groups:
1. **CoE-Admins** - Full access to manage CoE
2. **CoE-Makers** - Access to use CoE apps only

### Configure Environment:
- Add BOTH groups to environment security
- Share admin apps with CoE-Admins
- Share maker apps with CoE-Makers

### Benefits:
- Easier to manage
- Better security separation
- Scales as team grows

## Common Errors

| Error | Fix |
|-------|-----|
| "System did not accept your logon" | Add to security group |
| "Don't have permission to view app" | Share the app |
| "Insufficient permissions" | Assign security role |

## Key Points to Remember

1. **Security Group ≠ App Access**
   - Security group = environment access
   - App sharing = app access
   - Need BOTH

2. **Use Groups, Not Individuals**
   - Share apps with security groups
   - Easier to manage at scale

3. **Least Privilege**
   - Makers need "User" role (not "Co-owner")
   - Read access to data (not write)

## Resources

- Full FAQ: [FAQ-EnvironmentAccess.md](FAQ-EnvironmentAccess.md)
- Detailed Response: [RESPONSE-Issue-EnvironmentAccess.md](RESPONSE-Issue-EnvironmentAccess.md)
- [Microsoft Docs: Share Canvas Apps](https://learn.microsoft.com/power-apps/maker/canvas-apps/share-app)
- [Microsoft Docs: Environment Security](https://learn.microsoft.com/power-platform/admin/control-user-access)

---

**Version**: 1.0  
**Last Updated**: October 2025  
**Applies To**: CoE Starter Kit 4.49.2+
