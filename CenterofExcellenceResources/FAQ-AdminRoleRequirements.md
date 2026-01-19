# FAQ: Power Platform Administrator Role Requirements

## Overview

This document addresses common questions about the Power Platform Administrator role requirements for the Center of Excellence (CoE) Starter Kit, particularly the Core Components solution.

---

## Common Questions

### Q: Can I remove the Power Platform Administrator role after installing the CoE Starter Kit?

**A: No.** The Power Platform Administrator role is required for **ongoing runtime operations**, not just installation.

The CoE Starter Kit Core Components depend on admin-level APIs to:
- Inventory all environments, apps, flows, and connectors across your tenant
- Monitor Data Loss Prevention (DLP) policies
- Track capacity and usage
- Perform governance and cleanup operations

Without the admin role, **40+ flows will fail** and core functionality will stop working.

---

### Q: What happens if I remove the Power Platform Administrator role after setup?

**A:** Removing the admin role will cause immediate and significant functionality loss:

#### Immediate Impact:
- ❌ **Connection authentication failures** - All admin connector connections will fail
- ❌ **Flow execution errors** - 35% of flows (40+ out of 114) will enter failed state
- ❌ **No inventory updates** - Apps, flows, and environments won't be discovered or updated
- ❌ **Dashboard data goes stale** - Power BI reports will show outdated information

#### Operational Impact:
- ❌ **No tenant visibility** - Cannot see what's being created across the tenant
- ❌ **No governance** - Cannot enforce DLP, environment policies, or compliance
- ❌ **No automation** - Environment provisioning, cleanup, and management stop working
- ❌ **Manual workarounds required** - Would need PowerShell scripts run by admin separately

---

### Q: Will the CoE Kit keep running correctly without the admin role?

**A: No.** Core functionality fundamentally depends on admin-level permissions.

**Critical flows that require admin permissions:**
- `AdminSyncTemplatev4Driver` - Main orchestration flow (runs daily)
- `AdminSyncTemplatev3Connectors` - Inventories connectors
- `AdminSyncTemplatev4CustomConnectors` - Inventories custom connectors
- `AdminSyncTemplatev4ConnectionIdentities` - Tracks connection identities
- `CLEANUP-AdminSyncTemplatev4CheckDeleted` - Cleanup operations
- `EnvRequestCreateApprovedEnvironment` - Creates approved environments
- `DLPRequestApplyPolicytoEnvironmentChild` - Applies DLP policies

**Admin API operations performed continuously:**
- `Get-AdminEnvironment` - Retrieve all tenant environments
- `ListEnvironmentsAsAdmin` - List environments across the tenant
- `Get-AdminConnections` - Get connection details across environments
- `ListPoliciesV2` - List Data Loss Prevention policies

---

### Q: Is the admin role only needed during setup?

**A: No.** The admin role is needed both during setup AND runtime.

| Phase | Requires PP Admin Role? | Why? |
|-------|------------------------|------|
| **Installation** | ✅ YES | To create connections with admin permissions |
| **Configuration** | ✅ YES | To configure connection references to admin APIs |
| **Runtime (Daily Sync)** | ✅ YES | To call admin APIs for inventory collection |
| **Runtime (On-Demand)** | ✅ YES | For environment creation, DLP management, cleanup |

This is a **continuous requirement**, not a one-time setup need.

---

### Q: Can I use Environment Admin role instead of tenant-wide Power Platform Admin?

**A: No.** Environment Admin role is scoped to specific environments. 

The CoE Kit needs to:
- Discover **ALL** environments in the tenant
- Inventory apps and flows **across all environments**
- Monitor **tenant-wide** DLP policies
- Track **tenant-wide** capacity and usage

These operations require **tenant-level** Power Platform Administrator role, not environment-scoped permissions.

---

### Q: Is there a "read-only admin" option?

**A:** Microsoft does not currently offer a separate "read-only admin" role for Power Platform.

However, you can minimize risk by:
- Using a dedicated service account (not a personal admin account)
- Disabling management flows if you only want reporting (see below)
- Implementing compensating security controls (see Security Best Practices section)

**Note:** Even with only reporting enabled, you still need the full Power Platform Administrator role to call the read APIs that gather tenant-wide inventory.

---

### Q: What if I only want reporting, not management features?

**A:** You still need admin permissions for inventory collection.

The Power BI reports and dashboards depend on data collected by flows using admin connectors. Without admin access:
- Cannot get tenant-wide list of environments
- Cannot inventory apps and flows across environments
- Cannot track capacity, usage, or compliance metrics
- Reports will show no data or only partial data

**Option:** You can disable management flows (environment provisioning, DLP management) while keeping inventory flows enabled, but the underlying connection still requires Power Platform Administrator role.

---

### Q: Can I use a service principal instead of a user account?

**A:** The Core CoE Kit flows currently use **user-based connections** to admin connectors.

Service principals with admin permissions (via `New-PowerAppManagementApp` PowerShell cmdlet) are supported in some scenarios:
- ✅ ALM Accelerator components can use service principals
- ❌ Core inventory flows currently require user-based admin connections

**Important:** Service principals would still need **Power Platform admin-level permissions**, so this doesn't eliminate the need for admin access—it just changes the authentication method.

---

## Why Admin Permissions Cannot Be Avoided

The fundamental architecture of Power Platform requires admin-level API access for:

