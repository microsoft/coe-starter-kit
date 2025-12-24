# Issue Response Template: Office 365 Management API Subscription Flow - Get_Azure_Secret Error

Use this template when responding to issues related to the Office 365 Management API Subscription flow failing with "Get_Azure_Secret" errors.

---

## Response Template

Thank you for reporting this issue. The error you're experiencing with the **Admin | Audit Logs | Office 365 Management API Subscription** flow is a common configuration issue related to missing or empty environment variables.

### Summary

The error `Action 'Get_Azure_Secret' failed. Error occurred while reading secret: Value cannot be null. Parameter name: input` occurs when the flow attempts to retrieve the Azure Key Vault secret for Office 365 Management API authentication but the required environment variable is not configured.

### Root Cause

The flow expects one of these environment variables to be configured:
- `admin_auditlogsclientazuresecret` (Azure Key Vault-based secret - recommended)
- `admin_auditlogsclientsecret` (text-based secret - simpler setup)

When neither is properly configured, the flow fails at the `Get_Azure_Secret` action.

### Quick Resolution

For a fast resolution, please follow our **[Quick Fix Guide](../docs/troubleshooting/QUICK-FIX-audit-logs-get-azure-secret-error.md)** which provides a checklist and the fastest path to get your flow working.

**TL;DR**:
1. Verify environment variables exist and have values (Solutions > Environment variables)
2. Set up an Azure AD app registration with Office 365 Management API permissions
3. Configure `admin_auditlogsclientid` with your Application (Client) ID
4. Configure `admin_auditlogsclientsecret` with your client secret value
5. Configure `admin_TenantID` with your Azure Tenant ID
6. Rerun the flow

### Detailed Troubleshooting

For comprehensive troubleshooting steps, including:
- Understanding the flow logic and fallback mechanisms
- Azure AD app registration setup
- Azure Key Vault configuration
- Cloud-specific endpoint configurations
- Common errors and their solutions

Please see our **[Detailed Troubleshooting Guide](../docs/troubleshooting/audit-logs-office365-management-api-subscription-flow-errors.md)**.

### Prerequisites

Before using this flow, ensure:
1. ✅ Unified Audit Log is enabled in Microsoft Purview
2. ✅ You have appropriate licenses (Office 365/Microsoft 365 E3 or E5)
3. ✅ You have required admin permissions (Azure AD Application Administrator, Power Platform System Administrator)

### Related Issues

This issue is similar to:
- Missing environment variable configurations during initial setup
- Azure AD app registration not properly configured
- Client secrets that have expired

### Next Steps

After following the troubleshooting guides:
1. Test the flow with the `list` operation to verify the configuration
2. If successful, you can proceed with `start` or `stop` operations
3. If you continue to experience issues, please provide:
   - Screenshot of your environment variables (with sensitive values redacted)
   - Flow run history screenshot showing the specific error
   - Your CoE Starter Kit version
   - Your cloud environment type (Commercial, GCC, GCC High, etc.)

### Additional Resources

- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Set Up Audit Log Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Office 365 Management Activity API Reference](https://learn.microsoft.com/office/office-365-management-api/office-365-management-activity-api-reference)

---

Please let us know if you have any questions or if you're still experiencing issues after following these guides!

---

## Customization Notes for Responders

When using this template:
1. Replace relative links with full GitHub links to the documentation files
2. Adjust the response based on the specific details provided by the issue reporter
3. If they've already tried some steps, acknowledge that and focus on what they haven't tried
4. If multiple issues are reported, address each one or ask them to split into separate issues
5. Add labels: `area: audit logs`, `type: configuration`, `status: needs information` (if waiting for user response)
