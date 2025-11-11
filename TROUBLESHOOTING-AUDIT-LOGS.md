# Troubleshooting: Admin | Audit Logs | Sync Audit Logs (V2)

This document provides troubleshooting guidance for the "Admin | Audit Logs | Sync Audit Logs (V2)" flow, particularly addressing the common "Get_Azure_Secret" error.

## Common Issue: "Action 'Get_Azure_Secret' failed"

### Error Message
```
Action 'Get_Azure_Secret' failed: Error occurred while reading secret: Value cannot be null. Parameter name: input
```

### Understanding the Error

**This error is EXPECTED and HANDLED by the flow when you are using Client Secret (text-based) authentication instead of Azure Key Vault secrets.**

The flow is designed to support two types of authentication:
1. **Azure Key Vault Secret** - Stored in the `admin_auditlogsclientazuresecret` environment variable
2. **Client Secret (Text)** - Stored in the `admin_auditlogsclientsecret` environment variable

When the "Get_Azure_Secret" action fails (because you're using option 2), the flow automatically:
- Catches the failure
- Sets the `Secret_AzureType` variable to `false`
- Uses the text-based client secret instead

**The error you see in the flow run is NOT the actual cause of the flow failure.**

## Actual Root Cause

Based on the error screenshots and analysis, the actual issue is typically one of the following:

### 1. Missing or Incorrect Connector Permissions

The connectors **AuditLogQuery** and **ListAuditLogContent** require proper permissions to access the Microsoft 365 Management APIs.

#### Required Permissions:
- **API Permissions**: ActivityFeed.Read, ActivityFeed.ReadDlp
- **Application (App) Type**: Must be registered in Azure AD with these permissions granted

#### How to Fix:
1. Navigate to [Azure Portal](https://portal.azure.com)
2. Go to **Azure Active Directory** > **App registrations**
3. Find your app registration (using the Client ID from `admin_auditlogsclientid`)
4. Go to **API permissions**
5. Ensure the following permissions are added and **admin consent is granted**:
   - Office 365 Management APIs
     - ActivityFeed.Read
     - ActivityFeed.ReadDlp

### 2. Environment Variable Configuration

Ensure the following environment variables are properly configured:

| Environment Variable | Display Name | Required | Description |
|---------------------|--------------|----------|-------------|
| `admin_AuditLogsClientID` | Audit Logs - Client ID | Yes | The Application (client) ID from Azure AD |
| `admin_AuditLogsClientSecret` | Audit Logs - Client Secret | Yes (if not using Azure Key Vault) | The client secret value |
| `admin_AuditLogsClientAzureSecret` | Audit Logs - Client Azure Secret | No | The Key Vault reference (only if using Azure Key Vault) |
| `admin_AuditLogsUseGraphAPI` | Audit Logs - Use Graph API | Yes | Set to `yes` to use Graph API, `no` to use Office 365 Management API |

### 3. Verify Admin Consent

If you're seeing "Unauthorized" errors on the **ListAuditLogContent** action:

1. **Admin Consent Not Granted**: The Azure AD application requires admin consent for the API permissions
2. **Tenant ID Mismatch**: Ensure the Tenant ID in the environment variable matches your actual tenant
3. **Application Not Found**: The Client ID may be incorrect or the app registration was deleted

#### How to Grant Admin Consent:
1. Go to Azure Portal > Azure Active Directory > App registrations
2. Select your app
3. Go to **API permissions**
4. Click **Grant admin consent for [Your Tenant]**
5. Confirm the action

### 4. Connection Reference Issues

The flow uses connection references that must be properly authenticated:
- `admin_CoECoreDataverseForApps` - For Dataverse operations
- Ensure all connections are authenticated with an account that has necessary permissions

## Troubleshooting Steps

Follow these steps to diagnose and fix the issue:

### Step 1: Verify Environment Variables
1. Open the Power Platform admin center
2. Navigate to your environment
3. Go to **Settings** > **Environment variables**
4. Verify these variables have values:
   - `admin_AuditLogsClientID` - Should contain your Azure AD App Client ID
   - `admin_AuditLogsClientSecret` - Should contain your Client Secret (if not using Key Vault)
   - `admin_AuditLogsUseGraphAPI` - Should be set to `yes` or `no` based on your preference

### Step 2: Check Azure AD App Registration
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **App registrations**
3. Find your app using the Client ID from environment variable
4. Verify the app exists and is not expired
5. Check **Certificates & secrets** to ensure the secret is not expired

### Step 3: Verify API Permissions
1. In your app registration, go to **API permissions**
2. Ensure you have the following:
   - **Office 365 Management APIs**:
     - ActivityFeed.Read (Application)
     - ActivityFeed.ReadDlp (Application)
   - Or if using Graph API (`admin_AuditLogsUseGraphAPI` = yes):
     - **Microsoft Graph**:
       - AuditLog.Read.All (Application)
3. Verify **Admin consent granted** shows "Yes" with a green checkmark
4. If not, click **Grant admin consent for [Your Tenant]**

### Step 4: Test the Connection
1. Create a test flow that uses the same authentication:
   ```
   HTTP Action with:
   - Method: GET
   - URI: https://manage.office.com/api/v1.0/{tenantId}/activity/feed/subscriptions/list
   - Authentication: Active Directory OAuth
     - Authority: https://login.windows.net
     - Tenant: {Your Tenant ID}
     - Audience: https://manage.office.com
     - Client ID: {Your Client ID from environment variable}
     - Secret: {Your Client Secret from environment variable}
   ```
2. Run the test flow
3. If it succeeds, the issue is elsewhere in the flow
4. If it fails, check the error message for specific permission issues

### Step 5: Review Flow Run History
1. Open the flow "Admin | Audit Logs | Sync Audit Logs (V2)"
2. Check the run history
3. Look for the action that is ACTUALLY failing (not Get_Azure_Secret)
4. Common failure points:
   - **AuditLogQuery** - Graph API permission issues
   - **ListAuditLogContent** - Office 365 Management API permission issues
   - Connection authentication failures

### Step 6: Verify Graph API vs Management API Setting
The flow behavior differs based on the `admin_AuditLogsUseGraphAPI` setting:

**If `admin_AuditLogsUseGraphAPI` = yes (true):**
- Uses Microsoft Graph API
- Requires `AuditLog.Read.All` permission
- Uses the AuditLogQuery action
- More efficient with built-in filtering

**If `admin_AuditLogsUseGraphAPI` = no (false):**
- Uses Office 365 Management API
- Requires `ActivityFeed.Read` and `ActivityFeed.ReadDlp` permissions
- Uses ListAuditLogContent action
- Legacy approach

Ensure your API permissions match your setting.

## FAQ

### Q: Should I be concerned about the "Get_Azure_Secret" error?
**A:** No. If you're using Client Secret (text-based) authentication, this error is expected and automatically handled by the flow. The flow will use the text secret from the `admin_auditlogsclientsecret` environment variable.

### Q: When should I use Azure Key Vault for secrets?
**A:** Use Azure Key Vault if:
- Your organization's security policy requires it
- You want centralized secret management
- You need secret rotation capabilities
- You prefer not to store secrets in environment variables

### Q: Can I switch from Client Secret to Azure Key Vault?
**A:** Yes. To switch:
1. Set up Azure Key Vault
2. Store your client secret in Key Vault
3. Create an environment variable `admin_auditlogsclientazuresecret` with the Key Vault reference
4. The flow will automatically detect and use it

### Q: Why is my Power BI Dashboard not showing app details?
**A:** The Power BI Dashboard "App Deep Dive" page requires data from audit logs. If the "Sync Audit Logs (V2)" flow is failing, no audit log data is collected, resulting in empty details when drilling into apps. Fix the flow first, wait for it to collect data, then refresh your Power BI report.

### Q: How often does the flow run?
**A:** By default, the flow runs every hour. You can change this in the flow's recurrence trigger.

### Q: Can I manually trigger the flow?
**A:** Yes. Open the flow in Power Automate and click "Run" to manually trigger it. This is useful for testing after making configuration changes.

## Related Environment Variables Reference

| Variable Schema Name | Display Name | Type | Required | Description |
|---------------------|--------------|------|----------|-------------|
| `admin_TenantID` | Tenant ID | String | Yes | Your Azure AD Tenant ID |
| `admin_AuditLogsClientID` | Audit Logs - Client ID | String | Yes | Azure AD App Registration Client ID |
| `admin_AuditLogsClientSecret` | Audit Logs - Client Secret | String | Conditional | Client secret (required if not using Key Vault) |
| `admin_AuditLogsClientAzureSecret` | Audit Logs - Client Azure Secret | String | Conditional | Key Vault reference (required if using Key Vault) |
| `admin_AuditLogsUseGraphAPI` | Audit Logs - Use Graph API | Boolean | Yes | `yes` for Graph API, `no` for Office 365 Management API |
| `admin_AuditLogsAudience` | Audit Logs - Audience | String | Yes | Default: `https://manage.office.com` |
| `admin_AuditLogsAuthority` | Audit Logs - Authority | String | Yes | Default: `https://login.windows.net` |
| `admin_GraphURLEnvironmentVariable` | Graph URL Environment Variable | String | Yes | Default: `https://graph.microsoft.com/` |
| `admin_AuditLogsMinutestoLookBack` | Audit Logs - Minutes to Look Back | Integer | Yes | Default: 65 minutes |
| `admin_AuditLogsEndTimeMinutesAgo` | Audit Logs - End Time Minutes Ago | Integer | Yes | Default: 0 (current time) |

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Office 365 Management APIs](https://learn.microsoft.com/office/office-365-management-api/office-365-management-apis-overview)
- [Microsoft Graph Audit Log API](https://learn.microsoft.com/graph/api/resources/azure-ad-auditlog-overview)
- [Azure AD App Registration](https://learn.microsoft.com/azure/active-directory/develop/quickstart-register-app)

## Still Having Issues?

If you've followed all the troubleshooting steps and are still experiencing issues:

1. Gather the following information:
   - Flow run ID
   - Screenshot of the actual failing action (not Get_Azure_Secret)
   - Error messages from the failing action
   - Confirmation that admin consent was granted
   - Your `admin_AuditLogsUseGraphAPI` setting value

2. Create an issue on the [CoE Starter Kit GitHub repository](https://github.com/microsoft/coe-starter-kit/issues) using the bug report template

3. Include all gathered information to help the team diagnose the issue quickly