1. **Cross-environment visibility** - Only admin APIs can query across all environments in a tenant
2. **Tenant-wide inventory** - Regular user APIs are scoped to environments where the user has access
3. **Management operations** - Creating environments, applying DLP, managing capacity requires admin permissions by design
4. **Security model** - Microsoft's security model intentionally restricts these operations to administrators

This is not a limitation of the CoE Starter Kit—it's how the Power Platform admin APIs are designed.

---

## Security Best Practices

For organizations with strict security requirements, implement these compensating controls:

### 1. **Use a Dedicated Service Account**
- Create a non-personal account specifically for CoE Kit
- Don't use a personal admin account
- Use clear naming (e.g., `svc-coe-admin@contoso.com`)

### 2. **Implement Conditional Access Policies**
- Restrict sign-in locations (e.g., only from corporate network)
- Require MFA for the service account
- Block legacy authentication protocols
- Restrict device compliance requirements

### 3. **Enable Azure AD Privileged Identity Management (PIM)**
- While the service account needs standing admin access, use PIM for human admins
- Audit all admin role assignments regularly
- Set up alerts for suspicious activity

### 4. **Monitor and Audit**
- Review Azure AD sign-in logs regularly
- Monitor flow run history for unexpected operations
- Set up alerts for failed authentications
- Enable Microsoft 365 audit logging

### 5. **Deploy in a Dedicated Environment**
- Create a separate environment for CoE Kit
- Restrict access to this environment
- Apply DLP policies to limit which connectors can be used
- Use environment security groups

### 6. **Disable Unused Features**
- If you don't use environment provisioning, disable those flows
- If you don't use DLP management, disable those flows
- Keep only inventory flows enabled if that's all you need
- Regularly review and prune unnecessary flows

### 7. **Regular Security Reviews**
- Quarterly review of what flows are running
- Review connection ownership
- Validate admin role is still necessary for each use case
- Document and justify the admin role requirement

---

## Alternative Approaches (and Their Limitations)

If granting Power Platform Administrator role is not possible, consider these alternatives:

### Option 1: Manual PowerShell-Based Inventory
**Approach:** Use PowerShell scripts with Power Platform admin cmdlets to collect inventory data and manually import to Dataverse.

**Limitations:**
- ❌ No automation—requires manual script execution
- ❌ Not integrated with CoE Kit flows and apps
- ❌ Still requires admin credentials for PowerShell
- ❌ Loses real-time governance capabilities

### Option 2: Deploy Only Nurture Components
**Approach:** Deploy only the Nurture solution (training, templates, maker community features) without Core components.

**Limitations:**
- ❌ No inventory or visibility into tenant usage
- ❌ No governance or compliance features
- ❌ No Power BI dashboards or reports
- ❌ Defeats primary purpose of CoE Starter Kit

### Option 3: Custom Development
**Approach:** Build custom governance solution with different architecture.

**Limitations:**
- ❌ Significant development and maintenance effort
- ❌ Still requires admin permissions if you want tenant-wide visibility
- ❌ Loses benefit of Microsoft-maintained CoE Kit
- ❌ No community support or best practices

**Recommendation:** None of these alternatives provide the same value as the CoE Starter Kit with proper admin permissions. If admin access cannot be granted, the CoE Starter Kit Core solution is not viable.

---

## Technical Details

### Admin Connectors Used by CoE Kit

1. **Power Platform for Admins** (`shared_powerplatformforadmins`)
   - Used in 40 out of 114 flows (35%)
   - Required for environment, app, flow, and connector inventory

2. **Power Apps for Admins** (`shared_powerappsforadmins`)
   - Used for app-specific admin operations
   - Required for app sharing, permissions, and usage data

3. **Power Platform for Admins V2** (`shared_powerplatformadminv2`)
   - Newer version with enhanced capabilities
   - Used in critical driver flows

### Connection References Requiring Admin Permissions

From the solution configuration:
- `admin_CoECorePowerPlatformforAdmins`
- `admin_CoECorePowerPlatformforAdminsEnvRequest`
- `admin_CoECorePowerAppsAdmin2`
- `admin_CoECorePowerPlatformforAdminV2`

These connections must be created by a user with Power Platform Administrator role.

---

## Summary

### ✅ Admin Role IS Required For:
- Installation and setup
- Daily inventory synchronization
- Ongoing runtime operations
- Environment management
- DLP policy enforcement
- Capacity monitoring
- Cleanup operations

### ❌ Admin Role CANNOT Be:
- Removed after setup
- Replaced with Environment Admin role
- Replaced with read-only permissions
- Avoided with alternative authentication methods (without losing functionality)

### 🔒 Security Recommendations:
- Use dedicated service account
- Implement Conditional Access policies
- Enable monitoring and auditing
- Deploy in isolated environment
- Disable unused management features
- Regular security reviews

---

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Power Platform for Admins Connector](https://learn.microsoft.com/connectors/powerplatformforadmins/)
- [Power Platform Admin PowerShell](https://learn.microsoft.com/power-platform/admin/powershell-getting-started)
- [Azure AD Conditional Access](https://learn.microsoft.com/azure/active-directory/conditional-access/)
- [Privileged Identity Management](https://learn.microsoft.com/azure/active-directory/privileged-identity-management/)

---

## Need Help?

If you have questions or concerns about admin role requirements:

1. Review the official [CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. Ask questions in [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) using the Question template
3. Engage with the community in [Power Apps Community forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
4. Join [CoE Starter Kit Office Hours](https://aka.ms/coeofficehours)

---

**Last Updated:** January 2026  
**Applies to:** CoE Starter Kit Core Components (All versions)
