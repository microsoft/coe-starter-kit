# Troubleshooting: Admin | Audit Logs | Office 365 Management API Subscription Flow Errors

## Issue Description

The **Admin | Audit Logs | Office 365 Management API Subscription** flow fails with the following error:

```
Action 'Get_Azure_Secret' failed.
Error occurred while reading secret: Value cannot be null. Parameter name: input
```

## Root Causes

This error occurs when the flow attempts to retrieve the Azure Key Vault secret for the Office 365 Management API authentication but encounters one of the following issues:

1. **Missing Environment Variable**: The environment variable `admin_auditlogsclientazuresecret` does not exist in your environment
2. **Empty Environment Variable**: The environment variable exists but has no value configured
3. **Incorrect Setup**: The Azure Key Vault integration was not properly configured during setup
4. **Missing Fallback Secret**: Neither the Azure Key Vault secret nor the text-based secret (`admin_auditlogsclientsecret`) is configured

## Understanding the Flow Logic

The flow uses a two-tier approach for secret management:

1. **Primary Method (Azure Key Vault)**: Attempts to retrieve the secret from Azure Key Vault using the `admin_auditlogsclientazuresecret` environment variable
2. **Fallback Method (Text Secret)**: If the Azure Key Vault retrieval fails, it falls back to using the text-based secret from `admin_auditlogsclientsecret` environment variable

The error occurs when the `Get_Azure_Secret` action receives a null or empty input, preventing it from even attempting to retrieve the secret.

## Required Environment Variables

The flow requires one of the following configurations:

### Option 1: Azure Key Vault (Recommended for Production)
- **admin_auditlogsclientid**: The Application (Client) ID of the Azure AD app registration
- **admin_auditlogsclientazuresecret**: The Azure Key Vault secret reference for the client secret

### Option 2: Text-based Secret (For Testing/Development)
- **admin_auditlogsclientid**: The Application (Client) ID of the Azure AD app registration
- **admin_auditlogsclientsecret**: The client secret value stored as a plain text environment variable

### Additional Required Variables
- **admin_TenantID**: Your Azure Tenant ID
- **admin_AuditLogsAudience**: The audience URL (default: `https://manage.office.com`)
- **admin_AuditLogsAuthority**: The authority URL (default: `https://login.windows.net`)

## Troubleshooting Steps

### Step 1: Verify Environment Variables Exist

1. Navigate to your **CoE Governance** environment in Power Platform Admin Center
2. Go to **Solutions** > Open the **Center of Excellence - Core Components** solution
3. Select **Environment variables** from the left navigation
4. Check if the following environment variables exist:
   - `admin_auditlogsclientid`
   - `admin_auditlogsclientazuresecret` OR `admin_auditlogsclientsecret`
   - `admin_TenantID`
   - `admin_AuditLogsAudience`
   - `admin_AuditLogsAuthority`

### Step 2: Verify Environment Variable Values

1. For each environment variable found in Step 1:
   - Click on the environment variable to open it
   - Check if the **Current Value** field has a value
   - If the Current Value is empty, you need to add a value

### Step 3: Configure Azure AD App Registration

If you haven't set up the Azure AD app registration for Office 365 Management API:

1. **Register an Azure AD Application**:
   - Go to Azure Portal > Azure Active Directory > App registrations
   - Click "New registration"
   - Name: "CoE Audit Logs API Access" (or similar)
   - Supported account types: "Accounts in this organizational directory only"
   - Click "Register"

2. **Configure API Permissions**:
   - In your app registration, go to "API permissions"
   - Click "Add a permission"
   - Select "Office 365 Management APIs"
   - Select "Application permissions"
   - Add the following permissions:
     - `ActivityFeed.Read`
     - `ActivityFeed.ReadDlp`
     - `ServiceHealth.Read`
   - Click "Grant admin consent" (requires Global Admin or Application Admin role)

