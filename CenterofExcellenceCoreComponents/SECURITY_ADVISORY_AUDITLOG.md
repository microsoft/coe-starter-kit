# Security Advisory: Audit Log Access Restriction

## Issue Description

**Severity**: High  
**Component**: Power Platform Maker SR Security Role  
**Issue**: Unauthorized access to audit logs

## Problem

The Power Platform Maker SR security role previously included read access (`prvReadadmin_AuditLog`) to the `admin_auditlog` table. This configuration created significant security and privacy concerns:

1. **Data Exposure**: Makers could potentially use tools such as Power BI to view complete usage logs for all users
2. **Privacy Violation**: Audit logs contain sensitive information about user activities across the platform
3. **Compliance Risk**: Unrestricted access to audit logs may violate data protection regulations

## Resolution

The read permission for the `admin_auditlog` table has been **removed** from the Power Platform Maker SR role.

### Changes Made

- **File**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Roles/Power Platform Maker SR.xml`
- **Change**: Removed `prvReadadmin_AuditLog` privilege (previously at line 79 in the original file)

## Security Best Practices

### Recommended Role Assignments

| Role | Audit Log Access | Use Case |
|------|------------------|----------|
| **Power Platform Admin SR** | Full (Read, Write, Create, Delete) | Platform administrators and compliance officers |
| **Power Platform Maker SR** | None | App makers and developers |
| **Power Platform User SR** | None | End users |

### Implementation Steps

After deploying this security fix, administrators should:

1. **Update the Solution**
   - Import the updated CenterofExcellenceCoreComponents solution
   - Ensure all environments receive the updated security role

2. **Verify Access Restrictions**
   - Test with a user assigned the Maker SR role to confirm they cannot access audit logs
   - Validate that admin users still have the required access

3. **Audit Current Assignments**
   - Review all current role assignments
   - Ensure no unintended access persists after the permission change

4. **Update Documentation**
   - Inform makers about the permission change
   - Update internal governance policies

5. **Regular Reviews**
   - Periodically review security roles for excessive permissions
   - Monitor for privilege creep

## Governance Recommendations

1. **Access Control**: Only designated administrative roles should have access to sensitive tables like audit logs
2. **Monitoring**: Implement regular reviews of security role assignments
3. **Documentation**: Maintain clear documentation of who has access to sensitive data and why
4. **Training**: Educate stakeholders on the importance of restricted access to audit logs

## Communication

When deploying this fix, communicate to your organization:

- **Why**: To ensure compliance with security and privacy best practices
- **What**: Read access to audit logs has been removed from Maker roles
- **Impact**: Makers will no longer be able to view system-wide audit logs
- **Who to Contact**: Platform administrators for any audit log access needs

## References

- Original Issue: [#9691](https://github.com/microsoft/coe-starter-kit/issues/9691)
- Security Role Documentation: [Power Platform Security Roles](https://learn.microsoft.com/power-platform/admin/security-roles-privileges)
