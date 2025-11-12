# Troubleshooting Guide - CoE Audit Log Components

This document provides troubleshooting guidance for common issues encountered when setting up and using the CoE Audit Log components.

## Table of Contents
- [Azure Key Vault Access Issues](#azure-key-vault-access-issues)
- [Flow Authentication Errors](#flow-authentication-errors)
- [Common Setup Issues](#common-setup-issues)

---

## Azure Key Vault Access Issues

### Error: Microsoft.PowerPlatform provider not registered

**Error Message:**
```
Error occurred while reading secret: Could not verify the user permission on '/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.KeyVault/vaults/{vault-name}/secrets/{secret-name}' resource. Make sure that Microsoft.PowerPlatform provider is registered in the Azure subscription.
```

**Symptoms:**
- Audit sync flows fail when attempting to read secrets from Azure Key Vault
- Error appears in flow run history showing permission verification failure
- Configuration works in DEV but fails in PROD environment

**Root Cause:**
The Microsoft.PowerPlatform resource provider is not registered in the Azure subscription. This registration is required for Power Platform to access Azure Key Vault resources.

**Resolution:**

#### Option 1: Register via Azure Portal (Recommended)

1. **Navigate to Azure Portal**
   - Go to https://portal.azure.com
   - Sign in with an account that has Subscription Contributor or Owner permissions

2. **Access Subscription Settings**
   - In the search bar at the top, search for and select "Subscriptions"
   - Click on the subscription where your Key Vault is located

3. **Register the Resource Provider**
   - In the left navigation menu, under "Settings", click on "Resource providers"
   - In the search box, type "Microsoft.PowerPlatform"
   - Select "Microsoft.PowerPlatform" from the list
   - Click the "Register" button at the top
   - Wait for the status to change from "Registering" to "Registered" (this may take a few minutes)

   ![Resource Provider Registration](https://learn.microsoft.com/azure/azure-resource-manager/management/media/resource-providers-and-types/register-provider.png)

#### Option 2: Register via Azure CLI

```bash
# Login to Azure
az login

# Set the correct subscription
az account set --subscription "{subscription-id}"

# Register the Microsoft.PowerPlatform provider
az provider register --namespace Microsoft.PowerPlatform

# Verify registration status
az provider show --namespace Microsoft.PowerPlatform --query "registrationState"
```

#### Option 3: Register via PowerShell

```powershell
# Login to Azure
Connect-AzAccount

# Set the correct subscription
Set-AzContext -SubscriptionId "{subscription-id}"

# Register the Microsoft.PowerPlatform provider
Register-AzResourceProvider -ProviderNamespace Microsoft.PowerPlatform

# Verify registration status
Get-AzResourceProvider -ProviderNamespace Microsoft.PowerPlatform | Select-Object ProviderNamespace, RegistrationState
```

**Verification:**
After registering the provider, wait 5-10 minutes for the registration to fully propagate, then:
1. Go back to your Power Automate flow
2. Click "Resubmit" on the failed flow run
3. The flow should now successfully retrieve the secret from Azure Key Vault

---

### Error: Invalid client secret provided

**Error Message:**
```
BadRequest: Http request failed as there is an error getting AD OAuth token: 'AADSTS7000215: Invalid client secret provided. Ensure the secret being sent in the request is the client secret value, not the client secret ID, for a secret added to app '{app-id}'.
```

**Root Cause:**
- The wrong value was copied when setting up the client secret in the CoE environment variable
- The secret ID was used instead of the secret value
- The secret has expired

**Resolution:**

1. **Verify Azure AD App Registration Secret**
   - Go to Azure Portal > Azure Active Directory > App registrations
   - Find and select your Audit Log app registration
   - Go to "Certificates & secrets"
   - Check if the secret has expired (if yes, create a new one)
   
2. **Create a New Secret (if needed)**
   - Click "New client secret"
   - Add a description (e.g., "CoE Audit Log - {environment}")
   - Select an expiration period
   - Click "Add"
   - **IMPORTANT**: Copy the secret VALUE immediately (not the Secret ID). The value is only shown once and cannot be retrieved later.

3. **Update Azure Key Vault**
   - Go to Azure Portal > Key Vaults > Select your Key Vault
   - Go to "Secrets"
   - Select the secret used for the Audit Log (e.g., "COEAuditID")
   - Click "New Version"
   - Paste the secret VALUE you copied earlier
   - Click "Create"

4. **Test the Connection**
   - Return to your Power Automate flow
   - Resubmit the failed flow run or trigger manually
   - Verify the flow completes successfully

---

### Error: Key Vault access denied

**Error Message:**
```
Access denied: The user or application does not have access to the Key Vault
```

**Root Cause:**
The Power Platform service principal or the Azure AD application used by the flow doesn't have appropriate permissions on the Key Vault.

**Resolution:**

1. **Configure Key Vault Access Policy**
   - Go to Azure Portal > Key Vaults > Select your Key Vault
   - Go to "Access policies"
   - Click "Create" or "Add Access Policy"

2. **Set Secret Permissions**
   - Under "Secret permissions", select at minimum:
     - Get
     - List

3. **Select Principal**
   - For CoE flows using environment variables with Key Vault reference:
     - Search for "Microsoft.PowerPlatform"
     - Select the service principal
   - For flows using HTTP with Azure AD connector:
     - Search for your Azure AD application name or App ID
     - Select your application

4. **Review and Create**
   - Click "Next" through any additional screens
   - Click "Create" to save the access policy

5. **Verify RBAC Model (if using)**
   - If your Key Vault uses Azure RBAC instead of access policies:
     - Go to Key Vault > "Access control (IAM)"
     - Click "Add role assignment"
     - Select "Key Vault Secrets User" role
     - Assign to "Microsoft.PowerPlatform" service principal or your Azure AD application

---

## Flow Authentication Errors

### Issue: Subscription was disabled

**Error Message:**
```
The subscription was disabled.
```

**Root Cause:**
The Office 365 Management API subscription for audit logs has been disabled or wasn't properly initialized.

**Resolution:**

1. **Run the Setup Flow**
   - Navigate to the "Admin | Audit Logs | Start Audit Log subscription" flow
   - Run the flow manually
   - Wait for successful completion

2. **Verify Subscription Status**
   - The flow should create or re-enable the subscription
   - Check the flow run history for any errors
   - If errors persist, ensure the Azure AD application has the necessary API permissions:
     - Office 365 Management APIs: ActivityFeed.Read
     - Office 365 Management APIs: ActivityFeed.ReadDlp
     - Office 365 Management APIs: ServiceHealth.Read

3. **Grant Admin Consent**
   - Go to Azure Portal > Azure Active Directory > App registrations
   - Select your Audit Log app
   - Go to "API permissions"
   - Click "Grant admin consent for {your-organization}"

---

## Common Setup Issues

### Issue: Environment variable not resolving Key Vault reference

**Symptoms:**
- Environment variable shows the Key Vault reference string instead of the actual secret value
- Flows fail with authentication errors

**Root Cause:**
- Key Vault reference syntax is incorrect
- Insufficient permissions
- Microsoft.PowerPlatform provider not registered

**Resolution:**

1. **Verify Environment Variable Syntax**
   The correct format for Key Vault reference in environment variables:
   ```json
   {
     "KeyVaultReference": {
       "KeyVaultUrl": "https://{vault-name}.vault.azure.net/secrets/{secret-name}/{version}",
       "ResourceId": "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.KeyVault/vaults/{vault-name}"
     }
   }
   ```
   
   Or the simplified format:
   ```
   /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.KeyVault/vaults/{vault-name}/secrets/{secret-name}
   ```

2. **Verify Permissions**
   - Ensure Microsoft.PowerPlatform provider is registered (see main section above)
   - Verify Key Vault access policies are configured correctly
   - Check that the Key Vault is not behind a firewall that blocks Power Platform

3. **Test the Configuration**
   - Update the environment variable value
   - Save the changes
   - Wait 5-10 minutes for changes to propagate
   - Run the flow again

---

### Issue: Audit logs not appearing in CoE Dashboard

**Symptoms:**
- Flows run successfully
- No errors reported
- Audit data is not visible in the CoE Dashboard or Dataverse tables

**Possible Causes and Solutions:**

1. **Data Sync Timing**
   - Office 365 audit logs can have a delay of up to 24 hours
   - Check back after 24-48 hours to see if data appears

2. **Verify Flow Execution**
   - Check "Admin | Audit Logs | Sync Audit Logs" flow run history
   - Verify the "Get Logs" action returns data
   - Check for any errors in downstream actions

3. **Check Data in Dataverse**
   - Go to Power Apps > Tables
   - Find the "Audit Log" table (or equivalent)
   - Check if records are being created
   - If records exist but don't show in Power BI, refresh the Power BI report

4. **Licensing Requirements**
   - Ensure you have the appropriate Office 365 licenses for audit logging
   - Office 365 E3/E5 or Microsoft 365 E3/E5 typically required
   - Verify audit logging is enabled in Microsoft 365 Compliance Center

---

## Additional Resources

- **Official Documentation**: https://docs.microsoft.com/power-platform/guidance/coe/setup-auditlog
- **CoE Starter Kit GitHub**: https://github.com/microsoft/coe-starter-kit
- **Power Platform Admin Center**: https://admin.powerplatform.microsoft.com
- **Azure Portal**: https://portal.azure.com
- **Office 365 Compliance**: https://compliance.microsoft.com

## Getting Help

If you continue to experience issues after following this troubleshooting guide:

1. **Check Existing Issues**: Search the [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
2. **Create a New Issue**: If your issue isn't already reported, [create a new issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) using the bug report template
3. **Community Support**: Ask questions in the [Power Platform Community Forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

## Document Information

**Last Updated**: 2025-11-03  
**Applies To**: CoE Starter Kit v4.x and later  
**Component**: Audit Log Components