3. **Create a Client Secret**:
   - In your app registration, go to "Certificates & secrets"
   - Click "New client secret"
   - Add a description and select expiration period
   - Click "Add"
   - **Important**: Copy the secret value immediately (you won't be able to see it again)

4. **Get the Application (Client) ID**:
   - From the app registration Overview page, copy the "Application (client) ID"

### Step 4: Configure Environment Variables

#### Option A: Using Azure Key Vault (Recommended)

1. **Set up Azure Key Vault** (if not already done):
   - Create an Azure Key Vault in your Azure subscription
   - Add the client secret to Key Vault with a descriptive name (e.g., "coe-audit-logs-secret")
   - Configure access policies to allow your Power Platform environment to read secrets

2. **Configure Environment Variables**:
   - In Power Platform, set `admin_auditlogsclientid` to your Application (Client) ID
   - Set `admin_auditlogsclientazuresecret` as a "Secret" type and link it to your Azure Key Vault secret
   - Set `admin_TenantID` to your Azure Tenant ID

#### Option B: Using Text-based Secret (Simple Setup)

1. **Configure Environment Variables**:
   - In Power Platform, set `admin_auditlogsclientid` to your Application (Client) ID
   - Set `admin_auditlogsclientsecret` to your client secret value
   - Set `admin_TenantID` to your Azure Tenant ID
   - **Note**: This stores the secret in plain text; use Azure Key Vault for production environments

### Step 5: Verify Tenant ID and Endpoint Configuration

1. Verify `admin_TenantID`:
   - Go to Azure Portal > Azure Active Directory > Overview
   - Copy the "Tenant ID"
   - Update the environment variable if needed

2. Verify endpoint configurations based on your cloud:
   - **Commercial Cloud**:
     - `admin_AuditLogsAudience`: `https://manage.office.com`
     - `admin_AuditLogsAuthority`: `https://login.windows.net`
   - **GCC (US Government)**:
     - `admin_AuditLogsAudience`: `https://manage.office365.us`
     - `admin_AuditLogsAuthority`: `https://login.microsoftonline.us`
   - **GCC High**:
     - `admin_AuditLogsAudience`: `https://manage.office365.us`
     - `admin_AuditLogsAuthority`: `https://login.microsoftonline.us`

### Step 6: Test the Flow

1. Open the **Admin | Audit Logs | Office 365 Management API Subscription** flow
2. Click "Run" or "Test"
3. When prompted, enter one of the following operations:
   - `list` - Check if subscription exists
   - `start` - Start the subscription
   - `stop` - Stop the subscription
4. Review the run history:
   - If successful, you should see a "Succeeded" status
   - If it fails, check the error details in the flow run history

### Step 7: Verify Flow Connections

1. Open the flow in edit mode
2. Check all connection references:
   - Dataverse connections should be properly authenticated
   - No warnings or errors should appear on actions
3. If you see connection errors:
   - Click "Edit" on the connection
   - Re-authenticate with an account that has appropriate permissions

## Common Errors and Solutions

### Error: "Value cannot be null. Parameter name: input"

**Solution**: The environment variable for the Azure secret is not configured. Follow Step 4 above to configure either `admin_auditlogsclientazuresecret` or `admin_auditlogsclientsecret`.

### Error: "Unauthorized" or "401" status code

**Solution**: 
1. Verify the client secret hasn't expired
2. Check that API permissions are properly configured and admin consent is granted
3. Verify the Application (Client) ID is correct

### Error: "Forbidden" or "403" status code

**Solution**:
1. Ensure the Azure AD app has the required API permissions (`ActivityFeed.Read`, `ActivityFeed.ReadDlp`)
2. Verify admin consent has been granted for the permissions
3. Check that the service principal is enabled in your tenant

### Error: "The remote server returned an error: (404) Not Found"

**Solution**:
1. Verify you're using the correct audience URL for your cloud environment
2. Ensure the tenant ID is correct
3. Check that Office 365 audit logging is enabled in your tenant

## Prerequisites

Before using the Office 365 Management API Subscription flow, ensure:

1. **Unified Audit Log is enabled**: 
   - Go to Microsoft Purview compliance portal > Audit
   - Verify audit log search is enabled
   - If disabled, turn it on (may take up to 24 hours to become active)

2. **Required Licenses**: 
   - Office 365 E3/E5 or Microsoft 365 E3/E5 licenses
   - Audit logging capabilities are included in these licenses

3. **Required Permissions**:
   - Azure AD: Application Administrator or Global Administrator (for app registration)
   - Power Platform: System Administrator on the CoE environment
   - Office 365: Global Administrator (to enable audit logging)

## Related Documentation

- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Set Up Audit Log Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Office 365 Management Activity API Reference](https://learn.microsoft.com/office/office-365-management-api/office-365-management-activity-api-reference)
- [Enable or disable unified audit logging](https://learn.microsoft.com/microsoft-365/compliance/audit-log-enable-disable)

## Prevention

To prevent this issue in future deployments:

1. **Use the Setup Wizard**: The CoE Starter Kit includes a setup wizard that guides you through configuring all required environment variables
2. **Document Your Configuration**: Keep a record of all environment variables and their purposes
3. **Use Azure Key Vault**: For production environments, always use Azure Key Vault for storing secrets
4. **Monitor Secret Expiration**: Set up alerts for when client secrets are about to expire
5. **Regular Testing**: Periodically test the flow to ensure it's working correctly

## Additional Support

If you continue to experience issues after following these steps:

1. Check the [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
2. Review the flow run history for detailed error messages
3. Enable flow run history with detailed tracking to get more diagnostic information
4. File a new issue on GitHub with:
   - CoE Starter Kit version
   - Error message and flow run history screenshot
   - Steps you've already taken to troubleshoot
   - Your cloud environment type (Commercial, GCC, etc.)

## Summary

The "Value cannot be null" error in the Office 365 Management API Subscription flow is typically caused by missing or empty environment variables for authentication. By following the troubleshooting steps above, you should be able to:

1. Identify which environment variables are missing or empty
2. Configure the Azure AD app registration properly
3. Set up the correct authentication method (Azure Key Vault or text-based)
4. Successfully run the subscription flow

Remember that the flow supports both Azure Key Vault and text-based secrets, so you can choose the method that best fits your security requirements and environment setup.
