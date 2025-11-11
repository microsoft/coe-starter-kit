# Audit Logs Setup and Configuration Guide

This guide explains how to properly configure the Audit Logs feature in the CoE Starter Kit.

## Overview

The CoE Starter Kit includes flows that collect audit logs from Microsoft 365 to track Power Apps usage and deletion events. The main flow is:

- **Admin | Audit Logs | Sync Audit Logs (V2)** - Collects audit logs for app launches and deletions

## Authentication Configuration

The flow supports two methods of authentication with Microsoft 365 Audit APIs:

### Method 1: Client Secret (Text-based) - Recommended for Most Users

This method stores the client secret as a plain text environment variable.

**Environment Variables Required:**
- `admin_AuditLogsClientID` - Your Azure AD App Client ID
- `admin_AuditLogsClientSecret` - Your Azure AD App Client Secret

**Pros:**
- Simpler setup
- No additional Azure services required
- Easier to troubleshoot

**Cons:**
- Secret stored in environment variable (still encrypted by platform)
- Manual secret rotation required

### Method 2: Azure Key Vault Secret

This method retrieves the client secret from Azure Key Vault.

**Environment Variables Required:**
- `admin_AuditLogsClientID` - Your Azure AD App Client ID
- `admin_AuditLogsClientAzureSecret` - Azure Key Vault reference to the secret

**Pros:**
- Centralized secret management
- Audit trail for secret access
- Supports secret rotation

**Cons:**
- Requires Azure Key Vault setup
- Additional Azure resources needed
- More complex configuration

## How the Flow Handles Authentication

The flow logic is designed to automatically handle both authentication methods:

```
1. Try to get secret from Azure Key Vault (Get_Azure_Secret action)
   ├─ Success → Use Azure Key Vault secret
   └─ Failure → Set Secret_AzureType = false
                └─ Use text-based secret from environment variable
```

**Important:** If you see an error on the "Get_Azure_Secret" action, this is EXPECTED when using Method 1 (Client Secret). The flow handles this error and continues with the text-based secret.

## Setup Instructions

### Prerequisites

1. **Azure AD App Registration** with the following:
   - Application (client) ID
   - Client secret (not expired)
   - Proper API permissions (see below)

2. **API Permissions** - Choose based on your API preference:

   **Option A: Microsoft Graph API (Recommended)**
   - `AuditLog.Read.All` (Application permission)
   - Set `admin_AuditLogsUseGraphAPI` = `yes`
   
   **Option B: Office 365 Management API (Legacy)**
   - `ActivityFeed.Read` (Application permission)
   - `ActivityFeed.ReadDlp` (Application permission)
   - Set `admin_AuditLogsUseGraphAPI` = `no`

3. **Admin Consent** - Must be granted for all permissions

### Step-by-Step Setup

#### Step 1: Create Azure AD App Registration

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Go to **Azure Active Directory** > **App registrations** > **New registration**
3. Enter a name (e.g., "CoE Audit Logs")
4. Select **Accounts in this organizational directory only**
5. Click **Register**
6. **Copy the Application (client) ID** - you'll need this for the environment variable
7. **Copy the Directory (tenant) ID** - you'll need this for the tenant ID variable

#### Step 2: Create Client Secret

1. In your app registration, go to **Certificates & secrets**
2. Click **New client secret**
3. Enter a description (e.g., "CoE Starter Kit")
4. Select an expiration period (maximum 24 months)
5. Click **Add**
6. **Copy the secret value immediately** - you cannot retrieve it later
7. Note the expiration date to plan for secret renewal

#### Step 3: Add API Permissions

**If using Microsoft Graph API:**

1. In your app registration, go to **API permissions**
2. Click **Add a permission**
3. Select **Microsoft Graph**
4. Select **Application permissions**
5. Search for and select **AuditLog.Read.All**
6. Click **Add permissions**
7. Click **Grant admin consent for [Your Tenant]**
8. Verify the status shows "Granted for [Your Tenant]"

