# CoE Security Roles - Quick Reference

## The Three Security Roles

The CoE Starter Kit Core Components includes three Dataverse security roles:

| Role Name | Purpose | Typical Users |
|---|---|---|
| **Power Platform Admin SR** | Full admin access to CoE features | CoE administrators, governance team |
| **Power Platform Maker SR** | Maker access to view resources and submit requests | Power Platform makers, developers |
| **Power Platform User SR** | Read-only access to App Catalog | End users, business users |

## Quick Setup Steps

To grant a user access to CoE apps:

1. **Assign Security Role**
   - Power Platform admin center → Environments → [CoE Env] → Users
   - Select user → "Manage security roles"
   - Assign appropriate role above

2. **Share the App**
   - Power Apps → Apps → [Select CoE app] → Share
   - Add user or group
   - Users need BOTH role assignment AND app sharing

## Common Issue: "CoE Viewer" Role Not Found

**These role names do NOT exist**:
- ❌ "CoE Viewer"
- ❌ "CoE Maker Viewer"

**Use these instead**:
- ✅ "Power Platform Admin SR"
- ✅ "Power Platform Maker SR"
- ✅ "Power Platform User SR"

## More Information

For detailed information, see:
- [FAQ: Security Roles](../CenterofExcellenceResources/FAQ-SecurityRoles.md) - Complete guide
- [FAQ: Admin Role Requirements](../CenterofExcellenceResources/FAQ-AdminRoleRequirements.md) - Power Platform Admin requirements

---

**Quick Link**: https://aka.ms/coe-security-roles
