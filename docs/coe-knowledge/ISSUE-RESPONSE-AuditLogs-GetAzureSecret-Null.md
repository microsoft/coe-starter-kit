# Issue Response: Admin | Audit Logs | Office 365 Management API Subscription Flow Fails

## Summary
The `Admin | Audit Logs | Office 365 Management API Subscription` flow fails with error "Get_Azure_Secret - Value cannot be null" because the required environment variables for Office 365 Management API authentication are not configured.

## Root Cause
In managed CoE Starter Kit installations, environment variables that were not provided during solution import become read-only. The flow requires Azure AD app credentials (`admin_auditlogsclientid`, `admin_auditlogsclientsecret` or `admin_auditlogsclientazuresecret`, and `admin_TenantID`) to authenticate with the Office 365 Management API, but these values are missing or null.

## Quick Resolution

### Prerequisites
1. Create an Azure AD App Registration
2. Grant `ActivityFeed.Read` permission for Office 365 Management APIs
3. Create a Client Secret
4. Have ready:
   - Application (Client) ID
   - Client Secret VALUE (the actual secret, not the name or ID)
   - Azure Directory (Tenant) ID

### Steps to Fix

1. **Open the CoE Setup & Upgrade Wizard**
   - Navigate to [Power Apps](https://make.powerapps.com)
   - Select your CoE environment
   - Go to Solutions → Center of Excellence – Core Components
   - Launch the CoE Setup & Upgrade Wizard

2. **Configure Audit Logs Settings**
   - In the wizard, navigate to Inventory / Audit Logs
   - Provide:
     - **Audit Logs – Client ID**: Your Application (Client) ID
     - **Audit Logs – Client Secret**: The actual Client Secret VALUE
     - **Tenant ID**: Your Azure Directory (Tenant) ID

3. **Save and Test**
   - Complete the wizard
   - Go to Power Automate → Cloud flows
   - Find `Admin | Audit Logs | Office 365 Management API Subscription`
   - Turn the flow On
   - Run the flow to verify it completes successfully

## Detailed Documentation

For comprehensive troubleshooting steps, including alternative resolution methods and common errors:
- **[Troubleshooting Guide](docs/coe-knowledge/TROUBLESHOOT-AuditLogs-Office365ManagementAPI.md)** - Complete troubleshooting documentation
- **[Common Responses](docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md#audit-logs-configuration)** - Quick reference for audit logs issues

## Important Notes

⚠️ **For Managed Solutions**: Environment variables cannot be edited directly in the UI. You must use:
1. The CoE Setup & Upgrade Wizard (recommended), or
2. Re-import the solution and provide values during import

⚠️ **Client Secret**: Enter the actual secret VALUE, not the secret name or secret ID from Azure AD

## Additional Resources
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Configure Audit Logs](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

---

This response is based on the comprehensive troubleshooting documentation created for this issue. For more details, see the [CoE Knowledge Base](docs/coe-knowledge/README.md).
