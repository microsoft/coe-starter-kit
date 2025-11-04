# Issue Response Template: Get_Azure_Secret Error in Sync Audit Logs V2

## Quick Response

Thank you for reporting this issue. The "Get_Azure_Secret" error you're seeing is **expected behavior** when using Client Secret (text-based) authentication, and the flow is designed to handle this automatically.

### What's Actually Happening

The flow tries two authentication methods in this order:

1. **Azure Key Vault Secret** (via `admin_auditlogsclientazuresecret`)
2. **Client Secret Text** (via `admin_auditlogsclientsecret`)

When you're using method 2 (Client Secret), the "Get_Azure_Secret" action will fail, but this failure is caught and the flow continues using your text-based secret. **This is by design.**

### The Real Issue

Based on your screenshots showing "Unauthorized" errors on the **ListAuditLogContent** action, the actual problem is with **connector permissions**, not the Get_Azure_Secret action.

## Root Cause Analysis

The issue is typically one of the following:

1. **Missing API Permissions** on your Azure AD App Registration
2. **Admin Consent Not Granted** for the required permissions
3. **Expired Client Secret**
4. **Incorrect Environment Variables**

## Resolution Steps

### 1. Verify Azure AD App Permissions

Go to [Azure Portal](https://portal.azure.com) → Azure Active Directory → App registrations → [Your App]

**If `admin_AuditLogsUseGraphAPI` = yes:**
- Ensure **Microsoft Graph** > **AuditLog.Read.All** (Application) permission is added
- Verify admin consent is granted

**If `admin_AuditLogsUseGraphAPI` = no:**
- Ensure **Office 365 Management APIs** permissions:
  - **ActivityFeed.Read** (Application)
  - **ActivityFeed.ReadDlp** (Application)
- Verify admin consent is granted

### 2. Grant Admin Consent

In your Azure AD App registration:
1. Go to **API permissions**
2. Click **Grant admin consent for [Your Tenant]**
3. Confirm the action
4. Wait a few minutes for propagation

### 3. Verify Environment Variables

Check these environment variables in Power Platform admin center:
- ✅ `admin_AuditLogsClientID` - Contains your Client ID
- ✅ `admin_AuditLogsClientSecret` - Contains your Client Secret
- ✅ `admin_AuditLogsUseGraphAPI` - Set to `yes` or `no` (matches your API choice)
- ✅ `admin_TenantID` - Contains your Tenant ID

### 4. Test the Connection

After making changes:
1. Wait 5-10 minutes for permissions to propagate
2. Manually run the flow
3. Check the flow run history - the actual failing action should now succeed

## For Your Power BI Dashboard Issue

The Power BI "App Deep Dive" page requires audit log data. Once you fix the connector permissions and the flow runs successfully, wait for at least one hour of data collection, then refresh your Power BI report.

## Documentation

For detailed troubleshooting steps, see:
- [Audit Logs Setup Guide](../../CenterofExcellenceCoreComponents/AUDIT-LOGS-SETUP.md)
- [Troubleshooting Guide](../../TROUBLESHOOTING-AUDIT-LOGS.md)

## Still Having Issues?

If you've followed these steps and the issue persists, please provide:
1. Screenshot of the **actual failing action** (not Get_Azure_Secret)
2. Confirmation that admin consent was granted (screenshot of API permissions page)
3. Your `admin_AuditLogsUseGraphAPI` setting value
4. Flow run ID for investigation

---

**Summary:** The Get_Azure_Secret error is not the issue - it's expected when using Client Secret. Focus on fixing the connector permissions as outlined above.
