# CoE Starter Kit - Common GitHub Issue Responses

This document contains common responses and solutions for frequently reported issues in the CoE Starter Kit.

## Table of Contents

- [Permission and Access Issues](#permission-and-access-issues)
  - [AppForbidden Error - CoE Setup and Upgrade Wizard](#appforbidden-error---coe-setup-and-upgrade-wizard)
- [Installation Issues](#installation-issues)
- [Flow Failures](#flow-failures)
- [Data Issues](#data-issues)

---

## Permission and Access Issues

### AppForbidden Error - CoE Setup and Upgrade Wizard

**Issue Type:** Access/Permission Error  
**Component:** CoE Setup and Upgrade Wizard (Model-Driven App)  
**Solution:** Core Components

**Symptoms:**
- User receives `AppForbidden` error code when attempting to open the CoE Setup and Upgrade Wizard
- Error message states: "The user with object id 'xxxxx' does not have permission to access this"

**Root Cause:**
The user attempting to access the CoE Setup and Upgrade Wizard does not have one of the required security roles assigned.

**Required Security Roles** (user must have at least one):
1. **Power Platform Admin SR** (recommended - included in CoE Core Components)
2. **System Administrator** (Dataverse system role)
3. **System Customizer** (Dataverse system role)

**Resolution:**

Assign the appropriate security role to the user:

1. Sign in to the [Power Platform admin center](https://admin.powerplatform.microsoft.com/)
2. Navigate to **Environments** and select the CoE environment
3. Select **Settings** > **Users + permissions** > **Users**
4. Select the user who needs access
5. Select **Manage security roles**
6. Check the **Power Platform Admin SR** role (or System Administrator/System Customizer)
7. Select **Save**
8. Have the user sign out and sign back in
9. Clear browser cache if needed

**Additional Notes:**
- If the Object ID in the error differs from the user's Azure AD Object ID, this may indicate an application user, service principal, or cached credentials issue
- Environment variables do not need to be configured to access the Setup Wizard, but they are required for the CoE Starter Kit to function properly
- Users must wait a few minutes after role assignment for permissions to propagate

**Related Documentation:**
- [Troubleshooting Guide: AppForbidden Error](../troubleshooting/AppForbidden-Setup-Wizard.md)
- [CoE Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Assign Security Roles](https://learn.microsoft.com/en-us/power-platform/admin/assign-security-roles)

**GitHub Issues:**
- Use this response for issues with tags: `permission`, `access-denied`, `AppForbidden`, `setup-wizard`

---

## Installation Issues

*(To be expanded with common installation issues)*

## Flow Failures

*(To be expanded with common flow failure patterns)*

## Data Issues

*(To be expanded with common data-related issues)*

---

## Contributing to This Document

If you encounter a new common issue or have improved solutions:

1. Document the issue following the format above
2. Include symptoms, root cause, resolution steps, and related documentation
3. Submit a pull request with your additions
4. Ensure all links are valid and up-to-date

For more information, see the [How to Contribute](../../HOW_TO_CONTRIBUTE.md) guide.
