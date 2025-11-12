# Azure Key Vault Setup Guide for CoE Audit Logs

This guide provides step-by-step instructions for properly configuring Azure Key Vault to work with CoE Audit Log components.

## Prerequisites

- Azure subscription with appropriate permissions (Contributor or Owner role)
- Access to Power Platform environment where CoE is installed
- Azure AD application registration for Audit Logs
- Client secret value from the Azure AD app registration

## Step-by-Step Setup

### 1. Register Microsoft.PowerPlatform Resource Provider

**⚠️ CRITICAL STEP**: This must be completed BEFORE attempting to use Key Vault references in Power Platform environment variables.

#### Via Azure Portal

1. Sign in to [Azure Portal](https://portal.azure.com)
2. Navigate to **Subscriptions**
3. Select the subscription containing your Key Vault
4. In the left menu, select **Resource providers** (under Settings)
5. Search for `Microsoft.PowerPlatform`
6. If the status is "NotRegistered":
   - Select the provider
   - Click **Register**
   - Wait 5-10 minutes for registration to complete
7. Refresh until status shows **Registered**

#### Via Azure CLI

```bash
# Login
az login

# Set subscription
az account set --subscription "YOUR-SUBSCRIPTION-ID"

# Register provider
az provider register --namespace Microsoft.PowerPlatform

# Check status (repeat until Registered)
az provider show --namespace Microsoft.PowerPlatform --query "registrationState"
```

#### Via PowerShell

```powershell
# Login
Connect-AzAccount

# Set subscription
Set-AzContext -SubscriptionId "YOUR-SUBSCRIPTION-ID"

# Register provider
Register-AzResourceProvider -ProviderNamespace Microsoft.PowerPlatform

# Check status
Get-AzResourceProvider -ProviderNamespace Microsoft.PowerPlatform
```

---

### 2. Create or Configure Key Vault

#### Create New Key Vault (if needed)

```bash
# Via Azure CLI
az keyvault create \
  --name "YOUR-KEYVAULT-NAME" \
  --resource-group "YOUR-RESOURCE-GROUP" \
  --location "eastus" \
  --enable-rbac-authorization false
```

#### Configure Existing Key Vault

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Key Vaults**
3. Select your Key Vault
4. Note the following information (you'll need this later):
   - Vault URI: `https://YOUR-VAULT.vault.azure.net/`
   - Resource ID: `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.KeyVault/vaults/{vault-name}`

---

### 3. Configure Key Vault Access

You have two options: Access Policies (traditional) or Azure RBAC (newer approach).

#### Option A: Using Access Policies (Recommended for Power Platform)

1. In your Key Vault, go to **Access policies**
2. Click **Create**
3. Configure permissions:
   - **Secret permissions**: Select `Get` and `List`
4. Click **Next**
5. Search for and select **Microsoft.PowerPlatform**
   - If you don't see this, ensure Step 1 (register provider) is complete
6. Click **Next**, then **Create**

#### Option B: Using Azure RBAC

1. In your Key Vault, go to **Access control (IAM)**
2. Click **Add** > **Add role assignment**
3. Select role: **Key Vault Secrets User**
4. Click **Next**
5. Click **Select members**
6. Search for **Microsoft.PowerPlatform**
7. Select it and click **Select**
8. Click **Review + assign**

---

### 4. Store the Client Secret in Key Vault

1. In your Key Vault, go to **Secrets**
2. Click **Generate/Import**
3. Configure the secret:
   - **Upload options**: Manual
   - **Name**: `COEAuditID` (or your preferred name)
   - **Value**: Paste the client secret VALUE from your Azure AD app registration
     - ⚠️ **Important**: Use the secret VALUE, not the Secret ID
     - The value looks like: `aBc123~dEf456GhI789JkL012MnO345PqR678`
     - The ID looks like: `12345678-1234-1234-1234-123456789012`
   - **Content type**: Leave empty or add description
   - **Enabled**: Yes
4. Click **Create**
5. After creation, click on the secret name
6. Click on the current version
7. Copy the **Secret Identifier** (e.g., `https://your-vault.vault.azure.net/secrets/COEAuditID/abc123def456`)

---

### 5. Configure Power Platform Environment Variable

#### Option 1: Using Azure Key Vault Reference (Recommended)

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Navigate to your CoE environment
3. Go to **Settings** > **Environment variables**
4. Find the variable for your Audit Log client secret (e.g., `Audit Client Secret`)
5. Edit the variable and set the value using one of these formats:

**Full JSON Format:**
```json
{
  "KeyVaultReference": {
    "KeyVaultUrl": "https://your-vault.vault.azure.net/secrets/COEAuditID",
    "ResourceId": "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.KeyVault/vaults/{vault-name}"
  }
}
```

**Simplified Format:**
```
/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.KeyVault/vaults/{vault-name}/secrets/COEAuditID
```

6. Save the changes
7. Wait 5-10 minutes for the changes to propagate

#### Option 2: Direct Secret Value (Less Secure)

If Key Vault integration doesn't work or isn't suitable:

1. Navigate to your environment
2. Open the CoE solution
3. Find the environment variable
4. Paste the client secret VALUE directly
5. Save

**⚠️ Note**: This stores the secret in plain text and is less secure than Key Vault.

---

### 6. Verify the Configuration

#### Test 1: Check Environment Variable Resolution

1. In Power Apps, go to **Solutions**
2. Open your CoE solution
3. Go to **Environment variables**
4. Open the variable you configured
5. The "Current Value" should show:
   - If using Key Vault: `[Reference to Key Vault secret]` or similar indicator
   - If using direct value: The masked secret value

#### Test 2: Run the Flow

1. Go to Power Automate
2. Find "Admin | Audit Logs | Office 365 Management API | Subscription"
3. Click **Run** to test manually
4. Check the run history:
   - ✅ **Success**: Configuration is correct
   - ❌ **Failed**: Check the error message and refer to [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

## Common Configuration Mistakes

### ❌ Wrong Secret Value
- **Mistake**: Using the Secret ID instead of Secret VALUE
- **Symptom**: "Invalid client secret provided" error
- **Fix**: Use the secret value (the long random string shown only once when created)

### ❌ Provider Not Registered
- **Mistake**: Skipping Step 1 (registering Microsoft.PowerPlatform provider)
- **Symptom**: "Make sure that Microsoft.PowerPlatform provider is registered" error
- **Fix**: Complete Step 1 above and wait 5-10 minutes

### ❌ Missing Permissions
- **Mistake**: Not granting Get/List permissions to Microsoft.PowerPlatform service principal
- **Symptom**: "Access denied" or "Could not verify user permission" errors
- **Fix**: Complete Step 3 above

### ❌ Firewall Blocking Access
- **Mistake**: Key Vault has firewall rules that block Power Platform
- **Symptom**: Timeout or access denied errors
- **Fix**: In Key Vault > Networking, ensure "Allow public access from all networks" is enabled, or add Power Platform service IPs

### ❌ Wrong Subscription/Resource Group
- **Mistake**: Using incorrect subscription ID or resource group in the environment variable reference
- **Symptom**: "Resource not found" or "Invalid resource ID" errors
- **Fix**: Double-check the Resource ID format matches your actual Azure resources

---

## Security Best Practices

1. **Use Managed Identities When Possible**
   - For supported scenarios, use system-assigned or user-assigned managed identities instead of client secrets

2. **Rotate Secrets Regularly**
   - Set calendar reminders to rotate secrets before expiration
   - Create new secrets in Azure AD app registration
   - Update Key Vault with new secret values
   - Old secrets will automatically be deprecated

3. **Use Private Endpoints** (Enterprise scenarios)
   - For enhanced security, configure Private Link for Key Vault access
   - Requires additional networking configuration

4. **Monitor Access**
   - Enable diagnostic logging for Key Vault
   - Monitor secret access patterns
   - Set up alerts for suspicious activity

5. **Principle of Least Privilege**
   - Only grant `Get` and `List` permissions on secrets
   - Don't grant broader permissions unless absolutely necessary
   - Regularly audit access policies

---

## Troubleshooting

For detailed troubleshooting steps, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md).

**Quick Checks:**
- ✅ Microsoft.PowerPlatform provider registered?
- ✅ Key Vault access policies configured for Microsoft.PowerPlatform?
- ✅ Using secret VALUE (not ID)?
- ✅ Waited 5-10 minutes after configuration changes?
- ✅ Key Vault not behind restrictive firewall?

---

## Additional Resources

- [Azure Key Vault Documentation](https://docs.microsoft.com/azure/key-vault/)
- [Power Platform Environment Variables with Key Vault](https://docs.microsoft.com/power-apps/maker/data-platform/environmentvariables)
- [CoE Starter Kit Setup Guide](https://docs.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Office 365 Management API](https://docs.microsoft.com/office/office-365-management-api/office-365-management-activity-api-reference)

---

## Getting Help

If you encounter issues:

1. Review the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) guide
2. Search [existing issues](https://github.com/microsoft/coe-starter-kit/issues)
3. Create a [new issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) with:
   - Error messages (redact sensitive info)
   - Steps you've already tried
   - Screenshots of configuration (redact sensitive info)

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-03  
**Maintained By**: CoE Starter Kit Team
