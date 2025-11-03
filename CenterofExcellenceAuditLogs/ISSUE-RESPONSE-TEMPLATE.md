# Issue Response Template

Use this template to respond to Azure Key Vault permission issues in GitHub issues.

---

## Response for "Microsoft.PowerPlatform provider not registered" Error

Hi @[username],

Thank you for reporting this issue. The error you're encountering is a common Azure Key Vault permission issue. The solution involves registering the Microsoft.PowerPlatform resource provider in your Azure subscription.

### Quick Fix

The error message indicates that the **Microsoft.PowerPlatform resource provider** is not registered in your Azure subscription. This is a one-time setup required for Power Platform to access Azure Key Vault resources.

**To fix this:**

1. **Go to Azure Portal** → https://portal.azure.com
2. Navigate to **Subscriptions** → Select the subscription where your Key Vault is located
3. In the left menu under **Settings**, click **Resource providers**
4. Search for `Microsoft.PowerPlatform`
5. If the status shows "NotRegistered":
   - Select the provider
   - Click **Register** at the top
   - Wait 5-10 minutes for registration to complete

**Alternative: Using Azure CLI**
```bash
az provider register --namespace Microsoft.PowerPlatform
```

**Alternative: Using PowerShell**
```powershell
Register-AzResourceProvider -ProviderNamespace Microsoft.PowerPlatform
```

### After Registration

1. Wait 5-10 minutes for the registration to fully propagate
2. Go back to your failed flow run in Power Automate
3. Click **Resubmit**
4. The flow should now successfully retrieve the secret ✅

### Additional Configuration

You should also verify that your Key Vault has the proper access policies:

1. Go to your Key Vault in Azure Portal
2. Navigate to **Access policies**
3. Ensure `Microsoft.PowerPlatform` is listed with at minimum:
   - **Get** (secret permissions)
   - **List** (secret permissions)

If it's not listed, add it as described in our setup guide.

### Documentation

We've created comprehensive documentation to help with this and other common issues:

- **[Quick Fix Guide](./QUICK-FIX.md)** - Fast solution for this specific error
- **[Troubleshooting Guide](./TROUBLESHOOTING.md)** - Solutions for all common issues
- **[Azure Key Vault Setup Guide](./AZURE-KEYVAULT-SETUP.md)** - Complete setup instructions
- **[README](./README.md)** - Overview and architecture

### Why This Happens

The Microsoft.PowerPlatform resource provider registration is required for Power Platform services to interact with Azure resources. This is:
- A one-time setup per Azure subscription
- Independent of Key Vault access policies
- Required even if you have Key Vault permissions configured correctly

### Timeline

- Resource provider registration: 5-10 minutes
- Changes to propagate: 5-10 minutes  
- Total expected time to resolution: 15-20 minutes

Please let us know if this resolves your issue, or if you encounter any other problems!

---

## Response for "Invalid Client Secret" Error

Hi @[username],

Thank you for reporting this issue. The error indicates that the wrong value is being used for the client secret.

### Common Mistake

When configuring Azure Key Vault with the client secret, you must use the **secret VALUE**, not the **secret ID**.

**Secret VALUE** (correct):
- Looks like: `aBc123~dEf456GhI789JkL012MnO345PqR678`
- Only shown once when the secret is created
- This is what should be stored in Key Vault

**Secret ID** (incorrect):
- Looks like: `12345678-1234-1234-1234-123456789012`
- Always visible in Azure AD app registration
- This will cause authentication to fail

### Solution

1. **Go to Azure Portal** → Azure Active Directory → App registrations
2. Select your Audit Log app registration
3. Go to **Certificates & secrets**
4. Create a new client secret:
   - Click **New client secret**
   - Add description: "CoE Audit Log - PROD"
   - Select expiration period
   - Click **Add**
   - **IMPORTANT**: Immediately copy the secret **VALUE** (not the ID)

5. **Update Key Vault**:
   - Go to your Key Vault → Secrets
   - Select your audit secret (e.g., "COEAuditID")
   - Click **New Version**
   - Paste the secret VALUE
   - Click **Create**

6. **Test the flow** after 5-10 minutes

For detailed instructions, see our [Azure Key Vault Setup Guide](./AZURE-KEYVAULT-SETUP.md).

Please let us know if this resolves your issue!

---

## Response for General Key Vault Issues

Hi @[username],

Thank you for reporting this issue. We've recently added comprehensive documentation to help troubleshoot Azure Key Vault configuration issues with the CoE Audit Log components.

### Quick Checklist

Please verify the following:

- [ ] Microsoft.PowerPlatform resource provider is registered in Azure subscription
- [ ] Key Vault access policy includes Microsoft.PowerPlatform with Get + List permissions
- [ ] Using the client secret VALUE (not the secret ID) in Key Vault
- [ ] Environment variable correctly references the Key Vault secret
- [ ] Waited 5-10 minutes after making configuration changes

### Documentation

We've created detailed guides to help:

1. **[Quick Fix Guide](./QUICK-FIX.md)** - Fast solution for the most common error
2. **[Troubleshooting Guide](./TROUBLESHOOTING.md)** - Comprehensive troubleshooting for all common issues including:
   - Microsoft.PowerPlatform provider registration
   - Invalid client secret errors
   - Key Vault access denied errors
   - Subscription disabled errors
   - Missing audit log data

3. **[Azure Key Vault Setup Guide](./AZURE-KEYVAULT-SETUP.md)** - Complete step-by-step setup instructions

4. **[README](./README.md)** - Architecture overview and quick start

### Next Steps

1. Review the [Troubleshooting Guide](./TROUBLESHOOTING.md) for your specific error
2. Follow the recommended solution steps
3. If the issue persists, please provide:
   - The exact error message (redact sensitive information)
   - Which troubleshooting steps you've already tried
   - Screenshots of your configuration (redact sensitive information)

We're here to help! Please let us know if you have any questions.

---

**Note to Maintainers**: When responding to issues, personalize the response by:
1. Addressing the user by their GitHub handle
2. Referencing specific error messages from their issue
3. Linking to the relevant documentation sections
4. Offering to help if the documented solutions don't work