**If using Office 365 Management API:**

1. In your app registration, go to **API permissions**
2. Click **Add a permission**
3. Select **Office 365 Management APIs**
4. Select **Application permissions**
5. Search for and select:
   - **ActivityFeed.Read**
   - **ActivityFeed.ReadDlp**
6. Click **Add permissions**
7. Click **Grant admin consent for [Your Tenant]**
8. Verify the status shows "Granted for [Your Tenant]"

#### Step 4: Configure Environment Variables in Power Platform

1. Navigate to [Power Platform admin center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Go to **Settings** > **Environment variables**
4. Configure the following variables:

| Variable | Value |
|----------|-------|
| `admin_TenantID` | Your Azure AD Tenant ID (Directory ID) |
| `admin_AuditLogsClientID` | Your App Registration Client ID |
| `admin_AuditLogsClientSecret` | Your Client Secret value |
| `admin_AuditLogsUseGraphAPI` | `yes` (for Graph API) or `no` (for Management API) |
| `admin_AuditLogsAudience` | `https://manage.office.com` (for Management API) or `https://graph.microsoft.com/` (for Graph API) |
| `admin_AuditLogsAuthority` | `https://login.windows.net` |
| `admin_GraphURLEnvironmentVariable` | `https://graph.microsoft.com/` |

5. Save all changes

#### Step 5: Test the Flow

1. Open Power Automate
2. Navigate to your CoE environment
3. Find the flow "Admin | Audit Logs | Sync Audit Logs (V2)"
4. Click **Run** to manually trigger the flow
5. Monitor the flow run:
   - ✅ If using text secret, "Get_Azure_Secret" will fail (this is expected)
   - ✅ The flow should continue and complete successfully
   - ✅ Check that audit log records are created in the Dataverse

#### Step 6: Verify Data Collection

1. After the flow runs successfully, open the **Power Platform Admin View** app
2. Navigate to **Audit Logs**
3. Verify that audit log records are being created
4. Check the timestamps to ensure recent data is being collected

## Maintenance

### Secret Renewal

Client secrets have an expiration date (maximum 24 months). Before the secret expires:

1. Create a new secret in Azure AD App registration
2. Update the `admin_AuditLogsClientSecret` environment variable with the new value
3. Test the flow to ensure it works with the new secret
4. Delete the old secret from Azure AD

### Monitoring

- Set up alerts for flow failures
- Review the CoE Solution Metadata table for last run status
- Check the Sync Flow Errors table for any logged issues

## Troubleshooting

If you encounter issues, see the [Audit Logs Troubleshooting Guide](../TROUBLESHOOTING-AUDIT-LOGS.md) for detailed troubleshooting steps.

Common issues:
- "Get_Azure_Secret" error (expected when using client secret)
- "Unauthorized" errors (permission or consent issues)
- No data collected (connector permission issues)

## Architecture Notes

### Flow Behavior

The flow runs every hour by default and:

1. Calculates the time window for audit log collection
2. Retrieves authentication credentials
3. Queries the audit logs API (Graph or Management API)
4. Processes the results
5. Creates or updates audit log records in Dataverse
6. Marks deleted apps appropriately

### Data Retention

- Audit logs are stored in the `admin_auditlogs` table in Dataverse
- Power BI reports use this data for analytics
- Configure cleanup flows if needed for data retention policies

### Performance Considerations

- Default: Collects 65 minutes of audit logs per run
- Runs hourly to ensure no gaps in data
- Adjust `admin_AuditLogsMinutestoLookBack` if needed
- Use `admin_AuditLogsEndTimeMinutesAgo` to avoid incomplete data

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Troubleshooting Guide](../TROUBLESHOOTING-AUDIT-LOGS.md)
- [Office 365 Management APIs](https://learn.microsoft.com/office/office-365-management-api/office-365-management-apis-overview)
- [Microsoft Graph Audit Log API](https://learn.microsoft.com/graph/api/resources/azure-ad-auditlog-overview)
